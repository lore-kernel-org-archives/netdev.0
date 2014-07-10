From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2 v2] net: systemport: align multiple lines correctly
Date: Wed,  9 Jul 2014 17:36:46 -0700
Message-ID: <1404952607-10412-2-git-send-email-f.fainelli@gmail.com>
References: <1404952607-10412-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:55507 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbaGJAhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 20:37:35 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so10150227pab.1
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 17:37:35 -0700 (PDT)
In-Reply-To: <1404952607-10412-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch.pl flagged a bunch of: "CHECK: Alignment should match open
parenthesis" problems, fix all of them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 117 ++++++++++++++---------------
 1 file changed, 58 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 7a1bd2b3bc26..b6e4c7b418be 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -81,14 +81,14 @@ static inline void dma_desc_set_addr(struct bcm_sysport_priv *priv,
 {
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
-			d + DESC_ADDR_HI_STATUS_LEN);
+		     d + DESC_ADDR_HI_STATUS_LEN);
 #endif
 	__raw_writel(lower_32_bits(addr), d + DESC_ADDR_LO);
 }
 
 static inline void tdma_port_write_desc_addr(struct bcm_sysport_priv *priv,
-						struct dma_desc *desc,
-						unsigned int port)
+					     struct dma_desc *desc,
+					     unsigned int port)
 {
 	/* Ports are latched, so write upper address first */
 	tdma_writel(priv, desc->addr_status_len, TDMA_WRITE_PORT_HI(port));
@@ -108,7 +108,7 @@ static int bcm_sysport_set_settings(struct net_device *dev,
 }
 
 static int bcm_sysport_get_settings(struct net_device *dev,
-					struct ethtool_cmd *cmd)
+				    struct ethtool_cmd *cmd)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 
@@ -119,7 +119,7 @@ static int bcm_sysport_get_settings(struct net_device *dev,
 }
 
 static int bcm_sysport_set_rx_csum(struct net_device *dev,
-					netdev_features_t wanted)
+				   netdev_features_t wanted)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	u32 reg;
@@ -145,7 +145,7 @@ static int bcm_sysport_set_rx_csum(struct net_device *dev,
 }
 
 static int bcm_sysport_set_tx_csum(struct net_device *dev,
-					netdev_features_t wanted)
+				   netdev_features_t wanted)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	u32 reg;
@@ -165,7 +165,7 @@ static int bcm_sysport_set_tx_csum(struct net_device *dev,
 }
 
 static int bcm_sysport_set_features(struct net_device *dev,
-					netdev_features_t features)
+				    netdev_features_t features)
 {
 	netdev_features_t changed = features ^ dev->features;
 	netdev_features_t wanted = dev->wanted_features;
@@ -261,7 +261,7 @@ static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
 	/* RXCHK misc statistics */
 	STAT_RXCHK("rxchk_bad_csum", mib.rxchk_bad_csum, RXCHK_BAD_CSUM_CNTR),
 	STAT_RXCHK("rxchk_other_pkt_disc", mib.rxchk_other_pkt_disc,
-			RXCHK_OTHER_DISC_CNTR),
+		   RXCHK_OTHER_DISC_CNTR),
 	/* RBUF misc statistics */
 	STAT_RBUF("rbuf_ovflow_cnt", mib.rbuf_ovflow_cnt, RBUF_OVFL_DISC_CNTR),
 	STAT_RBUF("rbuf_err_cnt", mib.rbuf_err_cnt, RBUF_ERR_PKT_CNTR),
@@ -270,7 +270,7 @@ static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
 #define BCM_SYSPORT_STATS_LEN	ARRAY_SIZE(bcm_sysport_gstrings_stats)
 
 static void bcm_sysport_get_drvinfo(struct net_device *dev,
-					struct ethtool_drvinfo *info)
+				    struct ethtool_drvinfo *info)
 {
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, "0.1", sizeof(info->version));
@@ -303,7 +303,7 @@ static int bcm_sysport_get_sset_count(struct net_device *dev, int string_set)
 }
 
 static void bcm_sysport_get_strings(struct net_device *dev,
-					u32 stringset, u8 *data)
+				    u32 stringset, u8 *data)
 {
 	int i;
 
@@ -311,8 +311,8 @@ static void bcm_sysport_get_strings(struct net_device *dev,
 	case ETH_SS_STATS:
 		for (i = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
 			memcpy(data + i * ETH_GSTRING_LEN,
-				bcm_sysport_gstrings_stats[i].stat_string,
-				ETH_GSTRING_LEN);
+			       bcm_sysport_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
 		}
 		break;
 	default:
@@ -362,7 +362,7 @@ static void bcm_sysport_update_mib_counters(struct bcm_sysport_priv *priv)
 }
 
 static void bcm_sysport_get_stats(struct net_device *dev,
-					struct ethtool_stats *stats, u64 *data)
+				  struct ethtool_stats *stats, u64 *data)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	int i;
@@ -404,7 +404,7 @@ static void bcm_sysport_get_wol(struct net_device *dev,
 }
 
 static int bcm_sysport_set_wol(struct net_device *dev,
-				struct ethtool_wolinfo *wol)
+			       struct ethtool_wolinfo *wol)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	struct device *kdev = &priv->pdev->dev;
@@ -419,9 +419,9 @@ static int bcm_sysport_set_wol(struct net_device *dev,
 	/* Program the SecureOn password */
 	if (wol->wolopts & WAKE_MAGICSECURE) {
 		umac_writel(priv, get_unaligned_be16(&wol->sopass[0]),
-				UMAC_PSW_MS);
+			    UMAC_PSW_MS);
 		umac_writel(priv, get_unaligned_be32(&wol->sopass[2]),
-				UMAC_PSW_LS);
+			    UMAC_PSW_LS);
 	}
 
 	/* Flag the device and relevant IRQ as wakeup capable */
@@ -464,7 +464,7 @@ static int bcm_sysport_rx_refill(struct bcm_sysport_priv *priv,
 	}
 
 	mapping = dma_map_single(kdev, cb->skb->data,
-				RX_BUF_LENGTH, DMA_FROM_DEVICE);
+				 RX_BUF_LENGTH, DMA_FROM_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
 		bcm_sysport_free_cb(cb);
@@ -528,22 +528,20 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		to_process = p_index - priv->rx_c_index;
 
 	netif_dbg(priv, rx_status, ndev,
-			"p_index=%d rx_c_index=%d to_process=%d\n",
-			p_index, priv->rx_c_index, to_process);
-
-	while ((processed < to_process) &&
-		(processed < budget)) {
+		  "p_index=%d rx_c_index=%d to_process=%d\n",
+		  p_index, priv->rx_c_index, to_process);
 
+	while ((processed < to_process) && (processed < budget)) {
 		cb = &priv->rx_cbs[priv->rx_read_ptr];
 		skb = cb->skb;
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
-				RX_BUF_LENGTH, DMA_FROM_DEVICE);
+				 RX_BUF_LENGTH, DMA_FROM_DEVICE);
 
 		/* Extract the Receive Status Block prepended */
 		rsb = (struct bcm_rsb *)skb->data;
 		len = (rsb->rx_status_len >> DESC_LEN_SHIFT) & DESC_LEN_MASK;
 		status = (rsb->rx_status_len >> DESC_STATUS_SHIFT) &
-			DESC_STATUS_MASK;
+			  DESC_STATUS_MASK;
 
 		processed++;
 		priv->rx_read_ptr++;
@@ -551,9 +549,9 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 			priv->rx_read_ptr = 0;
 
 		netif_dbg(priv, rx_status, ndev,
-				"p=%d, c=%d, rd_ptr=%d, len=%d, flag=0x%04x\n",
-				p_index, priv->rx_c_index, priv->rx_read_ptr,
-				len, status);
+			  "p=%d, c=%d, rd_ptr=%d, len=%d, flag=0x%04x\n",
+			  p_index, priv->rx_c_index, priv->rx_read_ptr,
+			  len, status);
 
 		if (unlikely(!skb)) {
 			netif_err(priv, rx_err, ndev, "out of memory!\n");
@@ -612,9 +610,9 @@ refill:
 }
 
 static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_priv *priv,
-					struct bcm_sysport_cb *cb,
-					unsigned int *bytes_compl,
-					unsigned int *pkts_compl)
+				       struct bcm_sysport_cb *cb,
+				       unsigned int *bytes_compl,
+				       unsigned int *pkts_compl)
 {
 	struct device *kdev = &priv->pdev->dev;
 	struct net_device *ndev = priv->netdev;
@@ -623,8 +621,8 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_priv *priv,
 		ndev->stats.tx_bytes += cb->skb->len;
 		*bytes_compl += cb->skb->len;
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
-				dma_unmap_len(cb, dma_len),
-				DMA_TO_DEVICE);
+				 dma_unmap_len(cb, dma_len),
+				 DMA_TO_DEVICE);
 		ndev->stats.tx_packets++;
 		(*pkts_compl)++;
 		bcm_sysport_free_cb(cb);
@@ -632,7 +630,7 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_priv *priv,
 	} else if (dma_unmap_addr(cb, dma_addr)) {
 		ndev->stats.tx_bytes += dma_unmap_len(cb, dma_len);
 		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
-				dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
+			       dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
 		dma_unmap_addr_set(cb, dma_addr, 0);
 	}
 }
@@ -666,8 +664,8 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 		last_tx_cn = num_tx_cbs - last_c_index + c_index;
 
 	netif_dbg(priv, tx_done, ndev,
-			"ring=%d c_index=%d last_tx_cn=%d last_c_index=%d\n",
-			ring->index, c_index, last_tx_cn, last_c_index);
+		  "ring=%d c_index=%d last_tx_cn=%d last_c_index=%d\n",
+		  ring->index, c_index, last_tx_cn, last_c_index);
 
 	while (last_tx_cn-- > 0) {
 		cb = ring->cbs + last_c_index;
@@ -684,8 +682,8 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 		netif_tx_wake_queue(txq);
 
 	netif_dbg(priv, tx_done, ndev,
-			"ring=%d c_index=%d pkts_compl=%d, bytes_compl=%d\n",
-			ring->index, ring->c_index, pkts_compl, bytes_compl);
+		  "ring=%d c_index=%d pkts_compl=%d, bytes_compl=%d\n",
+		  ring->index, ring->c_index, pkts_compl, bytes_compl);
 
 	return pkts_compl;
 }
@@ -890,8 +888,9 @@ static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
 			csum_info |= L4_LENGTH_VALID;
 			if (ip_proto == IPPROTO_UDP && ip_ver == ETH_P_IP)
 				csum_info |= L4_UDP;
-		} else
+		} else {
 			csum_info = 0;
+		}
 
 		tsb->l4_ptr_dest_map = csum_info;
 	}
@@ -955,7 +954,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	if (dma_mapping_error(kdev, mapping)) {
 		netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
-				skb->data, skb_len);
+			  skb->data, skb_len);
 		ret = NETDEV_TX_OK;
 		goto out;
 	}
@@ -973,7 +972,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 	len_status = upper_32_bits(mapping) & DESC_ADDR_HI_MASK;
 	len_status |= (skb_len << DESC_LEN_SHIFT);
 	len_status |= (DESC_SOP | DESC_EOP | TX_STATUS_APP_CRC) <<
-			DESC_STATUS_SHIFT;
+		       DESC_STATUS_SHIFT;
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		len_status |= (DESC_L4_CSUM << DESC_STATUS_SHIFT);
 
@@ -998,7 +997,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 		netif_tx_stop_queue(txq);
 
 	netif_dbg(priv, tx_queued, dev, "ring=%d desc_count=%d, curr_desc=%d\n",
-			ring->index, ring->desc_count, ring->curr_desc);
+		  ring->index, ring->desc_count, ring->curr_desc);
 
 	ret = NETDEV_TX_OK;
 out:
@@ -1136,14 +1135,14 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	napi_enable(&ring->napi);
 
 	netif_dbg(priv, hw, priv->netdev,
-			"TDMA cfg, size=%d, desc_cpu=%p\n",
-			ring->size, ring->desc_cpu);
+		  "TDMA cfg, size=%d, desc_cpu=%p\n",
+		  ring->size, ring->desc_cpu);
 
 	return 0;
 }
 
 static void bcm_sysport_fini_tx_ring(struct bcm_sysport_priv *priv,
-					unsigned int index)
+				     unsigned int index)
 {
 	struct bcm_sysport_tx_ring *ring = &priv->tx_rings[index];
 	struct device *kdev = &priv->pdev->dev;
@@ -1174,7 +1173,7 @@ static void bcm_sysport_fini_tx_ring(struct bcm_sysport_priv *priv,
 
 /* RDMA helper */
 static inline int rdma_enable_set(struct bcm_sysport_priv *priv,
-					unsigned int enable)
+				  unsigned int enable)
 {
 	unsigned int timeout = 1000;
 	u32 reg;
@@ -1201,7 +1200,7 @@ static inline int rdma_enable_set(struct bcm_sysport_priv *priv,
 
 /* TDMA helper */
 static inline int tdma_enable_set(struct bcm_sysport_priv *priv,
-					unsigned int enable)
+				  unsigned int enable)
 {
 	unsigned int timeout = 1000;
 	u32 reg;
@@ -1272,8 +1271,8 @@ static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
 	rdma_writel(priv, 1, RDMA_MBDONE_INTR);
 
 	netif_dbg(priv, hw, priv->netdev,
-			"RDMA cfg, num_rx_bds=%d, rx_bds=%p\n",
-			priv->num_rx_bds, priv->rx_bds);
+		  "RDMA cfg, num_rx_bds=%d, rx_bds=%p\n",
+		  priv->num_rx_bds, priv->rx_bds);
 
 	return 0;
 }
@@ -1293,8 +1292,8 @@ static void bcm_sysport_fini_rx_ring(struct bcm_sysport_priv *priv)
 		cb = &priv->rx_cbs[i];
 		if (dma_unmap_addr(cb, dma_addr))
 			dma_unmap_single(&priv->pdev->dev,
-					dma_unmap_addr(cb, dma_addr),
-					RX_BUF_LENGTH, DMA_FROM_DEVICE);
+					 dma_unmap_addr(cb, dma_addr),
+					 RX_BUF_LENGTH, DMA_FROM_DEVICE);
 		bcm_sysport_free_cb(cb);
 	}
 
@@ -1322,7 +1321,7 @@ static void bcm_sysport_set_rx_mode(struct net_device *dev)
 }
 
 static inline void umac_enable_set(struct bcm_sysport_priv *priv,
-					u32 mask, unsigned int enable)
+				   u32 mask, unsigned int enable)
 {
 	u32 reg;
 
@@ -1365,7 +1364,7 @@ static inline int umac_reset(struct bcm_sysport_priv *priv)
 }
 
 static void umac_set_hw_addr(struct bcm_sysport_priv *priv,
-				unsigned char *addr)
+			     unsigned char *addr)
 {
 	umac_writel(priv, (addr[0] << 24) | (addr[1] << 16) |
 			(addr[2] << 8) | addr[3], UMAC_MAC0);
@@ -1474,7 +1473,7 @@ static int bcm_sysport_open(struct net_device *dev)
 		ret = bcm_sysport_init_tx_ring(priv, i);
 		if (ret) {
 			netdev_err(dev, "failed to initialize TX ring %d\n",
-					i);
+				   i);
 			goto out_free_tx_ring;
 		}
 	}
@@ -1692,7 +1691,7 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	/* Request the WOL interrupt and advertise suspend if available */
 	priv->wol_irq_disabled = 1;
 	ret = devm_request_irq(&pdev->dev, priv->wol_irq,
-				bcm_sysport_wol_isr, 0, dev->name, priv);
+			       bcm_sysport_wol_isr, 0, dev->name, priv);
 	if (!ret)
 		device_set_wakeup_capable(&pdev->dev, 1);
 
@@ -1717,10 +1716,10 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	priv->rev = topctrl_readl(priv, REV_CNTL) & REV_MASK;
 	dev_info(&pdev->dev,
-		"Broadcom SYSTEMPORT" REV_FMT
-		" at 0x%p (irqs: %d, %d, TXQs: %d, RXQs: %d)\n",
-		(priv->rev >> 8) & 0xff, priv->rev & 0xff,
-		priv->base, priv->irq0, priv->irq1, txq, rxq);
+		 "Broadcom SYSTEMPORT" REV_FMT
+		 " at 0x%p (irqs: %d, %d, TXQs: %d, RXQs: %d)\n",
+		 (priv->rev >> 8) & 0xff, priv->rev & 0xff,
+		 priv->base, priv->irq0, priv->irq1, txq, rxq);
 
 	return 0;
 err:
@@ -1869,7 +1868,7 @@ static int bcm_sysport_resume(struct device *d)
 		ret = bcm_sysport_init_tx_ring(priv, i);
 		if (ret) {
 			netdev_err(dev, "failed to initialize TX ring %d\n",
-					i);
+				   i);
 			goto out_free_tx_rings;
 		}
 	}
-- 
1.9.1
