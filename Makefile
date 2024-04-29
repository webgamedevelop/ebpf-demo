OS ?= linux
ARCH ?= amd64 # amd64|arm64

CONTAINER_TOOL ?= docker

##@ General
.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development
.PHONY: generate
generate: ## Run `go generate` in a Docker container.
	$(CONTAINER_TOOL) buildx create --name ebpf-obj-builder
	$(CONTAINER_TOOL) buildx use ebpf-obj-builder
	$(CONTAINER_TOOL) buildx build --platform=$(OS)/$(ARCH) --output=. --target=binaries -f Dockerfile-generator .
	$(CONTAINER_TOOL) buildx rm ebpf-obj-builder

.PHONY: build
build: $(LOCALBIN) generate ## Build the application.
	GOOS=$(OS) GOARCH=$(ARCH) go build -o ${LOCALBIN}/ebpf-demo .

## Location to install binaries to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)
