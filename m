From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH] whitespace and CodingStyle fixes for sis900
Date: Sun, 29 Aug 2004 12:39:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829103902.GE5168@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OZkY3AIuv2LYvjdk"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OZkY3AIuv2LYvjdk
Content-Type: multipart/mixed; boundary="/unnNtmY43mpUSKx"
Content-Disposition: inline


--/unnNtmY43mpUSKx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Big patch, but only contains whitespace and CodingStyle fixes to make
the whole sis900.c file uniform. Some >80 lines where too difficult to
split, so I let them alone, readability would be just as bad as is now.

This patch depends on the previous one liner that adds the new PHY ID
and is made against kernel 2.6.8 (as the previous).

This patch is also available at: http://teg.homeunix.org/sis900.html

--=20
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--/unnNtmY43mpUSKx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-codingstyle.diff"
Content-Transfer-Encoding: quoted-printable

Index: sis900.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/drivers/net/sis900.c	(revision 11)
+++ b/drivers/net/sis900.c	(working copy)
@@ -140,9 +140,9 @@
 };
=20
 typedef struct _BufferDesc {
-	u32	link;
-	u32	cmdsts;
-	u32	bufptr;
+	u32 link;
+	u32 cmdsts;
+	u32 bufptr;
 } BufferDesc;
=20
 struct sis900_private {
@@ -156,7 +156,7 @@
 	unsigned int cur_phy;
=20
 	struct timer_list timer; /* Link status detection timer. */
-	u8     autong_complete; /* 1: auto-negotiate complete  */
+	u8 autong_complete; /* 1: auto-negotiate complete  */
=20
 	unsigned int cur_rx, dirty_rx; /* producer/comsumer pointers for Tx/Rx ri=
ng */
 	unsigned int cur_tx, dirty_tx;
@@ -170,7 +170,7 @@
 	dma_addr_t tx_ring_dma;
 	dma_addr_t rx_ring_dma;
=20
-	unsigned int tx_full;			/* The Tx queue is full.    */
+	unsigned int tx_full; /* The Tx queue is full. */
 	u8 host_bridge_rev;
 	u32 pci_state[16];
 };
@@ -256,7 +256,8 @@
  *	MAC address is read into @net_dev->dev_addr.
  */
=20
-static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev, struct=
 net_device *net_dev)
+static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
+					struct net_device *net_dev)
 {
 	struct pci_dev *isa_bridge =3D NULL;
 	u8 reg;
@@ -293,7 +294,8 @@
  *	@net_dev->dev_addr.
  */
=20
-static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev, struct =
net_device *net_dev)
+static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
+					struct net_device *net_dev)
 {
 	long ioaddr =3D net_dev->base_addr;
 	u32 rfcrSave;
@@ -335,7 +337,8 @@
  *	MAC address is read into @net_dev->dev_addr.
  */
=20
-static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev, struct =
net_device *net_dev)
+static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev,
+					struct net_device *net_dev)
 {
 	long ioaddr =3D net_dev->base_addr;
 	long ee_addr =3D ioaddr + mear;
@@ -372,7 +375,8 @@
  *	ie: sis900_open(), sis900_start_xmit(), sis900_close(), etc.
  */
=20
-static int __devinit sis900_probe (struct pci_dev *pci_dev, const struct p=
ci_device_id *pci_id)
+static int __devinit sis900_probe(struct pci_dev *pci_dev,
+				const struct pci_device_id *pci_id)
 {
 	struct sis900_private *sis_priv;
 	struct net_device *net_dev;
@@ -523,7 +527,7 @@
  *	return error if it failed to found.
  */
=20
-static int __init sis900_mii_probe (struct net_device * net_dev)
+static int __init sis900_mii_probe(struct net_device * net_dev)
 {
 	struct sis900_private * sis_priv =3D net_dev->priv;
 	u16 poll_bit =3D MII_STAT_LINK, status =3D 0;
@@ -573,9 +577,10 @@
 				mii_phy->phy_types =3D mii_chip_table[i].phy_types;
 				if (mii_chip_table[i].phy_types =3D=3D MIX)
 					mii_phy->phy_types =3D
-						(mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOME;
+					    (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HO=
ME;
 				printk(KERN_INFO "%s: %s transceiver found at address %d.\n",
-				       net_dev->name, mii_chip_table[i].name, phy_addr);
+				       net_dev->name, mii_chip_table[i].name,
+				       phy_addr);
 				break;
 			}
 		=09
@@ -588,7 +593,7 @@
 =09
 	if (sis_priv->mii =3D=3D NULL) {
 		printk(KERN_INFO "%s: No MII transceivers found!\n",
-		       net_dev->name);
+			net_dev->name);
 		return 0;
 	}
=20
@@ -612,7 +617,8 @@
=20
 			poll_bit ^=3D (mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS) & poll=
_bit);
 			if (time_after_eq(jiffies, timeout)) {
-				printk(KERN_WARNING "%s: reset phy and link down now\n", net_dev->name=
);
+				printk(KERN_WARNING "%s: reset phy and link down now\n",
+					net_dev->name);
 				return -ETIME;
 			}
 		}
@@ -648,38 +654,41 @@
 static u16 sis900_default_phy(struct net_device * net_dev)
 {
 	struct sis900_private * sis_priv =3D net_dev->priv;
- 	struct mii_phy *phy =3D NULL, *phy_home =3D NULL, *default_phy =3D NULL,=
 *phy_lan =3D NULL;
+ 	struct mii_phy *phy =3D NULL, *phy_home =3D NULL,=20
+		*default_phy =3D NULL, *phy_lan =3D NULL;
 	u16 status;
=20
-        for( phy=3Dsis_priv->first_mii; phy; phy=3Dphy->next ){
+        for (phy=3Dsis_priv->first_mii; phy; phy=3Dphy->next) {
 		status =3D mdio_read(net_dev, phy->phy_addr, MII_STATUS);
 		status =3D mdio_read(net_dev, phy->phy_addr, MII_STATUS);
=20
 		/* Link ON & Not select default PHY & not ghost PHY */
-		 if ( (status & MII_STAT_LINK) && !default_phy && (phy->phy_types !=3D U=
NKNOWN) )
+		 if ((status & MII_STAT_LINK) && !default_phy &&
+					(phy->phy_types !=3D UNKNOWN))
 		 	default_phy =3D phy;
-		 else{
+		 else {
 			status =3D mdio_read(net_dev, phy->phy_addr, MII_CONTROL);
 			mdio_write(net_dev, phy->phy_addr, MII_CONTROL,
 				status | MII_CNTL_AUTO | MII_CNTL_ISOLATE);
-			if( phy->phy_types =3D=3D HOME )
+			if (phy->phy_types =3D=3D HOME)
 				phy_home =3D phy;
-			else if (phy->phy_types =3D=3D LAN)
+			else if(phy->phy_types =3D=3D LAN)
 				phy_lan =3D phy;
 		 }
 	}
=20
-	if( !default_phy && phy_home )
+	if (!default_phy && phy_home)
 		default_phy =3D phy_home;
-	else if( !default_phy && phy_lan )
+	else if (!default_phy && phy_lan)
 		default_phy =3D phy_lan;
-	else if ( !default_phy )
+	else if (!default_phy)
 		default_phy =3D sis_priv->first_mii;
=20
-	if( sis_priv->mii !=3D default_phy ){
+	if (sis_priv->mii !=3D default_phy) {
 		sis_priv->mii =3D default_phy;
 		sis_priv->cur_phy =3D default_phy->phy_addr;
-		printk(KERN_INFO "%s: Using transceiver found at address %d as default\n=
", net_dev->name,sis_priv->cur_phy);
+		printk(KERN_INFO "%s: Using transceiver found at address %d as default\n=
",
+					net_dev->name,sis_priv->cur_phy);
 	}
 =09
 	status =3D mdio_read(net_dev, sis_priv->cur_phy, MII_CONTROL);
@@ -702,7 +711,7 @@
  *	mii status register. It's necessary before auto-negotiate.
  */
 =20
-static void sis900_set_capability( struct net_device *net_dev , struct mii=
_phy *phy )
+static void sis900_set_capability(struct net_device *net_dev, struct mii_p=
hy *phy)
 {
 	u16 cap;
 	u16 status;
@@ -852,7 +861,8 @@
  *	please see SiS7014 or ICS spec
  */
=20
-static void mdio_write(struct net_device *net_dev, int phy_id, int locatio=
n, int value)
+static void mdio_write(struct net_device *net_dev, int phy_id, int locatio=
n,
+			int value)
 {
 	long mdio_addr =3D net_dev->base_addr + mear;
 	int mii_cmd =3D MIIwrite|(phy_id<<MIIpmdShift)|(location<<MIIregShift);
@@ -940,7 +950,8 @@
 	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
 	sis630_set_eq(net_dev, revision);
=20
-	ret =3D request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ, net_dev->n=
ame, net_dev);
+	ret =3D request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ,
+						net_dev->name, net_dev);
 	if (ret)
 		return ret;
=20
@@ -1137,48 +1148,55 @@
 		return;
=20
 	if (netif_carrier_ok(net_dev)) {
-		reg14h=3Dmdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
-		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, (0x2200 | reg14h) & 0xB=
FFF);
+		reg14h =3D mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
+		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
+					(0x2200 | reg14h) & 0xBFFF);
 		for (i=3D0; i < maxcount; i++) {
-			eq_value=3D(0x00F8 & mdio_read(net_dev, sis_priv->cur_phy, MII_RESV)) >=
> 3;
+			eq_value =3D (0x00F8 & mdio_read(net_dev,
+					sis_priv->cur_phy, MII_RESV)) >> 3;
 			if (i =3D=3D 0)
 				max_value=3Dmin_value=3Deq_value;
-			max_value=3D(eq_value > max_value) ? eq_value : max_value;
-			min_value=3D(eq_value < min_value) ? eq_value : min_value;
+			max_value =3D (eq_value > max_value) ?
+						eq_value : max_value;
+			min_value =3D (eq_value < min_value) ?
+						eq_value : min_value;
 		}
 		/* 630E rule to determine the equalizer value */
 		if (revision =3D=3D SIS630E_900_REV || revision =3D=3D SIS630EA1_900_REV=
 ||
 		    revision =3D=3D SIS630ET_900_REV) {
 			if (max_value < 5)
-				eq_value=3Dmax_value;
+				eq_value =3D max_value;
 			else if (max_value >=3D 5 && max_value < 15)
-				eq_value=3D(max_value =3D=3D min_value) ? max_value+2 : max_value+1;
+				eq_value =3D (max_value =3D=3D min_value) ?
+						max_value+2 : max_value+1;
 			else if (max_value >=3D 15)
-				eq_value=3D(max_value =3D=3D min_value) ? max_value+6 : max_value+5;
+				eq_value=3D(max_value =3D=3D min_value) ?
+						max_value+6 : max_value+5;
 		}
 		/* 630B0&B1 rule to determine the equalizer value */
 		if (revision =3D=3D SIS630A_900_REV &&=20
 		    (sis_priv->host_bridge_rev =3D=3D SIS630B0 ||=20
 		     sis_priv->host_bridge_rev =3D=3D SIS630B1)) {
 			if (max_value =3D=3D 0)
-				eq_value=3D3;
+				eq_value =3D 3;
 			else
-				eq_value=3D(max_value+min_value+1)/2;
+				eq_value =3D (max_value + min_value + 1)/2;
 		}
 		/* write equalizer value and setting */
-		reg14h=3Dmdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
-		reg14h=3D(reg14h & 0xFF07) | ((eq_value << 3) & 0x00F8);
-		reg14h=3D(reg14h | 0x6000) & 0xFDFF;
+		reg14h =3D mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
+		reg14h =3D (reg14h & 0xFF07) | ((eq_value << 3) & 0x00F8);
+		reg14h =3D (reg14h | 0x6000) & 0xFDFF;
 		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, reg14h);
-	}
-	else {
-		reg14h=3Dmdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
+	} else {
+		reg14h =3D mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
 		if (revision =3D=3D SIS630A_900_REV &&=20
 		    (sis_priv->host_bridge_rev =3D=3D SIS630B0 ||=20
 		     sis_priv->host_bridge_rev =3D=3D SIS630B1))=20
-			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, (reg14h | 0x2200) & 0x=
BFFF);
+			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
+						(reg14h | 0x2200) & 0xBFFF);
 		else
-			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, (reg14h | 0x2000) & 0x=
BFFF);
+			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
+						(reg14h | 0x2000) & 0xBFFF);
 	}
 	return;
 }
@@ -1206,7 +1224,8 @@
 		sis900_read_mode(net_dev, &speed, &duplex);
 		if (duplex){
 			sis900_set_mode(net_dev->base_addr, speed, duplex);
-			pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
+			pci_read_config_byte(sis_priv->pci_dev,
+						PCI_CLASS_REVISION, &revision);
 			sis630_set_eq(net_dev, revision);
 			netif_start_queue(net_dev);
 		}
@@ -1230,9 +1249,8 @@
 			sis900_check_mode(net_dev, mii_phy);
 			netif_carrier_on(net_dev);
 		}
-	}
+	} else {
 	/* Link ON -> OFF */
-	else {
                 if (!(status & MII_STAT_LINK)){
                 	netif_carrier_off(net_dev);
                 	printk(KERN_INFO "%s: Media Link Off\n", net_dev->name);
@@ -1242,7 +1260,8 @@
 			    ((mii_phy->phy_id1 & 0xFFF0) =3D=3D 0x8000))
                			sis900_reset_phy(net_dev,  sis_priv->cur_phy);
  =20
-                	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISIO=
N, &revision);
+                	pci_read_config_byte(sis_priv->pci_dev,
+					PCI_CLASS_REVISION, &revision);
 			sis630_set_eq(net_dev, revision);
  =20
                 	goto LookForLink;
@@ -1265,18 +1284,18 @@
  *	and autong_complete should be set to 1.
  */
=20
-static void sis900_check_mode (struct net_device *net_dev, struct mii_phy =
*mii_phy)
+static void sis900_check_mode(struct net_device *net_dev, struct mii_phy *=
mii_phy)
 {
 	struct sis900_private *sis_priv =3D net_dev->priv;
 	long ioaddr =3D net_dev->base_addr;
 	int speed, duplex;
=20
-	if( mii_phy->phy_types =3D=3D LAN  ){
-		outl( ~EXD & inl( ioaddr + cfg ), ioaddr + cfg);
+	if (mii_phy->phy_types =3D=3D LAN) {
+		outl(~EXD & inl(ioaddr + cfg), ioaddr + cfg);
 		sis900_set_capability(net_dev , mii_phy);
 		sis900_auto_negotiate(net_dev, sis_priv->cur_phy);
-	}else{
-		outl(EXD | inl( ioaddr + cfg ), ioaddr + cfg);
+	} else {
+		outl(EXD | inl(ioaddr + cfg), ioaddr + cfg);
 		speed =3D HW_SPEED_HOME;
 		duplex =3D FDX_CAPABLE_HALF_SELECTED;
 		sis900_set_mode(ioaddr, speed, duplex);
@@ -1301,20 +1320,20 @@
 {
 	u32 tx_flags =3D 0, rx_flags =3D 0;
=20
-	if( inl(ioaddr + cfg) & EDB_MASTER_EN ){
-		tx_flags =3D TxATP | (DMA_BURST_64 << TxMXDMA_shift) | (TX_FILL_THRESH <=
< TxFILLT_shift);
+	if (inl(ioaddr + cfg) & EDB_MASTER_EN) {
+		tx_flags =3D TxATP | (DMA_BURST_64 << TxMXDMA_shift) |
+					(TX_FILL_THRESH << TxFILLT_shift);
 		rx_flags =3D DMA_BURST_64 << RxMXDMA_shift;
-	}
-	else{
-		tx_flags =3D TxATP | (DMA_BURST_512 << TxMXDMA_shift) | (TX_FILL_THRESH =
<< TxFILLT_shift);
+	} else {
+		tx_flags =3D TxATP | (DMA_BURST_512 << TxMXDMA_shift) |
+					(TX_FILL_THRESH << TxFILLT_shift);
 		rx_flags =3D DMA_BURST_512 << RxMXDMA_shift;
 	}
=20
-	if (speed =3D=3D HW_SPEED_HOME || speed =3D=3D HW_SPEED_10_MBPS ) {
+	if (speed =3D=3D HW_SPEED_HOME || speed =3D=3D HW_SPEED_10_MBPS) {
 		rx_flags |=3D (RxDRNT_10 << RxDRNT_shift);
 		tx_flags |=3D (TxDRNT_10 << TxDRNT_shift);
-	}
-	else {
+	} else {
 		rx_flags |=3D (RxDRNT_100 << RxDRNT_shift);
 		tx_flags |=3D (TxDRNT_100 << TxDRNT_shift);
 	}
@@ -1404,19 +1423,19 @@
 	sis_priv->autong_complete =3D 1;
=20
 	/* Workaround for Realtek RTL8201 PHY issue */
-	if((phy->phy_id0 =3D=3D 0x0000) && ((phy->phy_id1 & 0xFFF0) =3D=3D 0x8200=
)){
-		if(mdio_read(net_dev, phy_addr, MII_CONTROL) & MII_CNTL_FDX)
+	if ((phy->phy_id0 =3D=3D 0x0000) && ((phy->phy_id1 & 0xFFF0) =3D=3D 0x820=
0)) {
+		if (mdio_read(net_dev, phy_addr, MII_CONTROL) & MII_CNTL_FDX)
 			*duplex =3D FDX_CAPABLE_FULL_SELECTED;
-		if(mdio_read(net_dev, phy_addr, 0x0019) & 0x01)
+		if (mdio_read(net_dev, phy_addr, 0x0019) & 0x01)
 			*speed =3D HW_SPEED_100_MBPS;
 	}
=20
 	printk(KERN_INFO "%s: Media Link On %s %s-duplex \n",
-	       net_dev->name,
-	       *speed =3D=3D HW_SPEED_100_MBPS ?
-	       "100mbps" : "10mbps",
-	       *duplex =3D=3D FDX_CAPABLE_FULL_SELECTED ?
-	       "full" : "half");
+	       				net_dev->name,
+	       				*speed =3D=3D HW_SPEED_100_MBPS ?
+	       					"100mbps" : "10mbps",
+	       				*duplex =3D=3D FDX_CAPABLE_FULL_SELECTED ?
+	       					"full" : "half");
 }
=20
 /**
@@ -1678,13 +1697,13 @@
 			sis_priv->stats.rx_bytes +=3D rx_size;
 			sis_priv->stats.rx_packets++;
=20
-			/* refill the Rx buffer, what if there is not enought memory for
-			   new socket buffer ?? */
+			/* refill the Rx buffer, what if there is not enought
+			 * memory for new socket buffer ?? */
 			if ((skb =3D dev_alloc_skb(RX_BUF_SIZE)) =3D=3D NULL) {
-				/* not enough memory for skbuff, this makes a "hole"
-				   on the buffer ring, it is not clear how the
-				   hardware will react to this kind of degenerated
-				   buffer */
+				/* not enough memory for skbuff, this makes a
+				 * "hole" on the buffer ring, it is not clear
+				 * how the hardware will react to this kind
+				 * of degenerated buffer */
 				printk(KERN_INFO "%s: Memory squeeze,"
 				       "deferring packet.\n",
 				       net_dev->name);
@@ -1708,8 +1727,8 @@
 		rx_status =3D sis_priv->rx_ring[entry].cmdsts;
 	} // while
=20
-	/* refill the Rx buffer, what if the rate of refilling is slower than=20
-	   consuming ?? */
+	/* refill the Rx buffer, what if the rate of refilling is slower
+	 * than consuming ?? */
 	for (;sis_priv->cur_rx - sis_priv->dirty_rx > 0; sis_priv->dirty_rx++) {
 		struct sk_buff *skb;
=20
@@ -1717,10 +1736,10 @@
=20
 		if (sis_priv->rx_skbuff[entry] =3D=3D NULL) {
 			if ((skb =3D dev_alloc_skb(RX_BUF_SIZE)) =3D=3D NULL) {
-				/* not enough memory for skbuff, this makes a "hole"
-				   on the buffer ring, it is not clear how the=20
-				   hardware will react to this kind of degenerated=20
-				   buffer */
+				/* not enough memory for skbuff, this makes a
+				 * "hole" on the buffer ring, it is not clear
+				 * how the hardware will react to this kind
+				 * of degenerated buffer */
 				printk(KERN_INFO "%s: Memory squeeze,"
 				       "deferring packet.\n",
 				       net_dev->name);
@@ -1765,8 +1784,8 @@
=20
 		if (tx_status & OWN) {
 			/* The packet is not transmitted yet (owned by hardware) !
-			   Note: the interrupt is generated only when Tx Machine
-			   is idle, so this is an almost impossible case */
+			 * Note: the interrupt is generated only when Tx Machine
+			 * is idle, so this is an almost impossible case */
 			break;
 		}
=20
@@ -1804,8 +1823,8 @@
=20
 	if (sis_priv->tx_full && netif_queue_stopped(net_dev) &&
 	    sis_priv->cur_tx - sis_priv->dirty_tx < NUM_TX_DESC - 4) {
-		/* The ring is no longer full, clear tx_full and schedule more transmiss=
ion
-		   by netif_wake_queue(net_dev) */
+		/* The ring is no longer full, clear tx_full and schedule
+		 * more transmission by netif_wake_queue(net_dev) */
 		sis_priv->tx_full =3D 0;
 		netif_wake_queue (net_dev);
 	}
@@ -1819,8 +1838,7 @@
  *	free Tx and RX socket buffer
  */
=20
-static int
-sis900_close(struct net_device *net_dev)
+static int sis900_close(struct net_device *net_dev)
 {
 	long ioaddr =3D net_dev->base_addr;
 	struct sis900_private *sis_priv =3D net_dev->priv;
@@ -1956,27 +1974,28 @@
=20
 	if ((map->port !=3D (u_char)(-1)) && (map->port !=3D dev->if_port)) {
 		/* we switch on the ifmap->port field. I couldn't find anything
-		   like a definition or standard for the values of that field.
-		   I think the meaning of those values is device specific. But
-		   since I would like to change the media type via the ifconfig
-		   command I use the definition from linux/netdevice.h=20
-		   (which seems to be different from the ifport(pcmcia) definition)=20
-		*/
+		 * like a definition or standard for the values of that field.
+		 * I think the meaning of those values is device specific. But
+		 * since I would like to change the media type via the ifconfig
+		 * command I use the definition from linux/netdevice.h=20
+		 * (which seems to be different from the ifport(pcmcia) definition) */
 		switch(map->port){
 		case IF_PORT_UNKNOWN: /* use auto here */  =20
 			dev->if_port =3D map->port;
-			/* we are going to change the media type, so the Link will
-			   be temporary down and we need to reflect that here. When
-			   the Link comes up again, it will be sensed by the sis_timer
-			   procedure, which also does all the rest for us */
+			/* we are going to change the media type, so the Link
+			 * will be temporary down and we need to reflect that
+			 * here. When the Link comes up again, it will be
+			 * sensed by the sis_timer procedure, which also does
+			 * all the rest for us */
 			netif_carrier_off(dev);
                =20
 			/* read current state */
 			status =3D mdio_read(dev, mii_phy->phy_addr, MII_CONTROL);
                =20
 			/* enable auto negotiation and reset the negotioation
-			   (I don't really know what the auto negatiotiation reset
-			   really means, but it sounds for me right to do one here)*/
+			 * (I don't really know what the auto negatiotiation
+			 * reset really means, but it sounds for me right to
+			 * do one here) */
 			mdio_write(dev, mii_phy->phy_addr,
 				   MII_CONTROL, status | MII_CNTL_AUTO | MII_CNTL_RST_AUTO);
=20
@@ -1985,10 +2004,11 @@
 		case IF_PORT_10BASET: /* 10BaseT */        =20
 			dev->if_port =3D map->port;
                =20
-			/* we are going to change the media type, so the Link will
-			   be temporary down and we need to reflect that here. When
-			   the Link comes up again, it will be sensed by the sis_timer
-			   procedure, which also does all the rest for us */
+			/* we are going to change the media type, so the Link
+			 * will be temporary down and we need to reflect that
+			 * here. When the Link comes up again, it will be
+			 * sensed by the sis_timer procedure, which also does
+			 * all the rest for us */
 			netif_carrier_off(dev);
        =20
 			/* set Speed to 10Mbps */
@@ -1997,24 +2017,27 @@
                =20
 			/* disable auto negotiation and force 10MBit mode*/
 			mdio_write(dev, mii_phy->phy_addr,
-				   MII_CONTROL, status & ~(MII_CNTL_SPEED | MII_CNTL_AUTO));
+				   MII_CONTROL, status & ~(MII_CNTL_SPEED |
+					MII_CNTL_AUTO));
 			break;
            =20
 		case IF_PORT_100BASET: /* 100BaseT */
 		case IF_PORT_100BASETX: /* 100BaseTx */=20
 			dev->if_port =3D map->port;
                =20
-			/* we are going to change the media type, so the Link will
-			   be temporary down and we need to reflect that here. When
-			   the Link comes up again, it will be sensed by the sis_timer
-			   procedure, which also does all the rest for us */
+			/* we are going to change the media type, so the Link
+			 * will be temporary down and we need to reflect that
+			 * here. When the Link comes up again, it will be
+			 * sensed by the sis_timer procedure, which also does
+			 * all the rest for us */
 			netif_carrier_off(dev);
                =20
 			/* set Speed to 100Mbps */
 			/* disable auto negotiation and enable 100MBit Mode */
 			status =3D mdio_read(dev, mii_phy->phy_addr, MII_CONTROL);
 			mdio_write(dev, mii_phy->phy_addr,
-				   MII_CONTROL, (status & ~MII_CNTL_SPEED) | MII_CNTL_SPEED);
+				   MII_CONTROL, (status & ~MII_CNTL_SPEED) |
+				   MII_CNTL_SPEED);
                =20
 			break;
            =20
@@ -2094,12 +2117,14 @@
 		for (i =3D 0; i < table_entries; i++)
 			mc_filter[i] =3D 0xffff;
 	} else {
-		/* Accept Broadcast packet, destination address matchs our MAC address,
-		   use Receive Filter to reject unwanted MCAST packet */
+		/* Accept Broadcast packet, destination address matchs our
+		 * MAC address, use Receive Filter to reject unwanted MCAST
+		 * packets */
 		struct dev_mc_list *mclist;
 		rx_mode =3D RFAAB;
-		for (i =3D 0, mclist =3D net_dev->mc_list; mclist && i < net_dev->mc_cou=
nt;
-		     i++, mclist =3D mclist->next) {
+		for (i =3D 0, mclist =3D net_dev->mc_list;
+			mclist && i < net_dev->mc_count;
+			i++, mclist =3D mclist->next) {
 			unsigned int bit_nr =3D
 				sis900_mcast_bitnr(mclist->dmi_addr, revision);
 			mc_filter[bit_nr >> 4] |=3D (1 << (bit_nr & 0xf));
@@ -2115,7 +2140,8 @@
=20
 	outl(RFEN | rx_mode, ioaddr + rfcr);
=20
-	/* sis900 is capatable of looping back packet at MAC level for debugging =
purpose */
+	/* sis900 is capable of looping back packets at MAC level for
+	 * debugging purpose */
 	if (net_dev->flags & IFF_LOOPBACK) {
 		u32 cr_saved;
 		/* We must disable Tx/Rx before setting loopback mode */

--/unnNtmY43mpUSKx--

--OZkY3AIuv2LYvjdk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBMbJG2rmHZCWzV+0RAuhLAJ4mZXrCsXCLS7W59xc+gwS6ZCXedwCfUTGw
3srm3J7GDYH4ernEYLvEnR8=
=BgTL
-----END PGP SIGNATURE-----

--OZkY3AIuv2LYvjdk--
