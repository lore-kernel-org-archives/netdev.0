From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH resend 2.6.25 1/12][BNX2X]: Spelling fixes
Date: Mon, 25 Feb 2008 12:32:43 +0200
Message-ID: <1203935563.8232.205.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1574 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbYBYKdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 05:33:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: Spelling fixes

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |  119 +++++++++++++++++++++++---------------------------
 drivers/net/bnx2x.h |    2 +-
 2 files changed, 56 insertions(+), 65 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index afc7f34..7b2d789 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -10,13 +10,13 @@
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
  * Slowpath rework by Vladislav Zolotarov
- * Statistics and Link managment by Yitchak Gertner
+ * Statistics and Link management by Yitchak Gertner
  *
  */
 
 /* define this to make the driver freeze on error
  * to allow getting debug info
- * (you will need to reboot afterwords)
+ * (you will need to reboot afterwards)
  */
 /*#define BNX2X_STOP_ON_ERROR*/
 
@@ -71,7 +71,7 @@
 #define TX_TIMEOUT      	(5*HZ)
 
 static char version[] __devinitdata =
-	"Broadcom NetXtreme II 577xx 10Gigabit Ethernet Driver "
+	"Broadcom NetXtreme II 5771X 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
@@ -94,8 +94,8 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
 MODULE_PARM_DESC(onefunc, "enable only first function");
-MODULE_PARM_DESC(nomcp, "ignore managment CPU (Implies onefunc)");
-MODULE_PARM_DESC(debug, "defualt debug msglevel");
+MODULE_PARM_DESC(nomcp, "ignore management CPU (Implies onefunc)");
+MODULE_PARM_DESC(debug, "default debug msglevel");
 
 #ifdef BNX2X_MULTI
 module_param(use_multi, int, 0);
@@ -341,6 +341,7 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 	}
 	return rc;
 }
+
 static void bnx2x_fw_dump(struct bnx2x *bp)
 {
 	u32 mark, offset;
@@ -491,7 +492,7 @@ static void bnx2x_disable_int_sync(struct bnx2x *bp)
 	int i;
 
 	atomic_inc(&bp->intr_sem);
-	/* prevent the HW from sending interrupts*/
+	/* prevent the HW from sending interrupts */
 	bnx2x_disable_int(bp);
 
 	/* make sure all ISRs are done */
@@ -775,6 +776,7 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		mb(); /* force bnx2x_wait_ramrod to see the change */
 		return;
 	}
+
 	switch (command | bp->state) {
 	case (RAMROD_CMD_ID_ETH_PORT_SETUP | BNX2X_STATE_OPENING_WAIT4_PORT):
 		DP(NETIF_MSG_IFUP, "got setup ramrod\n");
@@ -1471,7 +1473,7 @@ static int bnx2x_mdio45_vwrite(struct bnx2x *bp, u32 reg, u32 addr, u32 val)
 }
 
 /*
- * link managment
+ * link management
  */
 
 static void bnx2x_flow_ctrl_resolve(struct bnx2x *bp, u32 gp_status)
@@ -1482,7 +1484,7 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x *bp, u32 gp_status)
 
 	bp->flow_ctrl = 0;
 
-	/* reolve from gp_status in case of AN complete and not sgmii */
+	/* resolve from gp_status in case of AN complete and not sgmii */
 	if ((bp->req_autoneg & AUTONEG_FLOW_CTRL) &&
 	    (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) &&
 	    (!(bp->phy_flags & PHY_SGMII_FLAG)) &&
@@ -1680,7 +1682,7 @@ static void bnx2x_link_int_ack(struct bnx2x *bp, int is_10g)
 	int port = bp->port;
 
 	/* first reset all status
-	 * we asume only one line will be change at a time */
+	 * we assume only one line will be change at a time */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
 		       (NIG_XGXS0_LINK_STATUS |
 			NIG_SERDES0_LINK_STATUS |
@@ -1819,7 +1821,7 @@ static void bnx2x_bmac_enable(struct bnx2x *bp, int is_lb)
 	u32 wb_write[2];
 	u32 val;
 
-	DP(NETIF_MSG_LINK, "enableing BigMAC\n");
+	DP(NETIF_MSG_LINK, "enabling BigMAC\n");
 	/* reset and unreset the BigMac */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
@@ -1940,7 +1942,7 @@ static void bnx2x_emac_enable(struct bnx2x *bp)
 	u32 val;
 	int timeout;
 
-	DP(NETIF_MSG_LINK, "enableing EMAC\n");
+	DP(NETIF_MSG_LINK, "enabling EMAC\n");
 	/* reset and unreset the emac core */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 	       (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
@@ -2033,7 +2035,7 @@ static void bnx2x_emac_enable(struct bnx2x *bp)
 				      EMAC_TX_MODE_EXT_PAUSE_EN);
 	}
 
-	/* KEEP_VLAN_TAG, promiscous */
+	/* KEEP_VLAN_TAG, promiscuous */
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
 	val |= EMAC_RX_MODE_KEEP_VLAN_TAG | EMAC_RX_MODE_PROMISCUOUS;
 	EMAC_WR(EMAC_REG_EMAC_RX_MODE, val);
@@ -2161,7 +2163,6 @@ static void bnx2x_pbf_update(struct bnx2x *bp)
 	u32 count = 1000;
 	u32 pause = 0;
 
-
 	/* disable port */
 	REG_WR(bp, PBF_REG_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x1);
 
@@ -2803,7 +2804,7 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 			bnx2x_bits_en(bp,
 				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled extenal phy int\n");
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 
 			bp->phy_addr = ext_phy_type;
 			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
@@ -2824,7 +2825,7 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 			bnx2x_bits_en(bp,
 				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled extenal phy int\n");
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 
 			bp->phy_addr = ext_phy_type;
 			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
@@ -2857,7 +2858,7 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 			bnx2x_bits_en(bp,
 				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled extenal phy int\n");
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 			break;
 
 		default:
@@ -2994,13 +2995,13 @@ static void bnx2x_link_initialize(struct bnx2x *bp)
 			/* AN enabled */
 			bnx2x_set_brcm_cl37_advertisment(bp);
 
-			/* program duplex & pause advertisment (for aneg) */
+			/* program duplex & pause advertisement (for aneg) */
 			bnx2x_set_ieee_aneg_advertisment(bp);
 
 			/* enable autoneg */
 			bnx2x_set_autoneg(bp);
 
-			/* enalbe and restart AN */
+			/* enable and restart AN */
 			bnx2x_restart_autoneg(bp);
 		}
 
@@ -3158,7 +3159,7 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 	int port = bp->port;
 
 	DP(NETIF_MSG_TIMER,
-	   "spe (%x:%x)  command %x  hw_cid %x  data (%x:%x)  left %x\n",
+	   "spe (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
 	   (u32)U64_HI(bp->spq_mapping), (u32)(U64_LO(bp->spq_mapping) +
 	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
 	   HW_CID(bp, cid), data_hi, data_lo, bp->spq_left);
@@ -3464,7 +3465,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 						HW_PRTY_ASSERT_SET_1) ||
 			    (attn.sig[2] & group_mask.sig[2] &
 						HW_PRTY_ASSERT_SET_2))
-				BNX2X_ERR("FATAL HW block parity atention\n");
+				BNX2X_ERR("FATAL HW block parity attention\n");
 		}
 	}
 
@@ -3906,7 +3907,7 @@ static void bnx2x_stop_stats(struct bnx2x *bp)
 
 		while (bp->stats_state != STATS_STATE_DISABLE) {
 			if (!timeout) {
-				BNX2X_ERR("timeout wating for stats stop\n");
+				BNX2X_ERR("timeout waiting for stats stop\n");
 				break;
 			}
 			timeout--;
@@ -4626,7 +4627,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		fp->rx_bd_prod = fp->rx_comp_prod = ring_prod;
 		fp->rx_pkt = fp->rx_calls = 0;
 
-		/* Warning! this will genrate an interrupt (to the TSTORM) */
+		/* Warning! this will generate an interrupt (to the TSTORM) */
 		/* must only be done when chip is initialized */
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
 		       TSTORM_RCQ_PROD_OFFSET(port, j), ring_prod);
@@ -4850,7 +4851,7 @@ static void bnx2x_init_internal(struct bnx2x *bp)
 /*      DP(NETIF_MSG_IFUP, "tstorm_config: 0x%08x\n",
 	   (*(u32 *)&tstorm_config)); */
 
-	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx untill link is up */
+	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
 	bnx2x_set_storm_rx_mode(bp);
 
 	for_each_queue(bp, i)
@@ -5359,7 +5360,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		REG_RD(bp, USEM_REG_PASSIVE_BUFFER + 8);
 #endif
 		bnx2x_init_block(bp, QM_COMMON_START, QM_COMMON_END);
-		/* softrest pulse */
+		/* soft reset pulse */
 		REG_WR(bp, QM_REG_SOFT_RESET, 1);
 		REG_WR(bp, QM_REG_SOFT_RESET, 0);
 
@@ -5413,7 +5414,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		REG_WR(bp, SRC_REG_SOFT_RST, 1);
 		for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4) {
 			REG_WR(bp, i, 0xc0cac01a);
-			/* TODO: repleace with something meaningfull */
+			/* TODO: replace with something meaningful */
 		}
 		/* SRCH COMMON comes here */
 		REG_WR(bp, SRC_REG_SOFT_RST, 0);
@@ -5647,7 +5648,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 
 	bnx2x_link_reset(bp);
 
-	/* Reset pciex errors for debug */
+	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2114, 0xffffffff);
 	REG_WR(bp, 0x2120, 0xffffffff);
 	REG_WR(bp, 0x2814, 0xffffffff);
@@ -5681,8 +5682,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 	return 0;
 }
 
-
-/* send the MCP a request, block untill there is a reply */
+/* send the MCP a request, block until there is a reply */
 static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 {
 	u32 rc = 0;
@@ -5869,7 +5869,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	for (i = 0; i < 16*1024; i += 64)
 		* (u64 *)((char *)bp->t2 + i + 56) = bp->t2_mapping + i + 64;
 
-	/* now sixup the last line in the block to point to the next block */
+	/* now fixup the last line in the block to point to the next block */
 	*(u64 *)((char *)bp->t2 + 1024*16-8) = bp->t2_mapping;
 
 	/* Timer block array (MAX_CONN*8) phys uncached for now 1024 conns */
@@ -5950,11 +5950,11 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 	int i;
 
 	free_irq(bp->msix_table[0].vector, bp->dev);
-	DP(NETIF_MSG_IFDOWN, "rleased sp irq (%d)\n",
+	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
 	   bp->msix_table[0].vector);
 
 	for_each_queue(bp, i) {
-		DP(NETIF_MSG_IFDOWN, "about to rlease fp #%d->%d irq  "
+		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
 		   "state(%x)\n", i, bp->msix_table[i + 1].vector,
 		   bnx2x_fp(bp, i, state));
 
@@ -6010,7 +6010,6 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 {
 
-
 	int i, rc;
 
 	DP(NETIF_MSG_IFUP, "about to request sp irq\n");
@@ -6109,8 +6108,8 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 	/* can take a while if any port is running */
 	int timeout = 500;
 
-	/* DP("waiting for state to become %d on IDX [%d]\n",
-	state, sb_idx); */
+	DP(NETIF_MSG_IFUP, "%s for state to become %x on IDX [%d]\n",
+	   poll ? "polling" : "waiting", state, idx);
 
 	might_sleep();
 
@@ -6136,7 +6135,6 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 
 	}
 
-
 	/* timeout! */
 	BNX2X_ERR("timeout waiting for ramrod %d on %d\n", state, idx);
 	return -EBUSY;
@@ -6146,7 +6144,7 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 static int bnx2x_setup_leading(struct bnx2x *bp)
 {
 
-	/* reset IGU staae */
+	/* reset IGU state */
 	bnx2x_ack_sb(bp, DEF_SB_ID, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
 	/* SETUP ramrod */
@@ -6196,18 +6194,15 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 		rc = FW_MSG_CODE_DRV_LOAD_COMMON;
 	}
 
-	DP(NETIF_MSG_IFUP, "set number of queues to %d\n", bp->num_queues);
-
 	/* if we can't use msix we only need one fp,
 	 * so try to enable msix with the requested number of fp's
 	 * and fallback to inta with one fp
 	 */
 	if (req_irq) {
-
 		if (use_inta) {
 			bp->num_queues = 1;
 		} else {
-			if (use_multi > 1 && use_multi <= 16)
+			if ((use_multi > 1) && (use_multi <= 16))
 				/* user requested number */
 				bp->num_queues = use_multi;
 			else if (use_multi == 1)
@@ -6216,15 +6211,17 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 				bp->num_queues = 1;
 
 			if (bnx2x_enable_msix(bp)) {
-				/* faild to enable msix */
+				/* failed to enable msix */
 				bp->num_queues = 1;
 				if (use_multi)
-					BNX2X_ERR("Muti requested but failed"
+					BNX2X_ERR("Multi requested but failed"
 						  " to enable MSI-X\n");
 			}
 		}
 	}
 
+	DP(NETIF_MSG_IFUP, "set number of queues to %d\n", bp->num_queues);
+
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
@@ -6257,12 +6254,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 	atomic_set(&bp->intr_sem, 0);
 
-	/* Reenable SP tasklet */
-	/*if (bp->sp_task_en) { 	       */
-	/*        tasklet_enable(&bp->sp_task);*/
-	/*} else {      		       */
-	/*        bp->sp_task_en = 1;          */
-	/*}     			       */
 
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp);
@@ -6401,14 +6392,14 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 
 	int rc;
 
-	/* halt the connnection */
+	/* halt the connection */
 	bp->fp[index].state = BNX2X_FP_STATE_HALTING;
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, 0, 0);
 
 
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, index,
 				       &(bp->fp[index].state), 1);
-	if (rc) /* timout */
+	if (rc) /* timeout */
 		return rc;
 
 	/* delete cfc entry */
@@ -6423,7 +6414,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 static void bnx2x_stop_leading(struct bnx2x *bp)
 {
 
-	/* if the other port is hadling traffic,
+	/* if the other port is handling traffic,
 	   this can take a lot of time */
 	int timeout = 500;
 
@@ -6471,7 +6462,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
 		msleep(1);
 
 	/* Delete the timer: do it before disabling interrupts, as it
-	   may be stil STAT_QUERY ramrod pending after stopping the timer */
+	   may be still STAT_QUERY ramrod pending after stopping the timer */
 	del_timer_sync(&bp->timer);
 
 	/* Wait until stat ramrod returns and all SP tasks complete */
@@ -6932,7 +6923,7 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	val = SHMEM_RD(bp, validity_map[port]);
 	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+	    != (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
 		BNX2X_ERR("MCP validity signature bad\n");
 
 	bp->fw_seq = (SHMEM_RD(bp, drv_fw_mb[port].drv_mb_header) &
@@ -7452,13 +7443,13 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
 		DP(NETIF_MSG_NVM,
-		   "Invalid paramter: offset 0x%x  buf_size 0x%x\n",
+		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
 
 	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid paramter: offset (0x%x) +"
+		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
 		   offset, buf_size, bp->flash_size);
 		return -EINVAL;
@@ -7568,7 +7559,7 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	u32 val;
 
 	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid paramter: offset (0x%x) +"
+		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
 		   offset, buf_size, bp->flash_size);
 		return -EINVAL;
@@ -7621,13 +7612,13 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u32 offset, u8 *data_buf,
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
 		DP(NETIF_MSG_NVM,
-		   "Invalid paramter: offset 0x%x  buf_size 0x%x\n",
+		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
 
 	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid paramter: offset (0x%x) +"
+		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
 		   offset, buf_size, bp->flash_size);
 		return -EINVAL;
@@ -8314,7 +8305,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       ETH_TX_BD_ETH_ADDR_TYPE_SHIFT);
 	tx_bd->general_data |= 1; /* header nbd */
 
-	/* remeber the first bd of the packet */
+	/* remember the first bd of the packet */
 	tx_buf->first_bd = bd_prod;
 
 	DP(NETIF_MSG_TX_QUEUED,
@@ -8427,7 +8418,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			tx_bd->vlan = cpu_to_le16(pkt_prod);
 			/* this marks the bd
 			 * as one that has no individual mapping
-			 * the FW ignors this flag in a bd not maked start
+			 * the FW ignores this flag in a bd not marked start
 			 */
 			tx_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_SW_LSO;
 			DP(NETIF_MSG_TX_QUEUED,
@@ -8584,7 +8575,7 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIPHY:
 		data->phy_id = bp->phy_addr;
 
-		/* fallthru */
+		/* fallthrough */
 	case SIOCGMIIREG: {
 		u32 mii_regval;
 
@@ -8633,7 +8624,7 @@ static int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 
 	/* This does not race with packet allocation
-	 * because the actuall alloc size is
+	 * because the actual alloc size is
 	 * only updated as part of load
 	 */
 	dev->mtu = new_mtu;
@@ -8813,7 +8804,7 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 	bnx2x_get_hwinfo(bp);
 
 	if (CHIP_REV(bp) == CHIP_REV_FPGA) {
-		printk(KERN_ERR PFX "FPGA detacted. MCP disabled,"
+		printk(KERN_ERR PFX "FPGA detected. MCP disabled,"
 		       " will only init first device\n");
 		onefunc = 1;
 		nomcp = 1;
@@ -8944,7 +8935,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	rc = register_netdev(dev);
 	if (rc) {
-		printk(KERN_ERR PFX "Cannot register net device\n");
+		dev_err(&pdev->dev, "Cannot register net device\n");
 		if (bp->regview)
 			iounmap(bp->regview);
 		if (bp->doorbells)
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4f7ae6f..7a01668 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -517,7 +517,7 @@ struct bnx2x {
 	 */
 	u8      		stat_pending;
 
-	/* End of fileds used in the performance code paths */
+	/* End of fields used in the performance code paths */
 
 	int     		panic;
 	int     		msglevel;
-- 
1.5.3.2




