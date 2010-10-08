From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 6/7] qlcnic: change all P3 references to P3P
Date: Fri,  8 Oct 2010 02:46:10 -0700
Message-ID: <1286531171-21173-7-git-send-email-amit.salecha@qlogic.com>
References: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:65194 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756382Ab0JHJqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 05:46:13 -0400
In-Reply-To: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

This patch just rename all P3 #define to P3P.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |   38 +++++++++++++++---------------
 drivers/net/qlcnic/qlcnic_ethtool.c |   42 +++++++++++++++++-----------------
 drivers/net/qlcnic/qlcnic_hdr.h     |   24 ++++++++++----------
 drivers/net/qlcnic/qlcnic_hw.c      |   36 +++++++++++++++---------------
 drivers/net/qlcnic/qlcnic_init.c    |    4 +-
 5 files changed, 72 insertions(+), 72 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 4025e20..d325314 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -94,12 +94,12 @@
 #define FIRST_PAGE_GROUP_START	0
 #define FIRST_PAGE_GROUP_END	0x100000
 
-#define P3_MAX_MTU                     (9600)
-#define P3_MIN_MTU                     (68)
+#define P3P_MAX_MTU                     (9600)
+#define P3P_MIN_MTU                     (68)
 #define QLCNIC_MAX_ETHERHDR                32 /* This contains some padding */
 
-#define QLCNIC_P3_RX_BUF_MAX_LEN         (QLCNIC_MAX_ETHERHDR + ETH_DATA_LEN)
-#define QLCNIC_P3_RX_JUMBO_BUF_MAX_LEN   (QLCNIC_MAX_ETHERHDR + P3_MAX_MTU)
+#define QLCNIC_P3P_RX_BUF_MAX_LEN         (QLCNIC_MAX_ETHERHDR + ETH_DATA_LEN)
+#define QLCNIC_P3P_RX_JUMBO_BUF_MAX_LEN   (QLCNIC_MAX_ETHERHDR + P3P_MAX_MTU)
 #define QLCNIC_CT_DEFAULT_RX_BUF_LEN	2048
 #define QLCNIC_LRO_BUFFER_EXTRA		2048
 
@@ -307,20 +307,20 @@ struct uni_data_desc{
 /* Magic number to let user know flash is programmed */
 #define	QLCNIC_BDINFO_MAGIC 0x12345678
 
-#define QLCNIC_BRDTYPE_P3_REF_QG	0x0021
-#define QLCNIC_BRDTYPE_P3_HMEZ		0x0022
-#define QLCNIC_BRDTYPE_P3_10G_CX4_LP	0x0023
-#define QLCNIC_BRDTYPE_P3_4_GB		0x0024
-#define QLCNIC_BRDTYPE_P3_IMEZ		0x0025
-#define QLCNIC_BRDTYPE_P3_10G_SFP_PLUS	0x0026
-#define QLCNIC_BRDTYPE_P3_10000_BASE_T	0x0027
-#define QLCNIC_BRDTYPE_P3_XG_LOM	0x0028
-#define QLCNIC_BRDTYPE_P3_4_GB_MM	0x0029
-#define QLCNIC_BRDTYPE_P3_10G_SFP_CT	0x002a
-#define QLCNIC_BRDTYPE_P3_10G_SFP_QT	0x002b
-#define QLCNIC_BRDTYPE_P3_10G_CX4	0x0031
-#define QLCNIC_BRDTYPE_P3_10G_XFP	0x0032
-#define QLCNIC_BRDTYPE_P3_10G_TP	0x0080
+#define QLCNIC_BRDTYPE_P3P_REF_QG	0x0021
+#define QLCNIC_BRDTYPE_P3P_HMEZ		0x0022
+#define QLCNIC_BRDTYPE_P3P_10G_CX4_LP	0x0023
+#define QLCNIC_BRDTYPE_P3P_4_GB		0x0024
+#define QLCNIC_BRDTYPE_P3P_IMEZ		0x0025
+#define QLCNIC_BRDTYPE_P3P_10G_SFP_PLUS	0x0026
+#define QLCNIC_BRDTYPE_P3P_10000_BASE_T	0x0027
+#define QLCNIC_BRDTYPE_P3P_XG_LOM	0x0028
+#define QLCNIC_BRDTYPE_P3P_4_GB_MM	0x0029
+#define QLCNIC_BRDTYPE_P3P_10G_SFP_CT	0x002a
+#define QLCNIC_BRDTYPE_P3P_10G_SFP_QT	0x002b
+#define QLCNIC_BRDTYPE_P3P_10G_CX4	0x0031
+#define QLCNIC_BRDTYPE_P3P_10G_XFP	0x0032
+#define QLCNIC_BRDTYPE_P3P_10G_TP	0x0080
 
 #define QLCNIC_MSIX_TABLE_OFFSET	0x44
 
@@ -719,7 +719,7 @@ struct qlcnic_cardrsp_tx_ctx {
 
 /* MAC */
 
-#define MC_COUNT_P3	38
+#define MC_COUNT_P3P	38
 
 #define QLCNIC_MAC_NOOP	0
 #define QLCNIC_MAC_ADD	1
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index e07adb1..2568aa6 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -96,7 +96,7 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 static const u32 diag_registers[] = {
 	CRB_CMDPEG_STATE,
 	CRB_RCVPEG_STATE,
-	CRB_XG_STATE_P3,
+	CRB_XG_STATE_P3P,
 	CRB_FW_CAPABILITIES_1,
 	ISR_INT_STATE_REG,
 	QLCNIC_CRB_DRV_ACTIVE,
@@ -189,9 +189,9 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			goto skip;
 		}
 
-		val = QLCRD32(adapter, P3_LINK_SPEED_REG(pcifn));
-		ecmd->speed = P3_LINK_SPEED_MHZ *
-			P3_LINK_SPEED_VAL(pcifn, val);
+		val = QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn));
+		ecmd->speed = P3P_LINK_SPEED_MHZ *
+			P3P_LINK_SPEED_VAL(pcifn, val);
 		ecmd->duplex = DUPLEX_FULL;
 		ecmd->autoneg = AUTONEG_DISABLE;
 	} else
@@ -202,42 +202,42 @@ skip:
 	ecmd->transceiver = XCVR_EXTERNAL;
 
 	switch (adapter->ahw.board_type) {
-	case QLCNIC_BRDTYPE_P3_REF_QG:
-	case QLCNIC_BRDTYPE_P3_4_GB:
-	case QLCNIC_BRDTYPE_P3_4_GB_MM:
+	case QLCNIC_BRDTYPE_P3P_REF_QG:
+	case QLCNIC_BRDTYPE_P3P_4_GB:
+	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
 
 		ecmd->supported |= SUPPORTED_Autoneg;
 		ecmd->advertising |= ADVERTISED_Autoneg;
-	case QLCNIC_BRDTYPE_P3_10G_CX4:
-	case QLCNIC_BRDTYPE_P3_10G_CX4_LP:
-	case QLCNIC_BRDTYPE_P3_10000_BASE_T:
+	case QLCNIC_BRDTYPE_P3P_10G_CX4:
+	case QLCNIC_BRDTYPE_P3P_10G_CX4_LP:
+	case QLCNIC_BRDTYPE_P3P_10000_BASE_T:
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
 		ecmd->autoneg =  adapter->link_autoneg;
 		break;
-	case QLCNIC_BRDTYPE_P3_IMEZ:
-	case QLCNIC_BRDTYPE_P3_XG_LOM:
-	case QLCNIC_BRDTYPE_P3_HMEZ:
+	case QLCNIC_BRDTYPE_P3P_IMEZ:
+	case QLCNIC_BRDTYPE_P3P_XG_LOM:
+	case QLCNIC_BRDTYPE_P3P_HMEZ:
 		ecmd->supported |= SUPPORTED_MII;
 		ecmd->advertising |= ADVERTISED_MII;
 		ecmd->port = PORT_MII;
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
-	case QLCNIC_BRDTYPE_P3_10G_SFP_PLUS:
-	case QLCNIC_BRDTYPE_P3_10G_SFP_CT:
-	case QLCNIC_BRDTYPE_P3_10G_SFP_QT:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_PLUS:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_CT:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->supported |= SUPPORTED_TP;
 		check_sfp_module = netif_running(dev) &&
 			adapter->has_link_events;
-	case QLCNIC_BRDTYPE_P3_10G_XFP:
+	case QLCNIC_BRDTYPE_P3P_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_FIBRE;
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
-	case QLCNIC_BRDTYPE_P3_10G_TP:
+	case QLCNIC_BRDTYPE_P3P_10G_TP:
 		if (adapter->ahw.port_type == QLCNIC_XGBE) {
 			ecmd->autoneg = AUTONEG_DISABLE;
 			ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
@@ -381,9 +381,9 @@ static u32 qlcnic_test_link(struct net_device *dev)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 val;
 
-	val = QLCRD32(adapter, CRB_XG_STATE_P3);
-	val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
-	return (val == XG_LINK_UP_P3) ? 0 : 1;
+	val = QLCRD32(adapter, CRB_XG_STATE_P3P);
+	val = XG_LINK_STATE_P3P(adapter->ahw.pci_func, val);
+	return (val == XG_LINK_UP_P3P) ? 0 : 1;
 }
 
 static int
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 716203e..4290b80 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -556,18 +556,18 @@ enum {
 #define XG_LINK_UP	0x10
 #define XG_LINK_DOWN	0x20
 
-#define XG_LINK_UP_P3	0x01
-#define XG_LINK_DOWN_P3	0x02
-#define XG_LINK_STATE_P3_MASK 0xf
-#define XG_LINK_STATE_P3(pcifn, val) \
-	(((val) >> ((pcifn) * 4)) & XG_LINK_STATE_P3_MASK)
-
-#define P3_LINK_SPEED_MHZ	100
-#define P3_LINK_SPEED_MASK	0xff
-#define P3_LINK_SPEED_REG(pcifn)	\
+#define XG_LINK_UP_P3P	0x01
+#define XG_LINK_DOWN_P3P	0x02
+#define XG_LINK_STATE_P3P_MASK 0xf
+#define XG_LINK_STATE_P3P(pcifn, val) \
+	(((val) >> ((pcifn) * 4)) & XG_LINK_STATE_P3P_MASK)
+
+#define P3P_LINK_SPEED_MHZ	100
+#define P3P_LINK_SPEED_MASK	0xff
+#define P3P_LINK_SPEED_REG(pcifn)	\
 	(CRB_PF_LINK_SPEED_1 + (((pcifn) / 4) * 4))
-#define P3_LINK_SPEED_VAL(pcifn, reg)	\
-	(((reg) >> (8 * ((pcifn) & 0x3))) & P3_LINK_SPEED_MASK)
+#define P3P_LINK_SPEED_VAL(pcifn, reg)	\
+	(((reg) >> (8 * ((pcifn) & 0x3))) & P3P_LINK_SPEED_MASK)
 
 #define QLCNIC_CAM_RAM_BASE	(QLCNIC_CRB_CAM + 0x02000)
 #define QLCNIC_CAM_RAM(reg)	(QLCNIC_CAM_RAM_BASE + (reg))
@@ -592,7 +592,7 @@ enum {
 #define CRB_CMDPEG_STATE		(QLCNIC_REG(0x50))
 #define CRB_RCVPEG_STATE		(QLCNIC_REG(0x13c))
 
-#define CRB_XG_STATE_P3 		(QLCNIC_REG(0x98))
+#define CRB_XG_STATE_P3P		(QLCNIC_REG(0x98))
 #define CRB_PF_LINK_SPEED_1		(QLCNIC_REG(0xe8))
 #define CRB_PF_LINK_SPEED_2		(QLCNIC_REG(0xec))
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 53e8053..7a47a2a 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -754,9 +754,9 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int rc = 0;
 
-	if (mtu < P3_MIN_MTU || mtu > P3_MAX_MTU) {
+	if (mtu < P3P_MIN_MTU || mtu > P3P_MAX_MTU) {
 		dev_err(&adapter->netdev->dev, "%d bytes < mtu < %d bytes"
-			" not supported\n", P3_MAX_MTU, P3_MIN_MTU);
+			" not supported\n", P3P_MAX_MTU, P3P_MIN_MTU);
 		return -EINVAL;
 	}
 
@@ -1161,31 +1161,31 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 
 	adapter->ahw.board_type = board_type;
 
-	if (board_type == QLCNIC_BRDTYPE_P3_4_GB_MM) {
+	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
 		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I);
 		if ((gpio & 0x8000) == 0)
-			board_type = QLCNIC_BRDTYPE_P3_10G_TP;
+			board_type = QLCNIC_BRDTYPE_P3P_10G_TP;
 	}
 
 	switch (board_type) {
-	case QLCNIC_BRDTYPE_P3_HMEZ:
-	case QLCNIC_BRDTYPE_P3_XG_LOM:
-	case QLCNIC_BRDTYPE_P3_10G_CX4:
-	case QLCNIC_BRDTYPE_P3_10G_CX4_LP:
-	case QLCNIC_BRDTYPE_P3_IMEZ:
-	case QLCNIC_BRDTYPE_P3_10G_SFP_PLUS:
-	case QLCNIC_BRDTYPE_P3_10G_SFP_CT:
-	case QLCNIC_BRDTYPE_P3_10G_SFP_QT:
-	case QLCNIC_BRDTYPE_P3_10G_XFP:
-	case QLCNIC_BRDTYPE_P3_10000_BASE_T:
+	case QLCNIC_BRDTYPE_P3P_HMEZ:
+	case QLCNIC_BRDTYPE_P3P_XG_LOM:
+	case QLCNIC_BRDTYPE_P3P_10G_CX4:
+	case QLCNIC_BRDTYPE_P3P_10G_CX4_LP:
+	case QLCNIC_BRDTYPE_P3P_IMEZ:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_PLUS:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_CT:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
+	case QLCNIC_BRDTYPE_P3P_10G_XFP:
+	case QLCNIC_BRDTYPE_P3P_10000_BASE_T:
 		adapter->ahw.port_type = QLCNIC_XGBE;
 		break;
-	case QLCNIC_BRDTYPE_P3_REF_QG:
-	case QLCNIC_BRDTYPE_P3_4_GB:
-	case QLCNIC_BRDTYPE_P3_4_GB_MM:
+	case QLCNIC_BRDTYPE_P3P_REF_QG:
+	case QLCNIC_BRDTYPE_P3P_4_GB:
+	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
 		adapter->ahw.port_type = QLCNIC_GBE;
 		break;
-	case QLCNIC_BRDTYPE_P3_10G_TP:
+	case QLCNIC_BRDTYPE_P3P_10G_TP:
 		adapter->ahw.port_type = (adapter->portnum < 2) ?
 			QLCNIC_XGBE : QLCNIC_GBE;
 		break;
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 908a25b..0d180c6 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -259,14 +259,14 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 		switch (ring) {
 		case RCV_RING_NORMAL:
 			rds_ring->num_desc = adapter->num_rxd;
-			rds_ring->dma_size = QLCNIC_P3_RX_BUF_MAX_LEN;
+			rds_ring->dma_size = QLCNIC_P3P_RX_BUF_MAX_LEN;
 			rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
 			break;
 
 		case RCV_RING_JUMBO:
 			rds_ring->num_desc = adapter->num_jumbo_rxd;
 			rds_ring->dma_size =
-				QLCNIC_P3_RX_JUMBO_BUF_MAX_LEN;
+				QLCNIC_P3P_RX_JUMBO_BUF_MAX_LEN;
 
 			if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
 				rds_ring->dma_size += QLCNIC_LRO_BUFFER_EXTRA;
-- 
1.6.0.2

