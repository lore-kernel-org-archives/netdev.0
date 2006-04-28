From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/6] rt2x00 update: Use static const for the vals arrays
Date: Fri, 28 Apr 2006 16:52:27 +0200
Message-ID: <200604281652.27841.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1239706.PYmrTxuhLP";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:12768 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S965218AbWD1Ov0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:51:26 -0400
Received: by nproxy.gmail.com with SMTP id x30so1507178nfb
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:51:25 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1239706.PYmrTxuhLP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Make the vals arrays static const.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-28 15:16:23.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-28 15:32:12.000000000 +0200
@@ -2229,7 +2229,7 @@ rt2400pci_init_hw_channels(struct rt2x00
 {
 	int				counter;
 	u16				eeprom;
=2D	static u32 vals[] =3D {
+	static const u32 vals[] =3D {
 		0x000c1fda, 0x000c1fee, 0x000c2002, 0x000c2016,
 		0x000c202a, 0x000c203e, 0x000c2052, 0x000c2066,
 		0x000c207a, 0x000c208e, 0x000c20a2, 0x000c20b6,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-28 15:16:23.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-28 15:32:31.000000000 +0200
@@ -2347,7 +2347,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 	int				counter;
 	u32				rf2_base;
 	u16				eeprom;
=2D	static struct {
+	static const struct {
 		unsigned int chip;
 		u32 val[3];
 	} rf[] =3D {
@@ -2404,7 +2404,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 		rf2_base =3D 0x00080000;
=20
 	if (rt2x00_rf(&rt2x00pci->chip, RF2522)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x000c1fda, 0x000c1fee, 0x000c2002, 0x000c2016,
 			0x000c202a, 0x000c203e, 0x000c2052, 0x000c2066,
 			0x000c207a, 0x000c208e, 0x000c20a2, 0x000c20b6,
@@ -2416,7 +2416,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 	} else if (rt2x00_rf(&rt2x00pci->chip, RF2523)
 	|| rt2x00_rf(&rt2x00pci->chip, RF2524)
 	|| rt2x00_rf(&rt2x00pci->chip, RF2525)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x00000c9e, 0x00000ca2, 0x00000ca6, 0x00000caa,
 			0x00000cae, 0x00000cb2, 0x00000cb6, 0x00000cba,
 			0x00000cbe, 0x00000d02, 0x00000d06, 0x00000d0a,
@@ -2428,7 +2428,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 				cpu_to_le32(vals[counter] | rf2_base);
 	} else if (rt2x00_rf(&rt2x00pci->chip, RF2525E)
 	|| rt2x00_rf(&rt2x00pci->chip, RF5222)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x00001136, 0x0000113a, 0x0000113e, 0x00001182,
 			0x00001186, 0x0000118a, 0x0000118e, 0x00001192,
 			0x00001196, 0x0000119a, 0x0000119e, 0x000011a2,
@@ -2440,7 +2440,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 				cpu_to_le32(vals[counter] | rf2_base);
 	}
 	if (rt2x00_rf(&rt2x00pci->chip, RF5222)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x00018896, 0x0001889a, 0x0001889e, 0x000188a2,
 			0x000188a6, 0x000188aa, 0x000188ae, 0x000188b2,
 			0x00008802, 0x00008806, 0x0000880a, 0x0000880e,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-28 15:16:22.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-28 15:32:06.000000000 +0200
@@ -1968,7 +1968,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 	int				counter;
 	u32				rf2_base;
 	u16				eeprom;
=2D	static struct {
+	static const struct {
 		unsigned int chip;
 		u32 val[3];
 	} rf[] =3D {
@@ -2024,7 +2024,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		rf2_base =3D 0x00080000;
=20
 	if (rt2x00_rf(&rt2x00usb->chip, RF2522)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x000c1fda, 0x000c1fee, 0x000c2002, 0x000c2016,
 			0x000c202a, 0x000c203e, 0x000c2052, 0x000c2066,
 			0x000c207a, 0x000c208e, 0x000c20a2, 0x000c20b6,
@@ -2036,7 +2036,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF2523)
 	|| rt2x00_rf(&rt2x00usb->chip, RF2524)
 	|| rt2x00_rf(&rt2x00usb->chip, RF2525)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x00000c9e, 0x00000ca2, 0x00000ca6, 0x00000caa,
 			0x00000cae, 0x00000cb2, 0x00000cb6, 0x00000cba,
 			0x00000cbe, 0x00000d02, 0x00000d06, 0x00000d0a,
@@ -2046,7 +2046,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
 			channels[counter].val =3D vals[counter] | rf2_base;
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF2525E)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x0000089a, 0x0000089e, 0x0000089e, 0x000008a2,
 			0x000008a2, 0x000008a6, 0x000008a6, 0x000008aa,
 			0x000008aa, 0x000008ae, 0x000008ae, 0x000008b2,
@@ -2056,7 +2056,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
 			channels[counter].val =3D vals[counter];
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF5222)) {
=2D		static u32 vals[] =3D {
+		static const u32 vals[] =3D {
 			0x00001136, 0x0000113a, 0x0000113e, 0x00001182,
 			0x00001186, 0x0000118a, 0x0000118e, 0x00001192,
 			0x00001196, 0x0000119a, 0x0000119e, 0x000011a2,

--nextPart1239706.PYmrTxuhLP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiwraqndE37Em0gRAq/3AJ9p/V3oARb+zDXQtvvclODd1c6O2QCfaaKO
fdVD8vYfUX71BjAAJOqDEEs=
=YorP
-----END PGP SIGNATURE-----

--nextPart1239706.PYmrTxuhLP--
