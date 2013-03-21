From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/3] gianfar: Cleanup dead code and minor formatting
Date: Thu, 21 Mar 2013 15:12:14 +0200
Message-ID: <1363871535-29612-2-git-send-email-claudiu.manoil@freescale.com>
References: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:42080
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755823Ab3CUNM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 09:12:29 -0400
In-Reply-To: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 37fbf67..434b31b 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -690,7 +690,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	}
 
 	for (i = 0; i < priv->num_tx_queues; i++)
-	       priv->tx_queue[i] = NULL;
+		priv->tx_queue[i] = NULL;
 	for (i = 0; i < priv->num_rx_queues; i++)
 		priv->rx_queue[i] = NULL;
 
@@ -1824,6 +1824,7 @@ static void gfar_configure_coalescing(struct gfar_private *priv,
 
 	if (priv->mode == MQ_MG_MODE) {
 		int i = 0;
+
 		baddr = &regs->txic0;
 		for_each_set_bit(i, &tx_mask, priv->num_tx_queues) {
 			gfar_write(baddr + i, 0);
@@ -1838,7 +1839,7 @@ static void gfar_configure_coalescing(struct gfar_private *priv,
 				gfar_write(baddr + i, priv->rx_queue[i]->rxic);
 		}
 	} else {
-		/* Backward compatible case ---- even if we enable
+		/* Backward compatible case -- even if we enable
 		 * multiple queues, there's only single reg to program
 		 */
 		gfar_write(&regs->txic, 0);
@@ -2478,7 +2479,6 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	struct net_device *dev = tx_queue->dev;
 	struct netdev_queue *txq;
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct txbd8 *bdp, *next = NULL;
 	struct txbd8 *lbdp = NULL;
 	struct txbd8 *base = tx_queue->tx_bd_base;
@@ -2493,7 +2493,6 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	u32 lstatus;
 	size_t buflen;
 
-	rx_queue = priv->rx_queue[tqi];
 	txq = netdev_get_tx_queue(dev, tqi);
 	bdp = tx_queue->dirty_tx;
 	skb_dirtytx = tx_queue->skb_dirtytx;
-- 
1.7.11.3
