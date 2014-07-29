From: Brian Norris <computersforpeace@gmail.com>
Subject: [PATCH] net: bcmgenet: correct spelling
Date: Tue, 29 Jul 2014 14:18:13 -0700
Message-ID: <1406668693-2084-1-git-send-email-computersforpeace@gmail.com>
Cc: Brian Norris <computersforpeace@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:65531 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbaG2VSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 17:18:25 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so278986pab.2
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 14:18:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Brian Norris <computersforpeace@gmail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 16281ad2da12..61cf87fc4d81 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -98,7 +98,7 @@ static inline void dmadesc_set_addr(struct bcmgenet_priv *priv,
 
 	/* Register writes to GISB bus can take couple hundred nanoseconds
 	 * and are done for each packet, save these expensive writes unless
-	 * the platform is explicitely configured for 64-bits/LPAE.
+	 * the platform is explicitly configured for 64-bits/LPAE.
 	 */
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (priv->hw_params->flags & GENET_HAS_40BITS)
@@ -123,7 +123,7 @@ static inline dma_addr_t dmadesc_get_addr(struct bcmgenet_priv *priv,
 
 	/* Register writes to GISB bus can take couple hundred nanoseconds
 	 * and are done for each packet, save these expensive writes unless
-	 * the platform is explicitely configured for 64-bits/LPAE.
+	 * the platform is explicitly configured for 64-bits/LPAE.
 	 */
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (priv->hw_params->flags & GENET_HAS_40BITS)
@@ -879,7 +879,7 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 	struct netdev_queue *txq;
 	unsigned int c_index;
 
-	/* Compute how many buffers are transmited since last xmit call */
+	/* Compute how many buffers are transmitted since last xmit call */
 	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX);
 	txq = netdev_get_tx_queue(dev, ring->queue);
 
@@ -1008,7 +1008,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 	return 0;
 }
 
-/* Transmit a SKB fragement */
+/* Transmit a SKB fragment */
 static int bcmgenet_xmit_frag(struct net_device *dev,
 				skb_frag_t *frag,
 				u16 dma_desc_flags,
@@ -1318,7 +1318,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 
 		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
 			netif_err(priv, rx_status, dev,
-					"Droping fragmented packet!\n");
+					"Dropping fragmented packet!\n");
 			dev->stats.rx_dropped++;
 			dev->stats.rx_errors++;
 			dev_kfree_skb_any(cb->skb);
@@ -1462,7 +1462,7 @@ static int reset_umac(struct bcmgenet_priv *priv)
 
 	if (timeout == 1000) {
 		dev_err(kdev,
-			"timeout waiting for MAC to come out of resetn\n");
+			"timeout waiting for MAC to come out of reset\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1506,7 +1506,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 
 	dev_dbg(kdev, "%s:Enabling RXDMA_BDONE interrupt\n", __func__);
 
-	/* Monitor cable plug/unpluged event for internal PHY */
+	/* Monitor cable plug/unplugged event for internal PHY */
 	if (phy_is_internal(priv->phydev))
 		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
 	else if (priv->ext_phy)
@@ -1681,7 +1681,7 @@ static void bcmgenet_init_multiq(struct net_device *dev)
 					i * priv->hw_params->bds_cnt,
 					(i + 1) * priv->hw_params->bds_cnt);
 
-		/* Configure ring as decriptor ring and setup priority */
+		/* Configure ring as descriptor ring and setup priority */
 		ring_cfg |= 1 << i;
 		dma_priority |= ((GENET_Q0_PRIORITY + i) <<
 				(GENET_MAX_MQ_CNT + 1) * i);
@@ -1747,7 +1747,7 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 	/* Init tDma */
 	bcmgenet_tdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
 
-	/* Initialize commont TX ring structures */
+	/* Initialize common TX ring structures */
 	priv->tx_bds = priv->base + priv->hw_params->tdma_offset;
 	priv->num_tx_bds = TOTAL_DESC;
 	priv->tx_cbs = kzalloc(priv->num_tx_bds * sizeof(struct enet_cb),
@@ -1821,7 +1821,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 	priv->irq1_stat =
 		bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
 		~priv->int1_mask;
-	/* clear inerrupts*/
+	/* clear interrupts */
 	bcmgenet_intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
@@ -1849,7 +1849,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	priv->irq0_stat =
 		bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_STAT) &
 		~bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
-	/* clear inerrupts*/
+	/* clear interrupts */
 	bcmgenet_intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
@@ -2214,7 +2214,7 @@ static void bcmgenet_set_rx_mode(struct net_device *dev)
 
 	netif_dbg(priv, hw, dev, "%s: %08X\n", __func__, dev->flags);
 
-	/* Promiscous mode */
+	/* Promiscuous mode */
 	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
 	if (dev->flags & IFF_PROMISC) {
 		reg |= CMD_PROMISC;
-- 
1.9.1
