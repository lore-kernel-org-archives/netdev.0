From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] VSOCK: mark virtio_transport.ko experimental
Date: Fri,  4 Dec 2015 11:49:18 +0800
Message-ID: <1449200958-18810-1-git-send-email-stefanha@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Be explicit that the virtio_transport.ko code implements a draft virtio
specification that is still subject to change.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
If you'd rather wait until the device specification has been finalized, feel
free to revert the virtio-vsock code for now.  Apologies for not mentioning the
status in the Kconfig earlier.

 net/vmw_vsock/Kconfig | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index 74e0bc8..d8be850 100644
--- a/net/vmw_vsock/Kconfig
+++ b/net/vmw_vsock/Kconfig
@@ -28,12 +28,17 @@ config VMWARE_VMCI_VSOCKETS
 	  will be called vmw_vsock_vmci_transport. If unsure, say N.
 
 config VIRTIO_VSOCKETS
-	tristate "virtio transport for Virtual Sockets"
+	tristate "virtio transport for Virtual Sockets (Experimental)"
 	depends on VSOCKETS && VIRTIO
 	select VIRTIO_VSOCKETS_COMMON
+	default n
 	help
 	  This module implements a virtio transport for Virtual Sockets.
 
+	  This feature is based on a draft of the virtio-vsock device
+	  specification that is still subject to change.  It can be used
+	  to begin developing applications that use Virtual Sockets.
+
 	  Enable this transport if your Virtual Machine runs on Qemu/KVM.
 
 	  To compile this driver as a module, choose M here: the module
-- 
2.5.0

