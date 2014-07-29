From: Brian Norris <computersforpeace@gmail.com>
Subject: [PATCH net-next v2] net: bcmgenet: correct spelling
Date: Tue, 29 Jul 2014 14:34:14 -0700
Message-ID: <1406669654-18119-1-git-send-email-computersforpeace@gmail.com>
References: <1406668693-2084-1-git-send-email-computersforpeace@gmail.com>
Cc: Brian Norris <computersforpeace@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:45127 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaG2Veg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 17:34:36 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so290474pad.25
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 14:34:36 -0700 (PDT)
In-Reply-To: <1406668693-2084-1-git-send-email-computersforpeace@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Brian Norris <computersforpeace@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
---
v2: * Correct the 'Cc:' comment
    * Rebase to next-next.git

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 28c8111502cd..8a047a13e602 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -89,7 +89,7 @@ static inline void dmadesc_set_addr(struct bcmgenet_priv *priv,
 
 	/* Register writes to GISB bus can take couple hundred nanoseconds
 	 * and are done for each packet, save these expensive writes unless
-	 * the platform is explicitely configured for 64-bits/LPAE.
+	 * the platform is explicitly configured for 64-bits/LPAE.
 	 */
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (priv->hw_params->flags & GENET_HAS_40BITS)
@@ -114,7 +114,7 @@ static inline dma_addr_t dmadesc_get_addr(struct bcmgenet_priv *priv,
 
 	/* Register writes to GISB bus can take couple hundred nanoseconds
 	 * and are done for each packet, save these expensive writes unless
-	 * the platform is explicitely configured for 64-bits/LPAE.
+	 * the platform is explicitly configured for 64-bits/LPAE.
 	 */
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (priv->hw_params->flags & GENET_HAS_40BITS)
@@ -876,7 +876,7 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 	struct netdev_queue *txq;
 	unsigned int c_index;
 
-	/* Compute how many buffers are transmited since last xmit call */
+	/* Compute how many buffers are transmitted since last xmit call */
 	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX);
 	txq = netdev_get_tx_queue(dev, ring->queue);
 
@@ -1005,7 +1005,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 	return 0;
 }
 
-/* Transmit a SKB fragement */
+/* Transmit a SKB fragment */
 static int bcmgenet_xmit_frag(struct net_device *dev,
 			      skb_frag_t *frag,
 			      u16 dma_desc_flags,
@@ -1476,7 +1476,7 @@ static int reset_umac(struct bcmgenet_priv *priv)
 
 	if (timeout == 1000) {
 		dev_err(kdev,
-			"timeout waiting for MAC to come out of resetn\n");
+			"timeout waiting for MAC to come out of reset\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1529,7 +1529,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 
 	dev_dbg(kdev, "%s:Enabling RXDMA_BDONE interrupt\n", __func__);
 
-	/* Monitor cable plug/unpluged event for internal PHY */
+	/* Monitor cable plug/unplugged event for internal PHY */
 	if (phy_is_internal(priv->phydev)) {
 		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
 	} else if (priv->ext_phy) {
@@ -1704,7 +1704,7 @@ static void bcmgenet_init_multiq(struct net_device *dev)
 				      i * priv->hw_params->bds_cnt,
 				      (i + 1) * priv->hw_params->bds_cnt);
 
-		/* Configure ring as decriptor ring and setup priority */
+		/* Configure ring as descriptor ring and setup priority */
 		ring_cfg |= 1 << i;
 		dma_priority |= ((GENET_Q0_PRIORITY + i) <<
 				(GENET_MAX_MQ_CNT + 1) * i);
@@ -1770,7 +1770,7 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 	/* Init tDma */
 	bcmgenet_tdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
 
-	/* Initialize commont TX ring structures */
+	/* Initialize common TX ring structures */
 	priv->tx_bds = priv->base + priv->hw_params->tdma_offset;
 	priv->num_tx_bds = TOTAL_DESC;
 	priv->tx_cbs = kcalloc(priv->num_tx_bds, sizeof(struct enet_cb),
@@ -1852,7 +1852,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 	priv->irq1_stat =
 		bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
 		~priv->int1_mask;
-	/* clear inerrupts*/
+	/* clear interrupts */
 	bcmgenet_intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
@@ -1880,7 +1880,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	priv->irq0_stat =
 		bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_STAT) &
 		~bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
-	/* clear inerrupts*/
+	/* clear interrupts */
 	bcmgenet_intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
@@ -2239,7 +2239,7 @@ static void bcmgenet_set_rx_mode(struct net_device *dev)
 
 	netif_dbg(priv, hw, dev, "%s: %08X\n", __func__, dev->flags);
 
-	/* Promiscous mode */
+	/* Promiscuous mode */
 	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
 	if (dev->flags & IFF_PROMISC) {
 		reg |= CMD_PROMISC;
-- 
1.9.1
