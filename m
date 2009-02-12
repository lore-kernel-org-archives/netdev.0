From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 40/41]bnx2x: Clean-up
Date: Thu, 12 Feb 2009 20:38:32 +0200
Message-ID: <1234463912.1863.172.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2492 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757571AbZBLSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 40/41]bnx2x: Clean-up
Whitespaces, empty lines, 80 columns, indentations and removing redundant
parenthesis


Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h         |    2 +-
 drivers/net/bnx2x_fw_defs.h |   54 ++++++++++++++++++++-----------------------
 drivers/net/bnx2x_hsi.h     |    4 ---
 drivers/net/bnx2x_link.c    |    7 +----
 drivers/net/bnx2x_link.h    |    3 +-
 drivers/net/bnx2x_main.c    |   35 ++++++++++++++++++---------
 6 files changed, 52 insertions(+), 53 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 5eb35a6..408eae7 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -906,7 +906,7 @@ struct bnx2x {
 	u32			lin_cnt;
 
 	int			state;
-#define BNX2X_STATE_CLOSED		0x0
+#define BNX2X_STATE_CLOSED		0
 #define BNX2X_STATE_OPENING_WAIT4_LOAD	0x1000
 #define BNX2X_STATE_OPENING_WAIT4_PORT	0x2000
 #define BNX2X_STATE_OPEN		0x3000
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 0683e54..05d695d 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -217,14 +217,13 @@
 #define X_ETH_LOCAL_RING_SIZE 13
 #define FIRST_BD_IN_PKT 0
 #define PARSE_BD_INDEX 1
-#define NUM_OF_ETH_BDS_IN_PAGE \
-	((PAGE_SIZE) / (STRUCT_SIZE(eth_tx_bd)/8))
+#define NUM_OF_ETH_BDS_IN_PAGE ((PAGE_SIZE)/(STRUCT_SIZE(eth_tx_bd)/8))
 
 
 /* Rx ring params */
-#define U_ETH_LOCAL_BD_RING_SIZE (16)
-#define U_ETH_LOCAL_SGE_RING_SIZE (12)
-#define U_ETH_SGL_SIZE (8)
+#define U_ETH_LOCAL_BD_RING_SIZE 16
+#define U_ETH_LOCAL_SGE_RING_SIZE 12
+#define U_ETH_SGL_SIZE 8
 
 
 #define U_ETH_BDS_PER_PAGE_MASK \
@@ -246,15 +245,15 @@
 #define U_ETH_UNDEFINED_Q 0xFF
 
 /* values of command IDs in the ramrod message */
-#define RAMROD_CMD_ID_ETH_PORT_SETUP (80)
-#define RAMROD_CMD_ID_ETH_CLIENT_SETUP (85)
-#define RAMROD_CMD_ID_ETH_STAT_QUERY (90)
-#define RAMROD_CMD_ID_ETH_UPDATE (100)
-#define RAMROD_CMD_ID_ETH_HALT (105)
-#define RAMROD_CMD_ID_ETH_SET_MAC (110)
-#define RAMROD_CMD_ID_ETH_CFC_DEL (115)
-#define RAMROD_CMD_ID_ETH_PORT_DEL (120)
-#define RAMROD_CMD_ID_ETH_FORWARD_SETUP (125)
+#define RAMROD_CMD_ID_ETH_PORT_SETUP 80
+#define RAMROD_CMD_ID_ETH_CLIENT_SETUP 85
+#define RAMROD_CMD_ID_ETH_STAT_QUERY 90
+#define RAMROD_CMD_ID_ETH_UPDATE 100
+#define RAMROD_CMD_ID_ETH_HALT 105
+#define RAMROD_CMD_ID_ETH_SET_MAC 110
+#define RAMROD_CMD_ID_ETH_CFC_DEL 115
+#define RAMROD_CMD_ID_ETH_PORT_DEL 120
+#define RAMROD_CMD_ID_ETH_FORWARD_SETUP 125
 
 
 /* command values for set mac command */
@@ -271,8 +270,8 @@
 #define ETH_MAX_RX_CLIENTS_E1H 25
 
 /* Maximal aggregation queues supported */
-#define ETH_MAX_AGGREGATION_QUEUES_E1 (32)
-#define ETH_MAX_AGGREGATION_QUEUES_E1H (64)
+#define ETH_MAX_AGGREGATION_QUEUES_E1 32
+#define ETH_MAX_AGGREGATION_QUEUES_E1H 64
 
 /* ETH RSS modes */
 #define ETH_RSS_MODE_DISABLED 0
@@ -301,7 +300,7 @@
 #define RDMA_STATE (RDMA_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
 
 /* microcode fixed page page size 4K (chains and ring segments) */
-#define MC_PAGE_SIZE (4096)
+#define MC_PAGE_SIZE 4096
 
 
 /* Host coalescing constants */
@@ -348,16 +347,16 @@
 #define ATTENTION_ID 4
 
 /* max number of slow path commands per port */
-#define MAX_RAMRODS_PER_PORT (8)
+#define MAX_RAMRODS_PER_PORT 8
 
 /* values for RX ETH CQE type field */
-#define RX_ETH_CQE_TYPE_ETH_FASTPATH (0)
-#define RX_ETH_CQE_TYPE_ETH_RAMROD (1)
+#define RX_ETH_CQE_TYPE_ETH_FASTPATH 0
+#define RX_ETH_CQE_TYPE_ETH_RAMROD 1
 
 
 /**** DEFINES FOR TIMERS/CLOCKS RESOLUTIONS ****/
-#define EMULATION_FREQUENCY_FACTOR (1600)
-#define FPGA_FREQUENCY_FACTOR (100)
+#define EMULATION_FREQUENCY_FACTOR 1600
+#define FPGA_FREQUENCY_FACTOR 100
 
 #define TIMERS_TICK_SIZE_CHIP (1e-3)
 #define TIMERS_TICK_SIZE_EMUL \
@@ -371,12 +370,9 @@
 #define TSEMI_CLK1_RESUL_FPGA \
  ((TSEMI_CLK1_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
 
-#define USEMI_CLK1_RESUL_CHIP \
- (TIMERS_TICK_SIZE_CHIP)
-#define USEMI_CLK1_RESUL_EMUL \
- (TIMERS_TICK_SIZE_EMUL)
-#define USEMI_CLK1_RESUL_FPGA \
- (TIMERS_TICK_SIZE_FPGA)
+#define USEMI_CLK1_RESUL_CHIP (TIMERS_TICK_SIZE_CHIP)
+#define USEMI_CLK1_RESUL_EMUL (TIMERS_TICK_SIZE_EMUL)
+#define USEMI_CLK1_RESUL_FPGA (TIMERS_TICK_SIZE_FPGA)
 
 #define XSEMI_CLK1_RESUL_CHIP (1e-3)
 #define XSEMI_CLK1_RESUL_EMUL \
@@ -401,7 +397,7 @@
 #define XSTORM_IP_ID_ROLL_HALF 0x8000
 #define XSTORM_IP_ID_ROLL_ALL 0
 
-#define FW_LOG_LIST_SIZE (50)
+#define FW_LOG_LIST_SIZE 50
 
 #define NUM_OF_PROTOCOLS 4
 #define NUM_OF_SAFC_BITS 16
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 966b4a2..c1ba05c 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -806,11 +806,7 @@ struct mf_cfg {
 
 	struct shared_mf_cfg	shared_mf_config;
 	struct port_mf_cfg	port_mf_config[PORT_MAX];
-#if defined(b710)
-	struct func_mf_cfg	func_mf_config[E1_FUNC_MAX];
-#else
 	struct func_mf_cfg	func_mf_config[E1H_FUNC_MAX];
-#endif
 
 };
 
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index e1a4e39..73b52f1 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1923,9 +1923,6 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 			{
-			u16 emac_base;
-			emac_base = (params->port) ? GRCBASE_EMAC0 :
-					GRCBASE_EMAC1;
 
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
@@ -3806,7 +3803,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 					     "an_link_status=0x%x\n",
 					  val2, val1, an1000_status);
 
-					ext_phy_link_up = (((val1 & 4) == 4) ||
+				ext_phy_link_up = (((val1 & 4) == 4) ||
 						(an1000_status & (1<<1)));
 				if (ext_phy_link_up &&
 				    bnx2x_8073_is_snr_needed(params)) {
@@ -4188,7 +4185,7 @@ static void bnx2x_turn_on_ef(struct bnx2x *bp, u8 port, u8 ext_phy_addr,
 			      ext_phy_addr,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_CTRL,
-			       &ctrl);
+			      &ctrl);
 		if (!(ctrl & (1<<15))) {
 			DP(NETIF_MSG_LINK, "Reset completed\n\n");
 				break;
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 38254d0..027116a 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -66,8 +66,6 @@ struct link_params {
 	/* Device parameters */
 	u8 mac_addr[6];
 
-
-
 	/* shmem parameters */
 	u32 shmem_base;
 	u32 speed_cap_mask;
@@ -182,4 +180,5 @@ u8 bnx2x_test_link(struct link_params *input, struct link_vars *vars);
 /* One-time initialization for external phy after power up */
 u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base);
 
+
 #endif /* BNX2X_LINK_H */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ae36bc7..4b0476c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -679,6 +679,7 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 	REG_WR(bp, addr, val);
 	if (REG_RD(bp, addr) != val)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
+
 }
 
 static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
@@ -780,7 +781,6 @@ static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
 	/* Tell compiler that consumer and producer can change */
 	barrier();
 	return (fp->tx_pkt_prod != fp->tx_pkt_cons);
-
 }
 
 /* free skb in the packet ring at pos idx
@@ -2036,13 +2036,16 @@ static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 		bp->port.advertising &= ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
 		break;
+
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH:
 		bp->port.advertising |= (ADVERTISED_Asym_Pause |
 					 ADVERTISED_Pause);
 		break;
+
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC:
 		bp->port.advertising |= ADVERTISED_Asym_Pause;
 		break;
+
 	default:
 		bp->port.advertising &= ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
@@ -2067,7 +2070,8 @@ static void bnx2x_link_report(struct bnx2x *bp)
 		if (bp->link_vars.flow_ctrl != BNX2X_FLOW_CTRL_NONE) {
 			if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX) {
 				printk(", receive ");
-				if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_TX)
+				if (bp->link_vars.flow_ctrl &
+				    BNX2X_FLOW_CTRL_TX)
 					printk("& transmit ");
 			} else {
 				printk(", transmit ");
@@ -4454,8 +4458,7 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 		if (fp->tpa_state[i] == BNX2X_TPA_START)
 			pci_unmap_single(bp->pdev,
 					 pci_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size,
-					 PCI_DMA_FROMDEVICE);
+					 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
 
 		dev_kfree_skb(skb);
 		rx_buf->skb = NULL;
@@ -4800,18 +4803,22 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 		tstorm_mac_filter.mcast_drop_all = mask;
 		tstorm_mac_filter.bcast_drop_all = mask;
 		break;
+
 	case BNX2X_RX_MODE_NORMAL:
 		tstorm_mac_filter.bcast_accept_all = mask;
 		break;
+
 	case BNX2X_RX_MODE_ALLMULTI:
 		tstorm_mac_filter.mcast_accept_all = mask;
 		tstorm_mac_filter.bcast_accept_all = mask;
 		break;
+
 	case BNX2X_RX_MODE_PROMISC:
 		tstorm_mac_filter.ucast_accept_all = mask;
 		tstorm_mac_filter.mcast_accept_all = mask;
 		tstorm_mac_filter.bcast_accept_all = mask;
 		break;
+
 	default:
 		BNX2X_ERR("BAD rx mode (%d)\n", mode);
 		break;
@@ -5857,6 +5864,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	/* Port CSDM comes here */
 	/* Port USDM comes here */
 	/* Port XSDM comes here */
+
 	bnx2x_init_block(bp, port ? TSEM_PORT1_START : TSEM_PORT0_START,
 			     port ? TSEM_PORT1_END : TSEM_PORT0_END);
 	bnx2x_init_block(bp, port ? USEM_PORT1_START : USEM_PORT0_START,
@@ -5865,6 +5873,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 			     port ? CSEM_PORT1_END : CSEM_PORT0_END);
 	bnx2x_init_block(bp, port ? XSEM_PORT1_START : XSEM_PORT0_START,
 			     port ? XSEM_PORT1_END : XSEM_PORT0_END);
+
 	/* Port UPB comes here */
 	/* Port XPB comes here */
 
@@ -5923,6 +5932,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	/* Port EMAC1 comes here */
 	/* Port DBU comes here */
 	/* Port DBG comes here */
+
 	bnx2x_init_block(bp, port ? NIG_PORT1_START : NIG_PORT0_START,
 			     port ? NIG_PORT1_END : NIG_PORT0_END);
 
@@ -6404,8 +6414,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 
 			pci_unmap_single(bp->pdev,
 					 pci_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size,
-					 PCI_DMA_FROMDEVICE);
+					 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
 
 			rx_buf->skb = NULL;
 			dev_kfree_skb(skb);
@@ -7325,6 +7334,7 @@ unload_error:
 	/* Report UNLOAD_DONE to MCP */
 	if (!BP_NOMCP(bp))
 		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+
 	bp->port.pmf = 0;
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
@@ -9035,7 +9045,8 @@ static void bnx2x_get_pauseparam(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	epause->autoneg = (bp->link_params.req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
+	epause->autoneg = (bp->link_params.req_flow_ctrl ==
+			   BNX2X_FLOW_CTRL_AUTO) &&
 			  (bp->link_params.req_line_speed == SPEED_AUTO_NEG);
 
 	epause->rx_pause = ((bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX) ==
@@ -10059,6 +10070,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 
 	if (bnx2x_has_rx_work(fp))
 		work_done = bnx2x_rx_int(fp, budget);
+
 	rmb(); /* BNX2X_HAS_WORK() reads the status block */
 
 	/* must not complete if we consumed full budget */
@@ -10074,6 +10086,7 @@ poll_panic:
 		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
 			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
 	}
+
 	return work_done;
 }
 
@@ -10232,7 +10245,6 @@ static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 				wnd_sum -=
 					skb_shinfo(skb)->frags[wnd_idx].size;
 			}
-
 		} else {
 			/* in non-LSO too fragmented packet should always
 			   be linearized */
@@ -10824,7 +10836,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_open		= bnx2x_open,
 	.ndo_stop		= bnx2x_close,
 	.ndo_start_xmit		= bnx2x_start_xmit,
-	.ndo_set_multicast_list = bnx2x_set_rx_mode,
+	.ndo_set_multicast_list	= bnx2x_set_rx_mode,
 	.ndo_set_mac_address	= bnx2x_change_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= bnx2x_ioctl,
@@ -10838,7 +10850,6 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #endif
 };
 
-
 static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 				    struct net_device *dev)
 {
@@ -11317,8 +11328,8 @@ static void bnx2x_io_resume(struct pci_dev *pdev)
 
 static struct pci_error_handlers bnx2x_err_handler = {
 	.error_detected = bnx2x_io_error_detected,
-	.slot_reset = bnx2x_io_slot_reset,
-	.resume = bnx2x_io_resume,
+	.slot_reset     = bnx2x_io_slot_reset,
+	.resume         = bnx2x_io_resume,
 };
 
 static struct pci_driver bnx2x_pci_driver = {
-- 
1.5.4.3




