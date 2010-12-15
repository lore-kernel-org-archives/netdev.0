From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 10/12] cxgb4: add const to static arrays
Date: Tue, 14 Dec 2010 23:36:53 -0800
Message-ID: <1292398615-26527-11-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
 <1292398615-26527-3-git-send-email-dm@chelsio.com>
 <1292398615-26527-4-git-send-email-dm@chelsio.com>
 <1292398615-26527-5-git-send-email-dm@chelsio.com>
 <1292398615-26527-6-git-send-email-dm@chelsio.com>
 <1292398615-26527-7-git-send-email-dm@chelsio.com>
 <1292398615-26527-8-git-send-email-dm@chelsio.com>
 <1292398615-26527-9-git-send-email-dm@chelsio.com>
 <1292398615-26527-10-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2967 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICY004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:19 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7avkl026613
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:57 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7avOO026612
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:57 -0800
In-Reply-To: <1292398615-26527-10-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch originally from Joe Perches, unmodified.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |   48 ++++++++++++++++++++++----------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index 6af0452..c7fb549 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -183,7 +183,7 @@ static void dump_mbox(struct adapter *adap, int mbox, u32 data_reg)
 int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 		    void *rpl, bool sleep_ok)
 {
-	static int delay[] = {
+	static const int delay[] = {
 		1, 1, 3, 5, 10, 10, 20, 50, 100, 200
 	};
 
@@ -917,7 +917,7 @@ static int t4_handle_intr_status(struct adapter *adapter, unsigned int reg,
  */
 static void pcie_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info sysbus_intr_info[] = {
+	static const struct intr_info sysbus_intr_info[] = {
 		{ RNPP, "RXNP array parity error", -1, 1 },
 		{ RPCP, "RXPC array parity error", -1, 1 },
 		{ RCIP, "RXCIF array parity error", -1, 1 },
@@ -925,7 +925,7 @@ static void pcie_intr_handler(struct adapter *adapter)
 		{ RFTP, "RXFT array parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info pcie_port_intr_info[] = {
+	static const struct intr_info pcie_port_intr_info[] = {
 		{ TPCP, "TXPC array parity error", -1, 1 },
 		{ TNPP, "TXNP array parity error", -1, 1 },
 		{ TFTP, "TXFT array parity error", -1, 1 },
@@ -937,7 +937,7 @@ static void pcie_intr_handler(struct adapter *adapter)
 		{ TDUE, "Tx uncorrectable data error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info pcie_intr_info[] = {
+	static const struct intr_info pcie_intr_info[] = {
 		{ MSIADDRLPERR, "MSI AddrL parity error", -1, 1 },
 		{ MSIADDRHPERR, "MSI AddrH parity error", -1, 1 },
 		{ MSIDATAPERR, "MSI data parity error", -1, 1 },
@@ -989,7 +989,7 @@ static void pcie_intr_handler(struct adapter *adapter)
  */
 static void tp_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info tp_intr_info[] = {
+	static const struct intr_info tp_intr_info[] = {
 		{ 0x3fffffff, "TP parity error", -1, 1 },
 		{ FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1 },
 		{ 0 }
@@ -1006,7 +1006,7 @@ static void sge_intr_handler(struct adapter *adapter)
 {
 	u64 v;
 
-	static struct intr_info sge_intr_info[] = {
+	static const struct intr_info sge_intr_info[] = {
 		{ ERR_CPL_EXCEED_IQE_SIZE,
 		  "SGE received CPL exceeding IQE size", -1, 1 },
 		{ ERR_INVALID_CIDX_INC,
@@ -1051,7 +1051,7 @@ static void sge_intr_handler(struct adapter *adapter)
  */
 static void cim_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info cim_intr_info[] = {
+	static const struct intr_info cim_intr_info[] = {
 		{ PREFDROPINT, "CIM control register prefetch drop", -1, 1 },
 		{ OBQPARERR, "CIM OBQ parity error", -1, 1 },
 		{ IBQPARERR, "CIM IBQ parity error", -1, 1 },
@@ -1061,7 +1061,7 @@ static void cim_intr_handler(struct adapter *adapter)
 		{ TIEQOUTPARERRINT, "CIM TIEQ incoming parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info cim_upintr_info[] = {
+	static const struct intr_info cim_upintr_info[] = {
 		{ RSVDSPACEINT, "CIM reserved space access", -1, 1 },
 		{ ILLTRANSINT, "CIM illegal transaction", -1, 1 },
 		{ ILLWRINT, "CIM illegal write", -1, 1 },
@@ -1108,7 +1108,7 @@ static void cim_intr_handler(struct adapter *adapter)
  */
 static void ulprx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info ulprx_intr_info[] = {
+	static const struct intr_info ulprx_intr_info[] = {
 		{ 0x1800000, "ULPRX context error", -1, 1 },
 		{ 0x7fffff, "ULPRX parity error", -1, 1 },
 		{ 0 }
@@ -1123,7 +1123,7 @@ static void ulprx_intr_handler(struct adapter *adapter)
  */
 static void ulptx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info ulptx_intr_info[] = {
+	static const struct intr_info ulptx_intr_info[] = {
 		{ PBL_BOUND_ERR_CH3, "ULPTX channel 3 PBL out of bounds", -1,
 		  0 },
 		{ PBL_BOUND_ERR_CH2, "ULPTX channel 2 PBL out of bounds", -1,
@@ -1145,7 +1145,7 @@ static void ulptx_intr_handler(struct adapter *adapter)
  */
 static void pmtx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info pmtx_intr_info[] = {
+	static const struct intr_info pmtx_intr_info[] = {
 		{ PCMD_LEN_OVFL0, "PMTX channel 0 pcmd too large", -1, 1 },
 		{ PCMD_LEN_OVFL1, "PMTX channel 1 pcmd too large", -1, 1 },
 		{ PCMD_LEN_OVFL2, "PMTX channel 2 pcmd too large", -1, 1 },
@@ -1167,7 +1167,7 @@ static void pmtx_intr_handler(struct adapter *adapter)
  */
 static void pmrx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info pmrx_intr_info[] = {
+	static const struct intr_info pmrx_intr_info[] = {
 		{ ZERO_E_CMD_ERROR, "PMRX 0-length pcmd", -1, 1 },
 		{ PMRX_FRAMING_ERROR, "PMRX framing error", -1, 1 },
 		{ OCSPI_PAR_ERROR, "PMRX ocspi parity error", -1, 1 },
@@ -1186,7 +1186,7 @@ static void pmrx_intr_handler(struct adapter *adapter)
  */
 static void cplsw_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info cplsw_intr_info[] = {
+	static const struct intr_info cplsw_intr_info[] = {
 		{ CIM_OP_MAP_PERR, "CPLSW CIM op_map parity error", -1, 1 },
 		{ CIM_OVFL_ERROR, "CPLSW CIM overflow", -1, 1 },
 		{ TP_FRAMING_ERROR, "CPLSW TP framing error", -1, 1 },
@@ -1205,7 +1205,7 @@ static void cplsw_intr_handler(struct adapter *adapter)
  */
 static void le_intr_handler(struct adapter *adap)
 {
-	static struct intr_info le_intr_info[] = {
+	static const struct intr_info le_intr_info[] = {
 		{ LIPMISS, "LE LIP miss", -1, 0 },
 		{ LIP0, "LE 0 LIP error", -1, 0 },
 		{ PARITYERR, "LE parity error", -1, 1 },
@@ -1223,11 +1223,11 @@ static void le_intr_handler(struct adapter *adap)
  */
 static void mps_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info mps_rx_intr_info[] = {
+	static const struct intr_info mps_rx_intr_info[] = {
 		{ 0xffffff, "MPS Rx parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info mps_tx_intr_info[] = {
+	static const struct intr_info mps_tx_intr_info[] = {
 		{ TPFIFO, "MPS Tx TP FIFO parity error", -1, 1 },
 		{ NCSIFIFO, "MPS Tx NC-SI FIFO parity error", -1, 1 },
 		{ TXDATAFIFO, "MPS Tx data FIFO parity error", -1, 1 },
@@ -1237,25 +1237,25 @@ static void mps_intr_handler(struct adapter *adapter)
 		{ FRMERR, "MPS Tx framing error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info mps_trc_intr_info[] = {
+	static const struct intr_info mps_trc_intr_info[] = {
 		{ FILTMEM, "MPS TRC filter parity error", -1, 1 },
 		{ PKTFIFO, "MPS TRC packet FIFO parity error", -1, 1 },
 		{ MISCPERR, "MPS TRC misc parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info mps_stat_sram_intr_info[] = {
+	static const struct intr_info mps_stat_sram_intr_info[] = {
 		{ 0x1fffff, "MPS statistics SRAM parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info mps_stat_tx_intr_info[] = {
+	static const struct intr_info mps_stat_tx_intr_info[] = {
 		{ 0xfffff, "MPS statistics Tx FIFO parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info mps_stat_rx_intr_info[] = {
+	static const struct intr_info mps_stat_rx_intr_info[] = {
 		{ 0xffffff, "MPS statistics Rx FIFO parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info mps_cls_intr_info[] = {
+	static const struct intr_info mps_cls_intr_info[] = {
 		{ MATCHSRAM, "MPS match SRAM parity error", -1, 1 },
 		{ MATCHTCAM, "MPS match TCAM parity error", -1, 1 },
 		{ HASHSRAM, "MPS hash SRAM parity error", -1, 1 },
@@ -1354,7 +1354,7 @@ static void ma_intr_handler(struct adapter *adap)
  */
 static void smb_intr_handler(struct adapter *adap)
 {
-	static struct intr_info smb_intr_info[] = {
+	static const struct intr_info smb_intr_info[] = {
 		{ MSTTXFIFOPARINT, "SMB master Tx FIFO parity error", -1, 1 },
 		{ MSTRXFIFOPARINT, "SMB master Rx FIFO parity error", -1, 1 },
 		{ SLVFIFOPARINT, "SMB slave FIFO parity error", -1, 1 },
@@ -1370,7 +1370,7 @@ static void smb_intr_handler(struct adapter *adap)
  */
 static void ncsi_intr_handler(struct adapter *adap)
 {
-	static struct intr_info ncsi_intr_info[] = {
+	static const struct intr_info ncsi_intr_info[] = {
 		{ CIM_DM_PRTY_ERR, "NC-SI CIM parity error", -1, 1 },
 		{ MPS_DM_PRTY_ERR, "NC-SI MPS parity error", -1, 1 },
 		{ TXFIFO_PRTY_ERR, "NC-SI Tx FIFO parity error", -1, 1 },
@@ -1408,7 +1408,7 @@ static void xgmac_intr_handler(struct adapter *adap, int port)
  */
 static void pl_intr_handler(struct adapter *adap)
 {
-	static struct intr_info pl_intr_info[] = {
+	static const struct intr_info pl_intr_info[] = {
 		{ FATALPERR, "T4 fatal parity error", -1, 1 },
 		{ PERRVFID, "PL VFID_MAP parity error", -1, 1 },
 		{ 0 }
-- 
1.5.4

