From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 1/2] net:treewide: Fix typo in drivers/net
Date: Mon, 27 Apr 2015 23:14:57 +0900
Message-ID: <1430144098-4933-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Larry.Finger@lwfinger.net,
	rdunlap@infradead.org, trivial@kernel.org,
	chaoming_li@realsil.com.cn, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix spelling typo in printk.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/can/usb/kvaser_usb.c   | 2 +-
 drivers/net/ethernet/8390/etherh.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 4643914..8b17a90 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1102,7 +1102,7 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
 
 	if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
 					 MSG_FLAG_NERR)) {
-		netdev_err(priv->netdev, "Unknow error (flags: 0x%02x)\n",
+		netdev_err(priv->netdev, "Unknown error (flags: 0x%02x)\n",
 			   msg->u.rx_can_header.flag);
 
 		stats->rx_errors++;
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index b36ee9e..d686b9c 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -523,7 +523,7 @@ static int etherh_addr(char *addr, struct expansion_card *ec)
 	char *s;
 	
 	if (!ecard_readchunk(&cd, ec, 0xf5, 0)) {
-		printk(KERN_ERR "%s: unable to read podule description string\n",
+		printk(KERN_ERR "%s: unable to read module description string\n",
 		       dev_name(&ec->dev));
 		goto no_addr;
 	}
-- 
2.4.0.rc3.3.g6eb1401
