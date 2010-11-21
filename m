From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/62] cxgb4: Use static const
Date: Sat, 20 Nov 2010 18:38:14 -0800
Message-ID: <429206ca62961ce8a2c823746467ed10f8cdd8e1.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  30668	   2168	   5960	  38796	   978c	drivers/net/cxgb4/t4_hw.o.old
  32780	     56	   5960	  38796	   978c	drivers/net/cxgb4/t4_hw.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cxgb4/t4_hw.c |   48 ++++++++++++++++++++++----------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index bb813d9..1bf6614 100644
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
 
@@ -919,7 +919,7 @@ static int t4_handle_intr_status(struct adapter *adapter, unsigned int reg,
  */
 static void pcie_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info sysbus_intr_info[] = {
+	static const struct intr_info sysbus_intr_info[] = {
 		{ RNPP, "RXNP array parity error", -1, 1 },
 		{ RPCP, "RXPC array parity error", -1, 1 },
 		{ RCIP, "RXCIF array parity error", -1, 1 },
@@ -927,7 +927,7 @@ static void pcie_intr_handler(struct adapter *adapter)
 		{ RFTP, "RXFT array parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info pcie_port_intr_info[] = {
+	static const struct intr_info pcie_port_intr_info[] = {
 		{ TPCP, "TXPC array parity error", -1, 1 },
 		{ TNPP, "TXNP array parity error", -1, 1 },
 		{ TFTP, "TXFT array parity error", -1, 1 },
@@ -939,7 +939,7 @@ static void pcie_intr_handler(struct adapter *adapter)
 		{ TDUE, "Tx uncorrectable data error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info pcie_intr_info[] = {
+	static const struct intr_info pcie_intr_info[] = {
 		{ MSIADDRLPERR, "MSI AddrL parity error", -1, 1 },
 		{ MSIADDRHPERR, "MSI AddrH parity error", -1, 1 },
 		{ MSIDATAPERR, "MSI data parity error", -1, 1 },
@@ -991,7 +991,7 @@ static void pcie_intr_handler(struct adapter *adapter)
  */
 static void tp_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info tp_intr_info[] = {
+	static const struct intr_info tp_intr_info[] = {
 		{ 0x3fffffff, "TP parity error", -1, 1 },
 		{ FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1 },
 		{ 0 }
@@ -1008,7 +1008,7 @@ static void sge_intr_handler(struct adapter *adapter)
 {
 	u64 v;
 
-	static struct intr_info sge_intr_info[] = {
+	static const struct intr_info sge_intr_info[] = {
 		{ ERR_CPL_EXCEED_IQE_SIZE,
 		  "SGE received CPL exceeding IQE size", -1, 1 },
 		{ ERR_INVALID_CIDX_INC,
@@ -1053,7 +1053,7 @@ static void sge_intr_handler(struct adapter *adapter)
  */
 static void cim_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info cim_intr_info[] = {
+	static const struct intr_info cim_intr_info[] = {
 		{ PREFDROPINT, "CIM control register prefetch drop", -1, 1 },
 		{ OBQPARERR, "CIM OBQ parity error", -1, 1 },
 		{ IBQPARERR, "CIM IBQ parity error", -1, 1 },
@@ -1063,7 +1063,7 @@ static void cim_intr_handler(struct adapter *adapter)
 		{ TIEQOUTPARERRINT, "CIM TIEQ incoming parity error", -1, 1 },
 		{ 0 }
 	};
-	static struct intr_info cim_upintr_info[] = {
+	static const struct intr_info cim_upintr_info[] = {
 		{ RSVDSPACEINT, "CIM reserved space access", -1, 1 },
 		{ ILLTRANSINT, "CIM illegal transaction", -1, 1 },
 		{ ILLWRINT, "CIM illegal write", -1, 1 },
@@ -1110,7 +1110,7 @@ static void cim_intr_handler(struct adapter *adapter)
  */
 static void ulprx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info ulprx_intr_info[] = {
+	static const struct intr_info ulprx_intr_info[] = {
 		{ 0x1800000, "ULPRX context error", -1, 1 },
 		{ 0x7fffff, "ULPRX parity error", -1, 1 },
 		{ 0 }
@@ -1125,7 +1125,7 @@ static void ulprx_intr_handler(struct adapter *adapter)
  */
 static void ulptx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info ulptx_intr_info[] = {
+	static const struct intr_info ulptx_intr_info[] = {
 		{ PBL_BOUND_ERR_CH3, "ULPTX channel 3 PBL out of bounds", -1,
 		  0 },
 		{ PBL_BOUND_ERR_CH2, "ULPTX channel 2 PBL out of bounds", -1,
@@ -1147,7 +1147,7 @@ static void ulptx_intr_handler(struct adapter *adapter)
  */
 static void pmtx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info pmtx_intr_info[] = {
+	static const struct intr_info pmtx_intr_info[] = {
 		{ PCMD_LEN_OVFL0, "PMTX channel 0 pcmd too large", -1, 1 },
 		{ PCMD_LEN_OVFL1, "PMTX channel 1 pcmd too large", -1, 1 },
 		{ PCMD_LEN_OVFL2, "PMTX channel 2 pcmd too large", -1, 1 },
@@ -1169,7 +1169,7 @@ static void pmtx_intr_handler(struct adapter *adapter)
  */
 static void pmrx_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info pmrx_intr_info[] = {
+	static const struct intr_info pmrx_intr_info[] = {
 		{ ZERO_E_CMD_ERROR, "PMRX 0-length pcmd", -1, 1 },
 		{ PMRX_FRAMING_ERROR, "PMRX framing error", -1, 1 },
 		{ OCSPI_PAR_ERROR, "PMRX ocspi parity error", -1, 1 },
@@ -1188,7 +1188,7 @@ static void pmrx_intr_handler(struct adapter *adapter)
  */
 static void cplsw_intr_handler(struct adapter *adapter)
 {
-	static struct intr_info cplsw_intr_info[] = {
+	static const struct intr_info cplsw_intr_info[] = {
 		{ CIM_OP_MAP_PERR, "CPLSW CIM op_map parity error", -1, 1 },
 		{ CIM_OVFL_ERROR, "CPLSW CIM overflow", -1, 1 },
 		{ TP_FRAMING_ERROR, "CPLSW TP framing error", -1, 1 },
@@ -1207,7 +1207,7 @@ static void cplsw_intr_handler(struct adapter *adapter)
  */
 static void le_intr_handler(struct adapter *adap)
 {
-	static struct intr_info le_intr_info[] = {
+	static const struct intr_info le_intr_info[] = {
 		{ LIPMISS, "LE LIP miss", -1, 0 },
 		{ LIP0, "LE 0 LIP error", -1, 0 },
 		{ PARITYERR, "LE parity error", -1, 1 },
@@ -1225,11 +1225,11 @@ static void le_intr_handler(struct adapter *adap)
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
@@ -1239,25 +1239,25 @@ static void mps_intr_handler(struct adapter *adapter)
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
@@ -1356,7 +1356,7 @@ static void ma_intr_handler(struct adapter *adap)
  */
 static void smb_intr_handler(struct adapter *adap)
 {
-	static struct intr_info smb_intr_info[] = {
+	static const struct intr_info smb_intr_info[] = {
 		{ MSTTXFIFOPARINT, "SMB master Tx FIFO parity error", -1, 1 },
 		{ MSTRXFIFOPARINT, "SMB master Rx FIFO parity error", -1, 1 },
 		{ SLVFIFOPARINT, "SMB slave FIFO parity error", -1, 1 },
@@ -1372,7 +1372,7 @@ static void smb_intr_handler(struct adapter *adap)
  */
 static void ncsi_intr_handler(struct adapter *adap)
 {
-	static struct intr_info ncsi_intr_info[] = {
+	static const struct intr_info ncsi_intr_info[] = {
 		{ CIM_DM_PRTY_ERR, "NC-SI CIM parity error", -1, 1 },
 		{ MPS_DM_PRTY_ERR, "NC-SI MPS parity error", -1, 1 },
 		{ TXFIFO_PRTY_ERR, "NC-SI Tx FIFO parity error", -1, 1 },
@@ -1410,7 +1410,7 @@ static void xgmac_intr_handler(struct adapter *adap, int port)
  */
 static void pl_intr_handler(struct adapter *adap)
 {
-	static struct intr_info pl_intr_info[] = {
+	static const struct intr_info pl_intr_info[] = {
 		{ FATALPERR, "T4 fatal parity error", -1, 1 },
 		{ PERRVFID, "PL VFID_MAP parity error", -1, 1 },
 		{ 0 }
-- 
1.7.3.2.245.g03276.dirty
