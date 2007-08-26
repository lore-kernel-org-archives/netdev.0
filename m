From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Sat, 25 Aug 2007 17:09:35 -0700
Message-ID: <1188086976.18004.5.camel@localhost>
References: <1187808408.4314.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2042 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933797AbXHZAKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 20:10:24 -0400
In-Reply-To: <1187808408.4314.15.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More conversions to MAC_FMT/MAC_ARG in drivers/net

These conversions are for the multiple printk uses
similar to:

	for (i = 0; i < 6; i++)
		printk("%s02x", addr[i], i==0 ? "" : ":");

Signed-off-by:  Joe Perches <joe@perches.com>

---

 drivers/net/3c503.c                  |    3 +-
 drivers/net/3c507.c                  |    8 +++---
 drivers/net/3c509.c                  |   16 +++++------
 drivers/net/3c515.c                  |    3 +-
 drivers/net/3c523.c                  |   10 +++----
 drivers/net/3c59x.c                  |    6 +---
 drivers/net/8139too.c                |   13 ++-------
 drivers/net/82596.c                  |    2 +-
 drivers/net/ac3200.c                 |    7 +++--
 drivers/net/apne.c                   |    8 +++---
 drivers/net/ariadne.c                |   49 ++++++++++++---------------------
 drivers/net/arm/am79c961a.c          |    7 +---
 drivers/net/arm/ether1.c             |    7 +---
 drivers/net/arm/ether3.c             |    7 ++---
 drivers/net/arm/etherh.c             |    7 +---
 drivers/net/at1700.c                 |    3 +-
 drivers/net/atarilance.c             |   35 +++++++++--------------
 drivers/net/atp.c                    |    7 ++---
 drivers/net/b44.c                    |    8 ++---
 drivers/net/bmac.c                   |    5 +--
 drivers/net/bnx2.c                   |   24 +++++++---------
 drivers/net/bonding/bond_main.c      |   31 ++++++---------------
 drivers/net/cris/eth_v10.c           |    8 +----
 drivers/net/cs89x0.c                 |   13 ++-------
 drivers/net/de600.c                  |    5 +---
 drivers/net/de620.c                  |    7 +++--
 drivers/net/declance.c               |   13 ++++-----
 drivers/net/depca.c                  |   11 +------
 drivers/net/dgrs.c                   |   16 +++-------
 drivers/net/dm9000.c                 |    8 ++---
 drivers/net/e1000/e1000_main.c       |    3 +-
 drivers/net/eepro.c                  |    4 +-
 drivers/net/eepro100.c               |    8 +----
 drivers/net/epic100.c                |    8 ++---
 drivers/net/es3210.c                 |   21 +++++++-------
 drivers/net/ewrk3.c                  |    9 ++----
 drivers/net/fealnx.c                 |    8 ++---
 drivers/net/fec.c                    |    6 +---
 drivers/net/gianfar.c                |    6 +---
 drivers/net/hamachi.c                |    7 +---
 drivers/net/hamradio/bpqether.c      |   23 +++++-----------
 drivers/net/hp-plus.c                |    5 ++-
 drivers/net/hp.c                     |    4 ++-
 drivers/net/ibm_emac/ibm_emac_core.c |   12 +++-----
 drivers/net/ioc3-eth.c               |   11 +------
 drivers/net/isa-skeleton.c           |    4 ++-
 drivers/net/jazzsonic.c              |    9 +-----
 drivers/net/lance.c                  |    5 ++-
 drivers/net/mac89x0.c                |   10 +++----
 drivers/net/mace.c                   |    8 ++---
 drivers/net/macmace.c                |    5 +--
 drivers/net/macsonic.c               |   10 +-----
 drivers/net/myri_sbus.c              |   26 +++++-------------
 drivers/net/natsemi.c                |   10 +++----
 drivers/net/ne-h8300.c               |    7 ++---
 drivers/net/ne2.c                    |    8 +++---
 drivers/net/ne2k-pci.c               |   10 +++---
 drivers/net/ni5010.c                 |    3 +-
 drivers/net/pci-skeleton.c           |    8 +----
 drivers/net/pcmcia/3c574_cs.c        |    8 +++---
 drivers/net/pcmcia/3c589_cs.c        |    9 +++---
 drivers/net/pcmcia/axnet_cs.c        |    8 +++---
 drivers/net/pcmcia/fmvj18x_cs.c      |    7 ++---
 drivers/net/pcmcia/smc91c92_cs.c     |    7 ++---
 drivers/net/pcmcia/xirc2ps_cs.c      |    8 ++---
 drivers/net/pppoe.c                  |    7 +---
 drivers/net/rrunner.c                |    7 +----
 drivers/net/sb1250-mac.c             |    6 +---
 drivers/net/seeq8005.c               |    3 +-
 drivers/net/sgiseeq.c                |    5 +--
 drivers/net/sis190.c                 |    9 ++----
 drivers/net/sis900.c                 |    8 ++---
 drivers/net/smc-mca.c                |    7 +++--
 drivers/net/smc-ultra.c              |    7 +++--
 drivers/net/smc-ultra32.c            |    7 +++--
 drivers/net/smc9194.c                |    6 +---
 drivers/net/smc91x.c                 |    8 ++---
 drivers/net/starfire.c               |   21 ++++++--------
 drivers/net/sun3lance.c              |   34 +++++++++--------------
 drivers/net/sunbmac.c                |    7 +---
 drivers/net/sundance.c               |    9 ++----
 drivers/net/sungem.c                 |   11 +++-----
 drivers/net/sunhme.c                 |   10 +-----
 drivers/net/sunlance.c               |    8 +----
 drivers/net/tokenring/abyss.c        |    9 ++----
 drivers/net/tokenring/ibmtr.c        |    5 +--
 drivers/net/tokenring/lanstreamer.c  |   34 +++++++++--------------
 drivers/net/tokenring/madgemc.c      |   14 +++-------
 drivers/net/tokenring/olympic.c      |   27 +++++--------------
 drivers/net/tokenring/proteon.c      |    7 +---
 drivers/net/tokenring/skisa.c        |    7 +---
 drivers/net/tokenring/tmspci.c       |    9 ++----
 drivers/net/tulip/de2104x.c          |    8 +----
 drivers/net/tulip/de4x5.c            |   23 +++-------------
 drivers/net/tulip/dmfe.c             |   14 +++++-----
 drivers/net/tulip/tulip_core.c       |   13 +++-----
 drivers/net/tulip/winbond-840.c      |   26 +++++++----------
 drivers/net/tulip/xircom_cb.c        |    8 ++---
 drivers/net/typhoon.c                |    9 ++----
 drivers/net/via-rhine.c              |   12 +++-----
 drivers/net/wd.c                     |    6 +++-
 101 files changed, 391 insertions(+), 672 deletions(-)

diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index bc7e906..f141a4c 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -228,7 +228,8 @@ el2_probe1(struct net_device *dev, int ioaddr)
 
     /* Retrieve and print the ethernet address. */
     for (i = 0; i < 6; i++)
-	printk(" %2.2x", dev->dev_addr[i] = inb(ioaddr + i));
+	dev->dev_addr[i] = inb(ioaddr + i);
+    printk(MAC_FMT, MAC_ARG(dev->dev_addr));
 
     /* Map the 8390 back into the window. */
     outb(ECNTRL_THIN, ioaddr + 0x406);
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index eed4299..eda670f 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -388,7 +388,7 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 	if (net_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk("%s: 3c507 at %#x,", dev->name, ioaddr);
+	printk("%s: 3c507 at %#x, ", dev->name, ioaddr);
 
 	/* We should make a few more checks here, like the first three octets of
 	   the S.A. for the manufacturer's code. */
@@ -397,6 +397,7 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 
 	irqval = request_irq(irq, &el16_interrupt, 0, DRV_NAME, dev);
 	if (irqval) {
+		printk("\n");
 		printk(KERN_ERR "3c507: unable to get IRQ %d (irqval=%d).\n", irq, irqval);
 		retval = -EAGAIN;
 		goto out;
@@ -406,10 +407,9 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 	dev->base_addr = ioaddr;
 
 	outb(0x01, ioaddr + MISC_CTRL);
-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + i);
-		printk(" %02x", dev->dev_addr[i]);
-	}
+	printk(MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	if (mem_start)
 		net_debug = mem_start & 7;
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 127f608..1f6e950 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -313,7 +313,6 @@ static int nopnp;
 static int __init el3_common_init(struct net_device *dev)
 {
 	struct el3_private *lp = netdev_priv(dev);
-	short i;
 	int err;
 
 	spin_lock_init(&lp->lock);
@@ -348,15 +347,14 @@ static int __init el3_common_init(struct net_device *dev)
 
 	{
 		const char *if_names[] = {"10baseT", "AUI", "undefined", "BNC"};
-		printk("%s: 3c5x9 found at %#3.3lx, %s port, address ",
-			dev->name, dev->base_addr,
-			if_names[(dev->if_port & 0x03)]);
-	}
+		printk("%s: 3c5x9 found at %#3.3lx, %s port, "
+		       "address " MAC_FMT ", IRQ %d.\n",
+		       dev->name, dev->base_addr,
+		       if_names[(dev->if_port & 0x03)],
+		       MAC_ARG(dev->dev_addr), dev->irq);
 
-	/* Read in the station address. */
-	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i]);
-	printk(", IRQ %d.\n", dev->irq);
+
+	}
 
 	if (el3_debug > 0)
 		printk(KERN_INFO "%s", version);
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 290166d..a079d32 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -632,8 +632,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	checksum = (checksum ^ (checksum >> 8)) & 0xff;
 	if (checksum != 0x00)
 		printk(" ***INVALID CHECKSUM %4.4x*** ", checksum);
-	for (i = 0; i < 6; i++)
-		printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
+	printk(" " MAC_FMT, MAC_ARG(dev->dev_addr));
 	if (eeprom[16] == 0x11c7) {	/* Corkscrew */
 		if (request_dma(dev->dma, "3c515")) {
 			printk(", DMA %d allocation failed", dev->dma);
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index ab18343..0359365 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -383,8 +383,7 @@ void alloc586(struct net_device *dev)
 static int elmc_getinfo(char *buf, int slot, void *d)
 {
 	int len = 0;
-	struct net_device *dev = (struct net_device *) d;
-	int i;
+	struct net_device *dev = d;
 
 	if (dev == NULL)
 		return len;
@@ -545,12 +544,11 @@ static int __init do_elmc_probe(struct net_device *dev)
 
 	/* The hardware address for the 3c523 is stored in the first six
 	   bytes of the IO address. */
-	printk(KERN_INFO "%s: hardware address ", dev->name);
 	for (i = 0; i < 6; i++) {
 		dev->dev_addr[i] = inb(dev->base_addr + i);
-		printk(" %02x", dev->dev_addr[i]);
-	}
-	printk("\n");
+
+	printk(KERN_INFO "%s: hardware address " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	dev->open = &elmc_open;
 	dev->stop = &elmc_close;
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index a8c0f43..b2d5d20 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1203,10 +1203,8 @@ static int __devinit vortex_probe1(struct device *gendev,
 	for (i = 0; i < 3; i++)
 		((u16 *)dev->dev_addr)[i] = htons(eeprom[i + 10]);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-	if (print_info) {
-		for (i = 0; i < 6; i++)
-			printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
-	}
+	if (print_info)
+		printk(" " MAC_FMT, MAC_ARG(dev->dev_addr));
 	/* Unfortunately an all zero eeprom passes the checksum and this
 	   gets found in the wild in failure cases. Crypto is hard 8) */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 538493d..31679f8 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1023,16 +1023,9 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 
 	pci_set_drvdata (pdev, dev);
 
-	printk (KERN_INFO "%s: %s at 0x%lx, "
-		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-		"IRQ %d\n",
-		dev->name,
-		board_info[ent->driver_data].name,
-		dev->base_addr,
-		dev->dev_addr[0], dev->dev_addr[1],
-		dev->dev_addr[2], dev->dev_addr[3],
-		dev->dev_addr[4], dev->dev_addr[5],
-		dev->irq);
+	printk (KERN_INFO "%s: %s at 0x%lx, " MAC_FMT ", IRQ %d\n",
+		dev->name, board_info[ent->driver_data].name, dev->base_addr,
+		MAC_ARG(dev->dev_addr), dev->irq);
 
 	printk (KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
 		dev->name, rtl_chip_info[tp->chipset].name);
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 2f718e4..8fb314d 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1562,7 +1562,7 @@ static void set_multicast_list(struct net_device *dev)
 			memcpy(cp, dmi->dmi_addr, 6);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address " MAC_FMT "\n",
-						dev->name, MAC_ARG(cp));
+						dev->name, MAC_ARG(cp)));
 		}
 		i596_add_cmd(dev, &cmd->cmd);
 	}
diff --git a/drivers/net/ac3200.c b/drivers/net/ac3200.c
index 644c408..1c725ef 100644
--- a/drivers/net/ac3200.c
+++ b/drivers/net/ac3200.c
@@ -169,10 +169,11 @@ static int __init ac_probe1(int ioaddr, struct net_device *dev)
 		   inb(ioaddr + AC_ID_PORT + 2), inb(ioaddr + AC_ID_PORT + 3));
 #endif
 
-	printk("AC3200 in EISA slot %d, node", ioaddr/0x1000);
-	for(i = 0; i < 6; i++)
-		printk(" %02x", dev->dev_addr[i] = inb(ioaddr + AC_SA_PROM + i));
+	for (i = 0; i < 6; i++)
+		dev->dev_addr[i] = inb(ioaddr + AC_SA_PROM + i);
 
+	printk(KERN_DEBUG "AC3200 in EISA slot %d, node " MAC_FMT,
+	       ioaddr/0x1000, MAC_ARG(dev->dev_addr));
 #if 0
 	/* Check the vendor ID/prefix. Redundant after checking the EISA ID */
 	if (inb(ioaddr + AC_SA_PROM + 0) != AC_ADDR0
diff --git a/drivers/net/apne.c b/drivers/net/apne.c
index 9541911..d295278 100644
--- a/drivers/net/apne.c
+++ b/drivers/net/apne.c
@@ -317,12 +317,12 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
     i = request_irq(dev->irq, apne_interrupt, IRQF_SHARED, DRV_NAME, dev);
     if (i) return i;
 
-    for(i = 0; i < ETHER_ADDR_LEN; i++) {
-	printk(" %2.2x", SA_prom[i]);
+    for(i = 0; i < ETHER_ADDR_LEN; i++)
 	dev->dev_addr[i] = SA_prom[i];
-    }
 
-    printk("\n%s: %s found.\n", dev->name, name);
+    printk(" " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
+
+    printk("%s: %s found.\n", dev->name, name);
 
     ei_status.name = name;
     ei_status.tx_start_page = start_page;
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index 1e5fa70..bcadd28 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -613,21 +613,15 @@ static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
     /* Fill in a Tx ring entry */
 
 #if 0
-    printk(KERN_DEBUG "TX pkt type 0x%04x from ", ((u_short *)skb->data)[6]);
-    {
-	int i;
-	u_char *ptr = &((u_char *)skb->data)[6];
-	for (i = 0; i < 6; i++)
-	    printk("%02x", ptr[i]);
-    }
-    printk(" to ");
-    {
-	int i;
-	u_char *ptr = (u_char *)skb->data;
-	for (i = 0; i < 6; i++)
-	    printk("%02x", ptr[i]);
-    }
-    printk(" data 0x%08x len %d\n", (int)skb->data, (int)skb->len);
+{
+    printk(KERN_DEBUG "TX pkt type 0x%04x"
+	   " from " MAC_FMT " to " MAC_FMT
+	   " data 0x%08x len %d\n",
+	   ((u_short *)skb->data)[6],
+	   MAC_ARG(((u_char *)skb->data)+6),
+	   MAC_ARG((u_char *)skb->data),
+	   (int)skb->data, (int)skb->len);
+}
 #endif
 
     local_irq_save(flags);
@@ -747,22 +741,15 @@ static int ariadne_rx(struct net_device *dev)
 	    skb_copy_to_linear_data(skb, (char *)priv->rx_buff[entry], pkt_len);
 	    skb->protocol=eth_type_trans(skb,dev);
 #if 0
-	    printk(KERN_DEBUG "RX pkt type 0x%04x from ",
-		   ((u_short *)skb->data)[6]);
-	    {
-		int i;
-		u_char *ptr = &((u_char *)skb->data)[6];
-		for (i = 0; i < 6; i++)
-		    printk("%02x", ptr[i]);
-	    }
-	    printk(" to ");
-	    {
-		int i;
-		u_char *ptr = (u_char *)skb->data;
-		for (i = 0; i < 6; i++)
-		    printk("%02x", ptr[i]);
-	    }
-	    printk(" data 0x%08x len %d\n", (int)skb->data, (int)skb->len);
+{
+	    printk(KERN_DEBUG "RX pkt type 0x%04x"
+		   " from " MAC_FMT " to " MAC_FMT
+		   " data 0x%08x len %d\n",
+		   ((u_short *)skb->data)[6],
+		   MAC_ARG(((u_char *)skb->data)+6),
+		   MAC_ARG((u_char *)skb->data),
+		   (int)skb->data, (int)skb->len);
+}
 #endif
 
 	    netif_rx(skb);
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 2143eeb..b699557 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -741,12 +741,9 @@ static int __init am79c961_probe(struct platform_device *pdev)
 
 	ret = register_netdev(dev);
 	if (ret == 0) {
-		printk(KERN_INFO "%s: ether address ", dev->name);
-
-		/* Retrive and print the ethernet address. */
-		for (i = 0; i < 6; i++)
-			printk (i == 5 ? "%02x\n" : "%02x:", dev->dev_addr[i]);
 
+		printk(KERN_INFO "%s: ether address " MAC_FMT "\n",
+		       dev->name, MAC_ARG(dev->dev_addr));
 		return 0;
 	}
 
diff --git a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
index 80f33b6..714aa43 100644
--- a/drivers/net/arm/ether1.c
+++ b/drivers/net/arm/ether1.c
@@ -1044,12 +1044,9 @@ ether1_probe(struct expansion_card *ec, const struct ecard_id *id)
 	if (ret)
 		goto free;
 
-	printk(KERN_INFO "%s: ether1 in slot %d, ",
-		dev->name, ec->slot_no);
+	printk(KERN_INFO "%s: ether1 in slot %d, " MAC_FMT "\n",
+		dev->name, ec->slot_no, MAC_ARG(dev->dev_addr));
     
-	for (i = 0; i < 6; i++)
-		printk ("%2.2x%c", dev->dev_addr[i], i == 5 ? '\n' : ':');
-
 	ecard_set_drvdata(ec, dev);
 	return 0;
 
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 3805506..f05bb98 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -775,7 +775,7 @@ ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 {
 	const struct ether3_data *data = id->data;
 	struct net_device *dev;
-	int i, bus_type, ret;
+	int bus_type, ret;
 
 	ether3_banner();
 
@@ -859,9 +859,8 @@ ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 	if (ret)
 		goto free;
 
-	printk("%s: %s in slot %d, ", dev->name, data->name, ec->slot_no);
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i], i == 5 ? '\n' : ':');
+	printk("%s: %s in slot %d, " MAC_FMT "\n",
+	       dev->name, data->name, ec->slot_no, MAC_ARG(dev->dev_addr));
 
 	ecard_set_drvdata(ec, dev);
 	return 0;
diff --git a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
index 0d37d9d..dd40c5f 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/arm/etherh.c
@@ -746,11 +746,8 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 	if (ret)
 		goto free;
 
-	printk(KERN_INFO "%s: %s in slot %d, ",
-		dev->name, data->name, ec->slot_no);
-
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i], i == 5 ? '\n' : ':');
+	printk(KERN_INFO "%s: %s in slot %d, " MAC_FMT "\n",
+		dev->name, data->name, ec->slot_no, MAC_ARG(dev->dev_addr));
 
 	ecard_set_drvdata(ec, dev);
 
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index bed8e0e..6631510 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -392,16 +392,15 @@ found:
 	if (is_at1700) {
 		for(i = 0; i < 3; i++) {
 			unsigned short eeprom_val = read_eeprom(ioaddr, 4+i);
-			printk("%04x", eeprom_val);
 			((unsigned short *)dev->dev_addr)[i] = ntohs(eeprom_val);
 		}
 	} else {
 		for(i = 0; i < 6; i++) {
 			unsigned char val = inb(ioaddr + SAPROM + i);
-			printk("%02x", val);
 			dev->dev_addr[i] = val;
 		}
 	}
+	printk(MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	/* The EEPROM word 12 bit 0x0400 means use regular 100 ohm 10baseT signals,
 	   rather than 150 ohm shielded twisted pair compensation.
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index dfa8b9b..c508469 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -598,8 +598,7 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 		i = IO->mem;
 		break;
 	}
-	for( i = 0; i < 6; ++i )
-		printk( "%02x%s", dev->dev_addr[i], (i < 5) ? ":" : "\n" );
+	printk(MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 	if (lp->cardtype == OLD_RIEBL) {
 		printk( "%s: Warning: This is a default ethernet address!\n",
 				dev->name );
@@ -812,17 +811,12 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
 	/* Fill in a Tx ring entry */
 	if (lance_debug >= 3) {
-		u_char *p;
-		int i;
-		printk( "%s: TX pkt type 0x%04x from ", dev->name,
-				((u_short *)skb->data)[6]);
-		for( p = &((u_char *)skb->data)[6], i = 0; i < 6; i++ )
-			printk("%02x%s", *p++, i != 5 ? ":" : "" );
-		printk(" to ");
-		for( p = (u_char *)skb->data, i = 0; i < 6; i++ )
-			printk("%02x%s", *p++, i != 5 ? ":" : "" );
-		printk(" data at 0x%08x len %d\n", (int)skb->data,
-			   (int)skb->len );
+		printk( "%s: TX pkt type 0x%04x from "
+			MAC_FMT " to " EUI48_FMT
+			" data at 0x%08x len %d\n",
+			dev->name, ((u_short *)skb->data)[6],
+			MAC_ARG(&skb->data[6]), MAC_ARG(skb->data),
+			(int)skb->data, (int)skb->len );
 	}
 
 	/* We're not prepared for the int until the last flags are set/reset. And
@@ -1032,14 +1026,13 @@ static int lance_rx( struct net_device *dev )
 				}
 
 				if (lance_debug >= 3) {
-					u_char *data = PKTBUF_ADDR(head), *p;
-					printk( "%s: RX pkt type 0x%04x from ", dev->name,
-							((u_short *)data)[6]);
-					for( p = &data[6], i = 0; i < 6; i++ )
-						printk("%02x%s", *p++, i != 5 ? ":" : "" );
-					printk(" to ");
-					for( p = data, i = 0; i < 6; i++ )
-						printk("%02x%s", *p++, i != 5 ? ":" : "" );
+					u_char *data = PKTBUF_ADDR(head);
+
+					printk( "%s: RX pkt type 0x%04x from "
+						MAC_FMT " to " EUI48_FMT,
+						dev->name, ((u_short *)data)[6],
+						MAC_ARG(&data[6]), MAC_ARG(data));
+
 					printk(" data %02x %02x %02x %02x %02x %02x %02x %02x "
 						   "len %d\n",
 						   data[15], data[16], data[17], data[18],
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 82d78ff..88eccd0 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -325,10 +325,9 @@ static int __init atp_probe1(long ioaddr)
 		printk(KERN_INFO "%s", version);
 #endif
 
-	printk(KERN_NOTICE "%s: Pocket adapter found at %#3lx, IRQ %d, SAPROM "
-		   "%02X:%02X:%02X:%02X:%02X:%02X.\n", dev->name, dev->base_addr,
-		   dev->irq, dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		   dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	printk(KERN_NOTICE "%s: Pocket adapter found at %#3lx, IRQ %d, "
+	       "SAPROM " MAC_FMT ".\n",
+	       dev->name, dev->base_addr, dev->irq, MAC_ARG(dev->dev_addr));
 
 	/* Reset the ethernet hardware and activate the printer pass-through. */
 	write_reg_high(ioaddr, CMR1, CMR1h_RESET | CMR1h_MUX);
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 60b3d56..c36d780 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2099,7 +2099,7 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 	unsigned long b44reg_base, b44reg_len;
 	struct net_device *dev;
 	struct b44 *bp;
-	int err, i;
+	int err;
 
 	if (b44_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -2229,10 +2229,8 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 	 */
 	b44_chip_reset(bp);
 
-	printk(KERN_INFO "%s: Broadcom 4400 10/100BaseT Ethernet ", dev->name);
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i],
-		       i == 5 ? '\n' : ':');
+	printk(KERN_INFO "%s: Broadcom 4400 10/100BaseT Ethernet " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	return 0;
 
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 9b8d7d9..668a5d2 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1365,9 +1365,8 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
 		goto err_out_irq2;
 	}
 
-	printk(KERN_INFO "%s: BMAC%s at", dev->name, (is_bmac_plus? "+": ""));
-	for (j = 0; j < 6; ++j)
-		printk("%c%.2x", (j? ':': ' '), dev->dev_addr[j]);
+	printk(KERN_INFO "%s: BMAC%s at " MAC_FMT,
+	       dev->name, (is_bmac_plus ? "+" : ""), MAC_ARG(dev->dev_addr));
 	XXDEBUG((", base_addr=%#0lx", dev->base_addr));
 	printk("\n");
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7afffc4..bc23d87 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6811,7 +6811,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	static int version_printed = 0;
 	struct net_device *dev = NULL;
 	struct bnx2 *bp;
-	int rc, i;
+	int rc;
 	char str[40];
 
 	if (version_printed++ == 0)
@@ -6880,19 +6880,15 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	printk(KERN_INFO "%s: %s (%c%d) %s found at mem %lx, "
-		"IRQ %d, ",
-		dev->name,
-		bp->name,
-		((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
-		((CHIP_ID(bp) & 0x0ff0) >> 4),
-		bnx2_bus_string(bp, str),
-		dev->base_addr,
-		bp->pdev->irq);
-
-	printk("node addr ");
-	for (i = 0; i < 6; i++)
-		printk("%2.2x", dev->dev_addr[i]);
-	printk("\n");
+	       "IRQ %d, node addr " MAC_FMT "\n",
+	       dev->name,
+	       bp->name,
+	       ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
+	       ((CHIP_ID(bp) & 0x0ff0) >> 4),
+	       bnx2_bus_string(bp, str),
+	       dev->base_addr,
+	       bp->pdev->irq,
+	       MAC_ARG(dev->dev_addr));
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1afda32..d03d264 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1630,19 +1630,13 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 				 ETH_ALEN);
 	if (!mac_addr_differ && (bond->slave_cnt > 1)) {
 		printk(KERN_WARNING DRV_NAME
-		       ": %s: Warning: the permanent HWaddr of %s "
-		       "- %02X:%02X:%02X:%02X:%02X:%02X - is "
-		       "still in use by %s. Set the HWaddr of "
-		       "%s to a different address to avoid "
-		       "conflicts.\n",
+		       ": %s: Warning: the permanent HWaddr of %s - "
+		       MAC_FMT " - is still in use by %s. "
+		       "Set the HWaddr of %s to a different address "
+		       "to avoid conflicts.\n",
 		       bond_dev->name,
 		       slave_dev->name,
-		       slave->perm_hwaddr[0],
-		       slave->perm_hwaddr[1],
-		       slave->perm_hwaddr[2],
-		       slave->perm_hwaddr[3],
-		       slave->perm_hwaddr[4],
-		       slave->perm_hwaddr[5],
+		       MAC_ARG(slave->perm_hwaddr),
 		       bond_dev->name,
 		       slave_dev->name);
 	}
@@ -3021,13 +3015,8 @@ static void bond_info_show_master(struct seq_file *seq)
 				   ad_info.actor_key);
 			seq_printf(seq, "\tPartner Key: %d\n",
 				   ad_info.partner_key);
-			seq_printf(seq, "\tPartner Mac Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-				   ad_info.partner_system[0],
-				   ad_info.partner_system[1],
-				   ad_info.partner_system[2],
-				   ad_info.partner_system[3],
-				   ad_info.partner_system[4],
-				   ad_info.partner_system[5]);
+			seq_printf(seq, "\tPartner Mac Address: " MAC_FMT "\n",
+				   MAC_ARG(ad_info.partner_system));
 		}
 	}
 }
@@ -3043,10 +3032,8 @@ static void bond_info_show_slave(struct seq_file *seq, const struct slave *slave
 		   slave->link_failure_count);
 
 	seq_printf(seq,
-		   "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
-		   slave->perm_hwaddr[0], slave->perm_hwaddr[1],
-		   slave->perm_hwaddr[2], slave->perm_hwaddr[3],
-		   slave->perm_hwaddr[4], slave->perm_hwaddr[5]);
+		   "Permanent HW addr: " MAC_FMT "\n",
+		   MAC_ARG(slave->perm_hwaddr));
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		const struct aggregator *agg
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 5bdf5ca..918380e 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -618,12 +618,8 @@ e100_set_mac_address(struct net_device *dev, void *p)
 
 	/* show it in the log as well */
 
-	printk(KERN_INFO "%s: changed MAC to ", dev->name);
-
-	for (i = 0; i < 5; i++)
-		printk("%02X:", dev->dev_addr[i]);
-
-	printk("%02X\n", dev->dev_addr[i]);
+	printk(KERN_INFO "%s: changed MAC to " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	spin_unlock(&np->lock);
 
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 9774bb1..d342326 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -841,11 +841,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	}
 
 	/* print the ethernet address. */
-	printk(", MAC");
-	for (i = 0; i < ETH_ALEN; i++)
-	{
-		printk("%c%02x", i ? ':' : ' ', dev->dev_addr[i]);
-	}
+	printk(", MAC " MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	dev->open		= net_open;
 	dev->stop		= net_close;
@@ -1807,17 +1803,14 @@ static int set_mac_address(struct net_device *dev, void *p)
 	int i;
 	struct sockaddr *addr = p;
 
-
 	if (netif_running(dev))
 		return -EBUSY;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	if (net_debug) {
-		printk("%s: Setting MAC address to ", dev->name);
-		for (i = 0; i < dev->addr_len; i++)
-			printk(" %2.2x", dev->dev_addr[i]);
-		printk(".\n");
+		printk("%s: Setting MAC address to " MAC_FMT ".\n",
+		       dev->name, MAC_ARG(dev->dev_addr));
 	}
 	/* set the Ethernet address */
 	for (i=0; i < ETH_ALEN/2; i++)
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index dae97b8..cb8c338 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -444,10 +444,7 @@ static struct net_device * __init de600_probe(void)
 		goto out1;
 	}
 
-	printk(", Ethernet Address: %02X", dev->dev_addr[0]);
-	for (i = 1; i < ETH_ALEN; i++)
-		printk(":%02X",dev->dev_addr[i]);
-	printk("\n");
+	printk(", Ethernet Address: " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 
 	dev->get_stats = get_stats;
 
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index dc48924..687326b 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -866,13 +866,14 @@ struct net_device * __init de620_probe(int unit)
 	}
 
 	/* else, got it! */
-	printk(", Ethernet Address: %2.2X",
-		dev->dev_addr[0] = nic_data.NodeID[0]);
+	dev->dev_addr[0] = nic_data.NodeID[0];
 	for (i = 1; i < ETH_ALEN; i++) {
-		printk(":%2.2X", dev->dev_addr[i] = nic_data.NodeID[i]);
+		dev->dev_addr[i] = nic_data.NodeID[i];
 		dev->broadcast[i] = 0xff;
 	}
 
+	printk(", Ethernet Address: " MAC_FMT, MAC_ARG(dev->dev_addr));
+
 	printk(" (%dk RAM,",
 		(nic_data.RAM_Size) ? (nic_data.RAM_Size >> 2) : 64);
 
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index b2577f4..0dcf9df 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -1223,21 +1223,20 @@ static int __init dec_lance_probe(struct device *bdev, const int type)
 	 */
 	switch (type) {
 	case ASIC_LANCE:
-		printk("%s: IOASIC onboard LANCE, addr = ", name);
+		printk("%s: IOASIC onboard LANCE", name);
 		break;
 	case PMAD_LANCE:
-		printk("%s: PMAD-AA, addr = ", name);
+		printk("%s: PMAD-AA", name);
 		break;
 	case PMAX_LANCE:
-		printk("%s: PMAX onboard LANCE, addr = ", name);
+		printk("%s: PMAX onboard LANCE", name);
 		break;
 	}
-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = esar[i * 4];
-		printk("%2.2x%c", dev->dev_addr[i], i == 5 ? ',' : ':');
-	}
 
-	printk(" irq = %d\n", dev->irq);
+	printk(", addr = " MAC_FMT ", irq = %d\n",
+	       MAC_ARG(dev->dev_addr), dev->irq);
 
 	dev->open = &lance_open;
 	dev->stop = &lance_close;
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 1834970..3340482 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -634,14 +634,11 @@ static int __init depca_hw_init (struct net_device *dev, struct device *device)
 
 	printk(", h/w address ");
 	status = get_hw_addr(dev);
+	printk(MAC_FMT, MAC_ARG(dev->dev_addr));
 	if (status != 0) {
 		printk("      which has an Ethernet PROM CRC error.\n");
 		return -ENXIO;
 	}
-	for (i = 0; i < ETH_ALEN - 1; i++) {	/* get the ethernet address */
-		printk("%2.2x:", dev->dev_addr[i]);
-	}
-	printk("%2.2x", dev->dev_addr[i]);
 
 	/* Set up the maximum amount of network RAM(kB) */
 	netRAM = ((lp->adapter != DEPCA) ? 64 : 48);
@@ -1893,11 +1890,7 @@ static void depca_dbg_open(struct net_device *dev)
 		printk("...0x%8.8x\n", readl(&lp->tx_ring[i].base));
 		printk("Initialisation block at 0x%8.8lx(Phys)\n", lp->mem_start);
 		printk("        mode: 0x%4.4x\n", p->mode);
-		printk("        physical address: ");
-		for (i = 0; i < ETH_ALEN - 1; i++) {
-			printk("%2.2x:", p->phys_addr[i]);
-		}
-		printk("%2.2x\n", p->phys_addr[i]);
+		printk("        physical address: " MAC_FMT "\n", MAC_ARG(p->phys_addr));
 		printk("        multicast hash table: ");
 		for (i = 0; i < (HASH_TABLE_LEN >> 3) - 1; i++) {
 			printk("%2.2x:", p->mcast_table[i]);
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
index df62c02..a41f0da 100644
--- a/drivers/net/dgrs.c
+++ b/drivers/net/dgrs.c
@@ -1169,11 +1169,9 @@ dgrs_probe1(struct net_device *dev)
 	/*
 	 * Get ether address of board
 	 */
-	printk("%s: Ethernet address", dev->name);
 	memcpy(dev->dev_addr, priv->port->ethaddr, 6);
-	for (i = 0; i < 6; ++i)
-		printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
-	printk("\n");
+	printk("%s: Ethernet address " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	if (dev->dev_addr[0] & 1)
 	{
@@ -1230,15 +1228,11 @@ static int __init
 dgrs_initclone(struct net_device *dev)
 {
 	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
-	int		i;
 
-	printk("%s: Digi RightSwitch port %d ",
-		dev->name, priv->chan);
-	for (i = 0; i < 6; ++i)
-		printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
-	printk("\n");
+	printk("%s: Digi RightSwitch port %d " MAC_FMT "\n",
+		dev->name, priv->chan, MAC_ARG(dev->dev_addr));
 
-	return (0);
+	return 0;
 }
 
 static struct net_device * __init
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index c3de81b..8ea92cd 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -600,11 +600,9 @@ dm9000_probe(struct platform_device *pdev)
 	ret = register_netdev(ndev);
 
 	if (ret == 0) {
-		printk("%s: dm9000 at %p,%p IRQ %d MAC: ",
-		       ndev->name,  db->io_addr, db->io_data, ndev->irq);
-		for (i = 0; i < 5; i++)
-			printk("%02x:", ndev->dev_addr[i]);
-		printk("%02x\n", ndev->dev_addr[5]);
+		printk("%s: dm9000 at %p,%p IRQ %d MAC: " MAC_FMT "\n",
+		       ndev->name,  db->io_addr, db->io_data, ndev->irq,
+		       MAC_ARG(ndev->dev_addr));
 	}
 	return 0;
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 249cc84..408db03 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1131,8 +1131,7 @@ e1000_probe(struct pci_dev *pdev,
 		 "32-bit"));
 	}
 
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", netdev->dev_addr[i], i == 5 ? '\n' : ':');
+	printk(MAC_FMT "\n", MAC_ARG(netdev->dev_addr));
 
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 4768023..7d36471 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -717,10 +717,10 @@ static void __init eepro_print_info (struct net_device *dev)
 		case LAN595:
 			printk("%s: Intel 82595-based lan card at %#x,",
 					dev->name, (unsigned)dev->base_addr);
+			break;
 	}
 
-	for (i=0; i < 6; i++)
-		printk("%c%02x", i ? ':' : ' ', dev->dev_addr[i]);
+	printk(" " MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	if (net_debug > 3)
 		printk(KERN_DEBUG ", %dK RCV buffer",
diff --git a/drivers/net/eepro100.c b/drivers/net/eepro100.c
index 3c54014..3ef5506 100644
--- a/drivers/net/eepro100.c
+++ b/drivers/net/eepro100.c
@@ -706,12 +706,8 @@ static int __devinit speedo_found1(struct pci_dev *pdev,
 	else
 		product = pci_name(pdev);
 
-	printk(KERN_INFO "%s: %s, ", dev->name, product);
-
-	for (i = 0; i < 5; i++)
-		printk("%2.2X:", dev->dev_addr[i]);
-	printk("%2.2X, ", dev->dev_addr[i]);
-	printk("IRQ %d.\n", pdev->irq);
+	printk(KERN_INFO "%s: %s, " MAC_FMT ", IRQ %d.\n", dev->name, product,
+		   MAC_ARG(dev->dev_addr), pdev->irq);
 
 	sp = netdev_priv(dev);
 
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 211909d..842c386 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -494,11 +494,9 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	if (ret < 0)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ",
-		   dev->name, pci_id_tbl[chip_idx].name, ioaddr, dev->irq);
-	for (i = 0; i < 5; i++)
-		printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x.\n", dev->dev_addr[i]);
+	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, " MAC_FMT "\n",
+	       dev->name, pci_id_tbl[chip_idx].name, ioaddr, dev->irq,
+	       MAC_ARG(dev->dev_addr));
 
 out:
 	return ret;
diff --git a/drivers/net/es3210.c b/drivers/net/es3210.c
index 822e5bf..c3b79f4 100644
--- a/drivers/net/es3210.c
+++ b/drivers/net/es3210.c
@@ -192,7 +192,6 @@ static int __init es_probe1(struct net_device *dev, int ioaddr)
 		inb(ioaddr + ES_CFG4), inb(ioaddr + ES_CFG5), inb(ioaddr + ES_CFG6));
 #endif
 
-
 /*	Check the EISA ID of the card. */
 	eisa_id = inl(ioaddr + ES_ID_PORT);
 	if ((eisa_id != ES_EISA_ID1) && (eisa_id != ES_EISA_ID2)) {
@@ -200,21 +199,21 @@ static int __init es_probe1(struct net_device *dev, int ioaddr)
 		goto out;
 	}
 
+	for (i = 0; i < ETHER_ADDR_LEN ; i++)
+		dev->dev_addr[i] = inb(ioaddr + ES_SA_PROM + i);
+
 /*	Check the Racal vendor ID as well. */
-	if (inb(ioaddr + ES_SA_PROM + 0) != ES_ADDR0
-		|| inb(ioaddr + ES_SA_PROM + 1) != ES_ADDR1
-		|| inb(ioaddr + ES_SA_PROM + 2) != ES_ADDR2 ) {
-		printk("es3210.c: card not found");
-		for(i = 0; i < ETHER_ADDR_LEN; i++)
-			printk(" %02x", inb(ioaddr + ES_SA_PROM + i));
-		printk(" (invalid prefix).\n");
+	if (dev->dev_addr[0] != ES_ADDR0 ||
+	    dev->dev_addr[1] != ES_ADDR1 ||
+	    dev->dev_addr[2] != ES_ADDR2) {
+		printk("es3210.c: card not found " MAC_FMT
+		       " (invalid_prefix).\n", MAC_ARG(dev->dev_addr));
 		retval = -ENODEV;
 		goto out;
 	}
 
-	printk("es3210.c: ES3210 rev. %ld at %#x, node", eisa_id>>24, ioaddr);
-	for(i = 0; i < ETHER_ADDR_LEN; i++)
-		printk(" %02x", (dev->dev_addr[i] = inb(ioaddr + ES_SA_PROM + i)));
+	printk("es3210.c: ES3210 rev. %ld at %#x", eisa_id>>24, ioaddr);
+	printk(", node " MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	/* Snarf the interrupt now. */
 	if (dev->irq == 0) {
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index cb0792c..04594fe 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -632,7 +632,7 @@ static int ewrk3_open(struct net_device *dev)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
 	u_long iobase = dev->base_addr;
-	int i, status = 0;
+	int status = 0;
 	u_char icr, csr;
 
 	/*
@@ -653,11 +653,8 @@ static int ewrk3_open(struct net_device *dev)
 
 			if (ewrk3_debug > 1) {
 				printk("%s: ewrk3 open with irq %d\n", dev->name, dev->irq);
-				printk("  physical address: ");
-				for (i = 0; i < 5; i++) {
-					printk("%2.2x:", (u_char) dev->dev_addr[i]);
-				}
-				printk("%2.2x\n", (u_char) dev->dev_addr[i]);
+				printk("  physical address: " MAC_FMT "\n",
+				       MAC_ARG(dev->dev_addr));
 				if (lp->shmem_length == 0) {
 					printk("  no shared memory, I/O only mode\n");
 				} else {
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index ff9f177..d7b48ab 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -665,11 +665,9 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 	if (err)
 		goto err_out_free_tx;
 
-	printk(KERN_INFO "%s: %s at %p, ",
-	       dev->name, skel_netdrv_tbl[chip_id].chip_name, ioaddr);
-	for (i = 0; i < 5; i++)
-		printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], irq);
+	printk(KERN_INFO "%s: %s at %p, " MAC_FMT ", IRQ %d.\n",
+	       dev->name, skel_netdrv_tbl[chip_id].chip_name, ioaddr,
+	       MAC_ARG(dev->dev_addr), irq);
 
 	return 0;
 
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 4e8df91..bd8b29c 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -2663,10 +2663,8 @@ static int __init fec_enet_module_init(void)
 			return -EIO;
 		}
 
-		printk("%s: ethernet ", dev->name);
-		for (j = 0; (j < 5); j++)
-			printk("%02x:", dev->dev_addr[j]);
-		printk("%02x\n", dev->dev_addr[5]);
+		printk("%s: ethernet " MAC_FMT "\n",
+		       dev->name, MAC_ARG(dev->dev_addr));
 	}
 	return 0;
 }
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 89c2fb4..9f03b0b 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -361,10 +361,8 @@ static int gfar_probe(struct platform_device *pdev)
 	gfar_init_sysfs(dev);
 
 	/* Print out the device info */
-	printk(KERN_INFO DEVICE_NAME, dev->name);
-	for (idx = 0; idx < 6; idx++)
-		printk("%2.2x%c", dev->dev_addr[idx], idx == 5 ? ' ' : ':');
-	printk("\n");
+	printk(KERN_INFO DEVICE_NAME MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks. */
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 15254dc..13acd9a 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -742,12 +742,9 @@ static int __devinit hamachi_init_one (struct pci_dev *pdev,
 		goto err_out_unmap_rx;
 	}
 
-	printk(KERN_INFO "%s: %s type %x at %p, ",
+	printk(KERN_INFO "%s: %s type %x at %p, " MAC_FMT ", IRQ %d.\n",
 		   dev->name, chip_tbl[chip_id].name, readl(ioaddr + ChipRev),
-		   ioaddr);
-	for (i = 0; i < 5; i++)
-			printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], irq);
+		   ioaddr, MAC_ARG(dev->dev_addr), irq);
 	i = readb(ioaddr + PCIClkMeas);
 	printk(KERN_INFO "%s:  %d-bit %d Mhz PCI bus (%d), Virtual Jumpers "
 		   "%2.2x, LPA %4.4x.\n",
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index cc0ee93..76aae05 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -64,6 +64,7 @@
 #include <net/ax25.h>
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
@@ -94,7 +95,6 @@ static char bpq_eth_addr[6];
 
 static int bpq_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
 static int bpq_device_event(struct notifier_block *, unsigned long, void *);
-static const char *bpq_print_ethaddr(const unsigned char *);
 
 static struct packet_type bpq_packet_type = {
 	.type	= __constant_htons(ETH_P_BPQ),
@@ -379,16 +379,6 @@ static int bpq_close(struct net_device *dev)
 /*
  *	Proc filesystem
  */
-static const char * bpq_print_ethaddr(const unsigned char *e)
-{
-	static char buf[18];
-
-	sprintf(buf, "%2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X",
-		e[0], e[1], e[2], e[3], e[4], e[5]);
-
-	return buf;
-}
-
 static void *bpq_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	int i = 1;
@@ -435,13 +425,14 @@ static int bpq_seq_show(struct seq_file *seq, void *v)
 	else {
 		const struct bpqdev *bpqdev = v;
 
-		seq_printf(seq, "%-5s %-10s %s  ",
+		seq_printf(seq, "%-5s %-10s " MAC_FMT "  ",
 			bpqdev->axdev->name, bpqdev->ethdev->name,
-			bpq_print_ethaddr(bpqdev->dest_addr));
+			MAC_ARG(bpqdev->dest_addr));
 
-		seq_printf(seq, "%s\n",
-			(bpqdev->acpt_addr[0] & 0x01) ? "*" 
-			   : bpq_print_ethaddr(bpqdev->acpt_addr));
+		if (is_multicast_ether_addr(bpqdev->acpt_addr))
+			seq_printf(seq, "*\n");
+		else
+			seq_printf(seq, MAC_FMT "\n", MAC_ARG(bpqdev->acpt_addr));
 
 	}
 	return 0;
diff --git a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
index 99a36cc..36ecf91 100644
--- a/drivers/net/hp-plus.c
+++ b/drivers/net/hp-plus.c
@@ -182,7 +182,7 @@ static int __init hpp_probe1(struct net_device *dev, int ioaddr)
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk("%s: %s at %#3x,", dev->name, name, ioaddr);
+	printk("%s: %s at %#3x, ", dev->name, name, ioaddr);
 
 	/* Retrieve and checksum the station address. */
 	outw(MAC_Page, ioaddr + HP_PAGING);
@@ -191,10 +191,11 @@ static int __init hpp_probe1(struct net_device *dev, int ioaddr)
 		unsigned char inval = inb(ioaddr + 8 + i);
 		dev->dev_addr[i] = inval;
 		checksum += inval;
-		printk(" %2.2x", inval);
 	}
 	checksum += inb(ioaddr + 14);
 
+	printk(MAC_FMT, MAC_ARG(dev->dev_addr));
+
 	if (checksum != 0xff) {
 		printk(" bad checksum %2.2x.\n", checksum);
 		retval = -ENODEV;
diff --git a/drivers/net/hp.c b/drivers/net/hp.c
index 635b13c..5d24787 100644
--- a/drivers/net/hp.c
+++ b/drivers/net/hp.c
@@ -160,7 +160,9 @@ static int __init hp_probe1(struct net_device *dev, int ioaddr)
 	printk("%s: %s (ID %02x) at %#3x,", dev->name, name, board_id, ioaddr);
 
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
-		printk(" %2.2x", dev->dev_addr[i] = inb(ioaddr + i));
+		dev->dev_addr[i] = inb(ioaddr + i);
+
+	printk(" " MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	/* Snarf the interrupt now.  Someday this could be moved to open(). */
 	if (dev->irq < 2) {
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index f752e5f..9c9214c 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -353,10 +353,8 @@ static void emac_hash_mc(struct ocp_enet_private *dev)
 
 	for (dmi = dev->ndev->mc_list; dmi; dmi = dmi->next) {
 		int bit;
-		DBG2("%d: mc %02x:%02x:%02x:%02x:%02x:%02x" NL,
-		     dev->def->index,
-		     dmi->dmi_addr[0], dmi->dmi_addr[1], dmi->dmi_addr[2],
-		     dmi->dmi_addr[3], dmi->dmi_addr[4], dmi->dmi_addr[5]);
+		DBG2("%d: mc " MAC_FMT NL,
+		     dev->def->index, MAC_ARG(dmi->dmi_addr));
 
 		bit = 63 - (ether_crc(ETH_ALEN, dmi->dmi_addr) >> 26);
 		gaht[bit >> 4] |= 0x8000 >> (bit & 0x0f);
@@ -2191,10 +2189,8 @@ static int __init emac_probe(struct ocp_device *ocpdev)
 
 	ocp_set_drvdata(ocpdev, dev);
 
-	printk("%s: emac%d, MAC %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       ndev->name, dev->def->index,
-	       ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
-	       ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
+	printk("%s: emac%d, MAC " MAC_FMT "\n",
+	       ndev->name, dev->def->index, MAC_ARG(ndev->dev_addr));
 
 	if (dev->phy.address >= 0)
 		printk("%s: found %s PHY (0x%02x)\n", ndev->name,
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index cc0be53..f07a333 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -443,18 +443,11 @@ static void ioc3_get_eaddr_nic(struct ioc3_private *ip)
  */
 static void ioc3_get_eaddr(struct ioc3_private *ip)
 {
-	int i;
-
 
 	ioc3_get_eaddr_nic(ip);
 
-	printk("Ethernet address is ");
-	for (i = 0; i < 6; i++) {
-		printk("%02x", priv_netdev(ip)->dev_addr[i]);
-		if (i < 5)
-			printk(":");
-	}
-	printk(".\n");
+	printk("Ethernet address is " MAC_FMT ".\n",
+	       MAC_ARG(priv_netdev(ip)->dev_addr));
 }
 
 static void __ioc3_set_mac_address(struct net_device *dev)
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 0343f12..885837e 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -219,7 +219,9 @@ static int __init netcard_probe1(struct net_device *dev, int ioaddr)
 
 	/* Retrieve and print the ethernet address. */
 	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i] = inb(ioaddr + i));
+		dev->dev_addr[i] = inb(ioaddr + i);
+
+	printk(MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	err = -EAGAIN;
 #ifdef jumpered_interrupts
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 75f6f44..434a46a 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -255,13 +255,8 @@ static int __init jazz_sonic_probe(struct platform_device *pdev)
 	if (err)
 		goto out1;
 
-	printk("%s: MAC ", dev->name);
-	for (i = 0; i < 6; i++) {
-		printk("%2.2x", dev->dev_addr[i]);
-		if (i < 5)
-			printk(":");
-	}
-	printk(" IRQ %d\n", dev->irq);
+	printk("%s: MAC " MAC_FMT " IRQ %d\n",
+	       dev->name, MAC_ARG(dev->dev_addr), dev->irq);
 
 	return 0;
 
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index a4e5fab..993a899 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -523,12 +523,13 @@ static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int
 	   a ISA DMA-able region. */
 	SET_MODULE_OWNER(dev);
 	chipname = chip_table[lance_version].name;
-	printk("%s: %s at %#3x,", dev->name, chipname, ioaddr);
+	printk("%s: %s at %#3x, ", dev->name, chipname, ioaddr);
 
 	/* There is a 16 byte station address PROM at the base address.
 	   The first six bytes are the station address. */
 	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i] = inb(ioaddr + i));
+		dev->dev_addr[i] = inb(ioaddr + i);
+	printk(MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	dev->base_addr = ioaddr;
 	/* Make certain the data structures used by the LANCE are aligned and DMAble. */
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 62c1c62..c4bb9c1 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -274,13 +274,11 @@ struct net_device * __init mac89x0_probe(int unit)
         }
 
 	dev->irq = SLOT2IRQ(slot);
-	printk(" IRQ %d ADDR ", dev->irq);
 
-	/* print the ethernet address. */
-	for (i = 0; i < ETH_ALEN; i++)
-		printk("%2.2x%s", dev->dev_addr[i],
-		       ((i < ETH_ALEN-1) ? ":" : ""));
-	printk("\n");
+	/* print the IRQ and ethernet address. */
+
+	printk(" IRQ %d ADDR " MAC_FMT "\n",
+	       dev->irq, MAC_ARG(dev->dev_addr));
 
 	dev->open		= net_open;
 	dev->stop		= net_close;
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 52b9332..2be2677 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -245,11 +245,9 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 		goto err_free_rx_irq;
 	}
 
-	printk(KERN_INFO "%s: MACE at", dev->name);
-	for (j = 0; j < 6; ++j) {
-		printk("%c%.2x", (j? ':': ' '), dev->dev_addr[j]);
-	}
-	printk(", chip revision %d.%d\n", mp->chipid >> 8, mp->chipid & 0xff);
+	printk(KERN_INFO "%s: MACE at " MAC_FMT ", chip revision %d.%d\n",
+	       dev->name, MAC_ARG(dev->dev_addr),
+	       mp->chipid >> 8, mp->chipid & 0xff);
 
 	return 0;
 
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 9a343b9..9697270 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -254,9 +254,8 @@ static int __devinit mace_probe(struct platform_device *pdev)
 	dev->set_multicast_list	= mace_set_multicast;
 	dev->set_mac_address	= mace_set_address;
 
-	printk(KERN_INFO "%s: 68K MACE, hardware address %.2X", dev->name, dev->dev_addr[0]);
-	for (j = 1 ; j < 6 ; j++) printk(":%.2X", dev->dev_addr[j]);
-	printk("\n");
+	printk(KERN_INFO "%s: 68K MACE, hardware address " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	err = register_netdev(dev);
 	if (!err)
diff --git a/drivers/net/macsonic.c b/drivers/net/macsonic.c
index e9ecdbf..fb3a07a 100644
--- a/drivers/net/macsonic.c
+++ b/drivers/net/macsonic.c
@@ -567,7 +567,6 @@ static int __init mac_sonic_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct sonic_local *lp;
 	int err;
-	int i;
 
 	dev = alloc_etherdev(sizeof(struct sonic_local));
 	if (!dev)
@@ -592,13 +591,8 @@ found:
 	if (err)
 		goto out;
 
-	printk("%s: MAC ", dev->name);
-	for (i = 0; i < 6; i++) {
-		printk("%2.2x", dev->dev_addr[i]);
-		if (i < 5)
-			printk(":");
-	}
-	printk(" IRQ %d\n", dev->irq);
+	printk("%s: MAC " MAC_FMT " IRQ %d\n",
+	       dev->name, MAC_ARG(dev->dev_addr), dev->irq);
 
 	return 0;
 
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 1224ba3..e90b656 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -311,12 +311,10 @@ static void myri_is_not_so_happy(struct myri_eth *mp)
 #ifdef DEBUG_HEADER
 static void dump_ehdr(struct ethhdr *ehdr)
 {
-	printk("ehdr[h_dst(%02x:%02x:%02x:%02x:%02x:%02x)"
-	       "h_source(%02x:%02x:%02x:%02x:%02x:%02x)h_proto(%04x)]\n",
-	       ehdr->h_dest[0], ehdr->h_dest[1], ehdr->h_dest[2],
-	       ehdr->h_dest[3], ehdr->h_dest[4], ehdr->h_dest[4],
-	       ehdr->h_source[0], ehdr->h_source[1], ehdr->h_source[2],
-	       ehdr->h_source[3], ehdr->h_source[4], ehdr->h_source[4],
+	printk("ehdr[h_dst(" MAC_FMT ")"
+	       "h_source(" MAC_FMT ")"
+	       "h_proto(%04x)]\n",
+	       MAC_ARG(ehdr->h_dest), EUI48_2(ehdr->h_source),
 	       ehdr->h_proto);
 }
 
@@ -325,13 +323,7 @@ static void dump_ehdr_and_myripad(unsigned char *stuff)
 	struct ethhdr *ehdr = (struct ethhdr *) (stuff + 2);
 
 	printk("pad[%02x:%02x]", stuff[0], stuff[1]);
-	printk("ehdr[h_dst(%02x:%02x:%02x:%02x:%02x:%02x)"
-	       "h_source(%02x:%02x:%02x:%02x:%02x:%02x)h_proto(%04x)]\n",
-	       ehdr->h_dest[0], ehdr->h_dest[1], ehdr->h_dest[2],
-	       ehdr->h_dest[3], ehdr->h_dest[4], ehdr->h_dest[4],
-	       ehdr->h_source[0], ehdr->h_source[1], ehdr->h_source[2],
-	       ehdr->h_source[3], ehdr->h_source[4], ehdr->h_source[4],
-	       ehdr->h_proto);
+	dump_ehdr(ehdr);
 }
 #endif
 
@@ -1092,12 +1084,8 @@ static int __devinit myri_ether_init(struct sbus_dev *sdev)
 
 	num++;
 
-	printk("%s: MyriCOM MyriNET Ethernet ", dev->name);
-
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i],
-		       i == 5 ? ' ' : ':');
-	printk("\n");
+	printk("%s: MyriCOM MyriNET Ethernet " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	return 0;
 
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 8f80970..e973776 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -959,12 +959,10 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 		goto err_create_file;
 
 	if (netif_msg_drv(np)) {
-		printk(KERN_INFO "natsemi %s: %s at %#08lx (%s), ",
-			dev->name, natsemi_pci_info[chip_idx].name, iostart,
-			pci_name(np->pci_dev));
-		for (i = 0; i < ETH_ALEN-1; i++)
-				printk("%02x:", dev->dev_addr[i]);
-		printk("%02x, IRQ %d", dev->dev_addr[i], irq);
+		printk(KERN_INFO "natsemi %s: %s at %#08lx "
+		       "(%s), " MAC_FMT ", IRQ %d",
+		       dev->name, natsemi_pci_info[chip_idx].name, iostart,
+		       pci_name(np->pci_dev), MAC_ARG(dev->dev_addr), irq);
 		if (dev->if_port == PORT_TP)
 			printk(", port TP.\n");
 		else if (np->ignore_phy)
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index 38fd525..a4ad58b 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -298,12 +298,11 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 
 	dev->base_addr = ioaddr;
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++) {
-		printk(" %2.2x", SA_prom[i]);
+	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
-	}
+	printk(" " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 
-	printk("\n%s: %s found at %#x, using IRQ %d.\n",
+	printk("%s: %s found at %#x, using IRQ %d.\n",
 		dev->name, name, ioaddr, dev->irq);
 
 	ei_status.name = name;
diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
index 089b5bb..0f7337d 100644
--- a/drivers/net/ne2.c
+++ b/drivers/net/ne2.c
@@ -471,12 +471,12 @@ static int __init ne2_probe1(struct net_device *dev, int slot)
 
 	dev->base_addr = base_addr;
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++) {
-		printk(" %2.2x", SA_prom[i]);
+	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
-	}
 
-	printk("\n%s: %s found at %#x, using IRQ %d.\n",
+	printk(" " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
+
+	printk("%s: %s found at %#x, using IRQ %d.\n",
 			dev->name, name, base_addr, dev->irq);
 
 	mca_set_adapter_procfn(slot, (MCA_ProcFn) ne2_procinfo, dev);
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index f81d939..8a57858 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -366,12 +366,12 @@ static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
 	if (i)
 		goto err_out_free_netdev;
 
-	printk("%s: %s found at %#lx, IRQ %d, ",
-		   dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq);
-	for(i = 0; i < 6; i++) {
-		printk("%2.2X%s", SA_prom[i], i == 5 ? ".\n": ":");
+	for(i = 0; i < 6; i++)
 		dev->dev_addr[i] = SA_prom[i];
-	}
+	printk("%s: %s found at %#lx, IRQ %d, " MAC_FMT ".\n",
+	       dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq,
+	       MAC_ARG(dev->dev_addr));
+
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	return 0;
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 22a3b3d..28602dc 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -272,8 +272,9 @@ static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
 
 	for (i=0; i<6; i++) {
 		outw(i, IE_GP);
-		printk("%2.2x ", dev->dev_addr[i] = inb(IE_SAPROM));
+		dev->dev_addr[i] = inb(IE_SAPROM);
 	}
+	printk(MAC_FMT " ", MAC_ARG(dev->dev_addr));
 
 	PRINTK2((KERN_DEBUG "%s: I/O #4 passed!\n", dev->name));
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 3cdbe11..612e6e5 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -800,15 +800,11 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 
 	tp->phys[0] = 32;
 
-	printk (KERN_INFO "%s: %s at 0x%lx, "
-		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-		"IRQ %d\n",
+	printk (KERN_INFO "%s: %s at 0x%lx, " MAC_FMT "IRQ %d\n",
 		dev->name,
 		board_info[ent->driver_data].name,
 		dev->base_addr,
-		dev->dev_addr[0], dev->dev_addr[1],
-		dev->dev_addr[2], dev->dev_addr[3],
-		dev->dev_addr[4], dev->dev_addr[5],
+		MAC_ARG(dev->dev_addr),
 		dev->irq);
 
 	printk (KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 2b395ee..536f571 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -458,10 +458,10 @@ static int tc574_config(struct pcmcia_device *link)
 
 	strcpy(lp->node.dev_name, dev->name);
 
-	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, hw_addr ",
-		   dev->name, cardname, dev->base_addr, dev->irq);
-	for (i = 0; i < 6; i++)
-		printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : ".\n"));
+	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, "
+	       "hw_addr " MAC_FMT ".\n",
+	       dev->name, cardname, dev->base_addr, dev->irq,
+	       MAC_ARG(dev->dev_addr));
 	printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
 		   8 << config.u.ram_size, ram_split[config.u.ram_split],
 		   config.u.autoselect ? "autoselect " : "");
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 503f268..0bd8014 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -331,11 +331,10 @@ static int tc589_config(struct pcmcia_device *link)
 
     strcpy(lp->node.dev_name, dev->name);
 
-    printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, hw_addr ",
-	   dev->name, (multi ? "562" : "589"), dev->base_addr,
-	   dev->irq);
-    for (i = 0; i < 6; i++)
-	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
+    printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, "
+	   "hw_addr " MAC_FMT "\n",
+	   dev->name, (multi ? "562" : "589"), dev->base_addr, dev->irq,
+	   MAC_ARG(dev->dev_addr));
     printk(KERN_INFO "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
 	   (fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
 	   if_names[dev->if_port]);
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 50dff1b..9df3124 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -403,11 +403,11 @@ static int axnet_config(struct pcmcia_device *link)
 
     strcpy(info->node.dev_name, dev->name);
 
-    printk(KERN_INFO "%s: Asix AX88%d90: io %#3lx, irq %d, hw_addr ",
+    printk(KERN_INFO "%s: Asix AX88%d90: io %#3lx, irq %d, "
+	   "hw_addr " MAC_FMT "\n",
 	   dev->name, ((info->flags & IS_AX88790) ? 7 : 1),
-	   dev->base_addr, dev->irq);
-    for (i = 0; i < 6; i++)
-	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
+	   dev->base_addr, dev->irq,
+	   MAC_ARG(dev->dev_addr));
     if (info->phy_id != -1) {
 	DEBUG(0, "  MII transceiver at index %d, status %x.\n", info->phy_id, j);
     } else {
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 85d5f2c..5a1c105 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -534,11 +534,10 @@ static int fmvj18x_config(struct pcmcia_device *link)
     strcpy(lp->node.dev_name, dev->name);
 
     /* print current configuration */
-    printk(KERN_INFO "%s: %s, sram %s, port %#3lx, irq %d, hw_addr ", 
+    printk(KERN_INFO "%s: %s, sram %s, port %#3lx, irq %d, "
+	   "hw_addr " MAC_FMT "\n", 
 	   dev->name, card_name, sram_config == 0 ? "4K TX*2" : "8K TX*2", 
-	   dev->base_addr, dev->irq);
-    for (i = 0; i < 6; i++)
-	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
+	   dev->base_addr, dev->irq, MAC_ARG(dev->dev_addr));
 
     return 0;
     
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index af6728c..28e4e36 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1075,10 +1075,9 @@ static int smc91c92_config(struct pcmcia_device *link)
     strcpy(smc->node.dev_name, dev->name);
 
     printk(KERN_INFO "%s: smc91c%s rev %d: io %#3lx, irq %d, "
-	   "hw_addr ", dev->name, name, (rev & 0x0f), dev->base_addr,
-	   dev->irq);
-    for (i = 0; i < 6; i++)
-	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
+	   "hw_addr " MAC_FMT "\n",
+	   dev->name, name, (rev & 0x0f), dev->base_addr, dev->irq,
+	   MAC_ARG(dev->dev_addr));
 
     if (rev > 0) {
 	if (mir & 0x3ff)
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 258d6f3..d83a288 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1033,11 +1033,9 @@ xirc2ps_config(struct pcmcia_device * link)
     strcpy(local->node.dev_name, dev->name);
 
     /* give some infos about the hardware */
-    printk(KERN_INFO "%s: %s: port %#3lx, irq %d, hwaddr",
-	 dev->name, local->manf_str,(u_long)dev->base_addr, (int)dev->irq);
-    for (i = 0; i < 6; i++)
-	printk("%c%02X", i?':':' ', dev->dev_addr[i]);
-    printk("\n");
+    printk(KERN_INFO "%s: %s: port %#3lx, irq %d, hwaddr " MAC_FMT "\n",
+	   dev->name, local->manf_str,(u_long)dev->base_addr, (int)dev->irq,
+	   MAC_ARG(dev->dev_addr));
 
     return 0;
 
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 68631a5..4c27377 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -981,11 +981,8 @@ static int pppoe_seq_show(struct seq_file *seq, void *v)
 	po = v;
 	dev_name = po->pppoe_pa.dev;
 
-	seq_printf(seq, "%08X %02X:%02X:%02X:%02X:%02X:%02X %8s\n",
-		   po->pppoe_pa.sid,
-		   po->pppoe_pa.remote[0], po->pppoe_pa.remote[1],
-		   po->pppoe_pa.remote[2], po->pppoe_pa.remote[3],
-		   po->pppoe_pa.remote[4], po->pppoe_pa.remote[5], dev_name);
+	seq_printf(seq, "%08X " MAC_FMT " %8s\n",
+		   po->pppoe_pa.sid, MAC_ARG(po->pppoe_pa.remote), dev_name);
 out:
 	return 0;
 }
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 5c2e41f..15e3c52 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -522,7 +522,6 @@ static int __devinit rr_init(struct net_device *dev)
 	struct rr_regs __iomem *regs;
 	struct eeprom *hw = NULL;
 	u32 sram_size, rev;
-	int i;
 
 	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
@@ -560,11 +559,7 @@ static int __devinit rr_init(struct net_device *dev)
 	*(u32 *)(dev->dev_addr+2) =
 	  htonl(rr_read_eeprom_word(rrpriv, &hw->manf.BoardULA[4]));
 
-	printk("  MAC: ");
-
-	for (i = 0; i < 5; i++)
-		printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x\n", dev->dev_addr[i]);
+	printk("  MAC: " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 
 	sram_size = rr_read_eeprom_word(rrpriv, (void *)8);
 	printk("  SRAM size 0x%06x\n", sram_size);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 8386ba8..775394a 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2490,10 +2490,8 @@ static int sbmac_init(struct net_device *dev, int idx)
 	 * was being displayed)
 	 */
 	printk(KERN_INFO
-	       "%s: SiByte Ethernet at 0x%08lX, address: %02X:%02X:%02X:%02X:%02X:%02X\n",
-	       dev->name, dev->base_addr,
-	       eaddr[0],eaddr[1],eaddr[2],eaddr[3],eaddr[4],eaddr[5]);
-
+	       "%s: SiByte Ethernet at 0x%08lX, address: " MAC_FMT "\n",
+	       dev->name, dev->base_addr, MAC_ARG(eaddr));
 
 	return 0;
 
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index 4bce7c4..f5d31c1 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -303,7 +303,8 @@ static int __init seeq8005_probe1(struct net_device *dev, int ioaddr)
 
 	/* Retrieve and print the ethernet address. */
 	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i] = SA_prom[i+6]);
+		dev->dev_addr[i] = SA_prom[i+6];
+	printk(MAC_FMT, MAC_ARG(dev->dev_addr));
 
 	if (dev->irq == 0xff)
 		;			/* Do nothing: a user-level program will set it. */
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 384b468..824eaaf 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -711,9 +711,8 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 		goto err_out_free_page;
 	}
 
-	printk(KERN_INFO "%s: %s ", dev->name, sgiseeqstr);
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i], i == 5 ? '\n' : ':');
+	printk(KERN_INFO "%s: %s " MAC_FMT "\n",
+	       dev->name, sgiseeqstr, MAC_ARG(dev->dev_addr));
 
 	return 0;
 
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 038ccfb..764421c 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1819,12 +1819,9 @@ static int __devinit sis190_init_one(struct pci_dev *pdev,
 		goto err_remove_mii;
 
 	net_probe(tp, KERN_INFO "%s: %s at %p (IRQ: %d), "
-	       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
-	       pci_name(pdev), sis_chip_info[ent->driver_data].name,
-	       ioaddr, dev->irq,
-	       dev->dev_addr[0], dev->dev_addr[1],
-	       dev->dev_addr[2], dev->dev_addr[3],
-	       dev->dev_addr[4], dev->dev_addr[5]);
+		  MAC_FMT "\n",
+		  pci_name(pdev), sis_chip_info[ent->driver_data].name,
+		  ioaddr, dev->irq, MAC_ARG(dev->dev_addr));
 
 	net_probe(tp, KERN_INFO "%s: %s mode.\n", dev->name,
 		  (tp->features & F_HAS_RGMII) ? "RGMII" : "GMII");
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 7c6e480..610e502 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -537,11 +537,9 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 		goto err_unmap_rx;
 
 	/* print some information about our NIC */
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ", net_dev->name,
-	       card_name, ioaddr, net_dev->irq);
-	for (i = 0; i < 5; i++)
-		printk("%2.2x:", (u8)net_dev->dev_addr[i]);
-	printk("%2.2x.\n", net_dev->dev_addr[i]);
+	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, " MAC_FMT "\n",
+	       net_dev->name, card_name, ioaddr, net_dev->irq,
+	       MAC_ARG(net_dev->dev_addr));
 
 	/* Detect Wake on Lan support */
 	ret = (inl(net_dev->base_addr + CFGPMC) & PMESP) >> 27;
diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index ae1ae34..4ebc807 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -331,10 +331,11 @@ static int __init ultramca_probe(struct device *gen_dev)
 	reg4 = inb(ioaddr + 4) & 0x7f;
 	outb(reg4, ioaddr + 4);
 
-	printk(KERN_INFO "smc_mca[%d]: Parameters: %#3x,", slot + 1, ioaddr);
-
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
+
+	printk(KERN_INFO "smc_mca[%d]: Parameters: %#3x, " MAC_FMT,
+	       slot + 1, ioaddr, MAC_ARG(dev->dev_addr));
 
 	/* Switch from the station address to the alternate register set
 	 * and read the useful registers there.
diff --git a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
index a52b22d..e89d7f7 100644
--- a/drivers/net/smc-ultra.c
+++ b/drivers/net/smc-ultra.c
@@ -226,10 +226,11 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 
 	model_name = (idreg & 0xF0) == 0x20 ? "SMC Ultra" : "SMC EtherEZ";
 
-	printk("%s: %s at %#3x,", dev->name, model_name, ioaddr);
-
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
+
+	printk("%s: %s at %#3x, " MAC_FMT, dev->name, model_name,
+	       ioaddr, MAC_ARG(dev->dev_addr));
 
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
diff --git a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
index 88a30e5..3b7589a 100644
--- a/drivers/net/smc-ultra32.c
+++ b/drivers/net/smc-ultra32.c
@@ -205,10 +205,11 @@ static int __init ultra32_probe1(struct net_device *dev, int ioaddr)
 
 	model_name = "SMC Ultra32";
 
-	printk("%s: %s at 0x%X,", dev->name, model_name, ioaddr);
-
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
+
+	printk("%s: %s at 0x%X, " MAC_FMT,
+	       dev->name, model_name, ioaddr, MAC_ARG(dev->dev_addr));
 
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 36c1eba..9645657 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -891,6 +891,7 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	word memory_info_register;
 	word memory_cfg_register;
 
+
 	/* Grab the region so that no one else tries to probe our ioports. */
 	if (!request_region(ioaddr, SMC_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -1046,10 +1047,7 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	/*
 	 . Print the Ethernet address
 	*/
-	printk("ADDR: ");
-	for (i = 0; i < 5; i++)
-		printk("%2.2x:", dev->dev_addr[i] );
-	printk("%2.2x \n", dev->dev_addr[5] );
+	printk("ADDR: " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 
 	/* set the private data to zero by default */
 	memset(dev->priv, 0, sizeof(struct smc_local));
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 01cc3c7..7d16d3b 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1842,7 +1842,7 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr)
 {
 	struct smc_local *lp = netdev_priv(dev);
 	static int version_printed = 0;
-	int i, retval;
+	int retval;
 	unsigned int val, revision_register;
 	const char *version_string;
 
@@ -2035,10 +2035,8 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr)
 			       "set using ifconfig\n", dev->name);
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: ", dev->name);
-			for (i = 0; i < 5; i++)
-				printk("%2.2x:", dev->dev_addr[i]);
-			printk("%2.2x\n", dev->dev_addr[5]);
+			printk("%s: Ethernet addr: " MAC_FMT "\n",
+			       dev->name, MAC_ARG(dev->dev_addr));
 		}
 
 		if (lp->phy_type == 0) {
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 2f172a2..016d097 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -864,11 +864,9 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	if (register_netdev(dev))
 		goto err_out_cleardev;
 
-	printk(KERN_INFO "%s: %s at %p, ",
-		   dev->name, netdrv_tbl[chip_idx].name, base);
-	for (i = 0; i < 5; i++)
-		printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], irq);
+	printk(KERN_INFO "%s: %s at %p, " MAC_FMT ", IRQ %d.\n",
+	       dev->name, netdrv_tbl[chip_idx].name, base,
+	       MAC_ARG(dev->dev_addr), irq);
 
 	if (drv_flags & CanHaveMII) {
 		int phy, phy_idx = 0;
@@ -1470,13 +1468,12 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 		}
 #ifndef final_version			/* Remove after testing. */
 		/* You will want this info for the initial debug. */
-		if (debug > 5)
-			printk(KERN_DEBUG "  Rx data %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:"
-			       "%2.2x %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x %2.2x%2.2x.\n",
-			       skb->data[0], skb->data[1], skb->data[2], skb->data[3],
-			       skb->data[4], skb->data[5], skb->data[6], skb->data[7],
-			       skb->data[8], skb->data[9], skb->data[10],
-			       skb->data[11], skb->data[12], skb->data[13]);
+		if (debug > 5) {
+			printk(KERN_DEBUG "  Rx data " MAC_FMT " " MAC_FMT
+			       " %2.2x%2.2x.\n",
+			       MAC_ARG(&skb->data[0]), MAC_ARG(&skb->data[6]),
+			       skb->data[12], skb->data[13]);
+		}
 #endif
 
 		skb->protocol = eth_type_trans(skb, dev);
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index f1548c0..1a9b607 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -378,8 +378,7 @@ static int __init lance_probe( struct net_device *dev)
 	MEM->init.hwaddr[4] = dev->dev_addr[5];
 	MEM->init.hwaddr[5] = dev->dev_addr[4];
 
-	for( i = 0; i < 6; ++i )
-		printk( "%02x%s", dev->dev_addr[i], (i < 5) ? ":" : "\n" );
+	printk(MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 
 	MEM->init.mode = 0x0000;
 	MEM->init.filter[0] = 0x00000000;
@@ -596,17 +595,12 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	/* Fill in a Tx ring entry */
 #if 0
 	if (lance_debug >= 2) {
-		u_char *p;
-		int i;
-		printk( "%s: TX pkt %d type 0x%04x from ", dev->name,
-			lp->new_tx, ((u_short *)skb->data)[6]);
-		for( p = &((u_char *)skb->data)[6], i = 0; i < 6; i++ )
-			printk("%02x%s", *p++, i != 5 ? ":" : "" );
-		printk(" to ");
-		for( p = (u_char *)skb->data, i = 0; i < 6; i++ )
-			printk("%02x%s", *p++, i != 5 ? ":" : "" );
-		printk(" data at 0x%08x len %d\n", (int)skb->data,
-		       (int)skb->len );
+		printk( "%s: TX pkt %d type 0x%04x"
+			" from " MAC_FMT " to " MAC_FMT
+			" data at 0x%08x len %d\n",
+			dev->name, lp->new_tx, ((u_short *)skb->data)[6],
+			MAC_ARG(&skb->data[6]), MAC_ARG(skb->data),
+			(int)skb->data, (int)skb->len );
 	}
 #endif
 	/* We're not prepared for the int until the last flags are set/reset.
@@ -831,13 +825,13 @@ static int lance_rx( struct net_device *dev )
 
 #if 0
 				if (lance_debug >= 3) {
-					u_char *data = PKTBUF_ADDR(head), *p;
-					printk( "%s: RX pkt %d type 0x%04x from ", dev->name, entry, ((u_short *)data)[6]);
-					for( p = &data[6], i = 0; i < 6; i++ )
-						printk("%02x%s", *p++, i != 5 ? ":" : "" );
-					printk(" to ");
-					for( p = data, i = 0; i < 6; i++ )
-						printk("%02x%s", *p++, i != 5 ? ":" : "" );
+					u_char *data = PKTBUF_ADDR(head);
+
+					printk("%s: RX pkt %d type 0x%04x"
+					       " from " MAC_FMT " to " MAC_FMT,
+					       dev->name, lp->new_tx, ((u_short *)data)[6],
+					       MAC_ARG(&data[6]), MAC_ARG(data));
+
 					printk(" data %02x %02x %02x %02x %02x %02x %02x %02x "
 					       "len %d at %08x\n",
 					       data[15], data[16], data[17], data[18],
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index b3e0158..f63d594 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1227,11 +1227,8 @@ static int __init bigmac_ether_init(struct sbus_dev *qec_sdev)
 
 	dev_set_drvdata(&bp->bigmac_sdev->ofdev.dev, bp);
 
-	printk(KERN_INFO "%s: BigMAC 100baseT Ethernet ", dev->name);
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i],
-		       i == 5 ? ' ' : ':');
-	printk("\n");
+	printk(KERN_INFO "%s: BigMAC 100baseT Ethernet " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	return 0;
 
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index a8f2af8..4e07624 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -468,7 +468,6 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 #endif
 	int phy, phy_idx = 0;
 
-
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
 	static int printed_version;
@@ -547,11 +546,9 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 	if (i)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %p, ",
-		   dev->name, pci_id_tbl[chip_idx].name, ioaddr);
-	for (i = 0; i < 5; i++)
-			printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], irq);
+	printk(KERN_INFO "%s: %s at %p, " MAC_FMT ", IRQ %d.\n",
+	       dev->name, pci_id_tbl[chip_idx].name, ioaddr,
+	       MAC_ARG(dev->dev_addr), irq);
 
 	np->phys[0] = 1;		/* Default setting */
 	np->mii_preamble_required++;
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index ed6959e..139c74b 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2963,7 +2963,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	unsigned long gemreg_base, gemreg_len;
 	struct net_device *dev;
 	struct gem *gp;
-	int i, err, pci_using_dac;
+	int err, pci_using_dac;
 
 	if (gem_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -3148,12 +3148,9 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		goto err_out_free_consistent;
 	}
 
-	printk(KERN_INFO "%s: Sun GEM (PCI) 10/100/1000BaseT Ethernet ",
-	       dev->name);
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i],
-		       i == 5 ? ' ' : ':');
-	printk("\n");
+	printk(KERN_INFO "%s: Sun GEM (PCI) 10/100/1000BaseT Ethernet "
+	       MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	if (gp->phy_type == phy_mii_mdio0 ||
      	    gp->phy_type == phy_mii_mdio1)
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 8b35f13..20bfdcd 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2851,10 +2851,7 @@ static int __devinit happy_meal_sbus_probe_one(struct sbus_dev *sdev, int is_qfe
 		printk(KERN_INFO "%s: HAPPY MEAL (SBUS) 10/100baseT Ethernet ",
 		       dev->name);
 
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c",
-		       dev->dev_addr[i], i == 5 ? ' ' : ':');
-	printk("\n");
+	printk(MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 
 	return 0;
 
@@ -3203,10 +3200,7 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 		printk(KERN_INFO "%s: HAPPY MEAL (PCI/CheerIO) 10/100BaseT Ethernet ",
 		       dev->name);
 
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i], i == 5 ? ' ' : ':');
-
-	printk("\n");
+	printk(MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 
 	return 0;
 
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 68e4f66..d6c9e7f 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1489,12 +1489,8 @@ no_link_test:
 
 	dev_set_drvdata(&sdev->ofdev.dev, lp);
 
-	printk(KERN_INFO "%s: LANCE ", dev->name);
-
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i],
-		       i == 5 ? ' ': ':');
-	printk("\n");
+	printk(KERN_INFO "%s: LANCE " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	return 0;
 
diff --git a/drivers/net/tokenring/abyss.c b/drivers/net/tokenring/abyss.c
index 1bdd3be..8a86baf 100644
--- a/drivers/net/tokenring/abyss.c
+++ b/drivers/net/tokenring/abyss.c
@@ -97,7 +97,7 @@ static int __devinit abyss_attach(struct pci_dev *pdev, const struct pci_device_
 	static int versionprinted;
 	struct net_device *dev;
 	struct net_local *tp;
-	int i, ret, pci_irq_line;
+	int ret, pci_irq_line;
 	unsigned long pci_ioaddr;
 	
 	if (versionprinted++ == 0)
@@ -148,11 +148,8 @@ static int __devinit abyss_attach(struct pci_dev *pdev, const struct pci_device_
 
 	abyss_read_eeprom(dev);
 		
-	printk("%s:    Ring Station Address: ", dev->name);
-	printk("%2.2x", dev->dev_addr[0]);
-	for (i = 1; i < 6; i++)
-		printk(":%2.2x", dev->dev_addr[i]);
-	printk("\n");
+	printk("%s:    Ring Station Address: " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	tp = netdev_priv(dev);
 	tp->setnselout = abyss_setnselout_pins;
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 1e8958e..84253b2 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -705,9 +705,8 @@ static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
 		channel_def[cardpresent - 1], adapter_def(ti->adapter_type));
 	DPRINTK("using irq %d, PIOaddr %hx, %dK shared RAM.\n",
 			irq, PIOaddr, ti->mapped_ram_size / 2);
-	DPRINTK("Hardware address : %02X:%02X:%02X:%02X:%02X:%02X\n",
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	DPRINTK("Hardware address : " MAC_FMT "\n",
+		MAC_ARG(dev->dev_addr));
 	if (ti->page_mask)
 		DPRINTK("Shared RAM paging enabled. "
 			"Page size: %uK Shared Ram size %dK\n",
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 5d849c0..641b75c 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -447,6 +447,8 @@ static int streamer_reset(struct net_device *dev)
 	unsigned int uaa_addr;
 	struct sk_buff *skb = NULL;
 	__u16 misr;
+#if STREAMER_DEBUG
+#endif
 
 	streamer_priv = (struct streamer_private *) dev->priv;
 	streamer_mmio = streamer_priv->streamer_mmio;
@@ -575,11 +577,8 @@ static int streamer_reset(struct net_device *dev)
 			dev->dev_addr[i+1]= addr & 0xff;
 		}
 #if STREAMER_DEBUG
-		printk("Adapter address: ");
-		for (i = 0; i < 6; i++) {
-			printk("%02x:", dev->dev_addr[i]);
-		}
-		printk("\n");
+		printk("Adapter address: " MAC_FMT "\n",
+		       MAC_ARG(dev->dev_addr));
 #endif
 	}
 	return 0;
@@ -1611,15 +1610,11 @@ static void streamer_arb_cmd(struct net_device *dev)
 		       dev->name);
 		mac_hdr = tr_hdr(mac_frame);
 		printk(KERN_WARNING
-		       "%s: MAC Frame Dest. Addr: %02x:%02x:%02x:%02x:%02x:%02x \n",
-		       dev->name, mac_hdr->daddr[0], mac_hdr->daddr[1],
-		       mac_hdr->daddr[2], mac_hdr->daddr[3],
-		       mac_hdr->daddr[4], mac_hdr->daddr[5]);
+		       "%s: MAC Frame Dest. Addr: " MAC_FMT "\n",
+		       dev->name, MAC_ARG(mac_hdr->daddr));
 		printk(KERN_WARNING
-		       "%s: MAC Frame Srce. Addr: %02x:%02x:%02x:%02x:%02x:%02x \n",
-		       dev->name, mac_hdr->saddr[0], mac_hdr->saddr[1],
-		       mac_hdr->saddr[2], mac_hdr->saddr[3],
-		       mac_hdr->saddr[4], mac_hdr->saddr[5]);
+		       "%s: MAC Frame Srce. Addr: " MAC_FMT "\n",
+		       dev->name, DEV->ADDR6(mac_hdr->saddr));
 #endif
 		netif_rx(mac_frame);
 
@@ -1875,13 +1870,12 @@ static int sprintf_info(char *buffer, struct net_device *dev)
 	size = sprintf(buffer, "\n%6s: Adapter Address   : Node Address      : Functional Addr\n", dev->name);
 
 	size += sprintf(buffer + size,
-		    "%6s: %02x:%02x:%02x:%02x:%02x:%02x : %02x:%02x:%02x:%02x:%02x:%02x : %02x:%02x:%02x:%02x\n",
-		    dev->name, dev->dev_addr[0], dev->dev_addr[1],
-		    dev->dev_addr[2], dev->dev_addr[3], dev->dev_addr[4],
-		    dev->dev_addr[5], sat.node_addr[0], sat.node_addr[1],
-		    sat.node_addr[2], sat.node_addr[3], sat.node_addr[4],
-		    sat.node_addr[5], sat.func_addr[0], sat.func_addr[1],
-		    sat.func_addr[2], sat.func_addr[3]);
+			"%6s: " MAC_FMT " : %02x:%02x:%02x:%02x:%02x:%02x : %02x:%02x:%02x:%02x\n",
+			dev->name, MAC_ARG(dev->dev_addr),
+			sat.node_addr[0], sat.node_addr[1], sat.node_addr[2],
+			sat.node_addr[3], sat.node_addr[4], sat.node_addr[5],
+			sat.func_addr[0], sat.func_addr[1],
+			sat.func_addr[2], sat.func_addr[3]);
 
 	size += sprintf(buffer + size, "\n%6s: Token Ring Parameters Table:\n", dev->name);
 
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index f8f4d74..cfcbd20 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -323,11 +323,8 @@ static int __devinit madgemc_probe(struct device *device)
 	mca_device_set_name(mdev, (card->cardtype == 0x08)?MADGEMC16_CARDNAME:MADGEMC32_CARDNAME);
 	mca_set_adapter_procfn(mdev->slot, madgemc_mcaproc, dev);
 
-	printk("%s:     Ring Station Address: ", dev->name);
-	printk("%2.2x", dev->dev_addr[0]);
-	for (i = 1; i < 6; i++)
-		printk(":%2.2x", dev->dev_addr[i]);
-	printk("\n");
+	printk("%s:     Ring Station Address: " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 
 	if (tmsdev_init(dev, device)) {
 		printk("%s: unable to get memory for dev->priv.\n", 
@@ -717,11 +714,8 @@ static int madgemc_mcaproc(char *buf, int slot, void *d)
 		}
 		len += sprintf(buf+len, " (%s)\n", (curcard->fairness)?"Unfair":"Fair");
 		
-		len += sprintf(buf+len, "Ring Station Address: ");
-		len += sprintf(buf+len, "%2.2x", dev->dev_addr[0]);
-		for (i = 1; i < 6; i++)
-			len += sprintf(buf+len, " %2.2x", dev->dev_addr[i]);
-		len += sprintf(buf+len, "\n");
+		len += sprintf(buf+len, "Ring Station Address: " MAC_FMT "\n",
+			       MAC_ARG(dev->dev_addr));
 	} else 
 		len += sprintf(buf+len, "Card not configured\n");
 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 09b3cfb..cd8edc7 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -418,14 +418,12 @@ static int __devinit olympic_init(struct net_device *dev)
 	writel(uaa_addr,olympic_mmio+LAPA);
 	adapter_addr=olympic_priv->olympic_lap + (uaa_addr & (~0xf800));
 
+	memcpy_fromio(&dev->dev_addr[0], adapter_addr,6);
+
 #if OLYMPIC_DEBUG
-	printk("adapter address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-			readb(adapter_addr), readb(adapter_addr+1),readb(adapter_addr+2),
-			readb(adapter_addr+3),readb(adapter_addr+4),readb(adapter_addr+5));
+	printk("adapter address: " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 #endif
 
-	memcpy_fromio(&dev->dev_addr[0], adapter_addr,6);
-
 	olympic_priv->olympic_addr_table_addr = swab16(readw(init_srb + 12)); 
 	olympic_priv->olympic_parms_addr = swab16(readw(init_srb + 14)); 
 
@@ -567,14 +565,8 @@ static int olympic_open(struct net_device *dev)
 			goto out;
 
 		case 0x32:
-			printk(KERN_WARNING "%s: Invalid LAA: %02x:%02x:%02x:%02x:%02x:%02x\n",
-				dev->name, 
-				olympic_priv->olympic_laa[0],
-				olympic_priv->olympic_laa[1],
-				olympic_priv->olympic_laa[2],
-				olympic_priv->olympic_laa[3],
-				olympic_priv->olympic_laa[4],
-				olympic_priv->olympic_laa[5]) ; 
+			printk(KERN_WARNING "%s: Invalid LAA: " MAC_FMT "\n",
+			       dev->name, MAC_ARG(olympic_priv->olympic_laa));
 			goto out;
 
 		default:
@@ -1650,14 +1642,9 @@ static int olympic_proc_info(char *buffer, char **start, off_t offset, int lengt
 	size += sprintf(buffer+size, "\n%6s: Adapter Address   : Node Address      : Functional Addr\n",
  	   dev->name); 
 
-	size += sprintf(buffer+size, "%6s: %02x:%02x:%02x:%02x:%02x:%02x : %02x:%02x:%02x:%02x:%02x:%02x : %02x:%02x:%02x:%02x\n",
+	size += sprintf(buffer+size, "%6s: " MAC_FMT " : %02x:%02x:%02x:%02x:%02x:%02x : %02x:%02x:%02x:%02x\n",
 	   dev->name,
-           dev->dev_addr[0],
-	   dev->dev_addr[1],
-	   dev->dev_addr[2],
- 	   dev->dev_addr[3],
-	   dev->dev_addr[4],
-	   dev->dev_addr[5],
+	   MAC_ARG(dev->dev_addr),
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,node_addr)), 
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,node_addr)+1),
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,node_addr)+2),
diff --git a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
index cb7dbb6..0a4a874 100644
--- a/drivers/net/tokenring/proteon.c
+++ b/drivers/net/tokenring/proteon.c
@@ -153,11 +153,8 @@ static int __init setup_card(struct net_device *dev, struct device *pdev)
 		
 	proteon_read_eeprom(dev);
 
-	printk(KERN_DEBUG "proteon.c:    Ring Station Address: ");
-	printk("%2.2x", dev->dev_addr[0]);
-	for (j = 1; j < 6; j++)
-		printk(":%2.2x", dev->dev_addr[j]);
-	printk("\n");
+	printk(KERN_DEBUG "proteon.c:    Ring Station Address: " MAC_FMT "\n",
+	       MAC_ARG(dev->dev_addr));
 		
 	tp = netdev_priv(dev);
 	tp->setnselout = proteon_setnselout_pins;
diff --git a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
index 33afea3..9b21f32 100644
--- a/drivers/net/tokenring/skisa.c
+++ b/drivers/net/tokenring/skisa.c
@@ -170,11 +170,8 @@ static int __init setup_card(struct net_device *dev, struct device *pdev)
 		
 	sk_isa_read_eeprom(dev);
 
-	printk(KERN_DEBUG "skisa.c:    Ring Station Address: ");
-	printk("%2.2x", dev->dev_addr[0]);
-	for (j = 1; j < 6; j++)
-		printk(":%2.2x", dev->dev_addr[j]);
-	printk("\n");
+	printk(KERN_DEBUG "skisa.c:    Ring Station Address: " MAC_FMT "\n",
+	       MAC_ARG(dev->dev_addr));
 		
 	tp = netdev_priv(dev);
 	tp->setnselout = sk_isa_setnselout_pins;
diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index 3b2f00b..e7d885c 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -96,7 +96,7 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 	static int versionprinted;
 	struct net_device *dev;
 	struct net_local *tp;
-	int i, ret;
+	int ret;
 	unsigned int pci_irq_line;
 	unsigned long pci_ioaddr;
 	struct card_info *cardinfo = &card_info_table[ent->driver_data];
@@ -137,11 +137,8 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 		
 	tms_pci_read_eeprom(dev);
 
-	printk("%s:    Ring Station Address: ", dev->name);
-	printk("%2.2x", dev->dev_addr[0]);
-	for (i = 1; i < 6; i++)
-		printk(":%2.2x", dev->dev_addr[i]);
-	printk("\n");
+	printk("%s:    Ring Station Address: " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 		
 	ret = tmsdev_init(dev, &pdev->dev);
 	if (ret) {
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index d380e0b..c6606ea 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -2045,15 +2045,11 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 		goto err_out_iomap;
 
 	/* print info about board and interface just registered */
-	printk (KERN_INFO "%s: %s at 0x%lx, "
-		"%02x:%02x:%02x:%02x:%02x:%02x, "
-		"IRQ %d\n",
+	printk (KERN_INFO "%s: %s at 0x%lx, " MAC_FMT ", IRQ %d\n",
 		dev->name,
 		de->de21040 ? "21040" : "21041",
 		dev->base_addr,
-		dev->dev_addr[0], dev->dev_addr[1],
-		dev->dev_addr[2], dev->dev_addr[3],
-		dev->dev_addr[4], dev->dev_addr[5],
+		MAC_ARG(dev->dev_addr),
 		dev->irq);
 
 	pci_set_drvdata(pdev, dev);
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 0990289..9f9a73f 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -5475,13 +5475,9 @@ de4x5_dbg_srom(struct de4x5_srom *p)
 	printk("Sub-system ID:        %04x\n", *((u_short *)p->sub_system_id));
 	printk("ID Block CRC:         %02x\n", (u_char)(p->id_block_crc));
 	printk("SROM version:         %02x\n", (u_char)(p->version));
-	printk("# controllers:         %02x\n", (u_char)(p->num_controllers));
+	printk("# controllers:        %02x\n", (u_char)(p->num_controllers));
 
-	printk("Hardware Address:     ");
-	for (i=0;i<ETH_ALEN-1;i++) {
-	    printk("%02x:", (u_char)*(p->ieee_addr+i));
-	}
-	printk("%02x\n", (u_char)*(p->ieee_addr+i));
+	printk("Hardware Address:     " MAC_FMT "\n", MAC_ARG(p->ieee_addr));
 	printk("CRC checksum:         %04x\n", (u_short)(p->chksum));
 	for (i=0; i<64; i++) {
 	    printk("%3d %04x\n", i<<1, (u_short)*((u_short *)p+i));
@@ -5497,19 +5493,8 @@ de4x5_dbg_rx(struct sk_buff *skb, int len)
     int i, j;
 
     if (de4x5_debug & DEBUG_RX) {
-	printk("R: %02x:%02x:%02x:%02x:%02x:%02x <- %02x:%02x:%02x:%02x:%02x:%02x len/SAP:%02x%02x [%d]\n",
-	       (u_char)skb->data[0],
-	       (u_char)skb->data[1],
-	       (u_char)skb->data[2],
-	       (u_char)skb->data[3],
-	       (u_char)skb->data[4],
-	       (u_char)skb->data[5],
-	       (u_char)skb->data[6],
-	       (u_char)skb->data[7],
-	       (u_char)skb->data[8],
-	       (u_char)skb->data[9],
-	       (u_char)skb->data[10],
-	       (u_char)skb->data[11],
+	printk("R: " MAC_FMT " <- " MAC_FMT " len/SAP:%02x%02x [%d]\n",
+	       MAC_ARG(skb->data), MAC_ARG(&skb->data[6]),
 	       (u_char)skb->data[12],
 	       (u_char)skb->data[13],
 	       len);
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index dab74fe..5e6d40b 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -471,13 +471,13 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	if (err)
 		goto err_out_res;
 
-	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s,",
-		dev->name,
-		ent->driver_data >> 16,
-		pci_name(pdev));
-	for (i = 0; i < 6; i++)
-		printk("%c%02x", i ? ':' : ' ', dev->dev_addr[i]);
-	printk(", irq %d.\n", dev->irq);
+	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, "
+	       MAC_FMT ", irq %d.\n",
+	       dev->name,
+	       ent->driver_data >> 16,
+	       pci_name(pdev),
+	       MAC_ARG(dev->dev_addr),
+	       dev->irq);
 
 	pci_set_master(pdev);
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index da05a3a..1f319bf 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1044,12 +1044,10 @@ static void set_rx_mode(struct net_device *dev)
 				filterbit &= 0x3f;
 				mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 				if (tulip_debug > 2) {
-					printk(KERN_INFO "%s: Added filter for %2.2x:%2.2x:%2.2x:"
-						   "%2.2x:%2.2x:%2.2x  %8.8x bit %d.\n", dev->name,
-						   mclist->dmi_addr[0], mclist->dmi_addr[1],
-						   mclist->dmi_addr[2], mclist->dmi_addr[3],
-						   mclist->dmi_addr[4], mclist->dmi_addr[5],
-						   ether_crc(ETH_ALEN, mclist->dmi_addr), filterbit);
+					printk(KERN_INFO "%s: Added filter for " MAC_FMT
+					       "  %8.8x bit %d.\n",
+					       dev->name, MAC_ARG(mclist->dmi_addr),
+					       ether_crc(ETH_ALEN, mclist->dmi_addr), filterbit);
 				}
 			}
 			if (mc_filter[0] == tp->mc_filter[0]  &&
@@ -1633,8 +1631,7 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 	if (eeprom_missing)
 		printk(" EEPROM not present,");
-	for (i = 0; i < 6; i++)
-		printk("%c%2.2X", i ? ':' : ' ', dev->dev_addr[i]);
+	printk(" " MAC_FMT, MAC_ARG(dev->dev_addr));
 	printk(", IRQ %d.\n", irq);
 
         if (tp->chip_id == PNIC2)
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 5824f6a..4f771a4 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -434,11 +434,9 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 	if (i)
 		goto err_out_cleardev;
 
-	printk(KERN_INFO "%s: %s at %p, ",
-		   dev->name, pci_id_tbl[chip_idx].name, ioaddr);
-	for (i = 0; i < 5; i++)
-			printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], irq);
+	printk(KERN_INFO "%s: %s at %p, " MAC_FMT ", IRQ %d.\n",
+	       dev->name, pci_id_tbl[chip_idx].name, ioaddr,
+	       MAC_ARG(dev->dev_addr), irq);
 
 	if (np->drv_flags & CanHaveMII) {
 		int phy, phy_idx = 0;
@@ -1246,16 +1244,14 @@ static int netdev_rx(struct net_device *dev)
 			}
 #ifndef final_version				/* Remove after testing. */
 			/* You will want this info for the initial debug. */
-			if (debug > 5)
-				printk(KERN_DEBUG "  Rx data %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:"
-					   "%2.2x %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x %2.2x%2.2x "
-					   "%d.%d.%d.%d.\n",
-					   skb->data[0], skb->data[1], skb->data[2], skb->data[3],
-					   skb->data[4], skb->data[5], skb->data[6], skb->data[7],
-					   skb->data[8], skb->data[9], skb->data[10],
-					   skb->data[11], skb->data[12], skb->data[13],
-					   skb->data[14], skb->data[15], skb->data[16],
-					   skb->data[17]);
+			if (debug > 5) {
+
+				printk(KERN_DEBUG "  Rx data " MAC_FMT " " MAC_FMT
+				       " %2.2x%2.2x %d.%d.%d.%d.\n",
+				       MAC_ARG(&skb->data[0]), MAC_ARG(&skb->data[6]),
+				       skb->data[12], skb->data[13],
+				       skb->data[14], skb->data[15], skb->data[16], skb->data[17]);
+			}
 #endif
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 16a54e6..4feb09e 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -1105,11 +1105,7 @@ static void read_mac_address(struct xircom_private *card)
 		}
 	}
 	spin_unlock_irqrestore(&card->lock, flags);
-#ifdef DEBUG
-	for (i = 0; i < 6; i++)
-		printk("%c%2.2X", i ? ':' : ' ', card->dev->dev_addr[i]);
-	printk("\n");
-#endif
+	pr_debug(" " MAC_FMT "\n", MAC_ARG(card->dev->dev_addr));
 	leave("read_mac_address");
 }
 
@@ -1150,6 +1146,8 @@ static void xircom_up(struct xircom_private *card)
 {
 	unsigned long flags;
 	int i;
+#ifdef DEBUG
+#endif
 
 	enter("xircom_up");
 
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index fdcbdde..f7a8c30 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2315,7 +2315,6 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dma_addr_t shared_dma;
 	struct cmd_desc xp_cmd;
 	struct resp_desc xp_resp[3];
-	int i;
 	int err = 0;
 
 	if(!did_version++)
@@ -2532,13 +2531,11 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: %s at %s 0x%llx, ",
+	printk(KERN_INFO "%s: %s at %s 0x%llx, " MAC_FMT "\n",
 	       dev->name, typhoon_card_info[card_id].name,
 	       use_mmio ? "MMIO" : "IO",
-	       (unsigned long long)pci_resource_start(pdev, use_mmio));
-	for(i = 0; i < 5; i++)
-		printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x\n", dev->dev_addr[i]);
+	       (unsigned long long)pci_resource_start(pdev, use_mmio),
+	       MAC_ARG(dev->dev_addr));
 
 	/* xp_resp still contains the response to the READ_VERSIONS command.
 	 * For debugging, let the user know what version he has.
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 0e6aefe..e0ae43f 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -795,18 +795,14 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	if (rc)
 		goto err_out_unmap;
 
-	printk(KERN_INFO "%s: VIA %s at 0x%lx, ",
+	printk(KERN_INFO "%s: VIA %s at 0x%lx, " MAC_FMT ", IRQ %d.\n",
 	       dev->name, name,
 #ifdef USE_MMIO
-		memaddr
+	       memaddr,
 #else
-		(long)ioaddr
+	       (long)ioaddr,
 #endif
-		 );
-
-	for (i = 0; i < 5; i++)
-		printk("%2.2x:", dev->dev_addr[i]);
-	printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], pdev->irq);
+	       MAC_ARG(dev->dev_addr), pdev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index a032681..41a2bb9 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -176,9 +176,11 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk("%s: WD80x3 at %#3x,", dev->name, ioaddr);
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
+
+	printk("%s: WD80x3 at %#3x, " MAC_FMT,
+	       dev->name, ioaddr, MAC_ARG(dev->dev_addr));
 
 	/* The following PureData probe code was contributed by
 	   Mike Jagdis <jaggy@purplet.demon.co.uk>. Puredata does software




