From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] SAA9730: Fix large pile of warnings
Date: Tue, 20 Mar 2007 12:40:09 +0000
Message-ID: <20070320124009.GA6927@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:38433 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbXCTVhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 17:37:14 -0400
Received: from localhost.localdomain ([127.0.0.1]:35734 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022978AbXCTVhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 21:37:12 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SAA9730 driver doesn't quite grok what the difference between an ioport
and memory mapped I/O is.  It just happened to work on the one Linux
system the SAA9730 happens to spend it's misserable existence on.

drivers/net/saa9730.c: In function 'evm_saa9730_enable_lan_int':
drivers/net/saa9730.c:68: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:70: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:72: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'evm_saa9730_disable_lan_int':
drivers/net/saa9730.c:78: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:80: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'evm_saa9730_clear_lan_int':
drivers/net/saa9730.c:85: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'evm_saa9730_block_lan_int':
drivers/net/saa9730.c:91: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'evm_saa9730_unblock_lan_int':
drivers/net/saa9730.c:97: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'show_saa9730_regs':
drivers/net/saa9730.c:150: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_allocate_buffers':
drivers/net/saa9730.c:292: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:295: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:302: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:305: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:312: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_cam_load':
drivers/net/saa9730.c:329: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:332: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_mii_init':
drivers/net/saa9730.c:369: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:395: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:403: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:410: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:432: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_control_init':
drivers/net/saa9730.c:470: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:474: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:478: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:484: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:487: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:490: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:493: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_stop':
drivers/net/saa9730.c:505: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:508: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:510: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_dma_init':
drivers/net/saa9730.c:536: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_start':
drivers/net/saa9730.c:556: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:560: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:564: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:567: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_tx':
drivers/net/saa9730.c:590: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_rx':
drivers/net/saa9730.c:664: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:729: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_write':
drivers/net/saa9730.c:848: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c: In function 'lan_saa9730_set_multicast':
drivers/net/saa9730.c:943: warning: passing argument 2 of 'outl' makes integer from pointer without a cast
drivers/net/saa9730.c:949: warning: passing argument 2 of 'outl' makes integer from pointer without a cast

Fixed by using writel instead of outl.  42 warnings less.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index b269513..143958f 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -64,37 +64,37 @@ static unsigned int pci_irq_line;
 
 static void evm_saa9730_enable_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
-	outl(readl(&lp->evm_saa9730_regs->InterruptStatus1) | EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptStatus1);
-	outl(readl(&lp->evm_saa9730_regs->InterruptEnable1) | EVM_LAN_INT |
-	     EVM_MASTER_EN, &lp->evm_saa9730_regs->InterruptEnable1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptStatus1) | EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptStatus1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptEnable1) | EVM_LAN_INT |
+	       EVM_MASTER_EN, &lp->evm_saa9730_regs->InterruptEnable1);
 }
 
 static void evm_saa9730_disable_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
-	outl(readl(&lp->evm_saa9730_regs->InterruptEnable1) & ~EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptEnable1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptEnable1) & ~EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptEnable1);
 }
 
 static void evm_saa9730_clear_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(EVM_LAN_INT, &lp->evm_saa9730_regs->InterruptStatus1);
+	writel(EVM_LAN_INT, &lp->evm_saa9730_regs->InterruptStatus1);
 }
 
 static void evm_saa9730_block_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
 }
 
 static void evm_saa9730_unblock_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
 }
 
 static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
@@ -147,7 +147,7 @@ static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
 	printk("lp->lan_saa9730_regs->RxStatus = %x\n",
 	       readl(&lp->lan_saa9730_regs->RxStatus));
 	for (i = 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
-		outl(i, &lp->lan_saa9730_regs->CamAddress);
+		writel(i, &lp->lan_saa9730_regs->CamAddress);
 		printk("lp->lan_saa9730_regs->CamData = %x\n",
 		       readl(&lp->lan_saa9730_regs->CamData));
 	}
@@ -288,28 +288,27 @@ static int lan_saa9730_allocate_buffers(struct pci_dev *pdev,
 	 * Set rx buffer A and rx buffer B to point to the first two buffer
 	 * spaces.
 	 */
-	outl(lp->dma_addr + rxoffset,
-	     &lp->lan_saa9730_regs->RxBuffA);
-	outl(lp->dma_addr + rxoffset +
-	     LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_RCV_Q_SIZE,
-	     &lp->lan_saa9730_regs->RxBuffB);
+	writel(lp->dma_addr + rxoffset, &lp->lan_saa9730_regs->RxBuffA);
+	writel(lp->dma_addr + rxoffset +
+	       LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_RCV_Q_SIZE,
+	       &lp->lan_saa9730_regs->RxBuffB);
 
 	/*
 	 * Set txm_buf_a and txm_buf_b to point to the first two buffer
 	 * space
 	 */
-	outl(lp->dma_addr + txoffset,
-	     &lp->lan_saa9730_regs->TxBuffA);
-	outl(lp->dma_addr + txoffset +
-	     LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_TXM_Q_SIZE,
-	     &lp->lan_saa9730_regs->TxBuffB);
+	writel(lp->dma_addr + txoffset,
+	       &lp->lan_saa9730_regs->TxBuffA);
+	writel(lp->dma_addr + txoffset +
+	       LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_TXM_Q_SIZE,
+	       &lp->lan_saa9730_regs->TxBuffB);
 
 	/* Set packet number */
-	outl((lp->DmaRcvPackets << PK_COUNT_RX_A_SHF) |
-	     (lp->DmaRcvPackets << PK_COUNT_RX_B_SHF) |
-	     (lp->DmaTxmPackets << PK_COUNT_TX_A_SHF) |
-	     (lp->DmaTxmPackets << PK_COUNT_TX_B_SHF),
-	     &lp->lan_saa9730_regs->PacketCount);
+	writel((lp->DmaRcvPackets << PK_COUNT_RX_A_SHF) |
+	       (lp->DmaRcvPackets << PK_COUNT_RX_B_SHF) |
+	       (lp->DmaTxmPackets << PK_COUNT_TX_A_SHF) |
+	       (lp->DmaTxmPackets << PK_COUNT_TX_B_SHF),
+	       &lp->lan_saa9730_regs->PacketCount);
 
 	return 0;
 
@@ -326,10 +325,10 @@ static int lan_saa9730_cam_load(struct lan_saa9730_private *lp)
 
 	for (i = 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
 		/* First set address to where data is written */
-		outl(i, &lp->lan_saa9730_regs->CamAddress);
-		outl((NetworkAddress[0] << 24) | (NetworkAddress[1] << 16)
-		     | (NetworkAddress[2] << 8) | NetworkAddress[3],
-		     &lp->lan_saa9730_regs->CamData);
+		writel(i, &lp->lan_saa9730_regs->CamAddress);
+		writel((NetworkAddress[0] << 24) | (NetworkAddress[1] << 16) |
+		       (NetworkAddress[2] << 8) | NetworkAddress[3],
+		       &lp->lan_saa9730_regs->CamData);
 		NetworkAddress += 4;
 	}
 	return 0;
@@ -365,8 +364,8 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 	}
 
 	/* Now set the control and address register. */
-	outl(MD_CA_BUSY | PHY_STATUS | PHY_ADDRESS << MD_CA_PHY_SHF,
-	     &lp->lan_saa9730_regs->StationMgmtCtl);
+	writel(MD_CA_BUSY | PHY_STATUS | PHY_ADDRESS << MD_CA_PHY_SHF,
+	       &lp->lan_saa9730_regs->StationMgmtCtl);
 
 	/* check link status, spin here till station is not busy */
 	i = 0;
@@ -391,23 +390,23 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 		/* Link is down, reset the PHY first. */
 
 		/* set PHY address = 'CONTROL' */
-		outl(PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR | PHY_CONTROL,
-		     &lp->lan_saa9730_regs->StationMgmtCtl);
+		writel(PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR | PHY_CONTROL,
+		       &lp->lan_saa9730_regs->StationMgmtCtl);
 
 		/* Wait for 1 ms. */
 		mdelay(1);
 
 		/* set 'CONTROL' = force reset and renegotiate */
-		outl(PHY_CONTROL_RESET | PHY_CONTROL_AUTO_NEG |
-		     PHY_CONTROL_RESTART_AUTO_NEG,
-		     &lp->lan_saa9730_regs->StationMgmtData);
+		writel(PHY_CONTROL_RESET | PHY_CONTROL_AUTO_NEG |
+		       PHY_CONTROL_RESTART_AUTO_NEG,
+		       &lp->lan_saa9730_regs->StationMgmtData);
 
 		/* Wait for 50 ms. */
 		mdelay(50);
 
 		/* set 'BUSY' to start operation */
-		outl(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR |
-		     PHY_CONTROL, &lp->lan_saa9730_regs->StationMgmtCtl);
+		writel(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR |
+		       PHY_CONTROL, &lp->lan_saa9730_regs->StationMgmtCtl);
 
 		/* await completion */
 		i = 0;
@@ -427,9 +426,9 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 
 		for (l = 0; l < 2; l++) {
 			/* set PHY address = 'STATUS' */
-			outl(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF |
-			     PHY_STATUS,
-			     &lp->lan_saa9730_regs->StationMgmtCtl);
+			writel(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF |
+			       PHY_STATUS,
+			       &lp->lan_saa9730_regs->StationMgmtCtl);
 
 			/* await completion */
 			i = 0;
@@ -462,35 +461,35 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 static int lan_saa9730_control_init(struct lan_saa9730_private *lp)
 {
 	/* Initialize DMA control register. */
-	outl((LANMB_ANY << DMA_CTL_MAX_XFER_SHF) |
-	     (LANEND_LITTLE << DMA_CTL_ENDIAN_SHF) |
-	     (LAN_SAA9730_RCV_Q_INT_THRESHOLD << DMA_CTL_RX_INT_COUNT_SHF)
-	     | DMA_CTL_RX_INT_TO_EN | DMA_CTL_RX_INT_EN |
-	     DMA_CTL_MAC_RX_INT_EN | DMA_CTL_MAC_TX_INT_EN,
-	     &lp->lan_saa9730_regs->LanDmaCtl);
+	writel((LANMB_ANY << DMA_CTL_MAX_XFER_SHF) |
+	       (LANEND_LITTLE << DMA_CTL_ENDIAN_SHF) |
+	       (LAN_SAA9730_RCV_Q_INT_THRESHOLD << DMA_CTL_RX_INT_COUNT_SHF)
+	       | DMA_CTL_RX_INT_TO_EN | DMA_CTL_RX_INT_EN |
+	       DMA_CTL_MAC_RX_INT_EN | DMA_CTL_MAC_TX_INT_EN,
+	       &lp->lan_saa9730_regs->LanDmaCtl);
 
 	/* Initial MAC control register. */
-	outl((MACCM_MII << MAC_CONTROL_CONN_SHF) | MAC_CONTROL_FULL_DUP,
-	     &lp->lan_saa9730_regs->MacCtl);
+	writel((MACCM_MII << MAC_CONTROL_CONN_SHF) | MAC_CONTROL_FULL_DUP,
+	       &lp->lan_saa9730_regs->MacCtl);
 
 	/* Initialize CAM control register. */
-	outl(CAM_CONTROL_COMP_EN | CAM_CONTROL_BROAD_ACC,
-	     &lp->lan_saa9730_regs->CamCtl);
+	writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_BROAD_ACC,
+	       &lp->lan_saa9730_regs->CamCtl);
 
 	/*
 	 * Initialize CAM enable register, only turn on first entry, should
 	 * contain own addr.
 	 */
-	outl(0x0001, &lp->lan_saa9730_regs->CamEnable);
+	writel(0x0001, &lp->lan_saa9730_regs->CamEnable);
 
 	/* Initialize Tx control register */
-	outl(TX_CTL_EN_COMP, &lp->lan_saa9730_regs->TxCtl);
+	writel(TX_CTL_EN_COMP, &lp->lan_saa9730_regs->TxCtl);
 
 	/* Initialize Rcv control register */
-	outl(RX_CTL_STRIP_CRC, &lp->lan_saa9730_regs->RxCtl);
+	writel(RX_CTL_STRIP_CRC, &lp->lan_saa9730_regs->RxCtl);
 
 	/* Reset DMA engine */
-	outl(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
+	writel(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
 
 	return 0;
 }
@@ -500,14 +499,14 @@ static int lan_saa9730_stop(struct lan_saa9730_private *lp)
 	int i;
 
 	/* Stop DMA first */
-	outl(readl(&lp->lan_saa9730_regs->LanDmaCtl) &
-	     ~(DMA_CTL_EN_TX_DMA | DMA_CTL_EN_RX_DMA),
-	     &lp->lan_saa9730_regs->LanDmaCtl);
+	writel(readl(&lp->lan_saa9730_regs->LanDmaCtl) &
+	       ~(DMA_CTL_EN_TX_DMA | DMA_CTL_EN_RX_DMA),
+	       &lp->lan_saa9730_regs->LanDmaCtl);
 
 	/* Set the SW Reset bits in DMA and MAC control registers */
-	outl(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
-	outl(readl(&lp->lan_saa9730_regs->MacCtl) | MAC_CONTROL_RESET,
-	     &lp->lan_saa9730_regs->MacCtl);
+	writel(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
+	writel(readl(&lp->lan_saa9730_regs->MacCtl) | MAC_CONTROL_RESET,
+	       &lp->lan_saa9730_regs->MacCtl);
 
 	/*
 	 * Wait for MAC reset to have finished. The reset bit is auto cleared
@@ -532,8 +531,8 @@ static int lan_saa9730_dma_init(struct lan_saa9730_private *lp)
 	/* Stop lan controller. */
 	lan_saa9730_stop(lp);
 
-	outl(LAN_SAA9730_DEFAULT_TIME_OUT_CNT,
-	     &lp->lan_saa9730_regs->Timeout);
+	writel(LAN_SAA9730_DEFAULT_TIME_OUT_CNT,
+	       &lp->lan_saa9730_regs->Timeout);
 
 	return 0;
 }
@@ -552,19 +551,19 @@ static int lan_saa9730_start(struct lan_saa9730_private *lp)
 	lp->PendingTxmPacketIndex = 0;
 	lp->PendingTxmBufferIndex = 0;
 
-	outl(readl(&lp->lan_saa9730_regs->LanDmaCtl) | DMA_CTL_EN_TX_DMA |
-	     DMA_CTL_EN_RX_DMA, &lp->lan_saa9730_regs->LanDmaCtl);
+	writel(readl(&lp->lan_saa9730_regs->LanDmaCtl) | DMA_CTL_EN_TX_DMA |
+	       DMA_CTL_EN_RX_DMA, &lp->lan_saa9730_regs->LanDmaCtl);
 
 	/* For Tx, turn on MAC then DMA */
-	outl(readl(&lp->lan_saa9730_regs->TxCtl) | TX_CTL_TX_EN,
-	     &lp->lan_saa9730_regs->TxCtl);
+	writel(readl(&lp->lan_saa9730_regs->TxCtl) | TX_CTL_TX_EN,
+	       &lp->lan_saa9730_regs->TxCtl);
 
 	/* For Rx, turn on DMA then MAC */
-	outl(readl(&lp->lan_saa9730_regs->RxCtl) | RX_CTL_RX_EN,
-	     &lp->lan_saa9730_regs->RxCtl);
+	writel(readl(&lp->lan_saa9730_regs->RxCtl) | RX_CTL_RX_EN,
+	       &lp->lan_saa9730_regs->RxCtl);
 
 	/* Set Ok2Use to let hardware own the buffers.	*/
-	outl(OK2USE_RX_A | OK2USE_RX_B, &lp->lan_saa9730_regs->Ok2Use);
+	writel(OK2USE_RX_A | OK2USE_RX_B, &lp->lan_saa9730_regs->Ok2Use);
 
 	return 0;
 }
@@ -587,7 +586,7 @@ static int lan_saa9730_tx(struct net_device *dev)
 		printk("lan_saa9730_tx interrupt\n");
 
 	/* Clear interrupt. */
-	outl(DMA_STATUS_MAC_TX_INT, &lp->lan_saa9730_regs->DmaStatus);
+	writel(DMA_STATUS_MAC_TX_INT, &lp->lan_saa9730_regs->DmaStatus);
 
 	while (1) {
 		pPacket = lp->TxmBuffer[lp->PendingTxmBufferIndex]
@@ -660,8 +659,8 @@ static int lan_saa9730_rx(struct net_device *dev)
 		printk("lan_saa9730_rx interrupt\n");
 
 	/* Clear receive interrupts. */
-	outl(DMA_STATUS_MAC_RX_INT | DMA_STATUS_RX_INT |
-	     DMA_STATUS_RX_TO_INT, &lp->lan_saa9730_regs->DmaStatus);
+	writel(DMA_STATUS_MAC_RX_INT | DMA_STATUS_RX_INT |
+	       DMA_STATUS_RX_TO_INT, &lp->lan_saa9730_regs->DmaStatus);
 
 	/* Address next packet */
 	BufferIndex = lp->NextRcvBufferIndex;
@@ -725,8 +724,8 @@ static int lan_saa9730_rx(struct net_device *dev)
 		*pPacket = cpu_to_le32(RXSF_READY << RX_STAT_CTL_OWNER_SHF);
 
 		/* Make sure A or B is available to hardware as appropriate. */
-		outl(BufferIndex ? OK2USE_RX_B : OK2USE_RX_A,
-		     &lp->lan_saa9730_regs->Ok2Use);
+		writel(BufferIndex ? OK2USE_RX_B : OK2USE_RX_A,
+		       &lp->lan_saa9730_regs->Ok2Use);
 
 		/* Go to next packet in sequence. */
 		lp->NextRcvPacketIndex++;
@@ -844,8 +843,8 @@ static int lan_saa9730_write(struct lan_saa9730_private *lp,
 			    (len << TX_STAT_CTL_LENGTH_SHF));
 
 	/* Make sure A or B is available to hardware as appropriate. */
-	outl(BufferIndex ? OK2USE_TX_B : OK2USE_TX_A,
-	     &lp->lan_saa9730_regs->Ok2Use);
+	writel(BufferIndex ? OK2USE_TX_B : OK2USE_TX_A,
+	       &lp->lan_saa9730_regs->Ok2Use);
 
 	return 0;
 }
@@ -938,15 +937,15 @@ static void lan_saa9730_set_multicast(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 		/* accept all packets */
-		outl(CAM_CONTROL_COMP_EN | CAM_CONTROL_STATION_ACC |
-		     CAM_CONTROL_GROUP_ACC | CAM_CONTROL_BROAD_ACC,
-		     &lp->lan_saa9730_regs->CamCtl);
+		writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_STATION_ACC |
+		       CAM_CONTROL_GROUP_ACC | CAM_CONTROL_BROAD_ACC,
+		       &lp->lan_saa9730_regs->CamCtl);
 	} else {
 		if (dev->flags & IFF_ALLMULTI) {
 			/* accept all multicast packets */
-			outl(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
-			     CAM_CONTROL_BROAD_ACC,
-			     &lp->lan_saa9730_regs->CamCtl);
+			writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
+			       CAM_CONTROL_BROAD_ACC,
+			       &lp->lan_saa9730_regs->CamCtl);
 		} else {
 			/*
 			 * Will handle the multicast stuff later. -carstenl
