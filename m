From: Aurelien Jarno <aurelien@aurel32.net>
Subject: [PATCH] virtio-net: fix a typo
Date: Mon, 17 Jan 2011 09:14:19 +0100
Message-ID: <1295252059-27438-1-git-send-email-aurelien@aurel32.net>
Cc: Aurelien Jarno <aurelien@aurel32.net>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fitler -> filter

Cc: netdev@vger.kernel.org
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 90a23e4..48a4297 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -787,7 +787,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
 				  VIRTIO_NET_CTRL_MAC_TABLE_SET,
 				  sg, 2, 0))
-		dev_warn(&dev->dev, "Failed to set MAC fitler table.\n");
+		dev_warn(&dev->dev, "Failed to set MAC filter table.\n");
 
 	kfree(buf);
 }
-- 
1.7.2.3
