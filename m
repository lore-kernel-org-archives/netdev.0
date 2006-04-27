From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 32/32] rt2x00: misc fixes
Date: Fri, 28 Apr 2006 00:03:21 +0200
Message-ID: <200604280003.22207.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart12199212.0s07qflUEH";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.186]:62573 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751805AbWD0WCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:22 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463967nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:21 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart12199212.0s07qflUEH
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Misc. small fixes. Add small comments,
remove unwanted whitespaces etc.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 22:05:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 22:06:22.000000000 +0200
@@ -1003,7 +1003,7 @@ rt2400pci_txdone(void *data)
 	int			tx_status;
 	int			ack;
=20
=2D	 while (!rt2x00_ring_empty(ring)) {
+	while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
 		txd =3D entry->desc_addr;
=20
@@ -1212,7 +1212,7 @@ rt2400pci_free_ring(struct rt2x00_pci *r
 			ring->data_addr, ring->data_dma);
 	ring->data_addr =3D NULL;
=20
=2D		kfree(ring->entry);
+	kfree(ring->entry);
 	ring->entry =3D NULL;
 }
=20
@@ -1318,6 +1318,9 @@ rt2400pci_init_rings(struct rt2x00_pci *
 {
 	u32		reg;
=20
+	/*
+	 * Initialize rings.
+	 */
 	rt2400pci_init_rxdesc(rt2x00pci, &rt2x00pci->ring[RING_RX]);
 	rt2400pci_init_txdesc(rt2x00pci, &rt2x00pci->ring[RING_TX]);
 	rt2400pci_init_txdesc(rt2x00pci, &rt2x00pci->ring[RING_ATIM]);
@@ -1847,7 +1850,7 @@ rt2400pci_config_interface(struct net_de
 	rt2400pci_config_bssid(rt2x00pci, conf->bssid);
=20
 	return 0;
=2D }
+}
=20
 static void
 rt2400pci_set_multicast_list(struct net_device *net_dev,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 22:05:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 22:06:22.000000000 +0200
@@ -487,7 +487,7 @@ rt2500pci_config_channel(struct rt2x00_p
=20
 	if (rt2x00_rf(&rt2x00pci->chip, RF5222)) {
 		if (channel < 14) {
=2D		rf1 =3D cpu_to_le32(0x00022020);
+			rf1 =3D cpu_to_le32(0x00022020);
 			rf4 =3D cpu_to_le32(0x00000a0b);
 		} else if (channel =3D=3D 14) {
 			rf1 =3D cpu_to_le32(0x00022010);
@@ -501,7 +501,7 @@ rt2500pci_config_channel(struct rt2x00_p
 		} else if (channel < 161) {
 			rf1 =3D cpu_to_le32(0x00022020);
 			rf4 =3D cpu_to_le32(0x00000a07);
=2D	}
+		}
 	}
=20
 	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
@@ -1091,7 +1091,7 @@ rt2500pci_txdone(void *data)
 	int			tx_status;
 	int			ack;
=20
=2D	 while (!rt2x00_ring_empty(ring)) {
+	while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
 		txd =3D entry->desc_addr;
=20
@@ -1301,7 +1301,7 @@ rt2500pci_free_ring(struct rt2x00_pci *r
 			ring->data_addr, ring->data_dma);
 	ring->data_addr =3D NULL;
=20
=2D		kfree(ring->entry);
+	kfree(ring->entry);
 	ring->entry =3D NULL;
 }
=20
@@ -2438,7 +2438,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
 			channels[counter].val =3D
 				cpu_to_le32(vals[counter] | rf2_base);
=2D		}
+	}
 	if (rt2x00_rf(&rt2x00pci->chip, RF5222)) {
 		static u32 vals[] =3D {
 			0x00018896, 0x0001889a, 0x0001889e, 0x000188a2,
@@ -2453,7 +2453,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 =09
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
 			(chan++)->val =3D cpu_to_le32(vals[counter]);
=2D		}
+	}
=20
 	/*
 	 * Set TX power, each EEPROM TXpower entry
@@ -2472,7 +2472,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2);
 		if (channels[(counter * 2) + 1].power_level > 0x20)
 			channels[(counter * 2) + 1].power_level =3D 0x18;
=2D		}
+	}
=20
 	/*
 	 * Set device specific, but channel independent RF values.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 22:05:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 22:08:38.000000000 +0200
@@ -335,7 +335,7 @@ rt2500usb_config_channel(struct rt2x00_u
 	|| rt2x00_rf(&rt2x00usb->chip, RF2524)
 	|| rt2x00_rf(&rt2x00usb->chip, RF2525))
 	&& channel =3D=3D 14)
=2D			rf4 &=3D ~0x00000018;
+		rf4 &=3D ~0x00000018;
=20
 	if (rt2x00_rf(&rt2x00usb->chip, RF2525E)) {
 		if (channel & 0x01)
@@ -951,7 +951,7 @@ rt2500usb_txdone(void *data)
 		 * Check if we have received an
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
=2D		*/
+		 */
 		entry->tx_status.ack =3D 0;
 		if (ack && (entry->urb->status =3D=3D TX_SUCCESS))
 			entry->tx_status.ack =3D 1;
@@ -1636,7 +1636,7 @@ rt2500usb_config_interface(struct net_de
 		return 0;
=20
 	rt2500usb_config_bssid(rt2x00usb, conf->bssid);
=2D=20
+
 	return 0;
 }
=20
@@ -2071,12 +2071,12 @@ rt2500usb_init_hw_channels(struct rt2x00
=20
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
 			channels[counter].val =3D vals[counter];
=2D		}
+	}
=20
 		/*
 	 * Set TX power, each EEPROM TXpower entry
 	 * contains the TXpower value for 2 channels.
=2D		 */
+	 */
 	for (counter =3D 0; counter < EEPROM_TXPOWER_SIZE; counter++) {
 		rt2x00_eeprom_read(rt2x00usb,
 			EEPROM_TXPOWER_START + counter, &eeprom);
@@ -2090,7 +2090,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2);
 		if (channels[(counter * 2) + 1].power_level > 0x20)
 			channels[(counter * 2) + 1].power_level =3D 0x18;
=2D		}
+	}
=20
 	/*
 	 * Set device specific, but channel independent RF values.
@@ -2302,7 +2302,6 @@ rt2500usb_init_hw(struct rt2x00_usb *rt2
 	hw->modes[0].num_channels =3D 14;
 	hw->modes[0].num_rates =3D 12;
=20
=2D
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:57:18.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 22:07:42.000000000 +0200
@@ -44,6 +44,9 @@
  * and should be switched on using the module parameter.
  */
 #ifdef CONFIG_RT2X00_DEBUG
+/*
+ * Module parameter.
+ */
 static int rt2x00_debug_level =3D 0;
 #define DEBUG_PRINTK(__message...) \
 	do { if (rt2x00_debug_level) printk(__message); } while (0)

--nextPart12199212.0s07qflUEH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+qaqndE37Em0gRAoBiAJ4rSUaZOM3iG12Y5pvDJ+1RvXAUZACdF+tF
5kYvwyE2PFezG0EpDVXRao8=
=7f2L
-----END PGP SIGNATURE-----

--nextPart12199212.0s07qflUEH--
