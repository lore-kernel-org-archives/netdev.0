From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 23/25] bnx2x: Spelling mistakes
Date: Wed, 13 Aug 2008 17:16:23 +0300
Message-ID: <1218636983.547.99.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2057 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756769AbYHMOQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:16:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spelling mistakes
Spelling has to L's in it...

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   10 +++++-----
 drivers/net/bnx2x_hsi.h  |   16 ++++++++--------
 drivers/net/bnx2x_init.h |    6 +++---
 drivers/net/bnx2x_link.h |    4 ++--
 drivers/net/bnx2x_main.c |   24 ++++++++++++------------
 drivers/net/bnx2x_reg.h  |   18 +++++++++---------
 6 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 80f5179..33437e5 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -155,7 +155,7 @@ struct sw_rx_page {
 #define NUM_RX_SGE_PAGES		2
 #define RX_SGE_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_rx_sge))
 #define MAX_RX_SGE_CNT			(RX_SGE_CNT - 2)
-/* RX_SGE_CNT is promissed to be a power of 2 */
+/* RX_SGE_CNT is promised to be a power of 2 */
 #define RX_SGE_MASK			(RX_SGE_CNT - 1)
 #define NUM_RX_SGE			(RX_SGE_CNT * NUM_RX_SGE_PAGES)
 #define MAX_RX_SGE			(NUM_RX_SGE - 1)
@@ -317,7 +317,7 @@ struct bnx2x_fastpath {
 #define RCQ_BD(x)			((x) & MAX_RCQ_BD)
 
 
-/* This is needed for determening of last_max */
+/* This is needed for determining of last_max */
 #define SUB_S16(a, b)			(s16)((s16)(a) - (s16)(b))
 
 #define __SGE_MASK_SET_BIT(el, bit) \
@@ -784,7 +784,7 @@ struct bnx2x {
 	u8			stats_pending;
 	u8			set_mac_pending;
 
-	/* End of fileds used in the performance code paths */
+	/* End of fields used in the performance code paths */
 
 	int			panic;
 	int			msglevel;
@@ -1024,10 +1024,10 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 /* resolution of the rate shaping timer - 100 usec */
 #define RS_PERIODIC_TIMEOUT_USEC	100
 /* resolution of fairness algorithm in usecs -
-   coefficient for clauclating the actuall t fair */
+   coefficient for calculating the actual t fair */
 #define T_FAIR_COEF			10000000
 /* number of bytes in single QM arbitration cycle -
-   coeffiecnt for calculating the fairness timer */
+   coefficient for calculating the fairness timer */
 #define QM_ARB_BYTES			40000
 #define FAIR_MEM			2
 
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index d3e8198..efd7644 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1268,7 +1268,7 @@ struct doorbell {
 
 
 /*
- * IGU driver acknowlegement register
+ * IGU driver acknowledgement register
  */
 struct igu_ack_register {
 #if defined(__BIG_ENDIAN)
@@ -1882,7 +1882,7 @@ struct timers_block_context {
 };
 
 /*
- * structure for easy accessability to assembler
+ * structure for easy accessibility to assembler
  */
 struct eth_tx_bd_flags {
 	u8 as_bitfield;
@@ -2044,7 +2044,7 @@ struct eth_context {
 
 
 /*
- * ethernet doorbell
+ * Ethernet doorbell
  */
 struct eth_tx_doorbell {
 #if defined(__BIG_ENDIAN)
@@ -2256,7 +2256,7 @@ struct ramrod_data {
 };
 
 /*
- * union for ramrod data for ethernet protocol (CQE) (force size of 16 bits)
+ * union for ramrod data for Ethernet protocol (CQE) (force size of 16 bits)
  */
 union eth_ramrod_data {
 	struct ramrod_data general;
@@ -2330,7 +2330,7 @@ struct spe_hdr {
 };
 
 /*
- * ethernet slow path element
+ * Ethernet slow path element
  */
 union eth_specific_data {
 	u8 protocol_data[8];
@@ -2343,7 +2343,7 @@ union eth_specific_data {
 };
 
 /*
- * ethernet slow path element
+ * Ethernet slow path element
  */
 struct eth_spe {
 	struct spe_hdr hdr;
@@ -2615,7 +2615,7 @@ struct tstorm_eth_rx_producers {
 
 
 /*
- * common flag to indicate existance of TPA.
+ * common flag to indicate existence of TPA.
  */
 struct tstorm_eth_tpa_exist {
 #if defined(__BIG_ENDIAN)
@@ -2765,7 +2765,7 @@ struct tstorm_common_stats {
 };
 
 /*
- * Eth statistics query sturcture for the eth_stats_quesry ramrod
+ * Eth statistics query structure for the eth_stats_query ramrod
  */
 struct eth_stats_query {
 	struct xstorm_common_stats xstorm_common;
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 4c77507..f62891b 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -208,7 +208,7 @@ static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
 /*********************************************************
    There are different blobs for each PRAM section.
    In addition, each blob write operation is divided into a few operations
-   in order to decrease the amount of phys. contigious buffer needed.
+   in order to decrease the amount of phys. contiguous buffer needed.
    Thus, when we select a blob the address may be with some offset
    from the beginning of PRAM section.
    The same holds for the INT_TABLE sections.
@@ -336,7 +336,7 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 		len = op->str_wr.data_len;
 		data = data_base + op->str_wr.data_off;
 
-		/* carefull! it must be in order */
+		/* careful! it must be in order */
 		if (unlikely(op_type > OP_WB)) {
 
 			/* If E1 only */
@@ -740,7 +740,7 @@ static u8 calc_crc8(u32 data, u8 crc)
 	return crc_res;
 }
 
-/* regiesers addresses are not in order
+/* registers addresses are not in order
    so these arrays help simplify the code */
 static const int cm_start[E1H_FUNC_MAX][9] = {
 	{MISC_FUNC0_START, TCM_FUNC0_START, UCM_FUNC0_START, CCM_FUNC0_START,
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 80c945c..86d54a1 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -143,7 +143,7 @@ u8 bnx2x_cl45_write(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 		  u8 phy_addr, u8 devad, u16 reg, u16 val);
 
 /* Reads the link_status from the shmem,
-   and update the link vars accordinaly */
+   and update the link vars accordingly */
 void bnx2x_link_status_update(struct link_params *input,
 			    struct link_vars *output);
 /* returns string representing the fw_version of the external phy */
@@ -152,7 +152,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 
 /* Set/Unset the led
    Basically, the CLC takes care of the led for the link, but in case one needs
-   to set/unset the led unnatually, set the "mode" to LED_MODE_OPER to
+   to set/unset the led unnaturally, set the "mode" to LED_MODE_OPER to
    blink the led, and LED_MODE_OFF to set the led off.*/
 u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 	       u16 hw_led_mode, u32 chip_id);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d3c4c1e..1bbcdb2 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1151,8 +1151,8 @@ static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
 	memset(fp->sge_mask, 0xff,
 	       (NUM_RX_SGE >> RX_SGE_MASK_ELEM_SHIFT)*sizeof(u64));
 
-	/* Clear the two last indeces in the page to 1:
-	   these are the indeces that correspond to the "next" element,
+	/* Clear the two last indices in the page to 1:
+	   these are the indices that correspond to the "next" element,
 	   hence will never be indicated and should be removed from
 	   the calculations. */
 	bnx2x_clear_sge_mask_next_elems(fp);
@@ -2011,7 +2011,7 @@ static u8 bnx2x_link_test(struct bnx2x *bp)
      sum of vn_min_rates
        or
      0 - if all the min_rates are 0.
-     In the later case fainess algorithm should be deactivated.
+     In the later case fairness algorithm should be deactivated.
      If not all min_rates are zero then those that are zeroes will
      be set to 1.
  */
@@ -2134,7 +2134,7 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func,
 				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
 		/* If FAIRNESS is enabled (not all min rates are zeroes) and
 		   if current min rate is zero - set it to 1.
-		   This is a requirment of the algorithm. */
+		   This is a requirement of the algorithm. */
 		if ((vn_min_rate == 0) && wsum)
 			vn_min_rate = DEF_MIN_RATE;
 		vn_max_rate = ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
@@ -6562,7 +6562,7 @@ static void bnx2x_reset_port(struct bnx2x *bp)
 	val = REG_RD(bp, BRB1_REG_PORT_NUM_OCC_BLOCKS_0 + port*4);
 	if (val)
 		DP(NETIF_MSG_IFDOWN,
-		   "BRB1 is not empty  %d blooks are occupied\n", val);
+		   "BRB1 is not empty  %d blocks are occupied\n", val);
 
 	/* TODO: Close Doorbell port? */
 }
@@ -6602,7 +6602,7 @@ static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 	}
 }
 
-/* msut be called with rtnl_lock */
+/* must be called with rtnl_lock */
 static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 {
 	int port = BP_PORT(bp);
@@ -7455,7 +7455,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	if (BP_NOMCP(bp)) {
 		/* only supposed to happen on emulation/FPGA */
-		BNX2X_ERR("warning rendom MAC workaround active\n");
+		BNX2X_ERR("warning random MAC workaround active\n");
 		random_ether_addr(bp->dev->dev_addr);
 		memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 	}
@@ -8907,7 +8907,7 @@ static void bnx2x_self_test(struct net_device *dev,
 	if (!netif_running(dev))
 		return;
 
-	/* offline tests are not suppoerted in MF mode */
+	/* offline tests are not supported in MF mode */
 	if (IS_E1HMF(bp))
 		etest->flags &= ~ETH_TEST_FL_OFFLINE;
 
@@ -9216,7 +9216,7 @@ static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 				       PCI_PM_CTRL_PME_STATUS));
 
 		if (pmcsr & PCI_PM_CTRL_STATE_MASK)
-		/* delay required during transition out of D3hot */
+			/* delay required during transition out of D3hot */
 			msleep(20);
 		break;
 
@@ -9289,7 +9289,7 @@ poll_panic:
 
 
 /* we split the first BD into headers and data BDs
- * to ease the pain of our fellow micocode engineers
+ * to ease the pain of our fellow microcode engineers
  * we use one mapping for both BDs
  * So far this has only been observed to happen
  * in Other Operating Systems(TM)
@@ -9396,7 +9396,7 @@ static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 			/* Check if LSO packet needs to be copied:
 			   3 = 1 (for headers BD) + 2 (for PBD and last BD) */
 			int wnd_size = MAX_FETCH_BD - 3;
-			/* Number of widnows to check */
+			/* Number of windows to check */
 			int num_wnds = skb_shinfo(skb)->nr_frags - wnd_size;
 			int wnd_idx = 0;
 			int frag_idx = 0;
@@ -9498,7 +9498,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
 	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
 
-	/* First, check if we need to linearaize the skb
+	/* First, check if we need to linearize the skb
 	   (due to FW restrictions) */
 	if (bnx2x_pkt_req_lin(bp, skb, xmit_type)) {
 		/* Statistics of linearization */
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 5029d1e..a67b0c3 100755
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * The registers description starts with the regsister Access type followed
+ * The registers description starts with the register Access type followed
  * by size in bits. For example [RW 32]. The access types are:
  * R  - Read only
  * RC - Clear on read
@@ -49,7 +49,7 @@
 /* [RW 10] Write client 0: Assert pause threshold. */
 #define BRB1_REG_PAUSE_LOW_THRESHOLD_0				 0x60068
 #define BRB1_REG_PAUSE_LOW_THRESHOLD_1				 0x6006c
-/* [R 24] The number of full blocks occpied by port. */
+/* [R 24] The number of full blocks occupied by port. */
 #define BRB1_REG_PORT_NUM_OCC_BLOCKS_0				 0x60094
 /* [RW 1] Reset the design by software. */
 #define BRB1_REG_SOFT_RESET					 0x600dc
@@ -1412,13 +1412,13 @@
 #define MISC_REG_GPIO						 0xa490
 /* [R 28] this field hold the last information that caused reserved
    attention. bits [19:0] - address; [22:20] function; [23] reserved;
-   [27:24] the master thatcaused the attention - according to the following
+   [27:24] the master that caused the attention - according to the following
    encodeing:1 = pxp; 2 = mcp; 3 = usdm; 4 = tsdm; 5 = xsdm; 6 = csdm; 7 =
    dbu; 8 = dmae */
 #define MISC_REG_GRC_RSV_ATTN					 0xa3c0
 /* [R 28] this field hold the last information that caused timeout
    attention. bits [19:0] - address; [22:20] function; [23] reserved;
-   [27:24] the master thatcaused the attention - according to the following
+   [27:24] the master that caused the attention - according to the following
    encodeing:1 = pxp; 2 = mcp; 3 = usdm; 4 = tsdm; 5 = xsdm; 6 = csdm; 7 =
    dbu; 8 = dmae */
 #define MISC_REG_GRC_TIMEOUT_ATTN				 0xa3c4
@@ -2320,7 +2320,7 @@
 /* [RW 3] page size in L2P table for QM module; -4k; -8k; -16k; -32k; -64k;
    -128k */
 #define PXP2_REG_RQ_QM_P_SIZE					 0x120050
-/* [RW 1] 1' indicates that the RBC has finished configurating the PSWRQ */
+/* [RW 1] 1' indicates that the RBC has finished configuring the PSWRQ */
 #define PXP2_REG_RQ_RBC_DONE					 0x1201b0
 /* [RW 3] Max burst size filed for read requests port 0; 000 - 128B;
    001:256B; 010: 512B; 11:1K:100:2K; 01:4K */
@@ -2428,7 +2428,7 @@
 /* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
    buffer reaches this number has_payload will be asserted */
 #define PXP2_REG_WR_DMAE_MPS					 0x1205ec
-/* [RW 10] if Number of entries in dmae fifo will be higer than this
+/* [RW 10] if Number of entries in dmae fifo will be higher than this
    threshold then has_payload indication will be asserted; the default value
    should be equal to &gt;  write MBS size! */
 #define PXP2_REG_WR_DMAE_TH					 0x120368
@@ -2449,7 +2449,7 @@
 /* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
    buffer reaches this number has_payload will be asserted */
 #define PXP2_REG_WR_TSDM_MPS					 0x1205d4
-/* [RW 10] if Number of entries in usdmdp fifo will be higer than this
+/* [RW 10] if Number of entries in usdmdp fifo will be higher than this
    threshold then has_payload indication will be asserted; the default value
    should be equal to &gt;  write MBS size! */
 #define PXP2_REG_WR_USDMDP_TH					 0x120348
@@ -3316,12 +3316,12 @@
 #define XSEM_XSEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
 #define CFC_DEBUG1_REG_WRITE_AC 				 (0x1<<4)
 #define CFC_DEBUG1_REG_WRITE_AC_SIZE				 4
-/* [R 1] debug only: This bit indicates wheter indicates that external
+/* [R 1] debug only: This bit indicates whether indicates that external
    buffer was wrapped (oldest data was thrown); Relevant only when
    ~dbg_registers_debug_target=2 (PCI) & ~dbg_registers_full_mode=1 (wrap); */
 #define DBG_REG_WRAP_ON_EXT_BUFFER				 0xc124
 #define DBG_REG_WRAP_ON_EXT_BUFFER_SIZE 			 1
-/* [R 1] debug only: This bit indicates wheter the internal buffer was
+/* [R 1] debug only: This bit indicates whether the internal buffer was
    wrapped (oldest data was thrown) Relevant only when
    ~dbg_registers_debug_target=0 (internal buffer) */
 #define DBG_REG_WRAP_ON_INT_BUFFER				 0xc128
-- 
1.5.3.2




