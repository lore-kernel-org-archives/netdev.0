From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 2/2] r8169: RTL8169_registers clean-up
Date: Mon, 28 Feb 2005 13:04:44 -0600
Message-ID: <20050228190444.GA13415@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: romieu@fr.zoreil.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

An attempt to clean-up RTL8169_registers and  RTL8169_register_content.
Adjusted tab alignment and converted decimal values to hex.

Applies cleanly to linux-2.6.11-rc4-mm1 and tested on amd64

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- drivers/net/r8169.c	2005-02-27 11:45:27.000000000 -0600
+++ drivers/net/r8169.c.new	2005-02-27 11:44:44.000000000 -0600
@@ -186,91 +186,91 @@ static int rx_copybreak = 200;
 static int use_dac;
 
 enum RTL8169_registers {
-	MAC0 = 0,		/* Ethernet hardware address. */
-	MAR0 = 8,		/* Multicast filter. */
+	MAC0 		= 0x00,	/* Ethernet hardware address. */
+	MAR0 		= 0x08,	/* Multicast filter. */
 	TxDescStartAddrLow = 0x20,
 	TxDescStartAddrHigh = 0x24,
 	TxHDescStartAddrLow = 0x28,
 	TxHDescStartAddrHigh = 0x2c,
-	FLASH = 0x30,
-	ERSR = 0x36,
-	ChipCmd = 0x37,
-	TxPoll = 0x38,
-	IntrMask = 0x3C,
-	IntrStatus = 0x3E,
-	TxConfig = 0x40,
-	RxConfig = 0x44,
-	RxMissed = 0x4C,
-	Cfg9346 = 0x50,
-	Config0 = 0x51,
-	Config1 = 0x52,
-	Config2 = 0x53,
-	Config3 = 0x54,
-	Config4 = 0x55,
-	Config5 = 0x56,
-	MultiIntr = 0x5C,
-	PHYAR = 0x60,
-	TBICSR = 0x64,
-	TBI_ANAR = 0x68,
-	TBI_LPAR = 0x6A,
-	PHYstatus = 0x6C,
-	RxMaxSize = 0xDA,
-	CPlusCmd = 0xE0,
-	IntrMitigate = 0xE2,
-	RxDescAddrLow = 0xE4,
-	RxDescAddrHigh = 0xE8,
-	EarlyTxThres = 0xEC,
-	FuncEvent = 0xF0,
-	FuncEventMask = 0xF4,
+	FLASH 		= 0x30,
+	ERSR 		= 0x36,
+	ChipCmd 	= 0x37,
+	TxPoll 		= 0x38,
+	IntrMask 	= 0x3C,
+	IntrStatus 	= 0x3E,
+	TxConfig 	= 0x40,
+	RxConfig 	= 0x44,
+	RxMissed 	= 0x4C,
+	Cfg9346 	= 0x50,
+	Config0 	= 0x51,
+	Config1 	= 0x52,
+	Config2 	= 0x53,
+	Config3 	= 0x54,
+	Config4 	= 0x55,
+	Config5 	= 0x56,
+	MultiIntr 	= 0x5C,
+	PHYAR 		= 0x60,
+	TBICSR 		= 0x64,
+	TBI_ANAR 	= 0x68,
+	TBI_LPAR 	= 0x6A,
+	PHYstatus 	= 0x6C,
+	RxMaxSize 	= 0xDA,
+	CPlusCmd 	= 0xE0,
+	IntrMitigate 	= 0xE2,
+	RxDescAddrLow 	= 0xE4,
+	RxDescAddrHigh 	= 0xE8,
+	EarlyTxThres 	= 0xEC,
+	FuncEvent 	= 0xF0,
+	FuncEventMask 	= 0xF4,
 	FuncPresetState = 0xF8,
-	FuncForceEvent = 0xFC,
+	FuncForceEvent 	= 0xFC,
 };
 
 enum RTL8169_register_content {
 	/* InterruptStatusBits */
-	SYSErr = 0x8000,
-	PCSTimeout = 0x4000,
-	SWInt = 0x0100,
-	TxDescUnavail = 0x80,
-	RxFIFOOver = 0x40,
-	LinkChg = 0x20,
-	RxOverflow = 0x10,
-	TxErr = 0x08,
-	TxOK = 0x04,
-	RxErr = 0x02,
-	RxOK = 0x01,
+	SYSErr 		= 0x8000,
+	PCSTimeout	= 0x4000,
+	SWInt 		= 0x0100,
+	TxDescUnavail 	= 0x80,
+	RxFIFOOver 	= 0x40,
+	LinkChg 	= 0x20,
+	RxOverflow 	= 0x10,
+	TxErr 		= 0x08,
+	TxOK 		= 0x04,
+	RxErr 		= 0x02,
+	RxOK 		= 0x01,
 
 	/* RxStatusDesc */
-	RxRES = 0x00200000,
-	RxCRC = 0x00080000,
-	RxRUNT = 0x00100000,
-	RxRWT = 0x00400000,
+	RxRES		= 0x00200000,
+	RxCRC		= 0x00080000,
+	RxRUNT		= 0x00100000,
+	RxRWT 		= 0x00400000,
 
 	/* ChipCmdBits */
-	CmdReset = 0x10,
-	CmdRxEnb = 0x08,
-	CmdTxEnb = 0x04,
-	RxBufEmpty = 0x01,
+	CmdReset 	= 0x10,
+	CmdRxEnb 	= 0x08,
+	CmdTxEnb 	= 0x04,
+	RxBufEmpty 	= 0x01,
 
 	/* Cfg9346Bits */
-	Cfg9346_Lock = 0x00,
-	Cfg9346_Unlock = 0xC0,
+	Cfg9346_Lock 	= 0x00,
+	Cfg9346_Unlock 	= 0xC0,
 
 	/* rx_mode_bits */
-	AcceptErr = 0x20,
-	AcceptRunt = 0x10,
+	AcceptErr 	= 0x20,
+	AcceptRunt 	= 0x10,
 	AcceptBroadcast = 0x08,
 	AcceptMulticast = 0x04,
-	AcceptMyPhys = 0x02,
-	AcceptAllPhys = 0x01,
+	AcceptMyPhys 	= 0x02,
+	AcceptAllPhys 	= 0x01,
 
 	/* RxConfigBits */
-	RxCfgFIFOShift = 13,
-	RxCfgDMAShift = 8,
+	RxCfgFIFOShift 	= 0x0D,
+	RxCfgDMAShift 	= 0x08,
 
 	/* TxConfigBits */
-	TxInterFrameGapShift = 24,
-	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
+	TxInterFrameGapShift = 0x18,
+	TxDMAShift 	= 0x08, /* DMA burst value (0-7) is shiftied this many bits */
 
 	/* TBICSR p.28 */
 	TBIReset	= 0x80000000,
@@ -287,20 +287,20 @@ enum RTL8169_register_content {
 	PCIMulRW	= (1 << 3),
 
 	/* rtl8169_PHYstatus */
-	TBI_Enable = 0x80,
-	TxFlowCtrl = 0x40,
-	RxFlowCtrl = 0x20,
-	_1000bpsF = 0x10,
-	_100bps = 0x08,
-	_10bps = 0x04,
-	LinkStatus = 0x02,
-	FullDup = 0x01,
+	TBI_Enable 	= 0x80,
+	TxFlowCtrl 	= 0x40,
+	RxFlowCtrl 	= 0x20,
+	_1000bpsF 	= 0x10,
+	_100bps 	= 0x08,
+	_10bps 		= 0x04,
+	LinkStatus 	= 0x02,
+	FullDup 	= 0x01,
 
 	/* GIGABIT_PHY_registers */
-	PHY_CTRL_REG = 0,
-	PHY_STAT_REG = 1,
-	PHY_AUTO_NEGO_REG = 4,
-	PHY_1000_CTRL_REG = 9,
+	PHY_CTRL_REG 	= 0x00,
+	PHY_STAT_REG 	= 0x01,
+	PHY_AUTO_NEGO_REG = 0x04,
+	PHY_1000_CTRL_REG = 0x09,
 
 	/* GIGABIT_PHY_REG_BIT */
 	PHY_Restart_Auto_Nego = 0x0200,
@@ -311,24 +311,24 @@ enum RTL8169_register_content {
 
 	/* PHY_AUTO_NEGO_REG = 4 */
 	PHY_Cap_10_Half = 0x0020,
-	PHY_Cap_10_Full = 0x0040,
+	PHY_Cap_10_Full	= 0x0040,
 	PHY_Cap_100_Half = 0x0080,
 	PHY_Cap_100_Full = 0x0100,
 
 	/* PHY_1000_CTRL_REG = 9 */
 	PHY_Cap_1000_Full = 0x0200,
 
-	PHY_Cap_Null = 0x0,
+	PHY_Cap_Null 	= 0x00,
 
 	/* _MediaType */
-	_10_Half = 0x01,
-	_10_Full = 0x02,
-	_100_Half = 0x04,
-	_100_Full = 0x08,
-	_1000_Full = 0x10,
+	_10_Half 	= 0x01,
+	_10_Full 	= 0x02,
+	_100_Half 	= 0x04,
+	_100_Full 	= 0x08,
+	_1000_Full 	= 0x10,
 
 	/* _TBICSRBit */
-	TBILinkOK = 0x02000000,
+	TBILinkOK 	= 0x02000000,
 };
 
 enum _DescStatusBit {
