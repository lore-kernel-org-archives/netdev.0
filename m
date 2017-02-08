From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 03/16] net: stmmac: fix some typos in comments
Date: Wed,  8 Feb 2017 09:31:08 +0100
Message-ID: <20170208083121.27949-4-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix some typos in comments.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c   |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 16 ++++++++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |  2 +-
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index a414bde..3b1570d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -102,7 +102,7 @@ static void show_tx_process_state(unsigned int status)
 		pr_debug("- TX (Stopped): Reset or Stop command\n");
 		break;
 	case 1:
-		pr_debug("- TX (Running):Fetching the Tx desc\n");
+		pr_debug("- TX (Running): Fetching the Tx desc\n");
 		break;
 	case 2:
 		pr_debug("- TX (Running): Waiting for end of tx\n");
@@ -136,7 +136,7 @@ static void show_rx_process_state(unsigned int status)
 		pr_debug("- RX (Running): Fetching the Rx desc\n");
 		break;
 	case 2:
-		pr_debug("- RX (Running):Checking for end of pkt\n");
+		pr_debug("- RX (Running): Checking for end of pkt\n");
 		break;
 	case 3:
 		pr_debug("- RX (Running): Waiting for Rx pkt\n");
@@ -246,7 +246,7 @@ void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 	unsigned long data;
 
 	data = (addr[5] << 8) | addr[4];
-	/* For MAC Addr registers se have to set the Address Enable (AE)
+	/* For MAC Addr registers we have to set the Address Enable (AE)
 	 * bit that has no effect on the High Reg 0 where the bit 31 (MO)
 	 * is RO.
 	 */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1ef60282..0636858 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -216,7 +216,7 @@ static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv)
 /**
  * stmmac_hw_fix_mac_speed - callback for speed selection
  * @priv: driver private structure
- * Description: on some platforms (e.g. ST), some HW system configuraton
+ * Description: on some platforms (e.g. ST), some HW system configuration
  * registers have to be set according to the link speed negotiated.
  */
 static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
@@ -416,7 +416,7 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
 /**
  *  stmmac_hwtstamp_ioctl - control hardware timestamping.
  *  @dev: device pointer.
- *  @ifr: An IOCTL specefic structure, that can contain a pointer to
+ *  @ifr: An IOCTL specific structure, that can contain a pointer to
  *  a proprietary structure used to pass information to the driver.
  *  Description:
  *  This function configures the MAC to enable/disable both outgoing(TX)
@@ -1003,7 +1003,7 @@ static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)
  * @dev: net device structure
  * @flags: gfp flag.
  * Description: this function initializes the DMA RX/TX descriptors
- * and allocates the socket buffers. It suppors the chained and ring
+ * and allocates the socket buffers. It supports the chained and ring
  * modes.
  */
 static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
@@ -2532,7 +2532,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		if (unlikely(status == discard_frame)) {
 			priv->dev->stats.rx_errors++;
 			if (priv->hwts_rx_en && !priv->extend_desc) {
-				/* DESC2 & DESC3 will be overwitten by device
+				/* DESC2 & DESC3 will be overwritten by device
 				 * with timestamp value, hence reinitialize
 				 * them in stmmac_rx_refill() function so that
 				 * device can reuse it.
@@ -2555,7 +2555,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 			frame_len = priv->hw->desc->get_rx_frame_len(p, coe);
 
-			/*  If frame length is greather than skb buffer size
+			/*  If frame length is greater than skb buffer size
 			 *  (preallocated during init) then the packet is
 			 *  ignored
 			 */
@@ -2761,7 +2761,7 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 	/* Some GMAC devices have a bugged Jumbo frame support that
 	 * needs to have the Tx COE disabled for oversized frames
 	 * (due to limited buffer sizes). In this case we disable
-	 * the TX csum insertionin the TDES and not use SF.
+	 * the TX csum insertion in the TDES and not use SF.
 	 */
 	if (priv->plat->bugged_jumbo && (dev->mtu > ETH_DATA_LEN))
 		features &= ~NETIF_F_CSUM_MASK;
@@ -2988,7 +2988,7 @@ static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
 		   (priv->dma_cap.hash_filter) ? "Y" : "N");
 	seq_printf(seq, "\tMultiple MAC address registers: %s\n",
 		   (priv->dma_cap.multi_addr) ? "Y" : "N");
-	seq_printf(seq, "\tPCS (TBI/SGMII/RTBI PHY interfatces): %s\n",
+	seq_printf(seq, "\tPCS (TBI/SGMII/RTBI PHY interfaces): %s\n",
 		   (priv->dma_cap.pcs) ? "Y" : "N");
 	seq_printf(seq, "\tSMA (MDIO) Interface: %s\n",
 		   (priv->dma_cap.sma_mdio) ? "Y" : "N");
@@ -3485,7 +3485,7 @@ int stmmac_resume(struct device *dev)
 		priv->irq_wake = 0;
 	} else {
 		pinctrl_pm_select_default_state(priv->device);
-		/* enable the clk prevously disabled */
+		/* enable the clk previously disabled */
 		clk_enable(priv->plat->stmmac_clk);
 		clk_enable(priv->plat->pclk);
 		/* reset the phy so that it's ready */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index b0344c2..a1a469e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -198,7 +198,7 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 
 	/* This is a workaround for problems with the STE101P PHY.
 	 * It doesn't complete its reset until at least one clock cycle
-	 * on MDC, so perform a dummy mdio read. To be upadted for GMAC4
+	 * on MDC, so perform a dummy mdio read. To be updated for GMAC4
 	 * if needed.
 	 */
 	if (!priv->plat->has_gmac4)
-- 
2.10.2
