From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 31/42] vhost/net: enable virtio 1.0
Date: Tue, 25 Nov 2014 18:43:35 +0200
Message-ID: <1416933600-21398-32-git-send-email-mst@redhat.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416933600-21398-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 1ac58d0..984242e 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -61,7 +61,8 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
 enum {
 	VHOST_NET_FEATURES = VHOST_FEATURES |
 			 (1ULL << VHOST_NET_F_VIRTIO_NET_HDR) |
-			 (1ULL << VIRTIO_NET_F_MRG_RXBUF),
+			 (1ULL << VIRTIO_NET_F_MRG_RXBUF) |
+			 (1ULL << VIRTIO_F_VERSION_1),
 };
 
 enum {
-- 
MST
