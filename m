From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Wed, 09 Mar 2005 12:22:02 -0500
Message-ID: <422F30BA.5010809@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000406070700040303060608"
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000406070700040303060608
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Janitorial and viro-authored stuff.

--------------000406070700040303060608
Content-Type: text/plain;
 name="changelog.txt"
Content-Disposition: inline;
 filename="changelog.txt"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j29HNl5S020815

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 include/linux/dp83840.h                  |   41 --------
 drivers/net/3c503.c                      |   67 +++++++------
 drivers/net/3c509.c                      |    4=20
 drivers/net/3c515.c                      |   32 ++----
 drivers/net/3c527.c                      |    2=20
 drivers/net/amd8111e.c                   |    4=20
 drivers/net/arcnet/arc-rawmode.c         |    4=20
 drivers/net/arcnet/arc-rimi.c            |   14 +-
 drivers/net/arcnet/arcnet.c              |   30 ++---
 drivers/net/arcnet/com20020.c            |    6 -
 drivers/net/arcnet/com90io.c             |    4=20
 drivers/net/arcnet/com90xx.c             |    8 -
 drivers/net/arcnet/rfc1051.c             |    8 -
 drivers/net/arcnet/rfc1201.c             |   12 +-
 drivers/net/bonding/bond_3ad.c           |    2=20
 drivers/net/bonding/bond_3ad.h           |    1=20
 drivers/net/bonding/bond_alb.c           |    4=20
 drivers/net/cs89x0.c                     |    4=20
 drivers/net/depca.c                      |    4=20
 drivers/net/dgrs.c                       |    6 -
 drivers/net/eepro100.c                   |   10 -
 drivers/net/es3210.c                     |   32 +++---
 drivers/net/ethertap.c                   |    4=20
 drivers/net/ewrk3.c                      |   87 +++++++++--------
 drivers/net/ioc3-eth.c                   |    1=20
 drivers/net/irda/act200l-sir.c           |    3=20
 drivers/net/irda/irtty-sir.c             |    4=20
 drivers/net/irda/ma600-sir.c             |   12 --
 drivers/net/irda/sir_dev.c               |    4=20
 drivers/net/irda/tekram-sir.c            |    3=20
 drivers/net/loopback.c                   |    2=20
 drivers/net/lp486e.c                     |    8 -
 drivers/net/ni65.c                       |    3=20
 drivers/net/ns83820.c                    |    3=20
 drivers/net/pcmcia/ibmtr_cs.c            |    7 -
 drivers/net/pcmcia/xirc2ps_cs.c          |   23 +---
 drivers/net/ppp_deflate.c                |    4=20
 drivers/net/ppp_generic.c                |    2=20
 drivers/net/pppoe.c                      |    2=20
 drivers/net/s2io.c                       |   75 ++++++--------
 drivers/net/s2io.h                       |    8 -
 drivers/net/sb1000.c                     |   28 ++---
 drivers/net/shaper.c                     |    2=20
 drivers/net/slhc.c                       |   27 -----
 drivers/net/smc-mca.c                    |   37 ++++---
 drivers/net/smc-ultra.c                  |   34 +++---
 drivers/net/smc-ultra32.c                |   30 +++--
 drivers/net/tokenring/ibmtr.c            |  158 ++++++++++++++----------=
-------
 drivers/net/tulip/interrupt.c            |    2=20
 drivers/net/tun.c                        |    4=20
 drivers/net/via-rhine.c                  |    2=20
 drivers/net/via-velocity.c               |    2=20
 drivers/net/wan/cosa.c                   |    7 -
 drivers/net/wd.c                         |   36 ++++---
 drivers/net/wireless/airo.c              |   25 +---
 drivers/net/wireless/prism54/isl_ioctl.c |    2=20
 drivers/net/wireless/ray_cs.c            |    5=20
 drivers/net/wireless/strip.c             |   16 +--
 include/linux/ibmtr.h                    |   15 +-
 include/net/slhc_vj.h                    |    3=20
 60 files changed, 454 insertions(+), 535 deletions(-)

through these ChangeSets:

Adrian Bunk:
  o drivers/net/via-rhine.c: make a variable static const
  o drivers/net/sb1000.c: make some variables static
  o drivers/net/lp486e.c: make some code static
  o drivers/net/3c509.c: make 2 structs static
  o drivers/net/3c527.c: make a struct static
  o drivers/net/amd8111e.c: make 2 functions static
  o drivers/net/loopback.c: make a function static
  o drivers/net/ethertap.c: make 2 functions static
  o drivers/net/dgrs.c: make 3 functions static
  o drivers/net/depca.c: make 2 structs static
  o drivers/net/bonding/: make 3 functions static
  o drivers/net/s2io.c: cleanups
  o drivers/net/pppoe.c: make a struct static
  o drivers/net/ppp_deflate.c: make 2 structs static
  o drivers/net/via-velocity.c: make a function static
  o drivers/net/tun.c: make 2 functions static
  o drivers/net/tulip/interrupt.c: make a variable static
  o drivers/net/shaper.c: make a variable static
  o drivers/net/slhc.c: remove 2 functions
  o remove dp83840.h

Alexander Viro:
  o 3c503 (iomem + isa-ectomy)
  o ibmtr 2/2: ibmtr annotations - the rest
  o ibmtr 1/2: iomem annotations - trivial part
  o es3210 iomem annotions and isa-ectomy
  o ewrk3 iomem annotations + isa-ectomy
  o wd iomem annotations + isa-ectomy
  o smc-ultra32 iomem annotations + isa-ectomy
  o smc-ultra iomem annotations + isa-ectomy
  o smc-mca iomem annotations and isa-ectomy

Domen Puncer:
  o net/ewrk3: replace schedule_timeout() with msleep_interruptible()
  o net/tekram-sir: replace schedule_timeout() with msleep()
  o net/ns83820: replace schedule_timeout() with msleep()
  o net/ni65: replace schedule_timeout() with msleep()
  o net/sir_dev: replace schedule_timeout() with msleep()
  o net/xirc2ps_cs: replace Wait() with msleep()
  o net/ma600-sir: replace schedule_timeout() with msleep()
  o net/irtty-sir: replace schedule_timeout() with msleep()
  o net/act2001-sir: replace schedule_timeout() with msleep()
  o arcnet: remove casts

Fran=E7ois Romieu:
  o strip: use of netdev_priv

Nishanth Aravamudan:
  o net/cosa: replace schedule_timeout() with msleep()
  o net/airo: replace schedule_timeout() with msleep()/ssleep()
  o net/cs89x0: replace schedule_timeout() with msleep()

Paul Mackerras:
  o remove bogus exports in ppp

Pavel Machek:
  o eepro100 kill obsolete ifdefs

Randy Dunlap:
  o sb1000: reduce ioctl stack usage
  o ray_cs: reduce stack usage (sockaddr)
  o prism54: use NULL for pointer

Steffen Klassert:
  o Add MODULE_VERSION to the 3c515 driver
  o Use netdev_priv in the 3c515 driver


--------------000406070700040303060608
Content-Type: text/plain;
 name="patch"
Content-Disposition: inline;
 filename="patch"
Content-Transfer-Encoding: 7bit

diff -Nru a/drivers/net/3c503.c b/drivers/net/3c503.c
--- a/drivers/net/3c503.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/3c503.c	2005-03-09 12:20:51 -05:00
@@ -103,8 +103,15 @@
 	return -ENXIO;
 
     for (addr = addrs; *addr; addr++) {
-	unsigned base_bits = isa_readb(*addr);
-	int i = ffs(base_bits) - 1;
+	void __iomem *p = ioremap(*addr, 1);
+	unsigned base_bits;
+	int i;
+
+	if (!p)
+		continue;
+	base_bits = readb(p);
+	iounmap(p);
+	i = ffs(base_bits) - 1;
 	if (i == -1 || base_bits != (1 << i))
 	    continue;
 	if (el2_probe1(dev, netcard_portlist[i]) == 0)
@@ -145,6 +152,8 @@
 {
 	/* NB: el2_close() handles free_irq */
 	release_region(dev->base_addr, EL2_IO_EXTENT);
+	if (ei_status.mem)
+		iounmap(ei_status.mem);
 }
 
 #ifndef MODULE
@@ -262,42 +271,46 @@
     if ((membase_reg & 0xf0) == 0) {
 	dev->mem_start = 0;
 	ei_status.name = "3c503-PIO";
+	ei_status.mem = NULL;
     } else {
 	dev->mem_start = ((membase_reg & 0xc0) ? 0xD8000 : 0xC8000) +
 	    ((membase_reg & 0xA0) ? 0x4000 : 0);
-
 #define EL2_MEMSIZE (EL2_MB1_STOP_PG - EL2_MB1_START_PG)*256
+	ei_status.mem = ioremap(dev->mem_start, EL2_MEMSIZE);
+
 #ifdef EL2MEMTEST
 	/* This has never found an error, but someone might care.
 	   Note that it only tests the 2nd 8kB on 16kB 3c503/16
 	   cards between card addr. 0x2000 and 0x3fff. */
 	{			/* Check the card's memory. */
-	    unsigned long mem_base = dev->mem_start;
+	    void __iomem *mem_base = ei_status.mem;
 	    unsigned int test_val = 0xbbadf00d;
-	    isa_writel(0xba5eba5e, mem_base);
+	    writel(0xba5eba5e, mem_base);
 	    for (i = sizeof(test_val); i < EL2_MEMSIZE; i+=sizeof(test_val)) {
-		isa_writel(test_val, mem_base + i);
-		if (isa_readl(mem_base) != 0xba5eba5e
-		    || isa_readl(mem_base + i) != test_val) {
+		writel(test_val, mem_base + i);
+		if (readl(mem_base) != 0xba5eba5e
+		    || readl(mem_base + i) != test_val) {
 		    printk("3c503: memory failure or memory address conflict.\n");
 		    dev->mem_start = 0;
 		    ei_status.name = "3c503-PIO";
+		    iounmap(mem_base);
+		    ei_status.mem = NULL;
 		    break;
 		}
 		test_val += 0x55555555;
-		isa_writel(0, mem_base + i);
+		writel(0, mem_base + i);
 	    }
 	}
 #endif  /* EL2MEMTEST */
 
 	if (dev->mem_start)
-		dev->mem_end = ei_status.rmem_end = dev->mem_start + EL2_MEMSIZE;
+		dev->mem_end = dev->mem_start + EL2_MEMSIZE;
 
 	if (wordlength) {	/* No Tx pages to skip over to get to Rx */
-		ei_status.rmem_start = dev->mem_start;
+		ei_status.priv = 0;
 		ei_status.name = "3c503/16";
 	} else {
-		ei_status.rmem_start = TX_PAGES*256 + dev->mem_start;
+		ei_status.priv = TX_PAGES * 256;
 		ei_status.name = "3c503";
 	}
     }
@@ -471,16 +484,16 @@
     unsigned short int *wrd;
     int boguscount;		/* timeout counter */
     unsigned short word;	/* temporary for better machine code */
+    void __iomem *base = ei_status.mem;
 
     if (ei_status.word16)      /* Tx packets go into bank 0 on EL2/16 card */
 	outb(EGACFR_RSEL|EGACFR_TCM, E33G_GACFR);
     else
 	outb(EGACFR_NORM, E33G_GACFR);
 
-    if (dev->mem_start) {	/* Shared memory transfer */
-	unsigned long dest_addr = dev->mem_start +
-	    ((start_page - ei_status.tx_start_page) << 8);
-	isa_memcpy_toio(dest_addr, buf, count);
+    if (base) {	/* Shared memory transfer */
+	memcpy_toio(base + ((start_page - ei_status.tx_start_page) << 8),
+			buf, count);
 	outb(EGACFR_NORM, E33G_GACFR);	/* Back to bank1 in case on bank0 */
 	return;
     }
@@ -541,11 +554,12 @@
 el2_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
 {
     int boguscount;
-    unsigned long hdr_start = dev->mem_start + ((ring_page - EL2_MB1_START_PG)<<8);
+    void __iomem *base = ei_status.mem;
     unsigned short word;
 
-    if (dev->mem_start) {       /* Use the shared memory. */
-	isa_memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
+    if (base) {       /* Use the shared memory. */
+	void __iomem *hdr_start = base + ((ring_page - EL2_MB1_START_PG)<<8);
+	memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
 	hdr->count = le16_to_cpu(hdr->count);
 	return;
     }
@@ -581,23 +595,22 @@
 el2_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring_offset)
 {
     int boguscount = 0;
+    void __iomem *base = ei_status.mem;
     unsigned short int *buf;
     unsigned short word;
 
-    int end_of_ring = ei_status.rmem_end;
-
     /* Maybe enable shared memory just be to be safe... nahh.*/
-    if (dev->mem_start) {	/* Use the shared memory. */
+    if (base) {	/* Use the shared memory. */
 	ring_offset -= (EL2_MB1_START_PG<<8);
-	if (dev->mem_start + ring_offset + count > end_of_ring) {
+	if (ring_offset + count > EL2_MEMSIZE) {
 	    /* We must wrap the input move. */
-	    int semi_count = end_of_ring - (dev->mem_start + ring_offset);
-	    isa_memcpy_fromio(skb->data, dev->mem_start + ring_offset, semi_count);
+	    int semi_count = EL2_MEMSIZE - ring_offset;
+	    memcpy_fromio(skb->data, base + ring_offset, semi_count);
 	    count -= semi_count;
-	    isa_memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
+	    memcpy_fromio(skb->data + semi_count, base + ei_status.priv, count);
 	} else {
 		/* Packet is in one chunk -- we can copy + cksum. */
-		isa_eth_io_copy_and_sum(skb, dev->mem_start + ring_offset, count, 0);
+		eth_io_copy_and_sum(skb, base + ring_offset, count, 0);
 	}
 	return;
     }
diff -Nru a/drivers/net/3c509.c b/drivers/net/3c509.c
--- a/drivers/net/3c509.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/3c509.c	2005-03-09 12:20:51 -05:00
@@ -214,7 +214,7 @@
 #endif
 
 #ifdef CONFIG_EISA
-struct eisa_device_id el3_eisa_ids[] = {
+static struct eisa_device_id el3_eisa_ids[] = {
 		{ "TCM5092" },
 		{ "TCM5093" },
 		{ "" }
@@ -222,7 +222,7 @@
 
 static int el3_eisa_probe (struct device *device);
 
-struct eisa_driver el3_eisa_driver = {
+static struct eisa_driver el3_eisa_driver = {
 		.id_table = el3_eisa_ids,
 		.driver   = {
 				.name    = "3c509",
diff -Nru a/drivers/net/3c515.c b/drivers/net/3c515.c
--- a/drivers/net/3c515.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/3c515.c	2005-03-09 12:20:51 -05:00
@@ -86,6 +86,7 @@
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("3Com 3c515 Corkscrew driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 /* "Knobs" for adjusting internal parameters. */
 /* Put out somewhat more debugging messages. (0 - no msg, 1 minimal msgs). */
@@ -472,7 +473,7 @@
 
 static void cleanup_card(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	list_del_init(&vp->list);
 	if (dev->dma)
 		free_dma(dev->dma);
@@ -570,7 +571,7 @@
 static void corkscrew_setup(struct net_device *dev, int ioaddr,
 			    struct pnp_dev *idev, int card_number)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	unsigned int eeprom[0x40], checksum = 0;	/* EEPROM contents */
 	int i;
 	int irq;
@@ -696,8 +697,7 @@
 static int corkscrew_open(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	union wn3_config config;
 	int i;
 
@@ -862,7 +862,7 @@
 {
 #ifdef AUTOMEDIA
 	struct net_device *dev = (struct net_device *) data;
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 	int ok = 0;
@@ -954,8 +954,7 @@
 static void corkscrew_timeout(struct net_device *dev)
 {
 	int i;
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	printk(KERN_WARNING
@@ -994,8 +993,7 @@
 static int corkscrew_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Block a timer-based transmit from overlapping. */
@@ -1123,14 +1121,13 @@
 {
 	/* Use the now-standard shared IRQ implementation. */
 	struct net_device *dev = dev_id;
-	struct corkscrew_private *lp;
+	struct corkscrew_private *lp = netdev_priv(dev);
 	int ioaddr, status;
 	int latency;
 	int i = max_interrupt_work;
 
 	ioaddr = dev->base_addr;
 	latency = inb(ioaddr + Timer);
-	lp = (struct corkscrew_private *) dev->priv;
 
 	spin_lock(&lp->lock);
 	
@@ -1262,7 +1259,7 @@
 
 static int corkscrew_rx(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 	short rx_status;
@@ -1329,8 +1326,7 @@
 
 static int boomerang_rx(struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int entry = vp->cur_rx % RX_RING_SIZE;
 	int ioaddr = dev->base_addr;
 	int rx_status;
@@ -1420,8 +1416,7 @@
 
 static int corkscrew_close(struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 
@@ -1476,7 +1471,7 @@
 
 static struct net_device_stats *corkscrew_get_stats(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	unsigned long flags;
 
 	if (netif_running(dev)) {
@@ -1496,8 +1491,7 @@
 	*/
 static void update_stats(int ioaddr, struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 
 	/* Unlike the 3c5x9 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
diff -Nru a/drivers/net/3c527.c b/drivers/net/3c527.c
--- a/drivers/net/3c527.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/3c527.c	2005-03-09 12:20:51 -05:00
@@ -197,7 +197,7 @@
 	char		*name;
 };
 
-const struct mca_adapters_t mc32_adapters[] = {
+static const struct mca_adapters_t mc32_adapters[] = {
 	{ 0x0041, "3COM EtherLink MC/32" },
 	{ 0x8EF5, "IBM High Performance Lan Adapter" },
 	{ 0x0000, NULL }
diff -Nru a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
--- a/drivers/net/amd8111e.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/amd8111e.c	2005-03-09 12:20:51 -05:00
@@ -1489,7 +1489,7 @@
 amd8111e crc generator implementation is different from the kernel
 ether_crc() function.
 */
-int amd8111e_ether_crc(int len, char* mac_addr)
+static int amd8111e_ether_crc(int len, char* mac_addr)
 {
 	int i,byte;
 	unsigned char octet;
@@ -1717,7 +1717,7 @@
 /* 
 This function changes the mtu of the device. It restarts the device  to initialize the descriptor with new receive buffers.
 */  
-int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
+static int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int err;
diff -Nru a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
--- a/drivers/net/arcnet/arc-rawmode.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/arc-rawmode.c	2005-03-09 12:20:51 -05:00
@@ -87,7 +87,7 @@
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -168,7 +168,7 @@
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff -Nru a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
--- a/drivers/net/arcnet/arc-rimi.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/arc-rimi.c	2005-03-09 12:20:51 -05:00
@@ -230,7 +230,7 @@
  */
 static int arcrimi_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
@@ -251,7 +251,7 @@
 
 static void arcrimi_setmask(struct net_device *dev, int mask)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	AINTMASK(mask);
@@ -259,7 +259,7 @@
 
 static int arcrimi_status(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	return ASTATUS();
@@ -267,7 +267,7 @@
 
 static void arcrimi_command(struct net_device *dev, int cmd)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	ACOMMAND(cmd);
@@ -276,7 +276,7 @@
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -285,7 +285,7 @@
 static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -331,7 +331,7 @@
 static void __exit arc_rimi_exit(void)
 {
 	struct net_device *dev = my_dev;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	unregister_netdev(dev);
 	iounmap(lp->mem_start);
diff -Nru a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
--- a/drivers/net/arcnet/arcnet.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/arcnet.c	2005-03-09 12:20:51 -05:00
@@ -181,7 +181,7 @@
 void arcnet_dump_packet(struct net_device *dev, int bufnum, char *desc,
 			int take_arcnet_lock)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int i, length;
 	unsigned long flags = 0;
 	static uint8_t buf[512];
@@ -244,7 +244,7 @@
  */
 static void release_arcbuf(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int i;
 
 	lp->buf_queue[lp->first_free_buf++] = bufnum;
@@ -266,7 +266,7 @@
  */
 static int get_arcbuf(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int buf = -1, i;
 
 	if (!atomic_dec_and_test(&lp->buf_lock)) {
@@ -367,7 +367,7 @@
  */
 static int arcnet_open(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int count, newmtu, error;
 
 	BUGMSG(D_INIT,"opened.");
@@ -467,7 +467,7 @@
 /* The inverse routine to arcnet_open - shuts down the card. */
 static int arcnet_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	netif_stop_queue(dev);
 
@@ -488,7 +488,7 @@
 			 unsigned short type, void *daddr, void *saddr,
 			 unsigned len)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	uint8_t _daddr, proto_num;
 	struct ArcProto *proto;
 
@@ -546,7 +546,7 @@
 static int arcnet_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int status = 0;		/* default is failure */
 	unsigned short type;
 	uint8_t daddr=0;
@@ -591,7 +591,7 @@
 /* Called by the kernel in order to transmit a packet. */
 static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct archdr *pkt;
 	struct arc_rfc1201 *soft;
 	struct ArcProto *proto;
@@ -674,7 +674,7 @@
  */
 static int go_tx(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	BUGMSG(D_DURING, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
 	       ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
@@ -705,7 +705,7 @@
 static void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int status = ASTATUS();
 	char *msg;
 
@@ -754,7 +754,7 @@
 
 	BUGMSG(D_DURING, "in arcnet_interrupt\n");
 	
-	lp = (struct arcnet_local *) dev->priv;
+	lp = dev->priv;
 	if (!lp)
 		BUG();
 		
@@ -989,7 +989,7 @@
  */
 void arcnet_rx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct archdr pkt;
 	struct arc_rfc1201 *soft;
 	int length, ofs;
@@ -1053,7 +1053,7 @@
  */
 static struct net_device_stats *arcnet_get_stats(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	return &lp->stats;
 }
 
@@ -1070,7 +1070,7 @@
 static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 			     unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	BUGMSG(D_PROTO,
 	       "tx: can't build header for encap %02Xh; load a protocol driver.\n",
@@ -1085,7 +1085,7 @@
 static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 			   int length, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct arc_hardware newpkt;
 
 	BUGMSG(D_PROTO, "tx: no encap for this host; load a protocol driver.\n");
diff -Nru a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
--- a/drivers/net/arcnet/com20020.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/com20020.c	2005-03-09 12:20:51 -05:00
@@ -159,7 +159,7 @@
 
 	/* Initialize the rest of the device structure. */
 
-	lp = (struct arcnet_local *) dev->priv;
+	lp = dev->priv;
 
 	lp->hw.owner = THIS_MODULE;
 	lp->hw.command = com20020_command;
@@ -233,7 +233,7 @@
  */
 static int com20020_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	u_int ioaddr = dev->base_addr;
 	u_char inbyte;
 
@@ -300,7 +300,7 @@
 
 static void com20020_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	/* disable transmitter */
diff -Nru a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
--- a/drivers/net/arcnet/com90io.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/com90io.c	2005-03-09 12:20:51 -05:00
@@ -248,7 +248,7 @@
 		return -EBUSY;
 	}
 
-	lp = (struct arcnet_local *) (dev->priv);
+	lp = dev->priv;
 	lp->card_name = "COM90xx I/O";
 	lp->hw.command = com90io_command;
 	lp->hw.status = com90io_status;
@@ -290,7 +290,7 @@
  */
 static int com90io_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
diff -Nru a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
--- a/drivers/net/arcnet/com90xx.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/com90xx.c	2005-03-09 12:20:51 -05:00
@@ -529,7 +529,7 @@
  */
 int com90xx_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", ASTATUS());
@@ -565,7 +565,7 @@
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -574,7 +574,7 @@
 static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -600,7 +600,7 @@
 
 	for (count = 0; count < numcards; count++) {
 		dev = cards[count];
-		lp = (struct arcnet_local *) dev->priv;
+		lp = dev->priv;
 
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
diff -Nru a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
--- a/drivers/net/arcnet/rfc1051.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/rfc1051.c	2005-03-09 12:20:51 -05:00
@@ -88,7 +88,7 @@
  */
 static unsigned short type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
@@ -125,7 +125,7 @@
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -169,7 +169,7 @@
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
@@ -220,7 +220,7 @@
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff -Nru a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
--- a/drivers/net/arcnet/rfc1201.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/arcnet/rfc1201.c	2005-03-09 12:20:51 -05:00
@@ -92,7 +92,7 @@
 {
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
@@ -134,7 +134,7 @@
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	struct arc_rfc1201 *soft = &pkthdr->soft.rfc1201;
@@ -376,7 +376,7 @@
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
@@ -443,7 +443,7 @@
 static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 		     struct arc_rfc1201 *soft, int softlen, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int ofs;
 
 	/* assume length <= XMTU: someone should have handled that by now. */
@@ -476,7 +476,7 @@
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	const int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	struct Outgoing *out;
 
@@ -511,7 +511,7 @@
 
 static int continue_tx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct Outgoing *out = &lp->outgoing;
 	struct arc_hardware *hard = &out->pkt->hard;
 	struct arc_rfc1201 *soft = &out->pkt->soft.rfc1201, *newsoft;
diff -Nru a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
--- a/drivers/net/bonding/bond_3ad.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/bonding/bond_3ad.c	2005-03-09 12:20:51 -05:00
@@ -2175,7 +2175,7 @@
  * received frames (loopback). Since only the payload is given to this
  * function, it check for loopback.
  */
-void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u16 length)
+static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u16 length)
 {
 	struct port *port;
 
diff -Nru a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
--- a/drivers/net/bonding/bond_3ad.h	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/bonding/bond_3ad.h	2005-03-09 12:20:51 -05:00
@@ -290,7 +290,6 @@
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct bonding *bond);
-void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u16 length);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
diff -Nru a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/bonding/bond_alb.c	2005-03-09 12:20:51 -05:00
@@ -275,7 +275,7 @@
 }
 
 /* Caller must hold bond lock for read */
-struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
+static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct tlb_client_info *hash_table;
@@ -627,7 +627,7 @@
 }
 
 /* Caller must hold both bond and ptr locks for read */
-struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bond)
+static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct arp_pkt *arp = (struct arp_pkt *)skb->nh.raw;
diff -Nru a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
--- a/drivers/net/cs89x0.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/cs89x0.c	2005-03-09 12:20:51 -05:00
@@ -136,6 +136,7 @@
 #include <linux/string.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
+#include <linux/delay.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -909,8 +910,7 @@
 	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
 
 	/* wait 30 ms */
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(30*HZ/1000);
+	msleep(30);
 
 #ifndef CONFIG_ARCH_IXDP2X01
 	if (lp->chip_type != CS8900) {
diff -Nru a/drivers/net/depca.c b/drivers/net/depca.c
--- a/drivers/net/depca.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/depca.c	2005-03-09 12:20:51 -05:00
@@ -342,14 +342,14 @@
 static int depca_device_remove (struct device *device);
 
 #ifdef CONFIG_EISA
-struct eisa_device_id depca_eisa_ids[] = {
+static struct eisa_device_id depca_eisa_ids[] = {
 	{ "DEC4220", de422 },
 	{ "" }
 };
 
 static int depca_eisa_probe  (struct device *device);
 
-struct eisa_driver depca_eisa_driver = {
+static struct eisa_driver depca_eisa_driver = {
 	.id_table = depca_eisa_ids,
 	.driver   = {
 		.name    = depca_string,
diff -Nru a/drivers/net/dgrs.c b/drivers/net/dgrs.c
--- a/drivers/net/dgrs.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/dgrs.c	2005-03-09 12:20:51 -05:00
@@ -454,7 +454,7 @@
  *	up some state variables to let the host CPU continue doing
  *	other things until a DMA completion interrupt comes along.
  */
-void
+static void
 dgrs_rcv_frame(
 	struct net_device	*dev0,
 	DGRS_PRIV	*priv0,
@@ -1150,7 +1150,7 @@
 /*
  *	Probe (init) a board
  */
-int __init 
+static int __init 
 dgrs_probe1(struct net_device *dev)
 {
 	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
@@ -1228,7 +1228,7 @@
        	return rc;
 }
 
-int __init 
+static int __init 
 dgrs_initclone(struct net_device *dev)
 {
 	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
diff -Nru a/drivers/net/eepro100.c b/drivers/net/eepro100.c
--- a/drivers/net/eepro100.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/eepro100.c	2005-03-09 12:20:51 -05:00
@@ -152,16 +152,6 @@
 
 #define RUN_AT(x) (jiffies + (x))
 
-/* ACPI power states don't universally work (yet) */
-#ifndef CONFIG_PM
-#undef pci_set_power_state
-#define pci_set_power_state null_set_power_state
-static inline int null_set_power_state(struct pci_dev *dev, int state)
-{
-	return 0;
-}
-#endif /* CONFIG_PM */
-
 #define netdevice_start(dev)
 #define netdevice_stop(dev)
 #define netif_set_tx_timeout(dev, tf, tm) \
diff -Nru a/drivers/net/es3210.c b/drivers/net/es3210.c
--- a/drivers/net/es3210.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/es3210.c	2005-03-09 12:20:51 -05:00
@@ -159,6 +159,7 @@
 {
 	free_irq(dev->irq, dev);
 	release_region(dev->base_addr, ES_IO_EXTENT);
+	iounmap(ei_status.mem);
 }
 
 #ifndef MODULE
@@ -271,9 +272,14 @@
 		printk(" assigning ");
 	}
 
-	dev->mem_end = ei_status.rmem_end = dev->mem_start
-		+ (ES_STOP_PG - ES_START_PG)*256;
-	ei_status.rmem_start = dev->mem_start + TX_PAGES*256;
+	ei_status.mem = ioremap(dev->mem_start, (ES_STOP_PG - ES_START_PG)*256);
+	if (!ei_status.mem) {
+		printk("ioremap failed - giving up\n");
+		retval = -ENXIO;
+		goto out1;
+	}
+
+	dev->mem_end = dev->mem_start + (ES_STOP_PG - ES_START_PG)*256;
 
 	printk("mem %#lx-%#lx\n", dev->mem_start, dev->mem_end-1);
 
@@ -353,8 +359,8 @@
 static void
 es_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
 {
-	unsigned long hdr_start = dev->mem_start + ((ring_page - ES_START_PG)<<8);
-	isa_memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
+	void __iomem *hdr_start = ei_status.mem + ((ring_page - ES_START_PG)<<8);
+	memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
 	hdr->count = (hdr->count + 3) & ~3;     /* Round up allocation. */
 }
 
@@ -367,27 +373,27 @@
 static void es_block_input(struct net_device *dev, int count, struct sk_buff *skb,
 						  int ring_offset)
 {
-	unsigned long xfer_start = dev->mem_start + ring_offset - (ES_START_PG<<8);
+	void __iomem *xfer_start = ei_status.mem + ring_offset - ES_START_PG*256;
 
-	if (xfer_start + count > ei_status.rmem_end) {
+	if (ring_offset + count > ES_STOP_PG*256) {
 		/* Packet wraps over end of ring buffer. */
-		int semi_count = ei_status.rmem_end - xfer_start;
-		isa_memcpy_fromio(skb->data, xfer_start, semi_count);
+		int semi_count = ES_STOP_PG*256 - ring_offset;
+		memcpy_fromio(skb->data, xfer_start, semi_count);
 		count -= semi_count;
-		isa_memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
+		memcpy_fromio(skb->data + semi_count, ei_status.mem, count);
 	} else {
 		/* Packet is in one chunk. */
-		isa_eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		eth_io_copy_and_sum(skb, xfer_start, count, 0);
 	}
 }
 
 static void es_block_output(struct net_device *dev, int count,
 				const unsigned char *buf, int start_page)
 {
-	unsigned long shmem = dev->mem_start + ((start_page - ES_START_PG)<<8);
+	void __iomem *shmem = ei_status.mem + ((start_page - ES_START_PG)<<8);
 
 	count = (count + 3) & ~3;     /* Round up to doubleword */
-	isa_memcpy_toio(shmem, buf, count);
+	memcpy_toio(shmem, buf, count);
 }
 
 static int es_open(struct net_device *dev)
diff -Nru a/drivers/net/ethertap.c b/drivers/net/ethertap.c
--- a/drivers/net/ethertap.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/ethertap.c	2005-03-09 12:20:51 -05:00
@@ -343,7 +343,7 @@
 }
 
 
-int __init ethertap_init(void)
+static int __init ethertap_init(void)
 {
 	int i, err = 0;
 
@@ -371,7 +371,7 @@
 }
 module_init(ethertap_init);
 
-void __exit ethertap_cleanup(void)
+static void __exit ethertap_cleanup(void)
 {
 	int i;
 
diff -Nru a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
--- a/drivers/net/ewrk3.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/ewrk3.c	2005-03-09 12:20:51 -05:00
@@ -273,6 +273,7 @@
 struct ewrk3_private {
 	char adapter_name[80];	/* Name exported to /proc/ioports */
 	u_long shmem_base;	/* Shared memory start address */
+	void __iomem *shmem;
 	u_long shmem_length;	/* Shared memory window length */
 	struct net_device_stats stats;	/* Public stats */
 	struct ewrk3_stats pktStats; /* Private stats counters */
@@ -281,7 +282,7 @@
 	u_char lemac;		/* Chip rev. level */
 	u_char hard_strapped;	/* Don't allow a full open */
 	u_char txc;		/* Transmit cut through */
-	u_char *mctbl;		/* Pointer to the multicast table */
+	void __iomem *mctbl;	/* Pointer to the multicast table */
 	u_char led_mask;	/* Used to reserve LED access for ethtool */
 	spinlock_t hw_lock;
 };
@@ -535,6 +536,9 @@
 
 	lp = netdev_priv(dev);
 	lp->shmem_base = mem_start;
+	lp->shmem = ioremap(mem_start, shmem_length);
+	if (!lp->shmem)
+		return -ENOMEM;
 	lp->shmem_length = shmem_length;
 	lp->lemac = lemac;
 	lp->hard_strapped = hard_strapped;
@@ -590,6 +594,7 @@
 				} else {
 					printk(", but incorrect IRQ line detected.\n");
 				}
+				iounmap(lp->shmem);
 				return -ENXIO;
 			}
 
@@ -768,7 +773,7 @@
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
 	u_long iobase = dev->base_addr;
-	u_long buf = 0;
+	void __iomem *buf = NULL;
 	u_char icr;
 	u_char page;
 
@@ -801,13 +806,13 @@
 	if (lp->shmem_length == IO_ONLY) {
 		outb (page, EWRK3_IOPR);
 	} else if (lp->shmem_length == SHMEM_2K) {
-		buf = lp->shmem_base;
+		buf = lp->shmem;
 		outb (page, EWRK3_MPR);
 	} else if (lp->shmem_length == SHMEM_32K) {
-		buf = ((((short) page << 11) & 0x7800) + lp->shmem_base);
+		buf = (((short) page << 11) & 0x7800) + lp->shmem;
 		outb ((page >> 4), EWRK3_MPR);
 	} else if (lp->shmem_length == SHMEM_64K) {
-		buf = ((((short) page << 11) & 0xf800) + lp->shmem_base);
+		buf = (((short) page << 11) & 0xf800) + lp->shmem;
 		outb ((page >> 5), EWRK3_MPR);
 	} else {
 		printk (KERN_ERR "%s: Oops - your private data area is hosed!\n",
@@ -831,30 +836,28 @@
 		}
 		outb (page, EWRK3_TQ);	/* Start sending pkt */
 	} else {
-		isa_writeb ((char) (TCR_QMODE | TCR_PAD | TCR_IFC), buf);	/* ctrl byte */
+		writeb ((char) (TCR_QMODE | TCR_PAD | TCR_IFC), buf);	/* ctrl byte */
 		buf += 1;
-		isa_writeb ((char) (skb->len & 0xff), buf);	/* length (16 bit xfer) */
+		writeb ((char) (skb->len & 0xff), buf);	/* length (16 bit xfer) */
 		buf += 1;
 		if (lp->txc) {
-			isa_writeb ((char)
-				    (((skb->len >> 8) & 0xff) | XCT), buf);
+			writeb(((skb->len >> 8) & 0xff) | XCT, buf);
 			buf += 1;
-			isa_writeb (0x04, buf);	/* index byte */
+			writeb (0x04, buf);	/* index byte */
 			buf += 1;
-			isa_writeb (0x00, (buf + skb->len));	/* Write the XCT flag */
-			isa_memcpy_toio (buf, skb->data, PRELOAD);	/* Write PRELOAD bytes */
+			writeb (0x00, (buf + skb->len));	/* Write the XCT flag */
+			memcpy_toio (buf, skb->data, PRELOAD);	/* Write PRELOAD bytes */
 			outb (page, EWRK3_TQ);	/* Start sending pkt */
-			isa_memcpy_toio (buf + PRELOAD,
+			memcpy_toio (buf + PRELOAD,
 					 skb->data + PRELOAD,
 					 skb->len - PRELOAD);
-			isa_writeb (0xff, (buf + skb->len));	/* Write the XCT flag */
+			writeb (0xff, (buf + skb->len));	/* Write the XCT flag */
 		} else {
-			isa_writeb ((char)
-				    ((skb->len >> 8) & 0xff), buf);
+			writeb ((skb->len >> 8) & 0xff, buf);
 			buf += 1;
-			isa_writeb (0x04, buf);	/* index byte */
+			writeb (0x04, buf);	/* index byte */
 			buf += 1;
-			isa_memcpy_toio (buf, skb->data, skb->len);	/* Write data bytes */
+			memcpy_toio (buf, skb->data, skb->len);	/* Write data bytes */
 			outb (page, EWRK3_TQ);	/* Start sending pkt */
 		}
 	}
@@ -940,7 +943,7 @@
 	u_long iobase = dev->base_addr;
 	int i, status = 0;
 	u_char page;
-	u_long buf = 0;
+	void __iomem *buf = NULL;
 
 	while (inb(EWRK3_RQC) && !status) {	/* Whilst there's incoming data */
 		if ((page = inb(EWRK3_RQ)) < lp->mPage) {	/* Get next entry's buffer page */
@@ -950,13 +953,13 @@
 			if (lp->shmem_length == IO_ONLY) {
 				outb(page, EWRK3_IOPR);
 			} else if (lp->shmem_length == SHMEM_2K) {
-				buf = lp->shmem_base;
+				buf = lp->shmem;
 				outb(page, EWRK3_MPR);
 			} else if (lp->shmem_length == SHMEM_32K) {
-				buf = ((((short) page << 11) & 0x7800) + lp->shmem_base);
+				buf = (((short) page << 11) & 0x7800) + lp->shmem;
 				outb((page >> 4), EWRK3_MPR);
 			} else if (lp->shmem_length == SHMEM_64K) {
-				buf = ((((short) page << 11) & 0xf800) + lp->shmem_base);
+				buf = (((short) page << 11) & 0xf800) + lp->shmem;
 				outb((page >> 5), EWRK3_MPR);
 			} else {
 				status = -1;
@@ -972,9 +975,9 @@
 					pkt_len = inb(EWRK3_DATA);
 					pkt_len |= ((u_short) inb(EWRK3_DATA) << 8);
 				} else {
-					rx_status = isa_readb(buf);
+					rx_status = readb(buf);
 					buf += 1;
-					pkt_len = isa_readw(buf);
+					pkt_len = readw(buf);
 					buf += 3;
 				}
 
@@ -1001,7 +1004,7 @@
 								*p++ = inb(EWRK3_DATA);
 							}
 						} else {
-							isa_memcpy_fromio(p, buf, pkt_len);
+							memcpy_fromio(p, buf, pkt_len);
 						}
 
 						for (i = 1; i < EWRK3_PKT_STAT_SZ - 1; i++) {
@@ -1153,9 +1156,9 @@
 	csr = inb(EWRK3_CSR);
 
 	if (lp->shmem_length == IO_ONLY) {
-		lp->mctbl = (char *) PAGE0_HTE;
+		lp->mctbl = NULL;
 	} else {
-		lp->mctbl = (char *) (lp->shmem_base + PAGE0_HTE);
+		lp->mctbl = lp->shmem + PAGE0_HTE;
 	}
 
 	csr &= ~(CSR_PME | CSR_MCE);
@@ -1184,7 +1187,7 @@
 	u_long iobase = dev->base_addr;
 	int i;
 	char *addrs, bit, byte;
-	short *p = (short *) lp->mctbl;
+	short __iomem *p = lp->mctbl;
 	u16 hashcode;
 	u32 crc;
 
@@ -1192,7 +1195,7 @@
 
 	if (lp->shmem_length == IO_ONLY) {
 		outb(0, EWRK3_IOPR);
-		outw(EEPROM_OFFSET(lp->mctbl), EWRK3_PIR1);
+		outw(PAGE0_HTE, EWRK3_PIR1);
 	} else {
 		outb(0, EWRK3_MPR);
 	}
@@ -1202,7 +1205,7 @@
 			if (lp->shmem_length == IO_ONLY) {
 				outb(0xff, EWRK3_DATA);
 			} else {	/* memset didn't work here */
-				isa_writew(0xffff, (int) p);
+				writew(0xffff, p);
 				p++;
 				i++;
 			}
@@ -1219,8 +1222,8 @@
 				outb(0x00, EWRK3_DATA);
 			}
 		} else {
-			isa_memset_io((int) lp->mctbl, 0, (HASH_TABLE_LEN >> 3));
-			isa_writeb(0x80, (int) (lp->mctbl + (HASH_TABLE_LEN >> 4) - 1));
+			memset_io(lp->mctbl, 0, HASH_TABLE_LEN >> 3);
+			writeb(0x80, lp->mctbl + (HASH_TABLE_LEN >> 4) - 1);
 		}
 
 		/* Update table */
@@ -1237,13 +1240,13 @@
 				if (lp->shmem_length == IO_ONLY) {
 					u_char tmp;
 
-					outw((short) ((long) lp->mctbl) + byte, EWRK3_PIR1);
+					outw(PAGE0_HTE + byte, EWRK3_PIR1);
 					tmp = inb(EWRK3_DATA);
 					tmp |= bit;
-					outw((short) ((long) lp->mctbl) + byte, EWRK3_PIR1);
+					outw(PAGE0_HTE + byte, EWRK3_PIR1);
 					outb(tmp, EWRK3_DATA);
 				} else {
-					isa_writeb(isa_readb((int)(lp->mctbl + byte)) | bit, (int)(lp->mctbl + byte));
+					writeb(readb(lp->mctbl + byte) | bit, lp->mctbl + byte);
 				}
 			}
 		}
@@ -1654,8 +1657,7 @@
 
 		/* Wait a little while */
 		spin_unlock_irqrestore(&lp->hw_lock, flags);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ>>2);
+		msleep(250);
 		spin_lock_irqsave(&lp->hw_lock, flags);
 
 		/* Exit if we got a signal */
@@ -1784,7 +1786,7 @@
 			}
 		} else {
 			outb(0, EWRK3_MPR);
-			isa_memcpy_fromio(tmp->addr, lp->shmem_base + PAGE0_HTE, (HASH_TABLE_LEN >> 3));
+			memcpy_fromio(tmp->addr, lp->shmem + PAGE0_HTE, (HASH_TABLE_LEN >> 3));
 		}
 		spin_unlock_irqrestore(&lp->hw_lock, flags);
 
@@ -1954,10 +1956,13 @@
 	int i;
 
 	for( i=0; i<ndevs; i++ ) {
-		unregister_netdev(ewrk3_devs[i]);
-		release_region(ewrk3_devs[i]->base_addr, EWRK3_TOTAL_SIZE);
-		free_netdev(ewrk3_devs[i]);
+		struct net_device *dev = ewrk3_devs[i];
+		struct ewrk3_private *lp = netdev_priv(dev);
 		ewrk3_devs[i] = NULL;
+		unregister_netdev(dev);
+		release_region(dev->base_addr, EWRK3_TOTAL_SIZE);
+		iounmap(lp->shmem);
+		free_netdev(dev);
 	}
 }
 
diff -Nru a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
--- a/drivers/net/ioc3-eth.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/ioc3-eth.c	2005-03-09 12:20:51 -05:00
@@ -56,7 +56,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/skbuff.h>
-#include <linux/dp83840.h>
 #include <net/ip.h>
 
 #include <asm/byteorder.h>
diff -Nru a/drivers/net/irda/act200l-sir.c b/drivers/net/irda/act200l-sir.c
--- a/drivers/net/irda/act200l-sir.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/irda/act200l-sir.c	2005-03-09 12:20:51 -05:00
@@ -177,8 +177,7 @@
 
 	/* Write control bytes */
 	sirdev_raw_write(dev, control, 3);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(5));
+	msleep(5);
 
 	/* Go back to normal mode */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
diff -Nru a/drivers/net/irda/irtty-sir.c b/drivers/net/irda/irtty-sir.c
--- a/drivers/net/irda/irtty-sir.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/irda/irtty-sir.c	2005-03-09 12:20:51 -05:00
@@ -32,6 +32,7 @@
 #include <linux/init.h>
 #include <asm/uaccess.h>
 #include <linux/smp_lock.h>
+#include <linux/delay.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>
@@ -97,8 +98,7 @@
 		unlock_kernel();
 	}
 	else {
-		set_task_state(current, TASK_UNINTERRUPTIBLE);
-		schedule_timeout(msecs_to_jiffies(USBSERIAL_TX_DONE_DELAY));
+		msleep(USBSERIAL_TX_DONE_DELAY);
 	}
 }
 
diff -Nru a/drivers/net/irda/ma600-sir.c b/drivers/net/irda/ma600-sir.c
--- a/drivers/net/irda/ma600-sir.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/irda/ma600-sir.c	2005-03-09 12:20:51 -05:00
@@ -191,8 +191,7 @@
 	sirdev_raw_write(dev, &byte, sizeof(byte));
 
 	/* Wait at least 10ms: fake wait_until_sent - 10 bits at 9600 baud*/
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(15));		/* old ma600 uses 15ms */
+	msleep(15);					/* old ma600 uses 15ms */
 
 #if 1
 	/* read-back of the control byte. ma600 is the first dongle driver
@@ -215,8 +214,7 @@
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
 	/* Wait at least 10ms */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(10));
+	msleep(10);
 
 	/* dongle is now switched to the new speed */
 	dev->speed = speed;
@@ -245,13 +243,11 @@
 
 	/* Reset the dongle : set DTR low for 10 ms */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(10));
+	msleep(10);
 
 	/* Go back to normal mode */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(10));
+	msleep(10);
 
 	dev->speed = 9600;      /* That's the dongle-default */
 
diff -Nru a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
--- a/drivers/net/irda/sir_dev.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/irda/sir_dev.c	2005-03-09 12:20:51 -05:00
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/smp_lock.h>
+#include <linux/delay.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/wrapper.h>
@@ -73,8 +74,7 @@
 	spin_lock_irqsave(&dev->tx_lock, flags);	/* serialize with other tx operations */
 	while (dev->tx_buff.len > 0) {			/* wait until tx idle */
 		spin_unlock_irqrestore(&dev->tx_lock, flags);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(msecs_to_jiffies(10));
+		msleep(10);
 		spin_lock_irqsave(&dev->tx_lock, flags);
 	}
 
diff -Nru a/drivers/net/irda/tekram-sir.c b/drivers/net/irda/tekram-sir.c
--- a/drivers/net/irda/tekram-sir.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/irda/tekram-sir.c	2005-03-09 12:20:51 -05:00
@@ -210,8 +210,7 @@
 	sirdev_set_dtr_rts(dev, FALSE, TRUE); 
 
 	/* Should sleep 1 ms */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(1));
+	msleep(1);
 
 	/* Set DTR, Set RTS */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
diff -Nru a/drivers/net/loopback.c b/drivers/net/loopback.c
--- a/drivers/net/loopback.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/loopback.c	2005-03-09 12:20:51 -05:00
@@ -184,7 +184,7 @@
 	return stats;
 }
 
-u32 loopback_get_link(struct net_device *dev)
+static u32 loopback_get_link(struct net_device *dev)
 {
 	return 1;
 }
diff -Nru a/drivers/net/lp486e.c b/drivers/net/lp486e.c
--- a/drivers/net/lp486e.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/lp486e.c	2005-03-09 12:20:51 -05:00
@@ -112,8 +112,10 @@
 	CmdDiagnose = 7
 };
 
-char *CUcmdnames[8] = { "NOP", "IASetup", "Configure", "MulticastList",
-			"Tx", "TDR", "Dump", "Diagnose" };
+#if 0
+static const char *CUcmdnames[8] = { "NOP", "IASetup", "Configure", "MulticastList",
+				     "Tx", "TDR", "Dump", "Diagnose" };
+#endif
 
 /* Status word bits */
 #define	STAT_CX		0x8000	/* The CU finished executing a command
@@ -960,7 +962,7 @@
 		(unsigned char) add[12], (unsigned char) add[13]);
 }
 
-int __init lp486e_probe(struct net_device *dev) {
+static int __init lp486e_probe(struct net_device *dev) {
 	struct i596_private *lp;
 	unsigned char eth_addr[6] = { 0, 0xaa, 0, 0, 0, 0 };
 	unsigned char *bios;
diff -Nru a/drivers/net/ni65.c b/drivers/net/ni65.c
--- a/drivers/net/ni65.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/ni65.c	2005-03-09 12:20:51 -05:00
@@ -526,8 +526,7 @@
 			ni65_init_lance(p,dev->dev_addr,0,0);
 			irq_mask = probe_irq_on();
 			writereg(CSR0_INIT|CSR0_INEA,CSR0); /* trigger interrupt */
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ/50);
+			msleep(20);
 			dev->irq = probe_irq_off(irq_mask);
 			if(!dev->irq)
 			{
diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/ns83820.c	2005-03-09 12:20:51 -05:00
@@ -2007,8 +2007,7 @@
 	if (reset_phy) {
 		printk(KERN_INFO "%s: resetting phy\n", ndev->name);
 		writel(dev->CFG_cache | CFG_PHY_RST, dev->base + CFG);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout((HZ+99)/100);
+		msleep(10);
 		writel(dev->CFG_cache, dev->base + CFG);
 	}
 
diff -Nru a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
--- a/drivers/net/pcmcia/ibmtr_cs.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/pcmcia/ibmtr_cs.c	2005-03-09 12:20:51 -05:00
@@ -343,7 +343,8 @@
     CS_CHECK(MapMemPage, pcmcia_map_mem_page(info->sram_win_handle, &mem));
 
     ti->sram_base = mem.CardOffset >> 12;
-    ti->sram_virt = (u_long)ioremap(req.Base, req.Size);
+    ti->sram_virt = ioremap(req.Base, req.Size);
+    ti->sram_phys = req.Base;
 
     CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link->handle, &link->conf));
 
@@ -401,7 +402,7 @@
     pcmcia_release_irq(link->handle, &link->irq);
     if (link->win) {
 	struct tok_info *ti = netdev_priv(dev);
-	iounmap((void *)ti->mmio);
+	iounmap(ti->mmio);
 	pcmcia_release_window(link->win);
 	pcmcia_release_window(info->sram_win_handle);
     }
@@ -433,7 +434,7 @@
         if (link->state & DEV_CONFIG) {
 	    /* set flag to bypass normal interrupt code */
 	    struct tok_info *priv = netdev_priv(dev);
-	    priv->sram_virt |= 1;
+	    priv->sram_phys |= 1;
 	    netif_device_detach(dev);
         }
         break;
diff -Nru a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
--- a/drivers/net/pcmcia/xirc2ps_cs.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/pcmcia/xirc2ps_cs.c	2005-03-09 12:20:51 -05:00
@@ -415,11 +415,6 @@
 #define PutByte(reg,value) outb((value), ioaddr+(reg))
 #define PutWord(reg,value) outw((value), ioaddr+(reg))
 
-#define Wait(n) do { \
-	set_current_state(TASK_UNINTERRUPTIBLE); \
-	schedule_timeout(n); \
-} while (0)
-
 /*====== Functions used for debugging =================================*/
 #if defined(PCMCIA_DEBUG) && 0 /* reading regs may change system status */
 static void
@@ -1707,12 +1702,12 @@
     SelectPage(4);
     udelay(1);
     PutByte(XIRCREG4_GPR1, 0);	     /* clear bit 0: power down */
-    Wait(HZ/25);		     /* wait 40 msec */
+    msleep(40);				     /* wait 40 msec */
     if (local->mohawk)
 	PutByte(XIRCREG4_GPR1, 1);	 /* set bit 0: power up */
     else
 	PutByte(XIRCREG4_GPR1, 1 | 4);	 /* set bit 0: power up, bit 2: AIC */
-    Wait(HZ/50);		     /* wait 20 msec */
+    msleep(20);			     /* wait 20 msec */
 }
 
 static void
@@ -1726,9 +1721,9 @@
 
     hardreset(dev);
     PutByte(XIRCREG_CR, SoftReset); /* set */
-    Wait(HZ/50);		     /* wait 20 msec */
+    msleep(20);			     /* wait 20 msec */
     PutByte(XIRCREG_CR, 0);	     /* clear */
-    Wait(HZ/25);		     /* wait 40 msec */
+    msleep(40);			     /* wait 40 msec */
     if (local->mohawk) {
 	SelectPage(4);
 	/* set pin GP1 and GP2 to output  (0x0c)
@@ -1739,7 +1734,7 @@
     }
 
     /* give the circuits some time to power up */
-    Wait(HZ/2);		/* about 500ms */
+    msleep(500);			/* about 500ms */
 
     local->last_ptr_value = 0;
     local->silicon = local->mohawk ? (GetByte(XIRCREG4_BOV) & 0x70) >> 4
@@ -1758,7 +1753,7 @@
 	SelectPage(0x42);
 	PutByte(XIRCREG42_SWC1, 0x80);
     }
-    Wait(HZ/25);		     /* wait 40 msec to let it complete */
+    msleep(40);			     /* wait 40 msec to let it complete */
 
   #ifdef PCMCIA_DEBUG
     if (pc_debug) {
@@ -1817,7 +1812,7 @@
 	    printk(KERN_INFO "%s: MII selected\n", dev->name);
 	    SelectPage(2);
 	    PutByte(XIRCREG2_MSR, GetByte(XIRCREG2_MSR) | 0x08);
-	    Wait(HZ/50);
+	    msleep(20);
 	} else {
 	    printk(KERN_INFO "%s: MII detected; using 10mbs\n",
 		   dev->name);
@@ -1826,7 +1821,7 @@
 		PutByte(XIRCREG42_SWC1, 0xC0);
 	    else  /* enable 10BaseT */
 		PutByte(XIRCREG42_SWC1, 0x80);
-	    Wait(HZ/25);	/* wait 40 msec to let it complete */
+	    msleep(40);			/* wait 40 msec to let it complete */
 	}
 	if (full_duplex)
 	    PutByte(XIRCREG1_ECR, GetByte(XIRCREG1_ECR | FullDuplex));
@@ -1919,7 +1914,7 @@
 	 * Fixme: Better to use a timer here!
 	 */
 	for (i=0; i < 35; i++) {
-	    Wait(HZ/10);	 /* wait 100 msec */
+	    msleep(100);	 /* wait 100 msec */
 	    status = mii_rd(ioaddr,  0, 1);
 	    if ((status & 0x0020) && (status & 0x0004))
 		break;
diff -Nru a/drivers/net/ppp_deflate.c b/drivers/net/ppp_deflate.c
--- a/drivers/net/ppp_deflate.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/ppp_deflate.c	2005-03-09 12:20:51 -05:00
@@ -600,7 +600,7 @@
 /*
  * Procedures exported to if_ppp.c.
  */
-struct compressor ppp_deflate = {
+static struct compressor ppp_deflate = {
 	.compress_proto =	CI_DEFLATE,
 	.comp_alloc =		z_comp_alloc,
 	.comp_free =		z_comp_free,
@@ -618,7 +618,7 @@
 	.owner =		THIS_MODULE
 };
 
-struct compressor ppp_deflate_draft = {
+static struct compressor ppp_deflate_draft = {
 	.compress_proto =	CI_DEFLATE_DRAFT,
 	.comp_alloc =		z_comp_alloc,
 	.comp_free =		z_comp_free,
diff -Nru a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/ppp_generic.c	2005-03-09 12:20:51 -05:00
@@ -2741,8 +2741,6 @@
 EXPORT_SYMBOL(ppp_output_wakeup);
 EXPORT_SYMBOL(ppp_register_compressor);
 EXPORT_SYMBOL(ppp_unregister_compressor);
-EXPORT_SYMBOL(all_ppp_units); /* for debugging */
-EXPORT_SYMBOL(all_channels); /* for debugging */
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_CHARDEV_MAJOR(PPP_MAJOR);
 MODULE_ALIAS("/dev/ppp");
diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/pppoe.c	2005-03-09 12:20:51 -05:00
@@ -1036,7 +1036,7 @@
 	read_unlock_bh(&pppoe_hash_lock);
 }
 
-struct seq_operations pppoe_seq_ops = {
+static struct seq_operations pppoe_seq_ops = {
 	.start		= pppoe_seq_start,
 	.next		= pppoe_seq_next,
 	.stop		= pppoe_seq_stop,
diff -Nru a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/s2io.c	2005-03-09 12:20:51 -05:00
@@ -1350,7 +1350,7 @@
  *
  */
 
-void fix_mac_address(nic_t * sp)
+static void fix_mac_address(nic_t * sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
@@ -1506,7 +1506,7 @@
  *  Return Value: void 
 */
 
-void free_tx_buffers(struct s2io_nic *nic)
+static void free_tx_buffers(struct s2io_nic *nic)
 {
 	struct net_device *dev = nic->dev;
 	struct sk_buff *skb;
@@ -1597,7 +1597,7 @@
  *  SUCCESS on success or an appropriate -ve value on failure.
  */
 
-int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
+static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 {
 	struct net_device *dev = nic->dev;
 	struct sk_buff *skb;
@@ -2422,7 +2422,7 @@
  *   SUCCESS on success and FAILURE on failure.
  */
 
-int wait_for_cmd_complete(nic_t * sp)
+static int wait_for_cmd_complete(nic_t * sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	int ret = FAILURE, cnt = 0;
@@ -2452,7 +2452,7 @@
  *  void.
  */
 
-void s2io_reset(nic_t * sp)
+static void s2io_reset(nic_t * sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
@@ -2504,7 +2504,7 @@
  *  SUCCESS on success and FAILURE on failure.
  */
 
-int s2io_set_swapper(nic_t * sp)
+static int s2io_set_swapper(nic_t * sp)
 {
 	struct net_device *dev = sp->dev;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
@@ -2598,7 +2598,7 @@
  *   file on failure.
  */
 
-int s2io_open(struct net_device *dev)
+static int s2io_open(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
 	int err = 0;
@@ -2650,7 +2650,7 @@
  *  file on failure.
  */
 
-int s2io_close(struct net_device *dev)
+static int s2io_close(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
 
@@ -2677,7 +2677,7 @@
  *  0 on success & 1 on failure.
  */
 
-int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
+static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
 	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
@@ -2897,7 +2897,7 @@
  *  pointer to the updated net_device_stats structure.
  */
 
-struct net_device_stats *s2io_get_stats(struct net_device *dev)
+static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
 	mac_info_t *mac_control;
@@ -3150,7 +3150,7 @@
  * return 0 on success.
  */
 
-int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
+static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 {
 	nic_t *sp = dev->priv;
 	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
@@ -3347,8 +3347,8 @@
  * int, returns 0 on Success
  */
 
-int s2io_ethtool_setpause_data(struct net_device *dev,
-			       struct ethtool_pauseparam *ep)
+static int s2io_ethtool_setpause_data(struct net_device *dev,
+				      struct ethtool_pauseparam *ep)
 {
 	u64 val64;
 	nic_t *sp = dev->priv;
@@ -3463,8 +3463,8 @@
  *  int  0 on success
  */
 
-int s2io_ethtool_geeprom(struct net_device *dev,
-			 struct ethtool_eeprom *eeprom, u8 * data_buf)
+static int s2io_ethtool_geeprom(struct net_device *dev,
+				struct ethtool_eeprom *eeprom, u8 * data_buf)
 {
 	u32 data, i, valid;
 	nic_t *sp = dev->priv;
@@ -3961,19 +3961,20 @@
 	tmp_stats[i++] = stat_info->rmac_err_tcp;
 }
 
-int s2io_ethtool_get_regs_len(struct net_device *dev)
+static int s2io_ethtool_get_regs_len(struct net_device *dev)
 {
 	return (XENA_REG_SPACE);
 }
 
 
-u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
+static u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
 {
 	nic_t *sp = dev->priv;
 
 	return (sp->rx_csum);
 }
-int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
+
+static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
 {
 	nic_t *sp = dev->priv;
 
@@ -3984,17 +3985,19 @@
 
 	return 0;
 }
-int s2io_get_eeprom_len(struct net_device *dev)
+
+static int s2io_get_eeprom_len(struct net_device *dev)
 {
 	return (XENA_EEPROM_SPACE);
 }
 
-int s2io_ethtool_self_test_count(struct net_device *dev)
+static int s2io_ethtool_self_test_count(struct net_device *dev)
 {
 	return (S2IO_TEST_LEN);
 }
-void s2io_ethtool_get_strings(struct net_device *dev,
-			      u32 stringset, u8 * data)
+
+static void s2io_ethtool_get_strings(struct net_device *dev,
+				     u32 stringset, u8 * data)
 {
 	switch (stringset) {
 	case ETH_SS_TEST:
@@ -4005,12 +4008,13 @@
 		       sizeof(ethtool_stats_keys));
 	}
 }
+
 static int s2io_ethtool_get_stats_count(struct net_device *dev)
 {
 	return (S2IO_STAT_LEN);
 }
 
-int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
+static int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
 {
 	if (data)
 		dev->features |= NETIF_F_IP_CSUM;
@@ -4066,7 +4070,7 @@
  *  function returns OP NOT SUPPORTED value.
  */
 
-int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+static int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	return -EOPNOTSUPP;
 }
@@ -4082,7 +4086,7 @@
  *   file on failure.
  */
 
-int s2io_change_mtu(struct net_device *dev, int new_mtu)
+static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
@@ -4476,7 +4480,7 @@
  *  void.
  */
 
-void s2io_link(nic_t * sp, int link)
+static void s2io_link(nic_t * sp, int link)
 {
 	struct net_device *dev = (struct net_device *) sp->dev;
 
@@ -4493,23 +4497,6 @@
 }
 
 /**
- *  get_xena_rev_id - to identify revision ID of xena. 
- *  @pdev : PCI Dev structure
- *  Description:
- *  Function to identify the Revision ID of xena.
- *  Return value:
- *  returns the revision ID of the device.
- */
-
-int get_xena_rev_id(struct pci_dev *pdev)
-{
-	u8 id = 0;
-	int ret;
-	ret = pci_read_config_byte(pdev, PCI_REVISION_ID, (u8 *) & id);
-	return id;
-}
-
-/**
  *  s2io_init_pci -Initialization of PCI and PCI-X configuration registers . 
  *  @sp : private member of the device structure, which is a pointer to the 
  *  s2io_nic structure.
@@ -4962,7 +4949,7 @@
  * Description: This function is the cleanup routine for the driver. It unregist * ers the driver.
  */
 
-void s2io_closer(void)
+static void s2io_closer(void)
 {
 	pci_unregister_driver(&s2io_driver);
 	DBG_PRINT(INIT_DBG, "cleanup done\n");
diff -Nru a/drivers/net/s2io.h b/drivers/net/s2io.h
--- a/drivers/net/s2io.h	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/s2io.h	2005-03-09 12:20:51 -05:00
@@ -848,7 +848,7 @@
 static void alarm_intr_handler(struct s2io_nic *sp);
 
 static int s2io_starter(void);
-void s2io_closer(void);
+static void s2io_closer(void);
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
@@ -858,13 +858,13 @@
 static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
 			  buffAdd_t * ba);
 #endif
-void s2io_link(nic_t * sp, int link);
-void s2io_reset(nic_t * sp);
+static void s2io_link(nic_t * sp, int link);
+static void s2io_reset(nic_t * sp);
 #ifdef CONFIG_S2IO_NAPI
 static int s2io_poll(struct net_device *dev, int *budget);
 #endif
 static void s2io_init_pci(nic_t * sp);
-int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
+static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs);
 static int verify_xena_quiescence(u64 val64, int flag);
 static struct ethtool_ops netdev_ethtool_ops;
diff -Nru a/drivers/net/sb1000.c b/drivers/net/sb1000.c
--- a/drivers/net/sb1000.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/sb1000.c	2005-03-09 12:20:51 -05:00
@@ -57,9 +57,9 @@
 #include <asm/uaccess.h>
 
 #ifdef SB1000_DEBUG
-int sb1000_debug = SB1000_DEBUG;
+static int sb1000_debug = SB1000_DEBUG;
 #else
-int sb1000_debug = 1;
+static int sb1000_debug = 1;
 #endif
 
 static const int SB1000_IO_EXTENT = 8;
@@ -116,15 +116,15 @@
 static inline int sb1000_end_get_set_command(const int ioaddr[],
 	const char* name);
 static inline int sb1000_activate(const int ioaddr[], const char* name);
-static inline int sb1000_get_firmware_version(const int ioaddr[],
+static int sb1000_get_firmware_version(const int ioaddr[],
 	const char* name, unsigned char version[], int do_end);
-static inline int sb1000_get_frequency(const int ioaddr[], const char* name,
+static int sb1000_get_frequency(const int ioaddr[], const char* name,
 	int* frequency);
-static inline int sb1000_set_frequency(const int ioaddr[], const char* name,
+static int sb1000_set_frequency(const int ioaddr[], const char* name,
 	int frequency);
-static inline int sb1000_get_PIDs(const int ioaddr[], const char* name,
+static int sb1000_get_PIDs(const int ioaddr[], const char* name,
 	short PID[]);
-static inline int sb1000_set_PIDs(const int ioaddr[], const char* name,
+static int sb1000_set_PIDs(const int ioaddr[], const char* name,
 	const short PID[]);
 
 /* SB1000 commands for frame rx interrupt */
@@ -252,7 +252,7 @@
  * SB1000 hardware routines to be used during open/configuration phases
  */
 
-const int TimeOutJiffies = (875 * HZ) / 100;
+static const int TimeOutJiffies = (875 * HZ) / 100;
 
 static inline void nicedelay(unsigned long usecs)
 {
@@ -363,7 +363,7 @@
 /*
  * SB1000 hardware routines to be used during frame rx interrupt
  */
-const int Sb1000TimeOutJiffies = 7 * HZ;
+static const int Sb1000TimeOutJiffies = 7 * HZ;
 
 /* Card Wait For Ready (to be used during frame rx) */
 static inline int
@@ -552,7 +552,7 @@
 }
 
 /* get SB1000 firmware version */
-static inline int
+static int
 sb1000_get_firmware_version(const int ioaddr[], const char* name,
 	unsigned char version[], int do_end)
 {
@@ -575,7 +575,7 @@
 }
 
 /* get SB1000 frequency */
-static inline int
+static int
 sb1000_get_frequency(const int ioaddr[], const char* name, int* frequency)
 {
 	unsigned char st[7];
@@ -592,7 +592,7 @@
 }
 
 /* set SB1000 frequency */
-static inline int
+static int
 sb1000_set_frequency(const int ioaddr[], const char* name, int frequency)
 {
 	unsigned char st[7];
@@ -622,7 +622,7 @@
 }
 
 /* get SB1000 PIDs */
-static inline int
+static int
 sb1000_get_PIDs(const int ioaddr[], const char* name, short PID[])
 {
 	unsigned char st[7];
@@ -656,7 +656,7 @@
 }
 
 /* set SB1000 PIDs */
-static inline int
+static int
 sb1000_set_PIDs(const int ioaddr[], const char* name, const short PID[])
 {
 	unsigned char st[7];
diff -Nru a/drivers/net/shaper.c b/drivers/net/shaper.c
--- a/drivers/net/shaper.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/shaper.c	2005-03-09 12:20:51 -05:00
@@ -96,7 +96,7 @@
 }; 
 #define SHAPERCB(skb) ((struct shaper_cb *) ((skb)->cb))
 
-int sh_debug;		/* Debug flag */
+static int sh_debug;		/* Debug flag */
 
 #define SHAPER_BANNER	"CymruNet Traffic Shaper BETA 0.04 for Linux 2.1\n"
 
diff -Nru a/drivers/net/slhc.c b/drivers/net/slhc.c
--- a/drivers/net/slhc.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/slhc.c	2005-03-09 12:20:51 -05:00
@@ -693,33 +693,6 @@
 }
 
 
-void slhc_i_status(struct slcompress *comp)
-{
-	if (comp != NULLSLCOMPR) {
-		printk("\t%d Cmp, %d Uncmp, %d Bad, %d Tossed\n",
-			comp->sls_i_compressed,
-			comp->sls_i_uncompressed,
-			comp->sls_i_error,
-			comp->sls_i_tossed);
-	}
-}
-
-
-void slhc_o_status(struct slcompress *comp)
-{
-	if (comp != NULLSLCOMPR) {
-		printk("\t%d Cmp, %d Uncmp, %d AsIs, %d NotTCP\n",
-			comp->sls_o_compressed,
-			comp->sls_o_uncompressed,
-			comp->sls_o_tcp,
-			comp->sls_o_nontcp);
-		printk("\t%10d Searches, %10d Misses\n",
-			comp->sls_o_searches,
-			comp->sls_o_misses);
-	}
-}
-
-/* Should this be surrounded with "#ifdef CONFIG_MODULES" ? */
 /* VJ header compression */
 EXPORT_SYMBOL(slhc_init);
 EXPORT_SYMBOL(slhc_free);
diff -Nru a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
--- a/drivers/net/smc-mca.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/smc-mca.c	2005-03-09 12:20:51 -05:00
@@ -310,9 +310,13 @@
 	ei_status.rx_start_page = START_PG + TX_PAGES;
 	ei_status.stop_page = num_pages;
 
-	ei_status.rmem_start = dev->mem_start + TX_PAGES * 256;
-	dev->mem_end = ei_status.rmem_end =
-	dev->mem_start + (ei_status.stop_page - START_PG) * 256;
+	ei_status.mem = ioremap(dev->mem_start, (ei_status.stop_page - START_PG) * 256);
+	if (!ei_status.mem) {
+		rc = -ENOMEM;
+		goto err_release_region;
+	}
+
+	dev->mem_end = dev->mem_start + (ei_status.stop_page - START_PG) * 256;
 
 	printk(", IRQ %d memory %#lx-%#lx.\n",
 	dev->irq, dev->mem_start, dev->mem_end - 1);
@@ -334,10 +338,12 @@
 
 	rc = register_netdev(dev);
 	if (rc)
-		goto err_release_region;
+		goto err_unmap;
 
 	return 0;
 
+err_unmap:
+	iounmap(ei_status.mem);
 err_release_region:
 	release_region(ioaddr, ULTRA_IO_EXTENT);
 err_unclaim:
@@ -395,13 +401,13 @@
 
 static void ultramca_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
 {
-	unsigned long hdr_start = dev->mem_start + ((ring_page - START_PG) << 8);
+	void __iomem *hdr_start = ei_status.mem + ((ring_page - START_PG) << 8);
 
 #ifdef notdef
 	/* Officially this is what we are doing, but the readl() is faster */
-	isa_memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
+	memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
 #else
-	((unsigned int*)hdr)[0] = isa_readl(hdr_start);
+	((unsigned int*)hdr)[0] = readl(hdr_start);
 #endif
 }
 
@@ -411,17 +417,17 @@
 
 static void ultramca_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring_offset)
 {
-	unsigned long xfer_start = dev->mem_start + ring_offset - (START_PG << 8);
+	void __iomem *xfer_start = ei_status.mem + ring_offset - START_PG * 256;
 
-	if (xfer_start + count > ei_status.rmem_end) {
+	if (ring_offset + count > ei_status.stop_page * 256) {
 		/* We must wrap the input move. */
-		int semi_count = ei_status.rmem_end - xfer_start;
-		isa_memcpy_fromio(skb->data, xfer_start, semi_count);
+		int semi_count = ei_status.stop_page * 256 - ring_offset;
+		memcpy_fromio(skb->data, xfer_start, semi_count);
 		count -= semi_count;
-		isa_memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
+		memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 	} else {
 		/* Packet is in one chunk -- we can copy + cksum. */
-		isa_eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		eth_io_copy_and_sum(skb, xfer_start, count, 0);
 	}
 
 }
@@ -429,9 +435,9 @@
 static void ultramca_block_output(struct net_device *dev, int count, const unsigned char *buf,
                 int start_page)
 {
-	unsigned long shmem = dev->mem_start + ((start_page - START_PG) << 8);
+	void __iomem *shmem = ei_status.mem + ((start_page - START_PG) << 8);
 
-	isa_memcpy_toio(shmem, buf, count);
+	memcpy_toio(shmem, buf, count);
 }
 
 static int ultramca_close_card(struct net_device *dev)
@@ -466,6 +472,7 @@
 		unregister_netdev(dev);
 		mca_device_set_claim(mca_dev, 0);
 		release_region(ioaddr, ULTRA_IO_EXTENT);
+		iounmap(ei_status.mem);
 		free_netdev(dev);
 	}
 	return 0;
diff -Nru a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
--- a/drivers/net/smc-ultra.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/smc-ultra.c	2005-03-09 12:20:51 -05:00
@@ -176,6 +176,7 @@
 		pnp_device_detach(idev);
 #endif
 	release_region(dev->base_addr - ULTRA_NIC_OFFSET, ULTRA_IO_EXTENT);
+	iounmap(ei_status.mem);
 }
 
 #ifndef MODULE
@@ -294,9 +295,14 @@
 	ei_status.rx_start_page = START_PG + TX_PAGES;
 	ei_status.stop_page = num_pages;
 
-	ei_status.rmem_start = dev->mem_start + TX_PAGES*256;
-	dev->mem_end = ei_status.rmem_end
-		= dev->mem_start + (ei_status.stop_page - START_PG)*256;
+	ei_status.mem = ioremap(dev->mem_start, (ei_status.stop_page - START_PG)*256);
+	if (!ei_status.mem) {
+		printk(", failed to ioremap.\n");
+		retval =  -ENOMEM;
+		goto out;
+	}
+
+	dev->mem_end = dev->mem_start + (ei_status.stop_page - START_PG)*256;
 
 	if (piomode) {
 		printk(",%s IRQ %d programmed-I/O mode.\n",
@@ -430,16 +436,16 @@
 static void
 ultra_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
 {
-	unsigned long hdr_start = dev->mem_start + ((ring_page - START_PG)<<8);
+	void __iomem *hdr_start = ei_status.mem + ((ring_page - START_PG)<<8);
 
 	outb(ULTRA_MEMENB, dev->base_addr - ULTRA_NIC_OFFSET);	/* shmem on */
 #ifdef __BIG_ENDIAN
 	/* Officially this is what we are doing, but the readl() is faster */
 	/* unfortunately it isn't endian aware of the struct               */
-	isa_memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
+	memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
 	hdr->count = le16_to_cpu(hdr->count);
 #else
-	((unsigned int*)hdr)[0] = isa_readl(hdr_start);
+	((unsigned int*)hdr)[0] = readl(hdr_start);
 #endif
 	outb(0x00, dev->base_addr - ULTRA_NIC_OFFSET); /* shmem off */
 }
@@ -450,20 +456,20 @@
 static void
 ultra_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring_offset)
 {
-	unsigned long xfer_start = dev->mem_start + ring_offset - (START_PG<<8);
+	void __iomem *xfer_start = ei_status.mem + ring_offset - (START_PG<<8);
 
 	/* Enable shared memory. */
 	outb(ULTRA_MEMENB, dev->base_addr - ULTRA_NIC_OFFSET);
 
-	if (xfer_start + count > ei_status.rmem_end) {
+	if (ring_offset + count > ei_status.stop_page*256) {
 		/* We must wrap the input move. */
-		int semi_count = ei_status.rmem_end - xfer_start;
-		isa_memcpy_fromio(skb->data, xfer_start, semi_count);
+		int semi_count = ei_status.stop_page*256 - ring_offset;
+		memcpy_fromio(skb->data, xfer_start, semi_count);
 		count -= semi_count;
-		isa_memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
+		memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 	} else {
 		/* Packet is in one chunk -- we can copy + cksum. */
-		isa_eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		eth_io_copy_and_sum(skb, xfer_start, count, 0);
 	}
 
 	outb(0x00, dev->base_addr - ULTRA_NIC_OFFSET);	/* Disable memory. */
@@ -473,12 +479,12 @@
 ultra_block_output(struct net_device *dev, int count, const unsigned char *buf,
 				int start_page)
 {
-	unsigned long shmem = dev->mem_start + ((start_page - START_PG)<<8);
+	void __iomem *shmem = ei_status.mem + ((start_page - START_PG)<<8);
 
 	/* Enable shared memory. */
 	outb(ULTRA_MEMENB, dev->base_addr - ULTRA_NIC_OFFSET);
 
-	isa_memcpy_toio(shmem, buf, count);
+	memcpy_toio(shmem, buf, count);
 
 	outb(0x00, dev->base_addr - ULTRA_NIC_OFFSET); /* Disable memory. */
 }
diff -Nru a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
--- a/drivers/net/smc-ultra32.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/smc-ultra32.c	2005-03-09 12:20:51 -05:00
@@ -104,6 +104,7 @@
 	int ioaddr = dev->base_addr - ULTRA32_NIC_OFFSET;
 	/* NB: ultra32_close_card() does free_irq */
 	release_region(ioaddr, ULTRA32_IO_EXTENT);
+	iounmap(ei_status.mem);
 }
 
 /*	Probe for the Ultra32.  This looks like a 8013 with the station
@@ -259,8 +260,13 @@
 	/* All Ultra32 cards have 32KB memory with an 8KB window. */
 	ei_status.stop_page = 128;
 
-	ei_status.rmem_start = dev->mem_start + TX_PAGES*256;
-	dev->mem_end = ei_status.rmem_end = dev->mem_start + 0x1fff;
+	ei_status.mem = ioremap(dev->mem_start, 0x2000);
+	if (!ei_status.mem) {
+		printk(", failed to ioremap.\n");
+		retval = -ENOMEM;
+		goto out;
+	}
+	dev->mem_end = dev->mem_start + 0x1fff;
 
 	printk(", IRQ %d, 32KB memory, 8KB window at 0x%lx-0x%lx.\n",
 	       dev->irq, dev->mem_start, dev->mem_end);
@@ -345,7 +351,7 @@
 				 struct e8390_pkt_hdr *hdr,
 				 int ring_page)
 {
-	unsigned long hdr_start = dev->mem_start + ((ring_page & 0x1f) << 8);
+	void __iomem *hdr_start = ei_status.mem + ((ring_page & 0x1f) << 8);
 	unsigned int RamReg = dev->base_addr - ULTRA32_NIC_OFFSET + ULTRA32_CFG3;
 
 	/* Select correct 8KB Window. */
@@ -354,10 +360,10 @@
 #ifdef __BIG_ENDIAN
 	/* Officially this is what we are doing, but the readl() is faster */
 	/* unfortunately it isn't endian aware of the struct               */
-	isa_memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
+	memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
 	hdr->count = le16_to_cpu(hdr->count);
 #else
-	((unsigned int*)hdr)[0] = isa_readl(hdr_start);
+	((unsigned int*)hdr)[0] = readl(hdr_start);
 #endif
 }
 
@@ -371,26 +377,26 @@
 				struct sk_buff *skb,
 				int ring_offset)
 {
-	unsigned long xfer_start = dev->mem_start + (ring_offset & 0x1fff);
+	void __iomem *xfer_start = ei_status.mem + (ring_offset & 0x1fff);
 	unsigned int RamReg = dev->base_addr - ULTRA32_NIC_OFFSET + ULTRA32_CFG3;
 
 	if ((ring_offset & ~0x1fff) != ((ring_offset + count - 1) & ~0x1fff)) {
 		int semi_count = 8192 - (ring_offset & 0x1FFF);
-		isa_memcpy_fromio(skb->data, xfer_start, semi_count);
+		memcpy_fromio(skb->data, xfer_start, semi_count);
 		count -= semi_count;
 		if (ring_offset < 96*256) {
 			/* Select next 8KB Window. */
 			ring_offset += semi_count;
 			outb(ei_status.reg0 | ((ring_offset & 0x6000) >> 13), RamReg);
-			isa_memcpy_fromio(skb->data + semi_count, dev->mem_start, count);
+			memcpy_fromio(skb->data + semi_count, ei_status.mem, count);
 		} else {
 			/* Select first 8KB Window. */
 			outb(ei_status.reg0, RamReg);
-			isa_memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
+			memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 		}
 	} else {
 		/* Packet is in one chunk -- we can copy + cksum. */
-		isa_eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		eth_io_copy_and_sum(skb, xfer_start, count, 0);
 	}
 }
 
@@ -399,13 +405,13 @@
 				 const unsigned char *buf,
 				 int start_page)
 {
-	unsigned long xfer_start = dev->mem_start + (start_page<<8);
+	void __iomem *xfer_start = ei_status.mem + (start_page<<8);
 	unsigned int RamReg = dev->base_addr - ULTRA32_NIC_OFFSET + ULTRA32_CFG3;
 
 	/* Select first 8KB Window. */
 	outb(ei_status.reg0, RamReg);
 
-	isa_memcpy_toio(xfer_start, buf, count);
+	memcpy_toio(xfer_start, buf, count);
 }
 
 #ifdef MODULE
diff -Nru a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/tokenring/ibmtr.c	2005-03-09 12:20:51 -05:00
@@ -227,7 +227,7 @@
 	printk("\n");
 }
 
-static void __devinit HWPrtChanID(void * pcid, short stride)
+static void __devinit HWPrtChanID(void __iomem *pcid, short stride)
 {
 	short i, j;
 	for (i = 0, j = 0; i < 24; i++, j += stride)
@@ -239,15 +239,16 @@
  * going away. 
  */
 
-static void __devinit find_turbo_adapters(int *iolist) {
+static void __devinit find_turbo_adapters(int *iolist)
+{
 	int ram_addr;
 	int index=0;
-	void *chanid;
+	void __iomem *chanid;
 	int found_turbo=0;
 	unsigned char *tchanid, ctemp;
 	int i, j;
 	unsigned long jif;
-	void *ram_mapped ;   
+	void __iomem *ram_mapped ;   
 
 	if (turbo_searched == 1) return;
 	turbo_searched=1;
@@ -328,8 +329,8 @@
 
 	{ 
 		struct tok_info *ti = (struct tok_info *) dev->priv;
-		iounmap((u32 *)ti->mmio);
-		iounmap((u32 *)ti->sram_virt);
+		iounmap(ti->mmio);
+		iounmap(ti->sram_virt);
 	}
 #endif		
 }
@@ -383,9 +384,9 @@
 {
 
 	unsigned char segment, intr=0, irq=0, i, j, cardpresent=NOTOK, temp=0;
-	void * t_mmio = NULL;
+	void __iomem * t_mmio = NULL;
 	struct tok_info *ti = dev->priv;
-	void *cd_chanid;
+	void __iomem *cd_chanid;
 	unsigned char *tchanid, ctemp;
 #ifndef PCMCIA
 	unsigned char t_irq=0;
@@ -428,7 +429,7 @@
 	 */
 #ifdef PCMCIA
 	iounmap(t_mmio);
-	t_mmio = (void *)ti->mmio;	/*BMS to get virtual address */
+	t_mmio = ti->mmio;	/*BMS to get virtual address */
 	irq = ti->irq;		/*BMS to display the irq!   */
 #endif
 	cd_chanid = (CHANNEL_ID + t_mmio);	/* for efficiency */
@@ -515,7 +516,7 @@
 		if (intr == 3) irq = 11;
 		ti->global_int_enable = 0;
 		ti->adapter_int_enable = 0;
-		ti->sram_virt=(__u32)(inb(PIOaddr+ADAPTRESETREL) & 0xfe) << 12;
+		ti->sram_phys=(__u32)(inb(PIOaddr+ADAPTRESETREL) & 0xfe) << 12;
 		break;
 	case TR_ISAPNP:
 		if (!t_irq) {
@@ -533,7 +534,7 @@
 			kfree(ti);
 			return -ENODEV;
 		}
-		ti->sram_virt =
+		ti->sram_phys =
 		     ((__u32)readb(ti->mmio+ACA_OFFSET+ACA_RW+RRR_EVEN)<<12);
 		ti->adapter_int_enable = PIOaddr + ADAPTINTREL;
 		break;
@@ -542,7 +543,7 @@
 
 	if (ibmtr_debug_trace & TRC_INIT) {	/* just report int */
 		DPRINTK("irq=%d", irq);
-		printk(", sram_virt=0x%x", ti->sram_virt);
+		printk(", sram_phys=0x%x", ti->sram_phys);
 		if(ibmtr_debug_trace&TRC_INITV){ /* full chat in verbose only */
 			DPRINTK(", ti->mmio=%p", ti->mmio);
 			printk(", segment=%02X", segment);
@@ -681,7 +682,7 @@
 			ibmtr_mem_base = chk_base;
 		}
 	}
-	else  ti->sram_base = ti->sram_virt >> 12;
+	else  ti->sram_base = ti->sram_phys >> 12;
 
 	/* The PCMCIA has already got the interrupt line and the io port, 
 	   so no chance of anybody else getting it - MLP */
@@ -893,7 +894,7 @@
 	*/
 	dev->flags &= ~IFF_RUNNING;
 
-	ti->sram_virt &= ~1; /* to reverse what we do in tok_close */
+	ti->sram_phys &= ~1; /* to reverse what we do in tok_close */
 	/* init the spinlock */
 	spin_lock_init(&ti->lock);
 	init_timer(&ti->tr_timer);
@@ -1068,7 +1069,7 @@
 	/* unloading the module from memory, and then if a timer pops, ouch */
 	del_timer_sync(&ti->tr_timer);
 	outb(0, dev->base_addr + ADAPTRESET);
-	ti->sram_virt |= 1;
+	ti->sram_phys |= 1;
 	ti->open_status = CLOSED;
 
 	netif_stop_queue(dev);
@@ -1094,30 +1095,33 @@
 		"IMPL force received","Duplicate modifier",
 		"No monitor detected","Monitor contention failed for RPL"};
 
-void dir_open_adapter (struct net_device *dev) {
+static void __iomem *map_address(struct tok_info *ti, unsigned index, __u8 *page)
+{
+	if (ti->page_mask) {
+		*page = (index >> 8) & ti->page_mask;
+		index &= ~(ti->page_mask << 8);
+	}
+	return ti->sram_virt + index;
+}
 
+void dir_open_adapter (struct net_device *dev)
+{
         struct tok_info *ti = (struct tok_info *) dev->priv;
         unsigned char ret_code;
         __u16 err;
 
-        ti->srb = ntohs(readw(ti->init_srb + SRB_ADDRESS_OFST));
-        ti->ssb = ntohs(readw(ti->init_srb + SSB_ADDRESS_OFST));
-        ti->arb = ntohs(readw(ti->init_srb + ARB_ADDRESS_OFST));
-        ti->asb = ntohs(readw(ti->init_srb + ASB_ADDRESS_OFST));
-        if (ti->page_mask) {
-                ti->srb_page = (ti->srb >> 8) & ti->page_mask;
-                ti->srb &= ~(ti->page_mask << 8);
-                ti->ssb_page = (ti->ssb >> 8) & ti->page_mask;
-                ti->ssb &= ~(ti->page_mask << 8);
-                ti->arb_page = (ti->arb >> 8) & ti->page_mask;
-                ti->arb &= ~(ti->page_mask << 8);
-                ti->asb_page = (ti->asb >> 8) & ti->page_mask;
-                ti->asb &= ~(ti->page_mask << 8);
-        }
-        ti->srb += ti->sram_virt;
-        ti->ssb += ti->sram_virt;
-        ti->arb += ti->sram_virt;
-        ti->asb += ti->sram_virt;
+        ti->srb = map_address(ti,
+		ntohs(readw(ti->init_srb + SRB_ADDRESS_OFST)),
+		&ti->srb_page);
+        ti->ssb = map_address(ti,
+		ntohs(readw(ti->init_srb + SSB_ADDRESS_OFST)),
+		&ti->ssb_page);
+        ti->arb = map_address(ti,
+		ntohs(readw(ti->init_srb + ARB_ADDRESS_OFST)),
+		&ti->arb_page);
+        ti->asb = map_address(ti,
+		ntohs(readw(ti->init_srb + ASB_ADDRESS_OFST)),
+		&ti->asb_page);
         ti->current_skb = NULL;
         ret_code = readb(ti->init_srb + RETCODE_OFST);
         err = ntohs(readw(ti->init_srb + OPEN_ERROR_CODE_OFST));
@@ -1188,7 +1192,7 @@
 	DPRINTK("Int from tok_driver, dev : %p irq%d regs=%p\n", dev,irq,regs);
 #endif
 	ti = (struct tok_info *) dev->priv;
-	if (ti->sram_virt & 1)
+	if (ti->sram_phys & 1)
 		return IRQ_NONE;         /* PCMCIA card extraction flag */
 	spin_lock(&(ti->lock));
 #ifdef ENABLE_PAGING
@@ -1220,15 +1224,11 @@
 
 	if (status & ADAP_CHK_INT) {
 		int i;
-		__u32 check_reason;
+		void __iomem *check_reason;
 		__u8 check_reason_page = 0;
-		check_reason =
-			ntohs(readw(ti->mmio+ ACA_OFFSET+ACA_RW + WWCR_EVEN));
-		if (ti->page_mask) {
-			check_reason_page = (check_reason >> 8) & ti->page_mask;
-			check_reason &= ~(ti->page_mask << 8);
-		}
-		check_reason += ti->sram_virt;
+		check_reason = map_address(ti,
+			ntohs(readw(ti->mmio+ ACA_OFFSET+ACA_RW + WWCR_EVEN)),
+			&check_reason_page);
 		SET_PAGE(check_reason_page);
 
 		DPRINTK("Adapter check interrupt\n");
@@ -1517,23 +1517,20 @@
 	/* we assign the shared-ram address for ISA devices */
 	writeb(ti->sram_base, ti->mmio + ACA_OFFSET + ACA_RW + RRR_EVEN);
 #ifndef PCMCIA
-        ti->sram_virt = (u32)ioremap(((__u32)ti->sram_base << 12), ti->avail_shared_ram);
+        ti->sram_virt = ioremap(((__u32)ti->sram_base << 12), ti->avail_shared_ram);
 #endif
-	ti->init_srb = ntohs(readw(ti->mmio + ACA_OFFSET + WRBR_EVEN));
-	if (ti->page_mask) {
-		ti->init_srb_page = (ti->init_srb >> 8) & ti->page_mask;
-		ti->init_srb &= ~(ti->page_mask << 8);
-	}
-	ti->init_srb += ti->sram_virt;
+	ti->init_srb = map_address(ti,
+		ntohs(readw(ti->mmio + ACA_OFFSET + WRBR_EVEN)),
+		&ti->init_srb_page);
 	if (ti->page_mask && ti->avail_shared_ram == 127) {
-		int last_512 = 0xfe00, i;
-		int last_512_page=0;
-		last_512_page=(last_512>>8)&ti->page_mask;
-		last_512 &= ~(ti->page_mask << 8);
+		void __iomem *last_512;
+		__u8 last_512_page=0;
+		int i;
+		last_512 = map_address(ti, 0xfe00, &last_512_page);
 		/* initialize high section of ram (if necessary) */
 		SET_PAGE(last_512_page);
 		for (i = 0; i < 512; i++)
-			writeb(0, ti->sram_virt + last_512 + i);
+			writeb(0, last_512 + i);
 	}
 	SET_PAGE(ti->init_srb_page);
 
@@ -1542,7 +1539,7 @@
 	int i;
 
 	DPRINTK("ti->init_srb_page=0x%x\n", ti->init_srb_page);
-	DPRINTK("init_srb(%x):", (ti->init_srb) );
+	DPRINTK("init_srb(%p):", ti->init_srb );
 	for (i = 0; i < 20; i++)
 		printk("%02X ", (int) readb(ti->init_srb + i));
 	printk("\n");
@@ -1579,6 +1576,7 @@
 	struct trh_hdr *trhdr = (struct trh_hdr *) ti->current_skb->data;
 	unsigned int hdr_len;
 	__u32 dhb=0,dhb_base;
+	void __iomem *dhbuf = NULL;
 	unsigned char xmit_command;
 	int i,dhb_len=0x4000,src_len,src_offset;
 	struct trllc *llc;
@@ -1600,7 +1598,7 @@
 		dhb_page = (dhb_base >> 8) & ti->page_mask;
 		dhb=dhb_base & ~(ti->page_mask << 8);
 	}
-	dhb += ti->sram_virt;
+	dhbuf = ti->sram_virt + dhb;
 
 	/* Figure out the size of the 802.5 header */
 	if (!(trhdr->saddr[0] & 0x80))	/* RIF present? */
@@ -1626,12 +1624,12 @@
 		writew(htons(0x11), ti->asb + FRAME_LENGTH_OFST);
 		writeb(0x0e, ti->asb + HEADER_LENGTH_OFST);
 		SET_PAGE(dhb_page);
-		writeb(AC, dhb);
-		writeb(LLC_FRAME, dhb + 1);
+		writeb(AC, dhbuf);
+		writeb(LLC_FRAME, dhbuf + 1);
 		for (i = 0; i < TR_ALEN; i++)
-			writeb((int) 0x0FF, dhb + i + 2);
+			writeb((int) 0x0FF, dhbuf + i + 2);
 		for (i = 0; i < TR_ALEN; i++)
-			writeb(0, dhb + i + TR_ALEN + 2);
+			writeb(0, dhbuf + i + TR_ALEN + 2);
 		writeb(RESP_IN_ASB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
 		return;
 	}
@@ -1650,10 +1648,10 @@
 			dhb=dhb & ~(ti->page_mask << 8);
 			dhb_len=0x4000-dhb; /* remaining size of this page */
 		}
-		dhb+=ti->sram_virt;
+		dhbuf = ti->sram_virt + dhb;
 		SET_PAGE(dhb_page);
 		if (src_len > dhb_len) {
-			memcpy_toio(dhb,&ti->current_skb->data[src_offset],
+			memcpy_toio(dhbuf,&ti->current_skb->data[src_offset],
 					dhb_len);
 			src_len -= dhb_len;
 			src_offset += dhb_len;
@@ -1661,7 +1659,7 @@
 			dhb=dhb_base;
 			continue;
 		}
-		memcpy_toio(dhb, &ti->current_skb->data[src_offset], src_len);
+		memcpy_toio(dhbuf, &ti->current_skb->data[src_offset], src_len);
 		break;
 	}
 	writeb(RESP_IN_ASB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
@@ -1689,9 +1687,9 @@
 static void tr_rx(struct net_device *dev)
 {
 	struct tok_info *ti = (struct tok_info *) dev->priv;
-	__u32 rbuffer, rbufdata;
+	__u32 rbuffer;
+	void __iomem *rbuf, *rbufdata, *llc;
 	__u8 rbuffer_page = 0;
-	__u32 llc;
 	unsigned char *data;
 	unsigned int rbuffer_len, lan_hdr_len, hdr_len, ip_len, length;
 	unsigned char dlc_hdr_len;
@@ -1705,11 +1703,7 @@
 	SET_PAGE(ti->arb_page);
 	memcpy_fromio(&rarb, ti->arb, sizeof(rarb));
 	rbuffer = ntohs(rarb.rec_buf_addr) ;
-	if (ti->page_mask) {
-		rbuffer_page = (rbuffer >> 8) & ti->page_mask;
-		rbuffer &= ~(ti->page_mask << 8);
-	}
-	rbuffer += ti->sram_virt;
+	rbuf = map_address(ti, rbuffer, &rbuffer_page);
 
 	SET_PAGE(ti->asb_page);
 
@@ -1728,7 +1722,7 @@
 	hdr_len = lan_hdr_len + sizeof(struct trllc) + sizeof(struct iphdr);
 
 	SET_PAGE(rbuffer_page);
-	llc = (rbuffer + offsetof(struct rec_buf, data) + lan_hdr_len);
+	llc = rbuf + offsetof(struct rec_buf, data) + lan_hdr_len;
 
 #if TR_VERBOSE
 	DPRINTK("offsetof data: %02X lan_hdr_len: %02X\n",
@@ -1759,9 +1753,7 @@
 
 	if (!IPv4_p) {
 
-		__u32 trhhdr;
-
-		trhhdr = (rbuffer + offsetof(struct rec_buf, data));
+		void __iomem *trhhdr = rbuf + offsetof(struct rec_buf, data);
 
 		DPRINTK("Probably non-IP frame received.\n");
 		DPRINTK("ssap: %02X dsap: %02X "
@@ -1793,8 +1785,8 @@
 	skb_put(skb, length);
 	skb->dev = dev;
 	data = skb->data;
-	rbuffer_len = ntohs(readw(rbuffer + offsetof(struct rec_buf, buf_len)));
-	rbufdata = rbuffer + offsetof(struct rec_buf, data);
+	rbuffer_len = ntohs(readw(rbuf + offsetof(struct rec_buf, buf_len)));
+	rbufdata = rbuf + offsetof(struct rec_buf, data);
 
 	if (IPv4_p) {
 		/* Copy the headers without checksumming */
@@ -1822,20 +1814,16 @@
 			    data,length<rbuffer_len?length:rbuffer_len,chksum);
 		else
 			memcpy_fromio(data, rbufdata, rbuffer_len);
-		rbuffer = ntohs(readw(rbuffer+BUFFER_POINTER_OFST)) ;
+		rbuffer = ntohs(readw(rbuf+BUFFER_POINTER_OFST)) ;
 		if (!rbuffer)
 			break;
 		rbuffer -= 2;
 		length -= rbuffer_len;
 		data += rbuffer_len;
-		if (ti->page_mask) {
-			rbuffer_page = (rbuffer >> 8) & ti->page_mask;
-			rbuffer &= ~(ti->page_mask << 8);
-		}
-		rbuffer += ti->sram_virt;
+		rbuf = map_address(ti, rbuffer, &rbuffer_page);
 		SET_PAGE(rbuffer_page);
-		rbuffer_len = ntohs(readw(rbuffer + BUFFER_LENGTH_OFST));
-		rbufdata = rbuffer + offsetof(struct rec_buf, data);
+		rbuffer_len = ntohs(readw(rbuf + BUFFER_LENGTH_OFST));
+		rbufdata = rbuf + offsetof(struct rec_buf, data);
 	}
 
 	SET_PAGE(ti->asb_page);
diff -Nru a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
--- a/drivers/net/tulip/interrupt.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/tulip/interrupt.c	2005-03-09 12:20:51 -05:00
@@ -26,7 +26,7 @@
 #define MIT_SIZE 15
 #define MIT_TABLE 15 /* We use 0 or max */
 
-unsigned int mit_table[MIT_SIZE+1] =
+static unsigned int mit_table[MIT_SIZE+1] =
 {
         /*  CRS11 21143 hardware Mitigation Control Interrupt
             We use only RX mitigation we other techniques for
diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/tun.c	2005-03-09 12:20:51 -05:00
@@ -843,7 +843,7 @@
 	.set_rx_csum	= tun_set_rx_csum
 };
 
-int __init tun_init(void)
+static int __init tun_init(void)
 {
 	int ret = 0;
 
@@ -856,7 +856,7 @@
 	return ret;
 }
 
-void tun_cleanup(void)
+static void tun_cleanup(void)
 {
 	struct tun_struct *tun, *nxt;
 
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/via-rhine.c	2005-03-09 12:20:51 -05:00
@@ -390,7 +390,7 @@
 
 #ifdef USE_MMIO
 /* Registers we check that mmio and reg are the same. */
-int mmio_verify_registers[] = {
+static const int mmio_verify_registers[] = {
 	RxConfig, TxConfig, IntrEnable, ConfigA, ConfigB, ConfigC, ConfigD,
 	0
 };
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/via-velocity.c	2005-03-09 12:20:51 -05:00
@@ -3096,7 +3096,7 @@
  *	we are interested in.
  */
 
-u16 wol_calc_crc(int size, u8 * pattern, u8 *mask_pattern)
+static u16 wol_calc_crc(int size, u8 * pattern, u8 *mask_pattern)
 {
 	u16 crc = 0xFFFF;
 	u8 mask;
diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/wan/cosa.c	2005-03-09 12:20:51 -05:00
@@ -543,7 +543,7 @@
 		 * FIXME: When this code is not used as module, we should
 		 * probably call udelay() instead of the interruptible sleep.
 		 */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		cosa_putstatus(cosa, SR_TX_INT_ENA);
 		schedule_timeout(30);
 		irq = probe_irq_off(irqs);
@@ -1564,8 +1564,7 @@
 	cosa_getdata8(cosa);
 	cosa_putstatus(cosa, SR_RST);
 #ifdef MODULE
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(HZ/2);
+	msleep(500);
 #else
 	udelay(5*100000);
 #endif
@@ -1618,7 +1617,7 @@
 			return r;
 		}
 		/* sleep if not ready to read */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(1);
 	}
 	printk(KERN_INFO "cosa: timeout in get_wait_data (status 0x%x)\n",
diff -Nru a/drivers/net/wd.c b/drivers/net/wd.c
--- a/drivers/net/wd.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/wd.c	2005-03-09 12:20:51 -05:00
@@ -131,6 +131,7 @@
 {
 	free_irq(dev->irq, dev);
 	release_region(dev->base_addr - WD_NIC_OFFSET, WD_IO_EXTENT);
+	iounmap(ei_status.mem);
 }
 
 #ifndef MODULE
@@ -317,16 +318,22 @@
 	ei_status.rx_start_page = WD_START_PG + TX_PAGES;
 
 	/* Don't map in the shared memory until the board is actually opened. */
-	ei_status.rmem_start = dev->mem_start + TX_PAGES*256;
 
 	/* Some cards (eg WD8003EBT) can be jumpered for more (32k!) memory. */
 	if (dev->mem_end != 0) {
 		ei_status.stop_page = (dev->mem_end - dev->mem_start)/256;
+		ei_status.priv = dev->mem_end - dev->mem_start;
 	} else {
 		ei_status.stop_page = word16 ? WD13_STOP_PG : WD03_STOP_PG;
 		dev->mem_end = dev->mem_start + (ei_status.stop_page - WD_START_PG)*256;
+		ei_status.priv = (ei_status.stop_page - WD_START_PG)*256;
+	}
+
+	ei_status.mem = ioremap(dev->mem_start, ei_status.priv);
+	if (!ei_status.mem) {
+		free_irq(dev->irq, dev);
+		return -ENOMEM;
 	}
-	ei_status.rmem_end = dev->mem_end;
 
 	printk(" %s, IRQ %d, shared memory at %#lx-%#lx.\n",
 		   model_name, dev->irq, dev->mem_start, dev->mem_end-1);
@@ -397,7 +404,7 @@
 {
 
 	int wd_cmdreg = dev->base_addr - WD_NIC_OFFSET; /* WD_CMDREG */
-	unsigned long hdr_start = dev->mem_start + ((ring_page - WD_START_PG)<<8);
+	void __iomem *hdr_start = ei_status.mem + ((ring_page - WD_START_PG)<<8);
 
 	/* We'll always get a 4 byte header read followed by a packet read, so
 	   we enable 16 bit mode before the header, and disable after the body. */
@@ -407,10 +414,10 @@
 #ifdef __BIG_ENDIAN
 	/* Officially this is what we are doing, but the readl() is faster */
 	/* unfortunately it isn't endian aware of the struct               */
-	isa_memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
+	memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
 	hdr->count = le16_to_cpu(hdr->count);
 #else
-	((unsigned int*)hdr)[0] = isa_readl(hdr_start);
+	((unsigned int*)hdr)[0] = readl(hdr_start);
 #endif
 }
 
@@ -423,17 +430,18 @@
 wd_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring_offset)
 {
 	int wd_cmdreg = dev->base_addr - WD_NIC_OFFSET; /* WD_CMDREG */
-	unsigned long xfer_start = dev->mem_start + ring_offset - (WD_START_PG<<8);
+	unsigned long offset = ring_offset - (WD_START_PG<<8);
+	void __iomem *xfer_start = ei_status.mem + offset;
 
-	if (xfer_start + count > ei_status.rmem_end) {
+	if (offset + count > ei_status.priv) {
 		/* We must wrap the input move. */
-		int semi_count = ei_status.rmem_end - xfer_start;
-		isa_memcpy_fromio(skb->data, xfer_start, semi_count);
+		int semi_count = ei_status.priv - offset;
+		memcpy_fromio(skb->data, xfer_start, semi_count);
 		count -= semi_count;
-		isa_memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
+		memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 	} else {
 		/* Packet is in one chunk -- we can copy + cksum. */
-		isa_eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		eth_io_copy_and_sum(skb, xfer_start, count, 0);
 	}
 
 	/* Turn off 16 bit access so that reboot works.	 ISA brain-damage */
@@ -446,16 +454,16 @@
 				int start_page)
 {
 	int wd_cmdreg = dev->base_addr - WD_NIC_OFFSET; /* WD_CMDREG */
-	long shmem = dev->mem_start + ((start_page - WD_START_PG)<<8);
+	void __iomem *shmem = ei_status.mem + ((start_page - WD_START_PG)<<8);
 
 
 	if (ei_status.word16) {
 		/* Turn on and off 16 bit access so that reboot works. */
 		outb(ISA16 | ei_status.reg5, wd_cmdreg+WD_CMDREG5);
-		isa_memcpy_toio(shmem, buf, count);
+		memcpy_toio(shmem, buf, count);
 		outb(ei_status.reg5, wd_cmdreg+WD_CMDREG5);
 	} else
-		isa_memcpy_toio(shmem, buf, count);
+		memcpy_toio(shmem, buf, count);
 }
 
 
diff -Nru a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/wireless/airo.c	2005-03-09 12:20:51 -05:00
@@ -1698,9 +1698,8 @@
 			issuecommand(ai, &cmd, &rsp);
 			up(&ai->sem);
 			/* Let the command take effect */
-			set_current_state (TASK_INTERRUPTIBLE);
 			ai->task = current;
-			schedule_timeout (3*HZ);
+			ssleep(3);
 			ai->task = NULL;
 		}
 	rc = PC4500_readrid(ai, first ? RID_BSSLISTFIRST : RID_BSSLISTNEXT,
@@ -2685,11 +2684,9 @@
 		return -1;
 	waitbusy (ai);
 	OUT4500(ai,COMMAND,CMD_SOFTRESET);
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/5);
+	msleep(200);
 	waitbusy (ai);
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/5);
+	msleep(200);
 	if (lock)
 		up(&ai->sem);
 	return 0;
@@ -5516,12 +5513,12 @@
 	} else {
 		OUT4500(ai, EVACK, EV_AWAKEN);
 		OUT4500(ai, EVACK, EV_AWAKEN);
-		schedule_timeout(HZ/10);
+		msleep(100);
 	}
 
 	set_bit (FLAG_COMMIT, &ai->flags);
 	disable_MAC(ai, 0);
-        schedule_timeout (HZ/5);
+        msleep(200);
 	if (ai->SSID) {
 		writeSsidRid(ai, ai->SSID, 0);
 		kfree(ai->SSID);
@@ -7470,8 +7467,7 @@
 
 	OUT4500(ai,COMMAND,CMD_SOFTRESET);
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* WAS 600 12/7/00 */
+	ssleep(1);			/* WAS 600 12/7/00 */
 
 	if(!waitbusy (ai)){
 		printk(KERN_INFO "Waitbusy hang AFTER RESET\n");
@@ -7498,8 +7494,7 @@
 		OUT4500(ai, SWS3, FLASH_COMMAND);
 		OUT4500(ai, COMMAND,0);
 	}
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/2); /* 500ms delay */
+	msleep(500);		/* 500ms delay */
 
 	if(!waitbusy(ai)) {
 		clear_bit (FLAG_FLASHING, &ai->flags);
@@ -7609,8 +7604,7 @@
 int flashrestart(struct airo_info *ai,struct net_device *dev){
 	int    i,status;
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* Added 12/7/00 */
+	ssleep(1);			/* Added 12/7/00 */
 	clear_bit (FLAG_FLASHING, &ai->flags);
 	if (test_bit(FLAG_MPI, &ai->flags)) {
 		status = mpi_init_descriptors(ai);
@@ -7625,8 +7619,7 @@
 				( ai, 2312, i >= MAX_FIDS / 2 );
 		}
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* Added 12/7/00 */
+	ssleep(1);			/* Added 12/7/00 */
 	return status;
 }
 #endif /* CISCO_EXT */
diff -Nru a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
--- a/drivers/net/wireless/prism54/isl_ioctl.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	2005-03-09 12:20:51 -05:00
@@ -1750,7 +1750,7 @@
 	u8 wpa_ie[MAX_WPA_IE_LEN];
 	int wpa_ie_len;
 	size_t len = 0; /* u16, better? */
-	u8 *payload = 0, *pos = 0;
+	u8 *payload = NULL, *pos = NULL;
 	int ret;
 
 	/* I think all trapable objects are listed here.
diff -Nru a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
--- a/drivers/net/wireless/ray_cs.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/wireless/ray_cs.c	2005-03-09 12:20:51 -05:00
@@ -1215,6 +1215,9 @@
 #if WIRELESS_EXT > 7
     struct iwreq *wrq = (struct iwreq *) ifr;
 #endif	/* WIRELESS_EXT > 7 */
+#ifdef WIRELESS_SPY
+    struct sockaddr	address[IW_MAX_SPY];
+#endif	/* WIRELESS_SPY */
 
     if (!(link->state & DEV_PRESENT)) {
         DEBUG(2,"ray_dev_ioctl - device not present\n");
@@ -1511,7 +1514,6 @@
       /* If there is some addresses to copy */
       if(local->spy_number > 0)
 	{
-	  struct sockaddr	address[IW_MAX_SPY];
 	  int			i;
 
 	  /* Copy addresses to the driver */
@@ -1551,7 +1553,6 @@
       /* If the user want to have the addresses back... */
       if((local->spy_number > 0) && (wrq->u.data.pointer != (caddr_t) 0))
 	{
-	  struct sockaddr	address[IW_MAX_SPY];
 	  int			i;
 
 	  /* Copy addresses from the lp structure */
diff -Nru a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
--- a/drivers/net/wireless/strip.c	2005-03-09 12:20:51 -05:00
+++ b/drivers/net/wireless/strip.c	2005-03-09 12:20:51 -05:00
@@ -876,7 +876,7 @@
  */
 static int strip_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct strip *strip_info = dev->priv;
+	struct strip *strip_info = netdev_priv(dev);
 	int old_mtu = strip_info->mtu;
 	unsigned char *orbuff = strip_info->rx_buff;
 	unsigned char *osbuff = strip_info->sx_buff;
@@ -1563,7 +1563,7 @@
 /* Encapsulate a datagram and kick it into a TTY queue. */
 static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "%s: xmit call when iface is down\n",
@@ -1639,7 +1639,7 @@
 			unsigned short type, void *daddr, void *saddr,
 			unsigned len)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 	STRIP_Header *header = (STRIP_Header *) skb_push(skb, sizeof(STRIP_Header));
 
 	/*printk(KERN_INFO "%s: strip_header 0x%04X %s\n", dev->name, type,
@@ -1648,7 +1648,7 @@
 	header->src_addr = strip_info->true_dev_addr;
 	header->protocol = htons(type);
 
-	/*HexDump("strip_header", (struct strip *)(dev->priv), skb->data, skb->data + skb->len); */
+	/*HexDump("strip_header", netdev_priv(dev), skb->data, skb->data + skb->len); */
 
 	if (!daddr)
 		return (-dev->hard_header_len);
@@ -2400,7 +2400,7 @@
 
 static int strip_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 	struct sockaddr *sa = addr;
 	printk(KERN_INFO "%s: strip_set_dev_mac_address called\n", dev->name);
 	set_mac_address(strip_info, (MetricomAddress *) sa->sa_data);
@@ -2409,8 +2409,8 @@
 
 static struct net_device_stats *strip_get_stats(struct net_device *dev)
 {
+	struct strip *strip_info = netdev_priv(dev);
 	static struct net_device_stats stats;
-	struct strip *strip_info = (struct strip *) (dev->priv);
 
 	memset(&stats, 0, sizeof(struct net_device_stats));
 
@@ -2454,7 +2454,7 @@
 
 static int strip_open_low(struct net_device *dev)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 
 	if (strip_info->tty == NULL)
 		return (-ENODEV);
@@ -2487,7 +2487,7 @@
 
 static int strip_close_low(struct net_device *dev)
 {
-	struct strip *strip_info = (struct strip *) (dev->priv);
+	struct strip *strip_info = netdev_priv(dev);
 
 	if (strip_info->tty == NULL)
 		return -EBUSY;
diff -Nru a/include/linux/dp83840.h b/include/linux/dp83840.h
--- a/include/linux/dp83840.h	2005-03-09 12:20:51 -05:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,41 +0,0 @@
-/*
- * linux/dp83840.h: definitions for DP83840 MII-compatible transceivers
- *
- * Copyright (C) 1996, 1999 David S. Miller (davem@redhat.com)
- */
-#ifndef __LINUX_DP83840_H
-#define __LINUX_DP83840_H
-
-#include <linux/mii.h>
-
-/*
- * Data sheets and programming docs for the DP83840 are available at
- * from http://www.national.com/
- *
- * The DP83840 is capable of both 10 and 100Mbps ethernet, in both
- * half and full duplex mode.  It also supports auto negotiation.
- *
- * But.... THIS THING IS A PAIN IN THE ASS TO PROGRAM!
- * Debugging eeprom burnt code is more fun than programming this chip!
- */
-
-/* First, the MII register numbers (actually DP83840 register numbers). */
-#define MII_CSCONFIG        0x17        /* CS configuration            */
-
-/* The Carrier Sense config register. */
-#define CSCONFIG_RESV1          0x0001  /* Unused...                   */
-#define CSCONFIG_LED4           0x0002  /* Pin for full-dplx LED4      */
-#define CSCONFIG_LED1           0x0004  /* Pin for conn-status LED1    */
-#define CSCONFIG_RESV2          0x0008  /* Unused...                   */
-#define CSCONFIG_TCVDISAB       0x0010  /* Turns off the transceiver   */
-#define CSCONFIG_DFBYPASS       0x0020  /* Bypass disconnect function  */
-#define CSCONFIG_GLFORCE        0x0040  /* Good link force for 100mbps */
-#define CSCONFIG_CLKTRISTATE    0x0080  /* Tristate 25m clock          */
-#define CSCONFIG_RESV3          0x0700  /* Unused...                   */
-#define CSCONFIG_ENCODE         0x0800  /* 1=MLT-3, 0=binary           */
-#define CSCONFIG_RENABLE        0x1000  /* Repeater mode enable        */
-#define CSCONFIG_TCDISABLE      0x2000  /* Disable timeout counter     */
-#define CSCONFIG_RESV4          0x4000  /* Unused...                   */
-#define CSCONFIG_NDISABLE       0x8000  /* Disable NRZI                */
-
-#endif /* __LINUX_DP83840_H */
diff -Nru a/include/linux/ibmtr.h b/include/linux/ibmtr.h
--- a/include/linux/ibmtr.h	2005-03-09 12:20:51 -05:00
+++ b/include/linux/ibmtr.h	2005-03-09 12:20:51 -05:00
@@ -169,7 +169,7 @@
 
 struct tok_info {
 	unsigned char irq;
-	void *mmio;
+	void __iomem *mmio;
 	unsigned char hw_address[32];
 	unsigned char adapter_type;
 	unsigned char data_rate;
@@ -192,12 +192,13 @@
 	/* Additions by Peter De Schrijver */
 	unsigned char page_mask;          /* mask to select RAM page to Map*/
 	unsigned char mapped_ram_size;    /* size of RAM page */
-	__u32 sram_virt;                  /* Shared memory base address */
-	__u32 init_srb;               /* Initial System Request Block address */
-	__u32 srb;                        /* System Request Block address */
-	__u32 ssb;                        /* System Status Block address */
-	__u32 arb;                        /* Adapter Request Block address */
-	__u32 asb;                        /* Adapter Status Block address */
+	__u32 sram_phys;          /* Shared memory base address */
+	void __iomem *sram_virt;          /* Shared memory base address */
+	void __iomem *init_srb;   /* Initial System Request Block address */
+	void __iomem *srb;                /* System Request Block address */
+	void __iomem *ssb;                /* System Status Block address */
+	void __iomem *arb;                /* Adapter Request Block address */
+	void __iomem *asb;                /* Adapter Status Block address */
         __u8  init_srb_page;
         __u8  srb_page;
         __u8  ssb_page;
diff -Nru a/include/net/slhc_vj.h b/include/net/slhc_vj.h
--- a/include/net/slhc_vj.h	2005-03-09 12:20:51 -05:00
+++ b/include/net/slhc_vj.h	2005-03-09 12:20:51 -05:00
@@ -185,7 +185,4 @@
 			  int isize));
 int slhc_toss __ARGS((struct slcompress *comp));
 
-void slhc_i_status __ARGS((struct slcompress *comp));
-void slhc_o_status __ARGS((struct slcompress *comp));
-
 #endif	/* _SLHC_H */

--------------000406070700040303060608--
