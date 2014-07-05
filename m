From: Asias He <asias.hejun@gmail.com>
Subject: [RFC V2 7/7] Disable debug
Date: Sat,  5 Jul 2014 11:23:16 +0800
Message-ID: <1ffda5764d2e4466765dc463e61c5591d680522d.1404529115.git.asias.hejun@gmail.com>
References: <cover.1404529115.git.asias.hejun@gmail.com>
To: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <cover.1404529115.git.asias.hejun@gmail.com>
In-Reply-To: <cover.1404529115.git.asias.hejun@gmail.com>
References: <cover.1404529115.git.asias.hejun@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>

Signed-off-by: Asias He <asias@redhat.com>
---
 drivers/vhost/Makefile | 1 -
 net/vmw_vsock/Makefile | 2 --
 2 files changed, 3 deletions(-)

diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
index eccff51..6b012b9 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -6,7 +6,6 @@ vhost_scsi-y := scsi.o
 
 obj-$(CONFIG_VHOST_VSOCK) += vhost_vsock.o
 vhost_vsock-y := vsock.o
-CFLAGS_vsock.o := -DDEBUG
 
 obj-$(CONFIG_VHOST_RING) += vringh.o
 
diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
index a8fea3af..cf4c294 100644
--- a/net/vmw_vsock/Makefile
+++ b/net/vmw_vsock/Makefile
@@ -2,8 +2,6 @@ obj-$(CONFIG_VSOCKETS) += vsock.o
 obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
 obj-$(CONFIG_VIRTIO_VSOCKETS) += virtio_transport.o
 obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += virtio_transport_common.o
-CFLAGS_virtio_transport.o := -DDEBUG
-CFLAGS_virtio_transport_common.o := -DDEBUG
 
 vsock-y += af_vsock.o vsock_addr.o
 
-- 
1.9.3

