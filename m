From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 39/41]bnx2x: Comments and prints
Date: Thu, 12 Feb 2009 20:38:30 +0200
Message-ID: <1234463910.1863.171.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1656 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758867AbZBLSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 39/41]bnx2x: Comments and prints

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_fw_defs.h |    9 ++--
 drivers/net/bnx2x_hsi.h     |    2 +-
 drivers/net/bnx2x_init.h    |   94 +++++++++++++++++++++---------------------
 drivers/net/bnx2x_link.c    |    5 +-
 drivers/net/bnx2x_main.c    |   43 ++++++++++----------
 5 files changed, 78 insertions(+), 75 deletions(-)

diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index f6dacb0..0683e54 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -194,7 +194,7 @@
 #define COMMON_ASM_INVALID_ASSERT_OPCODE 0x0
 
 /**
-* This file defines HSI constatnts for the ETH flow
+* This file defines HSI constants for the ETH flow
 */
 #ifdef _EVEREST_MICROCODE
 #include "microcode_constants.h"
@@ -212,7 +212,8 @@
 #define IPV6_HASH_TYPE 3
 #define TCP_IPV6_HASH_TYPE 4
 
-/* Ethernet Ring parmaters */
+
+/* Ethernet Ring parameters */
 #define X_ETH_LOCAL_RING_SIZE 13
 #define FIRST_BD_IN_PKT 0
 #define PARSE_BD_INDEX 1
@@ -279,7 +280,7 @@
 
 
 /**
-* This file defines HSI constatnts common to all microcode flows
+* This file defines HSI constants common to all microcode flows
 */
 
 /* Connection types */
@@ -313,7 +314,7 @@
 #define HC_USTORM_SB_NUM_INDICES 4
 #define HC_CSTORM_SB_NUM_INDICES 4
 
-/* index values - which counterto update */
+/* index values - which counter to update */
 
 #define HC_INDEX_U_TOE_RX_CQ_CONS 0
 #define HC_INDEX_U_ETH_RX_CQ_CONS 1
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 51c5fe1..966b4a2 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1671,7 +1671,7 @@ struct xstorm_eth_ag_context {
 };
 
 /*
- * The eth aggregative context section of Tstorm
+ * The eth extra aggregative context section of Tstorm
  */
 struct tstorm_eth_extra_ag_context_section {
 	u32 __agg_val1;
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 6fcd1dc..ba370f7 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -429,57 +429,57 @@ struct arb_line {
 
 /* derived configuration for each read queue for each max request size */
 static const struct arb_line read_arb_data[NUM_RD_Q][MAX_RD_ORD + 1] = {
-	{{8 , 64 , 25}, {16 , 64 , 25}, {32 , 64 , 25}, {64 , 64 , 41} },
-	{{4 , 8 , 4},   {4 , 8 , 4},    {4 , 8 , 4},    {4 , 8 , 4} },
-	{{4 , 3 , 3},   {4 , 3 , 3},    {4 , 3 , 3},    {4 , 3 , 3} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {16 , 3 , 11},  {16 , 3 , 11} },
-	{{8 , 64 , 25}, {16 , 64 , 25}, {32 , 64 , 25}, {64 , 64 , 41} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {64 , 3 , 41} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {64 , 3 , 41} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {64 , 3 , 41} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {64 , 3 , 41} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 3 , 6},   {16 , 3 , 11},  {32 , 3 , 21},  {32 , 3 , 21} },
-	{{8 , 64 , 25}, {16 , 64 , 41}, {32 , 64 , 81}, {64 , 64 , 120} }
+/* 1 */	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25}, {64, 64, 41} },
+	{ {4, 8,  4},  {4,  8,  4},  {4,  8,  4},  {4,  8,  4}  },
+	{ {4, 3,  3},  {4,  3,  3},  {4,  3,  3},  {4,  3,  3}  },
+	{ {8, 3,  6},  {16, 3,  11}, {16, 3,  11}, {16, 3,  11} },
+	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25}, {64, 64, 41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {64, 3,  41} },
+/* 10 */{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+/* 20 */{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 3,  6},  {16, 3,  11}, {32, 3,  21}, {32, 3,  21} },
+	{ {8, 64, 25}, {16, 64, 41}, {32, 64, 81}, {64, 64, 120} }
 };
 
 /* derived configuration for each write queue for each max request size */
 static const struct arb_line write_arb_data[NUM_WR_Q][MAX_WR_ORD + 1] = {
-	{{4 , 6 , 3},   {4 , 6 , 3},    {4 , 6 , 3} },
-	{{4 , 2 , 3},   {4 , 2 , 3},    {4 , 2 , 3} },
-	{{8 , 2 , 6},   {16 , 2 , 11},  {16 , 2 , 11} },
-	{{8 , 2 , 6},   {16 , 2 , 11},  {32 , 2 , 21} },
-	{{8 , 2 , 6},   {16 , 2 , 11},  {32 , 2 , 21} },
-	{{8 , 2 , 6},   {16 , 2 , 11},  {32 , 2 , 21} },
-	{{8 , 64 , 25}, {16 , 64 , 25}, {32 , 64 , 25} },
-	{{8 , 2 , 6},   {16 , 2 , 11},  {16 , 2 , 11} },
-	{{8 , 2 , 6},   {16 , 2 , 11},  {16 , 2 , 11} },
-	{{8 , 9 , 6},   {16 , 9 , 11},  {32 , 9 , 21} },
-	{{8 , 47 , 19}, {16 , 47 , 19}, {32 , 47 , 21} },
-	{{8 , 9 , 6},   {16 , 9 , 11},  {16 , 9 , 11} },
-	{{8 , 64 , 25}, {16 , 64 , 41}, {32 , 64 , 81} }
+/* 1 */	{ {4, 6,  3},  {4,  6,  3},  {4,  6,  3} },
+	{ {4, 2,  3},  {4,  2,  3},  {4,  2,  3} },
+	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
+	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
+	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
+	{ {8, 2,  6},  {16, 2,  11}, {32, 2,  21} },
+	{ {8, 64, 25}, {16, 64, 25}, {32, 64, 25} },
+	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
+	{ {8, 2,  6},  {16, 2,  11}, {16, 2,  11} },
+/* 10 */{ {8, 9,  6},  {16, 9,  11}, {32, 9,  21} },
+	{ {8, 47, 19}, {16, 47, 19}, {32, 47, 21} },
+	{ {8, 9,  6},  {16, 9,  11}, {16, 9,  11} },
+	{ {8, 64, 25}, {16, 64, 41}, {32, 64, 81} }
 };
 
 /* register addresses for read queues */
 static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
-	{PXP2_REG_RQ_BW_RD_L0, PXP2_REG_RQ_BW_RD_ADD0,
+/* 1 */	{PXP2_REG_RQ_BW_RD_L0, PXP2_REG_RQ_BW_RD_ADD0,
 		PXP2_REG_RQ_BW_RD_UBOUND0},
 	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
 		PXP2_REG_PSWRQ_BW_UB1},
@@ -497,7 +497,7 @@ static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
 		PXP2_REG_PSWRQ_BW_UB7},
 	{PXP2_REG_PSWRQ_BW_L8, PXP2_REG_PSWRQ_BW_ADD8,
 		PXP2_REG_PSWRQ_BW_UB8},
-	{PXP2_REG_PSWRQ_BW_L9, PXP2_REG_PSWRQ_BW_ADD9,
+/* 10 */{PXP2_REG_PSWRQ_BW_L9, PXP2_REG_PSWRQ_BW_ADD9,
 		PXP2_REG_PSWRQ_BW_UB9},
 	{PXP2_REG_PSWRQ_BW_L10, PXP2_REG_PSWRQ_BW_ADD10,
 		PXP2_REG_PSWRQ_BW_UB10},
@@ -517,7 +517,7 @@ static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
 		PXP2_REG_RQ_BW_RD_UBOUND17},
 	{PXP2_REG_RQ_BW_RD_L18, PXP2_REG_RQ_BW_RD_ADD18,
 		PXP2_REG_RQ_BW_RD_UBOUND18},
-	{PXP2_REG_RQ_BW_RD_L19, PXP2_REG_RQ_BW_RD_ADD19,
+/* 20 */{PXP2_REG_RQ_BW_RD_L19, PXP2_REG_RQ_BW_RD_ADD19,
 		PXP2_REG_RQ_BW_RD_UBOUND19},
 	{PXP2_REG_RQ_BW_RD_L20, PXP2_REG_RQ_BW_RD_ADD20,
 		PXP2_REG_RQ_BW_RD_UBOUND20},
@@ -539,7 +539,7 @@ static const struct arb_line read_arb_addr[NUM_RD_Q-1] = {
 
 /* register addresses for write queues */
 static const struct arb_line write_arb_addr[NUM_WR_Q-1] = {
-	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
+/* 1 */	{PXP2_REG_PSWRQ_BW_L1, PXP2_REG_PSWRQ_BW_ADD1,
 		PXP2_REG_PSWRQ_BW_UB1},
 	{PXP2_REG_PSWRQ_BW_L2, PXP2_REG_PSWRQ_BW_ADD2,
 		PXP2_REG_PSWRQ_BW_UB2},
@@ -557,7 +557,7 @@ static const struct arb_line write_arb_addr[NUM_WR_Q-1] = {
 		PXP2_REG_PSWRQ_BW_UB10},
 	{PXP2_REG_PSWRQ_BW_L11, PXP2_REG_PSWRQ_BW_ADD11,
 		PXP2_REG_PSWRQ_BW_UB11},
-	{PXP2_REG_PSWRQ_BW_L28, PXP2_REG_PSWRQ_BW_ADD28,
+/* 10 */{PXP2_REG_PSWRQ_BW_L28, PXP2_REG_PSWRQ_BW_ADD28,
 		PXP2_REG_PSWRQ_BW_UB28},
 	{PXP2_REG_RQ_BW_WR_L29, PXP2_REG_RQ_BW_WR_ADD29,
 		PXP2_REG_RQ_BW_WR_UBOUND29},
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 5a17c7c..e1a4e39 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -4823,6 +4823,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 			return -EINVAL;
 			break;
 		}
+		DP(NETIF_MSG_LINK, "Phy address = 0x%x\n", params->phy_addr);
 
 		bnx2x_link_initialize(params, vars);
 		msleep(30);
@@ -5179,7 +5180,7 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 
 	/* PART3 - complete TX_POWER_DOWN process, and set GPIO2 back to low */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
-		/* Phase2 of POWER_DOWN_RESET*/
+		/* Phase2 of POWER_DOWN_RESET */
 		/* Release bit 10 (Release Tx power down) */
 		bnx2x_cl45_read(bp, port,
 			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
@@ -5258,7 +5259,7 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	u8 rc = 0;
 	u32 ext_phy_type;
 
-	DP(NETIF_MSG_LINK, "bnx2x_common_init_phy\n");
+	DP(NETIF_MSG_LINK, "Begin common phy init\n");
 
 	/* Read the ext_phy_type for arbitrary port(0) */
 	ext_phy_type = XGXS_EXT_PHY_TYPE(
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0d6015f..ae36bc7 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1704,7 +1704,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		DP(NETIF_MSG_INTR, "not our interrupt!\n");
 		return IRQ_NONE;
 	}
-	DP(NETIF_MSG_INTR, "got an interrupt  status %u\n", status);
+	DP(NETIF_MSG_INTR, "got an interrupt  status 0x%x\n", status);
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
@@ -2115,7 +2115,7 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 
 		return rc;
 	}
-	BNX2X_ERR("Bootcode is missing -not initializing link\n");
+	BNX2X_ERR("Bootcode is missing - can not initialize link\n");
 	return -EINVAL;
 }
 
@@ -2128,7 +2128,7 @@ static void bnx2x_link_set(struct bnx2x *bp)
 
 		bnx2x_calc_fc_adv(bp);
 	} else
-		BNX2X_ERR("Bootcode is missing -not setting link\n");
+		BNX2X_ERR("Bootcode is missing - can not set link\n");
 }
 
 static void bnx2x__link_reset(struct bnx2x *bp)
@@ -2138,7 +2138,7 @@ static void bnx2x__link_reset(struct bnx2x *bp)
 		bnx2x_link_reset(&bp->link_params, &bp->link_vars, 1);
 		bnx2x_release_phy_lock(bp);
 	} else
-		BNX2X_ERR("Bootcode is missing -not resetting link\n");
+		BNX2X_ERR("Bootcode is missing - can not reset link\n");
 }
 
 static u8 bnx2x_link_test(struct bnx2x *bp)
@@ -5139,8 +5139,8 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		fp->cl_id = BP_L_ID(bp) + i;
 		fp->sb_id = fp->cl_id;
 		DP(NETIF_MSG_IFUP,
-		   "bnx2x_init_sb(%p,%p) index %d  cl_id %d  sb %d\n",
-		   bp, fp->status_blk, i, fp->cl_id, fp->sb_id);
+		   "queue[%d]:  bnx2x_init_sb(%p,%p)  cl_id %d  sb %d\n",
+		   i, bp, fp->status_blk, fp->cl_id, fp->sb_id);
 		bnx2x_init_sb(bp, fp->status_blk, fp->status_blk_mapping,
 			      fp->sb_id);
 		bnx2x_update_fpsb_idx(fp);
@@ -6904,11 +6904,11 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	} else {
 		int port = BP_PORT(bp);
 
-		DP(NETIF_MSG_IFUP, "NO MCP load counts before us %d, %d, %d\n",
+		DP(NETIF_MSG_IFUP, "NO MCP - load counts      %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		load_count[0]++;
 		load_count[1 + port]++;
-		DP(NETIF_MSG_IFUP, "NO MCP new load counts       %d, %d, %d\n",
+		DP(NETIF_MSG_IFUP, "NO MCP - new load counts  %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		if (load_count[0] == 1)
 			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
@@ -6955,7 +6955,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	if (CHIP_IS_E1H(bp))
 		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
-			BNX2X_ERR("!!!  mf_cfg function disabled\n");
+			DP(NETIF_MSG_IFUP, "mf_cfg function disabled\n");
 			bp->state = BNX2X_STATE_DISABLED;
 		}
 
@@ -7028,8 +7028,6 @@ load_error1:
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
-	/* TBD we really need to reset the chip
-	   if we want to recover from this */
 	return rc;
 }
 
@@ -7303,11 +7301,11 @@ unload_error:
 	if (!BP_NOMCP(bp))
 		reset_code = bnx2x_fw_command(bp, reset_code);
 	else {
-		DP(NETIF_MSG_IFDOWN, "NO MCP load counts      %d, %d, %d\n",
+		DP(NETIF_MSG_IFDOWN, "NO MCP - load counts      %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		load_count[0]--;
 		load_count[1 + port]--;
-		DP(NETIF_MSG_IFDOWN, "NO MCP new load counts  %d, %d, %d\n",
+		DP(NETIF_MSG_IFDOWN, "NO MCP - new load counts  %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		if (load_count[0] == 0)
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
@@ -7615,7 +7613,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		bp->flags |= NO_WOL_FLAG;
 	}
 	BNX2X_DEV_INFO("%sWoL capable\n",
-		       (bp->flags & NO_WOL_FLAG) ? "Not " : "");
+		       (bp->flags & NO_WOL_FLAG) ? "not " : "");
 
 	val = SHMEM_RD(bp, dev_info.shared_hw_config.part_num);
 	val2 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[4]);
@@ -8111,7 +8109,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 				       "(0x%04x)\n",
 				       func, bp->e1hov, bp->e1hov);
 		} else {
-			BNX2X_DEV_INFO("Single function mode\n");
+			BNX2X_DEV_INFO("single function mode\n");
 			if (BP_E1HVN(bp)) {
 				BNX2X_ERR("!!!  No valid E1HOV for func %d,"
 					  "  aborting\n", func);
@@ -9519,7 +9517,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 
 	rc = bnx2x_nvram_read(bp, 0, data, 4);
 	if (rc) {
-		DP(NETIF_MSG_PROBE, "magic value read (rc -%d)\n", -rc);
+		DP(NETIF_MSG_PROBE, "magic value read (rc %d)\n", rc);
 		goto test_nvram_exit;
 	}
 
@@ -9536,7 +9534,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 				      nvram_tbl[i].size);
 		if (rc) {
 			DP(NETIF_MSG_PROBE,
-			   "nvram_tbl[%d] read data (rc -%d)\n", i, -rc);
+			   "nvram_tbl[%d] read data (rc %d)\n", i, rc);
 			goto test_nvram_exit;
 		}
 
@@ -10173,7 +10171,9 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 }
 
 #if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
-/* check if packet requires linearization (packet is too fragmented) */
+/* check if packet requires linearization (packet is too fragmented)
+   no need to check fragmentation if page size > 8K (there will be no
+   violation to FW restrictions) */
 static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 			     u32 xmit_type)
 {
@@ -10295,8 +10295,9 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
 
 #if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
-	/* First, check if we need to linearize the skb
-	   (due to FW restrictions) */
+	/* First, check if we need to linearize the skb (due to FW
+	   restrictions). No need to check fragmentation if page size > 8K
+	   (there will be no violation to FW restrictions) */
 	if (bnx2x_pkt_req_lin(bp, skb, xmit_type)) {
 		/* Statistics of linearization */
 		bp->lin_cnt++;
@@ -10557,7 +10558,7 @@ static int bnx2x_close(struct net_device *dev)
 	return 0;
 }
 
-/* called with netif_tx_lock from set_multicast */
+/* called with netif_tx_lock from dev_mcast.c */
 static void bnx2x_set_rx_mode(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-- 
1.5.4.3




