From: "Javier Blanco de Torres (Neurowork)" <jblanco@neurowork.net>
Subject: [PATCH 2.6.34-git] 8139too: fix Coding Styles
Date: Mon, 12 Apr 2010 09:36:43 +0200
Message-ID: <ba865f7b49c5df1b71bc393ad42ff40a.squirrel@neurowork.net>
Reply-To: jblanco@neurowork.net
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20100412093643_10627"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway11.websitewelcome.com ([67.18.71.7]:56235 "HELO
	gateway11.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752493Ab0DLHnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 03:43:23 -0400
Received: from flozy by gator309.hostgator.com with local (Exim 4.69)
	(envelope-from <jblanco@neurowork.net>)
	id 1O1ECJ-00048P-OH
	for netdev@vger.kernel.org; Mon, 12 Apr 2010 02:36:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_20100412093643_10627
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

Fixed coding styles in the 8139too net driver.

Signed-off-by: Javier Blanco de Torres <jblanco@neurowork.net>
Signed-off-by: Alejandro Sánchez Acosta <asanchez@neurowork.net>

-- 
Javier Blanco
Community Manager
jblanco@neurowork.net

Neurowork > http://www.neurowork.net
(+34) 916 851 242
------=_20100412093643_10627
Content-Type: text/x-patch; name="8139too-patch-fix-coding-style.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
  filename="8139too-patch-fix-coding-style.patch"

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index a03d291..305491a 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -11,7 +11,7 @@
 
 	-----<snip>-----
 
-        	Written 1997-2001 by Donald Becker.
+		Written 1997-2001 by Donald Becker.
 		This software may be used and distributed according to the
 		terms of the GNU General Public License (GPL), incorporated
 		herein by reference.  Drivers based on or derived from this
@@ -117,8 +117,8 @@
 
 /* Default Message level */
 #define RTL8139_DEF_MSG_ENABLE   (NETIF_MSG_DRV   | \
-                                 NETIF_MSG_PROBE  | \
-                                 NETIF_MSG_LINK)
+				NETIF_MSG_PROBE  | \
+				NETIF_MSG_LINK)
 
 
 /* define to 1, 2 or 3 to enable copious debugging info */
@@ -132,10 +132,10 @@
 #  define assert(expr) do {} while (0)
 #else
 #  define assert(expr) \
-        if (unlikely(!(expr))) {				\
+	if (unlikely(!(expr))) {				\
 		pr_err("Assertion failed! %s,%s,%s,line=%d\n",	\
 		       #expr, __FILE__, __func__, __LINE__);	\
-        }
+	}
 #endif
 
 
@@ -149,7 +149,7 @@ static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 #ifdef CONFIG_8139TOO_PIO
 static int use_io = 1;
 #else
-static int use_io = 0;
+static int use_io;
 #endif
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
@@ -192,7 +192,8 @@ static int debug = -1;
    Threshold is bytes transferred to chip before transmission starts. */
 #define TX_FIFO_THRESH 256	/* In bytes, rounded down to 32 byte units. */
 
-/* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6==1024, 7==end of packet. */
+/* The following settings are log_2(bytes)-4: */
+/* 0 == 16 bytes .. 6==1024, 7==end of packet. */
 #define RX_FIFO_THRESH	7	/* Rx buffer level before first PCI xfer.  */
 #define RX_DMA_BURST	7	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
@@ -217,7 +218,7 @@ enum {
 #define RTL8129_CAPS	HAS_MII_XCVR
 #define RTL8139_CAPS	(HAS_CHIP_XCVR|HAS_LNK_CHNG)
 
-typedef enum {
+enum {
 	RTL8139 = 0,
 	RTL8129,
 } board_t;
@@ -272,7 +273,7 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8139_pci_tbl) = {
 
 	{0,}
 };
-MODULE_DEVICE_TABLE (pci, rtl8139_pci_tbl);
+MODULE_DEVICE_TABLE(pci, rtl8139_pci_tbl);
 
 static struct {
 	const char str[ETH_GSTRING_LEN];
@@ -385,12 +386,12 @@ enum rx_mode_bits {
 
 /* Bits in TxConfig. */
 enum tx_config_bits {
-        /* Interframe Gap Time. Only TxIFG96 doesn't violate IEEE 802.3 */
-        TxIFGShift	= 24,
-        TxIFG84		= (0 << TxIFGShift), /* 8.4us / 840ns (10 / 100Mbps) */
-        TxIFG88		= (1 << TxIFGShift), /* 8.8us / 880ns (10 / 100Mbps) */
-        TxIFG92		= (2 << TxIFGShift), /* 9.2us / 920ns (10 / 100Mbps) */
-        TxIFG96		= (3 << TxIFGShift), /* 9.6us / 960ns (10 / 100Mbps) */
+	/* Interframe Gap Time. Only TxIFG96 doesn't violate IEEE 802.3 */
+	TxIFGShift	= 24,
+	TxIFG84		= (0 << TxIFGShift), /* 8.4us / 840ns (10 / 100Mbps) */
+	TxIFG88		= (1 << TxIFGShift), /* 8.8us / 880ns (10 / 100Mbps) */
+	TxIFG92		= (2 << TxIFGShift), /* 9.2us / 920ns (10 / 100Mbps) */
+	TxIFG96		= (3 << TxIFGShift), /* 9.6us / 960ns (10 / 100Mbps) */
 
 	TxLoopBack	= (1 << 18) | (1 << 17), /* enable loopback test mode */
 	TxCRC		= (1 << 16),	/* DISABLE Tx pkt CRC append */
@@ -417,14 +418,14 @@ enum Config1Bits {
 
 /* Bits in Config3 */
 enum Config3Bits {
-	Cfg3_FBtBEn   	= (1 << 0), /* 1	= Fast Back to Back */
-	Cfg3_FuncRegEn	= (1 << 1), /* 1	= enable CardBus Function registers */
-	Cfg3_CLKRUN_En	= (1 << 2), /* 1	= enable CLKRUN */
-	Cfg3_CardB_En 	= (1 << 3), /* 1	= enable CardBus registers */
-	Cfg3_LinkUp   	= (1 << 4), /* 1	= wake up on link up */
-	Cfg3_Magic    	= (1 << 5), /* 1	= wake up on Magic Packet (tm) */
-	Cfg3_PARM_En  	= (1 << 6), /* 0	= software can set twister parameters */
-	Cfg3_GNTSel   	= (1 << 7), /* 1	= delay 1 clock from PCI GNT signal */
+	Cfg3_FBtBEn	= (1 << 0), /* 1 = Fast Back to Back */
+	Cfg3_FuncRegEn	= (1 << 1), /* 1 = enable CardBus Function registers */
+	Cfg3_CLKRUN_En	= (1 << 2), /* 1 = enable CLKRUN */
+	Cfg3_LinkUp	= (1 << 4), /* 1 = wake up on link up */
+	Cfg3_Magic	= (1 << 5), /* 1 = wake up on Magic Packet (tm) */
+	Cfg3_PARM_En	= (1 << 6), /* 0 = software can set twister*/
+						/*parameters */
+	Cfg3_GNTSel	= (1 << 7), /* 1 = delay 1 clock from PCI GNT signal */
 };
 
 /* Bits in Config4 */
@@ -434,13 +435,13 @@ enum Config4Bits {
 
 /* Bits in Config5 */
 enum Config5Bits {
-	Cfg5_PME_STS   	= (1 << 0), /* 1	= PCI reset resets PME_Status */
-	Cfg5_LANWake   	= (1 << 1), /* 1	= enable LANWake signal */
-	Cfg5_LDPS      	= (1 << 2), /* 0	= save power when link is down */
-	Cfg5_FIFOAddrPtr= (1 << 3), /* Realtek internal SRAM testing */
-	Cfg5_UWF        = (1 << 4), /* 1 = accept unicast wakeup frame */
-	Cfg5_MWF        = (1 << 5), /* 1 = accept multicast wakeup frame */
-	Cfg5_BWF        = (1 << 6), /* 1 = accept broadcast wakeup frame */
+	Cfg5_PME_STS	= (1 << 0), /* 1= PCI reset resets PME_Status */
+	Cfg5_LANWake	= (1 << 1), /* 1= enable LANWake signal */
+	Cfg5_LDPS	= (1 << 2), /* 0= save power when link is down */
+	Cfg5_FIFOAddrPtr = (1 << 3), /* Realtek internal SRAM testing */
+	Cfg5_UWF	= (1 << 4), /* 1 = accept unicast wakeup frame */
+	Cfg5_MWF	= (1 << 5), /* 1 = accept multicast wakeup frame */
+	Cfg5_BWF	= (1 << 6), /* 1 = accept broadcast wakeup frame */
 };
 
 enum RxConfigBits {
@@ -477,7 +478,7 @@ enum Cfg9346Bits {
 	Cfg9346_Unlock	= 0xC0,
 };
 
-typedef enum {
+enum {
 	CH_8139	= 0,
 	CH_8139_K,
 	CH_8139A,
@@ -542,8 +543,8 @@ static const struct {
 
 	{ "RTL-8100",
 	  HW_REVID(1, 1, 1, 1, 0, 1, 0),
- 	  HasLWake,
- 	},
+	HasLWake,
+	},
 
 	{ "RTL-8100B/8139D",
 	  HW_REVID(1, 1, 1, 0, 1, 0, 1),
@@ -588,9 +589,9 @@ struct rtl8139_private {
 				/* Twister tune state. */
 	char			twistie, twist_row, twist_col;
 
-	unsigned int		watchdog_fired : 1;
-	unsigned int		default_port : 4; /* Last dev->if_port value. */
-	unsigned int		have_thread : 1;
+	unsigned int		watchdog_fired:1;
+	unsigned int		default_port:4; /* Last dev->if_port value. */
+	unsigned int		have_thread:1;
 
 	spinlock_t		lock;
 	spinlock_t		rx_lock;
@@ -606,8 +607,8 @@ struct rtl8139_private {
 	unsigned long		fifo_copy_timeout;
 };
 
-MODULE_AUTHOR ("Jeff Garzik <jgarzik@pobox.com>");
-MODULE_DESCRIPTION ("RealTek RTL-8139 Fast Ethernet driver");
+MODULE_AUTHOR("Jeff Garzik <jgarzik@pobox.com>");
+MODULE_DESCRIPTION("RealTek RTL-8139 Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
@@ -617,52 +618,56 @@ module_param(multicast_filter_limit, int, 0);
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 module_param(debug, int, 0);
-MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
-MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
-MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
-MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
-
-static int read_eeprom (void __iomem *ioaddr, int location, int addr_len);
-static int rtl8139_open (struct net_device *dev);
-static int mdio_read (struct net_device *dev, int phy_id, int location);
-static void mdio_write (struct net_device *dev, int phy_id, int location,
+MODULE_PARM_DESC(debug, "8139too bitmapped message enable number");
+MODULE_PARM_DESC(multicast_filter_limit, "8139too maximum number "
+					"of filtered multicast addresses");
+MODULE_PARM_DESC(media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
+MODULE_PARM_DESC(full_duplex, "8139too: Force full duplex for board(s) (1)");
+
+static int read_eeprom(void __iomem *ioaddr, int location, int addr_len);
+static int rtl8139_open(struct net_device *dev);
+static int mdio_read(struct net_device *dev, int phy_id, int location);
+static void mdio_write(struct net_device *dev, int phy_id, int location,
 			int val);
 static void rtl8139_start_thread(struct rtl8139_private *tp);
-static void rtl8139_tx_timeout (struct net_device *dev);
-static void rtl8139_init_ring (struct net_device *dev);
-static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
+static void rtl8139_tx_timeout(struct net_device *dev);
+static void rtl8139_init_ring(struct net_device *dev);
+static netdev_tx_t rtl8139_start_xmit(struct sk_buff *skb,
 				       struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void rtl8139_poll_controller(struct net_device *dev);
 #endif
 static int rtl8139_set_mac_address(struct net_device *dev, void *p);
 static int rtl8139_poll(struct napi_struct *napi, int budget);
-static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance);
-static int rtl8139_close (struct net_device *dev);
-static int netdev_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
-static struct net_device_stats *rtl8139_get_stats (struct net_device *dev);
-static void rtl8139_set_rx_mode (struct net_device *dev);
-static void __set_rx_mode (struct net_device *dev);
-static void rtl8139_hw_start (struct net_device *dev);
-static void rtl8139_thread (struct work_struct *work);
+static irqreturn_t rtl8139_interrupt(int irq, void *dev_instance);
+static int rtl8139_close(struct net_device *dev);
+static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static struct net_device_stats *rtl8139_get_stats(struct net_device *dev);
+static void rtl8139_set_rx_mode(struct net_device *dev);
+static void __set_rx_mode(struct net_device *dev);
+static void rtl8139_hw_start(struct net_device *dev);
+static void rtl8139_thread(struct work_struct *work);
 static void rtl8139_tx_timeout_task(struct work_struct *work);
 static const struct ethtool_ops rtl8139_ethtool_ops;
 
 /* write MMIO register, with flush */
 /* Flush avoids rtl8139 bug w/ posted MMIO writes */
-#define RTL_W8_F(reg, val8)	do { iowrite8 ((val8), ioaddr + (reg)); ioread8 (ioaddr + (reg)); } while (0)
-#define RTL_W16_F(reg, val16)	do { iowrite16 ((val16), ioaddr + (reg)); ioread16 (ioaddr + (reg)); } while (0)
-#define RTL_W32_F(reg, val32)	do { iowrite32 ((val32), ioaddr + (reg)); ioread32 (ioaddr + (reg)); } while (0)
+#define RTL_W8_F(reg, val8)	do { iowrite8((val8), "
+		"ioaddr + (reg)); ioread8(ioaddr + (reg)); } while (0)
+#define RTL_W16_F(reg, val16)	do { iowrite16((val16), "
+		"ioaddr + (reg)); ioread16(ioaddr + (reg)); } while (0)
+#define RTL_W32_F(reg, val32)	do { iowrite32((val32), "
+		"ioaddr + (reg)); ioread32(ioaddr + (reg)); } while (0)
 
 /* write MMIO register */
-#define RTL_W8(reg, val8)	iowrite8 ((val8), ioaddr + (reg))
-#define RTL_W16(reg, val16)	iowrite16 ((val16), ioaddr + (reg))
-#define RTL_W32(reg, val32)	iowrite32 ((val32), ioaddr + (reg))
+#define RTL_W8(reg, val8)	iowrite8((val8), ioaddr + (reg))
+#define RTL_W16(reg, val16)	iowrite16((val16), ioaddr + (reg))
+#define RTL_W32(reg, val32)	iowrite32((val32), ioaddr + (reg))
 
 /* read MMIO register */
-#define RTL_R8(reg)		ioread8 (ioaddr + (reg))
-#define RTL_R16(reg)		ioread16 (ioaddr + (reg))
-#define RTL_R32(reg)		((unsigned long) ioread32 (ioaddr + (reg)))
+#define RTL_R8(reg)ioread8(ioaddr + (reg))
+#define RTL_R16(reg)ioread16(ioaddr + (reg))
+#define RTL_R32(reg)((unsigned long) ioread32(ioaddr + (reg)))
 
 
 static const u16 rtl8139_intr_mask =
@@ -700,44 +705,44 @@ static const unsigned int rtl8139_rx_config =
 static const unsigned int rtl8139_tx_config =
 	TxIFG96 | (TX_DMA_BURST << TxDMAShift) | (TX_RETRY << TxRetryShift);
 
-static void __rtl8139_cleanup_dev (struct net_device *dev)
+static void __rtl8139_cleanup_dev(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev;
 
-	assert (dev != NULL);
-	assert (tp->pci_dev != NULL);
+	assert(dev != NULL);
+	assert(tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
 	if (tp->mmio_addr)
-		pci_iounmap (pdev, tp->mmio_addr);
+		pci_iounmap(pdev, tp->mmio_addr);
 
 	/* it's ok to call this even if we have no regions to free */
-	pci_release_regions (pdev);
+	pci_release_regions(pdev);
 
 	free_netdev(dev);
-	pci_set_drvdata (pdev, NULL);
+	pci_set_drvdata(pdev, NULL);
 }
 
 
-static void rtl8139_chip_reset (void __iomem *ioaddr)
+static void rtl8139_chip_reset(void __iomem *ioaddr)
 {
 	int i;
 
 	/* Soft reset the chip. */
-	RTL_W8 (ChipCmd, CmdReset);
+	RTL_W8(ChipCmd, CmdReset);
 
 	/* Check that the chip has finished the reset. */
 	for (i = 1000; i > 0; i--) {
 		barrier();
-		if ((RTL_R8 (ChipCmd) & CmdReset) == 0)
+		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
 			break;
-		udelay (10);
+		udelay(10);
 	}
 }
 
 
-static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
+static __devinit struct net_device *rtl8139_init_board(struct pci_dev *pdev)
 {
 	void __iomem *ioaddr;
 	struct net_device *dev;
@@ -749,10 +754,10 @@ static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
 	u32 version;
 
-	assert (pdev != NULL);
+	assert(pdev != NULL);
 
 	/* dev and priv zeroed in alloc_etherdev */
-	dev = alloc_etherdev (sizeof (*tp));
+	dev = alloc_etherdev(sizeof(*tp));
 	if (dev == NULL) {
 		dev_err(&pdev->dev, "Unable to alloc new net device\n");
 		return ERR_PTR(-ENOMEM);
@@ -763,19 +768,19 @@ static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 	tp->pci_dev = pdev;
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
-	rc = pci_enable_device (pdev);
+	rc = pci_enable_device(pdev);
 	if (rc)
 		goto err_out;
 
-	pio_start = pci_resource_start (pdev, 0);
-	pio_end = pci_resource_end (pdev, 0);
-	pio_flags = pci_resource_flags (pdev, 0);
-	pio_len = pci_resource_len (pdev, 0);
+	pio_start = pci_resource_start(pdev, 0);
+	pio_end = pci_resource_end(pdev, 0);
+	pio_flags = pci_resource_flags(pdev, 0);
+	pio_len = pci_resource_len(pdev, 0);
 
-	mmio_start = pci_resource_start (pdev, 1);
-	mmio_end = pci_resource_end (pdev, 1);
-	mmio_flags = pci_resource_flags (pdev, 1);
-	mmio_len = pci_resource_len (pdev, 1);
+	mmio_start = pci_resource_start(pdev, 1);
+	mmio_end = pci_resource_end(pdev, 1);
+	mmio_flags = pci_resource_flags(pdev, 1);
+	mmio_len = pci_resource_len(pdev, 1);
 
 	/* set this immediately, we need to know before
 	 * we talk to the chip directly */
@@ -786,37 +791,41 @@ retry:
 	if (use_io) {
 		/* make sure PCI base addr 0 is PIO */
 		if (!(pio_flags & IORESOURCE_IO)) {
-			dev_err(&pdev->dev, "region #0 not a PIO resource, aborting\n");
+			dev_err(&pdev->dev, "region #0 not a "
+					"PIO resource, aborting\n");
 			rc = -ENODEV;
 			goto err_out;
 		}
 		/* check for weird/broken PCI region reporting */
 		if (pio_len < RTL_MIN_IO_SIZE) {
-			dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
+			dev_err(&pdev->dev, "Invalid PCI I/O "
+					"region size(s), aborting\n");
 			rc = -ENODEV;
 			goto err_out;
 		}
 	} else {
 		/* make sure PCI base addr 1 is MMIO */
 		if (!(mmio_flags & IORESOURCE_MEM)) {
-			dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
+			dev_err(&pdev->dev, "region #1 not an MMIO "
+						"resource, aborting\n");
 			rc = -ENODEV;
 			goto err_out;
 		}
 		if (mmio_len < RTL_MIN_IO_SIZE) {
-			dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
+			dev_err(&pdev->dev, "Invalid PCI mem region "
+						"size(s), aborting\n");
 			rc = -ENODEV;
 			goto err_out;
 		}
 	}
 
-	rc = pci_request_regions (pdev, DRV_NAME);
+	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc)
 		goto err_out;
 	disable_dev_on_err = 1;
 
 	/* enable PCI bus-mastering */
-	pci_set_master (pdev);
+	pci_set_master(pdev);
 
 	if (use_io) {
 		ioaddr = pci_iomap(pdev, 0, 0);
@@ -842,26 +851,27 @@ retry:
 	tp->mmio_addr = ioaddr;
 
 	/* Bring old chips out of low-power mode. */
-	RTL_W8 (HltClk, 'R');
+	RTL_W8(HltClk, 'R');
 
 	/* check for missing/broken hardware */
-	if (RTL_R32 (TxConfig) == 0xFFFFFFFF) {
+	if (RTL_R32(TxConfig) == 0xFFFFFFFF) {
 		dev_err(&pdev->dev, "Chip not responding, ignoring board\n");
 		rc = -EIO;
 		goto err_out;
 	}
 
 	/* identify chip attached to board */
-	version = RTL_R32 (TxConfig) & HW_REVID_MASK;
-	for (i = 0; i < ARRAY_SIZE (rtl_chip_info); i++)
+	version = RTL_R32(TxConfig) & HW_REVID_MASK;
+	for (i = 0; i < ARRAY_SIZE(rtl_chip_info); i++)
 		if (version == rtl_chip_info[i].version) {
 			tp->chipset = i;
 			goto match;
 		}
 
-	/* if unknown chip, assume array element #0, original RTL-8139 in this case */
+	/* if unknown chip, assume array element #0,
+				original RTL-8139 in this case */
 	dev_dbg(&pdev->dev, "unknown chip version, assuming RTL-8139\n");
-	dev_dbg(&pdev->dev, "TxConfig = 0x%lx\n", RTL_R32 (TxConfig));
+	dev_dbg(&pdev->dev, "TxConfig = 0x%lx\n", RTL_R32(TxConfig));
 	tp->chipset = 0;
 
 match:
@@ -869,40 +879,40 @@ match:
 		 version, i, rtl_chip_info[i].name);
 
 	if (tp->chipset >= CH_8139B) {
-		u8 new_tmp8 = tmp8 = RTL_R8 (Config1);
+		u8 new_tmp8 = tmp8 = RTL_R8(Config1);
 		pr_debug("PCI PM wakeup\n");
 		if ((rtl_chip_info[tp->chipset].flags & HasLWake) &&
 		    (tmp8 & LWAKE))
 			new_tmp8 &= ~LWAKE;
 		new_tmp8 |= Cfg1_PM_Enable;
 		if (new_tmp8 != tmp8) {
-			RTL_W8 (Cfg9346, Cfg9346_Unlock);
-			RTL_W8 (Config1, tmp8);
-			RTL_W8 (Cfg9346, Cfg9346_Lock);
+			RTL_W8(Cfg9346, Cfg9346_Unlock);
+			RTL_W8(Config1, tmp8);
+			RTL_W8(Cfg9346, Cfg9346_Lock);
 		}
 		if (rtl_chip_info[tp->chipset].flags & HasLWake) {
-			tmp8 = RTL_R8 (Config4);
+			tmp8 = RTL_R8(Config4);
 			if (tmp8 & LWPTN) {
-				RTL_W8 (Cfg9346, Cfg9346_Unlock);
-				RTL_W8 (Config4, tmp8 & ~LWPTN);
-				RTL_W8 (Cfg9346, Cfg9346_Lock);
+				RTL_W8(Cfg9346, Cfg9346_Unlock);
+				RTL_W8(Config4, tmp8 & ~LWPTN);
+				RTL_W8(Cfg9346, Cfg9346_Lock);
 			}
 		}
 	} else {
 		pr_debug("Old chip wakeup\n");
-		tmp8 = RTL_R8 (Config1);
+		tmp8 = RTL_R8(Config1);
 		tmp8 &= ~(SLEEP | PWRDN);
-		RTL_W8 (Config1, tmp8);
+		RTL_W8(Config1, tmp8);
 	}
 
-	rtl8139_chip_reset (ioaddr);
+	rtl8139_chip_reset(ioaddr);
 
 	return dev;
 
 err_out:
-	__rtl8139_cleanup_dev (dev);
+	__rtl8139_cleanup_dev(dev);
 	if (disable_dev_on_err)
-		pci_disable_device (pdev);
+		pci_disable_device(pdev);
 	return ERR_PTR(rc);
 }
 
@@ -912,17 +922,13 @@ static const struct net_device_ops rtl8139_netdev_ops = {
 	.ndo_get_stats		= rtl8139_get_stats,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= rtl8139_set_mac_address,
-	.ndo_start_xmit		= rtl8139_start_xmit,
-	.ndo_set_multicast_list	= rtl8139_set_rx_mode,
-	.ndo_do_ioctl		= netdev_ioctl,
-	.ndo_tx_timeout		= rtl8139_tx_timeout,
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= rtl8139_poll_controller,
 #endif
 };
 
-static int __devinit rtl8139_init_one (struct pci_dev *pdev,
+static int __devinit rtl8139_init_one(struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
 	struct net_device *dev = NULL;
@@ -931,8 +937,8 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	void __iomem *ioaddr;
 	static int board_idx = -1;
 
-	assert (pdev != NULL);
-	assert (ent != NULL);
+	assert(pdev != NULL);
+	assert(ent != NULL);
 
 	board_idx++;
 
@@ -948,10 +954,12 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 #endif
 
 	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
-	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 && pdev->revision >= 0x20) {
+	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 && "
+					"pdev->revision >= 0x20) {
 		dev_info(&pdev->dev,
-			   "This (id %04x:%04x rev %02x) is an enhanced 8139C+ chip, use 8139cp\n",
-		       	   pdev->vendor, pdev->device, pdev->revision);
+			   "This (id %04x:%04x rev %02x) is an "
+					"enhanced 8139C+ chip, use 8139cp\n",
+		pdev->vendor, pdev->device, pdev->revision);
 		return -ENODEV;
 	}
 
@@ -963,21 +971,21 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 		use_io = 1;
 	}
 
-	dev = rtl8139_init_board (pdev);
+	dev = rtl8139_init_board(pdev);
 	if (IS_ERR(dev))
 		return PTR_ERR(dev);
 
-	assert (dev != NULL);
+	assert(dev != NULL);
 	tp = netdev_priv(dev);
 	tp->dev = dev;
 
 	ioaddr = tp->mmio_addr;
-	assert (ioaddr != NULL);
+	assert(ioaddr != NULL);
 
-	addr_len = read_eeprom (ioaddr, 0, 8) == 0x8129 ? 8 : 6;
+	addr_len = read_eeprom(ioaddr, 0, 8) == 0x8129 ? 8 : 6;
 	for (i = 0; i < 3; i++)
 		((__le16 *) (dev->dev_addr))[i] =
-		    cpu_to_le16(read_eeprom (ioaddr, i + 7, addr_len));
+		    cpu_to_le16(read_eeprom(ioaddr, i + 7, addr_len));
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	/* The Rtl8139-specific entries in the device structure. */
@@ -1002,8 +1010,8 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	tp->mmio_addr = ioaddr;
 	tp->msg_enable =
 		(debug < 0 ? RTL8139_DEF_MSG_ENABLE : ((1 << debug) - 1));
-	spin_lock_init (&tp->lock);
-	spin_lock_init (&tp->rx_lock);
+	spin_lock_init(&tp->lock);
+	spin_lock_init(&tp->rx_lock);
 	INIT_DELAYED_WORK(&tp->thread, rtl8139_thread);
 	tp->mii.dev = dev;
 	tp->mii.mdio_read = mdio_read;
@@ -1014,10 +1022,11 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	/* dev is fully set up and ready to use now */
 	pr_debug("about to register device named %s (%p)...\n",
 		 dev->name, dev);
-	i = register_netdev (dev);
-	if (i) goto err_out;
+	i = register_netdev(dev);
+	if (i)
+		goto err_out;
 
-	pci_set_drvdata (pdev, dev);
+	pci_set_drvdata(pdev, dev);
 
 	netdev_info(dev, "%s at 0x%lx, %pM, IRQ %d\n",
 		    board_info[ent->driver_data].name,
@@ -1037,12 +1046,14 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 			if (mii_status != 0xffff  &&  mii_status != 0x0000) {
 				u16 advertising = mdio_read(dev, phy, 4);
 				tp->phys[phy_idx++] = phy;
-				netdev_info(dev, "MII transceiver %d status 0x%04x advertising %04x\n",
+				netdev_info(dev, "MII transceiver %d "
+					"status 0x%04x advertising %04x\n",
 					    phy, mii_status, advertising);
 			}
 		}
 		if (phy_idx == 0) {
-			netdev_info(dev, "No MII transceivers found! Assuming SYM transceiver\n");
+			netdev_info(dev, "No MII transceivers found! "
+						"Assuming SYM transceiver\n");
 			tp->phys[0] = 32;
 		}
 	} else
@@ -1071,35 +1082,36 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 			    (option & 0x20 ? 100 : 10),
 			    (option & 0x10 ? "full" : "half"));
 		mdio_write(dev, tp->phys[0], 0,
-				   ((option & 0x20) ? 0x2000 : 0) | 	/* 100Mbps? */
-				   ((option & 0x10) ? 0x0100 : 0)); /* Full duplex? */
+			((option & 0x20) ? 0x2000 : 0) |	/* 100Mbps? */
+				   ((option & 0x10) ? 0x0100 : 0));
+							/* Full duplex? */
 	}
 
 	/* Put the chip into low-power mode. */
 	if (rtl_chip_info[tp->chipset].flags & HasHltClk)
-		RTL_W8 (HltClk, 'H');	/* 'R' would leave the clock running. */
+		RTL_W8(HltClk, 'H');	/* 'R' would leave the clock running. */
 
 	return 0;
 
 err_out:
-	__rtl8139_cleanup_dev (dev);
-	pci_disable_device (pdev);
+	__rtl8139_cleanup_dev(dev);
+	pci_disable_device(pdev);
 	return i;
 }
 
 
-static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
+static void __devexit rtl8139_remove_one(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 
-	assert (dev != NULL);
+	assert(dev != NULL);
 
 	flush_scheduled_work();
 
-	unregister_netdev (dev);
+	unregister_netdev(dev);
 
-	__rtl8139_cleanup_dev (dev);
-	pci_disable_device (pdev);
+	__rtl8139_cleanup_dev(dev);
+	pci_disable_device(pdev);
 }
 
 
@@ -1125,40 +1137,41 @@ static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
 #define EE_READ_CMD		(6)
 #define EE_ERASE_CMD	(7)
 
-static int __devinit read_eeprom (void __iomem *ioaddr, int location, int addr_len)
+static int __devinit read_eeprom(void __iomem *ioaddr,
+					int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
 	int read_cmd = location | (EE_READ_CMD << addr_len);
 
-	RTL_W8 (Cfg9346, EE_ENB & ~EE_CS);
-	RTL_W8 (Cfg9346, EE_ENB);
-	eeprom_delay ();
+	RTL_W8(Cfg9346, EE_ENB & ~EE_CS);
+	RTL_W8(Cfg9346, EE_ENB);
+	eeprom_delay();
 
 	/* Shift the read command bits out. */
 	for (i = 4 + addr_len; i >= 0; i--) {
 		int dataval = (read_cmd & (1 << i)) ? EE_DATA_WRITE : 0;
-		RTL_W8 (Cfg9346, EE_ENB | dataval);
-		eeprom_delay ();
-		RTL_W8 (Cfg9346, EE_ENB | dataval | EE_SHIFT_CLK);
-		eeprom_delay ();
+		RTL_W8(Cfg9346, EE_ENB | dataval);
+		eeprom_delay();
+		RTL_W8(Cfg9346, EE_ENB | dataval | EE_SHIFT_CLK);
+		eeprom_delay();
 	}
-	RTL_W8 (Cfg9346, EE_ENB);
-	eeprom_delay ();
+	RTL_W8(Cfg9346, EE_ENB);
+	eeprom_delay();
 
 	for (i = 16; i > 0; i--) {
-		RTL_W8 (Cfg9346, EE_ENB | EE_SHIFT_CLK);
-		eeprom_delay ();
+		RTL_W8(Cfg9346, EE_ENB | EE_SHIFT_CLK);
+		eeprom_delay();
 		retval =
-		    (retval << 1) | ((RTL_R8 (Cfg9346) & EE_DATA_READ) ? 1 :
+		    (retval << 1) | ((RTL_R8(Cfg9346) & EE_DATA_READ) ? 1 :
 				     0);
-		RTL_W8 (Cfg9346, EE_ENB);
-		eeprom_delay ();
+		RTL_W8(Cfg9346, EE_ENB);
+		eeprom_delay();
 	}
 
 	/* Terminate the EEPROM access. */
-	RTL_W8 (Cfg9346, ~EE_CS);
-	eeprom_delay ();
+	RTL_W8(Cfg9346, ~EE_CS);
+	eeprom_delay();
 
 	return retval;
 }
@@ -1193,20 +1206,20 @@ static const char mii_2_8139_map[8] = {
 
 #ifdef CONFIG_8139TOO_8129
 /* Syncronize the MII management interface by shifting 32 one bits out. */
-static void mdio_sync (void __iomem *ioaddr)
+static void mdio_sync(void __iomem *ioaddr)
 {
 	int i;
 
 	for (i = 32; i >= 0; i--) {
-		RTL_W8 (Config4, MDIO_WRITE1);
-		mdio_delay ();
-		RTL_W8 (Config4, MDIO_WRITE1 | MDIO_CLK);
-		mdio_delay ();
+		RTL_W8(Config4, MDIO_WRITE1);
+		mdio_delay();
+		RTL_W8(Config4, MDIO_WRITE1 | MDIO_CLK);
+		mdio_delay();
 	}
 }
 #endif
 
-static int mdio_read (struct net_device *dev, int phy_id, int location)
+static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval = 0;
@@ -1219,28 +1232,29 @@ static int mdio_read (struct net_device *dev, int phy_id, int location)
 	if (phy_id > 31) {	/* Really a 8139.  Use internal registers. */
 		void __iomem *ioaddr = tp->mmio_addr;
 		return location < 8 && mii_2_8139_map[location] ?
-		    RTL_R16 (mii_2_8139_map[location]) : 0;
+		    RTL_R16(mii_2_8139_map[location]) : 0;
 	}
 
 #ifdef CONFIG_8139TOO_8129
-	mdio_sync (ioaddr);
+	mdio_sync(ioaddr);
 	/* Shift the read command bits out. */
 	for (i = 15; i >= 0; i--) {
 		int dataval = (mii_cmd & (1 << i)) ? MDIO_DATA_OUT : 0;
 
-		RTL_W8 (Config4, MDIO_DIR | dataval);
-		mdio_delay ();
-		RTL_W8 (Config4, MDIO_DIR | dataval | MDIO_CLK);
-		mdio_delay ();
+		RTL_W8(Config4, MDIO_DIR | dataval);
+		mdio_delay();
+		RTL_W8(Config4, MDIO_DIR | dataval | MDIO_CLK);
+		mdio_delay();
 	}
 
 	/* Read the two transition, 16 data, and wire-idle bits. */
 	for (i = 19; i > 0; i--) {
-		RTL_W8 (Config4, 0);
-		mdio_delay ();
-		retval = (retval << 1) | ((RTL_R8 (Config4) & MDIO_DATA_IN) ? 1 : 0);
-		RTL_W8 (Config4, MDIO_CLK);
-		mdio_delay ();
+		RTL_W8(Config4, 0);
+		mdio_delay();
+		retval = (retval << 1) | ((RTL_R8(Config4) & MDIO_DATA_IN) ? "
+									"1 : 0);
+		RTL_W8(Config4, MDIO_CLK);
+		mdio_delay();
 	}
 #endif
 
@@ -1248,57 +1262,59 @@ static int mdio_read (struct net_device *dev, int phy_id, int location)
 }
 
 
-static void mdio_write (struct net_device *dev, int phy_id, int location,
+static void mdio_write(struct net_device *dev, int phy_id, int location,
 			int value)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 #ifdef CONFIG_8139TOO_8129
 	void __iomem *ioaddr = tp->mmio_addr;
-	int mii_cmd = (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
+	int mii_cmd = (0x5002 << 16) | (phy_id << 23) | (location << 18) |
+	value;
 	int i;
 #endif
 
 	if (phy_id > 31) {	/* Really a 8139.  Use internal registers. */
 		void __iomem *ioaddr = tp->mmio_addr;
 		if (location == 0) {
-			RTL_W8 (Cfg9346, Cfg9346_Unlock);
-			RTL_W16 (BasicModeCtrl, value);
-			RTL_W8 (Cfg9346, Cfg9346_Lock);
+			RTL_W8(Cfg9346, Cfg9346_Unlock);
+			RTL_W16(BasicModeCtrl, value);
+			RTL_W8(Cfg9346, Cfg9346_Lock);
 		} else if (location < 8 && mii_2_8139_map[location])
-			RTL_W16 (mii_2_8139_map[location], value);
+			RTL_W16(mii_2_8139_map[location], value);
 		return;
 	}
 
 #ifdef CONFIG_8139TOO_8129
-	mdio_sync (ioaddr);
+	mdio_sync(ioaddr);
 
 	/* Shift the command bits out. */
 	for (i = 31; i >= 0; i--) {
 		int dataval =
 		    (mii_cmd & (1 << i)) ? MDIO_WRITE1 : MDIO_WRITE0;
-		RTL_W8 (Config4, dataval);
-		mdio_delay ();
-		RTL_W8 (Config4, dataval | MDIO_CLK);
-		mdio_delay ();
+		RTL_W8(Config4, dataval);
+		mdio_delay();
+		RTL_W8(Config4, dataval | MDIO_CLK);
+		mdio_delay();
 	}
 	/* Clear out extra bits. */
 	for (i = 2; i > 0; i--) {
-		RTL_W8 (Config4, 0);
-		mdio_delay ();
-		RTL_W8 (Config4, MDIO_CLK);
-		mdio_delay ();
+		RTL_W8(Config4, 0);
+		mdio_delay();
+		RTL_W8(Config4, MDIO_CLK);
+		mdio_delay();
 	}
 #endif
 }
 
 
-static int rtl8139_open (struct net_device *dev)
+static int rtl8139_open(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval;
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	retval = request_irq (dev->irq, rtl8139_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(dev->irq, rtl8139_interrupt,
+	IRQF_SHARED, dev->name, dev);
 	if (retval)
 		return retval;
 
@@ -1325,15 +1341,15 @@ static int rtl8139_open (struct net_device *dev)
 	tp->mii.full_duplex = tp->mii.force_media;
 	tp->tx_flag = (TX_FIFO_THRESH << 11) & 0x003f0000;
 
-	rtl8139_init_ring (dev);
-	rtl8139_hw_start (dev);
-	netif_start_queue (dev);
+	rtl8139_init_ring(dev);
+	rtl8139_hw_start(dev);
+	netif_start_queue(dev);
 
 	netif_dbg(tp, ifup, dev,
 		  "%s() ioaddr %#llx IRQ %d GP Pins %02x %s-duplex\n",
 		  __func__,
-		  (unsigned long long)pci_resource_start (tp->pci_dev, 1),
-		  dev->irq, RTL_R8 (MediaStatus),
+		  (unsigned long long)pci_resource_start(tp->pci_dev, 1),
+		  dev->irq, RTL_R8(MediaStatus),
 		  tp->mii.full_duplex ? "full" : "half");
 
 	rtl8139_start_thread(tp);
@@ -1342,17 +1358,16 @@ static int rtl8139_open (struct net_device *dev)
 }
 
 
-static void rtl_check_media (struct net_device *dev, unsigned int init_media)
+static void rtl_check_media(struct net_device *dev, unsigned int init_media)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 
-	if (tp->phys[0] >= 0) {
+	if (tp->phys[0] >= 0)
 		mii_check_media(&tp->mii, netif_msg_link(tp), init_media);
-	}
 }
 
 /* Start the hardware at open or resume. */
-static void rtl8139_hw_start (struct net_device *dev)
+static void rtl8139_hw_start(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1361,65 +1376,66 @@ static void rtl8139_hw_start (struct net_device *dev)
 
 	/* Bring old chips out of low-power mode. */
 	if (rtl_chip_info[tp->chipset].flags & HasHltClk)
-		RTL_W8 (HltClk, 'R');
+		RTL_W8(HltClk, 'R');
 
-	rtl8139_chip_reset (ioaddr);
+	rtl8139_chip_reset(ioaddr);
 
 	/* unlock Config[01234] and BMCR register writes */
-	RTL_W8_F (Cfg9346, Cfg9346_Unlock);
+	RTL_W8_F(Cfg9346, Cfg9346_Unlock);
 	/* Restore our idea of the MAC address. */
-	RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
-	RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)));
+	RTL_W32_F(MAC0 + 0, le32_to_cpu(*(__le32 *) (dev->dev_addr + 0)));
+	RTL_W32_F(MAC0 + 4, le16_to_cpu(*(__le16 *) (dev->dev_addr + 4)));
 
 	tp->cur_rx = 0;
 
 	/* init Rx ring buffer DMA address */
-	RTL_W32_F (RxBuf, tp->rx_ring_dma);
+	RTL_W32_F(RxBuf, tp->rx_ring_dma);
 
 	/* Must enable Tx/Rx before setting transfer thresholds! */
-	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
+	RTL_W8(ChipCmd, CmdRxEnb | CmdTxEnb);
 
 	tp->rx_config = rtl8139_rx_config | AcceptBroadcast | AcceptMyPhys;
-	RTL_W32 (RxConfig, tp->rx_config);
-	RTL_W32 (TxConfig, rtl8139_tx_config);
+	RTL_W32(RxConfig, tp->rx_config);
+	RTL_W32(TxConfig, rtl8139_tx_config);
 
-	rtl_check_media (dev, 1);
+	rtl_check_media(dev, 1);
 
 	if (tp->chipset >= CH_8139B) {
 		/* Disable magic packet scanning, which is enabled
 		 * when PM is enabled in Config1.  It can be reenabled
 		 * via ETHTOOL_SWOL if desired.  */
-		RTL_W8 (Config3, RTL_R8 (Config3) & ~Cfg3_Magic);
+		RTL_W8(Config3, RTL_R8(Config3) & ~Cfg3_Magic);
 	}
 
 	netdev_dbg(dev, "init buffer addresses\n");
 
 	/* Lock Config[01234] and BMCR register writes */
-	RTL_W8 (Cfg9346, Cfg9346_Lock);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	/* init Tx buffer DMA addresses */
 	for (i = 0; i < NUM_TX_DESC; i++)
-		RTL_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs));
+		RTL_W32_F(TxAddr0 + (i * 4),
+		 tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs));
 
-	RTL_W32 (RxMissed, 0);
+	RTL_W32(RxMissed, 0);
 
-	rtl8139_set_rx_mode (dev);
+	rtl8139_set_rx_mode(dev);
 
 	/* no early-rx interrupts */
-	RTL_W16 (MultiIntr, RTL_R16 (MultiIntr) & MultiIntrClear);
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & MultiIntrClear);
 
 	/* make sure RxTx has started */
-	tmp = RTL_R8 (ChipCmd);
+	tmp = RTL_R8(ChipCmd);
 	if ((!(tmp & CmdRxEnb)) || (!(tmp & CmdTxEnb)))
-		RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
+		RTL_W8(ChipCmd, CmdRxEnb | CmdTxEnb);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16 (IntrMask, rtl8139_intr_mask);
+	RTL_W16(IntrMask, rtl8139_intr_mask);
 }
 
 
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
-static void rtl8139_init_ring (struct net_device *dev)
+static void rtl8139_init_ring(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	int i;
@@ -1437,7 +1453,7 @@ static void rtl8139_init_ring (struct net_device *dev)
 static int next_tick = 3 * HZ;
 
 #ifndef CONFIG_8139TOO_TUNE_TWISTER
-static inline void rtl8139_tune_twister (struct net_device *dev,
+static inline void rtl8139_tune_twister(struct net_device *dev,
 				  struct rtl8139_private *tp) {}
 #else
 enum TwisterParamVals {
@@ -1453,7 +1469,7 @@ static const unsigned long param[4][4] = {
 	{0xbb39de43, 0xbb39ce43, 0xbb39ce83, 0xbb39ce83}
 };
 
-static void rtl8139_tune_twister (struct net_device *dev,
+static void rtl8139_tune_twister(struct net_device *dev,
 				  struct rtl8139_private *tp)
 {
 	int linkcase;
@@ -1465,23 +1481,24 @@ static void rtl8139_tune_twister (struct net_device *dev,
 	 */
 	switch (tp->twistie) {
 	case 1:
-		if (RTL_R16 (CSCR) & CSCR_LinkOKBit) {
+		if (RTL_R16(CSCR) & CSCR_LinkOKBit) {
 			/* We have link beat, let us tune the twister. */
-			RTL_W16 (CSCR, CSCR_LinkDownOffCmd);
+			RTL_W16(CSCR, CSCR_LinkDownOffCmd);
 			tp->twistie = 2;	/* Change to state 2. */
 			next_tick = HZ / 10;
 		} else {
-			/* Just put in some reasonable defaults for when beat returns. */
-			RTL_W16 (CSCR, CSCR_LinkDownCmd);
-			RTL_W32 (FIFOTMS, 0x20);	/* Turn on cable test mode. */
-			RTL_W32 (PARA78, PARA78_default);
-			RTL_W32 (PARA7c, PARA7c_default);
+			/* Just put in some reasonable defaults for*/
+			/* when beat returns. */
+			RTL_W16(CSCR, CSCR_LinkDownCmd);
+			RTL_W32(FIFOTMS, 0x20);	/* Turn on cable test mode. */
+			RTL_W32(PARA78, PARA78_default);
+			RTL_W32(PARA7c, PARA7c_default);
 			tp->twistie = 0;	/* Bail from future actions. */
 		}
 		break;
 	case 2:
 		/* Read how long it took to hear the echo. */
-		linkcase = RTL_R16 (CSCR) & CSCR_LinkStatusBits;
+		linkcase = RTL_R16(CSCR) & CSCR_LinkStatusBits;
 		if (linkcase == 0x7000)
 			tp->twist_row = 3;
 		else if (linkcase == 0x3000)
@@ -1497,8 +1514,8 @@ static void rtl8139_tune_twister (struct net_device *dev,
 	case 3:
 		/* Put out four tuning parameters, one per 100msec. */
 		if (tp->twist_col == 0)
-			RTL_W16 (FIFOTMS, 0);
-		RTL_W32 (PARA7c, param[(int) tp->twist_row]
+			RTL_W16(FIFOTMS, 0);
+		RTL_W32(PARA7c, param[(int) tp->twist_row]
 			 [(int) tp->twist_col]);
 		next_tick = HZ / 10;
 		if (++tp->twist_col >= 4) {
@@ -1510,22 +1527,22 @@ static void rtl8139_tune_twister (struct net_device *dev,
 		break;
 	case 4:
 		/* Special case for long cables: check for mistune. */
-		if ((RTL_R16 (CSCR) &
+		if ((RTL_R16(CSCR) &
 		     CSCR_LinkStatusBits) == 0x7000) {
 			tp->twistie = 0;
 			break;
 		} else {
-			RTL_W32 (PARA7c, 0xfb38de03);
+			RTL_W32(PARA7c, 0xfb38de03);
 			tp->twistie = 5;
 			next_tick = HZ / 10;
 		}
 		break;
 	case 5:
 		/* Retune for shorter cable (column 2). */
-		RTL_W32 (FIFOTMS, 0x20);
-		RTL_W32 (PARA78, PARA78_default);
-		RTL_W32 (PARA7c, PARA7c_default);
-		RTL_W32 (FIFOTMS, 0x00);
+		RTL_W32(FIFOTMS, 0x20);
+		RTL_W32(PARA78, PARA78_default);
+		RTL_W32(PARA7c, PARA7c_default);
+		RTL_W32(FIFOTMS, 0x00);
 		tp->twist_row = 2;
 		tp->twist_col = 0;
 		tp->twistie = 3;
@@ -1539,13 +1556,13 @@ static void rtl8139_tune_twister (struct net_device *dev,
 }
 #endif /* CONFIG_8139TOO_TUNE_TWISTER */
 
-static inline void rtl8139_thread_iter (struct net_device *dev,
+static inline void rtl8139_thread_iter(struct net_device *dev,
 				 struct rtl8139_private *tp,
 				 void __iomem *ioaddr)
 {
 	int mii_lpa;
 
-	mii_lpa = mdio_read (dev, tp->phys[0], MII_LPA);
+	mii_lpa = mdio_read(dev, tp->phys[0], MII_LPA);
 
 	if (!tp->mii.force_media && mii_lpa != 0xffff) {
 		int duplex = ((mii_lpa & LPA_100FULL) ||
@@ -1554,23 +1571,27 @@ static inline void rtl8139_thread_iter (struct net_device *dev,
 			tp->mii.full_duplex = duplex;
 
 			if (mii_lpa) {
-				netdev_info(dev, "Setting %s-duplex based on MII #%d link partner ability of %04x\n",
-					    tp->mii.full_duplex ? "full" : "half",
+				netdev_info(dev, "Setting %s-duplex based "
+				"on MII #%d link partner ability of %04x\n",
+					    tp->mii.full_duplex ? "full""
+							" : "half",
 					    tp->phys[0], mii_lpa);
 			} else {
-				netdev_info(dev, "media is unconnected, link down, or incompatible connection\n");
+				netdev_info(dev, "media is unconnected, "
+					"link down, or incompatible "
+							"connection\n");
 			}
 #if 0
-			RTL_W8 (Cfg9346, Cfg9346_Unlock);
-			RTL_W8 (Config1, tp->mii.full_duplex ? 0x60 : 0x20);
-			RTL_W8 (Cfg9346, Cfg9346_Lock);
+			RTL_W8(Cfg9346, Cfg9346_Unlock);
+			RTL_W8(Config1, tp->mii.full_duplex ? 0x60 : 0x20);
+			RTL_W8(Cfg9346, Cfg9346_Lock);
 #endif
 		}
 	}
 
 	next_tick = HZ * 60;
 
-	rtl8139_tune_twister (dev, tp);
+	rtl8139_tune_twister(dev, tp);
 
 	netdev_dbg(dev, "Media selection tick, Link partner %04x\n",
 		   RTL_R16(NWayLPAR));
@@ -1580,7 +1601,7 @@ static inline void rtl8139_thread_iter (struct net_device *dev,
 		   RTL_R8(Config0), RTL_R8(Config1));
 }
 
-static void rtl8139_thread (struct work_struct *work)
+static void rtl8139_thread(struct work_struct *work)
 {
 	struct rtl8139_private *tp =
 		container_of(work, struct rtl8139_private, thread.work);
@@ -1601,7 +1622,7 @@ static void rtl8139_thread (struct work_struct *work)
 	if (tp->have_thread)
 		schedule_delayed_work(&tp->thread, thr_delay);
 out_unlock:
-	rtnl_unlock ();
+	rtnl_unlock();
 }
 
 static void rtl8139_start_thread(struct rtl8139_private *tp)
@@ -1618,7 +1639,7 @@ static void rtl8139_start_thread(struct rtl8139_private *tp)
 	schedule_delayed_work(&tp->thread, next_tick);
 }
 
-static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
+static inline void rtl8139_tx_clear(struct rtl8139_private *tp)
 {
 	tp->cur_tx = 0;
 	tp->dirty_tx = 0;
@@ -1626,7 +1647,7 @@ static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
 	/* XXX account for unsent Tx packets in tp->stats.tx_dropped */
 }
 
-static void rtl8139_tx_timeout_task (struct work_struct *work)
+static void rtl8139_tx_timeout_task(struct work_struct *work)
 {
 	struct rtl8139_private *tp =
 		container_of(work, struct rtl8139_private, thread.work);
@@ -1650,28 +1671,28 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
 	tp->xstats.tx_timeouts++;
 
 	/* disable Tx ASAP, if not already */
-	tmp8 = RTL_R8 (ChipCmd);
+	tmp8 = RTL_R8(ChipCmd);
 	if (tmp8 & CmdTxEnb)
-		RTL_W8 (ChipCmd, CmdRxEnb);
+		RTL_W8(ChipCmd, CmdRxEnb);
 
 	spin_lock_bh(&tp->rx_lock);
 	/* Disable interrupts by clearing the interrupt mask. */
-	RTL_W16 (IntrMask, 0x0000);
+	RTL_W16(IntrMask, 0x0000);
 
 	/* Stop a shared interrupt from scavenging while we are. */
 	spin_lock_irq(&tp->lock);
-	rtl8139_tx_clear (tp);
+	rtl8139_tx_clear(tp);
 	spin_unlock_irq(&tp->lock);
 
 	/* ...and finally, reset everything */
 	if (netif_running(dev)) {
-		rtl8139_hw_start (dev);
-		netif_wake_queue (dev);
+		rtl8139_hw_start(dev);
+		netif_wake_queue(dev);
 	}
 	spin_unlock_bh(&tp->rx_lock);
 }
 
-static void rtl8139_tx_timeout (struct net_device *dev)
+static void rtl8139_tx_timeout(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 
@@ -1682,7 +1703,7 @@ static void rtl8139_tx_timeout (struct net_device *dev)
 	}
 }
 
-static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
+static netdev_tx_t rtl8139_start_xmit(struct sk_buff *skb,
 					     struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
@@ -1713,7 +1734,7 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 	 * to make sure that the device sees the updated data.
 	 */
 	wmb();
-	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
+	RTL_W32_F(TxStatus0 + (entry * sizeof(u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
 
 	dev->trans_start = jiffies;
@@ -1721,7 +1742,7 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 	tp->cur_tx++;
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
-		netif_stop_queue (dev);
+		netif_stop_queue(dev);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	netif_dbg(tp, tx_queued, dev, "Queued Tx packet size %u to slot %d\n",
@@ -1731,14 +1752,14 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 }
 
 
-static void rtl8139_tx_interrupt (struct net_device *dev,
+static void rtl8139_tx_interrupt(struct net_device *dev,
 				  struct rtl8139_private *tp,
 				  void __iomem *ioaddr)
 {
 	unsigned long dirty_tx, tx_left;
 
-	assert (dev != NULL);
-	assert (ioaddr != NULL);
+	assert(dev != NULL);
+	assert(ioaddr != NULL);
 
 	dirty_tx = tp->dirty_tx;
 	tx_left = tp->cur_tx - dirty_tx;
@@ -1746,7 +1767,7 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 		int entry = dirty_tx % NUM_TX_DESC;
 		int txstatus;
 
-		txstatus = RTL_R32 (TxStatus0 + (entry * sizeof (u32)));
+		txstatus = RTL_R32(TxStatus0 + (entry * sizeof(u32)));
 
 		if (!(txstatus & (TxStatOK | TxUnderrun | TxAborted)))
 			break;	/* It still hasn't been Txed */
@@ -1754,13 +1775,14 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 		/* Note: TxCarrierLost is always asserted at 100mbps. */
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
-			netif_dbg(tp, tx_err, dev, "Transmit error, Tx status %08x\n",
+			netif_dbg(tp, tx_err, dev, "Transmit error, "
+							"Tx status %08x\n",
 				  txstatus);
 			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
 				dev->stats.tx_aborted_errors++;
-				RTL_W32 (TxConfig, TxClearAbt);
-				RTL_W16 (IntrStatus, TxErr);
+				RTL_W32(TxConfig, TxClearAbt);
+				RTL_W16(IntrStatus, TxErr);
 				wmb();
 			}
 			if (txstatus & TxCarrierLost)
@@ -1795,13 +1817,13 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		mb();
-		netif_wake_queue (dev);
+		netif_wake_queue(dev);
 	}
 }
 
 
 /* TODO: clean this up!  Rx reset need not be this intensive */
-static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
+static void rtl8139_rx_err(u32 rx_status, struct net_device *dev,
 			    struct rtl8139_private *tp, void __iomem *ioaddr)
 {
 	u8 tmp8;
@@ -1814,7 +1836,8 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	dev->stats.rx_errors++;
 	if (!(rx_status & RxStatusOK)) {
 		if (rx_status & RxTooLong) {
-			netdev_dbg(dev, "Oversized Ethernet frame, status %04x!\n",
+			netdev_dbg(dev, "Oversized Ethernet frame, "
+							"status %04x!\n",
 				   rx_status);
 			/* A.C.: The chip hangs here. */
 		}
@@ -1829,20 +1852,20 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	}
 
 #ifndef CONFIG_8139_OLD_RX_RESET
-	tmp8 = RTL_R8 (ChipCmd);
-	RTL_W8 (ChipCmd, tmp8 & ~CmdRxEnb);
-	RTL_W8 (ChipCmd, tmp8);
-	RTL_W32 (RxConfig, tp->rx_config);
+	tmp8 = RTL_R8(ChipCmd);
+	RTL_W8(ChipCmd, tmp8 & ~CmdRxEnb);
+	RTL_W8(ChipCmd, tmp8);
+	RTL_W32(RxConfig, tp->rx_config);
 	tp->cur_rx = 0;
 #else
 	/* Reset the receiver, based on RealTek recommendation. (Bug?) */
 
 	/* disable receive */
-	RTL_W8_F (ChipCmd, CmdTxEnb);
+	RTL_W8_F(ChipCmd, CmdTxEnb);
 	tmp_work = 200;
 	while (--tmp_work > 0) {
 		udelay(1);
-		tmp8 = RTL_R8 (ChipCmd);
+		tmp8 = RTL_R8(ChipCmd);
 		if (!(tmp8 & CmdRxEnb))
 			break;
 	}
@@ -1851,9 +1874,9 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	/* restart receive */
 	tmp_work = 200;
 	while (--tmp_work > 0) {
-		RTL_W8_F (ChipCmd, CmdRxEnb | CmdTxEnb);
+		RTL_W8_F(ChipCmd, CmdRxEnb | CmdTxEnb);
 		udelay(1);
-		tmp8 = RTL_R8 (ChipCmd);
+		tmp8 = RTL_R8(ChipCmd);
 		if ((tmp8 & CmdRxEnb) && (tmp8 & CmdTxEnb))
 			break;
 	}
@@ -1861,24 +1884,24 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 		netdev_warn(dev, "tx/rx enable wait too long\n");
 
 	/* and reinitialize all rx related registers */
-	RTL_W8_F (Cfg9346, Cfg9346_Unlock);
+	RTL_W8_F(Cfg9346, Cfg9346_Unlock);
 	/* Must enable Tx/Rx before setting transfer thresholds! */
-	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
+	RTL_W8(ChipCmd, CmdRxEnb | CmdTxEnb);
 
 	tp->rx_config = rtl8139_rx_config | AcceptBroadcast | AcceptMyPhys;
-	RTL_W32 (RxConfig, tp->rx_config);
+	RTL_W32(RxConfig, tp->rx_config);
 	tp->cur_rx = 0;
 
 	netdev_dbg(dev, "init buffer addresses\n");
 
 	/* Lock Config[01234] and BMCR register writes */
-	RTL_W8 (Cfg9346, Cfg9346_Lock);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	/* init Rx ring buffer DMA address */
-	RTL_W32_F (RxBuf, tp->rx_ring_dma);
+	RTL_W32_F(RxBuf, tp->rx_ring_dma);
 
 	/* A.C.: Reset the multicast list. */
-	__set_rx_mode (dev);
+	__set_rx_mode(dev);
 #endif
 }
 
@@ -1901,7 +1924,7 @@ static void rtl8139_isr_ack(struct rtl8139_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 	u16 status;
 
-	status = RTL_R16 (IntrStatus) & RxAckBits;
+	status = RTL_R16(IntrStatus) & RxAckBits;
 
 	/* Clear out errors and receive interrupts */
 	if (likely(status != 0)) {
@@ -1910,7 +1933,7 @@ static void rtl8139_isr_ack(struct rtl8139_private *tp)
 			if (status & RxFIFOOver)
 				tp->dev->stats.rx_fifo_errors++;
 		}
-		RTL_W16_F (IntrStatus, RxAckBits);
+		RTL_W16_F(IntrStatus, RxAckBits);
 	}
 }
 
@@ -1923,12 +1946,13 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 	unsigned int cur_rx = tp->cur_rx;
 	unsigned int rx_size = 0;
 
-	netdev_dbg(dev, "In %s(), current %04x BufAddr %04x, free to %04x, Cmd %02x\n",
+	netdev_dbg(dev, "In %s(), current %04x BufAddr %04x, free to %04x, "
+								"Cmd %02x\n",
 		   __func__, (u16)cur_rx,
 		   RTL_R16(RxBufAddr), RTL_R16(RxBufPtr), RTL_R8(ChipCmd));
 
 	while (netif_running(dev) && received < budget &&
-	       (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
+	       (RTL_R8(ChipCmd) & RxBufEmpty) == 0) {
 		u32 ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
 		unsigned int pkt_size;
@@ -1937,11 +1961,12 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		rmb();
 
 		/* read size+status of next frame from DMA ring buffer */
-		rx_status = le32_to_cpu (*(__le32 *) (rx_ring + ring_offset));
+		rx_status = le32_to_cpu(*(__le32 *) (rx_ring + ring_offset));
 		rx_size = rx_status >> 16;
 		pkt_size = rx_size - 4;
 
-		netif_dbg(tp, rx_status, dev, "%s() status %04x, size %04x, cur %04x\n",
+		netif_dbg(tp, rx_status, dev, "%s() status %04x, size %04x, "
+								"cur %04x\n",
 			  __func__, rx_status, rx_size, cur_rx);
 #if RTL8139_DEBUG > 2
 		print_dump_hex(KERN_DEBUG, "Frame contents: ",
@@ -1977,7 +2002,7 @@ no_early_rx:
 		if (unlikely((rx_size > (MAX_ETH_FRAME_SIZE+4)) ||
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
-			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
+			rtl8139_rx_err(rx_status, dev, tp, ioaddr);
 			received = -1;
 			goto out;
 		}
@@ -1990,25 +2015,27 @@ no_early_rx:
 #if RX_BUF_IDX == 3
 			wrap_copy(skb, rx_ring, ring_offset+4, pkt_size);
 #else
-			skb_copy_to_linear_data (skb, &rx_ring[ring_offset + 4], pkt_size);
+			skb_copy_to_linear_data(skb, &rx_ring[ring_offset + 4],
+								 pkt_size);
 #endif
-			skb_put (skb, pkt_size);
+			skb_put(skb, pkt_size);
 
-			skb->protocol = eth_type_trans (skb, dev);
+			skb->protocol = eth_type_trans(skb, dev);
 
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
 
-			netif_receive_skb (skb);
+			netif_receive_skb(skb);
 		} else {
 			if (net_ratelimit())
-				netdev_warn(dev, "Memory squeeze, dropping packet\n");
+				netdev_warn(dev, "Memory squeeze, "
+						"dropping packet\n");
 			dev->stats.rx_dropped++;
 		}
 		received++;
 
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
-		RTL_W16 (RxBufPtr, (u16) (cur_rx - 16));
+		RTL_W16(RxBufPtr, (u16) (cur_rx - 16));
 
 		rtl8139_isr_ack(tp);
 	}
@@ -2016,7 +2043,8 @@ no_early_rx:
 	if (unlikely(!received || rx_size == 0xfff0))
 		rtl8139_isr_ack(tp);
 
-	netdev_dbg(dev, "Done %s(), current %04x BufAddr %04x, free to %04x, Cmd %02x\n",
+	netdev_dbg(dev, "Done %s(), current %04x BufAddr %04x, free to %04x, "
+								"Cmd %02x\n",
 		   __func__, cur_rx,
 		   RTL_R16(RxBufAddr), RTL_R16(RxBufPtr), RTL_R8(ChipCmd));
 
@@ -2034,20 +2062,20 @@ out:
 }
 
 
-static void rtl8139_weird_interrupt (struct net_device *dev,
+static void rtl8139_weird_interrupt(struct net_device *dev,
 				     struct rtl8139_private *tp,
 				     void __iomem *ioaddr,
 				     int status, int link_changed)
 {
 	netdev_dbg(dev, "Abnormal interrupt, status %08x\n", status);
 
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
+	assert(dev != NULL);
+	assert(tp != NULL);
+	assert(ioaddr != NULL);
 
 	/* Update the error count. */
-	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
-	RTL_W32 (RxMissed, 0);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
+	RTL_W32(RxMissed, 0);
 
 	if ((status & RxUnderrun) && link_changed &&
 	    (tp->drv_flags & HAS_LNK_CHNG)) {
@@ -2064,8 +2092,8 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 		dev->stats.rx_fifo_errors++;
 	if (status & PCIErr) {
 		u16 pci_cmd_status;
-		pci_read_config_word (tp->pci_dev, PCI_STATUS, &pci_cmd_status);
-		pci_write_config_word (tp->pci_dev, PCI_STATUS, pci_cmd_status);
+		pci_read_config_word(tp->pci_dev, PCI_STATUS, &pci_cmd_status);
+		pci_write_config_word(tp->pci_dev, PCI_STATUS, pci_cmd_status);
 
 		netdev_err(dev, "PCI Bus error %04x\n", pci_cmd_status);
 	}
@@ -2073,7 +2101,8 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 
 static int rtl8139_poll(struct napi_struct *napi, int budget)
 {
-	struct rtl8139_private *tp = container_of(napi, struct rtl8139_private, napi);
+	struct rtl8139_private *tp = container_of(napi, struct rtl8139_private,
+									 napi);
 	struct net_device *dev = tp->dev;
 	void __iomem *ioaddr = tp->mmio_addr;
 	int work_done;
@@ -2101,7 +2130,7 @@ static int rtl8139_poll(struct napi_struct *napi, int budget)
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
-static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
+static irqreturn_t rtl8139_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct rtl8139_private *tp = netdev_priv(dev);
@@ -2110,8 +2139,8 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
 	int link_changed = 0; /* avoid bogus "uninit" warning */
 	int handled = 0;
 
-	spin_lock (&tp->lock);
-	status = RTL_R16 (IntrStatus);
+	spin_lock(&tp->lock);
+	status = RTL_R16(IntrStatus);
 
 	/* shared irq? */
 	if (unlikely((status & rtl8139_intr_mask) == 0))
@@ -2125,40 +2154,40 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
 
 	/* close possible race's with dev_close */
 	if (unlikely(!netif_running(dev))) {
-		RTL_W16 (IntrMask, 0);
+		RTL_W16(IntrMask, 0);
 		goto out;
 	}
 
 	/* Acknowledge all of the current interrupt sources ASAP, but
 	   an first get an additional status bit from CSCR. */
 	if (unlikely(status & RxUnderrun))
-		link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
+		link_changed = RTL_R16(CSCR) & CSCR_LinkChangeBit;
 
 	ackstat = status & ~(RxAckBits | TxErr);
 	if (ackstat)
-		RTL_W16 (IntrStatus, ackstat);
+		RTL_W16(IntrStatus, ackstat);
 
 	/* Receive packets are processed by poll routine.
 	   If not running start it now. */
-	if (status & RxAckBits){
+	if (status & RxAckBits) {
 		if (napi_schedule_prep(&tp->napi)) {
-			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
+			RTL_W16_F(IntrMask, rtl8139_norx_intr_mask);
 			__napi_schedule(&tp->napi);
 		}
 	}
 
 	/* Check uncommon events with one test. */
 	if (unlikely(status & (PCIErr | PCSTimeout | RxUnderrun | RxErr)))
-		rtl8139_weird_interrupt (dev, tp, ioaddr,
+		rtl8139_weird_interrupt(dev, tp, ioaddr,
 					 status, link_changed);
 
 	if (status & (TxOK | TxErr)) {
-		rtl8139_tx_interrupt (dev, tp, ioaddr);
+		rtl8139_tx_interrupt(dev, tp, ioaddr);
 		if (status & TxErr)
-			RTL_W16 (IntrStatus, TxErr);
+			RTL_W16(IntrStatus, TxErr);
 	}
  out:
-	spin_unlock (&tp->lock);
+	spin_unlock(&tp->lock);
 
 	netdev_dbg(dev, "exiting interrupt, intr_status=%#4.4x\n",
 		   RTL_R16(IntrStatus));
@@ -2201,7 +2230,7 @@ static int rtl8139_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int rtl8139_close (struct net_device *dev)
+static int rtl8139_close(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -2210,26 +2239,27 @@ static int rtl8139_close (struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&tp->napi);
 
-	netif_dbg(tp, ifdown, dev, "Shutting down ethercard, status was 0x%04x\n",
-		  RTL_R16(IntrStatus));
+	netif_dbg(tp, ifdown, dev, "Shutting down ethercard,"
+					" status was 0x%04x\n",
+					RTL_R16(IntrStatus));
 
-	spin_lock_irqsave (&tp->lock, flags);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	/* Stop the chip's Tx and Rx DMA processes. */
-	RTL_W8 (ChipCmd, 0);
+	RTL_W8(ChipCmd, 0);
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	RTL_W16 (IntrMask, 0);
+	RTL_W16(IntrMask, 0);
 
 	/* Update the error counts. */
-	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
-	RTL_W32 (RxMissed, 0);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
+	RTL_W32(RxMissed, 0);
 
-	spin_unlock_irqrestore (&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
-	free_irq (dev->irq, dev);
+	free_irq(dev->irq, dev);
 
-	rtl8139_tx_clear (tp);
+	rtl8139_tx_clear(tp);
 
 	dma_free_coherent(&tp->pci_dev->dev, RX_BUF_TOT_LEN,
 			  tp->rx_ring, tp->rx_ring_dma);
@@ -2239,10 +2269,10 @@ static int rtl8139_close (struct net_device *dev)
 	tp->tx_bufs = NULL;
 
 	/* Green! Put the chip in low-power mode. */
-	RTL_W8 (Cfg9346, Cfg9346_Unlock);
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
 	if (rtl_chip_info[tp->chipset].flags & HasHltClk)
-		RTL_W8 (HltClk, 'H');	/* 'R' would leave the clock running. */
+		RTL_W8(HltClk, 'H');	/* 'R' would leave the clock running. */
 
 	return 0;
 }
@@ -2258,8 +2288,8 @@ static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	spin_lock_irq(&tp->lock);
 	if (rtl_chip_info[tp->chipset].flags & HasLWake) {
-		u8 cfg3 = RTL_R8 (Config3);
-		u8 cfg5 = RTL_R8 (Config5);
+		u8 cfg3 = RTL_R8(Config3);
+		u8 cfg5 = RTL_R8(Config5);
 
 		wol->supported = WAKE_PHY | WAKE_MAGIC
 			| WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;
@@ -2300,16 +2330,16 @@ static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		return -EINVAL;
 
 	spin_lock_irq(&tp->lock);
-	cfg3 = RTL_R8 (Config3) & ~(Cfg3_LinkUp | Cfg3_Magic);
+	cfg3 = RTL_R8(Config3) & ~(Cfg3_LinkUp | Cfg3_Magic);
 	if (wol->wolopts & WAKE_PHY)
 		cfg3 |= Cfg3_LinkUp;
 	if (wol->wolopts & WAKE_MAGIC)
 		cfg3 |= Cfg3_Magic;
-	RTL_W8 (Cfg9346, Cfg9346_Unlock);
-	RTL_W8 (Config3, cfg3);
-	RTL_W8 (Cfg9346, Cfg9346_Lock);
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W8(Config3, cfg3);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	cfg5 = RTL_R8 (Config5) & ~(Cfg5_UWF | Cfg5_MWF | Cfg5_BWF);
+	cfg5 = RTL_R8(Config5) & ~(Cfg5_UWF | Cfg5_MWF | Cfg5_BWF);
 	/* (KON)FIXME: These are untested.  We may have to set the
 	   CRC0, Wakeup0 and LSBCRC0 registers too, but I have no
 	   documentation.  */
@@ -2319,13 +2349,14 @@ static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		cfg5 |= Cfg5_MWF;
 	if (wol->wolopts & WAKE_BCAST)
 		cfg5 |= Cfg5_BWF;
-	RTL_W8 (Config5, cfg5);	/* need not unlock via Cfg9346 */
+	RTL_W8(Config5, cfg5);	/* need not unlock via Cfg9346 */
 	spin_unlock_irq(&tp->lock);
 
 	return 0;
 }
 
-static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+static void rtl8139_get_drvinfo(struct net_device *dev,
+				struct ethtool_drvinfo *info)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	strcpy(info->driver, DRV_NAME);
@@ -2387,7 +2418,8 @@ static int rtl8139_get_regs_len(struct net_device *dev)
 	return tp->regs_len;
 }
 
-static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
+static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+								 void *regbuf)
 {
 	struct rtl8139_private *tp;
 
@@ -2413,7 +2445,8 @@ static int rtl8139_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
-static void rtl8139_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
+static void rtl8139_get_ethtool_stats(struct net_device *dev,
+			struct ethtool_stats *stats, u64 *data)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 
@@ -2461,17 +2494,17 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 
-static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
+static struct net_device_stats *rtl8139_get_stats(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
 	if (netif_running(dev)) {
-		spin_lock_irqsave (&tp->lock, flags);
-		dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
-		RTL_W32 (RxMissed, 0);
-		spin_unlock_irqrestore (&tp->lock, flags);
+		spin_lock_irqsave(&tp->lock, flags);
+		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
+		RTL_W32(RxMissed, 0);
+		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
 	return &dev->stats;
@@ -2480,7 +2513,7 @@ static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 /* Set or clear the multicast filter for this adaptor.
    This routine is not state sensitive and need not be SMP locked. */
 
-static void __set_rx_mode (struct net_device *dev)
+static void __set_rx_mode(struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -2507,7 +2540,8 @@ static void __set_rx_mode (struct net_device *dev)
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
 		netdev_for_each_mc_addr(mclist, dev) {
-			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+			int bit_nr = ether_crc(ETH_ALEN,
+			mclist->dmi_addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			rx_mode |= AcceptMulticast;
@@ -2517,68 +2551,68 @@ static void __set_rx_mode (struct net_device *dev)
 	/* We can safely update without stopping the chip. */
 	tmp = rtl8139_rx_config | rx_mode;
 	if (tp->rx_config != tmp) {
-		RTL_W32_F (RxConfig, tmp);
+		RTL_W32_F(RxConfig, tmp);
 		tp->rx_config = tmp;
 	}
-	RTL_W32_F (MAR0 + 0, mc_filter[0]);
-	RTL_W32_F (MAR0 + 4, mc_filter[1]);
+	RTL_W32_F(MAR0 + 0, mc_filter[0]);
+	RTL_W32_F(MAR0 + 4, mc_filter[1]);
 }
 
-static void rtl8139_set_rx_mode (struct net_device *dev)
+static void rtl8139_set_rx_mode(struct net_device *dev)
 {
 	unsigned long flags;
 	struct rtl8139_private *tp = netdev_priv(dev);
 
-	spin_lock_irqsave (&tp->lock, flags);
+	spin_lock_irqsave(&tp->lock, flags);
 	__set_rx_mode(dev);
-	spin_unlock_irqrestore (&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
 #ifdef CONFIG_PM
 
-static int rtl8139_suspend (struct pci_dev *pdev, pm_message_t state)
+static int rtl8139_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
-	pci_save_state (pdev);
+	pci_save_state(pdev);
 
-	if (!netif_running (dev))
+	if (!netif_running(dev))
 		return 0;
 
-	netif_device_detach (dev);
+	netif_device_detach(dev);
 
-	spin_lock_irqsave (&tp->lock, flags);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	/* Disable interrupts, stop Tx and Rx. */
-	RTL_W16 (IntrMask, 0);
-	RTL_W8 (ChipCmd, 0);
+	RTL_W16(IntrMask, 0);
+	RTL_W8(ChipCmd, 0);
 
 	/* Update the error counts. */
-	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
-	RTL_W32 (RxMissed, 0);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
+	RTL_W32(RxMissed, 0);
 
-	spin_unlock_irqrestore (&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
-	pci_set_power_state (pdev, PCI_D3hot);
+	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
 }
 
 
-static int rtl8139_resume (struct pci_dev *pdev)
+static int rtl8139_resume(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 
-	pci_restore_state (pdev);
-	if (!netif_running (dev))
+	pci_restore_state(pdev);
+	if (!netif_running(dev))
 		return 0;
-	pci_set_power_state (pdev, PCI_D0);
-	rtl8139_init_ring (dev);
-	rtl8139_hw_start (dev);
-	netif_device_attach (dev);
+	pci_set_power_state(pdev, PCI_D0);
+	rtl8139_init_ring(dev);
+	rtl8139_hw_start(dev);
+	netif_device_attach(dev);
 	return 0;
 }
 
@@ -2597,7 +2631,7 @@ static struct pci_driver rtl8139_pci_driver = {
 };
 
 
-static int __init rtl8139_init_module (void)
+static int __init rtl8139_init_module(void)
 {
 	/* when we're a module, we always print a version message,
 	 * even if no 8139 board is found.
@@ -2610,11 +2644,11 @@ static int __init rtl8139_init_module (void)
 }
 
 
-static void __exit rtl8139_cleanup_module (void)
+static void __exit rtl8139_cleanup_module(void)
 {
-	pci_unregister_driver (&rtl8139_pci_driver);
+	pci_unregister_driver(&rtl8139_pci_driver);
 }
 
 
 module_init(rtl8139_init_module);
-module_exit(rtl8139_cleanup_module);
+Module_exit(rtl8139_cleanup_module);
------=_20100412093643_10627--

