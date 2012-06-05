From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [RFC v2 net-next 1/5] gianfar: whitespace cleanup - pointers and multiplications
Date: Tue,  5 Jun 2012 09:07:12 +0200
Message-ID: <1338880036-11533-2-git-send-email-jan.ceuleers@computer.org>
References: <1338880036-11533-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jiajun Wu <b06378@freescale.com>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:49554 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392Ab2FEHJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 03:09:57 -0400
In-Reply-To: <1338880036-11533-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 drivers/net/ethernet/freescale/gianfar.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 0741ade..5ca7b9e 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -266,8 +266,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		tx_queue->tx_bd_dma_base = addr;
 		tx_queue->dev = ndev;
 		/* enet DMA only understands physical addresses */
-		addr    += sizeof(struct txbd8) *tx_queue->tx_ring_size;
-		vaddr   += sizeof(struct txbd8) *tx_queue->tx_ring_size;
+		addr    += sizeof(struct txbd8) * tx_queue->tx_ring_size;
+		vaddr   += sizeof(struct txbd8) * tx_queue->tx_ring_size;
 	}
 
 	/* Start the rx descriptor ring where the tx ring leaves off */
@@ -276,8 +276,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		rx_queue->rx_bd_base = vaddr;
 		rx_queue->rx_bd_dma_base = addr;
 		rx_queue->dev = ndev;
-		addr    += sizeof (struct rxbd8) * rx_queue->rx_ring_size;
-		vaddr   += sizeof (struct rxbd8) * rx_queue->rx_ring_size;
+		addr    += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
+		vaddr   += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
 	}
 
 	/* Setup the skbuff rings */
@@ -2590,7 +2590,7 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 	gfar_init_rxbdp(rx_queue, bdp, buf);
 }
 
-static struct sk_buff * gfar_alloc_skb(struct net_device *dev)
+static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
@@ -2604,7 +2604,7 @@ static struct sk_buff * gfar_alloc_skb(struct net_device *dev)
 	return skb;
 }
 
-struct sk_buff * gfar_new_skb(struct net_device *dev)
+struct sk_buff *gfar_new_skb(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
@@ -2728,8 +2728,8 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 }
 
 /* gfar_clean_rx_ring() -- Processes each frame in the rx ring
- *   until the budget/quota has been reached. Returns the number
- *   of frames handled
+ * until the budget/quota has been reached. Returns the number
+ * of frames handled
  */
 int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 {
-- 
1.7.9.5
