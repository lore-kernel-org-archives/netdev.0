From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Subject: [PATCH 1/2] 8139too: clean up spaces and TABs
Date: Sat, 14 Jun 2008 14:36:50 +0200
Message-ID: <4853BB62.1060109@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754268AbYFNMhu@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>

Clean up the following errors and warnings reported by checkpatch.pl:
 - space prohibited between function name and open parenthesis '('
 - space required before the open brace '{'
 - code indent should use tabs where possible
 - line over 80 characters
 - spaces required around that '=3D' (ctx:VxW)

Signed-off-by: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
---
--- a/drivers/net/8139too.c	2008-06-14 00:20:47.000000000 +0200
+++ b/drivers/net/8139too.c	2008-06-14 14:08:18.000000000 +0200
@@ -11,7 +11,7 @@

 	-----<snip>-----

-        	Written 1997-2001 by Donald Becker.
+		Written 1997-2001 by Donald Becker.
 		This software may be used and distributed according to the
 		terms of the GNU General Public License (GPL), incorporated
 		herein by reference.  Drivers based on or derived from this
@@ -116,8 +116,8 @@

 /* Default Message level */
 #define RTL8139_DEF_MSG_ENABLE   (NETIF_MSG_DRV   | \
-                                 NETIF_MSG_PROBE  | \
-                                 NETIF_MSG_LINK)
+				  NETIF_MSG_PROBE | \
+				  NETIF_MSG_LINK)


 /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
@@ -134,7 +134,8 @@

 #if RTL8139_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTI=
ON__ , ## args)
+#  define DPRINTK(fmt, args...) \
+	printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -143,10 +144,10 @@
 #  define assert(expr) do {} while (0)
 #else
 #  define assert(expr) \
-        if(unlikely(!(expr))) {				        \
-        printk(KERN_ERR "Assertion failed! %s,%s,%s,line=3D%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		        \
-        }
+	if (unlikely(!(expr))) {					\
+		printk(KERN_ERR "Assertion failed! %s,%s,%s,line=3D%d\n",	\
+		       #expr, __FILE__, __FUNCTION__, __LINE__);	\
+	}
 #endif


@@ -196,7 +197,8 @@ static int debug =3D -1;
    Threshold is bytes transferred to chip before transmission starts. =
*/
 #define TX_FIFO_THRESH 256	/* In bytes, rounded down to 32 byte units.=
 */

-/* The following settings are log_2(bytes)-4:  0 =3D=3D 16 bytes .. 6=3D=
=3D1024, 7=3D=3Dend of packet. */
+/* The following settings are log_2(bytes)-4:
+   0 =3D=3D 16 bytes .. 6=3D=3D1024, 7=3D=3Dend of packet. */
 #define RX_FIFO_THRESH	7	/* Rx buffer level before first PCI xfer.  */
 #define RX_DMA_BURST	7	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
@@ -276,7 +278,7 @@ static struct pci_device_id rtl8139_pci_

 	{0,}
 };
-MODULE_DEVICE_TABLE (pci, rtl8139_pci_tbl);
+MODULE_DEVICE_TABLE(pci, rtl8139_pci_tbl);

 static struct {
 	const char str[ETH_GSTRING_LEN];
@@ -388,12 +390,12 @@ enum rx_mode_bits {

 /* Bits in TxConfig. */
 enum tx_config_bits {
-        /* Interframe Gap Time. Only TxIFG96 doesn't violate IEEE 802.=
3 */
-        TxIFGShift	=3D 24,
-        TxIFG84		=3D (0 << TxIFGShift), /* 8.4us / 840ns (10 / 100Mbps=
) */
-        TxIFG88		=3D (1 << TxIFGShift), /* 8.8us / 880ns (10 / 100Mbps=
) */
-        TxIFG92		=3D (2 << TxIFGShift), /* 9.2us / 920ns (10 / 100Mbps=
) */
-        TxIFG96		=3D (3 << TxIFGShift), /* 9.6us / 960ns (10 / 100Mbps=
) */
+	/* Interframe Gap Time. Only TxIFG96 doesn't violate IEEE 802.3 */
+	TxIFGShift	=3D 24,
+	TxIFG84		=3D (0 << TxIFGShift), /* 8.4us / 840ns (10 / 100Mbps) */
+	TxIFG88		=3D (1 << TxIFGShift), /* 8.8us / 880ns (10 / 100Mbps) */
+	TxIFG92		=3D (2 << TxIFGShift), /* 9.2us / 920ns (10 / 100Mbps) */
+	TxIFG96		=3D (3 << TxIFGShift), /* 9.6us / 960ns (10 / 100Mbps) */

 	TxLoopBack	=3D (1 << 18) | (1 << 17), /* enable loopback test mode */
 	TxCRC		=3D (1 << 16),	/* DISABLE Tx pkt CRC append */
@@ -420,14 +422,15 @@ enum Config1Bits {

 /* Bits in Config3 */
 enum Config3Bits {
-	Cfg3_FBtBEn   	=3D (1 << 0), /* 1	=3D Fast Back to Back */
-	Cfg3_FuncRegEn	=3D (1 << 1), /* 1	=3D enable CardBus Function registe=
rs */
-	Cfg3_CLKRUN_En	=3D (1 << 2), /* 1	=3D enable CLKRUN */
-	Cfg3_CardB_En 	=3D (1 << 3), /* 1	=3D enable CardBus registers */
-	Cfg3_LinkUp   	=3D (1 << 4), /* 1	=3D wake up on link up */
-	Cfg3_Magic    	=3D (1 << 5), /* 1	=3D wake up on Magic Packet (tm) */
-	Cfg3_PARM_En  	=3D (1 << 6), /* 0	=3D software can set twister parame=
ters */
-	Cfg3_GNTSel   	=3D (1 << 7), /* 1	=3D delay 1 clock from PCI GNT sign=
al */
+	Cfg3_FBtBEn   	=3D (1 << 0), /* 1 =3D Fast Back to Back */
+	Cfg3_FuncRegEn	=3D (1 << 1), /* 1 =3D enable CardBus Function registe=
rs */
+	Cfg3_CLKRUN_En	=3D (1 << 2), /* 1 =3D enable CLKRUN */
+	Cfg3_CardB_En 	=3D (1 << 3), /* 1 =3D enable CardBus registers */
+	Cfg3_LinkUp   	=3D (1 << 4), /* 1 =3D wake up on link up */
+	Cfg3_Magic    	=3D (1 << 5), /* 1 =3D wake up on Magic Packet (tm) */
+	Cfg3_PARM_En  	=3D (1 << 6), /* 0 =3D software can set twister
+					   parameters */
+	Cfg3_GNTSel   	=3D (1 << 7), /* 1 =3D delay 1 clock from PCI GNT sign=
al */
 };

 /* Bits in Config4 */
@@ -437,13 +440,13 @@ enum Config4Bits {

 /* Bits in Config5 */
 enum Config5Bits {
-	Cfg5_PME_STS   	=3D (1 << 0), /* 1	=3D PCI reset resets PME_Status */
-	Cfg5_LANWake   	=3D (1 << 1), /* 1	=3D enable LANWake signal */
-	Cfg5_LDPS      	=3D (1 << 2), /* 0	=3D save power when link is down *=
/
-	Cfg5_FIFOAddrPtr=3D (1 << 3), /* Realtek internal SRAM testing */
-	Cfg5_UWF        =3D (1 << 4), /* 1 =3D accept unicast wakeup frame */
-	Cfg5_MWF        =3D (1 << 5), /* 1 =3D accept multicast wakeup frame =
*/
-	Cfg5_BWF        =3D (1 << 6), /* 1 =3D accept broadcast wakeup frame =
*/
+	Cfg5_PME_STS     =3D (1 << 0), /* 1 =3D PCI reset resets PME_Status *=
/
+	Cfg5_LANWake     =3D (1 << 1), /* 1 =3D enable LANWake signal */
+	Cfg5_LDPS        =3D (1 << 2), /* 0 =3D save power when link is down =
*/
+	Cfg5_FIFOAddrPtr =3D (1 << 3), /* Realtek internal SRAM testing */
+	Cfg5_UWF         =3D (1 << 4), /* 1 =3D accept unicast wakeup frame *=
/
+	Cfg5_MWF         =3D (1 << 5), /* 1 =3D accept multicast wakeup frame=
 */
+	Cfg5_BWF         =3D (1 << 6), /* 1 =3D accept broadcast wakeup frame=
 */
 };

 enum RxConfigBits {
@@ -545,8 +548,8 @@ static const struct {

 	{ "RTL-8100",
 	  HW_REVID(1, 1, 1, 1, 0, 1, 0),
- 	  HasLWake,
- 	},
+	  HasLWake,
+	},

 	{ "RTL-8100B/8139D",
 	  HW_REVID(1, 1, 1, 0, 1, 0, 1),
@@ -610,8 +613,8 @@ struct rtl8139_private {
 	unsigned long		fifo_copy_timeout;
 };

-MODULE_AUTHOR ("Jeff Garzik <jgarzik@pobox.com>");
-MODULE_DESCRIPTION ("RealTek RTL-8139 Fast Ethernet driver");
+MODULE_AUTHOR("Jeff Garzik <jgarzik@pobox.com>");
+MODULE_DESCRIPTION("RealTek RTL-8139 Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);

@@ -619,51 +622,63 @@ module_param(multicast_filter_limit, int
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 module_param(debug, int, 0);
-MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
-MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of f=
iltered multicast addresses");
-MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5:=
 100Mbps");
-MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s=
) (1)");
-
-static int read_eeprom (void __iomem *ioaddr, int location, int addr_l=
en);
-static int rtl8139_open (struct net_device *dev);
-static int mdio_read (struct net_device *dev, int phy_id, int location=
);
-static void mdio_write (struct net_device *dev, int phy_id, int locati=
on,
+MODULE_PARM_DESC(debug, "8139too bitmapped message enable number");
+MODULE_PARM_DESC(multicast_filter_limit,
+	"8139too maximum number of filtered multicast addresses");
+MODULE_PARM_DESC(media, "8139too: Bits 4+9: force full duplex, bit 5: =
100Mbps");
+MODULE_PARM_DESC(full_duplex, "8139too: Force full duplex for board(s)=
 (1)");
+
+static int read_eeprom(void __iomem *ioaddr, int location, int addr_le=
n);
+static int rtl8139_open(struct net_device *dev);
+static int mdio_read(struct net_device *dev, int phy_id, int location)=
;
+static void mdio_write(struct net_device *dev, int phy_id, int locatio=
n,
 			int val);
 static void rtl8139_start_thread(struct rtl8139_private *tp);
-static void rtl8139_tx_timeout (struct net_device *dev);
-static void rtl8139_init_ring (struct net_device *dev);
-static int rtl8139_start_xmit (struct sk_buff *skb,
+static void rtl8139_tx_timeout(struct net_device *dev);
+static void rtl8139_init_ring(struct net_device *dev);
+static int rtl8139_start_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void rtl8139_poll_controller(struct net_device *dev);
 #endif
 static int rtl8139_poll(struct napi_struct *napi, int budget);
-static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance);
-static int rtl8139_close (struct net_device *dev);
-static int netdev_ioctl (struct net_device *dev, struct ifreq *rq, int=
 cmd);
-static struct net_device_stats *rtl8139_get_stats (struct net_device *=
dev);
-static void rtl8139_set_rx_mode (struct net_device *dev);
-static void __set_rx_mode (struct net_device *dev);
-static void rtl8139_hw_start (struct net_device *dev);
-static void rtl8139_thread (struct work_struct *work);
+static irqreturn_t rtl8139_interrupt(int irq, void *dev_instance);
+static int rtl8139_close(struct net_device *dev);
+static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd);
+static struct net_device_stats *rtl8139_get_stats(struct net_device *d=
ev);
+static void rtl8139_set_rx_mode(struct net_device *dev);
+static void __set_rx_mode(struct net_device *dev);
+static void rtl8139_hw_start(struct net_device *dev);
+static void rtl8139_thread(struct work_struct *work);
 static void rtl8139_tx_timeout_task(struct work_struct *work);
 static const struct ethtool_ops rtl8139_ethtool_ops;

 /* write MMIO register, with flush */
 /* Flush avoids rtl8139 bug w/ posted MMIO writes */
-#define RTL_W8_F(reg, val8)	do { iowrite8 ((val8), ioaddr + (reg)); io=
read8 (ioaddr + (reg)); } while (0)
-#define RTL_W16_F(reg, val16)	do { iowrite16 ((val16), ioaddr + (reg))=
; ioread16 (ioaddr + (reg)); } while (0)
-#define RTL_W32_F(reg, val32)	do { iowrite32 ((val32), ioaddr + (reg))=
; ioread32 (ioaddr + (reg)); } while (0)
+#define RTL_W8_F(reg, val8)	\
+	do { \
+		iowrite8((val8), ioaddr + (reg)); \
+		ioread8(ioaddr + (reg)); \
+	} while (0)
+#define RTL_W16_F(reg, val16)	\
+	do { \
+		iowrite16((val16), ioaddr + (reg)); \
+		ioread16(ioaddr + (reg)); \
+	} while (0)
+#define RTL_W32_F(reg, val32)	do { \
+		iowrite32((val32), ioaddr + (reg)); \
+		ioread32(ioaddr + (reg)); \
+	} while (0)

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
+#define RTL_R8(reg)		ioread8(ioaddr + (reg))
+#define RTL_R16(reg)		ioread16(ioaddr + (reg))
+#define RTL_R32(reg)		((unsigned long) ioread32(ioaddr + (reg)))


 static const u16 rtl8139_intr_mask =3D
@@ -701,50 +716,50 @@ static const unsigned int rtl8139_rx_con
 static const unsigned int rtl8139_tx_config =3D
 	TxIFG96 | (TX_DMA_BURST << TxDMAShift) | (TX_RETRY << TxRetryShift);

-static void __rtl8139_cleanup_dev (struct net_device *dev)
+static void __rtl8139_cleanup_dev(struct net_device *dev)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	struct pci_dev *pdev;

-	assert (dev !=3D NULL);
-	assert (tp->pci_dev !=3D NULL);
+	assert(dev !=3D NULL);
+	assert(tp->pci_dev !=3D NULL);
 	pdev =3D tp->pci_dev;

 #ifdef USE_IO_OPS
 	if (tp->mmio_addr)
-		ioport_unmap (tp->mmio_addr);
+		ioport_unmap(tp->mmio_addr);
 #else
 	if (tp->mmio_addr)
-		pci_iounmap (pdev, tp->mmio_addr);
+		pci_iounmap(pdev, tp->mmio_addr);
 #endif /* USE_IO_OPS */

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
 	for (i =3D 1000; i > 0; i--) {
 		barrier();
-		if ((RTL_R8 (ChipCmd) & CmdReset) =3D=3D 0)
+		if ((RTL_R8(ChipCmd) & CmdReset) =3D=3D 0)
 			break;
-		udelay (10);
+		udelay(10);
 	}
 }


-static int __devinit rtl8139_init_board (struct pci_dev *pdev,
-					 struct net_device **dev_out)
+static int __devinit rtl8139_init_board(struct pci_dev *pdev,
+					struct net_device **dev_out)
 {
 	void __iomem *ioaddr;
 	struct net_device *dev;
@@ -756,12 +771,12 @@ static int __devinit rtl8139_init_board
 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
 	u32 version;

-	assert (pdev !=3D NULL);
+	assert(pdev !=3D NULL);

 	*dev_out =3D NULL;

 	/* dev and priv zeroed in alloc_etherdev */
-	dev =3D alloc_etherdev (sizeof (*tp));
+	dev =3D alloc_etherdev(sizeof(*tp));
 	if (dev =3D=3D NULL) {
 		dev_err(&pdev->dev, "Unable to alloc new net device\n");
 		return -ENOMEM;
@@ -772,19 +787,19 @@ static int __devinit rtl8139_init_board
 	tp->pci_dev =3D pdev;

 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
-	rc =3D pci_enable_device (pdev);
+	rc =3D pci_enable_device(pdev);
 	if (rc)
 		goto err_out;

-	pio_start =3D pci_resource_start (pdev, 0);
-	pio_end =3D pci_resource_end (pdev, 0);
-	pio_flags =3D pci_resource_flags (pdev, 0);
-	pio_len =3D pci_resource_len (pdev, 0);
-
-	mmio_start =3D pci_resource_start (pdev, 1);
-	mmio_end =3D pci_resource_end (pdev, 1);
-	mmio_flags =3D pci_resource_flags (pdev, 1);
-	mmio_len =3D pci_resource_len (pdev, 1);
+	pio_start =3D pci_resource_start(pdev, 0);
+	pio_end =3D pci_resource_end(pdev, 0);
+	pio_flags =3D pci_resource_flags(pdev, 0);
+	pio_len =3D pci_resource_len(pdev, 0);
+
+	mmio_start =3D pci_resource_start(pdev, 1);
+	mmio_end =3D pci_resource_end(pdev, 1);
+	mmio_flags =3D pci_resource_flags(pdev, 1);
+	mmio_len =3D pci_resource_len(pdev, 1);

 	/* set this immediately, we need to know before
 	 * we talk to the chip directly */
@@ -800,31 +815,34 @@ static int __devinit rtl8139_init_board
 	}
 	/* check for weird/broken PCI region reporting */
 	if (pio_len < RTL_MIN_IO_SIZE) {
-		dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
+		dev_err(&pdev->dev,
+			"Invalid PCI I/O region size(s), aborting\n");
 		rc =3D -ENODEV;
 		goto err_out;
 	}
 #else
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(mmio_flags & IORESOURCE_MEM)) {
-		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
+		dev_err(&pdev->dev,
+			"region #1 not an MMIO resource, aborting\n");
 		rc =3D -ENODEV;
 		goto err_out;
 	}
 	if (mmio_len < RTL_MIN_IO_SIZE) {
-		dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
+		dev_err(&pdev->dev,
+			"Invalid PCI mem region size(s), aborting\n");
 		rc =3D -ENODEV;
 		goto err_out;
 	}
 #endif

-	rc =3D pci_request_regions (pdev, DRV_NAME);
+	rc =3D pci_request_regions(pdev, DRV_NAME);
 	if (rc)
 		goto err_out;
 	disable_dev_on_err =3D 1;

 	/* enable PCI bus-mastering */
-	pci_set_master (pdev);
+	pci_set_master(pdev);

 #ifdef USE_IO_OPS
 	ioaddr =3D ioport_map(pio_start, pio_len);
@@ -850,76 +868,77 @@ static int __devinit rtl8139_init_board
 #endif /* USE_IO_OPS */

 	/* Bring old chips out of low-power mode. */
-	RTL_W8 (HltClk, 'R');
+	RTL_W8(HltClk, 'R');

 	/* check for missing/broken hardware */
-	if (RTL_R32 (TxConfig) =3D=3D 0xFFFFFFFF) {
+	if (RTL_R32(TxConfig) =3D=3D 0xFFFFFFFF) {
 		dev_err(&pdev->dev, "Chip not responding, ignoring board\n");
 		rc =3D -EIO;
 		goto err_out;
 	}

 	/* identify chip attached to board */
-	version =3D RTL_R32 (TxConfig) & HW_REVID_MASK;
-	for (i =3D 0; i < ARRAY_SIZE (rtl_chip_info); i++)
+	version =3D RTL_R32(TxConfig) & HW_REVID_MASK;
+	for (i =3D 0; i < ARRAY_SIZE(rtl_chip_info); i++)
 		if (version =3D=3D rtl_chip_info[i].version) {
 			tp->chipset =3D i;
 			goto match;
 		}

-	/* if unknown chip, assume array element #0, original RTL-8139 in thi=
s case */
-	dev_printk (KERN_DEBUG, &pdev->dev,
-		    "unknown chip version, assuming RTL-8139\n");
-	dev_printk (KERN_DEBUG, &pdev->dev,
-		    "TxConfig =3D 0x%lx\n", RTL_R32 (TxConfig));
+	/* if unknown chip, assume array element #0, original RTL-8139 in
+	   this case */
+	dev_printk(KERN_DEBUG, &pdev->dev,
+		   "unknown chip version, assuming RTL-8139\n");
+	dev_printk(KERN_DEBUG, &pdev->dev,
+		   "TxConfig =3D 0x%lx\n", RTL_R32(TxConfig));
 	tp->chipset =3D 0;

 match:
-	DPRINTK ("chipset id (%d) =3D=3D index %d, '%s'\n",
-		 version, i, rtl_chip_info[i].name);
+	DPRINTK("chipset id (%d) =3D=3D index %d, '%s'\n",
+		version, i, rtl_chip_info[i].name);

 	if (tp->chipset >=3D CH_8139B) {
-		u8 new_tmp8 =3D tmp8 =3D RTL_R8 (Config1);
+		u8 new_tmp8 =3D tmp8 =3D RTL_R8(Config1);
 		DPRINTK("PCI PM wakeup\n");
 		if ((rtl_chip_info[tp->chipset].flags & HasLWake) &&
 		    (tmp8 & LWAKE))
 			new_tmp8 &=3D ~LWAKE;
 		new_tmp8 |=3D Cfg1_PM_Enable;
 		if (new_tmp8 !=3D tmp8) {
-			RTL_W8 (Cfg9346, Cfg9346_Unlock);
-			RTL_W8 (Config1, tmp8);
-			RTL_W8 (Cfg9346, Cfg9346_Lock);
+			RTL_W8(Cfg9346, Cfg9346_Unlock);
+			RTL_W8(Config1, tmp8);
+			RTL_W8(Cfg9346, Cfg9346_Lock);
 		}
 		if (rtl_chip_info[tp->chipset].flags & HasLWake) {
-			tmp8 =3D RTL_R8 (Config4);
+			tmp8 =3D RTL_R8(Config4);
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
 		DPRINTK("Old chip wakeup\n");
-		tmp8 =3D RTL_R8 (Config1);
+		tmp8 =3D RTL_R8(Config1);
 		tmp8 &=3D ~(SLEEP | PWRDN);
-		RTL_W8 (Config1, tmp8);
+		RTL_W8(Config1, tmp8);
 	}

-	rtl8139_chip_reset (ioaddr);
+	rtl8139_chip_reset(ioaddr);

 	*dev_out =3D dev;
 	return 0;

 err_out:
-	__rtl8139_cleanup_dev (dev);
+	__rtl8139_cleanup_dev(dev);
 	if (disable_dev_on_err)
-		pci_disable_device (pdev);
+		pci_disable_device(pdev);
 	return rc;
 }


-static int __devinit rtl8139_init_one (struct pci_dev *pdev,
-				       const struct pci_device_id *ent)
+static int __devinit rtl8139_init_one(struct pci_dev *pdev,
+				      const struct pci_device_id *ent)
 {
 	struct net_device *dev =3D NULL;
 	struct rtl8139_private *tp;
@@ -928,8 +947,8 @@ static int __devinit rtl8139_init_one (s
 	static int board_idx =3D -1;
 	DECLARE_MAC_BUF(mac);

-	assert (pdev !=3D NULL);
-	assert (ent !=3D NULL);
+	assert(pdev !=3D NULL);
+	assert(ent !=3D NULL);

 	board_idx++;

@@ -940,34 +959,35 @@ static int __devinit rtl8139_init_one (s
 	{
 		static int printed_version;
 		if (!printed_version++)
-			printk (KERN_INFO RTL8139_DRIVER_NAME "\n");
+			printk(KERN_INFO RTL8139_DRIVER_NAME "\n");
 	}
 #endif

 	if (pdev->vendor =3D=3D PCI_VENDOR_ID_REALTEK &&
-	    pdev->device =3D=3D PCI_DEVICE_ID_REALTEK_8139 && pdev->revision =
>=3D 0x20) {
-		dev_info(&pdev->dev,
-			   "This (id %04x:%04x rev %02x) is an enhanced 8139C+ chip\n",
-		       	   pdev->vendor, pdev->device, pdev->revision);
-		dev_info(&pdev->dev,
-			   "Use the \"8139cp\" driver for improved performance and stabilit=
y.\n");
+	    pdev->device =3D=3D PCI_DEVICE_ID_REALTEK_8139 &&
+	    pdev->revision >=3D 0x20) {
+		dev_info(&pdev->dev, "This (id %04x:%04x rev %02x) is "
+			"an enhanced 8139C+ chip\n",
+			pdev->vendor, pdev->device, pdev->revision);
+		dev_info(&pdev->dev, "Use the \"8139cp\" driver for "
+			"improved performance and stability.\n");
 	}

-	i =3D rtl8139_init_board (pdev, &dev);
+	i =3D rtl8139_init_board(pdev, &dev);
 	if (i < 0)
 		return i;

-	assert (dev !=3D NULL);
+	assert(dev !=3D NULL);
 	tp =3D netdev_priv(dev);
 	tp->dev =3D dev;

 	ioaddr =3D tp->mmio_addr;
-	assert (ioaddr !=3D NULL);
+	assert(ioaddr !=3D NULL);

-	addr_len =3D read_eeprom (ioaddr, 0, 8) =3D=3D 0x8129 ? 8 : 6;
+	addr_len =3D read_eeprom(ioaddr, 0, 8) =3D=3D 0x8129 ? 8 : 6;
 	for (i =3D 0; i < 3; i++)
 		((__le16 *) (dev->dev_addr))[i] =3D
-		    cpu_to_le16(read_eeprom (ioaddr, i + 7, addr_len));
+		    cpu_to_le16(read_eeprom(ioaddr, i + 7, addr_len));
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);

 	/* The Rtl8139-specific entries in the device structure. */
@@ -1001,8 +1021,8 @@ static int __devinit rtl8139_init_one (s
 	tp->mmio_addr =3D ioaddr;
 	tp->msg_enable =3D
 		(debug < 0 ? RTL8139_DEF_MSG_ENABLE : ((1 << debug) - 1));
-	spin_lock_init (&tp->lock);
-	spin_lock_init (&tp->rx_lock);
+	spin_lock_init(&tp->lock);
+	spin_lock_init(&tp->rx_lock);
 	INIT_DELAYED_WORK(&tp->thread, rtl8139_thread);
 	tp->mii.dev =3D dev;
 	tp->mii.mdio_read =3D mdio_read;
@@ -1012,21 +1032,21 @@ static int __devinit rtl8139_init_one (s

 	/* dev is fully set up and ready to use now */
 	DPRINTK("about to register device named %s (%p)...\n", dev->name, dev=
);
-	i =3D register_netdev (dev);
+	i =3D register_netdev(dev);
 	if (i) goto err_out;

-	pci_set_drvdata (pdev, dev);
+	pci_set_drvdata(pdev, dev);

-	printk (KERN_INFO "%s: %s at 0x%lx, "
-		"%s, IRQ %d\n",
-		dev->name,
-		board_info[ent->driver_data].name,
-		dev->base_addr,
-		print_mac(mac, dev->dev_addr),
-		dev->irq);
+	printk(KERN_INFO "%s: %s at 0x%lx, "
+	       "%s, IRQ %d\n",
+	       dev->name,
+	       board_info[ent->driver_data].name,
+	       dev->base_addr,
+	       print_mac(mac, dev->dev_addr),
+	       dev->irq);

-	printk (KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
-		dev->name, rtl_chip_info[tp->chipset].name);
+	printk(KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
+	       dev->name, rtl_chip_info[tp->chipset].name);

 	/* Find the connected MII xcvrs.
 	   Doing this in open() would allow detecting external xcvrs later, b=
ut
@@ -1039,15 +1059,17 @@ static int __devinit rtl8139_init_one (s
 			if (mii_status !=3D 0xffff  &&  mii_status !=3D 0x0000) {
 				u16 advertising =3D mdio_read(dev, phy, 4);
 				tp->phys[phy_idx++] =3D phy;
-				printk(KERN_INFO "%s: MII transceiver %d status 0x%4.4x "
-					   "advertising %4.4x.\n",
-					   dev->name, phy, mii_status, advertising);
+				printk(KERN_INFO
+				       "%s: MII transceiver %d status 0x%4.4x "
+				       "advertising %4.4x.\n",
+				       dev->name, phy, mii_status,
+				       advertising);
 			}
 		}
 		if (phy_idx =3D=3D 0) {
-			printk(KERN_INFO "%s: No MII transceivers found!  Assuming SYM "
-				   "transceiver.\n",
-				   dev->name);
+			printk(KERN_INFO "%s: No MII transceivers found!  "
+			       "Assuming SYM transceiver.\n",
+			       dev->name);
 			tp->phys[0] =3D 32;
 		}
 	} else
@@ -1066,45 +1088,46 @@ static int __devinit rtl8139_init_one (s
 	if (board_idx < MAX_UNITS  &&  full_duplex[board_idx] > 0)
 		tp->mii.full_duplex =3D full_duplex[board_idx];
 	if (tp->mii.full_duplex) {
-		printk(KERN_INFO "%s: Media type forced to Full Duplex.\n", dev->nam=
e);
+		printk(KERN_INFO "%s: Media type forced to Full Duplex.\n",
+		       dev->name);
 		/* Changing the MII-advertised media because might prevent
 		   re-connection. */
 		tp->mii.force_media =3D 1;
 	}
 	if (tp->default_port) {
 		printk(KERN_INFO "  Forcing %dMbps %s-duplex operation.\n",
-			   (option & 0x20 ? 100 : 10),
-			   (option & 0x10 ? "full" : "half"));
+		       (option & 0x20 ? 100 : 10),
+		       (option & 0x10 ? "full" : "half"));
 		mdio_write(dev, tp->phys[0], 0,
-				   ((option & 0x20) ? 0x2000 : 0) | 	/* 100Mbps? */
-				   ((option & 0x10) ? 0x0100 : 0)); /* Full duplex? */
+			   ((option & 0x20) ? 0x2000 : 0) | 	/* 100Mbps? */
+			   ((option & 0x10) ? 0x0100 : 0)); /* Full duplex? */
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
-	struct net_device *dev =3D pci_get_drvdata (pdev);
+	struct net_device *dev =3D pci_get_drvdata(pdev);

-	assert (dev !=3D NULL);
+	assert(dev !=3D NULL);

 	flush_scheduled_work();

-	unregister_netdev (dev);
+	unregister_netdev(dev);

-	__rtl8139_cleanup_dev (dev);
-	pci_disable_device (pdev);
+	__rtl8139_cleanup_dev(dev);
+	pci_disable_device(pdev);
 }


@@ -1130,40 +1153,41 @@ static void __devexit rtl8139_remove_one
 #define EE_READ_CMD		(6)
 #define EE_ERASE_CMD	(7)

-static int __devinit read_eeprom (void __iomem *ioaddr, int location, =
int addr_len)
+static int __devinit read_eeprom(void __iomem *ioaddr, int location,
+				 int addr_len)
 {
 	int i;
 	unsigned retval =3D 0;
 	int read_cmd =3D location | (EE_READ_CMD << addr_len);

-	RTL_W8 (Cfg9346, EE_ENB & ~EE_CS);
-	RTL_W8 (Cfg9346, EE_ENB);
-	eeprom_delay ();
+	RTL_W8(Cfg9346, EE_ENB & ~EE_CS);
+	RTL_W8(Cfg9346, EE_ENB);
+	eeprom_delay();

 	/* Shift the read command bits out. */
 	for (i =3D 4 + addr_len; i >=3D 0; i--) {
 		int dataval =3D (read_cmd & (1 << i)) ? EE_DATA_WRITE : 0;
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

 	for (i =3D 16; i > 0; i--) {
-		RTL_W8 (Cfg9346, EE_ENB | EE_SHIFT_CLK);
-		eeprom_delay ();
+		RTL_W8(Cfg9346, EE_ENB | EE_SHIFT_CLK);
+		eeprom_delay();
 		retval =3D
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
@@ -1198,20 +1222,20 @@ static const char mii_2_8139_map[8] =3D {

 #ifdef CONFIG_8139TOO_8129
 /* Syncronize the MII management interface by shifting 32 one bits out=
=2E */
-static void mdio_sync (void __iomem *ioaddr)
+static void mdio_sync(void __iomem *ioaddr)
 {
 	int i;

 	for (i =3D 32; i >=3D 0; i--) {
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

-static int mdio_read (struct net_device *dev, int phy_id, int location=
)
+static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	int retval =3D 0;
@@ -1224,28 +1248,29 @@ static int mdio_read (struct net_device
 	if (phy_id > 31) {	/* Really a 8139.  Use internal registers. */
 		void __iomem *ioaddr =3D tp->mmio_addr;
 		return location < 8 && mii_2_8139_map[location] ?
-		    RTL_R16 (mii_2_8139_map[location]) : 0;
+		    RTL_R16(mii_2_8139_map[location]) : 0;
 	}

 #ifdef CONFIG_8139TOO_8129
-	mdio_sync (ioaddr);
+	mdio_sync(ioaddr);
 	/* Shift the read command bits out. */
 	for (i =3D 15; i >=3D 0; i--) {
 		int dataval =3D (mii_cmd & (1 << i)) ? MDIO_DATA_OUT : 0;

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
 	for (i =3D 19; i > 0; i--) {
-		RTL_W8 (Config4, 0);
-		mdio_delay ();
-		retval =3D (retval << 1) | ((RTL_R8 (Config4) & MDIO_DATA_IN) ? 1 : =
0);
-		RTL_W8 (Config4, MDIO_CLK);
-		mdio_delay ();
+		RTL_W8(Config4, 0);
+		mdio_delay();
+		retval =3D (retval << 1) |
+			 ((RTL_R8(Config4) & MDIO_DATA_IN) ? 1 : 0);
+		RTL_W8(Config4, MDIO_CLK);
+		mdio_delay();
 	}
 #endif

@@ -1253,57 +1278,59 @@ static int mdio_read (struct net_device
 }


-static void mdio_write (struct net_device *dev, int phy_id, int locati=
on,
-			int value)
+static void mdio_write(struct net_device *dev, int phy_id, int locatio=
n,
+		       int value)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 #ifdef CONFIG_8139TOO_8129
 	void __iomem *ioaddr =3D tp->mmio_addr;
-	int mii_cmd =3D (0x5002 << 16) | (phy_id << 23) | (location << 18) | =
value;
+	int mii_cmd =3D (0x5002 << 16) | (phy_id << 23) | (location << 18) |
+		      value;
 	int i;
 #endif

 	if (phy_id > 31) {	/* Really a 8139.  Use internal registers. */
 		void __iomem *ioaddr =3D tp->mmio_addr;
 		if (location =3D=3D 0) {
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
 	for (i =3D 31; i >=3D 0; i--) {
 		int dataval =3D
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
 	for (i =3D 2; i > 0; i--) {
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
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	int retval;
 	void __iomem *ioaddr =3D tp->mmio_addr;

-	retval =3D request_irq (dev->irq, rtl8139_interrupt, IRQF_SHARED, dev=
->name, dev);
+	retval =3D request_irq(dev->irq, rtl8139_interrupt, IRQF_SHARED,
+			     dev->name, dev);
 	if (retval)
 		return retval;

@@ -1330,16 +1357,16 @@ static int rtl8139_open (struct net_devi
 	tp->mii.full_duplex =3D tp->mii.force_media;
 	tp->tx_flag =3D (TX_FIFO_THRESH << 11) & 0x003f0000;

-	rtl8139_init_ring (dev);
-	rtl8139_hw_start (dev);
-	netif_start_queue (dev);
+	rtl8139_init_ring(dev);
+	rtl8139_hw_start(dev);
+	netif_start_queue(dev);

 	if (netif_msg_ifup(tp))
 		printk(KERN_DEBUG "%s: rtl8139_open() ioaddr %#llx IRQ %d"
-			" GP Pins %2.2x %s-duplex.\n", dev->name,
-			(unsigned long long)pci_resource_start (tp->pci_dev, 1),
-			dev->irq, RTL_R8 (MediaStatus),
-			tp->mii.full_duplex ? "full" : "half");
+		       " GP Pins %2.2x %s-duplex.\n", dev->name,
+		       (unsigned long long)pci_resource_start(tp->pci_dev, 1),
+		       dev->irq, RTL_R8(MediaStatus),
+		       tp->mii.full_duplex ? "full" : "half");

 	rtl8139_start_thread(tp);

@@ -1347,7 +1374,7 @@ static int rtl8139_open (struct net_devi
 }


-static void rtl_check_media (struct net_device *dev, unsigned int init=
_media)
+static void rtl_check_media(struct net_device *dev, unsigned int init_=
media)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);

@@ -1357,7 +1384,7 @@ static void rtl_check_media (struct net_
 }

 /* Start the hardware at open or resume. */
-static void rtl8139_hw_start (struct net_device *dev)
+static void rtl8139_hw_start(struct net_device *dev)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -1366,65 +1393,66 @@ static void rtl8139_hw_start (struct net

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

 	/* Must enable Tx/Rx before setting transfer thresholds! */
-	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
+	RTL_W8(ChipCmd, CmdRxEnb | CmdTxEnb);

 	tp->rx_config =3D rtl8139_rx_config | AcceptBroadcast | AcceptMyPhys;
-	RTL_W32 (RxConfig, tp->rx_config);
-	RTL_W32 (TxConfig, rtl8139_tx_config);
+	RTL_W32(RxConfig, tp->rx_config);
+	RTL_W32(TxConfig, rtl8139_tx_config);

 	tp->cur_rx =3D 0;

-	rtl_check_media (dev, 1);
+	rtl_check_media(dev, 1);

 	if (tp->chipset >=3D CH_8139B) {
 		/* Disable magic packet scanning, which is enabled
 		 * when PM is enabled in Config1.  It can be reenabled
 		 * via ETHTOOL_SWOL if desired.  */
-		RTL_W8 (Config3, RTL_R8 (Config3) & ~Cfg3_Magic);
+		RTL_W8(Config3, RTL_R8(Config3) & ~Cfg3_Magic);
 	}

 	DPRINTK("init buffer addresses\n");

 	/* Lock Config[01234] and BMCR register writes */
-	RTL_W8 (Cfg9346, Cfg9346_Lock);
+	RTL_W8(Cfg9346, Cfg9346_Lock);

 	/* init Rx ring buffer DMA address */
-	RTL_W32_F (RxBuf, tp->rx_ring_dma);
+	RTL_W32_F(RxBuf, tp->rx_ring_dma);

 	/* init Tx buffer DMA addresses */
 	for (i =3D 0; i < NUM_TX_DESC; i++)
-		RTL_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] - tp-=
>tx_bufs));
+		RTL_W32_F(TxAddr0 + (i * 4),
+			  tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs));

-	RTL_W32 (RxMissed, 0);
+	RTL_W32(RxMissed, 0);

-	rtl8139_set_rx_mode (dev);
+	rtl8139_set_rx_mode(dev);

 	/* no early-rx interrupts */
-	RTL_W16 (MultiIntr, RTL_R16 (MultiIntr) & MultiIntrClear);
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & MultiIntrClear);

 	/* make sure RxTx has started */
-	tmp =3D RTL_R8 (ChipCmd);
+	tmp =3D RTL_R8(ChipCmd);
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
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	int i;
@@ -1442,7 +1470,7 @@ static void rtl8139_init_ring (struct ne
 static int next_tick =3D 3 * HZ;

 #ifndef CONFIG_8139TOO_TUNE_TWISTER
-static inline void rtl8139_tune_twister (struct net_device *dev,
+static inline void rtl8139_tune_twister(struct net_device *dev,
 				  struct rtl8139_private *tp) {}
 #else
 enum TwisterParamVals {
@@ -1458,8 +1486,8 @@ static const unsigned long param[4][4] =3D
 	{0xbb39de43, 0xbb39ce43, 0xbb39ce83, 0xbb39ce83}
 };

-static void rtl8139_tune_twister (struct net_device *dev,
-				  struct rtl8139_private *tp)
+static void rtl8139_tune_twister(struct net_device *dev,
+				 struct rtl8139_private *tp)
 {
 	int linkcase;
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -1470,23 +1498,24 @@ static void rtl8139_tune_twister (struct
 	 */
 	switch (tp->twistie) {
 	case 1:
-		if (RTL_R16 (CSCR) & CSCR_LinkOKBit) {
+		if (RTL_R16(CSCR) & CSCR_LinkOKBit) {
 			/* We have link beat, let us tune the twister. */
-			RTL_W16 (CSCR, CSCR_LinkDownOffCmd);
+			RTL_W16(CSCR, CSCR_LinkDownOffCmd);
 			tp->twistie =3D 2;	/* Change to state 2. */
 			next_tick =3D HZ / 10;
 		} else {
-			/* Just put in some reasonable defaults for when beat returns. */
-			RTL_W16 (CSCR, CSCR_LinkDownCmd);
-			RTL_W32 (FIFOTMS, 0x20);	/* Turn on cable test mode. */
-			RTL_W32 (PARA78, PARA78_default);
-			RTL_W32 (PARA7c, PARA7c_default);
+			/* Just put in some reasonable defaults for when beat
+			   returns. */
+			RTL_W16(CSCR, CSCR_LinkDownCmd);
+			RTL_W32(FIFOTMS, 0x20);	/* Turn on cable test mode. */
+			RTL_W32(PARA78, PARA78_default);
+			RTL_W32(PARA7c, PARA7c_default);
 			tp->twistie =3D 0;	/* Bail from future actions. */
 		}
 		break;
 	case 2:
 		/* Read how long it took to hear the echo. */
-		linkcase =3D RTL_R16 (CSCR) & CSCR_LinkStatusBits;
+		linkcase =3D RTL_R16(CSCR) & CSCR_LinkStatusBits;
 		if (linkcase =3D=3D 0x7000)
 			tp->twist_row =3D 3;
 		else if (linkcase =3D=3D 0x3000)
@@ -1502,8 +1531,8 @@ static void rtl8139_tune_twister (struct
 	case 3:
 		/* Put out four tuning parameters, one per 100msec. */
 		if (tp->twist_col =3D=3D 0)
-			RTL_W16 (FIFOTMS, 0);
-		RTL_W32 (PARA7c, param[(int) tp->twist_row]
+			RTL_W16(FIFOTMS, 0);
+		RTL_W32(PARA7c, param[(int) tp->twist_row]
 			 [(int) tp->twist_col]);
 		next_tick =3D HZ / 10;
 		if (++tp->twist_col >=3D 4) {
@@ -1515,22 +1544,22 @@ static void rtl8139_tune_twister (struct
 		break;
 	case 4:
 		/* Special case for long cables: check for mistune. */
-		if ((RTL_R16 (CSCR) &
+		if ((RTL_R16(CSCR) &
 		     CSCR_LinkStatusBits) =3D=3D 0x7000) {
 			tp->twistie =3D 0;
 			break;
 		} else {
-			RTL_W32 (PARA7c, 0xfb38de03);
+			RTL_W32(PARA7c, 0xfb38de03);
 			tp->twistie =3D 5;
 			next_tick =3D HZ / 10;
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
 		tp->twist_row =3D 2;
 		tp->twist_col =3D 0;
 		tp->twistie =3D 3;
@@ -1544,13 +1573,13 @@ static void rtl8139_tune_twister (struct
 }
 #endif /* CONFIG_8139TOO_TUNE_TWISTER */

-static inline void rtl8139_thread_iter (struct net_device *dev,
-				 struct rtl8139_private *tp,
-				 void __iomem *ioaddr)
+static inline void rtl8139_thread_iter(struct net_device *dev,
+				       struct rtl8139_private *tp,
+				       void __iomem *ioaddr)
 {
 	int mii_lpa;

-	mii_lpa =3D mdio_read (dev, tp->phys[0], MII_LPA);
+	mii_lpa =3D mdio_read(dev, tp->phys[0], MII_LPA);

 	if (!tp->mii.force_media && mii_lpa !=3D 0xffff) {
 		int duplex =3D (mii_lpa & LPA_100FULL)
@@ -1559,38 +1588,39 @@ static inline void rtl8139_thread_iter (
 			tp->mii.full_duplex =3D duplex;

 			if (mii_lpa) {
-				printk (KERN_INFO
-					"%s: Setting %s-duplex based on MII #%d link"
-					" partner ability of %4.4x.\n",
-					dev->name,
-					tp->mii.full_duplex ? "full" : "half",
-					tp->phys[0], mii_lpa);
+				printk(KERN_INFO
+				       "%s: Setting %s-duplex based on MII "
+				       "#%d link partner ability of %4.4x.\n",
+				       dev->name,
+				       tp->mii.full_duplex ? "full" : "half",
+				       tp->phys[0], mii_lpa);
 			} else {
-				printk(KERN_INFO"%s: media is unconnected, link down, or incompati=
ble connection\n",
-				       dev->name);
+				printk(KERN_INFO"%s: media is unconnected, "
+				       "link down, or incompatible "
+				       "connection\n", dev->name);
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

 	next_tick =3D HZ * 60;

-	rtl8139_tune_twister (dev, tp);
+	rtl8139_tune_twister(dev, tp);

-	DPRINTK ("%s: Media selection tick, Link partner %4.4x.\n",
-		 dev->name, RTL_R16 (NWayLPAR));
-	DPRINTK ("%s:  Other registers are IntMask %4.4x IntStatus %4.4x\n",
-		 dev->name, RTL_R16 (IntrMask), RTL_R16 (IntrStatus));
-	DPRINTK ("%s:  Chip config %2.2x %2.2x.\n",
-		 dev->name, RTL_R8 (Config0),
-		 RTL_R8 (Config1));
+	DPRINTK("%s: Media selection tick, Link partner %4.4x.\n",
+		dev->name, RTL_R16(NWayLPAR));
+	DPRINTK("%s:  Other registers are IntMask %4.4x IntStatus %4.4x\n",
+		dev->name, RTL_R16(IntrMask), RTL_R16(IntrStatus));
+	DPRINTK("%s:  Chip config %2.2x %2.2x.\n",
+		dev->name, RTL_R8(Config0),
+		RTL_R8(Config1));
 }

-static void rtl8139_thread (struct work_struct *work)
+static void rtl8139_thread(struct work_struct *work)
 {
 	struct rtl8139_private *tp =3D
 		container_of(work, struct rtl8139_private, thread.work);
@@ -1611,7 +1641,7 @@ static void rtl8139_thread (struct work_
 	if (tp->have_thread)
 		schedule_delayed_work(&tp->thread, thr_delay);
 out_unlock:
-	rtnl_unlock ();
+	rtnl_unlock();
 }

 static void rtl8139_start_thread(struct rtl8139_private *tp)
@@ -1628,7 +1658,7 @@ static void rtl8139_start_thread(struct
 	schedule_delayed_work(&tp->thread, next_tick);
 }

-static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
+static inline void rtl8139_tx_clear(struct rtl8139_private *tp)
 {
 	tp->cur_tx =3D 0;
 	tp->dirty_tx =3D 0;
@@ -1636,7 +1666,7 @@ static inline void rtl8139_tx_clear (str
 	/* XXX account for unsent Tx packets in tp->stats.tx_dropped */
 }

-static void rtl8139_tx_timeout_task (struct work_struct *work)
+static void rtl8139_tx_timeout_task(struct work_struct *work)
 {
 	struct rtl8139_private *tp =3D
 		container_of(work, struct rtl8139_private, thread.work);
@@ -1645,43 +1675,43 @@ static void rtl8139_tx_timeout_task (str
 	int i;
 	u8 tmp8;

-	printk (KERN_DEBUG "%s: Transmit timeout, status %2.2x %4.4x %4.4x "
-		"media %2.2x.\n", dev->name, RTL_R8 (ChipCmd),
-		RTL_R16(IntrStatus), RTL_R16(IntrMask), RTL_R8(MediaStatus));
+	printk(KERN_DEBUG "%s: Transmit timeout, status %2.2x %4.4x %4.4x "
+	       "media %2.2x.\n", dev->name, RTL_R8(ChipCmd),
+	       RTL_R16(IntrStatus), RTL_R16(IntrMask), RTL_R8(MediaStatus));
 	/* Emit info to figure out what went wrong. */
-	printk (KERN_DEBUG "%s: Tx queue start entry %ld  dirty entry %ld.\n"=
,
-		dev->name, tp->cur_tx, tp->dirty_tx);
+	printk(KERN_DEBUG "%s: Tx queue start entry %ld  dirty entry %ld.\n",
+	       dev->name, tp->cur_tx, tp->dirty_tx);
 	for (i =3D 0; i < NUM_TX_DESC; i++)
-		printk (KERN_DEBUG "%s:  Tx descriptor %d is %8.8lx.%s\n",
-			dev->name, i, RTL_R32 (TxStatus0 + (i * 4)),
-			i =3D=3D tp->dirty_tx % NUM_TX_DESC ?
+		printk(KERN_DEBUG "%s:  Tx descriptor %d is %8.8lx.%s\n",
+		       dev->name, i, RTL_R32(TxStatus0 + (i * 4)),
+		       i =3D=3D tp->dirty_tx % NUM_TX_DESC ?
 				" (queue head)" : "");

 	tp->xstats.tx_timeouts++;

 	/* disable Tx ASAP, if not already */
-	tmp8 =3D RTL_R8 (ChipCmd);
+	tmp8 =3D RTL_R8(ChipCmd);
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
 	struct rtl8139_private *tp =3D netdev_priv(dev);

@@ -1692,7 +1722,7 @@ static void rtl8139_tx_timeout (struct n
 	}
 }

-static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device =
*dev)
+static int rtl8139_start_xmit(struct sk_buff *skb, struct net_device *=
dev)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -1716,8 +1746,8 @@ static int rtl8139_start_xmit (struct sk
 	}

 	spin_lock_irqsave(&tp->lock, flags);
-	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
-		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
+	RTL_W32_F(TxStatus0 + (entry * sizeof(u32)),
+		  tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));

 	dev->trans_start =3D jiffies;

@@ -1725,25 +1755,25 @@ static int rtl8139_start_xmit (struct sk
 	wmb();

 	if ((tp->cur_tx - NUM_TX_DESC) =3D=3D tp->dirty_tx)
-		netif_stop_queue (dev);
+		netif_stop_queue(dev);
 	spin_unlock_irqrestore(&tp->lock, flags);

 	if (netif_msg_tx_queued(tp))
-		printk (KERN_DEBUG "%s: Queued Tx packet size %u to slot %d.\n",
-			dev->name, len, entry);
+		printk(KERN_DEBUG "%s: Queued Tx packet size %u to slot %d.\n",
+		       dev->name, len, entry);

 	return 0;
 }


-static void rtl8139_tx_interrupt (struct net_device *dev,
-				  struct rtl8139_private *tp,
-				  void __iomem *ioaddr)
+static void rtl8139_tx_interrupt(struct net_device *dev,
+				 struct rtl8139_private *tp,
+				 void __iomem *ioaddr)
 {
 	unsigned long dirty_tx, tx_left;

-	assert (dev !=3D NULL);
-	assert (ioaddr !=3D NULL);
+	assert(dev !=3D NULL);
+	assert(ioaddr !=3D NULL);

 	dirty_tx =3D tp->dirty_tx;
 	tx_left =3D tp->cur_tx - dirty_tx;
@@ -1751,7 +1781,7 @@ static void rtl8139_tx_interrupt (struct
 		int entry =3D dirty_tx % NUM_TX_DESC;
 		int txstatus;

-		txstatus =3D RTL_R32 (TxStatus0 + (entry * sizeof (u32)));
+		txstatus =3D RTL_R32(TxStatus0 + (entry * sizeof(u32)));

 		if (!(txstatus & (TxStatOK | TxUnderrun | TxAborted)))
 			break;	/* It still hasn't been Txed */
@@ -1760,13 +1790,14 @@ static void rtl8139_tx_interrupt (struct
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
 			if (netif_msg_tx_err(tp))
-				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-					dev->name, txstatus);
+				printk(KERN_DEBUG "%s: Transmit error, "
+				       "Tx status %8.8x.\n",
+				       dev->name, txstatus);
 			tp->stats.tx_errors++;
 			if (txstatus & TxAborted) {
 				tp->stats.tx_aborted_errors++;
-				RTL_W32 (TxConfig, TxClearAbt);
-				RTL_W16 (IntrStatus, TxErr);
+				RTL_W32(TxConfig, TxClearAbt);
+				RTL_W16(IntrStatus, TxErr);
 				wmb();
 			}
 			if (txstatus & TxCarrierLost)
@@ -1791,8 +1822,8 @@ static void rtl8139_tx_interrupt (struct

 #ifndef RTL8139_NDEBUG
 	if (tp->cur_tx - dirty_tx > NUM_TX_DESC) {
-		printk (KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
-		        dev->name, dirty_tx, tp->cur_tx);
+		printk(KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
+		       dev->name, dirty_tx, tp->cur_tx);
 		dirty_tx +=3D NUM_TX_DESC;
 	}
 #endif /* RTL8139_NDEBUG */
@@ -1801,28 +1832,28 @@ static void rtl8139_tx_interrupt (struct
 	if (tp->dirty_tx !=3D dirty_tx) {
 		tp->dirty_tx =3D dirty_tx;
 		mb();
-		netif_wake_queue (dev);
+		netif_wake_queue(dev);
 	}
 }


 /* TODO: clean this up!  Rx reset need not be this intensive */
-static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
-			    struct rtl8139_private *tp, void __iomem *ioaddr)
+static void rtl8139_rx_err(u32 rx_status, struct net_device *dev,
+			   struct rtl8139_private *tp, void __iomem *ioaddr)
 {
 	u8 tmp8;
 #ifdef CONFIG_8139_OLD_RX_RESET
 	int tmp_work;
 #endif

-	if (netif_msg_rx_err (tp))
-		printk(KERN_DEBUG "%s: Ethernet frame had errors, status %8.8x.\n",
-			dev->name, rx_status);
+	if (netif_msg_rx_err(tp))
+		printk(KERN_DEBUG "%s: Ethernet frame had errors, "
+		       "status %8.8x.\n", dev->name, rx_status);
 	tp->stats.rx_errors++;
 	if (!(rx_status & RxStatusOK)) {
 		if (rx_status & RxTooLong) {
-			DPRINTK ("%s: Oversized Ethernet frame, status %4.4x!\n",
-			 	dev->name, rx_status);
+			DPRINTK("%s: Oversized Ethernet frame, status %4.4x!\n",
+				dev->name, rx_status);
 			/* A.C.: The chip hangs here. */
 		}
 		if (rx_status & (RxBadSymbol | RxBadAlign))
@@ -1836,56 +1867,56 @@ static void rtl8139_rx_err (u32 rx_statu
 	}

 #ifndef CONFIG_8139_OLD_RX_RESET
-	tmp8 =3D RTL_R8 (ChipCmd);
-	RTL_W8 (ChipCmd, tmp8 & ~CmdRxEnb);
-	RTL_W8 (ChipCmd, tmp8);
-	RTL_W32 (RxConfig, tp->rx_config);
+	tmp8 =3D RTL_R8(ChipCmd);
+	RTL_W8(ChipCmd, tmp8 & ~CmdRxEnb);
+	RTL_W8(ChipCmd, tmp8);
+	RTL_W32(RxConfig, tp->rx_config);
 	tp->cur_rx =3D 0;
 #else
 	/* Reset the receiver, based on RealTek recommendation. (Bug?) */

 	/* disable receive */
-	RTL_W8_F (ChipCmd, CmdTxEnb);
+	RTL_W8_F(ChipCmd, CmdTxEnb);
 	tmp_work =3D 200;
 	while (--tmp_work > 0) {
 		udelay(1);
-		tmp8 =3D RTL_R8 (ChipCmd);
+		tmp8 =3D RTL_R8(ChipCmd);
 		if (!(tmp8 & CmdRxEnb))
 			break;
 	}
 	if (tmp_work <=3D 0)
-		printk (KERN_WARNING PFX "rx stop wait too long\n");
+		printk(KERN_WARNING PFX "rx stop wait too long\n");
 	/* restart receive */
 	tmp_work =3D 200;
 	while (--tmp_work > 0) {
-		RTL_W8_F (ChipCmd, CmdRxEnb | CmdTxEnb);
+		RTL_W8_F(ChipCmd, CmdRxEnb | CmdTxEnb);
 		udelay(1);
-		tmp8 =3D RTL_R8 (ChipCmd);
+		tmp8 =3D RTL_R8(ChipCmd);
 		if ((tmp8 & CmdRxEnb) && (tmp8 & CmdTxEnb))
 			break;
 	}
 	if (tmp_work <=3D 0)
-		printk (KERN_WARNING PFX "tx/rx enable wait too long\n");
+		printk(KERN_WARNING PFX "tx/rx enable wait too long\n");

 	/* and reinitialize all rx related registers */
-	RTL_W8_F (Cfg9346, Cfg9346_Unlock);
+	RTL_W8_F(Cfg9346, Cfg9346_Unlock);
 	/* Must enable Tx/Rx before setting transfer thresholds! */
-	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
+	RTL_W8(ChipCmd, CmdRxEnb | CmdTxEnb);

 	tp->rx_config =3D rtl8139_rx_config | AcceptBroadcast | AcceptMyPhys;
-	RTL_W32 (RxConfig, tp->rx_config);
+	RTL_W32(RxConfig, tp->rx_config);
 	tp->cur_rx =3D 0;

 	DPRINTK("init buffer addresses\n");

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

@@ -1908,7 +1939,7 @@ static void rtl8139_isr_ack(struct rtl81
 	void __iomem *ioaddr =3D tp->mmio_addr;
 	u16 status;

-	status =3D RTL_R16 (IntrStatus) & RxAckBits;
+	status =3D RTL_R16(IntrStatus) & RxAckBits;

 	/* Clear out errors and receive interrupts */
 	if (likely(status !=3D 0)) {
@@ -1917,7 +1948,7 @@ static void rtl8139_isr_ack(struct rtl81
 			if (status & RxFIFOOver)
 				tp->stats.rx_fifo_errors++;
 		}
-		RTL_W16_F (IntrStatus, RxAckBits);
+		RTL_W16_F(IntrStatus, RxAckBits);
 	}
 }

@@ -1930,13 +1961,13 @@ static int rtl8139_rx(struct net_device
 	unsigned int cur_rx =3D tp->cur_rx;
 	unsigned int rx_size =3D 0;

-	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, (u16)cur_rx,
-		 RTL_R16 (RxBufAddr),
-		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
+	DPRINTK("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
+		" free to %4.4x, Cmd %2.2x.\n", dev->name, (u16)cur_rx,
+		RTL_R16(RxBufAddr),
+		RTL_R16(RxBufPtr), RTL_R8(ChipCmd));

 	while (netif_running(dev) && received < budget
-	       && (RTL_R8 (ChipCmd) & RxBufEmpty) =3D=3D 0) {
+	       && (RTL_R8(ChipCmd) & RxBufEmpty) =3D=3D 0) {
 		u32 ring_offset =3D cur_rx % RX_BUF_LEN;
 		u32 rx_status;
 		unsigned int pkt_size;
@@ -1945,22 +1976,22 @@ static int rtl8139_rx(struct net_device
 		rmb();

 		/* read size+status of next frame from DMA ring buffer */
-		rx_status =3D le32_to_cpu (*(__le32 *) (rx_ring + ring_offset));
+		rx_status =3D le32_to_cpu(*(__le32 *) (rx_ring + ring_offset));
 		rx_size =3D rx_status >> 16;
 		pkt_size =3D rx_size - 4;

 		if (netif_msg_rx_status(tp))
-			printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, size %4.4x,"
-				" cur %4.4x.\n", dev->name, rx_status,
-			 rx_size, cur_rx);
+			printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, "
+			       "size %4.4x, cur %4.4x.\n",
+			       dev->name, rx_status, rx_size, cur_rx);
 #if RTL8139_DEBUG > 2
 		{
 			int i;
-			DPRINTK ("%s: Frame contents ", dev->name);
+			DPRINTK("%s: Frame contents ", dev->name);
 			for (i =3D 0; i < 70; i++)
-				printk (" %2.2x",
-					rx_ring[ring_offset + i]);
-			printk (".\n");
+				printk(" %2.2x",
+				       rx_ring[ring_offset + i]);
+			printk(".\n");
 		}
 #endif

@@ -1972,7 +2003,7 @@ static int rtl8139_rx(struct net_device
 			if (!tp->fifo_copy_timeout)
 				tp->fifo_copy_timeout =3D jiffies + 2;
 			else if (time_after(jiffies, tp->fifo_copy_timeout)) {
-				DPRINTK ("%s: hung FIFO. Reset.", dev->name);
+				DPRINTK("%s: hung FIFO. Reset.", dev->name);
 				rx_size =3D 0;
 				goto no_early_rx;
 			}
@@ -1995,7 +2026,7 @@ no_early_rx:
 		if (unlikely((rx_size > (MAX_ETH_FRAME_SIZE+4)) ||
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
-			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
+			rtl8139_rx_err(rx_status, dev, tp, ioaddr);
 			received =3D -1;
 			goto out;
 		}
@@ -2003,34 +2034,35 @@ no_early_rx:
 		/* Malloc up new buffer, compatible with net-2e. */
 		/* Omit the four octet CRC from the length. */

-		skb =3D dev_alloc_skb (pkt_size + 2);
+		skb =3D dev_alloc_skb(pkt_size + 2);
 		if (likely(skb)) {
-			skb_reserve (skb, 2);	/* 16 byte align the IP fields. */
+			skb_reserve(skb, 2); /* 16 byte align the IP fields. */
 #if RX_BUF_IDX =3D=3D 3
 			wrap_copy(skb, rx_ring, ring_offset+4, pkt_size);
 #else
-			skb_copy_to_linear_data (skb, &rx_ring[ring_offset + 4], pkt_size);
+			skb_copy_to_linear_data(skb, &rx_ring[ring_offset + 4],
+				pkt_size);
 #endif
-			skb_put (skb, pkt_size);
+			skb_put(skb, pkt_size);

-			skb->protocol =3D eth_type_trans (skb, dev);
+			skb->protocol =3D eth_type_trans(skb, dev);

 			dev->last_rx =3D jiffies;
 			tp->stats.rx_bytes +=3D pkt_size;
 			tp->stats.rx_packets++;

-			netif_receive_skb (skb);
+			netif_receive_skb(skb);
 		} else {
 			if (net_ratelimit())
-				printk (KERN_WARNING
-					"%s: Memory squeeze, dropping packet.\n",
-					dev->name);
+				printk(KERN_WARNING
+				       "%s: Memory squeeze, dropping packet.\n",
+				       dev->name);
 			tp->stats.rx_dropped++;
 		}
 		received++;

 		cur_rx =3D (cur_rx + rx_size + 4 + 3) & ~3;
-		RTL_W16 (RxBufPtr, (u16) (cur_rx - 16));
+		RTL_W16(RxBufPtr, (u16) (cur_rx - 16));

 		rtl8139_isr_ack(tp);
 	}
@@ -2039,10 +2071,10 @@ no_early_rx:
 		rtl8139_isr_ack(tp);

 #if RTL8139_DEBUG > 1
-	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
-		 RTL_R16 (RxBufAddr),
-		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
+	DPRINTK("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
+		" free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
+		RTL_R16(RxBufAddr),
+		RTL_R16(RxBufPtr), RTL_R8(ChipCmd));
 #endif

 	tp->cur_rx =3D cur_rx;
@@ -2059,21 +2091,21 @@ out:
 }


-static void rtl8139_weird_interrupt (struct net_device *dev,
-				     struct rtl8139_private *tp,
-				     void __iomem *ioaddr,
-				     int status, int link_changed)
-{
-	DPRINTK ("%s: Abnormal interrupt, status %8.8x.\n",
-		 dev->name, status);
-
-	assert (dev !=3D NULL);
-	assert (tp !=3D NULL);
-	assert (ioaddr !=3D NULL);
+static void rtl8139_weird_interrupt(struct net_device *dev,
+				    struct rtl8139_private *tp,
+				    void __iomem *ioaddr,
+				    int status, int link_changed)
+{
+	DPRINTK("%s: Abnormal interrupt, status %8.8x.\n",
+		dev->name, status);
+
+	assert(dev !=3D NULL);
+	assert(tp !=3D NULL);
+	assert(ioaddr !=3D NULL);

 	/* Update the error count. */
-	tp->stats.rx_missed_errors +=3D RTL_R32 (RxMissed);
-	RTL_W32 (RxMissed, 0);
+	tp->stats.rx_missed_errors +=3D RTL_R32(RxMissed);
+	RTL_W32(RxMissed, 0);

 	if ((status & RxUnderrun) && link_changed &&
 	    (tp->drv_flags & HAS_LNK_CHNG)) {
@@ -2090,17 +2122,18 @@ static void rtl8139_weird_interrupt (str
 		tp->stats.rx_fifo_errors++;
 	if (status & PCIErr) {
 		u16 pci_cmd_status;
-		pci_read_config_word (tp->pci_dev, PCI_STATUS, &pci_cmd_status);
-		pci_write_config_word (tp->pci_dev, PCI_STATUS, pci_cmd_status);
+		pci_read_config_word(tp->pci_dev, PCI_STATUS, &pci_cmd_status);
+		pci_write_config_word(tp->pci_dev, PCI_STATUS, pci_cmd_status);

-		printk (KERN_ERR "%s: PCI Bus error %4.4x.\n",
-			dev->name, pci_cmd_status);
+		printk(KERN_ERR "%s: PCI Bus error %4.4x.\n",
+		       dev->name, pci_cmd_status);
 	}
 }

 static int rtl8139_poll(struct napi_struct *napi, int budget)
 {
-	struct rtl8139_private *tp =3D container_of(napi, struct rtl8139_priv=
ate, napi);
+	struct rtl8139_private *tp =3D
+		container_of(napi, struct rtl8139_private, napi);
 	struct net_device *dev =3D tp->dev;
 	void __iomem *ioaddr =3D tp->mmio_addr;
 	int work_done;
@@ -2128,7 +2161,7 @@ static int rtl8139_poll(struct napi_stru

 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
-static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
+static irqreturn_t rtl8139_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev =3D (struct net_device *) dev_instance;
 	struct rtl8139_private *tp =3D netdev_priv(dev);
@@ -2137,8 +2170,8 @@ static irqreturn_t rtl8139_interrupt (in
 	int link_changed =3D 0; /* avoid bogus "uninit" warning */
 	int handled =3D 0;

-	spin_lock (&tp->lock);
-	status =3D RTL_R16 (IntrStatus);
+	spin_lock(&tp->lock);
+	status =3D RTL_R16(IntrStatus);

 	/* shared irq? */
 	if (unlikely((status & rtl8139_intr_mask) =3D=3D 0))
@@ -2152,43 +2185,43 @@ static irqreturn_t rtl8139_interrupt (in

 	/* close possible race's with dev_close */
 	if (unlikely(!netif_running(dev))) {
-		RTL_W16 (IntrMask, 0);
+		RTL_W16(IntrMask, 0);
 		goto out;
 	}

 	/* Acknowledge all of the current interrupt sources ASAP, but
 	   an first get an additional status bit from CSCR. */
 	if (unlikely(status & RxUnderrun))
-		link_changed =3D RTL_R16 (CSCR) & CSCR_LinkChangeBit;
+		link_changed =3D RTL_R16(CSCR) & CSCR_LinkChangeBit;

 	ackstat =3D status & ~(RxAckBits | TxErr);
 	if (ackstat)
-		RTL_W16 (IntrStatus, ackstat);
+		RTL_W16(IntrStatus, ackstat);

 	/* Receive packets are processed by poll routine.
 	   If not running start it now. */
-	if (status & RxAckBits){
+	if (status & RxAckBits) {
 		if (netif_rx_schedule_prep(dev, &tp->napi)) {
-			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
+			RTL_W16_F(IntrMask, rtl8139_norx_intr_mask);
 			__netif_rx_schedule(dev, &tp->napi);
 		}
 	}

 	/* Check uncommon events with one test. */
 	if (unlikely(status & (PCIErr | PCSTimeout | RxUnderrun | RxErr)))
-		rtl8139_weird_interrupt (dev, tp, ioaddr,
-					 status, link_changed);
+		rtl8139_weird_interrupt(dev, tp, ioaddr,
+					status, link_changed);

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

-	DPRINTK ("%s: exiting interrupt, intr_status=3D%#4.4x.\n",
-		 dev->name, RTL_R16 (IntrStatus));
+	DPRINTK("%s: exiting interrupt, intr_status=3D%#4.4x.\n",
+		dev->name, RTL_R16(IntrStatus));
 	return IRQ_RETVAL(handled);
 }

@@ -2205,7 +2238,7 @@ static void rtl8139_poll_controller(stru
 }
 #endif

-static int rtl8139_close (struct net_device *dev)
+static int rtl8139_close(struct net_device *dev)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -2215,27 +2248,28 @@ static int rtl8139_close (struct net_dev
 	napi_disable(&tp->napi);

 	if (netif_msg_ifdown(tp))
-		printk(KERN_DEBUG "%s: Shutting down ethercard, status was 0x%4.4x.\=
n",
-			dev->name, RTL_R16 (IntrStatus));
+		printk(KERN_DEBUG "%s: Shutting down ethercard, "
+		       "status was 0x%4.4x.\n",
+		       dev->name, RTL_R16(IntrStatus));

-	spin_lock_irqsave (&tp->lock, flags);
+	spin_lock_irqsave(&tp->lock, flags);

 	/* Stop the chip's Tx and Rx DMA processes. */
-	RTL_W8 (ChipCmd, 0);
+	RTL_W8(ChipCmd, 0);

 	/* Disable interrupts by clearing the interrupt mask. */
-	RTL_W16 (IntrMask, 0);
+	RTL_W16(IntrMask, 0);

 	/* Update the error counts. */
-	tp->stats.rx_missed_errors +=3D RTL_R32 (RxMissed);
-	RTL_W32 (RxMissed, 0);
+	tp->stats.rx_missed_errors +=3D RTL_R32(RxMissed);
+	RTL_W32(RxMissed, 0);

-	spin_unlock_irqrestore (&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->lock, flags);

-	synchronize_irq (dev->irq);	/* racy, but that's ok here */
-	free_irq (dev->irq, dev);
+	synchronize_irq(dev->irq);	/* racy, but that's ok here */
+	free_irq(dev->irq, dev);

-	rtl8139_tx_clear (tp);
+	rtl8139_tx_clear(tp);

 	dma_free_coherent(&tp->pci_dev->dev, RX_BUF_TOT_LEN,
 			  tp->rx_ring, tp->rx_ring_dma);
@@ -2245,10 +2279,10 @@ static int rtl8139_close (struct net_dev
 	tp->tx_bufs =3D NULL;

 	/* Green! Put the chip in low-power mode. */
-	RTL_W8 (Cfg9346, Cfg9346_Unlock);
+	RTL_W8(Cfg9346, Cfg9346_Unlock);

 	if (rtl_chip_info[tp->chipset].flags & HasHltClk)
-		RTL_W8 (HltClk, 'H');	/* 'R' would leave the clock running. */
+		RTL_W8(HltClk, 'H');	/* 'R' would leave the clock running. */

 	return 0;
 }
@@ -2264,8 +2298,8 @@ static void rtl8139_get_wol(struct net_d

 	spin_lock_irq(&np->lock);
 	if (rtl_chip_info[np->chipset].flags & HasLWake) {
-		u8 cfg3 =3D RTL_R8 (Config3);
-		u8 cfg5 =3D RTL_R8 (Config5);
+		u8 cfg3 =3D RTL_R8(Config3);
+		u8 cfg5 =3D RTL_R8(Config5);

 		wol->supported =3D WAKE_PHY | WAKE_MAGIC
 			| WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;
@@ -2306,16 +2340,16 @@ static int rtl8139_set_wol(struct net_de
 		return -EINVAL;

 	spin_lock_irq(&np->lock);
-	cfg3 =3D RTL_R8 (Config3) & ~(Cfg3_LinkUp | Cfg3_Magic);
+	cfg3 =3D RTL_R8(Config3) & ~(Cfg3_LinkUp | Cfg3_Magic);
 	if (wol->wolopts & WAKE_PHY)
 		cfg3 |=3D Cfg3_LinkUp;
 	if (wol->wolopts & WAKE_MAGIC)
 		cfg3 |=3D Cfg3_Magic;
-	RTL_W8 (Cfg9346, Cfg9346_Unlock);
-	RTL_W8 (Config3, cfg3);
-	RTL_W8 (Cfg9346, Cfg9346_Lock);
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W8(Config3, cfg3);
+	RTL_W8(Cfg9346, Cfg9346_Lock);

-	cfg5 =3D RTL_R8 (Config5) & ~(Cfg5_UWF | Cfg5_MWF | Cfg5_BWF);
+	cfg5 =3D RTL_R8(Config5) & ~(Cfg5_UWF | Cfg5_MWF | Cfg5_BWF);
 	/* (KON)FIXME: These are untested.  We may have to set the
 	   CRC0, Wakeup0 and LSBCRC0 registers too, but I have no
 	   documentation.  */
@@ -2325,13 +2359,14 @@ static int rtl8139_set_wol(struct net_de
 		cfg5 |=3D Cfg5_MWF;
 	if (wol->wolopts & WAKE_BCAST)
 		cfg5 |=3D Cfg5_BWF;
-	RTL_W8 (Config5, cfg5);	/* need not unlock via Cfg9346 */
+	RTL_W8(Config5, cfg5);	/* need not unlock via Cfg9346 */
 	spin_unlock_irq(&np->lock);

 	return 0;
 }

-static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool=
_drvinfo *info)
+static void rtl8139_get_drvinfo(struct net_device *dev,
+	struct ethtool_drvinfo *info)
 {
 	struct rtl8139_private *np =3D netdev_priv(dev);
 	strcpy(info->driver, DRV_NAME);
@@ -2394,7 +2429,8 @@ static int rtl8139_get_regs_len(struct n
 	return np->regs_len;
 }

-static void rtl8139_get_regs(struct net_device *dev, struct ethtool_re=
gs *regs, void *regbuf)
+static void rtl8139_get_regs(struct net_device *dev, struct ethtool_re=
gs *regs,
+	void *regbuf)
 {
 	struct rtl8139_private *np =3D netdev_priv(dev);

@@ -2416,7 +2452,8 @@ static int rtl8139_get_sset_count(struct
 	}
 }

-static void rtl8139_get_ethtool_stats(struct net_device *dev, struct e=
thtool_stats *stats, u64 *data)
+static void rtl8139_get_ethtool_stats(struct net_device *dev,
+	struct ethtool_stats *stats, u64 *data)
 {
 	struct rtl8139_private *np =3D netdev_priv(dev);

@@ -2464,17 +2501,17 @@ static int netdev_ioctl(struct net_devic
 }


-static struct net_device_stats *rtl8139_get_stats (struct net_device *=
dev)
+static struct net_device_stats *rtl8139_get_stats(struct net_device *d=
ev)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
 	unsigned long flags;

 	if (netif_running(dev)) {
-		spin_lock_irqsave (&tp->lock, flags);
-		tp->stats.rx_missed_errors +=3D RTL_R32 (RxMissed);
-		RTL_W32 (RxMissed, 0);
-		spin_unlock_irqrestore (&tp->lock, flags);
+		spin_lock_irqsave(&tp->lock, flags);
+		tp->stats.rx_missed_errors +=3D RTL_R32(RxMissed);
+		RTL_W32(RxMissed, 0);
+		spin_unlock_irqrestore(&tp->lock, flags);
 	}

 	return &tp->stats;
@@ -2483,7 +2520,7 @@ static struct net_device_stats *rtl8139_
 /* Set or clear the multicast filter for this adaptor.
    This routine is not state sensitive and need not be SMP locked. */

-static void __set_rx_mode (struct net_device *dev)
+static void __set_rx_mode(struct net_device *dev)
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -2491,8 +2528,8 @@ static void __set_rx_mode (struct net_de
 	int i, rx_mode;
 	u32 tmp;

-	DPRINTK ("%s:   rtl8139_set_rx_mode(%4.4x) done -- Rx config %8.8lx.\=
n",
-			dev->name, dev->flags, RTL_R32 (RxConfig));
+	DPRINTK("%s:   rtl8139_set_rx_mode(%4.4x) done -- Rx config %8.8lx.\n=
",
+			dev->name, dev->flags, RTL_R32(RxConfig));

 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
@@ -2511,7 +2548,8 @@ static void __set_rx_mode (struct net_de
 		mc_filter[1] =3D mc_filter[0] =3D 0;
 		for (i =3D 0, mclist =3D dev->mc_list; mclist && i < dev->mc_count;
 		     i++, mclist =3D mclist->next) {
-			int bit_nr =3D ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+			int bit_nr =3D
+				ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;

 			mc_filter[bit_nr >> 5] |=3D 1 << (bit_nr & 31);
 			rx_mode |=3D AcceptMulticast;
@@ -2521,68 +2559,68 @@ static void __set_rx_mode (struct net_de
 	/* We can safely update without stopping the chip. */
 	tmp =3D rtl8139_rx_config | rx_mode;
 	if (tp->rx_config !=3D tmp) {
-		RTL_W32_F (RxConfig, tmp);
+		RTL_W32_F(RxConfig, tmp);
 		tp->rx_config =3D tmp;
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
 	struct rtl8139_private *tp =3D netdev_priv(dev);

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
-	struct net_device *dev =3D pci_get_drvdata (pdev);
+	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct rtl8139_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
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
-	tp->stats.rx_missed_errors +=3D RTL_R32 (RxMissed);
-	RTL_W32 (RxMissed, 0);
+	tp->stats.rx_missed_errors +=3D RTL_R32(RxMissed);
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
-	struct net_device *dev =3D pci_get_drvdata (pdev);
+	struct net_device *dev =3D pci_get_drvdata(pdev);

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

@@ -2601,22 +2639,22 @@ static struct pci_driver rtl8139_pci_dri
 };


-static int __init rtl8139_init_module (void)
+static int __init rtl8139_init_module(void)
 {
 	/* when we're a module, we always print a version message,
 	 * even if no 8139 board is found.
 	 */
 #ifdef MODULE
-	printk (KERN_INFO RTL8139_DRIVER_NAME "\n");
+	printk(KERN_INFO RTL8139_DRIVER_NAME "\n");
 #endif

 	return pci_register_driver(&rtl8139_pci_driver);
 }


-static void __exit rtl8139_cleanup_module (void)
+static void __exit rtl8139_cleanup_module(void)
 {
-	pci_unregister_driver (&rtl8139_pci_driver);
+	pci_unregister_driver(&rtl8139_pci_driver);
 }
