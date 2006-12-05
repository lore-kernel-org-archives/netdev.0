From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skge: fix sparse warnings
Date: Tue, 5 Dec 2006 12:02:50 -0800
Message-ID: <20061205120250.36c1b198@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:50364 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968669AbWLEUC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 15:02:58 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix sparse warnings from using enum as part of arithmetic
expression, and comment indentation fixes

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/skge.h |  150 ++++++++++++++++++++++++++--------------------------
 1 files changed, 75 insertions(+), 75 deletions(-)

diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index 537c0aa..bc79f9e 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -389,10 +389,10 @@ #define SK_RI_TO_53	36		/* RAM interface
 /* Packet Arbiter Registers */
 /*	B3_PA_CTRL		16 bit	Packet Arbiter Ctrl Register */
 enum {
-	PA_CLR_TO_TX2	= 1<<13,	/* Clear IRQ Packet Timeout TX2 */
-	PA_CLR_TO_TX1	= 1<<12,	/* Clear IRQ Packet Timeout TX1 */
-	PA_CLR_TO_RX2	= 1<<11,	/* Clear IRQ Packet Timeout RX2 */
-	PA_CLR_TO_RX1	= 1<<10,	/* Clear IRQ Packet Timeout RX1 */
+	PA_CLR_TO_TX2	= 1<<13,/* Clear IRQ Packet Timeout TX2 */
+	PA_CLR_TO_TX1	= 1<<12,/* Clear IRQ Packet Timeout TX1 */
+	PA_CLR_TO_RX2	= 1<<11,/* Clear IRQ Packet Timeout RX2 */
+	PA_CLR_TO_RX1	= 1<<10,/* Clear IRQ Packet Timeout RX1 */
 	PA_ENA_TO_TX2	= 1<<9,	/* Enable  Timeout Timer TX2 */
 	PA_DIS_TO_TX2	= 1<<8,	/* Disable Timeout Timer TX2 */
 	PA_ENA_TO_TX1	= 1<<7,	/* Enable  Timeout Timer TX1 */
@@ -481,14 +481,14 @@ #define Q_ADDR(reg, offs) (B8_Q_REGS + (
 /* RAM Buffer Register Offsets */
 enum {
 
-	RB_START	= 0x00,/* 32 bit	RAM Buffer Start Address */
+	RB_START= 0x00,/* 32 bit	RAM Buffer Start Address */
 	RB_END	= 0x04,/* 32 bit	RAM Buffer End Address */
 	RB_WP	= 0x08,/* 32 bit	RAM Buffer Write Pointer */
 	RB_RP	= 0x0c,/* 32 bit	RAM Buffer Read Pointer */
-	RB_RX_UTPP	= 0x10,/* 32 bit	Rx Upper Threshold, Pause Packet */
-	RB_RX_LTPP	= 0x14,/* 32 bit	Rx Lower Threshold, Pause Packet */
-	RB_RX_UTHP	= 0x18,/* 32 bit	Rx Upper Threshold, High Prio */
-	RB_RX_LTHP	= 0x1c,/* 32 bit	Rx Lower Threshold, High Prio */
+	RB_RX_UTPP= 0x10,/* 32 bit	Rx Upper Threshold, Pause Packet */
+	RB_RX_LTPP= 0x14,/* 32 bit	Rx Lower Threshold, Pause Packet */
+	RB_RX_UTHP= 0x18,/* 32 bit	Rx Upper Threshold, High Prio */
+	RB_RX_LTHP= 0x1c,/* 32 bit	Rx Lower Threshold, High Prio */
 	/* 0x10 - 0x1f:	reserved at Tx RAM Buffer Registers */
 	RB_PC	= 0x20,/* 32 bit	RAM Buffer Packet Counter */
 	RB_LEV	= 0x24,/* 32 bit	RAM Buffer Level Register */
@@ -532,7 +532,7 @@ enum {
 	PHY_ADDR_MARV	= 0,
 };
 
-#define RB_ADDR(offs, queue) (B16_RAM_REGS + (queue) + (offs))
+#define RB_ADDR(offs, queue) ((u16)B16_RAM_REGS + (u16)(queue) + (offs))
 
 /* Receive MAC FIFO, Receive LED, and Link_Sync regs (GENESIS only) */
 enum {
@@ -578,15 +578,15 @@ enum {
 	MFF_DIS_TIST	= 1<<2,	/* Disable Time Stamp Gener */
 	MFF_CLR_INTIST	= 1<<1,	/* Clear IRQ No Time Stamp */
 	MFF_CLR_INSTAT	= 1<<0,	/* Clear IRQ No Status */
-#define MFF_RX_CTRL_DEF MFF_ENA_TIM_PAT
+	MFF_RX_CTRL_DEF = MFF_ENA_TIM_PAT,
 };
 
 /*	TX_MFF_CTRL1	16 bit	Transmit MAC FIFO Control Reg 1 */
 enum {
-	MFF_CLR_PERR	= 1<<15,	/* Clear Parity Error IRQ */
-								/* Bit 14:	reserved */
-	MFF_ENA_PKT_REC	= 1<<13,	/* Enable  Packet Recovery */
-	MFF_DIS_PKT_REC	= 1<<12,	/* Disable Packet Recovery */
+	MFF_CLR_PERR	= 1<<15, /* Clear Parity Error IRQ */
+
+	MFF_ENA_PKT_REC	= 1<<13, /* Enable  Packet Recovery */
+	MFF_DIS_PKT_REC	= 1<<12, /* Disable Packet Recovery */
 
 	MFF_ENA_W4E	= 1<<7,	/* Enable  Wait for Empty */
 	MFF_DIS_W4E	= 1<<6,	/* Disable Wait for Empty */
@@ -595,9 +595,10 @@ enum {
 	MFF_DIS_LOOPB	= 1<<2,	/* Disable Loopback */
 	MFF_CLR_MAC_RST	= 1<<1,	/* Clear XMAC Reset */
 	MFF_SET_MAC_RST	= 1<<0,	/* Set   XMAC Reset */
+
+	MFF_TX_CTRL_DEF	 = MFF_ENA_PKT_REC | (u16) MFF_ENA_TIM_PAT | MFF_ENA_FLUSH,
 };
 
-#define MFF_TX_CTRL_DEF	(MFF_ENA_PKT_REC | MFF_ENA_TIM_PAT | MFF_ENA_FLUSH)
 
 /*	RX_MFF_TST2	 	 8 bit	Receive MAC FIFO Test Register 2 */
 /*	TX_MFF_TST2	 	 8 bit	Transmit MAC FIFO Test Register 2 */
@@ -1304,8 +1305,8 @@ enum {
 
 /* special defines for FIBER (88E1011S only) */
 enum {
-	PHY_M_AN_ASP_X	= 1<<8, /* Asymmetric Pause */
-	PHY_M_AN_PC_X	= 1<<7, /* MAC Pause implemented */
+	PHY_M_AN_ASP_X		= 1<<8, /* Asymmetric Pause */
+	PHY_M_AN_PC_X		= 1<<7, /* MAC Pause implemented */
 	PHY_M_AN_1000X_AHD	= 1<<6, /* Advertise 10000Base-X Half Duplex */
 	PHY_M_AN_1000X_AFD	= 1<<5, /* Advertise 10000Base-X Full Duplex */
 };
@@ -1320,7 +1321,7 @@ enum {
 
 /*****  PHY_MARV_1000T_CTRL	16 bit r/w	1000Base-T Control Reg *****/
 enum {
-	PHY_M_1000C_TEST	= 7<<13,/* Bit 15..13:	Test Modes */
+	PHY_M_1000C_TEST= 7<<13,/* Bit 15..13:	Test Modes */
 	PHY_M_1000C_MSE	= 1<<12, /* Manual Master/Slave Enable */
 	PHY_M_1000C_MSC	= 1<<11, /* M/S Configuration (1=Master) */
 	PHY_M_1000C_MPD	= 1<<10, /* Multi-Port Device */
@@ -1349,7 +1350,7 @@ enum {
 	PHY_M_PC_EN_DET_PLUS	= 3<<8, /* Energy Detect Plus (Mode 2) */
 };
 
-#define PHY_M_PC_MDI_XMODE(x)	(((x)<<5) & PHY_M_PC_MDIX_MSK)
+#define PHY_M_PC_MDI_XMODE(x)	((((u16)(x)<<5) & PHY_M_PC_MDIX_MSK)
 
 enum {
 	PHY_M_PC_MAN_MDI	= 0, /* 00 = Manual MDI configuration */
@@ -1432,24 +1433,24 @@ enum {
 	PHY_M_EC_DIS_LINK_P = 1<<12, /* Disable Link Pulses (88E1111 only) */
 	PHY_M_EC_M_DSC_MSK  = 3<<10, /* Bit 11..10:	Master Downshift Counter */
 					/* (88E1011 only) */
-	PHY_M_EC_S_DSC_MSK	= 3<<8,/* Bit  9.. 8:	Slave  Downshift Counter */
+	PHY_M_EC_S_DSC_MSK  = 3<<8,  /* Bit  9.. 8:	Slave  Downshift Counter */
 				       /* (88E1011 only) */
-	PHY_M_EC_M_DSC_MSK2	= 7<<9,/* Bit 11.. 9:	Master Downshift Counter */
+	PHY_M_EC_M_DSC_MSK2  = 7<<9, /* Bit 11.. 9:	Master Downshift Counter */
 					/* (88E1111 only) */
-	PHY_M_EC_DOWN_S_ENA	= 1<<8, /* Downshift Enable (88E1111 only) */
+	PHY_M_EC_DOWN_S_ENA  = 1<<8, /* Downshift Enable (88E1111 only) */
 					/* !!! Errata in spec. (1 = disable) */
-	PHY_M_EC_RX_TIM_CT	= 1<<7, /* RGMII Rx Timing Control*/
-	PHY_M_EC_MAC_S_MSK	= 7<<4,/* Bit  6.. 4:	Def. MAC interface speed */
-	PHY_M_EC_FIB_AN_ENA	= 1<<3, /* Fiber Auto-Neg. Enable (88E1011S only) */
-	PHY_M_EC_DTE_D_ENA	= 1<<2, /* DTE Detect Enable (88E1111 only) */
-	PHY_M_EC_TX_TIM_CT	= 1<<1, /* RGMII Tx Timing Control */
-	PHY_M_EC_TRANS_DIS	= 1<<0, /* Transmitter Disable (88E1111 only) */};
-
-#define PHY_M_EC_M_DSC(x)	((x)<<10) /* 00=1x; 01=2x; 10=3x; 11=4x */
-#define PHY_M_EC_S_DSC(x)	((x)<<8) /* 00=dis; 01=1x; 10=2x; 11=3x */
-#define PHY_M_EC_MAC_S(x)	((x)<<4) /* 01X=0; 110=2.5; 111=25 (MHz) */
-
-#define PHY_M_EC_M_DSC_2(x)	((x)<<9) /* 000=1x; 001=2x; 010=3x; 011=4x */
+	PHY_M_EC_RX_TIM_CT   = 1<<7, /* RGMII Rx Timing Control*/
+	PHY_M_EC_MAC_S_MSK   = 7<<4, /* Bit  6.. 4:	Def. MAC interface speed */
+	PHY_M_EC_FIB_AN_ENA  = 1<<3, /* Fiber Auto-Neg. Enable (88E1011S only) */
+	PHY_M_EC_DTE_D_ENA   = 1<<2, /* DTE Detect Enable (88E1111 only) */
+	PHY_M_EC_TX_TIM_CT   = 1<<1, /* RGMII Tx Timing Control */
+	PHY_M_EC_TRANS_DIS   = 1<<0, /* Transmitter Disable (88E1111 only) */};
+
+#define PHY_M_EC_M_DSC(x)	((u16)(x)<<10) /* 00=1x; 01=2x; 10=3x; 11=4x */
+#define PHY_M_EC_S_DSC(x)	((u16)(x)<<8) /* 00=dis; 01=1x; 10=2x; 11=3x */
+#define PHY_M_EC_MAC_S(x)	((u16)(x)<<4) /* 01X=0; 110=2.5; 111=25 (MHz) */
+
+#define PHY_M_EC_M_DSC_2(x)	((u16)(x)<<9) /* 000=1x; 001=2x; 010=3x; 011=4x */
 											/* 100=5x; 101=6x; 110=7x; 111=8x */
 enum {
 	MAC_TX_CLK_0_MHZ	= 2,
@@ -1468,10 +1469,12 @@ enum {
 	PHY_M_LEDC_LK_C_MSK	= 7<<3,/* Bit  5.. 3: Link Control Mask */
 					/* (88E1111 only) */
 };
+#define PHY_M_LED_PULS_DUR(x)	(((u16)(x)<<12) & PHY_M_LEDC_PULS_MSK)
+#define PHY_M_LED_BLINK_RT(x)	(((u16)(x)<<8) & PHY_M_LEDC_BL_R_MSK)
 
 enum {
-	PHY_M_LEDC_LINK_MSK	= 3<<3,/* Bit  4.. 3: Link Control Mask */
-									/* (88E1011 only) */
+	PHY_M_LEDC_LINK_MSK	= 3<<3, /* Bit  4.. 3: Link Control Mask */
+					/* (88E1011 only) */
 	PHY_M_LEDC_DP_CTRL	= 1<<2, /* Duplex Control */
 	PHY_M_LEDC_DP_C_MSB	= 1<<2, /* Duplex Control (MSB, 88E1111 only) */
 	PHY_M_LEDC_RX_CTRL	= 1<<1, /* Rx Activity / Link */
@@ -1479,27 +1482,24 @@ enum {
 	PHY_M_LEDC_TX_C_MSB	= 1<<0, /* Tx Control (MSB, 88E1111 only) */
 };
 
-#define PHY_M_LED_PULS_DUR(x)	(((x)<<12) & PHY_M_LEDC_PULS_MSK)
-
 enum {
-	PULS_NO_STR	= 0,/* no pulse stretching */
-	PULS_21MS	= 1,/* 21 ms to 42 ms */
-	PULS_42MS	= 2,/* 42 ms to 84 ms */
-	PULS_84MS	= 3,/* 84 ms to 170 ms */
-	PULS_170MS	= 4,/* 170 ms to 340 ms */
-	PULS_340MS	= 5,/* 340 ms to 670 ms */
-	PULS_670MS	= 6,/* 670 ms to 1.3 s */
-	PULS_1300MS	= 7,/* 1.3 s to 2.7 s */
+	PULS_NO_STR	= 0, /* no pulse stretching */
+	PULS_21MS	= 1, /* 21 ms to 42 ms */
+	PULS_42MS	= 2, /* 42 ms to 84 ms */
+	PULS_84MS	= 3, /* 84 ms to 170 ms */
+	PULS_170MS	= 4, /* 170 ms to 340 ms */
+	PULS_340MS	= 5, /* 340 ms to 670 ms */
+	PULS_670MS	= 6, /* 670 ms to 1.3 s */
+	PULS_1300MS	= 7, /* 1.3 s to 2.7 s */
 };
 
-#define PHY_M_LED_BLINK_RT(x)	(((x)<<8) & PHY_M_LEDC_BL_R_MSK)
 
 enum {
-	BLINK_42MS	= 0,/* 42 ms */
-	BLINK_84MS	= 1,/* 84 ms */
-	BLINK_170MS	= 2,/* 170 ms */
-	BLINK_340MS	= 3,/* 340 ms */
-	BLINK_670MS	= 4,/* 670 ms */
+	BLINK_42MS	= 0, /* 42 ms */
+	BLINK_84MS	= 1, /* 84 ms */
+	BLINK_170MS	= 2, /* 170 ms */
+	BLINK_340MS	= 3, /* 340 ms */
+	BLINK_670MS	= 4, /* 670 ms */
 };
 
 /*****  PHY_MARV_LED_OVER	16 bit r/w	Manual LED Override Reg *****/
@@ -1525,7 +1525,7 @@ enum {
 	PHY_M_EC2_FO_IMPED	= 1<<5, /* Fiber Output Impedance */
 	PHY_M_EC2_FO_M_CLK	= 1<<4, /* Fiber Mode Clock Enable */
 	PHY_M_EC2_FO_BOOST	= 1<<3, /* Fiber Output Boost */
-	PHY_M_EC2_FO_AM_MSK	= 7,/* Bit  2.. 0:	Fiber Output Amplitude */
+	PHY_M_EC2_FO_AM_MSK	= 7, /* Bit  2.. 0:	Fiber Output Amplitude */
 };
 
 /*****  PHY_MARV_EXT_P_STAT 16 bit r/w	Ext. PHY Specific Status *****/
@@ -1550,7 +1550,7 @@ enum {
 	PHY_M_CABD_DIS_WAIT	= 1<<15, /* Disable Waiting Period (Page 1) */
 					/* (88E1111 only) */
 	PHY_M_CABD_STAT_MSK	= 3<<13, /* Bit 14..13: Status Mask */
-	PHY_M_CABD_AMPL_MSK	= 0x1f<<8,/* Bit 12.. 8: Amplitude Mask */
+	PHY_M_CABD_AMPL_MSK	= 0x1f<<8, /* Bit 12.. 8: Amplitude Mask */
 					/* (88E1111 only) */
 	PHY_M_CABD_DIST_MSK	= 0xff, /* Bit  7.. 0: Distance Mask */
 };
@@ -1605,9 +1605,9 @@ enum {
 
 /*****  PHY_MARV_PHY_CTRL (page 3)		16 bit r/w	LED Control Reg. *****/
 enum {
-	PHY_M_LEDC_LOS_MSK	= 0xf<<12,/* Bit 15..12: LOS LED Ctrl. Mask */
+	PHY_M_LEDC_LOS_MSK	= 0xf<<12, /* Bit 15..12: LOS LED Ctrl. Mask */
 	PHY_M_LEDC_INIT_MSK	= 0xf<<8, /* Bit 11.. 8: INIT LED Ctrl. Mask */
-	PHY_M_LEDC_STA1_MSK	= 0xf<<4,/* Bit  7.. 4: STAT1 LED Ctrl. Mask */
+	PHY_M_LEDC_STA1_MSK	= 0xf<<4, /* Bit  7.. 4: STAT1 LED Ctrl. Mask */
 	PHY_M_LEDC_STA0_MSK	= 0xf, /* Bit  3.. 0: STAT0 LED Ctrl. Mask */
 };
 
@@ -1804,8 +1804,8 @@ #define IPG_DATA_DEF		0x1e
 
 /*	GM_SMI_CTRL			16 bit r/w	SMI Control Register */
 enum {
-	GM_SMI_CT_PHY_A_MSK	= 0x1f<<11,/* Bit 15..11:	PHY Device Address */
-	GM_SMI_CT_REG_A_MSK	= 0x1f<<6,/* Bit 10.. 6:	PHY Register Address */
+	GM_SMI_CT_PHY_A_MSK	= 0x1f<<11, /* Bit 15..11:	PHY Device Address */
+	GM_SMI_CT_REG_A_MSK	= 0x1f<<6, /* Bit 10.. 6:	PHY Register Address */
 	GM_SMI_CT_OP_RD		= 1<<5,	/* Bit  5:	OpCode Read (0=Write)*/
 	GM_SMI_CT_RD_VAL	= 1<<4,	/* Bit  4:	Read Valid (Read completed) */
 	GM_SMI_CT_BUSY		= 1<<3,	/* Bit  3:	Busy (Operation in progress) */
@@ -1875,9 +1875,9 @@ enum {
 
 /*	TX_GMF_CTRL_T	32 bit	Tx GMAC FIFO Control/Test */
 enum {
-	GMF_WSP_TST_ON	= 1<<18,/* Write Shadow Pointer Test On */
-	GMF_WSP_TST_OFF	= 1<<17,/* Write Shadow Pointer Test Off */
-	GMF_WSP_STEP	= 1<<16,/* Write Shadow Pointer Step/Increment */
+	GMF_WSP_TST_ON	= 1<<18, /* Write Shadow Pointer Test On */
+	GMF_WSP_TST_OFF	= 1<<17, /* Write Shadow Pointer Test Off */
+	GMF_WSP_STEP	= 1<<16, /* Write Shadow Pointer Step/Increment */
 
 	GMF_CLI_TX_FU	= 1<<6,	/* Clear IRQ Tx FIFO Underrun */
 	GMF_CLI_TX_FC	= 1<<5,	/* Clear IRQ Tx Frame Complete */
@@ -2111,18 +2111,18 @@ enum {
 
 /*	XM_MMU_CMD	16 bit r/w	MMU Command Register */
 enum {
-	XM_MMU_PHY_RDY	= 1<<12,/* Bit 12:	PHY Read Ready */
-	XM_MMU_PHY_BUSY	= 1<<11,/* Bit 11:	PHY Busy */
-	XM_MMU_IGN_PF	= 1<<10,/* Bit 10:	Ignore Pause Frame */
-	XM_MMU_MAC_LB	= 1<<9,	/* Bit  9:	Enable MAC Loopback */
-	XM_MMU_FRC_COL	= 1<<7,	/* Bit  7:	Force Collision */
-	XM_MMU_SIM_COL	= 1<<6,	/* Bit  6:	Simulate Collision */
-	XM_MMU_NO_PRE	= 1<<5,	/* Bit  5:	No MDIO Preamble */
-	XM_MMU_GMII_FD	= 1<<4,	/* Bit  4:	GMII uses Full Duplex */
-	XM_MMU_RAT_CTRL	= 1<<3,	/* Bit  3:	Enable Rate Control */
-	XM_MMU_GMII_LOOP= 1<<2,	/* Bit  2:	PHY is in Loopback Mode */
-	XM_MMU_ENA_RX	= 1<<1,	/* Bit  1:	Enable Receiver */
-	XM_MMU_ENA_TX	= 1<<0,	/* Bit  0:	Enable Transmitter */
+	XM_MMU_PHY_RDY	= 1<<12, /* Bit 12:	PHY Read Ready */
+	XM_MMU_PHY_BUSY	= 1<<11, /* Bit 11:	PHY Busy */
+	XM_MMU_IGN_PF	= 1<<10, /* Bit 10:	Ignore Pause Frame */
+	XM_MMU_MAC_LB	= 1<<9,	 /* Bit  9:	Enable MAC Loopback */
+	XM_MMU_FRC_COL	= 1<<7,	 /* Bit  7:	Force Collision */
+	XM_MMU_SIM_COL	= 1<<6,	 /* Bit  6:	Simulate Collision */
+	XM_MMU_NO_PRE	= 1<<5,	 /* Bit  5:	No MDIO Preamble */
+	XM_MMU_GMII_FD	= 1<<4,	 /* Bit  4:	GMII uses Full Duplex */
+	XM_MMU_RAT_CTRL	= 1<<3,	 /* Bit  3:	Enable Rate Control */
+	XM_MMU_GMII_LOOP= 1<<2,	 /* Bit  2:	PHY is in Loopback Mode */
+	XM_MMU_ENA_RX	= 1<<1,	 /* Bit  1:	Enable Receiver */
+	XM_MMU_ENA_TX	= 1<<0,	 /* Bit  0:	Enable Transmitter */
 };
 
 
@@ -2506,7 +2506,7 @@ static inline void skge_write8(const str
 }
 
 /* MAC Related Registers inside the device. */
-#define SK_REG(port,reg)	(((port)<<7)+(reg))
+#define SK_REG(port,reg)	(((port)<<7)+(u16)(reg))
 #define SK_XMAC_REG(port, reg) \
 	((BASE_XMAC_1 + (port) * (BASE_XMAC_2 - BASE_XMAC_1)) | (reg) << 1)
 
-- 
1.4.1



-- 
Stephen Hemminger <shemminger@osdl.org>
