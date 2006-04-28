From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 4/6] rt2x00 update: Remove packed attributes for structures that don't need it
Date: Fri, 28 Apr 2006 16:52:28 +0200
Message-ID: <200604281652.28468.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4518607.oTbeSyGL4a";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.189]:26336 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S965219AbWD1Ov1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:51:27 -0400
Received: by nproxy.gmail.com with SMTP id n29so1594535nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:51:26 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4518607.oTbeSyGL4a
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Remove __attribute__ ((packed)) for structures that
are not being send to the device.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-28 15:09:53.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-28 15:50:06.000000000 +0200
@@ -324,12 +324,12 @@ extern int error_bitrange_bad;
 struct rt2x00_field16{
 	u16	bit_offset;
 	u16	bit_mask;
=2D} __attribute__ ((packed));
+};
=20
 struct rt2x00_field32{
 	u32	bit_offset;
 	u32	bit_mask;
=2D} __attribute__ ((packed));
+};
=20
 /*
  * Before intitializing the rt2x00_field# structures,
@@ -430,7 +430,7 @@ rt2x00_get_field16_nb(const u16 reg, con
 struct _rt2x00_chip{
 	u16				rt;
 	u16				rf;
=2D} __attribute__ ((packed));
+};
=20
 /*
  * Set chipset data.
@@ -511,7 +511,7 @@ struct data_ring{
 	 */
 	u16					data_size;
 	u16					desc_size;
=2D} __attribute__ ((packed));
+};
=20
 /*
  * Handlers to determine the address of the current device specific
@@ -612,7 +612,7 @@ struct scanning{
 	short					status;
 #define SCANNING_READY				0x0001
 #define SCANNING_CANCELLED			0x0002
=2D} __attribute__ ((packed));
+};
=20
=20
 /*
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	20=
06-04-28 15:09:45.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00pci.=
h	2006-04-28 15:49:18.000000000 +0200
@@ -72,7 +72,7 @@ struct rt2x00_button{
 	short					button_status:1;
 	short					active_poll:1;
 	short					__pad:14;
=2D} __attribute__ ((packed));
+};
 #endif /* CONFIG_RT2X00_BUTTON */
=20
 /*
@@ -106,7 +106,7 @@ struct data_entry{
 	 */
 	void				*data_addr;
 	dma_addr_t			data_dma;
=2D} __attribute__ ((packed));
+};
=20
 /*
  * Device specific structure.
@@ -231,7 +231,7 @@ struct rt2x00_pci{
 	 * after that the beacon and RX ring follow.
 	 */
 	struct data_ring			*ring;
=2D} __attribute__ ((packed));
+};
=20
 static inline struct data_ring*
 rt2x00pci_get_ring(struct rt2x00_pci *rt2x00pci, const int ring)
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	20=
06-04-28 15:09:44.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00usb.=
h	2006-04-28 15:49:31.000000000 +0200
@@ -85,7 +85,7 @@ struct data_entry{
 	 */
 	void				*data_addr;
 	dma_addr_t			data_dma;
=2D} __attribute__ ((packed));
+};
=20
 /*
  * The location of the descriptor is variating and depends
@@ -215,7 +215,7 @@ struct rt2x00_usb{
 	 * after that the beacon and RX ring follow.
 	 */
 	struct data_ring			*ring;
=2D} __attribute__ ((packed));
+};
=20
 static inline struct data_ring*
 rt2x00usb_get_ring(struct rt2x00_usb *rt2x00usb, const int ring)

--nextPart4518607.oTbeSyGL4a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiwsaqndE37Em0gRAmapAJ9lxREUBkB+WiHSrgqgC3OSq0dxywCgmajb
GHytALuXpcfeTJUjzwcMg4I=
=+vzC
-----END PGP SIGNATURE-----

--nextPart4518607.oTbeSyGL4a--
