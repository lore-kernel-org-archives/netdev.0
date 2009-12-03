From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next-2.6] drivers/net: Move && and || to end of
 previous line
Date: Thu, 03 Dec 2009 09:58:21 -0800
Message-ID: <1259863101.22783.63.camel@Joe-Laptop.home>
References: <1259001504.16503.79.camel@Joe-Laptop.home>
	 <20091123.104130.117837098.davem@davemloft.net>
	 <1259528449.29779.194.camel@Joe-Laptop.home>
	 <20091129.165557.84377714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1275 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109AbZLCR6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 12:58:17 -0500
In-Reply-To: <20091129.165557.84377714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only files where David Miller is the primary git-signer.
wireless, wimax, ixgbe, etc are not modified.

Compile tested x86 allyesconfig only
Not all files compiled (not x86 compatible)

Added a few > 80 column lines, which I ignored.
Existing checkpatch complaints ignored.
    
Signed-off-by: Joe Perches <joe@perches.com>

---
 drivers/net/3c501.c                     |    8 ++--
 drivers/net/3c503.c                     |   15 +++---
 drivers/net/3c507.c                     |    4 +-
 drivers/net/3c509.c                     |   10 ++--
 drivers/net/3c515.c                     |   13 +++--
 drivers/net/3c527.c                     |    4 +-
 drivers/net/3c59x.c                     |    4 +-
 drivers/net/8139cp.c                    |    4 +-
 drivers/net/8139too.c                   |   12 ++--
 drivers/net/appletalk/ipddp.c           |   12 ++--
 drivers/net/arcnet/arc-rimi.c           |    6 +-
 drivers/net/arcnet/arcnet.c             |   14 +++---
 drivers/net/at1700.c                    |   16 +++---
 drivers/net/atarilance.c                |    4 +-
 drivers/net/atlx/atl1.c                 |    8 ++--
 drivers/net/atp.c                       |    4 +-
 drivers/net/benet/be_main.c             |    4 +-
 drivers/net/bfin_mac.c                  |   12 ++--
 drivers/net/bmac.c                      |    4 +-
 drivers/net/bnx2x_link.c                |    4 +-
 drivers/net/bonding/bond_3ad.c          |   24 ++++----
 drivers/net/bonding/bond_main.c         |    4 +-
 drivers/net/bonding/bonding.h           |    4 +-
 drivers/net/can/usb/ems_usb.c           |    8 ++--
 drivers/net/cxgb3/cxgb3_main.c          |   26 +++++-----
 drivers/net/dl2k.c                      |    4 +-
 drivers/net/dm9000.c                    |    4 +-
 drivers/net/e1000/e1000_main.c          |    4 +-
 drivers/net/e1000e/netdev.c             |    8 ++--
 drivers/net/e2100.c                     |    6 +-
 drivers/net/ehea/ehea_main.c            |   20 ++++----
 drivers/net/ehea/ehea_qmr.c             |    4 +-
 drivers/net/epic100.c                   |    8 ++--
 drivers/net/fealnx.c                    |   12 ++--
 drivers/net/gianfar_sysfs.c             |    4 +-
 drivers/net/hamachi.c                   |   10 ++--
 drivers/net/hamradio/bpqether.c         |    5 +--
 drivers/net/hamradio/dmascc.c           |    8 ++--
 drivers/net/hp-plus.c                   |    4 +-
 drivers/net/hp100.c                     |    4 +-
 drivers/net/ibm_newemac/core.c          |   24 ++++----
 drivers/net/igb/igb_main.c              |    5 +-
 drivers/net/igbvf/netdev.c              |    4 +-
 drivers/net/irda/irda-usb.c             |    8 ++--
 drivers/net/irda/stir4200.c             |   12 ++--
 drivers/net/irda/via-ircc.c             |   16 +++---
 drivers/net/irda/vlsi_ir.c              |   16 +++---
 drivers/net/isa-skeleton.c              |    6 +-
 drivers/net/iseries_veth.c              |   42 ++++++++--------
 drivers/net/jazzsonic.c                 |    4 +-
 drivers/net/jme.c                       |   12 ++--
 drivers/net/lance.c                     |   12 ++--
 drivers/net/lib8390.c                   |   12 ++--
 drivers/net/ll_temac_main.c             |    4 +-
 drivers/net/mac89x0.c                   |    4 +-
 drivers/net/mace.c                      |    4 +-
 drivers/net/myri10ge/myri10ge.c         |   16 +++---
 drivers/net/natsemi.c                   |   28 +++++-----
 drivers/net/netxen/netxen_nic_ethtool.c |   32 ++++++------
 drivers/net/netxen/netxen_nic_hw.c      |   16 +++---
 drivers/net/ni52.c                      |    4 +-
 drivers/net/ns83820.c                   |   24 ++++----
 drivers/net/pci-skeleton.c              |   12 ++--
 drivers/net/pcmcia/axnet_cs.c           |    4 +-
 drivers/net/pcmcia/fmvj18x_cs.c         |   20 ++++----
 drivers/net/pcmcia/pcnet_cs.c           |    4 +-
 drivers/net/pcmcia/smc91c92_cs.c        |    8 ++--
 drivers/net/pcmcia/xirc2ps_cs.c         |   16 +++---
 drivers/net/pcnet32.c                   |   20 ++++----
 drivers/net/phy/phy.c                   |   18 +++---
 drivers/net/plip.c                      |   13 ++---
 drivers/net/ppp_async.c                 |   12 ++--
 drivers/net/ppp_deflate.c               |   44 ++++++++--------
 drivers/net/ppp_generic.c               |   66 ++++++++++++------------
 drivers/net/ppp_mppe.c                  |    8 ++--
 drivers/net/ppp_synctty.c               |    4 +-
 drivers/net/pppoe.c                     |    4 +-
 drivers/net/qla3xxx.c                   |    8 ++--
 drivers/net/qlge/qlge_main.c            |    4 +-
 drivers/net/r6040.c                     |    3 +-
 drivers/net/r8169.c                     |    4 +-
 drivers/net/s6gmac.c                    |    6 +-
 drivers/net/sc92031.c                   |   14 +++---
 drivers/net/skge.c                      |   23 ++++----
 drivers/net/sky2.c                      |   32 ++++++------
 drivers/net/slip.c                      |    8 ++--
 drivers/net/smc-mca.c                   |    6 +-
 drivers/net/smc91x.h                    |   10 ++--
 drivers/net/smsc911x.c                  |    4 +-
 drivers/net/starfire.c                  |    8 ++--
 drivers/net/stmmac/stmmac_main.c        |    3 +-
 drivers/net/sundance.c                  |   16 +++---
 drivers/net/sungem.h                    |    4 +-
 drivers/net/sunhme.c                    |    6 +-
 drivers/net/tehuti.c                    |   14 +++---
 drivers/net/tg3.c                       |   13 ++---
 drivers/net/tlan.c                      |    4 +-
 drivers/net/tokenring/lanstreamer.c     |    8 ++--
 drivers/net/tokenring/smctr.c           |   86 +++++++++++++++----------------
 drivers/net/tokenring/tms380tr.c        |   24 ++++----
 drivers/net/tulip/21142.c               |    8 ++--
 drivers/net/tulip/de2104x.c             |    6 +-
 drivers/net/tulip/eeprom.c              |    8 ++--
 drivers/net/tulip/interrupt.c           |   16 +++---
 drivers/net/tulip/media.c               |    4 +-
 drivers/net/tulip/pnic2.c               |    6 +-
 drivers/net/tulip/tulip_core.c          |   22 ++++----
 drivers/net/tulip/winbond-840.c         |    8 ++--
 drivers/net/typhoon.c                   |    4 +-
 drivers/net/ucc_geth.c                  |   24 ++++----
 drivers/net/usb/asix.c                  |   12 ++--
 drivers/net/usb/catc.c                  |    4 +-
 drivers/net/usb/cdc-phonet.c            |    8 ++--
 drivers/net/usb/cdc_eem.c               |    4 +-
 drivers/net/usb/cdc_ether.c             |   32 ++++++------
 drivers/net/usb/hso.c                   |   34 ++++++------
 drivers/net/usb/mcs7830.c               |    4 +-
 drivers/net/usb/rndis_host.c            |   10 ++--
 drivers/net/usb/usbnet.c                |   48 +++++++++---------
 drivers/net/usb/zaurus.c                |    4 +-
 drivers/net/via-rhine.c                 |   10 ++--
 drivers/net/via-velocity.c              |   16 +++---
 drivers/net/virtio_net.c                |   10 ++--
 drivers/net/vmxnet3/vmxnet3_drv.c       |    4 +-
 drivers/net/vxge/vxge-main.c            |    6 +-
 drivers/net/vxge/vxge-traffic.c         |   20 ++++----
 drivers/net/wan/farsync.c               |   12 ++--
 drivers/net/wan/pc300_drv.c             |   17 +++---
 drivers/net/wan/sbni.c                  |   28 +++++-----
 drivers/net/wan/x25_asy.c               |    4 +-
 drivers/net/yellowfin.c                 |    8 ++--
 drivers/net/znet.c                      |    4 +-
 132 files changed, 799 insertions(+), 805 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 62ceb2b..4d4cad3 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -249,11 +249,11 @@ static int __init el1_probe1(struct net_device *dev, int ioaddr)
 	 *	for the Sager NP943 prefix.
 	 */
 
-	if (station_addr[0] == 0x02  &&  station_addr[1] == 0x60
-						&& station_addr[2] == 0x8c)
+	if (station_addr[0] == 0x02 && station_addr[1] == 0x60 &&
+	    station_addr[2] == 0x8c)
 		mname = "3c501";
-	else if (station_addr[0] == 0x00  &&  station_addr[1] == 0x80
-						&& station_addr[2] == 0xC8)
+	else if (station_addr[0] == 0x00 && station_addr[1] == 0x80 &&
+		 station_addr[2] == 0xC8)
 		mname = "NP943";
 	else {
 		release_region(ioaddr, EL1_IO_EXTENT);
diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index c71e12d..66e0323 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -214,8 +214,8 @@ el2_probe1(struct net_device *dev, int ioaddr)
     iobase_reg = inb(ioaddr+0x403);
     membase_reg = inb(ioaddr+0x404);
     /* ASIC location registers should be 0 or have only a single bit set. */
-    if (   (iobase_reg  & (iobase_reg - 1))
-	|| (membase_reg & (membase_reg - 1))) {
+    if ((iobase_reg  & (iobase_reg - 1)) ||
+	(membase_reg & (membase_reg - 1))) {
 	retval = -ENODEV;
 	goto out1;
     }
@@ -291,8 +291,8 @@ el2_probe1(struct net_device *dev, int ioaddr)
 	    writel(0xba5eba5e, mem_base);
 	    for (i = sizeof(test_val); i < EL2_MEMSIZE; i+=sizeof(test_val)) {
 		writel(test_val, mem_base + i);
-		if (readl(mem_base) != 0xba5eba5e
-		    || readl(mem_base + i) != test_val) {
+		if (readl(mem_base) != 0xba5eba5e ||
+		    readl(mem_base + i) != test_val) {
 		    pr_warning("3c503: memory failure or memory address conflict.\n");
 		    dev->mem_start = 0;
 		    ei_status.name = "3c503-PIO";
@@ -397,9 +397,10 @@ el2_open(struct net_device *dev)
 		unsigned long cookie = probe_irq_on();
 		outb_p(0x04 << ((*irqp == 9) ? 2 : *irqp), E33G_IDCFR);
 		outb_p(0x00, E33G_IDCFR);
-		if (*irqp == probe_irq_off(cookie)	/* It's a good IRQ line! */
-		    && ((retval = request_irq(dev->irq = *irqp,
-		    eip_interrupt, 0, dev->name, dev)) == 0))
+		if (*irqp == probe_irq_off(cookie) &&	/* It's a good IRQ line! */
+		    ((retval = request_irq(dev->irq = *irqp,
+					   eip_interrupt, 0,
+					   dev->name, dev)) == 0))
 		    break;
 	    } else {
 		    if (retval != -EBUSY)
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index 605f1d1..fbc2311 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -836,8 +836,8 @@ static void el16_rx(struct net_device *dev)
 		void __iomem *data_frame = lp->base + data_buffer_addr;
 		ushort pkt_len = readw(data_frame);
 
-		if (rfd_cmd != 0 || data_buffer_addr != rx_head + 22
-			|| (pkt_len & 0xC000) != 0xC000) {
+		if (rfd_cmd != 0 || data_buffer_addr != rx_head + 22 ||
+		    (pkt_len & 0xC000) != 0xC000) {
 			pr_err("%s: Rx frame at %#x corrupted, "
 			       "status %04x cmd %04x next %04x "
 			       "data-buf @%04x %04x.\n",
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 8d4ce09..9d85efc 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -253,9 +253,9 @@ static int el3_isa_id_sequence(__be16 *phys_addr)
 		   This check is needed in order not to register them twice. */
 		for (i = 0; i < el3_cards; i++) {
 			struct el3_private *lp = netdev_priv(el3_devs[i]);
-			if (lp->type == EL3_PNP
-			    && !memcmp(phys_addr, el3_devs[i]->dev_addr,
-				       ETH_ALEN)) {
+			if (lp->type == EL3_PNP &&
+			    !memcmp(phys_addr, el3_devs[i]->dev_addr,
+				    ETH_ALEN)) {
 				if (el3_debug > 3)
 					pr_debug("3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
 						phys_addr[0] & 0xff, phys_addr[0] >> 8,
@@ -835,8 +835,8 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifndef final_version
 	{	/* Error-checking code, delete someday. */
 		ushort status = inw(ioaddr + EL3_STATUS);
-		if (status & 0x0001 		/* IRQ line active, missed one. */
-			&& inw(ioaddr + EL3_STATUS) & 1) { 			/* Make sure. */
+		if (status & 0x0001 && 		/* IRQ line active, missed one. */
+		    inw(ioaddr + EL3_STATUS) & 1) { 			/* Make sure. */
 			pr_debug("%s: Missed interrupt, status then %04x now %04x"
 				   "  Tx %2.2x Rx %4.4x.\n", dev->name, status,
 				   inw(ioaddr + EL3_STATUS), inb(ioaddr + TX_STATUS),
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 37faf36..063b049 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -764,10 +764,11 @@ static int corkscrew_open(struct net_device *dev)
 	/* Use the now-standard shared IRQ implementation. */
 	if (vp->capabilities == 0x11c7) {
 		/* Corkscrew: Cannot share ISA resources. */
-		if (dev->irq == 0
-		    || dev->dma == 0
-		    || request_irq(dev->irq, corkscrew_interrupt, 0,
-				   vp->product_name, dev)) return -EAGAIN;
+		if (dev->irq == 0 ||
+		    dev->dma == 0 ||
+		    request_irq(dev->irq, corkscrew_interrupt, 0,
+				vp->product_name, dev))
+			return -EAGAIN;
 		enable_dma(dev->dma);
 		set_dma_mode(dev->dma, DMA_MODE_CASCADE);
 	} else if (request_irq(dev->irq, corkscrew_interrupt, IRQF_SHARED,
@@ -1368,8 +1369,8 @@ static int boomerang_rx(struct net_device *dev)
 
 			/* Check if the packet is long enough to just accept without
 			   copying to a properly sized skbuff. */
-			if (pkt_len < rx_copybreak
-			    && (skb = dev_alloc_skb(pkt_len + 4)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+			    (skb = dev_alloc_skb(pkt_len + 4)) != NULL) {
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 				/* 'skb_put()' points to the start of sk_buff data area. */
 				memcpy(skb_put(skb, pkt_len),
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index d91c346..36c4191 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1168,8 +1168,8 @@ static void mc32_rx_ring(struct net_device *dev)
 
 			/* Try to save time by avoiding a copy on big frames */
 
-			if ((length > RX_COPYBREAK)
-			    && ((newskb=dev_alloc_skb(1532)) != NULL))
+			if ((length > RX_COPYBREAK) &&
+			    ((newskb=dev_alloc_skb(1532)) != NULL))
 			{
 				skb=lp->rx_ring[rx_ring_tail].skb;
 				skb_put(skb, length);
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 32031ea..78b7167 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1942,8 +1942,8 @@ vortex_error(struct net_device *dev, int status)
 	if (status & TxComplete) {			/* Really "TxError" for us. */
 		tx_status = ioread8(ioaddr + TxStatus);
 		/* Presumably a tx-timeout. We must merely re-enable. */
-		if (vortex_debug > 2
-			|| (tx_status != 0x88 && vortex_debug > 0)) {
+		if (vortex_debug > 2 ||
+		    (tx_status != 0x88 && vortex_debug > 0)) {
 			pr_err("%s: Transmit error, Tx status register %2.2x.\n",
 				   dev->name, tx_status);
 			if (tx_status == 0x82) {
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index ab451bb..3f452bc 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -909,8 +909,8 @@ static void __cp_set_rx_mode (struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 7e333f7..25f7339 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1549,8 +1549,8 @@ static inline void rtl8139_thread_iter (struct net_device *dev,
 	mii_lpa = mdio_read (dev, tp->phys[0], MII_LPA);
 
 	if (!tp->mii.force_media && mii_lpa != 0xffff) {
-		int duplex = (mii_lpa & LPA_100FULL)
-		    || (mii_lpa & 0x01C0) == 0x0040;
+		int duplex = ((mii_lpa & LPA_100FULL) ||
+			      (mii_lpa & 0x01C0) == 0x0040);
 		if (tp->mii.full_duplex != duplex) {
 			tp->mii.full_duplex = duplex;
 
@@ -1936,8 +1936,8 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
-	while (netif_running(dev) && received < budget
-	       && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
+	while (netif_running(dev) && received < budget &&
+	       (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		u32 ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
 		unsigned int pkt_size;
@@ -2521,8 +2521,8 @@ static void __set_rx_mode (struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index aaf14d3..eb0448b 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -230,9 +230,9 @@ static int ipddp_delete(struct ipddp_route *rt)
 	spin_lock_bh(&ipddp_route_lock);
         while((tmp = *r) != NULL)
         {
-                if(tmp->ip == rt->ip
-                        && tmp->at.s_net == rt->at.s_net
-                        && tmp->at.s_node == rt->at.s_node)
+                if(tmp->ip == rt->ip &&
+		   tmp->at.s_net == rt->at.s_net &&
+		   tmp->at.s_node == rt->at.s_node)
                 {
                         *r = tmp->next;
 			spin_unlock_bh(&ipddp_route_lock);
@@ -255,9 +255,9 @@ static struct ipddp_route* __ipddp_find_route(struct ipddp_route *rt)
 
         for(f = ipddp_route_list; f != NULL; f = f->next)
         {
-                if(f->ip == rt->ip
-                        && f->at.s_net == rt->at.s_net
-                        && f->at.s_node == rt->at.s_node)
+                if(f->ip == rt->ip &&
+		   f->at.s_net == rt->at.s_net &&
+		   f->at.s_node == rt->at.s_node)
                         return (f);
         }
 
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index c5b9881..e6afab2 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -174,9 +174,9 @@ static int __init arcrimi_found(struct net_device *dev)
 	 * 2k (or there are no mirrors at all) but on some, it's 4k.
 	 */
 	mirror_size = MIRROR_SIZE;
-	if (readb(p) == TESTvalue
-	    && check_mirror(shmem - MIRROR_SIZE, MIRROR_SIZE) == 0
-	    && check_mirror(shmem - 2 * MIRROR_SIZE, MIRROR_SIZE) == 1)
+	if (readb(p) == TESTvalue &&
+	    check_mirror(shmem - MIRROR_SIZE, MIRROR_SIZE) == 0 &&
+	    check_mirror(shmem - 2 * MIRROR_SIZE, MIRROR_SIZE) == 1)
 		mirror_size = 2 * MIRROR_SIZE;
 
 	first_mirror = shmem - mirror_size;
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 75a5725..d8f0293 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -301,8 +301,8 @@ static int choose_mtu(void)
 
 	/* choose the smallest MTU of all available encaps */
 	for (count = 0; count < 256; count++) {
-		if (arc_proto_map[count] != &arc_proto_null
-		    && arc_proto_map[count]->mtu < mtu) {
+		if (arc_proto_map[count] != &arc_proto_null &&
+		    arc_proto_map[count]->mtu < mtu) {
 			mtu = arc_proto_map[count]->mtu;
 		}
 	}
@@ -953,13 +953,13 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 				 *    > RECON_THRESHOLD/min;
 				 * then print a warning message.
 				 */
-				if (!lp->network_down
-				    && (lp->last_recon - lp->first_recon) <= HZ * 60
-				  && lp->num_recons >= RECON_THRESHOLD) {
+				if (!lp->network_down &&
+				    (lp->last_recon - lp->first_recon) <= HZ * 60 &&
+				    lp->num_recons >= RECON_THRESHOLD) {
 					lp->network_down = 1;
 					BUGMSG(D_NORMAL, "many reconfigurations detected: cabling problem?\n");
-				} else if (!lp->network_down
-					   && lp->last_recon - lp->first_recon > HZ * 60) {
+				} else if (!lp->network_down &&
+					   lp->last_recon - lp->first_recon > HZ * 60) {
 					/* reset counters if we've gone for over a minute. */
 					lp->first_recon = lp->last_recon;
 					lp->num_recons = 1;
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index d4ab69f..b14f479 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -350,13 +350,13 @@ static int __init at1700_probe1(struct net_device *dev, int ioaddr)
 	slot = -1;
 	/* We must check for the EEPROM-config boards first, else accessing
 	   IOCONFIG0 will move the board! */
-	if (at1700_probe_list[inb(ioaddr + IOCONFIG1) & 0x07] == ioaddr
-		&& read_eeprom(ioaddr, 4) == 0x0000
-		&& (read_eeprom(ioaddr, 5) & 0xff00) == 0xF400)
+	if (at1700_probe_list[inb(ioaddr + IOCONFIG1) & 0x07] == ioaddr &&
+	    read_eeprom(ioaddr, 4) == 0x0000 &&
+	    (read_eeprom(ioaddr, 5) & 0xff00) == 0xF400)
 		is_at1700 = 1;
-	else if (inb(ioaddr   + SAPROM    ) == 0x00
-		&& inb(ioaddr + SAPROM + 1) == 0x00
-		&& inb(ioaddr + SAPROM + 2) == 0x0e)
+	else if (inb(ioaddr + SAPROM    ) == 0x00 &&
+		 inb(ioaddr + SAPROM + 1) == 0x00 &&
+		 inb(ioaddr + SAPROM + 2) == 0x0e)
 		is_fmv18x = 1;
 	else {
 		goto err_out;
@@ -839,8 +839,8 @@ set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
-	} else if (dev->mc_count > MC_FILTERBREAK
-			   ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if (dev->mc_count > MC_FILTERBREAK ||
+			   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 0c0dece..c5721cb 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -930,8 +930,8 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 			}
 #endif
 
-			if (lp->tx_full && (netif_queue_stopped(dev))
-				&& dirty_tx > lp->cur_tx - TX_RING_SIZE + 2) {
+			if (lp->tx_full && (netif_queue_stopped(dev)) &&
+				dirty_tx > lp->cur_tx - TX_RING_SIZE + 2) {
 				/* The ring is no longer full, clear tbusy. */
 				lp->tx_full = 0;
 				netif_wake_queue (dev);
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index e547f78..b6cf326 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1344,8 +1344,8 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 
 	/* link result is our setting */
 	if (!reconfig) {
-		if (adapter->link_speed != speed
-		    || adapter->link_duplex != duplex) {
+		if (adapter->link_speed != speed ||
+		    adapter->link_duplex != duplex) {
 			adapter->link_speed = speed;
 			adapter->link_duplex = duplex;
 			atl1_setup_mac_ctrl(adapter);
@@ -2087,8 +2087,8 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 	}
 	atomic_set(&tpd_ring->next_to_clean, sw_tpd_next_to_clean);
 
-	if (netif_queue_stopped(adapter->netdev)
-	    && netif_carrier_ok(adapter->netdev))
+	if (netif_queue_stopped(adapter->netdev) &&
+	    netif_carrier_ok(adapter->netdev))
 		netif_wake_queue(adapter->netdev);
 }
 
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 0017917..2f8261c 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -673,8 +673,8 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 				netif_wake_queue(dev);	/* Inform upper layers. */
 			}
 			num_tx_since_rx++;
-		} else if (num_tx_since_rx > 8
-				   && time_after(jiffies, dev->last_rx + HZ)) {
+		} else if (num_tx_since_rx > 8 &&
+			   time_after(jiffies, dev->last_rx + HZ)) {
 			if (net_debug > 2)
 				printk(KERN_DEBUG "%s: Missed packet? No Rx after %d Tx and "
 					   "%ld jiffies status %02x  CMR1 %02x.\n", dev->name,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f24ac4b..ec7ca65 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2338,8 +2338,8 @@ static struct pci_driver be_driver = {
 
 static int __init be_init_module(void)
 {
-	if (rx_frag_size != 8192 && rx_frag_size != 4096
-		&& rx_frag_size != 2048) {
+	if (rx_frag_size != 8192 && rx_frag_size != 4096 &&
+	    rx_frag_size != 2048) {
 		printk(KERN_WARNING DRV_NAME
 			" : Module param rx_frag_size must be 2048/4096/8192."
 			" Using 2048\n");
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 14bd380..8ffea39 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -554,8 +554,8 @@ static void adjust_tx_list(void)
 {
 	int timeout_cnt = MAX_TIMEOUT_CNT;
 
-	if (tx_list_head->status.status_word != 0
-	    && current_tx_ptr != tx_list_head) {
+	if (tx_list_head->status.status_word != 0 &&
+	    current_tx_ptr != tx_list_head) {
 		goto adjust_head;	/* released something, just return; */
 	}
 
@@ -567,8 +567,8 @@ static void adjust_tx_list(void)
 	if (current_tx_ptr->next->next == tx_list_head) {
 		while (tx_list_head->status.status_word == 0) {
 			udelay(10);
-			if (tx_list_head->status.status_word != 0
-			    || !(bfin_read_DMA2_IRQ_STATUS() & DMA_RUN)) {
+			if (tx_list_head->status.status_word != 0 ||
+			    !(bfin_read_DMA2_IRQ_STATUS() & DMA_RUN)) {
 				goto adjust_head;
 			}
 			if (timeout_cnt-- < 0) {
@@ -596,8 +596,8 @@ adjust_head:
 			       ": no sk_buff in a transmitted frame!\n");
 		}
 		tx_list_head = tx_list_head->next;
-	} while (tx_list_head->status.status_word != 0
-		 && current_tx_ptr != tx_list_head);
+	} while (tx_list_head->status.status_word != 0 &&
+		 current_tx_ptr != tx_list_head);
 	return;
 
 }
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 406f064..9b587c3 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -438,8 +438,8 @@ bmac_init_phy(struct net_device *dev)
 
 		ctrl = bmac_mif_read(dev, 0);
 		capable = ((bmac_mif_read(dev, 1) & 0xf800) >> 6) | 1;
-		if (bmac_mif_read(dev, 4) != capable
-		    || (ctrl & 0x1000) == 0) {
+		if (bmac_mif_read(dev, 4) != capable ||
+		    (ctrl & 0x1000) == 0) {
 			bmac_mif_write(dev, 4, capable);
 			bmac_mif_write(dev, 0, 0x1200);
 		} else
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 41b9b7b..cf57789 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -4717,8 +4717,8 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				      0xc809, &val1);
 
 			DP(NETIF_MSG_LINK, "8705 1.c809 val=0x%x\n", val1);
-			ext_phy_link_up = ((rx_sd & 0x1) && (val1 & (1<<9))
-					   && ((val1 & (1<<8)) == 0));
+			ext_phy_link_up = ((rx_sd & 0x1) && (val1 & (1<<9)) &&
+					   ((val1 & (1<<8)) == 0));
 			if (ext_phy_link_up)
 				vars->line_speed = SPEED_10000;
 			break;
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 88c3fe8..d69e683 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -561,12 +561,12 @@ static void __update_selected(struct lacpdu *lacpdu, struct port *port)
 		const struct port_params *partner = &port->partner_oper;
 
 		// check if any parameter is different
-		if (ntohs(lacpdu->actor_port) != partner->port_number
-		    || ntohs(lacpdu->actor_port_priority) != partner->port_priority
-		    || MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system)
-		    || ntohs(lacpdu->actor_system_priority) != partner->system_priority
-		    || ntohs(lacpdu->actor_key) != partner->key
-		    || (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
+		if (ntohs(lacpdu->actor_port) != partner->port_number ||
+		    ntohs(lacpdu->actor_port_priority) != partner->port_priority ||
+		    MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system) ||
+		    ntohs(lacpdu->actor_system_priority) != partner->system_priority ||
+		    ntohs(lacpdu->actor_key) != partner->key ||
+		    (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
 			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
 		}
@@ -592,12 +592,12 @@ static void __update_default_selected(struct port *port)
 		const struct port_params *oper = &port->partner_oper;
 
 		// check if any parameter is different
-		if (admin->port_number != oper->port_number
-		    || admin->port_priority != oper->port_priority
-		    || MAC_ADDRESS_COMPARE(&admin->system, &oper->system)
-		    || admin->system_priority != oper->system_priority
-		    || admin->key != oper->key
-		    || (admin->port_state & AD_STATE_AGGREGATION)
+		if (admin->port_number != oper->port_number ||
+		    admin->port_priority != oper->port_priority ||
+		    MAC_ADDRESS_COMPARE(&admin->system, &oper->system) ||
+		    admin->system_priority != oper->system_priority ||
+		    admin->key != oper->key ||
+		    (admin->port_state & AD_STATE_AGGREGATION)
 			!= (oper->port_state & AD_STATE_AGGREGATION)) {
 			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ac3fe20..af9b9c4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1852,8 +1852,8 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	if (!bond->params.fail_over_mac) {
-		if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr)
-		    && bond->slave_cnt > 1)
+		if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr) &&
+		    bond->slave_cnt > 1)
 			pr_warning(DRV_NAME
 			       ": %s: Warning: the permanent HWaddr of %s - "
 			       "%pM - is still in use by %s. "
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a51ae7d..558ec13 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -254,8 +254,8 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 
 static inline bool bond_is_lb(const struct bonding *bond)
 {
-	return bond->params.mode == BOND_MODE_TLB
-		|| bond->params.mode == BOND_MODE_ALB;
+	return (bond->params.mode == BOND_MODE_TLB ||
+		bond->params.mode == BOND_MODE_ALB);
 }
 
 #define BOND_PRI_RESELECT_ALWAYS	0
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 3e44190..591eb0e 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -318,12 +318,12 @@ static void ems_usb_rx_can_msg(struct ems_usb *dev, struct ems_cpc_msg *msg)
 	cf->can_id = le32_to_cpu(msg->msg.can_msg.id);
 	cf->can_dlc = min_t(u8, msg->msg.can_msg.length, 8);
 
-	if (msg->type == CPC_MSG_TYPE_EXT_CAN_FRAME
-	    || msg->type == CPC_MSG_TYPE_EXT_RTR_FRAME)
+	if (msg->type == CPC_MSG_TYPE_EXT_CAN_FRAME ||
+	    msg->type == CPC_MSG_TYPE_EXT_RTR_FRAME)
 		cf->can_id |= CAN_EFF_FLAG;
 
-	if (msg->type == CPC_MSG_TYPE_RTR_FRAME
-	    || msg->type == CPC_MSG_TYPE_EXT_RTR_FRAME) {
+	if (msg->type == CPC_MSG_TYPE_RTR_FRAME ||
+	    msg->type == CPC_MSG_TYPE_EXT_RTR_FRAME) {
 		cf->can_id |= CAN_RTR_FLAG;
 	} else {
 		for (i = 0; i < cf->can_dlc; i++)
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index b1a5a00..cef3f88 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2117,19 +2117,19 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 		if (t.qset_idx >= SGE_QSETS)
 			return -EINVAL;
 		if (!in_range(t.intr_lat, 0, M_NEWTIMER) ||
-			!in_range(t.cong_thres, 0, 255) ||
-			!in_range(t.txq_size[0], MIN_TXQ_ENTRIES,
-				MAX_TXQ_ENTRIES) ||
-			!in_range(t.txq_size[1], MIN_TXQ_ENTRIES,
-				MAX_TXQ_ENTRIES) ||
-			!in_range(t.txq_size[2], MIN_CTRL_TXQ_ENTRIES,
-				MAX_CTRL_TXQ_ENTRIES) ||
-			!in_range(t.fl_size[0], MIN_FL_ENTRIES,
-				MAX_RX_BUFFERS)
-			|| !in_range(t.fl_size[1], MIN_FL_ENTRIES,
-					MAX_RX_JUMBO_BUFFERS)
-			|| !in_range(t.rspq_size, MIN_RSPQ_ENTRIES,
-					MAX_RSPQ_ENTRIES))
+		    !in_range(t.cong_thres, 0, 255) ||
+		    !in_range(t.txq_size[0], MIN_TXQ_ENTRIES,
+			      MAX_TXQ_ENTRIES) ||
+		    !in_range(t.txq_size[1], MIN_TXQ_ENTRIES,
+			      MAX_TXQ_ENTRIES) ||
+		    !in_range(t.txq_size[2], MIN_CTRL_TXQ_ENTRIES,
+			      MAX_CTRL_TXQ_ENTRIES) ||
+		    !in_range(t.fl_size[0], MIN_FL_ENTRIES,
+			      MAX_RX_BUFFERS) ||
+		    !in_range(t.fl_size[1], MIN_FL_ENTRIES,
+			      MAX_RX_JUMBO_BUFFERS) ||
+		    !in_range(t.rspq_size, MIN_RSPQ_ENTRIES,
+			      MAX_RSPQ_ENTRIES))
 			return -EINVAL;
 
 		if ((adapter->flags & FULL_INIT_DONE) && t.lro > 0)
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index a2f1860..2a8b6a7 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -163,8 +163,8 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 			    strcmp (media[card_idx], "4") == 0) {
 				np->speed = 100;
 				np->full_duplex = 1;
-			} else if (strcmp (media[card_idx], "100mbps_hd") == 0
-				   || strcmp (media[card_idx], "3") == 0) {
+			} else if (strcmp (media[card_idx], "100mbps_hd") == 0 ||
+				   strcmp (media[card_idx], "3") == 0) {
 				np->speed = 100;
 				np->full_duplex = 0;
 			} else if (strcmp (media[card_idx], "10mbps_fd") == 0 ||
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 81590fb..0cbe3c0 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1024,8 +1024,8 @@ dm9000_rx(struct net_device *dev)
 		}
 
 		/* Move data from DM9000 */
-		if (GoodPacket
-		    && ((skb = dev_alloc_skb(RxLen + 4)) != NULL)) {
+		if (GoodPacket &&
+		    ((skb = dev_alloc_skb(RxLen + 4)) != NULL)) {
 			skb_reserve(skb, 2);
 			rdptr = (u8 *) skb_put(skb, RxLen - 4);
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b9d86f8..7e855f9 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3507,8 +3507,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[eop].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
-		               (adapter->tx_timeout_factor * HZ))
-		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
+		               (adapter->tx_timeout_factor * HZ)) &&
+		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 
 			/* detected Tx unit hang */
 			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 941c5f9..c3105c5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -679,8 +679,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 		adapter->detect_tx_hung = 0;
 		if (tx_ring->buffer_info[i].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp
-			       + (adapter->tx_timeout_factor * HZ))
-		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
+			       + (adapter->tx_timeout_factor * HZ)) &&
+		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 			schedule_work(&adapter->print_hang_task);
 			netif_stop_queue(netdev);
 		}
@@ -4046,8 +4046,8 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 	u16 length, offset;
 
 	if (vlan_tx_tag_present(skb)) {
-		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id)
-		    && (adapter->hw.mng_cookie.status &
+		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
+		    (adapter->hw.mng_cookie.status &
 			E1000_MNG_DHCP_COOKIE_STATUS_VLAN)))
 			return 0;
 	}
diff --git a/drivers/net/e2100.c b/drivers/net/e2100.c
index d2f6ee1..ca93c9a 100644
--- a/drivers/net/e2100.c
+++ b/drivers/net/e2100.c
@@ -186,9 +186,9 @@ static int __init e21_probe1(struct net_device *dev, int ioaddr)
 		return -EBUSY;
 
 	/* First check the station address for the Ctron prefix. */
-	if (inb(ioaddr + E21_SAPROM + 0) != 0x00
-		|| inb(ioaddr + E21_SAPROM + 1) != 0x00
-		|| inb(ioaddr + E21_SAPROM + 2) != 0x1d) {
+	if (inb(ioaddr + E21_SAPROM + 0) != 0x00 ||
+	    inb(ioaddr + E21_SAPROM + 1) != 0x00 ||
+	    inb(ioaddr + E21_SAPROM + 2) != 0x1d) {
 		retval = -ENODEV;
 		goto out;
 	}
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 7f8fcc2..7b62336 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -189,8 +189,8 @@ static void ehea_update_firmware_handles(void)
 		for (k = 0; k < EHEA_MAX_PORTS; k++) {
 			struct ehea_port *port = adapter->port[k];
 
-			if (!port || (port->state != EHEA_PORT_UP)
-				|| (num_ports == 0))
+			if (!port || (port->state != EHEA_PORT_UP) ||
+			    (num_ports == 0))
 				continue;
 
 			for (l = 0;
@@ -657,8 +657,8 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
 			  struct sk_buff *skb)
 {
-	int vlan_extracted = (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
-		&& pr->port->vgrp;
+	int vlan_extracted = ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
+			      pr->port->vgrp);
 
 	if (use_lro) {
 		if (vlan_extracted)
@@ -1389,8 +1389,8 @@ out:
 
 int ehea_rem_smrs(struct ehea_port_res *pr)
 {
-	if ((ehea_rem_mr(&pr->send_mr))
-	    || (ehea_rem_mr(&pr->recv_mr)))
+	if ((ehea_rem_mr(&pr->send_mr)) ||
+	    (ehea_rem_mr(&pr->recv_mr)))
 		return -EIO;
 	else
 		return 0;
@@ -2031,8 +2031,8 @@ static void ehea_xmit2(struct sk_buff *skb, struct net_device *dev,
 		write_ip_start_end(swqe, skb);
 
 		if (iph->protocol == IPPROTO_UDP) {
-			if ((iph->frag_off & IP_MF)
-			    || (iph->frag_off & IP_OFFSET))
+			if ((iph->frag_off & IP_MF) ||
+			    (iph->frag_off & IP_OFFSET))
 				/* IP fragment, so don't change cs */
 				swqe->tx_control &= ~EHEA_SWQE_TCP_CHECKSUM;
 			else
@@ -2077,8 +2077,8 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 			write_tcp_offset_end(swqe, skb);
 
 		} else if (iph->protocol == IPPROTO_UDP) {
-			if ((iph->frag_off & IP_MF)
-			    || (iph->frag_off & IP_OFFSET))
+			if ((iph->frag_off & IP_MF) ||
+			    (iph->frag_off & IP_OFFSET))
 				/* IP fragment, so don't change cs */
 				swqe->tx_control |= EHEA_SWQE_CRC
 						 | EHEA_SWQE_IMM_DATA_PRESENT;
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index bc7c5b7..18d405f 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -837,8 +837,8 @@ static u64 ehea_reg_mr_section(int top, int dir, int idx, u64 *pt,
 		hret = ehea_h_register_rpage_mr(adapter->handle, mr->handle, 0,
 						0, pt_abs, EHEA_MAX_RPAGE);
 
-		if ((hret != H_SUCCESS)
-		    && (hret != H_PAGE_REGISTERED)) {
+		if ((hret != H_SUCCESS) &&
+		    (hret != H_PAGE_REGISTERED)) {
 			ehea_h_free_resource(adapter->handle, mr->handle,
 					     FORCE_FREE);
 			ehea_error("register_rpage_mr failed");
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 703b4c8..41494f7 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -630,8 +630,8 @@ static int mdio_read(struct net_device *dev, int phy_id, int location)
 		barrier();
 		if ((inl(ioaddr + MIICtrl) & MII_READOP) == 0) {
 			/* Work around read failure bug. */
-			if (phy_id == 1 && location < 6
-				&& inw(ioaddr + MIIData) == 0xffff) {
+			if (phy_id == 1 && location < 6 &&
+			    inw(ioaddr + MIIData) == 0xffff) {
 				outl(read_cmd, ioaddr + MIICtrl);
 				continue;
 			}
@@ -1205,8 +1205,8 @@ static int epic_rx(struct net_device *dev, int budget)
 			}
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak
-				&& (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(ep->pci_dev,
 							    ep->rx_ring[entry].bufaddr,
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index e173515..dac4e59 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1629,8 +1629,8 @@ static int netdev_rx(struct net_device *dev)
 		if (debug)
 			printk(KERN_DEBUG "  netdev_rx() status was %8.8x.\n", rx_status);
 
-		if ((!((rx_status & RXFSD) && (rx_status & RXLSD)))
-		    || (rx_status & ErrorSummary)) {
+		if ((!((rx_status & RXFSD) && (rx_status & RXLSD))) ||
+		    (rx_status & ErrorSummary)) {
 			if (rx_status & ErrorSummary) {	/* there was a fatal error */
 				if (debug)
 					printk(KERN_DEBUG
@@ -1655,8 +1655,8 @@ static int netdev_rx(struct net_device *dev)
 					cur = np->cur_rx;
 					while (desno <= np->really_rx_count) {
 						++desno;
-						if ((!(cur->status & RXOWN))
-						    && (cur->status & RXLSD))
+						if ((!(cur->status & RXOWN)) &&
+						    (cur->status & RXLSD))
 							break;
 						/* goto next rx descriptor */
 						cur = cur->next_desc_logical;
@@ -1786,8 +1786,8 @@ static void __set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = CR_W_PROM | CR_W_AB | CR_W_AM;
-	} else if ((dev->mc_count > multicast_filter_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = CR_W_AB | CR_W_AM;
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index b31c9c8..b98c6c5 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -62,8 +62,8 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 	/* Find out the new setting */
 	if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
 		new_setting = 1;
-	else if (!strncmp("off", buf, count - 1)
-		 || !strncmp("0", buf, count - 1))
+	else if (!strncmp("off", buf, count - 1) ||
+		 !strncmp("0", buf, count - 1))
 		new_setting = 0;
 	else
 		return count;
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 5d8c633..ea85075 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1566,8 +1566,8 @@ static int hamachi_rx(struct net_device *dev)
 #endif
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak
-				&& (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 #ifdef RX_CHECKSUM
 				printk(KERN_ERR "%s: rx_copybreak non-zero "
 				  "not good with RX_CHECKSUM\n", dev->name);
@@ -1722,10 +1722,10 @@ static void hamachi_error(struct net_device *dev, int intr_status)
 		readl(ioaddr + 0x370);
 		readl(ioaddr + 0x3F0);
 	}
-	if ((intr_status & ~(LinkChange|StatsMax|NegotiationChange|IntrRxDone|IntrTxDone))
-		&& hamachi_debug)
+	if ((intr_status & ~(LinkChange|StatsMax|NegotiationChange|IntrRxDone|IntrTxDone)) &&
+	    hamachi_debug)
 		printk(KERN_ERR "%s: Something Wicked happened! %4.4x.\n",
-			   dev->name, intr_status);
+		       dev->name, intr_status);
 	/* Hmmmmm, it's not clear how to recover from PCI faults. */
 	if (intr_status & (IntrTxPCIErr | IntrTxPCIFault))
 		hmp->stats.tx_fifo_errors++;
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 76abed9..ae5f11c 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -167,10 +167,7 @@ static inline struct net_device *bpq_get_ax25_dev(struct net_device *dev)
 
 static inline int dev_is_ethdev(struct net_device *dev)
 {
-	return (
-			dev->type == ARPHRD_ETHER
-			&& strncmp(dev->name, "dummy", 5)
-	);
+	return (dev->type == ARPHRD_ETHER && strncmp(dev->name, "dummy", 5));
 }
 
 /* ------------------------------------------------------------------------ */
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 950f3bb..9ee76b4 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -331,8 +331,8 @@ static int __init dmascc_init(void)
 			for (i = 0; i < MAX_NUM_DEVS && io[i]; i++) {
 				j = (io[i] -
 				     hw[h].io_region) / hw[h].io_delta;
-				if (j >= 0 && j < hw[h].num_devs
-				    && hw[h].io_region +
+				if (j >= 0 && j < hw[h].num_devs &&
+				    hw[h].io_region +
 				    j * hw[h].io_delta == io[i]) {
 					base[j] = io[i];
 				}
@@ -396,8 +396,8 @@ static int __init dmascc_init(void)
 					t_val =
 					    inb(t1[i]) + (inb(t1[i]) << 8);
 					/* Also check whether counter did wrap */
-					if (t_val == 0
-					    || t_val > TMR_0_HZ / HZ * 10)
+					if (t_val == 0 ||
+					    t_val > TMR_0_HZ / HZ * 10)
 						counting[i] = 0;
 					delay[i] = jiffies - start[i];
 				}
diff --git a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
index 0486cbe..efdbcad 100644
--- a/drivers/net/hp-plus.c
+++ b/drivers/net/hp-plus.c
@@ -187,8 +187,8 @@ static int __init hpp_probe1(struct net_device *dev, int ioaddr)
 		return -EBUSY;
 
 	/* Check for the HP+ signature, 50 48 0x 53. */
-	if (inw(ioaddr + HP_ID) != 0x4850
-		|| (inw(ioaddr + HP_PAGING) & 0xfff0) != 0x5300) {
+	if (inw(ioaddr + HP_ID) != 0x4850 ||
+	    (inw(ioaddr + HP_PAGING) & 0xfff0) != 0x5300) {
 		retval = -ENODEV;
 		goto out;
 	}
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index dd86651..90f890e 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -993,8 +993,8 @@ static void hp100_mmuinit(struct net_device *dev)
 	if (lp->mode == 1) {	/* only needed for Busmaster */
 		int xmit_stop, recv_stop;
 
-		if ((lp->chip == HP100_CHIPID_RAINIER)
-		    || (lp->chip == HP100_CHIPID_SHASTA)) {
+		if ((lp->chip == HP100_CHIPID_RAINIER) ||
+		    (lp->chip == HP100_CHIPID_SHASTA)) {
 			int pdl_stop;
 
 			/*
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index af117c6..fb5e019 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1976,27 +1976,27 @@ static int emac_ethtool_set_settings(struct net_device *ndev,
 	if (cmd->autoneg == AUTONEG_DISABLE) {
 		switch (cmd->speed) {
 		case SPEED_10:
-			if (cmd->duplex == DUPLEX_HALF
-			    && !(f & SUPPORTED_10baseT_Half))
+			if (cmd->duplex == DUPLEX_HALF &&
+			    !(f & SUPPORTED_10baseT_Half))
 				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL
-			    && !(f & SUPPORTED_10baseT_Full))
+			if (cmd->duplex == DUPLEX_FULL &&
+			    !(f & SUPPORTED_10baseT_Full))
 				return -EINVAL;
 			break;
 		case SPEED_100:
-			if (cmd->duplex == DUPLEX_HALF
-			    && !(f & SUPPORTED_100baseT_Half))
+			if (cmd->duplex == DUPLEX_HALF &&
+			    !(f & SUPPORTED_100baseT_Half))
 				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL
-			    && !(f & SUPPORTED_100baseT_Full))
+			if (cmd->duplex == DUPLEX_FULL &&
+			    !(f & SUPPORTED_100baseT_Full))
 				return -EINVAL;
 			break;
 		case SPEED_1000:
-			if (cmd->duplex == DUPLEX_HALF
-			    && !(f & SUPPORTED_1000baseT_Half))
+			if (cmd->duplex == DUPLEX_HALF &&
+			    !(f & SUPPORTED_1000baseT_Half))
 				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL
-			    && !(f & SUPPORTED_1000baseT_Full))
+			if (cmd->duplex == DUPLEX_FULL &&
+			    !(f & SUPPORTED_1000baseT_Full))
 				return -EINVAL;
 			break;
 		default:
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e57b32d..16349ba 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4974,9 +4974,8 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 		tx_ring->detect_tx_hung = false;
 		if (tx_ring->buffer_info[i].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp +
-			       (adapter->tx_timeout_factor * HZ))
-		    && !(rd32(E1000_STATUS) &
-			 E1000_STATUS_TXOFF)) {
+			       (adapter->tx_timeout_factor * HZ)) &&
+		    !(rd32(E1000_STATUS) & E1000_STATUS_TXOFF)) {
 
 			/* detected Tx unit hang */
 			dev_err(&tx_ring->pdev->dev,
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index cf26f92..a127620 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -827,8 +827,8 @@ static bool igbvf_clean_tx_irq(struct igbvf_ring *tx_ring)
 		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[i].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp +
-		               (adapter->tx_timeout_factor * HZ))
-		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
+		               (adapter->tx_timeout_factor * HZ)) &&
+		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 
 			tx_desc = IGBVF_TX_DESC_ADV(*tx_ring, i);
 			/* detected Tx unit hang */
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index ae6eab3..e8e33bb 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1124,11 +1124,11 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
                  * The actual image starts after the "STMP" keyword
                  * so forward to the firmware header tag
                  */
-                for (i = 0; (fw->data[i] != STIR421X_PATCH_END_OF_HDR_TAG)
-			     && (i < fw->size); i++) ;
+                for (i = 0; (fw->data[i] != STIR421X_PATCH_END_OF_HDR_TAG) &&
+			     (i < fw->size); i++) ;
                 /* here we check for the out of buffer case */
-                if ((STIR421X_PATCH_END_OF_HDR_TAG == fw->data[i])
-                    && (i < STIR421X_PATCH_CODE_OFFSET)) {
+                if ((STIR421X_PATCH_END_OF_HDR_TAG == fw->data[i]) &&
+                    (i < STIR421X_PATCH_CODE_OFFSET)) {
                         if (!memcmp(fw->data + i + 1, STIR421X_PATCH_STMP_TAG,
                                     sizeof(STIR421X_PATCH_STMP_TAG) - 1)) {
 
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 528767d..e5698fa 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -612,16 +612,16 @@ static int fifo_txwait(struct stir_cb *stir, int space)
 		pr_debug("fifo status 0x%lx count %lu\n", status, count);
 
 		/* is fifo receiving already, or empty */
-		if (!(status & FIFOCTL_DIR)
-		    || (status & FIFOCTL_EMPTY))
+		if (!(status & FIFOCTL_DIR) ||
+		    (status & FIFOCTL_EMPTY))
 			return 0;
 
 		if (signal_pending(current))
 			return -EINTR;
 
 		/* shutting down? */
-		if (!netif_running(stir->netdev)
-		    || !netif_device_present(stir->netdev))
+		if (!netif_running(stir->netdev) ||
+		    !netif_device_present(stir->netdev))
 			return -ESHUTDOWN;
 
 		/* only waiting for some space */
@@ -776,8 +776,8 @@ static int stir_transmit_thread(void *arg)
 		}
 
 		/* nothing to send? start receiving */
-		if (!stir->receiving 
-		    && irda_device_txqueue_empty(dev)) {
+		if (!stir->receiving &&
+		    irda_device_txqueue_empty(dev)) {
 			/* Wait otherwise chip gets confused. */
 			if (fifo_txwait(stir, -1))
 				break;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index a5ca71c..fddb4ef 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1185,8 +1185,8 @@ F01_E */
 		 * if frame size,data ptr,or skb ptr are wrong ,the get next
 		 * entry.
 		 */
-		if ((skb == NULL) || (skb->data == NULL)
-		    || (self->rx_buff.data == NULL) || (len < 6)) {
+		if ((skb == NULL) || (skb->data == NULL) ||
+		    (self->rx_buff.data == NULL) || (len < 6)) {
 			self->netdev->stats.rx_dropped++;
 			return TRUE;
 		}
@@ -1284,8 +1284,8 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 		self->RetryCount++;
 
 	if ((self->RetryCount >= 1) ||
-	    ((st_fifo->pending_bytes + 2048) > self->rx_buff.truesize)
-	    || (st_fifo->len >= (MAX_RX_WINDOW))) {
+	    ((st_fifo->pending_bytes + 2048) > self->rx_buff.truesize) ||
+	    (st_fifo->len >= (MAX_RX_WINDOW))) {
 		while (st_fifo->len > 0) {	//upload frame
 			// Put this entry back in fifo 
 			if (st_fifo->head > MAX_RX_WINDOW)
@@ -1300,8 +1300,8 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 			 * if frame size, data ptr, or skb ptr are wrong,
 			 * then get next entry.
 			 */
-			if ((skb == NULL) || (skb->data == NULL)
-			    || (self->rx_buff.data == NULL) || (len < 6)) {
+			if ((skb == NULL) || (skb->data == NULL) ||
+			    (self->rx_buff.data == NULL) || (len < 6)) {
 				self->netdev->stats.rx_dropped++;
 				continue;
 			}
@@ -1332,8 +1332,8 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 		 * if frame is receive complete at this routine ,then upload
 		 * frame.
 		 */
-		if ((GetRXStatus(iobase) & 0x10)
-		    && (RxCurCount(iobase, self) != self->RxLastCount)) {
+		if ((GetRXStatus(iobase) & 0x10) &&
+		    (RxCurCount(iobase, self) != self->RxLastCount)) {
 			upload_rxdata(self, iobase);
 			if (irda_device_txqueue_empty(self->netdev))
 				via_ircc_dma_receive(self);
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 7cfb8b6..bd3c6b5 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -431,8 +431,8 @@ static struct vlsi_ring *vlsi_alloc_ring(struct pci_dev *pdev, struct ring_descr
 		memset(rd, 0, sizeof(*rd));
 		rd->hw = hwmap + i;
 		rd->buf = kmalloc(len, GFP_KERNEL|GFP_DMA);
-		if (rd->buf == NULL
-		    ||  !(busaddr = pci_map_single(pdev, rd->buf, len, dir))) {
+		if (rd->buf == NULL ||
+		    !(busaddr = pci_map_single(pdev, rd->buf, len, dir))) {
 			if (rd->buf) {
 				IRDA_ERROR("%s: failed to create PCI-MAP for %p",
 					   __func__, rd->buf);
@@ -955,8 +955,8 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 		}
 		for(;;) {
 			do_gettimeofday(&now);
-			if (now.tv_sec > ready.tv_sec
-			    ||  (now.tv_sec==ready.tv_sec && now.tv_usec>=ready.tv_usec))
+			if (now.tv_sec > ready.tv_sec ||
+			    (now.tv_sec==ready.tv_sec && now.tv_usec>=ready.tv_usec))
 			    	break;
 			udelay(100);
 			/* must not sleep here - called under netif_tx_lock! */
@@ -1594,8 +1594,8 @@ static int vlsi_irda_init(struct net_device *ndev)
 	 * see include file for details why we need these 2 masks, in this order!
 	 */
 
-	if (pci_set_dma_mask(pdev,DMA_MASK_USED_BY_HW)
-	    || pci_set_dma_mask(pdev,DMA_MASK_MSTRPAGE)) {
+	if (pci_set_dma_mask(pdev,DMA_MASK_USED_BY_HW) ||
+	    pci_set_dma_mask(pdev,DMA_MASK_MSTRPAGE)) {
 		IRDA_ERROR("%s: aborting due to PCI BM-DMA address limitations\n", __func__);
 		return -1;
 	}
@@ -1641,8 +1641,8 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	IRDA_MESSAGE("%s: IrDA PCI controller %s detected\n",
 		     drivername, pci_name(pdev));
 
-	if ( !pci_resource_start(pdev,0)
-	     || !(pci_resource_flags(pdev,0) & IORESOURCE_IO) ) {
+	if ( !pci_resource_start(pdev,0) ||
+	     !(pci_resource_flags(pdev,0) & IORESOURCE_IO) ) {
 		IRDA_ERROR("%s: bar 0 invalid", __func__);
 		goto out_disable;
 	}
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 0e71e2a..04d0502 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -214,9 +214,9 @@ static int __init netcard_probe1(struct net_device *dev, int ioaddr)
 	 * contains the manufacturer's unique code. That might be a good probe
 	 * method. Ideally you would add additional checks.
 	 */
-	if (inb(ioaddr + 0) != SA_ADDR0
-		||	 inb(ioaddr + 1) != SA_ADDR1
-		||	 inb(ioaddr + 2) != SA_ADDR2)
+	if (inb(ioaddr + 0) != SA_ADDR0 ||
+	    inb(ioaddr + 1) != SA_ADDR1 ||
+	    inb(ioaddr + 2) != SA_ADDR2)
 		goto out;
 
 	if (net_debug  &&  version_printed++ == 0)
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index aa7286b..4999719 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -604,10 +604,10 @@ static int veth_process_caps(struct veth_lpar_connection *cnx)
 	/* Convert timer to jiffies */
 	cnx->ack_timeout = remote_caps->ack_timeout * HZ / 1000000;
 
-	if ( (remote_caps->num_buffers == 0)
-	     || (remote_caps->ack_threshold > VETH_MAX_ACKS_PER_MSG)
-	     || (remote_caps->ack_threshold == 0)
-	     || (cnx->ack_timeout == 0) ) {
+	if ( (remote_caps->num_buffers == 0) ||
+	     (remote_caps->ack_threshold > VETH_MAX_ACKS_PER_MSG) ||
+	     (remote_caps->ack_threshold == 0) ||
+	     (cnx->ack_timeout == 0) ) {
 		veth_error("Received incompatible capabilities from LPAR %d.\n",
 				cnx->remote_lp);
 		return HvLpEvent_Rc_InvalidSubtypeData;
@@ -714,8 +714,8 @@ static void veth_statemachine(struct work_struct *work)
 		cnx->state |= VETH_STATE_OPEN;
 	}
 
-	if ( (cnx->state & VETH_STATE_OPEN)
-	     && !(cnx->state & VETH_STATE_SENTMON) ) {
+	if ( (cnx->state & VETH_STATE_OPEN) &&
+	     !(cnx->state & VETH_STATE_SENTMON) ) {
 		rc = veth_signalevent(cnx, VETH_EVENT_MONITOR,
 				      HvLpEvent_AckInd_DoAck,
 				      HvLpEvent_AckType_DeferredAck,
@@ -724,8 +724,8 @@ static void veth_statemachine(struct work_struct *work)
 		if (rc == HvLpEvent_Rc_Good) {
 			cnx->state |= VETH_STATE_SENTMON;
 		} else {
-			if ( (rc != HvLpEvent_Rc_PartitionDead)
-			     && (rc != HvLpEvent_Rc_PathClosed) )
+			if ( (rc != HvLpEvent_Rc_PartitionDead) &&
+			     (rc != HvLpEvent_Rc_PathClosed) )
 				veth_error("Error sending monitor to LPAR %d, "
 						"rc = %d\n", rlp, rc);
 
@@ -735,8 +735,8 @@ static void veth_statemachine(struct work_struct *work)
 		}
 	}
 
-	if ( (cnx->state & VETH_STATE_OPEN)
-	     && !(cnx->state & VETH_STATE_SENTCAPS)) {
+	if ( (cnx->state & VETH_STATE_OPEN) &&
+	     !(cnx->state & VETH_STATE_SENTCAPS)) {
 		u64 *rawcap = (u64 *)&cnx->local_caps;
 
 		rc = veth_signalevent(cnx, VETH_EVENT_CAP,
@@ -748,8 +748,8 @@ static void veth_statemachine(struct work_struct *work)
 		if (rc == HvLpEvent_Rc_Good) {
 			cnx->state |= VETH_STATE_SENTCAPS;
 		} else {
-			if ( (rc != HvLpEvent_Rc_PartitionDead)
-			     && (rc != HvLpEvent_Rc_PathClosed) )
+			if ( (rc != HvLpEvent_Rc_PartitionDead) &&
+			     (rc != HvLpEvent_Rc_PathClosed) )
 				veth_error("Error sending caps to LPAR %d, "
 						"rc = %d\n", rlp, rc);
 
@@ -759,8 +759,8 @@ static void veth_statemachine(struct work_struct *work)
 		}
 	}
 
-	if ((cnx->state & VETH_STATE_GOTCAPS)
-	    && !(cnx->state & VETH_STATE_SENTCAPACK)) {
+	if ((cnx->state & VETH_STATE_GOTCAPS) &&
+	    !(cnx->state & VETH_STATE_SENTCAPACK)) {
 		struct veth_cap_data *remote_caps = &cnx->remote_caps;
 
 		memcpy(remote_caps, &cnx->cap_event.u.caps_data,
@@ -783,9 +783,9 @@ static void veth_statemachine(struct work_struct *work)
 			goto cant_cope;
 	}
 
-	if ((cnx->state & VETH_STATE_GOTCAPACK)
-	    && (cnx->state & VETH_STATE_GOTCAPS)
-	    && !(cnx->state & VETH_STATE_READY)) {
+	if ((cnx->state & VETH_STATE_GOTCAPACK) &&
+	    (cnx->state & VETH_STATE_GOTCAPS) &&
+	    !(cnx->state & VETH_STATE_READY)) {
 		if (cnx->cap_ack_event.base_event.xRc == HvLpEvent_Rc_Good) {
 			/* Start the ACK timer */
 			cnx->ack_timer.expires = jiffies + cnx->ack_timeout;
@@ -818,8 +818,8 @@ static int veth_init_connection(u8 rlp)
 	struct veth_msg *msgs;
 	int i;
 
-	if ( (rlp == this_lp)
-	     || ! HvLpConfig_doLpsCommunicateOnVirtualLan(this_lp, rlp) )
+	if ( (rlp == this_lp) ||
+	     ! HvLpConfig_doLpsCommunicateOnVirtualLan(this_lp, rlp) )
 		return 0;
 
 	cnx = kzalloc(sizeof(*cnx), GFP_KERNEL);
@@ -1538,8 +1538,8 @@ static void veth_receive(struct veth_lpar_connection *cnx,
 	cnx->pending_acks[cnx->num_pending_acks++] =
 		event->base_event.xCorrelationToken;
 
-	if ( (cnx->num_pending_acks >= cnx->remote_caps.ack_threshold)
-	     || (cnx->num_pending_acks >= VETH_MAX_ACKS_PER_MSG) )
+	if ( (cnx->num_pending_acks >= cnx->remote_caps.ack_threshold) ||
+	     (cnx->num_pending_acks >= VETH_MAX_ACKS_PER_MSG) )
 		veth_flush_acks(cnx);
 
 	spin_unlock_irqrestore(&cnx->lock, flags);
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 35d5bed..f47d4d6 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -130,8 +130,8 @@ static int __devinit sonic_probe1(struct net_device *dev)
 		printk("SONIC Silicon Revision = 0x%04x\n",silicon_revision);
 
 	i = 0;
-	while (known_revisions[i] != 0xffff
-	       && known_revisions[i] != silicon_revision)
+	while (known_revisions[i] != 0xffff &&
+	       known_revisions[i] != silicon_revision)
 		i++;
 
 	if (known_revisions[i] == 0xffff) {
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 6c1b92f..792b88f 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1050,8 +1050,8 @@ jme_dynamic_pcc(struct jme_adapter *jme)
 
 	if ((NET_STAT(jme).rx_bytes - dpi->last_bytes) > PCC_P3_THRESHOLD)
 		jme_attempt_pcc(dpi, PCC_P3);
-	else if ((NET_STAT(jme).rx_packets - dpi->last_pkts) > PCC_P2_THRESHOLD
-	|| dpi->intr_cnt > PCC_INTR_THRESHOLD)
+	else if ((NET_STAT(jme).rx_packets - dpi->last_pkts) > PCC_P2_THRESHOLD ||
+		 dpi->intr_cnt > PCC_INTR_THRESHOLD)
 		jme_attempt_pcc(dpi, PCC_P2);
 	else
 		jme_attempt_pcc(dpi, PCC_P1);
@@ -2199,8 +2199,8 @@ jme_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecmd)
 	if (netif_running(netdev))
 		return -EBUSY;
 
-	if (ecmd->use_adaptive_rx_coalesce
-	&& test_bit(JME_FLAG_POLL, &jme->flags)) {
+	if (ecmd->use_adaptive_rx_coalesce &&
+	    test_bit(JME_FLAG_POLL, &jme->flags)) {
 		clear_bit(JME_FLAG_POLL, &jme->flags);
 		jme->jme_rx = netif_rx;
 		jme->jme_vlan_rx = vlan_hwaccel_rx;
@@ -2209,8 +2209,8 @@ jme_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecmd)
 		dpi->cnt		= 0;
 		jme_set_rx_pcc(jme, PCC_P1);
 		jme_interrupt_mode(jme);
-	} else if (!(ecmd->use_adaptive_rx_coalesce)
-	&& !(test_bit(JME_FLAG_POLL, &jme->flags))) {
+	} else if (!(ecmd->use_adaptive_rx_coalesce) &&
+		   !(test_bit(JME_FLAG_POLL, &jme->flags))) {
 		set_bit(JME_FLAG_POLL, &jme->flags);
 		jme->jme_rx = netif_receive_skb;
 		jme->jme_vlan_rx = vlan_hwaccel_receive_skb;
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 7b2c429..8d7d3d4 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -493,14 +493,14 @@ static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int
 		static const short ioaddr_table[] = { 0x300, 0x320, 0x340, 0x360};
 		int hp_port = (readl(bios + 1) & 1)  ? 0x499 : 0x99;
 		/* We can have boards other than the built-in!  Verify this is on-board. */
-		if ((inb(hp_port) & 0xc0) == 0x80
-			&& ioaddr_table[inb(hp_port) & 3] == ioaddr)
+		if ((inb(hp_port) & 0xc0) == 0x80 &&
+		    ioaddr_table[inb(hp_port) & 3] == ioaddr)
 			hp_builtin = hp_port;
 	}
 	iounmap(bios);
 	/* We also recognize the HP Vectra on-board here, but check below. */
-	hpJ2405A = (inb(ioaddr) == 0x08 && inb(ioaddr+1) == 0x00
-				&& inb(ioaddr+2) == 0x09);
+	hpJ2405A = (inb(ioaddr) == 0x08 && inb(ioaddr+1) == 0x00 &&
+		    inb(ioaddr+2) == 0x09);
 
 	/* Reset the LANCE.	 */
 	reset_val = inw(ioaddr+LANCE_RESET); /* Reset the LANCE */
@@ -1035,8 +1035,8 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 	spin_lock (&lp->devlock);
 
 	outw(0x00, dev->base_addr + LANCE_ADDR);
-	while ((csr0 = inw(dev->base_addr + LANCE_DATA)) & 0x8600
-		   && --boguscnt >= 0) {
+	while ((csr0 = inw(dev->base_addr + LANCE_DATA)) & 0x8600 &&
+	       --boguscnt >= 0) {
 		/* Acknowledge all of the current interrupt sources ASAP. */
 		outw(csr0 & ~0x004f, dev->base_addr + LANCE_DATA);
 
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 2561198..57f2584 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -464,8 +464,8 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 			   ei_inb_p(e8390_base + EN0_ISR));
 
 	/* !!Assumption!! -- we stay in page 0.	 Don't break this. */
-	while ((interrupts = ei_inb_p(e8390_base + EN0_ISR)) != 0
-		   && ++nr_serviced < MAX_SERVICE)
+	while ((interrupts = ei_inb_p(e8390_base + EN0_ISR)) != 0 &&
+	       ++nr_serviced < MAX_SERVICE)
 	{
 		if (!netif_running(dev)) {
 			printk(KERN_WARNING "%s: interrupt from stopped card\n", dev->name);
@@ -721,10 +721,10 @@ static void ei_receive(struct net_device *dev)
 		/* Check for bogosity warned by 3c503 book: the status byte is never
 		   written.  This happened a lot during testing! This code should be
 		   cleaned up someday. */
-		if (rx_frame.next != next_frame
-			&& rx_frame.next != next_frame + 1
-			&& rx_frame.next != next_frame - num_rx_pages
-			&& rx_frame.next != next_frame + 1 - num_rx_pages) {
+		if (rx_frame.next != next_frame &&
+		    rx_frame.next != next_frame + 1 &&
+		    rx_frame.next != next_frame - num_rx_pages &&
+		    rx_frame.next != next_frame + 1 - num_rx_pages) {
 			ei_local->current_page = rxing_page;
 			ei_outb(ei_local->current_page-1, e8390_base+EN0_BOUNDARY);
 			dev->stats.rx_errors++;
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index f2a197f..336e7c7 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -231,8 +231,8 @@ static void temac_set_multicast_list(struct net_device *ndev)
 	int i;
 
 	mutex_lock(&lp->indirect_mutex);
-	if (ndev->flags & (IFF_ALLMULTI | IFF_PROMISC)
-			|| ndev->mc_count > MULTICAST_CAM_TABLE_NUM) {
+	if (ndev->flags & (IFF_ALLMULTI | IFF_PROMISC) ||
+	    ndev->mc_count > MULTICAST_CAM_TABLE_NUM) {
 		/*
 		 *	We must make the kernel realise we had to move
 		 *	into promisc mode or we start all out war on
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index c244ec3..23b633e 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -222,8 +222,8 @@ struct net_device * __init mac89x0_probe(int unit)
 		int card_present;
 
 		local_irq_save(flags);
-		card_present = hwreg_present((void*) ioaddr+4)
-		  && hwreg_present((void*) ioaddr + DATA_PORT);
+		card_present = (hwreg_present((void*) ioaddr+4) &&
+				hwreg_present((void*) ioaddr + DATA_PORT));
 		local_irq_restore(flags);
 
 		if (!card_present)
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 7d7577b..d9fbad3 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -897,8 +897,8 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 	    if (next >= N_RX_RING)
 		next = 0;
 	    np = mp->rx_cmds + next;
-	    if (next != mp->rx_fill
-		&& (ld_le16(&np->xfer_status) & ACTIVE) != 0) {
+	    if (next != mp->rx_fill &&
+		(ld_le16(&np->xfer_status) & ACTIVE) != 0) {
 		printk(KERN_DEBUG "mace: lost a status word\n");
 		++mace_lost_status;
 	    } else
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 85e1b6a..d389219 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -410,8 +410,8 @@ myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
 		 * and try to get the completion quickly
 		 * (1ms will be enough for those commands) */
 		for (sleep_total = 0;
-		     sleep_total < 1000
-		     && response->result == htonl(MYRI10GE_NO_RESPONSE_RESULT);
+		     sleep_total < 1000 &&
+		     response->result == htonl(MYRI10GE_NO_RESPONSE_RESULT);
 		     sleep_total += 10) {
 			udelay(10);
 			mb();
@@ -419,8 +419,8 @@ myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
 	} else {
 		/* use msleep for most command */
 		for (sleep_total = 0;
-		     sleep_total < 15
-		     && response->result == htonl(MYRI10GE_NO_RESPONSE_RESULT);
+		     sleep_total < 15 &&
+		     response->result == htonl(MYRI10GE_NO_RESPONSE_RESULT);
 		     sleep_total++)
 			msleep(1);
 	}
@@ -557,8 +557,8 @@ myri10ge_validate_firmware(struct myri10ge_priv *mgp,
 	sscanf(mgp->fw_version, "%d.%d.%d", &mgp->fw_ver_major,
 	       &mgp->fw_ver_minor, &mgp->fw_ver_tiny);
 
-	if (!(mgp->fw_ver_major == MXGEFW_VERSION_MAJOR
-	      && mgp->fw_ver_minor == MXGEFW_VERSION_MINOR)) {
+	if (!(mgp->fw_ver_major == MXGEFW_VERSION_MAJOR &&
+	      mgp->fw_ver_minor == MXGEFW_VERSION_MINOR)) {
 		dev_err(dev, "Found firmware version %s\n", mgp->fw_version);
 		dev_err(dev, "Driver needs %d.%d\n", MXGEFW_VERSION_MAJOR,
 			MXGEFW_VERSION_MINOR);
@@ -1412,8 +1412,8 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 	}
 
 	/* start the queue if we've stopped it */
-	if (netif_tx_queue_stopped(dev_queue)
-	    && tx->req - tx->done < (tx->mask >> 1)) {
+	if (netif_tx_queue_stopped(dev_queue) &&
+	    tx->req - tx->done < (tx->mask >> 1)) {
 		tx->wake_queue++;
 		netif_tx_wake_queue(dev_queue);
 	}
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9a8d3ab..797fe16 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -683,8 +683,8 @@ static ssize_t natsemi_set_dspcfg_workaround(struct device *dev,
         /* Find out the new setting */
         if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
                 new_setting = 1;
-        else if (!strncmp("off", buf, count - 1)
-                 || !strncmp("0", buf, count - 1))
+        else if (!strncmp("off", buf, count - 1) ||
+                 !strncmp("0", buf, count - 1))
 		new_setting = 0;
 	else
                  return count;
@@ -757,8 +757,8 @@ static void __devinit natsemi_init_media (struct net_device *dev)
 	np->autoneg    = (tmp & BMCR_ANENABLE)? AUTONEG_ENABLE: AUTONEG_DISABLE;
 	np->advertising= mdio_read(dev, MII_ADVERTISE);
 
-	if ((np->advertising & ADVERTISE_ALL) != ADVERTISE_ALL
-	 && netif_msg_probe(np)) {
+	if ((np->advertising & ADVERTISE_ALL) != ADVERTISE_ALL &&
+	    netif_msg_probe(np)) {
 		printk(KERN_INFO "natsemi %s: Transceiver default autonegotiation %s "
 			"10%s %s duplex.\n",
 			pci_name(np->pci_dev),
@@ -1153,8 +1153,8 @@ static void init_phy_fixup(struct net_device *dev)
 	tmp = mdio_read(dev, MII_BMCR);
 	if (np->autoneg == AUTONEG_ENABLE) {
 		/* renegotiate if something changed */
-		if ((tmp & BMCR_ANENABLE) == 0
-		 || np->advertising != mdio_read(dev, MII_ADVERTISE))
+		if ((tmp & BMCR_ANENABLE) == 0 ||
+		    np->advertising != mdio_read(dev, MII_ADVERTISE))
 		{
 			/* turn on autonegotiation and force negotiation */
 			tmp |= (BMCR_ANENABLE | BMCR_ANRESTART);
@@ -2164,8 +2164,8 @@ static void netdev_tx_done(struct net_device *dev)
 		dev_kfree_skb_irq(np->tx_skbuff[entry]);
 		np->tx_skbuff[entry] = NULL;
 	}
-	if (netif_queue_stopped(dev)
-		&& np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
+	if (netif_queue_stopped(dev) &&
+	    np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 		/* The ring is no longer full, wake queue. */
 		netif_wake_queue(dev);
 	}
@@ -2343,8 +2343,8 @@ static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do)
 			/* Omit CRC size. */
 			/* Check if the packet is long enough to accept
 			 * without copying to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak
-			    && (skb = dev_alloc_skb(pkt_len + RX_OFFSET)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+			    (skb = dev_alloc_skb(pkt_len + RX_OFFSET)) != NULL) {
 				/* 16 byte align the IP header */
 				skb_reserve(skb, RX_OFFSET);
 				pci_dma_sync_single_for_cpu(np->pci_dev,
@@ -2390,8 +2390,8 @@ static void netdev_error(struct net_device *dev, int intr_status)
 	spin_lock(&np->lock);
 	if (intr_status & LinkChange) {
 		u16 lpa = mdio_read(dev, MII_LPA);
-		if (mdio_read(dev, MII_BMCR) & BMCR_ANENABLE
-		 && netif_msg_link(np)) {
+		if (mdio_read(dev, MII_BMCR) & BMCR_ANENABLE &&
+		    netif_msg_link(np)) {
 			printk(KERN_INFO
 				"%s: Autonegotiation advertising"
 				" %#04x  partner %#04x.\n", dev->name,
@@ -2488,8 +2488,8 @@ static void __set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) { /* Set promiscuous. */
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptAllPhys | AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit)
-	  || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptMyPhys;
 	} else {
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index c86095e..ddd704a 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -257,18 +257,18 @@ netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	/* read which mode */
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		/* autonegotiation */
-		if (adapter->phy_write
-		    && adapter->phy_write(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					  ecmd->autoneg) != 0)
+		if (adapter->phy_write &&
+		    adapter->phy_write(adapter,
+				       NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
+				       ecmd->autoneg) != 0)
 			return -EIO;
 		else
 			adapter->link_autoneg = ecmd->autoneg;
 
-		if (adapter->phy_read
-		    && adapter->phy_read(adapter,
-					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					 &status) != 0)
+		if (adapter->phy_read &&
+		    adapter->phy_read(adapter,
+				      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+				      &status) != 0)
 			return -EIO;
 
 		/* speed */
@@ -288,10 +288,10 @@ netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			netxen_clear_phy_duplex(status);
 		if (ecmd->duplex == DUPLEX_FULL)
 			netxen_set_phy_duplex(status);
-		if (adapter->phy_write
-		    && adapter->phy_write(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					  *((int *)&status)) != 0)
+		if (adapter->phy_write &&
+		    adapter->phy_write(adapter,
+				       NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+				       *((int *)&status)) != 0)
 			return -EIO;
 		else {
 			adapter->link_speed = ecmd->speed;
@@ -442,10 +442,10 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 
 	/* read which mode */
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		if (adapter->phy_read
-		    && adapter->phy_read(adapter,
-					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					 &status) != 0)
+		if (adapter->phy_read &&
+		    adapter->phy_read(adapter,
+				      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+				      &status) != 0)
 			return -EIO;
 		else {
 			val = netxen_get_phy_link(status);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 89bd519..2e364fe 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1936,10 +1936,10 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 			return;
 		}
 
-		if (adapter->phy_read
-		    && adapter->phy_read(adapter,
-			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-			     &status) == 0) {
+		if (adapter->phy_read &&
+		    adapter->phy_read(adapter,
+				      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+				      &status) == 0) {
 			if (netxen_get_phy_link(status)) {
 				switch (netxen_get_phy_speed(status)) {
 				case 0:
@@ -1966,10 +1966,10 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 					adapter->link_duplex = -1;
 					break;
 				}
-				if (adapter->phy_read
-				    && adapter->phy_read(adapter,
-					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					     &autoneg) != 0)
+				if (adapter->phy_read &&
+				    adapter->phy_read(adapter,
+						      NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
+						      &autoneg) != 0)
 					adapter->link_autoneg = autoneg;
 			} else
 				goto link_down;
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 305f4ba..b42f5e5 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -477,8 +477,8 @@ static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = inb(dev->base_addr+i);
 
-	if (dev->dev_addr[0] != NI52_ADDR0 || dev->dev_addr[1] != NI52_ADDR1
-		 || dev->dev_addr[2] != NI52_ADDR2) {
+	if (dev->dev_addr[0] != NI52_ADDR0 || dev->dev_addr[1] != NI52_ADDR1 ||
+	    dev->dev_addr[2] != NI52_ADDR2) {
 		retval = -ENODEV;
 		goto out;
 	}
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 57fd483..1f6327d 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -648,8 +648,8 @@ static void phy_intr(struct net_device *ndev)
 		dprintk("phy_intr: tbisr=%08x, tanar=%08x, tanlpar=%08x\n",
 			tbisr, tanar, tanlpar);
 
-		if ( (fullduplex = (tanlpar & TANAR_FULL_DUP)
-		      && (tanar & TANAR_FULL_DUP)) ) {
+		if ( (fullduplex = (tanlpar & TANAR_FULL_DUP) &&
+		      (tanar & TANAR_FULL_DUP)) ) {
 
 			/* both of us are full duplex */
 			writel(readl(dev->base + TXCFG)
@@ -661,12 +661,12 @@ static void phy_intr(struct net_device *ndev)
 			writel(readl(dev->base + GPIOR) | GPIOR_GP1_OUT,
 			       dev->base + GPIOR);
 
-		} else if(((tanlpar & TANAR_HALF_DUP)
-			   && (tanar & TANAR_HALF_DUP))
-			|| ((tanlpar & TANAR_FULL_DUP)
-			    && (tanar & TANAR_HALF_DUP))
-			|| ((tanlpar & TANAR_HALF_DUP)
-			    && (tanar & TANAR_FULL_DUP))) {
+		} else if (((tanlpar & TANAR_HALF_DUP) &&
+			    (tanar & TANAR_HALF_DUP)) ||
+			   ((tanlpar & TANAR_FULL_DUP) &&
+			    (tanar & TANAR_HALF_DUP)) ||
+			   ((tanlpar & TANAR_HALF_DUP) &&
+			    (tanar & TANAR_FULL_DUP))) {
 
 			/* one or both of us are half duplex */
 			writel((readl(dev->base + TXCFG)
@@ -720,16 +720,16 @@ static void phy_intr(struct net_device *ndev)
 
 	newlinkstate = (cfg & CFG_LNKSTS) ? LINK_UP : LINK_DOWN;
 
-	if (newlinkstate & LINK_UP
-	    && dev->linkstate != newlinkstate) {
+	if (newlinkstate & LINK_UP &&
+	    dev->linkstate != newlinkstate) {
 		netif_start_queue(ndev);
 		netif_wake_queue(ndev);
 		printk(KERN_INFO "%s: link now %s mbps, %s duplex and up.\n",
 			ndev->name,
 			speeds[speed],
 			fullduplex ? "full" : "half");
-	} else if (newlinkstate & LINK_DOWN
-		   && dev->linkstate != newlinkstate) {
+	} else if (newlinkstate & LINK_DOWN &&
+		   dev->linkstate != newlinkstate) {
 		netif_stop_queue(ndev);
 		printk(KERN_INFO "%s: link now down.\n", ndev->name);
 	}
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 0c44b48..480af40 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1225,8 +1225,8 @@ static void netdrv_timer (unsigned long data)
 	mii_lpa = mdio_read (dev, tp->phys[0], MII_LPA);
 
 	if (!tp->duplex_lock && mii_lpa != 0xffff) {
-		int duplex = (mii_lpa & LPA_100FULL)
-		    || (mii_lpa & 0x01C0) == 0x0040;
+		int duplex = ((mii_lpa & LPA_100FULL) ||
+			      (mii_lpa & 0x01C0) == 0x0040);
 		if (tp->full_duplex != duplex) {
 			tp->full_duplex = duplex;
 			printk (KERN_INFO
@@ -1612,8 +1612,8 @@ static void netdrv_weird_interrupt (struct net_device *dev,
 	    (tp->drv_flags & HAS_LNK_CHNG)) {
 		/* Really link-change on new chips. */
 		int lpar = NETDRV_R16 (NWayLPAR);
-		int duplex = (lpar & 0x0100) || (lpar & 0x01C0) == 0x0040
-				|| tp->duplex_lock;
+		int duplex = ((lpar & 0x0100) || (lpar & 0x01C0) == 0x0040 ||
+			      tp->duplex_lock);
 		if (tp->full_duplex != duplex) {
 			tp->full_duplex = duplex;
 			NETDRV_W8 (Cfg9346, Cfg9346_Unlock);
@@ -1820,8 +1820,8 @@ static void netdrv_set_rx_mode (struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 3131a59..ca711f4 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1232,8 +1232,8 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 	ei_local->irqlock = 1;
    
 	/* !!Assumption!! -- we stay in page 0.	 Don't break this. */
-	while ((interrupts = inb_p(e8390_base + EN0_ISR)) != 0
-		   && ++nr_serviced < MAX_SERVICE) 
+	while ((interrupts = inb_p(e8390_base + EN0_ISR)) != 0 &&
+	       ++nr_serviced < MAX_SERVICE)
 	{
 		if (!netif_running(dev) || (interrupts == 0xff)) {
 			if (ei_debug > 1)
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 57e0961..a696121 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -371,9 +371,9 @@ static int fmvj18x_config(struct pcmcia_device *link)
 	switch (link->manf_id) {
 	case MANFID_TDK:
 	    cardtype = TDK;
-	    if (link->card_id == PRODID_TDK_GN3410
-			|| link->card_id == PRODID_TDK_NP9610
-			|| link->card_id == PRODID_TDK_MN3200) {
+	    if (link->card_id == PRODID_TDK_GN3410 ||
+		link->card_id == PRODID_TDK_NP9610 ||
+		link->card_id == PRODID_TDK_MN3200) {
 		/* MultiFunction Card */
 		link->conf.ConfigBase = 0x800;
 		link->conf.ConfigIndex = 0x47;
@@ -590,11 +590,11 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
     */ 
     for (i = 0; i < 0x200; i++) {
 	if (readb(base+i*2) == 0x22) {	
-	    if (readb(base+(i-1)*2) == 0xff
-	     && readb(base+(i+5)*2) == 0x04
-	     && readb(base+(i+6)*2) == 0x06
-	     && readb(base+(i+13)*2) == 0xff) 
-		break;
+		if (readb(base+(i-1)*2) == 0xff &&
+		    readb(base+(i+5)*2) == 0x04 &&
+		    readb(base+(i+6)*2) == 0x06 &&
+		    readb(base+(i+13)*2) == 0xff)
+			break;
 	}
     }
 
@@ -1219,8 +1219,8 @@ static void set_rx_mode(struct net_device *dev)
     if (dev->flags & IFF_PROMISC) {
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
-    } else if (dev->mc_count > MC_FILTERBREAK
-	       ||  (dev->flags & IFF_ALLMULTI)) {
+    } else if (dev->mc_count > MC_FILTERBREAK ||
+	       (dev->flags & IFF_ALLMULTI)) {
 	/* Too many to filter perfectly -- accept all multicasts. */
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 4696844..347eaee 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -601,8 +601,8 @@ static int pcnet_config(struct pcmcia_device *link)
 	dev->if_port = 0;
     }
 
-    if ((link->conf.ConfigBase == 0x03c0)
-	&& (link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
+    if ((link->conf.ConfigBase == 0x03c0) &&
+	(link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
 	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
 	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
 	goto failed;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 7bde2cd..117b083 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -526,10 +526,10 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 	mem.CardOffset = link->conf.ConfigBase;
     i = pcmcia_map_mem_page(link->win, &mem);
 
-    if ((i == 0)
-	&& (smc->manfid == MANFID_MEGAHERTZ)
-	&& (smc->cardid == PRODID_MEGAHERTZ_EM3288))
-	mhz_3288_power(link);
+    if ((i == 0) &&
+	(smc->manfid == MANFID_MEGAHERTZ) &&
+	(smc->cardid == PRODID_MEGAHERTZ_EM3288))
+	    mhz_3288_power(link);
 
 free_cfg_mem:
     kfree(cfg_mem);
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index cf84231..187da21 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -421,9 +421,9 @@ PrintRegisters(struct net_device *dev)
 	    printk("\n");
 	}
 	for (page=0x40 ; page <= 0x5f; page++) {
-	    if (page == 0x43 || (page >= 0x46 && page <= 0x4f)
-		|| (page >= 0x51 && page <=0x5e))
-		continue;
+		if (page == 0x43 || (page >= 0x46 && page <= 0x4f) ||
+		    (page >= 0x51 && page <=0x5e))
+			continue;
 	    printk(KDBG_XIRC "Register page %2x: ", page);
 	    SelectPage(page);
 	    for (i = 8; i < 16; i++)
@@ -834,9 +834,9 @@ xirc2ps_config(struct pcmcia_device * link)
 	/* Once I saw two CISTPL_FUNCE_LAN_NODE_ID entries:
 	 * the first one with a length of zero the second correct -
 	 * so I skip all entries with length 0 */
-	if (parse.funce.type == CISTPL_FUNCE_LAN_NODE_ID
-	    && ((cistpl_lan_node_id_t *)parse.funce.data)->nb)
-	    break;
+	    if (parse.funce.type == CISTPL_FUNCE_LAN_NODE_ID &&
+		((cistpl_lan_node_id_t *)parse.funce.data)->nb)
+		    break;
     }
     if (err) { /* not found: try to get the node-id from tuple 0x89 */
 	tuple.DesiredTuple = 0x89;  /* data layout looks like tuple 0x22 */
@@ -852,8 +852,8 @@ xirc2ps_config(struct pcmcia_device * link)
 	tuple.DesiredTuple = CISTPL_FUNCE;
 	for (err = first_tuple(link, &tuple, &parse); !err;
 				 err = next_tuple(link, &tuple, &parse)) {
-	    if (parse.funce.type == 0x02 && parse.funce.data[0] == 1
-		&& parse.funce.data[1] == 6 && tuple.TupleDataLen == 13) {
+		if (parse.funce.type == 0x02 && parse.funce.data[0] == 1 &&
+		    parse.funce.data[1] == 6 && tuple.TupleDataLen == 13) {
 		buf[1] = 4;
 		memcpy(&parse, buf+1, 8);
 		break;
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 076f23a..dcc67a3 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1515,8 +1515,8 @@ static void __devinit pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
 		if (request_region
 		    (ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_vlbus")) {
 			/* check if there is really a pcnet chip on that ioaddr */
-			if ((inb(ioaddr + 14) == 0x57)
-			    && (inb(ioaddr + 15) == 0x57)) {
+			if ((inb(ioaddr + 14) == 0x57) &&
+			    (inb(ioaddr + 15) == 0x57)) {
 				pcnet32_probe1(ioaddr, 0, NULL);
 			} else {
 				release_region(ioaddr, PCNET32_TOTAL_SIZE);
@@ -1610,8 +1610,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		a = &pcnet32_wio;
 	} else {
 		pcnet32_dwio_reset(ioaddr);
-		if (pcnet32_dwio_read_csr(ioaddr, 0) == 4
-		    && pcnet32_dwio_check(ioaddr)) {
+		if (pcnet32_dwio_read_csr(ioaddr, 0) == 4 &&
+		    pcnet32_dwio_check(ioaddr)) {
 			a = &pcnet32_dwio;
 		} else {
 			if (pcnet32_debug & NETIF_MSG_PROBE)
@@ -1750,8 +1750,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	for (i = 0; i < 6; i++)
 		promaddr[i] = inb(ioaddr + i);
 
-	if (memcmp(promaddr, dev->dev_addr, 6)
-	    || !is_valid_ether_addr(dev->dev_addr)) {
+	if (memcmp(promaddr, dev->dev_addr, 6) ||
+	    !is_valid_ether_addr(dev->dev_addr)) {
 		if (is_valid_ether_addr(promaddr)) {
 			if (pcnet32_debug & NETIF_MSG_PROBE) {
 				printk(" warning: CSR address invalid,\n");
@@ -1840,8 +1840,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	lp->mii = mii;
 	lp->chip_version = chip_version;
 	lp->msg_enable = pcnet32_debug;
-	if ((cards_found >= MAX_UNITS)
-	    || (options[cards_found] >= sizeof(options_mapping)))
+	if ((cards_found >= MAX_UNITS) ||
+	    (options[cards_found] >= sizeof(options_mapping)))
 		lp->options = PCNET32_PORT_ASEL;
 	else
 		lp->options = options_mapping[options[cards_found]];
@@ -1866,8 +1866,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		goto err_free_ring;
 	}
 	/* detect special T1/E1 WAN card by checking for MAC address */
-	if (dev->dev_addr[0] == 0x00 && dev->dev_addr[1] == 0xe0
-	    && dev->dev_addr[2] == 0x75)
+	if (dev->dev_addr[0] == 0x00 && dev->dev_addr[1] == 0xe0 &&
+	    dev->dev_addr[2] == 0x75)
 		lp->options = PCNET32_PORT_FD | PCNET32_PORT_GPSI;
 
 	lp->init_block->mode = cpu_to_le16(0x0003);	/* Disable Rx and Tx. */
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 6b71b00..b0e9f9c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -254,12 +254,12 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_DISABLE
-			&& ((cmd->speed != SPEED_1000
-					&& cmd->speed != SPEED_100
-					&& cmd->speed != SPEED_10)
-				|| (cmd->duplex != DUPLEX_HALF
-					&& cmd->duplex != DUPLEX_FULL)))
+	if (cmd->autoneg == AUTONEG_DISABLE &&
+	    ((cmd->speed != SPEED_1000 &&
+	      cmd->speed != SPEED_100 &&
+	      cmd->speed != SPEED_10) ||
+	     (cmd->duplex != DUPLEX_HALF &&
+	      cmd->duplex != DUPLEX_FULL)))
 		return -EINVAL;
 
 	phydev->autoneg = cmd->autoneg;
@@ -353,9 +353,9 @@ int phy_mii_ioctl(struct phy_device *phydev,
 
 		phy_write(phydev, mii_data->reg_num, val);
 		
-		if (mii_data->reg_num == MII_BMCR 
-				&& val & BMCR_RESET
-				&& phydev->drv->config_init) {
+		if (mii_data->reg_num == MII_BMCR &&
+		    val & BMCR_RESET &&
+		    phydev->drv->config_init) {
 			phy_scan_fixups(phydev);
 			phydev->drv->config_init(phydev);
 		}
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 00487f5..3327e9f 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -372,8 +372,8 @@ plip_bh(struct work_struct *work)
 
 	nl->is_deferred = 0;
 	f = connection_state_table[nl->connection];
-	if ((r = (*f)(nl->dev, nl, snd, rcv)) != OK
-	    && (r = plip_bh_timeout_error(nl->dev, nl, snd, rcv, r)) != OK) {
+	if ((r = (*f)(nl->dev, nl, snd, rcv)) != OK &&
+	    (r = plip_bh_timeout_error(nl->dev, nl, snd, rcv, r)) != OK) {
 		nl->is_deferred = 1;
 		schedule_delayed_work(&nl->deferred, 1);
 	}
@@ -416,9 +416,8 @@ plip_bh_timeout_error(struct net_device *dev, struct net_local *nl,
 
 		if (error != ERROR) { /* Timeout */
 			nl->timeout_count++;
-			if ((error == HS_TIMEOUT
-			     && nl->timeout_count <= 10)
-			    || nl->timeout_count <= 3) {
+			if ((error == HS_TIMEOUT && nl->timeout_count <= 10) ||
+			    nl->timeout_count <= 3) {
 				spin_unlock_irq(&nl->lock);
 				/* Try again later */
 				return TIMEOUT;
@@ -624,8 +623,8 @@ plip_receive_packet(struct net_device *dev, struct net_local *nl,
 		if (plip_receive(nibble_timeout, dev,
 				 &rcv->nibble, &rcv->length.b.msb))
 			return TIMEOUT;
-		if (rcv->length.h > dev->mtu + dev->hard_header_len
-		    || rcv->length.h < 8) {
+		if (rcv->length.h > dev->mtu + dev->hard_header_len ||
+		    rcv->length.h < 8) {
 			printk(KERN_WARNING "%s: bogus packet size %d.\n", dev->name, rcv->length.h);
 			return ERROR;
 		}
diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index c311fa6..6a375ea 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -558,8 +558,8 @@ ppp_async_encode(struct asyncppp *ap)
 		 * Start of a new packet - insert the leading FLAG
 		 * character if necessary.
 		 */
-		if (islcp || flag_time == 0
-		    || time_after_eq(jiffies, ap->last_xmit + flag_time))
+		if (islcp || flag_time == 0 ||
+		    time_after_eq(jiffies, ap->last_xmit + flag_time))
 			*buf++ = PPP_FLAG;
 		ap->last_xmit = jiffies;
 		fcs = PPP_INITFCS;
@@ -696,8 +696,8 @@ ppp_async_push(struct asyncppp *ap)
 		 */
 		clear_bit(XMIT_BUSY, &ap->xmit_flags);
 		/* any more work to do? if not, exit the loop */
-		if (!(test_bit(XMIT_WAKEUP, &ap->xmit_flags)
-		      || (!tty_stuffed && ap->tpkt)))
+		if (!(test_bit(XMIT_WAKEUP, &ap->xmit_flags) ||
+		      (!tty_stuffed && ap->tpkt)))
 			break;
 		/* more work to do, see if we can do it now */
 		if (test_and_set_bit(XMIT_BUSY, &ap->xmit_flags))
@@ -754,8 +754,8 @@ scan_ordinary(struct asyncppp *ap, const unsigned char *buf, int count)
 
 	for (i = 0; i < count; ++i) {
 		c = buf[i];
-		if (c == PPP_ESCAPE || c == PPP_FLAG
-		    || (c < 0x20 && (ap->raccm & (1 << c)) != 0))
+		if (c == PPP_ESCAPE || c == PPP_FLAG ||
+		    (c < 0x20 && (ap->raccm & (1 << c)) != 0))
 			break;
 	}
 	return i;
diff --git a/drivers/net/ppp_deflate.c b/drivers/net/ppp_deflate.c
index 034c1c6..695bc83 100644
--- a/drivers/net/ppp_deflate.c
+++ b/drivers/net/ppp_deflate.c
@@ -111,11 +111,11 @@ static void *z_comp_alloc(unsigned char *options, int opt_len)
 	struct ppp_deflate_state *state;
 	int w_size;
 
-	if (opt_len != CILEN_DEFLATE
-	    || (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT)
-	    || options[1] != CILEN_DEFLATE
-	    || DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL
-	    || options[3] != DEFLATE_CHK_SEQUENCE)
+	if (opt_len != CILEN_DEFLATE ||
+	    (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT) ||
+	    options[1] != CILEN_DEFLATE ||
+	    DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL ||
+	    options[3] != DEFLATE_CHK_SEQUENCE)
 		return NULL;
 	w_size = DEFLATE_SIZE(options[2]);
 	if (w_size < DEFLATE_MIN_SIZE || w_size > DEFLATE_MAX_SIZE)
@@ -163,12 +163,12 @@ static int z_comp_init(void *arg, unsigned char *options, int opt_len,
 {
 	struct ppp_deflate_state *state = (struct ppp_deflate_state *) arg;
 
-	if (opt_len < CILEN_DEFLATE
-	    || (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT)
-	    || options[1] != CILEN_DEFLATE
-	    || DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL
-	    || DEFLATE_SIZE(options[2]) != state->w_size
-	    || options[3] != DEFLATE_CHK_SEQUENCE)
+	if (opt_len < CILEN_DEFLATE ||
+	    (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT) ||
+	    options[1] != CILEN_DEFLATE ||
+	    DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL ||
+	    DEFLATE_SIZE(options[2]) != state->w_size ||
+	    options[3] != DEFLATE_CHK_SEQUENCE)
 		return 0;
 
 	state->seqno = 0;
@@ -330,11 +330,11 @@ static void *z_decomp_alloc(unsigned char *options, int opt_len)
 	struct ppp_deflate_state *state;
 	int w_size;
 
-	if (opt_len != CILEN_DEFLATE
-	    || (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT)
-	    || options[1] != CILEN_DEFLATE
-	    || DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL
-	    || options[3] != DEFLATE_CHK_SEQUENCE)
+	if (opt_len != CILEN_DEFLATE ||
+	    (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT) ||
+	    options[1] != CILEN_DEFLATE ||
+	    DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL ||
+	    options[3] != DEFLATE_CHK_SEQUENCE)
 		return NULL;
 	w_size = DEFLATE_SIZE(options[2]);
 	if (w_size < DEFLATE_MIN_SIZE || w_size > DEFLATE_MAX_SIZE)
@@ -381,12 +381,12 @@ static int z_decomp_init(void *arg, unsigned char *options, int opt_len,
 {
 	struct ppp_deflate_state *state = (struct ppp_deflate_state *) arg;
 
-	if (opt_len < CILEN_DEFLATE
-	    || (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT)
-	    || options[1] != CILEN_DEFLATE
-	    || DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL
-	    || DEFLATE_SIZE(options[2]) != state->w_size
-	    || options[3] != DEFLATE_CHK_SEQUENCE)
+	if (opt_len < CILEN_DEFLATE ||
+	    (options[0] != CI_DEFLATE && options[0] != CI_DEFLATE_DRAFT) ||
+	    options[1] != CILEN_DEFLATE ||
+	    DEFLATE_METHOD(options[2]) != DEFLATE_METHOD_VAL ||
+	    DEFLATE_SIZE(options[2]) != state->w_size ||
+	    options[3] != DEFLATE_CHK_SEQUENCE)
 		return 0;
 
 	state->seqno = 0;
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index f671bb8..2282e72 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -425,8 +425,8 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
 			 * network traffic (demand mode).
 			 */
 			struct ppp *ppp = PF_TO_PPP(pf);
-			if (ppp->n_channels == 0
-			    && (ppp->flags & SC_LOOP_TRAFFIC) == 0)
+			if (ppp->n_channels == 0 &&
+			    (ppp->flags & SC_LOOP_TRAFFIC) == 0)
 				break;
 		}
 		ret = -EAGAIN;
@@ -511,8 +511,8 @@ static unsigned int ppp_poll(struct file *file, poll_table *wait)
 	else if (pf->kind == INTERFACE) {
 		/* see comment in ppp_read */
 		struct ppp *ppp = PF_TO_PPP(pf);
-		if (ppp->n_channels == 0
-		    && (ppp->flags & SC_LOOP_TRAFFIC) == 0)
+		if (ppp->n_channels == 0 &&
+		    (ppp->flags & SC_LOOP_TRAFFIC) == 0)
 			mask |= POLLIN | POLLRDNORM;
 	}
 
@@ -1057,8 +1057,8 @@ ppp_xmit_process(struct ppp *ppp)
 	ppp_xmit_lock(ppp);
 	if (!ppp->closing) {
 		ppp_push(ppp);
-		while (!ppp->xmit_pending
-		       && (skb = skb_dequeue(&ppp->file.xq)))
+		while (!ppp->xmit_pending &&
+		       (skb = skb_dequeue(&ppp->file.xq)))
 			ppp_send_frame(ppp, skb);
 		/* If there's no work left to do, tell the core net
 		   code that we can accept some more. */
@@ -1137,18 +1137,18 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		/* the filter instructions are constructed assuming
 		   a four-byte PPP header on each packet */
 		*skb_push(skb, 2) = 1;
-		if (ppp->pass_filter
-		    && sk_run_filter(skb, ppp->pass_filter,
-				     ppp->pass_len) == 0) {
+		if (ppp->pass_filter &&
+		    sk_run_filter(skb, ppp->pass_filter,
+				  ppp->pass_len) == 0) {
 			if (ppp->debug & 1)
 				printk(KERN_DEBUG "PPP: outbound frame not passed\n");
 			kfree_skb(skb);
 			return;
 		}
 		/* if this packet passes the active filter, record the time */
-		if (!(ppp->active_filter
-		      && sk_run_filter(skb, ppp->active_filter,
-				       ppp->active_len) == 0))
+		if (!(ppp->active_filter &&
+		      sk_run_filter(skb, ppp->active_filter,
+				    ppp->active_len) == 0))
 			ppp->last_xmit = jiffies;
 		skb_pull(skb, 2);
 #else
@@ -1202,8 +1202,8 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	}
 
 	/* try to do packet compression */
-	if ((ppp->xstate & SC_COMP_RUN) && ppp->xc_state
-	    && proto != PPP_LCP && proto != PPP_CCP) {
+	if ((ppp->xstate & SC_COMP_RUN) && ppp->xc_state &&
+	    proto != PPP_LCP && proto != PPP_CCP) {
 		if (!(ppp->flags & SC_CCP_UP) && (ppp->flags & SC_MUST_COMP)) {
 			if (net_ratelimit())
 				printk(KERN_ERR "ppp: compression required but down - pkt dropped.\n");
@@ -1577,8 +1577,8 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 		/* put it on the channel queue */
 		skb_queue_tail(&pch->file.rq, skb);
 		/* drop old frames if queue too long */
-		while (pch->file.rq.qlen > PPP_MAX_RQLEN
-		       && (skb = skb_dequeue(&pch->file.rq)))
+		while (pch->file.rq.qlen > PPP_MAX_RQLEN &&
+		       (skb = skb_dequeue(&pch->file.rq)))
 			kfree_skb(skb);
 		wake_up_interruptible(&pch->file.rwait);
 	} else {
@@ -1654,8 +1654,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 	 * Note that some decompressors need to see uncompressed frames
 	 * that come in as well as compressed frames.
 	 */
-	if (ppp->rc_state && (ppp->rstate & SC_DECOMP_RUN)
-	    && (ppp->rstate & (SC_DC_FERROR | SC_DC_ERROR)) == 0)
+	if (ppp->rc_state && (ppp->rstate & SC_DECOMP_RUN) &&
+	    (ppp->rstate & (SC_DC_FERROR | SC_DC_ERROR)) == 0)
 		skb = ppp_decompress_frame(ppp, skb);
 
 	if (ppp->flags & SC_MUST_COMP && ppp->rstate & SC_DC_FERROR)
@@ -1726,8 +1726,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 		/* control or unknown frame - pass it to pppd */
 		skb_queue_tail(&ppp->file.rq, skb);
 		/* limit queue length by dropping old frames */
-		while (ppp->file.rq.qlen > PPP_MAX_RQLEN
-		       && (skb = skb_dequeue(&ppp->file.rq)))
+		while (ppp->file.rq.qlen > PPP_MAX_RQLEN &&
+		       (skb = skb_dequeue(&ppp->file.rq)))
 			kfree_skb(skb);
 		/* wake up any process polling or blocking on read */
 		wake_up_interruptible(&ppp->file.rwait);
@@ -1745,26 +1745,26 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 				goto err;
 
 			*skb_push(skb, 2) = 0;
-			if (ppp->pass_filter
-			    && sk_run_filter(skb, ppp->pass_filter,
-					     ppp->pass_len) == 0) {
+			if (ppp->pass_filter &&
+			    sk_run_filter(skb, ppp->pass_filter,
+					  ppp->pass_len) == 0) {
 				if (ppp->debug & 1)
 					printk(KERN_DEBUG "PPP: inbound frame "
 					       "not passed\n");
 				kfree_skb(skb);
 				return;
 			}
-			if (!(ppp->active_filter
-			      && sk_run_filter(skb, ppp->active_filter,
-					       ppp->active_len) == 0))
+			if (!(ppp->active_filter &&
+			      sk_run_filter(skb, ppp->active_filter,
+					    ppp->active_len) == 0))
 				ppp->last_recv = jiffies;
 			__skb_pull(skb, 2);
 		} else
 #endif /* CONFIG_PPP_FILTER */
 			ppp->last_recv = jiffies;
 
-		if ((ppp->dev->flags & IFF_UP) == 0
-		    || ppp->npmode[npi] != NPMODE_PASS) {
+		if ((ppp->dev->flags & IFF_UP) == 0 ||
+		    ppp->npmode[npi] != NPMODE_PASS) {
 			kfree_skb(skb);
 		} else {
 			/* chop off protocol */
@@ -2228,13 +2228,13 @@ ppp_set_compress(struct ppp *ppp, unsigned long arg)
 	unsigned char ccp_option[CCP_MAX_OPTION_LENGTH];
 
 	err = -EFAULT;
-	if (copy_from_user(&data, (void __user *) arg, sizeof(data))
-	    || (data.length <= CCP_MAX_OPTION_LENGTH
-		&& copy_from_user(ccp_option, (void __user *) data.ptr, data.length)))
+	if (copy_from_user(&data, (void __user *) arg, sizeof(data)) ||
+	    (data.length <= CCP_MAX_OPTION_LENGTH &&
+	     copy_from_user(ccp_option, (void __user *) data.ptr, data.length)))
 		goto out;
 	err = -EINVAL;
-	if (data.length > CCP_MAX_OPTION_LENGTH
-	    || ccp_option[1] < 2 || ccp_option[1] > data.length)
+	if (data.length > CCP_MAX_OPTION_LENGTH ||
+	    ccp_option[1] < 2 || ccp_option[1] > data.length)
 		goto out;
 
 	cp = try_then_request_module(
diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp_mppe.c
index 88f03c9..6d1a1b8 100644
--- a/drivers/net/ppp_mppe.c
+++ b/drivers/net/ppp_mppe.c
@@ -195,8 +195,8 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 	struct ppp_mppe_state *state;
 	unsigned int digestsize;
 
-	if (optlen != CILEN_MPPE + sizeof(state->master_key)
-	    || options[0] != CI_MPPE || options[1] != CILEN_MPPE)
+	if (optlen != CILEN_MPPE + sizeof(state->master_key) ||
+	    options[0] != CI_MPPE || options[1] != CILEN_MPPE)
 		goto out;
 
 	state = kzalloc(sizeof(*state), GFP_KERNEL);
@@ -276,8 +276,8 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
 	unsigned char mppe_opts;
 
-	if (optlen != CILEN_MPPE
-	    || options[0] != CI_MPPE || options[1] != CILEN_MPPE)
+	if (optlen != CILEN_MPPE ||
+	    options[0] != CI_MPPE || options[1] != CILEN_MPPE)
 		return 0;
 
 	MPPE_CI_TO_OPTS(&options[2], mppe_opts);
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
index c908b08..3a13cec 100644
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -662,8 +662,8 @@ ppp_sync_push(struct syncppp *ap)
 		}
 		/* haven't made any progress */
 		spin_unlock_bh(&ap->xmit_lock);
-		if (!(test_bit(XMIT_WAKEUP, &ap->xmit_flags)
-		      || (!tty_stuffed && ap->tpkt)))
+		if (!(test_bit(XMIT_WAKEUP, &ap->xmit_flags) ||
+		      (!tty_stuffed && ap->tpkt)))
 			break;
 		if (!spin_trylock_bh(&ap->xmit_lock))
 			break;
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index a4ed776..cdd11ba 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -323,8 +323,8 @@ static void pppoe_flush_dev(struct net_device *dev)
 			write_unlock_bh(&pn->hash_lock);
 			lock_sock(sk);
 
-			if (po->pppoe_dev == dev
-			    && sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
+			if (po->pppoe_dev == dev &&
+			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
 				pppox_unbind_sock(sk);
 				sk->sk_state = PPPOX_ZOMBIE;
 				sk->sk_state_change(sk);
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 4c61051..e3e6bc9 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1969,8 +1969,8 @@ static void ql_update_lrg_bufq_prod_index(struct ql3_adapter *qdev)
 	struct ql_rcv_buf_cb *lrg_buf_cb;
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
 
-	if ((qdev->lrg_buf_free_count >= 8)
-	    && (qdev->lrg_buf_release_cnt >= 16)) {
+	if ((qdev->lrg_buf_free_count >= 8) &&
+	    (qdev->lrg_buf_release_cnt >= 16)) {
 
 		if (qdev->lrg_buf_skb_check)
 			if (!ql_populate_free_queue(qdev))
@@ -1978,8 +1978,8 @@ static void ql_update_lrg_bufq_prod_index(struct ql3_adapter *qdev)
 
 		lrg_buf_q_ele = qdev->lrg_buf_next_free;
 
-		while ((qdev->lrg_buf_release_cnt >= 16)
-		       && (qdev->lrg_buf_free_count >= 8)) {
+		while ((qdev->lrg_buf_release_cnt >= 16) &&
+		       (qdev->lrg_buf_free_count >= 8)) {
 
 			for (i = 0; i < 8; i++) {
 				lrg_buf_cb =
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 7692299..707b391 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2347,8 +2347,8 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 	    pci_alloc_consistent(qdev->pdev, tx_ring->wq_size,
 				 &tx_ring->wq_base_dma);
 
-	if ((tx_ring->wq_base == NULL)
-		|| tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
+	if ((tx_ring->wq_base == NULL) ||
+	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
 		QPRINTK(qdev, IFUP, ERR, "tx_ring alloc failed.\n");
 		return -ENOMEM;
 	}
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 0f30ea4..f03e2e4 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -958,8 +958,7 @@ static void r6040_multicast_list(struct net_device *dev)
 	}
 	/* Too many multicast addresses
 	 * accept all traffic */
-	else if ((dev->mc_count > MCAST_MAX)
-		|| (dev->flags & IFF_ALLMULTI))
+	else if ((dev->mc_count > MCAST_MAX) || (dev->flags & IFF_ALLMULTI))
 		reg |= 0x0020;
 
 	iowrite16(reg, ioaddr);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f6899c3..acfc5a3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4763,8 +4763,8 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
diff --git a/drivers/net/s6gmac.c b/drivers/net/s6gmac.c
index d81706e..45f2634 100644
--- a/drivers/net/s6gmac.c
+++ b/drivers/net/s6gmac.c
@@ -373,9 +373,9 @@ struct s6gmac {
 static void s6gmac_rx_fillfifo(struct s6gmac *pd)
 {
 	struct sk_buff *skb;
-	while ((((u8)(pd->rx_skb_i - pd->rx_skb_o)) < S6_NUM_RX_SKB)
-			&& (!s6dmac_fifo_full(pd->rx_dma, pd->rx_chan))
-			&& (skb = dev_alloc_skb(S6_MAX_FRLEN + 2))) {
+	while ((((u8)(pd->rx_skb_i - pd->rx_skb_o)) < S6_NUM_RX_SKB) &&
+	       (!s6dmac_fifo_full(pd->rx_dma, pd->rx_chan)) &&
+	       (skb = dev_alloc_skb(S6_MAX_FRLEN + 2))) {
 		pd->rx_skb[(pd->rx_skb_i++) % S6_NUM_RX_SKB] = skb;
 		s6dmac_put_fifo_cache(pd->rx_dma, pd->rx_chan,
 			pd->io, (u32)skb->data, S6_MAX_FRLEN);
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index b7e0eb4..e350503 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -428,9 +428,9 @@ static void _sc92031_set_mar(struct net_device *dev)
 	void __iomem *port_base = priv->port_base;
 	u32 mar0 = 0, mar1 = 0;
 
-	if ((dev->flags & IFF_PROMISC)
-			|| dev->mc_count > multicast_filter_limit
-			|| (dev->flags & IFF_ALLMULTI))
+	if ((dev->flags & IFF_PROMISC) ||
+	    dev->mc_count > multicast_filter_limit ||
+	    (dev->flags & IFF_ALLMULTI))
 		mar0 = mar1 = 0xffffffff;
 	else if (dev->flags & IFF_MULTICAST) {
 		struct dev_mc_list *mc_list;
@@ -777,10 +777,10 @@ static void _sc92031_rx_tasklet(struct net_device *dev)
 
 		rx_ring_offset = (rx_ring_offset + 4) % RX_BUF_LEN;
 
-		if (unlikely(rx_status == 0
-				|| rx_size > (MAX_ETH_FRAME_SIZE + 4)
-				|| rx_size < 16
-				|| !(rx_status & RxStatesOK))) {
+		if (unlikely(rx_status == 0 ||
+			     rx_size > (MAX_ETH_FRAME_SIZE + 4) ||
+			     rx_size < 16 ||
+			     !(rx_status & RxStatesOK))) {
 			_sc92031_rx_tasklet_error(dev, rx_status, rx_size);
 			break;
 		}
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 34b4e7d..379a3dc 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -238,8 +238,8 @@ static int skge_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 
-	if ((wol->wolopts & ~wol_supported(hw))
-	    || !device_can_wakeup(&hw->pdev->dev))
+	if ((wol->wolopts & ~wol_supported(hw)) ||
+	    !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	skge->wol = wol->wolopts;
@@ -576,9 +576,10 @@ static void skge_get_pauseparam(struct net_device *dev,
 {
 	struct skge_port *skge = netdev_priv(dev);
 
-	ecmd->rx_pause = (skge->flow_control == FLOW_MODE_SYMMETRIC)
-		|| (skge->flow_control == FLOW_MODE_SYM_OR_REM);
-	ecmd->tx_pause = ecmd->rx_pause || (skge->flow_control == FLOW_MODE_LOC_SEND);
+	ecmd->rx_pause = ((skge->flow_control == FLOW_MODE_SYMMETRIC) ||
+			  (skge->flow_control == FLOW_MODE_SYM_OR_REM));
+	ecmd->tx_pause = (ecmd->rx_pause ||
+			  (skge->flow_control == FLOW_MODE_LOC_SEND));
 
 	ecmd->autoneg = ecmd->rx_pause || ecmd->tx_pause;
 }
@@ -2779,8 +2780,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 		/* This seems backwards, but it is what the sk98lin
 		 * does.  Looks like hardware is wrong?
 		 */
-		if (ipip_hdr(skb)->protocol == IPPROTO_UDP
-	            && hw->chip_rev == 0 && hw->chip_id == CHIP_ID_YUKON)
+		if (ipip_hdr(skb)->protocol == IPPROTO_UDP &&
+	            hw->chip_rev == 0 && hw->chip_id == CHIP_ID_YUKON)
 			control = BMU_TCP_CHECK;
 		else
 			control = BMU_UDP_CHECK;
@@ -2948,8 +2949,8 @@ static void genesis_set_multicast(struct net_device *dev)
 	else {
 		memset(filter, 0, sizeof(filter));
 
-		if (skge->flow_status == FLOW_STAT_REM_SEND
-		    || skge->flow_status == FLOW_STAT_SYMMETRIC)
+		if (skge->flow_status == FLOW_STAT_REM_SEND ||
+		    skge->flow_status == FLOW_STAT_SYMMETRIC)
 			genesis_add_filter(filter, pause_mc_addr);
 
 		for (i = 0; list && i < count; i++, list = list->next)
@@ -2972,8 +2973,8 @@ static void yukon_set_multicast(struct net_device *dev)
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 	struct dev_mc_list *list = dev->mc_list;
-	int rx_pause = (skge->flow_status == FLOW_STAT_REM_SEND
-			|| skge->flow_status == FLOW_STAT_SYMMETRIC);
+	int rx_pause = (skge->flow_status == FLOW_STAT_REM_SEND ||
+			skge->flow_status == FLOW_STAT_SYMMETRIC);
 	u16 reg;
 	u8 filter[8];
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a3d9991..3943d89 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -374,8 +374,8 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
 
 			/* downshift on PHY 88E1112 and 88E1149 is changed */
-			if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED)
-			    && (hw->flags & SKY2_HW_NEWER_PHY)) {
+			if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
+			     (hw->flags & SKY2_HW_NEWER_PHY)) {
 				/* set downshift counter to 3x and enable downshift */
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
@@ -619,8 +619,8 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		/* no effect on Yukon-XL */
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
-		if ( !(sky2->flags & SKY2_FLAG_AUTO_SPEED)
-		     || sky2->speed == SPEED_100) {
+		if (!(sky2->flags & SKY2_FLAG_AUTO_SPEED) ||
+		    sky2->speed == SPEED_100) {
 			/* turn on 100 Mbps LED (LED_LINK100) */
 			ledover |= PHY_M_LED_MO_100(MO_LED_ON);
 		}
@@ -937,8 +937,8 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	/* On chips without ram buffer, pause is controled by MAC level */
 	if (!(hw->flags & SKY2_HW_RAM_BUFFER)) {
 		/* Pause threshold is scaled by 8 in bytes */
-		if (hw->chip_id == CHIP_ID_YUKON_FE_P
-			&& hw->chip_rev == CHIP_REV_YU_FE2_A0)
+		if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+		    hw->chip_rev == CHIP_REV_YU_FE2_A0)
 			reg = 1568 / 8;
 		else
 			reg = 1024 / 8;
@@ -1353,8 +1353,8 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	/* These chips have no ram buffer?
 	 * MAC Rx RAM Read is controlled by hardware */
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
-	    (hw->chip_rev == CHIP_REV_YU_EC_U_A1
-	     || hw->chip_rev == CHIP_REV_YU_EC_U_B0))
+	    (hw->chip_rev == CHIP_REV_YU_EC_U_A1 ||
+	     hw->chip_rev == CHIP_REV_YU_EC_U_B0))
 		sky2_write32(hw, Q_ADDR(rxq, Q_TEST), F_M_RX_RAM_DIS);
 
 	sky2_prefetch_init(hw, rxq, sky2->rx_le_map, RX_LE_SIZE - 1);
@@ -1560,8 +1560,8 @@ static int sky2_up(struct net_device *dev)
 		sky2_write32(hw, Q_ADDR(txqaddr[port], Q_TEST), F_TX_CHK_AUTO_OFF);
 
 	/* Set almost empty threshold */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U
-	    && hw->chip_rev == CHIP_REV_YU_EC_U_A0)
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
+	    hw->chip_rev == CHIP_REV_YU_EC_U_A0)
 		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), ECU_TXFF_LEV);
 
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
@@ -1907,8 +1907,8 @@ static int sky2_down(struct net_device *dev)
 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
 
 	/* Workaround shared GMAC reset */
-	if (!(hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev == 0
-	      && port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
+	if (!(hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev == 0 &&
+	      port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_SET);
 
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
@@ -2085,8 +2085,8 @@ static int sky2_autoneg_done(struct sky2_port *sky2, u16 aux)
 			sky2->flow_status = FC_TX;
 	}
 
-	if (sky2->duplex == DUPLEX_HALF && sky2->speed < SPEED_1000
-	    && !(hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX))
+	if (sky2->duplex == DUPLEX_HALF && sky2->speed < SPEED_1000 &&
+	    !(hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX))
 		sky2->flow_status = FC_NONE;
 
 	if (sky2->flow_status & FC_TX)
@@ -3244,8 +3244,8 @@ static int sky2_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 
-	if ((wol->wolopts & ~sky2_wol_supported(sky2->hw))
-	    || !device_can_wakeup(&hw->pdev->dev))
+	if ((wol->wolopts & ~sky2_wol_supported(sky2->hw)) ||
+	    !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	sky2->wol = wol->wolopts;
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 6640469..ba5bbc5 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -956,8 +956,8 @@ static void slip_unesc(struct slip *sl, unsigned char s)
 			clear_bit(SLF_KEEPTEST, &sl->flags);
 #endif
 
-		if (!test_and_clear_bit(SLF_ERROR, &sl->flags)
-							&& (sl->rcount > 2))
+		if (!test_and_clear_bit(SLF_ERROR, &sl->flags) &&
+		    (sl->rcount > 2))
 			sl_bump(sl);
 		clear_bit(SLF_ESCAPE, &sl->flags);
 		sl->rcount = 0;
@@ -1039,8 +1039,8 @@ static void slip_unesc6(struct slip *sl, unsigned char s)
 			clear_bit(SLF_KEEPTEST, &sl->flags);
 #endif
 
-		if (!test_and_clear_bit(SLF_ERROR, &sl->flags)
-							&& (sl->rcount > 2))
+		if (!test_and_clear_bit(SLF_ERROR, &sl->flags) &&
+		    (sl->rcount > 2))
 			sl_bump(sl);
 		sl->rcount = 0;
 		sl->xbits = 0;
diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index c791ef7..a93f122 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -268,9 +268,9 @@ static int __init ultramca_probe(struct device *gen_dev)
 		}
 	}
 
-	if(!tirq || !tbase
-	   || (irq && irq != tirq)
-	   || (base_addr && tbase != base_addr))
+	if(!tirq || !tbase ||
+	   (irq && irq != tirq) ||
+	   (base_addr && tbase != base_addr))
 		/* FIXME: we're trying to force the ordering of the
 		 * devices here, there should be a way of getting this
 		 * to happen */
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 3911be7..7815bfc 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -158,8 +158,8 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_outsb(a, r, p, l)	writesb((a) + (r), p, (l))
 #define SMC_IRQ_FLAGS		(-1)	/* from resource */
 
-#elif	defined(CONFIG_MACH_LOGICPD_PXA270) \
-	|| defined(CONFIG_MACH_NOMADIK_8815NHK)
+#elif	defined(CONFIG_MACH_LOGICPD_PXA270) ||	\
+	defined(CONFIG_MACH_NOMADIK_8815NHK)
 
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
@@ -258,9 +258,9 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define RPC_LSA_DEFAULT		RPC_LED_TX_RX
 #define RPC_LSB_DEFAULT		RPC_LED_100_10
 
-#elif   defined(CONFIG_MACH_LPD79520) \
-     || defined(CONFIG_MACH_LPD7A400) \
-     || defined(CONFIG_MACH_LPD7A404)
+#elif   defined(CONFIG_MACH_LPD79520) ||	\
+	defined(CONFIG_MACH_LPD7A400) ||	\
+	defined(CONFIG_MACH_LPD7A404)
 
 /* The LPD7X_IOBARRIER is necessary to overcome a mismatch between the
  * way that the CPU handles chip selects and the way that the SMC chip
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 7f01e60..4d0d5c5 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -748,8 +748,8 @@ static void smsc911x_phy_adjust_link(struct net_device *dev)
 			 * usage is 10/100 indicator */
 			pdata->gpio_setting = smsc911x_reg_read(pdata,
 				GPIO_CFG);
-			if ((pdata->gpio_setting & GPIO_CFG_LED1_EN_)
-			    && (!pdata->using_extphy)) {
+			if ((pdata->gpio_setting & GPIO_CFG_LED1_EN_) &&
+			    (!pdata->using_extphy)) {
 				/* Force 10/100 LED off, after saving
 				 * orginal GPIO configuration */
 				pdata->gpio_orig_setting = pdata->gpio_setting;
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index aa10158..95db60a 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1482,8 +1482,8 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 			printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d, quota %d.\n", pkt_len, *quota);
 		/* Check if the packet is long enough to accept without copying
 		   to a minimally-sized skbuff. */
-		if (pkt_len < rx_copybreak
-		    && (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+		if (pkt_len < rx_copybreak &&
+		    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 			skb_reserve(skb, 2);	/* 16 byte align the IP header */
 			pci_dma_sync_single_for_cpu(np->pci_dev,
 						    np->rx_info[entry].mapping,
@@ -1793,8 +1793,8 @@ static void set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		rx_mode |= AcceptAll;
-	} else if ((dev->mc_count > multicast_filter_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		rx_mode |= AcceptBroadcast|AcceptAllMulticast|PerfectFilter;
 	} else if (dev->mc_count <= 14) {
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 40813f0..508fba8 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -922,8 +922,7 @@ static void stmmac_dma_interrupt(struct net_device *dev)
 		DBG(intr, INFO, "CSR5[15] DMA ABNORMAL IRQ: ");
 		if (unlikely(intr_status & DMA_STATUS_UNF)) {
 			DBG(intr, INFO, "transmit underflow\n");
-			if (unlikely(tc != SF_DMA_MODE)
-			    && (tc <= 256)) {
+			if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
 				/* Try to bump up the threshold */
 				tc += 64;
 				priv->mac_type->ops->dma_mode(ioaddr, tc,
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 5c396c2..d58e189 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -603,8 +603,8 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 			    strcmp (media[card_idx], "4") == 0) {
 				np->speed = 100;
 				np->mii_if.full_duplex = 1;
-			} else if (strcmp (media[card_idx], "100mbps_hd") == 0
-				   || strcmp (media[card_idx], "3") == 0) {
+			} else if (strcmp (media[card_idx], "100mbps_hd") == 0 ||
+				   strcmp (media[card_idx], "3") == 0) {
 				np->speed = 100;
 				np->mii_if.full_duplex = 0;
 			} else if (strcmp (media[card_idx], "10mbps_fd") == 0 ||
@@ -1079,8 +1079,8 @@ start_tx (struct sk_buff *skb, struct net_device *dev)
 	tasklet_schedule(&np->tx_tasklet);
 
 	/* On some architectures: explicitly flush cache lines here. */
-	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1
-			&& !netif_queue_stopped(dev)) {
+	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1 &&
+	    !netif_queue_stopped(dev)) {
 		/* do nothing */
 	} else {
 		netif_stop_queue (dev);
@@ -1336,8 +1336,8 @@ static void rx_poll(unsigned long data)
 #endif
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak
-				&& (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,
 							    le32_to_cpu(desc->frag[0].addr),
@@ -1517,8 +1517,8 @@ static void set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAll | AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit)
-			   ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index f7a0291..1990546 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -1031,8 +1031,8 @@ struct gem {
 #endif
 };
 
-#define found_mii_phy(gp) ((gp->phy_type == phy_mii_mdio0 || gp->phy_type == phy_mii_mdio1) \
-				&& gp->phy_mii.def && gp->phy_mii.def->ops)
+#define found_mii_phy(gp) ((gp->phy_type == phy_mii_mdio0 || gp->phy_type == phy_mii_mdio1) && \
+			   gp->phy_mii.def && gp->phy_mii.def->ops)
 
 #define ALIGNED_RX_SKB_ADDR(addr) \
         ((((unsigned long)(addr) + (64UL - 1UL)) & ~(64UL - 1UL)) - (unsigned long)(addr))
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 0970e17..6762f1c 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -3056,9 +3056,9 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 		int len;
 
 		if (qfe_slot != -1 &&
-		    (addr = of_get_property(dp,
-					    "local-mac-address", &len)) != NULL
-		    && len == 6) {
+		    (addr = of_get_property(dp, "local-mac-address", &len))
+			!= NULL &&
+		    len == 6) {
 			memcpy(dev->dev_addr, addr, 6);
 		} else {
 			memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 2fbac31..80b404f 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1784,9 +1784,9 @@ static void bdx_tx_cleanup(struct bdx_priv *priv)
 	}
 #endif
 
-	if (unlikely(netif_queue_stopped(priv->ndev)
-		     && netif_carrier_ok(priv->ndev)
-		     && (priv->tx_level >= BDX_MIN_TX_LEVEL))) {
+	if (unlikely(netif_queue_stopped(priv->ndev) &&
+		     netif_carrier_ok(priv->ndev) &&
+		     (priv->tx_level >= BDX_MIN_TX_LEVEL))) {
 		DBG("%s: %s: TX Q WAKE level %d\n",
 		    BDX_DRV_NAME, priv->ndev->name, priv->tx_level);
 		netif_wake_queue(priv->ndev);
@@ -2273,8 +2273,8 @@ bdx_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecoal)
 	    (((tx_max_coal * BDX_TXF_DESC_SZ) + PCK_TH_MULT - 1)
 	     / PCK_TH_MULT);
 
-	if ((rx_coal > 0x7FFF) || (tx_coal > 0x7FFF)
-	    || (rx_max_coal > 0xF) || (tx_max_coal > 0xF))
+	if ((rx_coal > 0x7FFF) || (tx_coal > 0x7FFF) ||
+	    (rx_max_coal > 0xF) || (tx_max_coal > 0xF))
 		return -EINVAL;
 
 	rdintcm = INT_REG_VAL(rx_coal, GET_INT_COAL_RC(priv->rdintcm),
@@ -2347,8 +2347,8 @@ bdx_set_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 		tx_size = 3;
 
 	/*Is there anything to do? */
-	if ((rx_size == priv->rxf_size)
-	    && (tx_size == priv->txd_size))
+	if ((rx_size == priv->rxf_size) &&
+	    (tx_size == priv->txd_size))
 		return 0;
 
 	priv->rxf_size = rx_size;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 302ea0b..f845837 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4621,13 +4621,12 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) -
 		      ETH_FCS_LEN;
 
-		if (len > RX_COPY_THRESHOLD
-			&& tp->rx_offset == NET_IP_ALIGN
-			/* rx_offset will likely not equal NET_IP_ALIGN
-			 * if this is a 5701 card running in PCI-X mode
-			 * [see tg3_get_invariants()]
-			 */
-		) {
+		if (len > RX_COPY_THRESHOLD &&
+		    tp->rx_offset == NET_IP_ALIGN) {
+		    /* rx_offset will likely not equal NET_IP_ALIGN
+		     * if this is a 5701 card running in PCI-X mode
+		     * [see tg3_get_invariants()]
+		     */
 			int skb_size;
 
 			skb_size = tg3_alloc_rx_skb(tp, tpr, opaque_key,
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 16f23f8..fabaeff 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1755,8 +1755,8 @@ static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 			     ! ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
                 		tlphy_ctl |= TLAN_TC_SWAPOL;
                 		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
-        		} else if ( ( tlphy_sts & TLAN_TS_POLOK )
-				    && ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
+			} else if ( ( tlphy_sts & TLAN_TS_POLOK ) &&
+				    ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
                 		tlphy_ctl &= ~TLAN_TC_SWAPOL;
                 		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
         		}
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 7b1fe94..d6ccd59 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -712,8 +712,8 @@ static int streamer_open(struct net_device *dev)
 					strcat(open_error, " - ");
 					strcat(open_error, open_min_error[(error_code & 0x0f)]);
 
-					if (!streamer_priv->streamer_ring_speed
-					    && ((error_code & 0x0f) == 0x0d)) 
+					if (!streamer_priv->streamer_ring_speed &&
+					    ((error_code & 0x0f) == 0x0d))
 					{
 						printk(KERN_WARNING "%s: Tried to autosense ring speed with no monitors present\n", dev->name);
 						printk(KERN_WARNING "%s: Please try again with a specified ring speed \n", dev->name);
@@ -1032,8 +1032,8 @@ static irqreturn_t streamer_interrupt(int irq, void *dev_id)
 	sisr = readw(streamer_mmio + SISR);
 
 	while((sisr & (SISR_MI | SISR_SRB_REPLY | SISR_ADAPTER_CHECK | SISR_ASB_FREE | 
-		       SISR_ARB_CMD | SISR_TRB_REPLY | SISR_PAR_ERR | SISR_SERR_ERR))
-               && (max_intr > 0)) {
+		       SISR_ARB_CMD | SISR_TRB_REPLY | SISR_PAR_ERR | SISR_SERR_ERR)) &&
+	      (max_intr > 0)) {
 
 		if(sisr & SISR_PAR_ERR) {
 			writew(~SISR_PAR_ERR, streamer_mmio + SISR_RUM);
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index ebda61b..427a897 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -2309,9 +2309,9 @@ static irqreturn_t smctr_interrupt(int irq, void *dev_id)
                                 else
                                 {
                                         if((tp->acb_head->cmd
-                                                == ACB_CMD_READ_TRC_STATUS)
-                                                && (tp->acb_head->subcmd
-                                                == RW_TRC_STATUS_BLOCK))
+					    == ACB_CMD_READ_TRC_STATUS) &&
+					   (tp->acb_head->subcmd
+					    == RW_TRC_STATUS_BLOCK))
                                         {
                                                 if(tp->ptr_bcn_type)
                                                 {
@@ -2331,8 +2331,8 @@ static irqreturn_t smctr_interrupt(int irq, void *dev_id)
                                                         smctr_disable_16bit(dev);
                                                         err = smctr_ring_status_chg(dev);
                                                         smctr_enable_16bit(dev);
-                                                        if((tp->ring_status & REMOVE_RECEIVED)
-                                                                && (tp->config_word0 & NO_AUTOREMOVE))
+                                                        if((tp->ring_status & REMOVE_RECEIVED) &&
+							   (tp->config_word0 & NO_AUTOREMOVE))
                                                         {
                                                                 smctr_issue_remove_cmd(dev);
                                                         }
@@ -2511,9 +2511,9 @@ static int smctr_issue_init_timers_cmd(struct net_device *dev)
         tp->config_word0 = THDREN | DMA_TRIGGER | USETPT | NO_AUTOREMOVE;
         tp->config_word1 = 0;
 
-        if((tp->media_type == MEDIA_STP_16)
-                || (tp->media_type == MEDIA_UTP_16)
-                || (tp->media_type == MEDIA_STP_16_UTP_16))
+        if((tp->media_type == MEDIA_STP_16) ||
+	   (tp->media_type == MEDIA_UTP_16) ||
+	   (tp->media_type == MEDIA_STP_16_UTP_16))
         {
                 tp->config_word0 |= FREQ_16MB_BIT;
         }
@@ -2556,9 +2556,9 @@ static int smctr_issue_init_timers_cmd(struct net_device *dev)
                         tp->config_word1 &= ~SOURCE_ROUTING_SPANNING_BITS;
         }
 
-        if((tp->media_type == MEDIA_STP_16)
-                || (tp->media_type == MEDIA_UTP_16)
-                || (tp->media_type == MEDIA_STP_16_UTP_16))
+        if((tp->media_type == MEDIA_STP_16) ||
+	   (tp->media_type == MEDIA_UTP_16) ||
+	   (tp->media_type == MEDIA_STP_16_UTP_16))
         {
                 tp->config_word1 |= INTERFRAME_SPACING_16;
         }
@@ -2568,9 +2568,9 @@ static int smctr_issue_init_timers_cmd(struct net_device *dev)
         *pTimer_Struc++ = tp->config_word0;
         *pTimer_Struc++ = tp->config_word1;
 
-        if((tp->media_type == MEDIA_STP_4)
-                || (tp->media_type == MEDIA_UTP_4)
-                || (tp->media_type == MEDIA_STP_4_UTP_4))
+        if((tp->media_type == MEDIA_STP_4) ||
+	   (tp->media_type == MEDIA_UTP_4) ||
+	   (tp->media_type == MEDIA_STP_4_UTP_4))
         {
                 *pTimer_Struc++ = 0x00FA;       /* prescale */
                 *pTimer_Struc++ = 0x2710;       /* TPT_limit */
@@ -2990,8 +2990,8 @@ static int smctr_load_firmware(struct net_device *dev)
 	}
 
         /* Verify the firmware exists and is there in the right amount. */
-        if (!fw->data
-                || (*(fw->data + UCODE_VERSION_OFFSET) < UCODE_VERSION))
+        if (!fw->data ||
+	    (*(fw->data + UCODE_VERSION_OFFSET) < UCODE_VERSION))
         {
                 err = (UCODE_NOT_PRESENT);
 		goto out;
@@ -3010,9 +3010,8 @@ static int smctr_load_firmware(struct net_device *dev)
         smctr_enable_16bit(dev);
         smctr_set_page(dev, (__u8 *)tp->ram_access);
 
-        if((smctr_checksum_firmware(dev))
-                || (*(fw->data + UCODE_VERSION_OFFSET)
-                > tp->microcode_version))
+        if((smctr_checksum_firmware(dev)) ||
+	   (*(fw->data + UCODE_VERSION_OFFSET) > tp->microcode_version))
         {
                 smctr_enable_adapter_ctrl_store(dev);
 
@@ -3117,9 +3116,9 @@ static int smctr_lobe_media_test(struct net_device *dev)
         }
 
         /* Check if any frames received during test. */
-        if((tp->rx_fcb_curr[MAC_QUEUE]->frame_status)
-                || (tp->rx_fcb_curr[NON_MAC_QUEUE]->frame_status))
-			goto err;
+        if((tp->rx_fcb_curr[MAC_QUEUE]->frame_status) ||
+	   (tp->rx_fcb_curr[NON_MAC_QUEUE]->frame_status))
+		goto err;
 
         /* Set receive mask to "Promisc" mode. */
         tp->receive_mask = saved_rcv_mask;
@@ -3303,8 +3302,8 @@ static int smctr_make_group_addr(struct net_device *dev, MAC_SUB_VECTOR *tsv)
         /* Set Group Address Sub-vector to all zeros if only the
          * Group Address/Functional Address Indicator is set.
          */
-        if(tsv->svv[0] == 0x80 && tsv->svv[1] == 0x00
-        	&& tsv->svv[2] == 0x00 && tsv->svv[3] == 0x00)
+        if(tsv->svv[0] == 0x80 && tsv->svv[1] == 0x00 &&
+	   tsv->svv[2] == 0x00 && tsv->svv[3] == 0x00)
                 tsv->svv[0] = 0x00;
 
         return (0);
@@ -3876,10 +3875,10 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
         /* NOTE: UNKNOWN MAC frames will NOT be passed up unless
          * ACCEPT_ATT_MAC_FRAMES is set.
          */
-        if(((tp->receive_mask & ACCEPT_ATT_MAC_FRAMES)
-                && (xframe == (__u8)0))
-                || ((tp->receive_mask & ACCEPT_EXT_MAC_FRAMES)
-                && (xframe == (__u8)1)))
+        if(((tp->receive_mask & ACCEPT_ATT_MAC_FRAMES) &&
+	    (xframe == (__u8)0)) ||
+	   ((tp->receive_mask & ACCEPT_EXT_MAC_FRAMES) &&
+	    (xframe == (__u8)1)))
         {
                 rmf->vl = SWAP_BYTES(rmf->vl);
 
@@ -3934,8 +3933,8 @@ static int smctr_ram_memory_test(struct net_device *dev)
 
                 word_pattern = start_pattern;
 
-                for(j = 1; j < (__u32)(tp->ram_usable * 1024) - 1
-                        && (~err); j += 2, word_pattern++)
+                for(j = 1; j < (__u32)(tp->ram_usable * 1024) - 1 && (~err);
+		    j += 2, word_pattern++)
                 {
                         word_read = *(__u16 *)(pword + j);
                         if(word_read != word_pattern)
@@ -3959,8 +3958,7 @@ static int smctr_ram_memory_test(struct net_device *dev)
                 for(j = 0; j < (__u32)tp->ram_usable * 1024; j +=2)
                         *(__u16 *)(pword + j) = word_pattern;
 
-                for(j =0; j < (__u32)tp->ram_usable * 1024
-                        && (~err); j += 2)
+                for(j =0; j < (__u32)tp->ram_usable * 1024 && (~err); j += 2)
                 {
                         word_read = *(__u16 *)(pword + j);
                         if(word_read != word_pattern)
@@ -4325,8 +4323,8 @@ static int smctr_restart_tx_chain(struct net_device *dev, short queue)
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_restart_tx_chain\n", dev->name);
 
-        if(tp->num_tx_fcbs_used[queue] != 0
-                && tp->tx_queue_status[queue] == NOT_TRANSMITING)
+        if(tp->num_tx_fcbs_used[queue] != 0 &&
+	   tp->tx_queue_status[queue] == NOT_TRANSMITING)
         {
                 tp->tx_queue_status[queue] = TRANSMITING;
                 err = smctr_issue_resume_tx_fcb_cmd(dev, queue);
@@ -4349,8 +4347,8 @@ static int smctr_ring_status_chg(struct net_device *dev)
          */
         if(tp->ring_status_flags == MONITOR_STATE_CHANGED)
         {
-                if((tp->monitor_state == MS_ACTIVE_MONITOR_STATE)
-                        || (tp->monitor_state == MS_STANDBY_MONITOR_STATE))
+                if((tp->monitor_state == MS_ACTIVE_MONITOR_STATE) ||
+		   (tp->monitor_state == MS_STANDBY_MONITOR_STATE))
                 {
                         tp->monitor_state_ready = 1;
                 }
@@ -4363,8 +4361,8 @@ static int smctr_ring_status_chg(struct net_device *dev)
                         tp->monitor_state_ready = 0;
 
 			/* Ring speed problem, switching to auto mode. */
-			if(tp->monitor_state == MS_MONITOR_FSM_INACTIVE
-				&& !tp->cleanup)
+			if(tp->monitor_state == MS_MONITOR_FSM_INACTIVE &&
+			   !tp->cleanup)
 			{
 				printk(KERN_INFO "%s: Incorrect ring speed switching.\n",
 					dev->name);
@@ -4442,8 +4440,8 @@ static int smctr_rx_frame(struct net_device *dev)
         {
                 err = HARDWARE_FAILED;
 
-                if(((status & 0x007f) == 0)
-                        || ((tp->receive_mask & ACCEPT_ERR_PACKETS) != 0))
+                if(((status & 0x007f) == 0) ||
+		   ((tp->receive_mask & ACCEPT_ERR_PACKETS) != 0))
                 {
                         /* frame length less the CRC (4 bytes) + FS (1 byte) */
                         rx_size = tp->rx_fcb_curr[queue]->frame_length - 5;
@@ -4538,8 +4536,8 @@ static int smctr_send_dat(struct net_device *dev)
         }
 
         /* Check if GOOD frame Tx'ed. */
-        if(!(fcb->frame_status &  FCB_COMMAND_DONE)
-                || fcb->frame_status & (FCB_TX_STATUS_E | FCB_TX_AC_BITS))
+        if(!(fcb->frame_status &  FCB_COMMAND_DONE) ||
+	   fcb->frame_status & (FCB_TX_STATUS_E | FCB_TX_AC_BITS))
         {
                 return (INITIALIZE_FAILED);
         }
@@ -4653,8 +4651,8 @@ static int smctr_send_lobe_media_test(struct net_device *dev)
         }
 
         /* Check if GOOD frame Tx'ed */
-        if(!(fcb->frame_status & FCB_COMMAND_DONE)
-                || fcb->frame_status & (FCB_TX_STATUS_E | FCB_TX_AC_BITS))
+        if(!(fcb->frame_status & FCB_COMMAND_DONE) ||
+	   fcb->frame_status & (FCB_TX_STATUS_E | FCB_TX_AC_BITS))
         {
                 return (LOBE_MEDIA_TEST_FAILED);
         }
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index fa15214..e3c42f5 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -729,8 +729,8 @@ static void tms380tr_timer_chk(unsigned long data)
 		return;
 
 	tms380tr_chk_outstanding_cmds(dev);
-	if(time_before(tp->LastSendTime + SEND_TIMEOUT, jiffies)
-		&& (tp->TplFree != tp->TplBusy))
+	if(time_before(tp->LastSendTime + SEND_TIMEOUT, jiffies) &&
+	   (tp->TplFree != tp->TplBusy))
 	{
 		/* Anything to send, but stalled too long */
 		tp->LastSendTime = jiffies;
@@ -830,8 +830,8 @@ irqreturn_t tms380tr_interrupt(int irq, void *dev_id)
 		}
 
 		/* Reset system interrupt if not already done. */
-		if(irq_type != STS_IRQ_TRANSMIT_STATUS
-			&& irq_type != STS_IRQ_RECEIVE_STATUS) {
+		if(irq_type != STS_IRQ_TRANSMIT_STATUS &&
+		   irq_type != STS_IRQ_RECEIVE_STATUS) {
 			tms380tr_reset_interrupt(dev);
 		}
 
@@ -895,10 +895,10 @@ static unsigned char tms380tr_chk_ssb(struct net_local *tp, unsigned short IrqTy
 
 	/* Check if this interrupt does use the SSB. */
 
-	if(IrqType != STS_IRQ_TRANSMIT_STATUS
-		&& IrqType != STS_IRQ_RECEIVE_STATUS
-		&& IrqType != STS_IRQ_COMMAND_STATUS
-		&& IrqType != STS_IRQ_RING_STATUS)
+	if(IrqType != STS_IRQ_TRANSMIT_STATUS &&
+	   IrqType != STS_IRQ_RECEIVE_STATUS &&
+	   IrqType != STS_IRQ_COMMAND_STATUS &&
+	   IrqType != STS_IRQ_RING_STATUS)
 	{
 		return (1);	/* SSB not involved. */
 	}
@@ -1485,8 +1485,8 @@ static int tms380tr_init_adapter(struct net_device *dev)
 			/* Mask interesting status bits */
 			Status = SIFREADW(SIFSTS);
 			Status &= STS_MASK;
-		} while(((Status &(STS_INITIALIZE | STS_ERROR | STS_TEST)) != 0)
-			&& ((Status & STS_ERROR) == 0) && (loop_cnt != 0));
+		} while(((Status &(STS_INITIALIZE | STS_ERROR | STS_TEST)) != 0) &&
+			((Status & STS_ERROR) == 0) && (loop_cnt != 0));
 
 		if((Status & (STS_INITIALIZE | STS_ERROR | STS_TEST)) == 0)
 		{
@@ -2183,8 +2183,8 @@ static void tms380tr_rcv_status_irq(struct net_device *dev)
 				}
 			}
 
-			if(skb && (rpl->SkbStat == SKB_DATA_COPY
-				|| rpl->SkbStat == SKB_DMA_DIRECT))
+			if(skb && (rpl->SkbStat == SKB_DATA_COPY ||
+				   rpl->SkbStat == SKB_DMA_DIRECT))
 			{
 				if(rpl->SkbStat == SKB_DATA_COPY)
 					skb_copy_to_linear_data(skb, ReceiveDataPtr,
diff --git a/drivers/net/tulip/21142.c b/drivers/net/tulip/21142.c
index db7d5e1..9f6742f 100644
--- a/drivers/net/tulip/21142.c
+++ b/drivers/net/tulip/21142.c
@@ -209,10 +209,10 @@ void t21142_lnk_change(struct net_device *dev, int csr5)
 			printk(KERN_DEBUG "%s:  Setting CSR6 %8.8x/%x CSR12 %8.8x.\n",
 				   dev->name, tp->csr6, ioread32(ioaddr + CSR6),
 				   ioread32(ioaddr + CSR12));
-	} else if ((tp->nwayset  &&  (csr5 & 0x08000000)
-				&& (dev->if_port == 3  ||  dev->if_port == 5)
-				&& (csr12 & 2) == 2) ||
-			   (tp->nway && (csr5 & (TPLnkFail)))) {
+	} else if ((tp->nwayset  &&  (csr5 & 0x08000000) &&
+		    (dev->if_port == 3  ||  dev->if_port == 5) &&
+		    (csr12 & 2) == 2) ||
+		   (tp->nway && (csr5 & (TPLnkFail)))) {
 		/* Link blew? Maybe restart NWay. */
 		del_timer_sync(&tp->timer);
 		t21142_start_nway(dev);
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 74e5ba4..d4255d4 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -62,9 +62,9 @@ module_param (debug, int, 0);
 MODULE_PARM_DESC (debug, "de2104x bitmapped message enable number");
 
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
-#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
-        || defined(CONFIG_SPARC) || defined(__ia64__) \
-        || defined(__sh__) || defined(__mips__)
+#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) || \
+        defined(CONFIG_SPARC) || defined(__ia64__) ||		   \
+        defined(__sh__) || defined(__mips__)
 static int rx_copybreak = 1518;
 #else
 static int rx_copybreak = 100;
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index 391acd3..889f57a 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -174,10 +174,10 @@ void __devinit tulip_parse_eeprom(struct net_device *dev)
 		}
 	  /* Do a fix-up based on the vendor half of the station address prefix. */
 	  for (i = 0; eeprom_fixups[i].name; i++) {
-		if (dev->dev_addr[0] == eeprom_fixups[i].addr0
-			&&  dev->dev_addr[1] == eeprom_fixups[i].addr1
-			&&  dev->dev_addr[2] == eeprom_fixups[i].addr2) {
-		  if (dev->dev_addr[2] == 0xE8  &&  ee_data[0x1a] == 0x55)
+		  if (dev->dev_addr[0] == eeprom_fixups[i].addr0 &&
+		      dev->dev_addr[1] == eeprom_fixups[i].addr1 &&
+		      dev->dev_addr[2] == eeprom_fixups[i].addr2) {
+		  if (dev->dev_addr[2] == 0xE8 && ee_data[0x1a] == 0x55)
 			  i++;			/* An Accton EN1207, not an outlaw Maxtech. */
 		  memcpy(ee_data + 26, eeprom_fixups[i].newtable,
 				 sizeof(eeprom_fixups[i].newtable));
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index c8d220c..2e8e8ee 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -170,8 +170,8 @@ int tulip_poll(struct napi_struct *napi, int budget)
 				      RxDescCollisionSeen |
 				      RxDescRunt |
 				      RxDescDescErr |
-				      RxWholePkt)) != RxWholePkt
-			   || pkt_len > 1518) {
+				      RxWholePkt)) != RxWholePkt ||
+			   pkt_len > 1518) {
 			       if ((status & (RxLengthOver2047 |
 					      RxWholePkt)) != RxWholePkt) {
                                 /* Ingore earlier buffers. */
@@ -201,8 +201,8 @@ int tulip_poll(struct napi_struct *napi, int budget)
 
                                /* Check if the packet is long enough to accept without copying
                                   to a minimally-sized skbuff. */
-                               if (pkt_len < tulip_rx_copybreak
-                                   && (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+                               if (pkt_len < tulip_rx_copybreak &&
+                                   (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
                                        skb_reserve(skb, 2);    /* 16 byte align the IP header */
                                        pci_dma_sync_single_for_cpu(tp->pdev,
 								   tp->rx_buffers[entry].mapping,
@@ -395,8 +395,8 @@ static int tulip_rx(struct net_device *dev)
 			       RxDescCollisionSeen |
 			       RxDescRunt |
 			       RxDescDescErr |
-			       RxWholePkt))        != RxWholePkt
-		     || pkt_len > 1518) {
+			       RxWholePkt))        != RxWholePkt ||
+		    pkt_len > 1518) {
 			if ((status & (RxLengthOver2047 |
 			     RxWholePkt))         != RxWholePkt) {
 				/* Ingore earlier buffers. */
@@ -425,8 +425,8 @@ static int tulip_rx(struct net_device *dev)
 
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
-			if (pkt_len < tulip_rx_copybreak
-				&& (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			if (pkt_len < tulip_rx_copybreak &&
+			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(tp->pdev,
 							    tp->rx_buffers[entry].mapping,
diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index daddfa5..d8fda83 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
@@ -468,8 +468,8 @@ void __devinit tulip_find_mii (struct net_device *dev, int board_idx)
 		int phy = phyn & 0x1f;
 		int mii_status = tulip_mdio_read (dev, phy, MII_BMSR);
 		if ((mii_status & 0x8301) == 0x8001 ||
-		    ((mii_status & BMSR_100BASE4) == 0
-		     && (mii_status & 0x7800) != 0)) {
+		    ((mii_status & BMSR_100BASE4) == 0 &&
+		     (mii_status & 0x7800) != 0)) {
 			/* preserve Becker logic, gain indentation level */
 		} else {
 			continue;
diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
index f495791..d841869 100644
--- a/drivers/net/tulip/pnic2.c
+++ b/drivers/net/tulip/pnic2.c
@@ -316,9 +316,9 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 		}
 	}
 
-	if ((tp->nwayset  &&  (csr5 & 0x08000000)
-			  && (dev->if_port == 3  ||  dev->if_port == 5)
-			  && (csr12 & 2) == 2) || (tp->nway && (csr5 & (TPLnkFail)))) {
+	if ((tp->nwayset  &&  (csr5 & 0x08000000) &&
+	     (dev->if_port == 3  ||  dev->if_port == 5) &&
+	     (csr12 & 2) == 2) || (tp->nway && (csr5 & (TPLnkFail)))) {
 
 		/* Link blew? Maybe restart NWay. */
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 0df983b..0fa3140 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -64,9 +64,9 @@ const char * const medianame[32] = {
 };
 
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
-#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
-	|| defined(CONFIG_SPARC) || defined(__ia64__) \
-	|| defined(__sh__) || defined(__mips__)
+#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) || \
+	defined(CONFIG_SPARC) || defined(__ia64__) || \
+	defined(__sh__) || defined(__mips__)
 static int rx_copybreak = 1518;
 #else
 static int rx_copybreak = 100;
@@ -449,8 +449,8 @@ media_picked:
 			iowrite32(0x0201B078, ioaddr + 0xB8);
 			next_tick = 1*HZ;
 		}
-	} else if ((tp->chip_id == MX98713 || tp->chip_id == COMPEX9881)
-			   && ! tp->medialock) {
+	} else if ((tp->chip_id == MX98713 || tp->chip_id == COMPEX9881) &&
+		   ! tp->medialock) {
 		dev->if_port = 0;
 		tp->csr6 = 0x01880000 | (tp->full_duplex ? 0x0200 : 0);
 		iowrite32(0x0f370000 | ioread16(ioaddr + 0x80), ioaddr + 0x80);
@@ -535,9 +535,9 @@ static void tulip_tx_timeout(struct net_device *dev)
 		if (tulip_debug > 1)
 			printk(KERN_WARNING "%s: Transmit timeout using MII device.\n",
 				   dev->name);
-	} else if (tp->chip_id == DC21140 || tp->chip_id == DC21142
-			   || tp->chip_id == MX98713 || tp->chip_id == COMPEX9881
-			   || tp->chip_id == DM910X) {
+	} else if (tp->chip_id == DC21140 || tp->chip_id == DC21142 ||
+		   tp->chip_id == MX98713 || tp->chip_id == COMPEX9881 ||
+		   tp->chip_id == DM910X) {
 		printk(KERN_WARNING "%s: 21140 transmit timed out, status %8.8x, "
 			   "SIA %8.8x %8.8x %8.8x %8.8x, resetting...\n",
 			   dev->name, ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR12),
@@ -1538,8 +1538,10 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		}
 	}
 	/* Lite-On boards have the address byte-swapped. */
-	if ((dev->dev_addr[0] == 0xA0  ||  dev->dev_addr[0] == 0xC0 || dev->dev_addr[0] == 0x02)
-		&&  dev->dev_addr[1] == 0x00)
+	if ((dev->dev_addr[0] == 0xA0 ||
+	     dev->dev_addr[0] == 0xC0 ||
+	     dev->dev_addr[0] == 0x02) &&
+	    dev->dev_addr[1] == 0x00)
 		for (i = 0; i < 6; i+=2) {
 			char tmp = dev->dev_addr[i];
 			dev->dev_addr[i] = dev->dev_addr[i+1];
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 1a52729..869a7a0 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1230,8 +1230,8 @@ static int netdev_rx(struct net_device *dev)
 #endif
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak
-				&& (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,np->rx_addr[entry],
 							    np->rx_skbuff[entry]->len,
@@ -1357,8 +1357,8 @@ static u32 __set_rx_mode(struct net_device *dev)
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = RxAcceptBroadcast | AcceptMulticast | RxAcceptAllPhys
 			| AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit)
-			   ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = RxAcceptBroadcast | AcceptMulticast | AcceptMyPhys;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 079a970..39f1fc6 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1769,8 +1769,8 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
 		csum_bits = rx->rxStatus & (TYPHOON_RX_IP_CHK_GOOD |
 			TYPHOON_RX_UDP_CHK_GOOD | TYPHOON_RX_TCP_CHK_GOOD);
 		if(csum_bits ==
-		   (TYPHOON_RX_IP_CHK_GOOD | TYPHOON_RX_TCP_CHK_GOOD)
-		   || csum_bits ==
+		   (TYPHOON_RX_IP_CHK_GOOD | TYPHOON_RX_TCP_CHK_GOOD) ||
+		   csum_bits ==
 		   (TYPHOON_RX_IP_CHK_GOOD | TYPHOON_RX_UDP_CHK_GOOD)) {
 			new_skb->ip_summed = CHECKSUM_UNNECESSARY;
 		} else
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 4469f24..9f44c99 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1306,8 +1306,8 @@ static int init_max_rx_buff_len(u16 max_rx_buf_len,
 				u16 __iomem *mrblr_register)
 {
 	/* max_rx_buf_len value must be a multiple of 128 */
-	if ((max_rx_buf_len == 0)
-	    || (max_rx_buf_len % UCC_GETH_MRBLR_ALIGNMENT))
+	if ((max_rx_buf_len == 0) ||
+	    (max_rx_buf_len % UCC_GETH_MRBLR_ALIGNMENT))
 		return -EINVAL;
 
 	out_be16(mrblr_register, max_rx_buf_len);
@@ -2159,8 +2159,8 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	}
 
 	if ((ug_info->numStationAddresses !=
-	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1)
-	    && ug_info->rxExtendedFiltering) {
+	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1) &&
+	    ug_info->rxExtendedFiltering) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Number of station addresses greater than 1 "
 				  "not allowed in extended parsing mode.",
@@ -2284,9 +2284,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1);
 
 	ugeth->rx_extended_features = ugeth->rx_non_dynamic_extended_features ||
-	    (ug_info->vlanOperationTagged != UCC_GETH_VLAN_OPERATION_TAGGED_NOP)
-	    || (ug_info->vlanOperationNonTagged !=
-		UCC_GETH_VLAN_OPERATION_NON_TAGGED_NOP);
+		(ug_info->vlanOperationTagged != UCC_GETH_VLAN_OPERATION_TAGGED_NOP) ||
+		(ug_info->vlanOperationNonTagged !=
+		 UCC_GETH_VLAN_OPERATION_NON_TAGGED_NOP);
 
 	init_default_reg_vals(&uf_regs->upsmr,
 			      &ug_regs->maccfg1, &ug_regs->maccfg2);
@@ -2987,11 +2987,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	ugeth->p_init_enet_param_shadow->rgftgfrxglobal |=
 	    ugeth->rx_glbl_pram_offset | ug_info->riscRx;
 	if ((ug_info->largestexternallookupkeysize !=
-	     QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_NONE)
-	    && (ug_info->largestexternallookupkeysize !=
-		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
-	    && (ug_info->largestexternallookupkeysize !=
-		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
+	     QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_NONE) &&
+	    (ug_info->largestexternallookupkeysize !=
+	     QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES) &&
+	    (ug_info->largestexternallookupkeysize !=
+	     QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Invalid largest External Lookup Key Size.",
 				  __func__);
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 1bef39a..a516185 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -365,8 +365,8 @@ static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 
 	padlen = ((skb->len + 4) % 512) ? 0 : 4;
 
-	if ((!skb_cloned(skb))
-	    && ((headroom + tailroom) >= (4 + padlen))) {
+	if ((!skb_cloned(skb)) &&
+	    ((headroom + tailroom) >= (4 + padlen))) {
 		if ((headroom < 4) || (tailroom < padlen)) {
 			skb->data = memmove(skb->head + 4, skb->data, skb->len);
 			skb_set_tail_pointer(skb, skb->len);
@@ -541,8 +541,8 @@ static void asix_set_multicast(struct net_device *net)
 
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= AX_RX_CTL_PRO;
-	} else if (net->flags & IFF_ALLMULTI
-		   || net->mc_count > AX_MAX_MCAST) {
+	} else if (net->flags & IFF_ALLMULTI ||
+		   net->mc_count > AX_MAX_MCAST) {
 		rx_ctl |= AX_RX_CTL_AMALL;
 	} else if (net->mc_count == 0) {
 		/* just broadcast and directed */
@@ -753,8 +753,8 @@ static void ax88172_set_multicast(struct net_device *net)
 
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= 0x01;
-	} else if (net->flags & IFF_ALLMULTI
-		   || net->mc_count > AX_MAX_MCAST) {
+	} else if (net->flags & IFF_ALLMULTI ||
+		   net->mc_count > AX_MAX_MCAST) {
 		rx_ctl |= 0x02;
 	} else if (net->mc_count == 0) {
 		/* just broadcast and directed */
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 2bed6b0..22b87e6 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -436,8 +436,8 @@ static netdev_tx_t catc_start_xmit(struct sk_buff *skb,
 			clear_bit(TX_RUNNING, &catc->flags);
 	}
 
-	if ((catc->is_f5u011 && catc->tx_ptr)
-	     || (catc->tx_ptr >= ((TX_MAX_BURST - 1) * (PKT_SZ + 2))))
+	if ((catc->is_f5u011 && catc->tx_ptr) ||
+	    (catc->tx_ptr >= ((TX_MAX_BURST - 1) * (PKT_SZ + 2))))
 		netif_stop_queue(netdev);
 
 	spin_unlock_irqrestore(&catc->tx_lock, flags);
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 33d5c57..6491c9c 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -372,12 +372,12 @@ int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
 	/* Data interface has one inactive and one active setting */
 	if (data_intf->num_altsetting != 2)
 		return -EINVAL;
-	if (data_intf->altsetting[0].desc.bNumEndpoints == 0
-	 && data_intf->altsetting[1].desc.bNumEndpoints == 2)
+	if (data_intf->altsetting[0].desc.bNumEndpoints == 0 &&
+	    data_intf->altsetting[1].desc.bNumEndpoints == 2)
 		data_desc = data_intf->altsetting + 1;
 	else
-	if (data_intf->altsetting[0].desc.bNumEndpoints == 2
-	 && data_intf->altsetting[1].desc.bNumEndpoints == 0)
+	if (data_intf->altsetting[0].desc.bNumEndpoints == 2 &&
+	    data_intf->altsetting[1].desc.bNumEndpoints == 0)
 		data_desc = data_intf->altsetting;
 	else
 		return -EINVAL;
diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 2330065..c337ffc 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -121,8 +121,8 @@ static struct sk_buff *eem_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 		int	headroom = skb_headroom(skb);
 		int	tailroom = skb_tailroom(skb);
 
-		if ((tailroom >= ETH_FCS_LEN + padlen)
-				&& (headroom >= EEM_HEAD))
+		if ((tailroom >= ETH_FCS_LEN + padlen) &&
+		    (headroom >= EEM_HEAD))
 			goto done;
 
 		if ((headroom + tailroom)
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 7ec24c9..de3e365 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -37,23 +37,23 @@
 
 static int is_rndis(struct usb_interface_descriptor *desc)
 {
-	return desc->bInterfaceClass == USB_CLASS_COMM
-		&& desc->bInterfaceSubClass == 2
-		&& desc->bInterfaceProtocol == 0xff;
+	return (desc->bInterfaceClass == USB_CLASS_COMM &&
+		desc->bInterfaceSubClass == 2 &&
+		desc->bInterfaceProtocol == 0xff);
 }
 
 static int is_activesync(struct usb_interface_descriptor *desc)
 {
-	return desc->bInterfaceClass == USB_CLASS_MISC
-		&& desc->bInterfaceSubClass == 1
-		&& desc->bInterfaceProtocol == 1;
+	return (desc->bInterfaceClass == USB_CLASS_MISC &&
+		desc->bInterfaceSubClass == 1 &&
+		desc->bInterfaceProtocol == 1);
 }
 
 static int is_wireless_rndis(struct usb_interface_descriptor *desc)
 {
-	return desc->bInterfaceClass == USB_CLASS_WIRELESS_CONTROLLER
-		&& desc->bInterfaceSubClass == 1
-		&& desc->bInterfaceProtocol == 3;
+	return (desc->bInterfaceClass == USB_CLASS_WIRELESS_CONTROLLER &&
+		desc->bInterfaceSubClass == 1 &&
+		desc->bInterfaceProtocol == 3);
 }
 
 #else
@@ -116,9 +116,9 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* this assumes that if there's a non-RNDIS vendor variant
 	 * of cdc-acm, it'll fail RNDIS requests cleanly.
 	 */
-	rndis = is_rndis(&intf->cur_altsetting->desc)
-		|| is_activesync(&intf->cur_altsetting->desc)
-		|| is_wireless_rndis(&intf->cur_altsetting->desc);
+	rndis = (is_rndis(&intf->cur_altsetting->desc) ||
+		 is_activesync(&intf->cur_altsetting->desc) ||
+		 is_wireless_rndis(&intf->cur_altsetting->desc));
 
 	memset(info, 0, sizeof *info);
 	info->control = intf;
@@ -279,10 +279,10 @@ next_desc:
 
 		dev->status = &info->control->cur_altsetting->endpoint [0];
 		desc = &dev->status->desc;
-		if (!usb_endpoint_is_int_in(desc)
-				|| (le16_to_cpu(desc->wMaxPacketSize)
-					< sizeof(struct usb_cdc_notification))
-				|| !desc->bInterval) {
+		if (!usb_endpoint_is_int_in(desc) ||
+		    (le16_to_cpu(desc->wMaxPacketSize)
+		     < sizeof(struct usb_cdc_notification)) ||
+		    !desc->bInterval) {
 			dev_dbg(&intf->dev, "bad notification endpoint\n");
 			dev->status = NULL;
 		}
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 43bc3fc..f78f090 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -602,9 +602,9 @@ static struct hso_serial *get_serial_by_shared_int_and_type(
 	port = hso_mux_to_port(mux);
 
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
-		if (serial_table[i]
-		    && (dev2ser(serial_table[i])->shared_int == shared_int)
-		    && ((serial_table[i]->port_spec & HSO_PORT_MASK) == port)) {
+		if (serial_table[i] &&
+		    (dev2ser(serial_table[i])->shared_int == shared_int) &&
+		    ((serial_table[i]->port_spec & HSO_PORT_MASK) == port)) {
 			return dev2ser(serial_table[i]);
 		}
 	}
@@ -846,8 +846,8 @@ static void hso_net_tx_timeout(struct net_device *net)
 	dev_warn(&net->dev, "Tx timed out.\n");
 
 	/* Tear the waiting frame off the list */
-	if (odev->mux_bulk_tx_urb
-	    && (odev->mux_bulk_tx_urb->status == -EINPROGRESS))
+	if (odev->mux_bulk_tx_urb &&
+	    (odev->mux_bulk_tx_urb->status == -EINPROGRESS))
 		usb_unlink_urb(odev->mux_bulk_tx_urb);
 
 	/* Update statistics */
@@ -1020,9 +1020,9 @@ static void read_bulk_callback(struct urb *urb)
 		u32 rest;
 		u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
 		rest = urb->actual_length % odev->in_endp->wMaxPacketSize;
-		if (((rest == 5) || (rest == 6))
-		    && !memcmp(((u8 *) urb->transfer_buffer) +
-			       urb->actual_length - 4, crc_check, 4)) {
+		if (((rest == 5) || (rest == 6)) &&
+		    !memcmp(((u8 *) urb->transfer_buffer) +
+			    urb->actual_length - 4, crc_check, 4)) {
 			urb->actual_length -= 4;
 		}
 	}
@@ -1226,9 +1226,9 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
 			rest =
 			    urb->actual_length %
 			    serial->in_endp->wMaxPacketSize;
-			if (((rest == 5) || (rest == 6))
-			    && !memcmp(((u8 *) urb->transfer_buffer) +
-				       urb->actual_length - 4, crc_check, 4)) {
+			if (((rest == 5) || (rest == 6)) &&
+			    !memcmp(((u8 *) urb->transfer_buffer) +
+				    urb->actual_length - 4, crc_check, 4)) {
 				urb->actual_length -= 4;
 			}
 		}
@@ -2982,8 +2982,8 @@ static int hso_probe(struct usb_interface *interface,
 
 	case HSO_INTF_BULK:
 		/* It's a regular bulk interface */
-		if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK)
-		    && !disable_net)
+		if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) &&
+		    !disable_net)
 			hso_dev = hso_create_net_device(interface, port_spec);
 		else
 			hso_dev =
@@ -3146,8 +3146,8 @@ static void hso_free_interface(struct usb_interface *interface)
 	int i;
 
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
-		if (serial_table[i]
-		    && (serial_table[i]->interface == interface)) {
+		if (serial_table[i] &&
+		    (serial_table[i]->interface == interface)) {
 			hso_dev = dev2ser(serial_table[i]);
 			spin_lock_irq(&hso_dev->serial_lock);
 			tty = tty_kref_get(hso_dev->tty);
@@ -3163,8 +3163,8 @@ static void hso_free_interface(struct usb_interface *interface)
 	}
 
 	for (i = 0; i < HSO_MAX_NET_DEVICES; i++) {
-		if (network_table[i]
-		    && (network_table[i]->interface == interface)) {
+		if (network_table[i] &&
+		    (network_table[i]->interface == interface)) {
 			struct rfkill *rfk = dev2net(network_table[i])->rfkill;
 			/* hso_stop_net_device doesn't stop the net queue since
 			 * traffic needs to start it again when suspended */
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 10873d9..8737431 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -391,8 +391,8 @@ static void mcs7830_set_multicast(struct net_device *net)
 
 	if (net->flags & IFF_PROMISC) {
 		data->config |= HIF_REG_CONFIG_PROMISCIOUS;
-	} else if (net->flags & IFF_ALLMULTI
-		   || net->mc_count > MCS7830_MAX_MCAST) {
+	} else if (net->flags & IFF_ALLMULTI ||
+		   net->mc_count > MCS7830_MAX_MCAST) {
 		data->config |= HIF_REG_CONFIG_ALLMULTICAST;
 	} else if (net->mc_count == 0) {
 		/* just broadcast and directed */
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index f56dec6..490fa8f 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -114,8 +114,8 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 	 */
 
 	/* Issue the request; xid is unique, don't bother byteswapping it */
-	if (likely(buf->msg_type != RNDIS_MSG_HALT
-			&& buf->msg_type != RNDIS_MSG_RESET)) {
+	if (likely(buf->msg_type != RNDIS_MSG_HALT &&
+		   buf->msg_type != RNDIS_MSG_RESET)) {
 		xid = dev->xid++;
 		if (!xid)
 			xid = dev->xid++;
@@ -493,9 +493,9 @@ int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		data_len = le32_to_cpu(hdr->data_len);
 
 		/* don't choke if we see oob, per-packet data, etc */
-		if (unlikely(hdr->msg_type != RNDIS_MSG_PACKET
-				|| skb->len < msg_len
-				|| (data_offset + data_len + 8) > msg_len)) {
+		if (unlikely(hdr->msg_type != RNDIS_MSG_PACKET ||
+			     skb->len < msg_len ||
+			     (data_offset + data_len + 8) > msg_len)) {
 			dev->net->stats.rx_frame_errors++;
 			devdbg(dev, "bad rndis message %d/%d/%d/%d, len %d",
 				le32_to_cpu(hdr->msg_type),
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 04f3f28..511e7bd 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -140,8 +140,8 @@ int usbnet_get_endpoints(struct usbnet *dev, struct usb_interface *intf)
 	if (!alt || !in || !out)
 		return -EINVAL;
 
-	if (alt->desc.bAlternateSetting != 0
-			|| !(dev->driver_info->flags & FLAG_NO_SETINT)) {
+	if (alt->desc.bAlternateSetting != 0 ||
+	    !(dev->driver_info->flags & FLAG_NO_SETINT)) {
 		tmp = usb_set_interface (dev->udev, alt->desc.bInterfaceNumber,
 				alt->desc.bAlternateSetting);
 		if (tmp < 0)
@@ -351,9 +351,9 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 
 	spin_lock_irqsave (&dev->rxq.lock, lockflags);
 
-	if (netif_running (dev->net)
-			&& netif_device_present (dev->net)
-			&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
+	if (netif_running (dev->net) &&
+	    netif_device_present (dev->net) &&
+	    !test_bit (EVENT_RX_HALT, &dev->flags)) {
 		switch (retval = usb_submit_urb (urb, GFP_ATOMIC)) {
 		case -EPIPE:
 			usbnet_defer_kevent (dev, EVENT_RX_HALT);
@@ -391,8 +391,8 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 
 static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 {
-	if (dev->driver_info->rx_fixup
-			&& !dev->driver_info->rx_fixup (dev, skb))
+	if (dev->driver_info->rx_fixup &&
+	    !dev->driver_info->rx_fixup (dev, skb))
 		goto error;
 	// else network stack removes extra byte if we forced a short packet
 
@@ -484,8 +484,8 @@ block:
 	defer_bh(dev, skb, &dev->rxq);
 
 	if (urb) {
-		if (netif_running (dev->net)
-				&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
+		if (netif_running (dev->net) &&
+		    !test_bit (EVENT_RX_HALT, &dev->flags)) {
 			rx_submit (dev, urb, GFP_ATOMIC);
 			return;
 		}
@@ -649,9 +649,9 @@ int usbnet_stop (struct net_device *net)
 			unlink_urbs(dev, &dev->rxq);
 
 		/* maybe wait for deletions to finish. */
-		while (!skb_queue_empty(&dev->rxq)
-				&& !skb_queue_empty(&dev->txq)
-				&& !skb_queue_empty(&dev->done)) {
+		while (!skb_queue_empty(&dev->rxq) &&
+		       !skb_queue_empty(&dev->txq) &&
+		       !skb_queue_empty(&dev->done)) {
 			msleep(UNLINK_TIMEOUT_MS);
 			if (netif_msg_ifdown(dev))
 				devdbg(dev, "waited for %d urb completions",
@@ -882,9 +882,9 @@ kevent (struct work_struct *work)
 	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
 		unlink_urbs (dev, &dev->txq);
 		status = usb_clear_halt (dev->udev, dev->out);
-		if (status < 0
-				&& status != -EPIPE
-				&& status != -ESHUTDOWN) {
+		if (status < 0 &&
+		    status != -EPIPE &&
+		    status != -ESHUTDOWN) {
 			if (netif_msg_tx_err (dev))
 				deverr (dev, "can't clear tx halt, status %d",
 					status);
@@ -897,9 +897,9 @@ kevent (struct work_struct *work)
 	if (test_bit (EVENT_RX_HALT, &dev->flags)) {
 		unlink_urbs (dev, &dev->rxq);
 		status = usb_clear_halt (dev->udev, dev->in);
-		if (status < 0
-				&& status != -EPIPE
-				&& status != -ESHUTDOWN) {
+		if (status < 0 &&
+		    status != -EPIPE &&
+		    status != -ESHUTDOWN) {
 			if (netif_msg_rx_err (dev))
 				deverr (dev, "can't clear rx halt, status %d",
 					status);
@@ -1126,10 +1126,10 @@ static void usbnet_bh (unsigned long param)
 		}
 
 	// or are we maybe short a few urbs?
-	} else if (netif_running (dev->net)
-			&& netif_device_present (dev->net)
-			&& !timer_pending (&dev->delay)
-			&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
+	} else if (netif_running (dev->net) &&
+		   netif_device_present (dev->net) &&
+		   !timer_pending (&dev->delay) &&
+		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
 		int	qlen = RX_QLEN (dev);
 
@@ -1297,8 +1297,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		// heuristic:  "usb%d" for links we know are two-host,
 		// else "eth%d" when there's reasonable doubt.  userspace
 		// can rename the link if it knows better.
-		if ((dev->driver_info->flags & FLAG_ETHER) != 0
-				&& (net->dev_addr [0] & 0x02) == 0)
+		if ((dev->driver_info->flags & FLAG_ETHER) != 0 &&
+		    (net->dev_addr [0] & 0x02) == 0)
 			strcpy (net->name, "eth%d");
 		/* WLAN devices should always be named "wlan%d" */
 		if ((dev->driver_info->flags & FLAG_WLAN) != 0)
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 04882c8..3eb0b16 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -174,8 +174,8 @@ static int blan_mdlm_bind(struct usbnet *dev, struct usb_interface *intf)
 				goto bad_desc;
 			}
 			/* expect bcdVersion 1.0, ignore */
-			if (memcmp(&desc->bGUID, blan_guid, 16)
-				    && memcmp(&desc->bGUID, safe_guid, 16) ) {
+			if (memcmp(&desc->bGUID, blan_guid, 16) &&
+			    memcmp(&desc->bGUID, safe_guid, 16)) {
 				/* hey, this one might _really_ be MDLM! */
 				dev_dbg(&intf->dev, "MDLM guid\n");
 				goto bad_desc;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index ec94ddf..593e01f 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -42,9 +42,9 @@ static int max_interrupt_work = 20;
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1518 effectively disables this feature. */
-#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
-       || defined(CONFIG_SPARC) || defined(__ia64__) \
-       || defined(__sh__) || defined(__mips__)
+#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) || \
+	defined(CONFIG_SPARC) || defined(__ia64__) ||		   \
+	defined(__sh__) || defined(__mips__)
 static int rx_copybreak = 1518;
 #else
 static int rx_copybreak;
@@ -1683,8 +1683,8 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		rx_mode = 0x1C;
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
-	} else if ((dev->mc_count > multicast_filter_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index d4eac2a..4ceb441 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -895,8 +895,8 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 
 	/*
 	   Check if new status is consisent with current status
-	   if (((mii_status & curr_status) & VELOCITY_AUTONEG_ENABLE)
-	   || (mii_status==curr_status)) {
+	   if (((mii_status & curr_status) & VELOCITY_AUTONEG_ENABLE) ||
+	       (mii_status==curr_status)) {
 	   vptr->mii_status=mii_check_media_mode(vptr->mac_regs);
 	   vptr->mii_status=check_connection_type(vptr->mac_regs);
 	   VELOCITY_PRT(MSG_LEVEL_INFO, "Velocity link no change\n");
@@ -1132,8 +1132,8 @@ static void velocity_set_multi(struct net_device *dev)
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
-	} else if ((dev->mc_count > vptr->multicast_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > vptr->multicast_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB);
@@ -1936,8 +1936,8 @@ static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
 	 *	Look to see if we should kick the transmit network
 	 *	layer for more work.
 	 */
-	if (netif_queue_stopped(vptr->dev) && (full == 0)
-	    && (!(vptr->mii_status & VELOCITY_LINK_FAIL))) {
+	if (netif_queue_stopped(vptr->dev) && (full == 0) &&
+	    (!(vptr->mii_status & VELOCITY_LINK_FAIL))) {
 		netif_wake_queue(vptr->dev);
 	}
 	return works;
@@ -2584,8 +2584,8 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	/*
 	 *	Handle hardware checksum
 	 */
-	if ( (dev->features & NETIF_F_IP_CSUM)
-				 && (skb->ip_summed == CHECKSUM_PARTIAL)) {
+	if ((dev->features & NETIF_F_IP_CSUM) &&
+	    (skb->ip_summed == CHECKSUM_PARTIAL)) {
 		const struct iphdr *ip = ip_hdr(skb);
 		if (ip->protocol == IPPROTO_TCP)
 			td_ptr->tdesc1.TCR |= TCR0_TCPCK;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 74636c5..c708ecc 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -428,8 +428,8 @@ again:
 	/* Out of packets? */
 	if (received < budget) {
 		napi_complete(napi);
-		if (unlikely(!vi->rvq->vq_ops->enable_cb(vi->rvq))
-		    && napi_schedule_prep(napi)) {
+		if (unlikely(!vi->rvq->vq_ops->enable_cb(vi->rvq)) &&
+		    napi_schedule_prep(napi)) {
 			vi->rvq->vq_ops->disable_cb(vi->rvq);
 			__napi_schedule(napi);
 			goto again;
@@ -890,9 +890,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
-	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4)
-	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)
-	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6) ||
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
 		vi->big_packets = true;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index a4c97e7..1ceb9d0 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1780,8 +1780,8 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_LRO);
 		devRead->misc.maxNumRxSG = cpu_to_le16(1 + MAX_SKB_FRAGS);
 	}
-	if ((adapter->netdev->features & NETIF_F_HW_VLAN_RX)
-			&& adapter->vlan_grp) {
+	if ((adapter->netdev->features & NETIF_F_HW_VLAN_RX) &&
+	    adapter->vlan_grp) {
 		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_RXVLAN);
 	}
 
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index e21358e..f1c4b2a 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -2510,9 +2510,9 @@ static int vxge_add_isr(struct vxgedev *vdev)
 			}
 
 			/* Point to next vpath handler */
-			if (((intr_idx + 1) % VXGE_HW_VPATH_MSIX_ACTIVE == 0)
-				&& (vp_idx < (vdev->no_of_vpath - 1)))
-					vp_idx++;
+			if (((intr_idx + 1) % VXGE_HW_VPATH_MSIX_ACTIVE == 0) &&
+			    (vp_idx < (vdev->no_of_vpath - 1)))
+				vp_idx++;
 		}
 
 		intr_cnt = vdev->max_vpath_supported * 2;
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 61ce754..2c012f4 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -1963,14 +1963,14 @@ enum vxge_hw_status __vxge_hw_vpath_alarm_process(
 			val64 = readq(&vp_reg->asic_ntwk_vp_err_reg);
 
 			if (((val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT) &&
-			    (!(val64 &
+			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT) &&
+			     (!(val64 &
 				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK))) ||
 			    ((val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR)
-				&& (!(val64 &
+			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR) &&
+			     (!(val64 &
 				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR)
-			))) {
+				     ))) {
 				sw_stats->error_stats.network_sustained_fault++;
 
 				writeq(
@@ -1983,14 +1983,14 @@ enum vxge_hw_status __vxge_hw_vpath_alarm_process(
 			}
 
 			if (((val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK) &&
-			    (!(val64 &
+			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK) &&
+			     (!(val64 &
 				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT))) ||
 			    ((val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR)
-				&& (!(val64 &
+			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR) &&
+			     (!(val64 &
 				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR)
-			))) {
+				     ))) {
 
 				sw_stats->error_stats.network_sustained_ok++;
 
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index beda387..9bc2e36 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -1346,8 +1346,8 @@ do_bottom_half_tx(struct fst_card_info *card)
 
 		dev = port_to_dev(port);
 		while (!(FST_RDB(card, txDescrRing[pi][port->txpos].bits) &
-			 DMA_OWN)
-		       && !(card->dmatx_in_progress)) {
+			 DMA_OWN) &&
+		       !(card->dmatx_in_progress)) {
 			/*
 			 * There doesn't seem to be a txdone event per-se
 			 * We seem to have to deduce it, by checking the DMA_OWN
@@ -1379,8 +1379,8 @@ do_bottom_half_tx(struct fst_card_info *card)
 				 */
 				FST_WRW(card, txDescrRing[pi][port->txpos].bcnt,
 					cnv_bcnt(skb->len));
-				if ((skb->len < FST_MIN_DMA_LEN)
-				    || (card->family == FST_FAMILY_TXP)) {
+				if ((skb->len < FST_MIN_DMA_LEN) ||
+				    (card->family == FST_FAMILY_TXP)) {
 					/* Enqueue the packet with normal io */
 					memcpy_toio(card->mem +
 						    BUF_OFFSET(txBuffer[pi]
@@ -2030,8 +2030,8 @@ fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		/* Sanity check the parameters. We don't support partial writes
 		 * when going over the top
 		 */
-		if (wrthdr.size > FST_MEMSIZE || wrthdr.offset > FST_MEMSIZE
-		    || wrthdr.size + wrthdr.offset > FST_MEMSIZE) {
+		if (wrthdr.size > FST_MEMSIZE || wrthdr.offset > FST_MEMSIZE ||
+		    wrthdr.size + wrthdr.offset > FST_MEMSIZE) {
 			return -ENXIO;
 		}
 
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 79dabc5..aec4d39 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -514,8 +514,8 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 				  RX_BD_ADDR(ch, chan->rx_first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		nchar = cpc_readw(&ptdescr->len);
-		if ((status & (DST_OVR | DST_CRC | DST_RBIT | DST_SHRT | DST_ABT))
-		    || (nchar > BD_DEF_LEN)) {
+		if ((status & (DST_OVR | DST_CRC | DST_RBIT | DST_SHRT | DST_ABT)) ||
+		    (nchar > BD_DEF_LEN)) {
 
 			if (nchar > BD_DEF_LEN)
 				status |= DST_RBIT;
@@ -1428,8 +1428,7 @@ static void falc_update_stats(pc300_t * card, int ch)
 
 		if (((conf->media == IF_IFACE_T1) &&
 		     (cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_LLBAD) &&
-		     (!(cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_PDEN)))
-		    ||
+		     (!(cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_PDEN))) ||
 		    ((conf->media == IF_IFACE_E1) &&
 		     (cpc_readb(falcbase + F_REG(RSP, ch)) & RSP_LLBAD))) {
 			pfalc->prbs = 2;
@@ -2285,8 +2284,8 @@ static void falc_e1_intr(pc300_t * card, int ch)
 		if (gis & GIS_ISR1) {
 			isr1 = cpc_readb(falcbase + F_REG(FISR1, ch));
 			if (isr1 & FISR1_XMB) {
-				if ((pfalc->xmb_cause & 2)
-				    && pfalc->multiframe_mode) {
+				if ((pfalc->xmb_cause & 2) &&
+				    pfalc->multiframe_mode) {
 					if (cpc_readb (falcbase + F_REG(FRS0, ch)) & 
 									(FRS0_LOS | FRS0_AIS | FRS0_LFA)) {
 						cpc_writeb(falcbase + F_REG(XSP, ch),
@@ -2639,9 +2638,9 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 						!(cpc_readb (scabase + M_REG(CTL, ch)) & CTL_DTR);
 					/* There is no DSR in HD64572 */
 				}
-				if (!arg
-				    || copy_to_user(arg, &pc300status, sizeof(pc300status_t)))
-						return -EINVAL;
+				if (!arg ||
+				    copy_to_user(arg, &pc300status, sizeof(pc300status_t)))
+					return -EINVAL;
 				return 0;
 			}
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 1cc24a4..25477b5 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -195,9 +195,9 @@ static unsigned int  netcard_portlist[ ] __initdata = {
 static inline int __init
 sbni_isa_probe( struct net_device  *dev )
 {
-	if( dev->base_addr > 0x1ff
-	    &&  request_region( dev->base_addr, SBNI_IO_EXTENT, dev->name )
-	    &&  sbni_probe1( dev, dev->base_addr, dev->irq ) )
+	if( dev->base_addr > 0x1ff &&
+	    request_region( dev->base_addr, SBNI_IO_EXTENT, dev->name ) &&
+	    sbni_probe1( dev, dev->base_addr, dev->irq ) )
 
 		return  0;
 	else {
@@ -286,8 +286,8 @@ static int __init sbni_init(struct net_device *dev)
 
 	for( i = 0;  netcard_portlist[ i ];  ++i ) {
 		int  ioaddr = netcard_portlist[ i ];
-		if( request_region( ioaddr, SBNI_IO_EXTENT, dev->name )
-		    &&  sbni_probe1( dev, ioaddr, 0 ))
+		if( request_region( ioaddr, SBNI_IO_EXTENT, dev->name ) &&
+		    sbni_probe1( dev, ioaddr, 0 ))
 			return 0;
 	}
 
@@ -306,9 +306,9 @@ sbni_pci_probe( struct net_device  *dev )
 		unsigned long  pci_ioaddr;
 		u16  subsys;
 
-		if( pdev->vendor != SBNI_PCI_VENDOR
-		    &&  pdev->device != SBNI_PCI_DEVICE )
-				continue;
+		if( pdev->vendor != SBNI_PCI_VENDOR &&
+		    pdev->device != SBNI_PCI_DEVICE )
+			continue;
 
 		pci_ioaddr = pci_resource_start( pdev, 0 );
 		pci_irq_line = pdev->irq;
@@ -977,8 +977,8 @@ check_fhdr( u32  ioaddr,  u32  *framelen,  u32  *frameno,  u32  *ack,
 	*ack = *framelen & FRAME_ACK_MASK;
 	*is_first = (*framelen & FRAME_FIRST) != 0;
 
-	if( (*framelen &= FRAME_LEN_MASK) < 6
-	    ||  *framelen > SBNI_MAX_FRAME - 3 )
+	if( (*framelen &= FRAME_LEN_MASK) < 6 ||
+	    *framelen > SBNI_MAX_FRAME - 3 )
 		return  0;
 
 	value = inb( ioaddr + DAT );
@@ -1173,10 +1173,10 @@ sbni_open( struct net_device  *dev )
 	if( dev->base_addr < 0x400 ) {		/* ISA only */
 		struct net_device  **p = sbni_cards;
 		for( ;  *p  &&  p < sbni_cards + SBNI_MAX_NUM_CARDS;  ++p )
-			if( (*p)->irq == dev->irq
-			    &&  ((*p)->base_addr == dev->base_addr + 4
-				 ||  (*p)->base_addr == dev->base_addr - 4)
-			    &&  (*p)->flags & IFF_UP ) {
+			if( (*p)->irq == dev->irq &&
+			    ((*p)->base_addr == dev->base_addr + 4 ||
+			     (*p)->base_addr == dev->base_addr - 4) &&
+			    (*p)->flags & IFF_UP ) {
 
 				((struct net_local *) (netdev_priv(*p)))
 					->second = dev;
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 3c325d7..b9f520b 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -657,8 +657,8 @@ static void x25_asy_unesc(struct x25_asy *sl, unsigned char s)
 
 	switch (s) {
 	case X25_END:
-		if (!test_and_clear_bit(SLF_ERROR, &sl->flags)
-			&& sl->rcount > 2)
+		if (!test_and_clear_bit(SLF_ERROR, &sl->flags) &&
+		    sl->rcount > 2)
 			x25_asy_bump(sl);
 		clear_bit(SLF_ESCAPE, &sl->flags);
 		sl->rcount = 0;
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index d831dfc..0f773a9 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -944,8 +944,8 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 			dev_kfree_skb_irq(skb);
 			yp->tx_skbuff[entry] = NULL;
 		}
-		if (yp->tx_full
-			&& yp->cur_tx - yp->dirty_tx < TX_QUEUE_SIZE - 4) {
+		if (yp->tx_full &&
+		    yp->cur_tx - yp->dirty_tx < TX_QUEUE_SIZE - 4) {
 			/* The ring is no longer full, clear tbusy. */
 			yp->tx_full = 0;
 			netif_wake_queue(dev);
@@ -1014,8 +1014,8 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 			}
 #endif
 
-			if (yp->tx_full
-				&& yp->cur_tx - dirty_tx < TX_QUEUE_SIZE - 2) {
+			if (yp->tx_full &&
+			    yp->cur_tx - dirty_tx < TX_QUEUE_SIZE - 2) {
 				/* The ring is no longer full, clear tbusy. */
 				yp->tx_full = 0;
 				netif_wake_queue(dev);
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index a97d894..bc5ae0f 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -697,8 +697,8 @@ static void znet_rx(struct net_device *dev)
 	   the same area of the backwards links we now have.  This allows us to
 	   pass packets to the upper layers in the order they were received --
 	   important for fast-path sequential operations. */
-	 while (znet->rx_start + cur_frame_end_offset != znet->rx_cur
-			&& ++boguscount < 5) {
+	while (znet->rx_start + cur_frame_end_offset != znet->rx_cur &&
+	       ++boguscount < 5) {
 		unsigned short hi_cnt, lo_cnt, hi_status, lo_status;
 		int count, status;
 


