From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 05/15] via-rhine: Spelling/phrases cleanup.
Date: Mon, 31 Dec 2012 16:25:39 +0100
Message-ID: <1356967549-5056-6-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54114 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab2LaPep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:45 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 2d410ec..4162649 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -83,7 +83,7 @@ static const int multicast_filter_limit = 32;
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT	(2*HZ)
 
-#define PKT_BUF_SZ	1536	/* Size of each temporary Rx buffer.*/
+#define PKT_BUF_SZ	1536	/* Size of each temporary Rx buffer. */
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -264,7 +264,7 @@ enum rhine_quirks {
 /*
  * rqRhineI: VT86C100A (aka Rhine-I) uses different bits to enable
  * MMIO as well as for the collision counter and the Tx FIFO underflow
- * indicator. In addition, Tx and Rx buffers need to 4 byte aligned.
+ * indicator. In addition, Tx and Rx buffers need to be 4 byte aligned.
  */
 
 /* Beware of PCI posted writes */
@@ -1266,7 +1266,7 @@ static void rhine_set_carrier(struct mii_if_info *mii)
 		/* autoneg is off: Link is always assumed to be up */
 		if (!netif_carrier_ok(dev))
 			netif_carrier_on(dev);
-	} else	/* Let MMI library update carrier status */
+	} else	/* Let MII library update carrier status */
 		rhine_check_media(dev, 0);
 
 	netif_info(rp, link, dev, "force_media %d, carrier %d\n",
@@ -1649,7 +1649,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	void __iomem *ioaddr = rp->base;
 	unsigned entry;
 
-	/* Caution: the write order is important here, set the field
+	/* Caution: the write order is important here - set the field
 	   with the "ownership" bits last. */
 
 	/* Calculate the next Tx descriptor entry. */
@@ -1868,7 +1868,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 					    &rp->rx_ring[entry]);
 				dev->stats.rx_length_errors++;
 			} else if (desc_status & RxErr) {
-				/* There was a error. */
+				/* There was an error. */
 				netif_dbg(rp, rx_err, dev,
 					  "%s() Rx error %08x\n", __func__,
 					  desc_status);
-- 
1.7.2.5
