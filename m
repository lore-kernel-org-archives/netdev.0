From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 4/5] r8169: uniformize comments
Date: Tue, 22 Feb 2005 00:57:18 +0100
Message-ID: <20050221235718.GD31723@electric-eye.fr.zoreil.com>
References: <20050221235125.GD26248@electric-eye.fr.zoreil.com> <20050221235301.GA31723@electric-eye.fr.zoreil.com> <20050221235450.GB31723@electric-eye.fr.zoreil.com> <20050221235611.GC31723@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050221235611.GC31723@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Uniformize comments

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-430 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-430	2005-02-18 22:21:13.590966183 +0100
+++ b/drivers/net/r8169.c	2005-02-18 22:32:43.918377456 +0100
@@ -48,7 +48,7 @@ VERSION 2.2LK	<2005/01/25>
 	- VLAN
 	- baby (< 7200) Jumbo frames support
 	- Merge of Realtek's version 2.2 (new phy)
-*/
+ */
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -107,13 +107,13 @@ static int num_media = 0;
 static int max_interrupt_work = 20;
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
-   The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
+   The RTL chips use a 64 element hash table based on the Ethernet CRC. */
 static int multicast_filter_limit = 32;
 
-/* MAC address length*/
+/* MAC address length */
 #define MAC_ADDR_LEN	6
 
-#define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer.  */
+#define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
@@ -226,7 +226,7 @@ enum RTL8169_registers {
 };
 
 enum RTL8169_register_content {
-	/*InterruptStatusBits */
+	/* InterruptStatusBits */
 	SYSErr = 0x8000,
 	PCSTimeout = 0x4000,
 	SWInt = 0x0100,
@@ -239,23 +239,23 @@ enum RTL8169_register_content {
 	RxErr = 0x02,
 	RxOK = 0x01,
 
-	/*RxStatusDesc */
+	/* RxStatusDesc */
 	RxRES = 0x00200000,
 	RxCRC = 0x00080000,
 	RxRUNT = 0x00100000,
 	RxRWT = 0x00400000,
 
-	/*ChipCmdBits */
+	/* ChipCmdBits */
 	CmdReset = 0x10,
 	CmdRxEnb = 0x08,
 	CmdTxEnb = 0x04,
 	RxBufEmpty = 0x01,
 
-	/*Cfg9346Bits */
+	/* Cfg9346Bits */
 	Cfg9346_Lock = 0x00,
 	Cfg9346_Unlock = 0xC0,
 
-	/*rx_mode_bits */
+	/* rx_mode_bits */
 	AcceptErr = 0x20,
 	AcceptRunt = 0x10,
 	AcceptBroadcast = 0x08,
@@ -263,11 +263,11 @@ enum RTL8169_register_content {
 	AcceptMyPhys = 0x02,
 	AcceptAllPhys = 0x01,
 
-	/*RxConfigBits */
+	/* RxConfigBits */
 	RxCfgFIFOShift = 13,
 	RxCfgDMAShift = 8,
 
-	/*TxConfigBits */
+	/* TxConfigBits */
 	TxInterFrameGapShift = 24,
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
@@ -285,7 +285,7 @@ enum RTL8169_register_content {
 	PCIDAC		= (1 << 4),
 	PCIMulRW	= (1 << 3),
 
-	/*rtl8169_PHYstatus */
+	/* rtl8169_PHYstatus */
 	TBI_Enable = 0x80,
 	TxFlowCtrl = 0x40,
 	RxFlowCtrl = 0x20,
@@ -295,38 +295,38 @@ enum RTL8169_register_content {
 	LinkStatus = 0x02,
 	FullDup = 0x01,
 
-	/*GIGABIT_PHY_registers */
+	/* GIGABIT_PHY_registers */
 	PHY_CTRL_REG = 0,
 	PHY_STAT_REG = 1,
 	PHY_AUTO_NEGO_REG = 4,
 	PHY_1000_CTRL_REG = 9,
 
-	/*GIGABIT_PHY_REG_BIT */
+	/* GIGABIT_PHY_REG_BIT */
 	PHY_Restart_Auto_Nego = 0x0200,
 	PHY_Enable_Auto_Nego = 0x1000,
 
-	//PHY_STAT_REG = 1;
+	/* PHY_STAT_REG = 1 */
 	PHY_Auto_Neco_Comp = 0x0020,
 
-	//PHY_AUTO_NEGO_REG = 4;
+	/* PHY_AUTO_NEGO_REG = 4 */
 	PHY_Cap_10_Half = 0x0020,
 	PHY_Cap_10_Full = 0x0040,
 	PHY_Cap_100_Half = 0x0080,
 	PHY_Cap_100_Full = 0x0100,
 
-	//PHY_1000_CTRL_REG = 9;
+	/* PHY_1000_CTRL_REG = 9 */
 	PHY_Cap_1000_Full = 0x0200,
 
 	PHY_Cap_Null = 0x0,
 
-	/*_MediaType*/
+	/* _MediaType */
 	_10_Half = 0x01,
 	_10_Full = 0x02,
 	_100_Half = 0x04,
 	_100_Full = 0x08,
 	_1000_Full = 0x10,
 
-	/*_TBICSRBit*/
+	/* _TBICSRBit */
 	TBILinkOK = 0x02000000,
 };
 
@@ -382,7 +382,7 @@ struct ring_info {
 
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
-	struct pci_dev *pci_dev;	/* Index of PCI device  */
+	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;		/* spin lock flag */
 	int chipset;
@@ -463,7 +463,7 @@ static void mdio_write(void __iomem *ioa
 	udelay(1000);
 
 	for (i = 2000; i > 0; i--) {
-		// Check if the RTL8169 has completed writing to the specified MII register
+		/* Check if the RTL8169 has completed writing to the specified MII register */
 		if (!(RTL_R32(PHYAR) & 0x80000000)) 
 			break;
 		udelay(100);
@@ -478,7 +478,7 @@ static int mdio_read(void __iomem *ioadd
 	udelay(1000);
 
 	for (i = 2000; i > 0; i--) {
-		// Check if the RTL8169 has completed retrieving data from the specified MII register
+		/* Check if the RTL8169 has completed retrieving data from the specified MII register */
 		if (RTL_R32(PHYAR) & 0x80000000) {
 			value = (int) (RTL_R32(PHYAR) & 0xFFFF);
 			break;
@@ -1037,7 +1037,7 @@ static void rtl8169_hw_phy_config(struct
 		return;
 	}
 
-	// phy config for RTL8169s mac_version C chip
+	/* phy config for RTL8169s mac_version C chip */
 	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
 	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
 	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
@@ -1159,7 +1159,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	assert(ioaddr_out != NULL);
 
-	// dev zeroed in alloc_etherdev 
+	/* dev zeroed in alloc_etherdev */
 	dev = alloc_etherdev(sizeof (*tp));
 	if (dev == NULL) {
 		printk(KERN_ERR PFX "unable to alloc new ethernet\n");
@@ -1170,7 +1170,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = netdev_priv(dev);
 
-	// enable device (incl. PCI PM wakeup and hotplug setup)
+	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc) {
 		printk(KERN_ERR PFX "%s: enable failure\n", pdev->slot_name);
@@ -1194,14 +1194,14 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_mwi;
 	}
 
-	// make sure PCI base addr 1 is MMIO
+	/* make sure PCI base addr 1 is MMIO */
 	if (!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
 		printk(KERN_ERR PFX
 		       "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out_mwi;
 	}
-	// check for weird/broken PCI region reporting
+	/* check for weird/broken PCI region reporting */
 	if (pci_resource_len(pdev, 1) < R8169_REGS_SIZE) {
 		printk(KERN_ERR PFX "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
@@ -1231,7 +1231,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	// ioremap MMIO region 
+	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, 1), R8169_REGS_SIZE);
 	if (ioaddr == NULL) {
 		printk(KERN_ERR PFX "cannot remap MMIO, aborting\n");
@@ -1239,20 +1239,20 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	// Unneeded ? Don't mess with Mrs. Murphy.
+	/* Unneeded ? Don't mess with Mrs. Murphy. */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-	// Soft reset the chip. 
+	/* Soft reset the chip. */
 	RTL_W8(ChipCmd, CmdReset);
 
-	// Check that the chip has finished the reset.
+	/* Check that the chip has finished the reset. */
 	for (i = 1000; i > 0; i--) {
 		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
 			break;
 		udelay(10);
 	}
 
-	// Identify chip attached to board
+	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 	rtl8169_get_phy_version(tp, ioaddr);
 
@@ -1340,7 +1340,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		tp->link_ok = rtl8169_xmii_link_ok;
 	}
 
-	// Get MAC address.  FIXME: read EEPROM
+	/* Get MAC address.  FIXME: read EEPROM */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 
@@ -1578,10 +1578,10 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	// For gigabit rtl8169, MTU + header + CRC + VLAN
+	/* For gigabit rtl8169, MTU + header + CRC + VLAN */
 	RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
-	// Set Rx Config register
+	/* Set Rx Config register */
 	i = rtl8169_rx_config |
 		(RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
 	RTL_W32(RxConfig, i);
@@ -2009,7 +2009,7 @@ static int rtl8169_start_xmit(struct sk_
 
 	smp_wmb();
 
-	RTL_W8(TxPoll, 0x40);	//set polling bit
+	RTL_W8(TxPoll, 0x40);	/* set polling bit */
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
@@ -2290,11 +2290,11 @@ rtl8169_interrupt(int irq, void *dev_ins
 		}
 		break;
 #else
-		// Rx interrupt 
+		/* Rx interrupt */
 		if (status & (RxOK | RxOverflow | RxFIFOOver)) {
 			rtl8169_rx_interrupt(dev, tp, ioaddr);
 		}
-		// Tx interrupt
+		/* Tx interrupt */
 		if (status & (TxOK | TxErr))
 			rtl8169_tx_interrupt(dev, tp, ioaddr);
 #endif

_
