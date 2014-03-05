From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/5] samsung: xgmac: Neaten comments
Date: Wed,  5 Mar 2014 11:20:18 -0800
Message-ID: <1e47c4adec56f7ef0db314f2d81dda06caa02f63.1394046997.git.joe@perches.com>
References: <cover.1394046997.git.joe@perches.com>
Cc: linux-samsung-soc@vger.kernel.org, davem@davemloft.net,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, ilho215.lee@samsung.com,
	netdev@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <cover.1394046997.git.joe@perches.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a couple of typos
Fix some comments that seem to have been kernel-doc style.
Fix alignment where noticed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/samsung/xgmac_core.c |  1 -
 drivers/net/ethernet/samsung/xgmac_desc.c | 14 +++++++-------
 drivers/net/ethernet/samsung/xgmac_desc.h |  2 +-
 drivers/net/ethernet/samsung/xgmac_dma.c  |  3 ++-
 drivers/net/ethernet/samsung/xgmac_dma.h  |  2 +-
 drivers/net/ethernet/samsung/xgmac_main.c | 14 ++++++++------
 drivers/net/ethernet/samsung/xgmac_reg.h  |  8 ++++----
 7 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_core.c b/drivers/net/ethernet/samsung/xgmac_core.c
index c5afba4..40b1946 100644
--- a/drivers/net/ethernet/samsung/xgmac_core.c
+++ b/drivers/net/ethernet/samsung/xgmac_core.c
@@ -1,4 +1,3 @@
-
 /* 10G controller driver for Samsung SoCs
  *
  * Copyright (C) 2013 Samsung Electronics Co., Ltd.
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.c b/drivers/net/ethernet/samsung/xgmac_desc.c
index ef25efd..2a7fd21 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.c
+++ b/drivers/net/ethernet/samsung/xgmac_desc.c
@@ -84,7 +84,7 @@ static void xgmac_release_tx_desc(struct xgmac_tx_norm_desc *p)
 
 /* Clear interrupt on tx frame completion. When this bit is
  * set an interrupt happens as soon as the frame is transmitted
-*/
+ */
 static void xgmac_clear_tx_ic(struct xgmac_tx_norm_desc *p)
 {
 	p->tdes23.tx_rd_des23.int_on_com = 0;
@@ -158,8 +158,8 @@ static void xgmac_tx_ctxt_desc_reset_ostc(struct xgmac_tx_ctxt_desc *p)
 
 /* Set IVLAN information */
 static void xgmac_tx_ctxt_desc_set_ivlantag(struct xgmac_tx_ctxt_desc *p,
-				     int is_ivlanvalid, int ivlan_tag,
-				     int ivlan_ctl)
+					    int is_ivlanvalid, int ivlan_tag,
+					    int ivlan_ctl)
 {
 	if (is_ivlanvalid) {
 		p->ivlan_tag_valid = is_ivlanvalid;
@@ -176,7 +176,7 @@ static int xgmac_tx_ctxt_desc_get_ivlantag(struct xgmac_tx_ctxt_desc *p)
 
 /* Set VLAN Tag */
 static void xgmac_tx_ctxt_desc_set_vlantag(struct xgmac_tx_ctxt_desc *p,
-					int is_vlanvalid, int vlan_tag)
+					   int is_vlanvalid, int vlan_tag)
 {
 	if (is_vlanvalid) {
 		p->vltag_valid = is_vlanvalid;
@@ -214,7 +214,7 @@ static int xgmac_tx_ctxt_desc_get_cde(struct xgmac_tx_ctxt_desc *p)
 
 /* DMA RX descriptor ring initialization */
 static void xgmac_init_rx_desc(struct xgmac_rx_norm_desc *p, int disable_rx_ic,
-			int mode, int end)
+			       int mode, int end)
 {
 	p->rdes23.rx_rd_des23.own_bit = 1;
 	if (disable_rx_ic)
@@ -413,7 +413,7 @@ static void xgmac_set_ctxt_rx_owner(struct xgmac_rx_ctxt_desc *p)
 
 /* Return the reception status looking at Context control information */
 static void xgmac_rx_ctxt_wbstatus(struct xgmac_rx_ctxt_desc *p,
-				struct xgmac_extra_stats *x)
+				   struct xgmac_extra_stats *x)
 {
 	if (p->tstamp_dropped)
 		x->timestamp_dropped++;
@@ -445,7 +445,7 @@ static void xgmac_rx_ctxt_wbstatus(struct xgmac_rx_ctxt_desc *p,
 		x->rx_ptp_resv_msg_type++;
 }
 
-/* get rx timestamp status */
+/* Get rx timestamp status */
 static int xgmac_get_rx_ctxt_tstamp_status(struct xgmac_rx_ctxt_desc *p)
 {
 	if ((p->tstamp_hi == 0xffffffff) && (p->tstamp_lo == 0xffffffff)) {
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.h b/drivers/net/ethernet/samsung/xgmac_desc.h
index 028b505..8433030 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.h
+++ b/drivers/net/ethernet/samsung/xgmac_desc.h
@@ -14,7 +14,7 @@
 
 #define XGMAC_DESC_SIZE_BYTES	16
 
-/* forward declatarion */
+/* forward declaration */
 struct xgmac_extra_stats;
 
 /* Transmit checksum insertion control */
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.c b/drivers/net/ethernet/samsung/xgmac_dma.c
index 384866c..9a22990a 100644
--- a/drivers/net/ethernet/samsung/xgmac_dma.c
+++ b/drivers/net/ethernet/samsung/xgmac_dma.c
@@ -20,9 +20,10 @@
 #include "xgmac_dma.h"
 #include "xgmac_reg.h"
 #include "xgmac_desc.h"
+
 /* DMA core initialization */
 static int xgmac_dma_init(void __iomem *ioaddr, int fix_burst,
-			     int burst_map, int adv_addr_mode)
+			  int burst_map, int adv_addr_mode)
 {
 	int retry_count = 10;
 	u32 reg_val;
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.h b/drivers/net/ethernet/samsung/xgmac_dma.h
index 2e76ae0..022fd2b 100644
--- a/drivers/net/ethernet/samsung/xgmac_dma.h
+++ b/drivers/net/ethernet/samsung/xgmac_dma.h
@@ -12,7 +12,7 @@
 #ifndef __XGMAC_DMA_H__
 #define __XGMAC_DMA_H__
 
-/* forward declatarion */
+/* forward declaration */
 struct xgmac_extra_stats;
 
 #define XGMAC_DMA_BLENMAP_LSHIFT	1
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index f642c99..e0e339e 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -1880,7 +1880,8 @@ static void xgmac_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
 	writel(data, ioaddr + XGMAC_ADDR_LOW(reg_n));
 }
 
-/* xgmac_set_rx_mode - entry point for setting different receive mode of
+/**
+ * xgmac_set_rx_mode - entry point for setting different receive mode of
  * a device. unicast, multicast addressing
  * @dev : pointer to the device structure
  * Description:
@@ -1952,7 +1953,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	readl(ioaddr + XGMAC_HASH_HIGH), readl(ioaddr + XGMAC_HASH_LOW));
 }
 
-/* xgmac_config - entry point for changing configuration mode passed on by
+/**
+ * xgmac_config - entry point for changing configuration mode passed on by
  * ifconfig
  * @dev : pointer to the device structure
  * @map : pointer to the device mapping structure
@@ -1984,7 +1986,8 @@ static int xgmac_config(struct net_device *dev, struct ifmap *map)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-/* xgmac_poll_controller - entry point for polling receive by device
+/**
+ * xgmac_poll_controller - entry point for polling receive by device
  * @dev : pointer to the device structure
  * Description:
  * This function is used by NETCONSOLE and other diagnostic tools
@@ -2048,7 +2051,7 @@ static const struct net_device_ops xgmac_netdev_ops = {
 	.ndo_set_mac_address = eth_mac_addr,
 };
 
-/* get the hardware ops */
+/* Get the hardware ops */
 void xgmac_get_ops(struct xgmac_ops * const ops_ptr)
 {
 	ops_ptr->mac = xgmac_get_core_ops();
@@ -2359,8 +2362,7 @@ int xgmac_restore(struct net_device *ndev)
 }
 #endif /* CONFIG_PM */
 
-/* Driver is configured as Platf drivers
- */
+/* Driver is configured as Platform driver */
 static int __init xgmac_init(void)
 {
 	int ret;
diff --git a/drivers/net/ethernet/samsung/xgmac_reg.h b/drivers/net/ethernet/samsung/xgmac_reg.h
index 1218f8d..b26d99b 100644
--- a/drivers/net/ethernet/samsung/xgmac_reg.h
+++ b/drivers/net/ethernet/samsung/xgmac_reg.h
@@ -195,7 +195,7 @@
 #define XGMAC_CORE_RSS_ADD_REG		0x0C88
 #define XGMAC_CORE_RSS_DATA_REG		0x0C8C
 
-/* RSS conrol register bits */
+/* RSS control register bits */
 #define XGMAC_CORE_RSS_CTL_UDP4TE	BIT(3)
 #define XGMAC_CORE_RSS_CTL_TCP4TE	BIT(2)
 #define XGMAC_CORE_RSS_CTL_IP2TE	BIT(1)
@@ -256,7 +256,7 @@
 #define XGMAC_MTL_TX_PRTYMAP0_REG	(XGMAC_MTL_BASE_REG + 0x0040)
 #define XGMAC_MTL_TX_PRTYMAP1_REG	(XGMAC_MTL_BASE_REG + 0x0044)
 
-/* TC/Queue registers , qnum=0-15 */
+/* TC/Queue registers, qnum=0-15 */
 #define XGMAC_MTL_TC_TXBASE_REG		(XGMAC_MTL_BASE_REG + 0x0100)
 #define XGMAC_MTL_TXQ_OPMODE_REG(qnum) \
 		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x00)
@@ -404,10 +404,10 @@ enum vlan_tag_ctl_tx {
 #define XGMAC_RX_UNICAST_DETECT		BIT(1)
 #define XGMAC_RX_PRTYFLOW_CTL_ENABLE	BIT(8)
 
-/* xgmac rx Q control0 register bifields */
+/* xgmac rx Q control0 register bitfields */
 #define XGMAC_RX_Q_ENABLE	0x2
 
-/* XGMAC hardware features bit field specific */
+/* XGMAC hardware features bitfield specific */
 /* Capability Register 0 */
 #define XGMAC_HW_FEAT_GMII(cap)			((cap & 0x00000002) >> 1)
 #define XGMAC_HW_FEAT_VLAN_HASH_FILTER(cap)	((cap & 0x00000010) >> 4)
-- 
1.8.1.2.459.gbcd45b4.dirty
