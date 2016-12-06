From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 08/10] vsock/virtio: mark an internal function static
Date: Tue, 6 Dec 2016 17:41:00 +0200
Message-ID: <1481038106-24899-9-git-send-email-mst@redhat.com>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        "David S. Miller" <davem@davemloft.net>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481038106-24899-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio_transport_alloc_pkt is only used locally, make it static.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/vmw_vsock/virtio_transport_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index a53b3a1..6120384 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -32,7 +32,7 @@ static const struct virtio_transport *virtio_transport_get_ops(void)
 	return container_of(t, struct virtio_transport, transport);
 }
 
-struct virtio_vsock_pkt *
+static struct virtio_vsock_pkt *
 virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
 			   size_t len,
 			   u32 src_cid,
-- 
MST
