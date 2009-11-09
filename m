From: Sven Anders <sven@anduras.de>
Subject: [PATCH] e1000e: Add new ID
Date: Mon, 09 Nov 2009 21:25:19 +0100
Message-ID: <4AF87AAF.2020508@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC70DAC593F24B1AC64A4EAA3"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:43417 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823AbZKIUZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 15:25:16 -0500
Received: from popper.anduras.office (p54918733.dip0.t-ipconnect.de [84.145.135.51])
	(Authenticated sender: anduras@anduras.priv)
	by metropolitan.anduras.de (Postfix) with ESMTP id 5D8691E543C
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 21:25:21 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by popper.anduras.office (Postfix) with ESMTP id DE8A62140A5
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 21:25:20 +0100 (CET)
Received: from popper.anduras.office ([127.0.0.1])
	by localhost (popper.anduras.office [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 11959-08 for <netdev@vger.kernel.org>;
	Mon, 9 Nov 2009 21:25:20 +0100 (CET)
Received: from [192.168.10.15] (suburban.anduras.office [10.10.20.242])
	by popper.anduras.office (Postfix) with ESMTP id 5D1C2214001
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 21:25:20 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC70DAC593F24B1AC64A4EAA3
Content-Type: multipart/mixed;
 boundary="------------070705000604020800030303"

This is a multi-part message in MIME format.
--------------070705000604020800030303
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello!

We use the the 82571EB (QUAD COPPER BP) with the e1000e driver.
We haven't experienced any problems yet.

The patch is trivial, just adding a new PCI ID...

Regards
 Sven Anders

--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstrasse 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Those who would give up essential Liberty, to purchase a little
temporary Safety, deserve neither Liberty nor Safety.
  - Benjamin Franklin

--------------070705000604020800030303
Content-Type: text/x-patch;
 name="e1000e-Add_ID_01A0.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="e1000e-Add_ID_01A0.patch"

--- linux-2.6.26.2/drivers/net/e1000e/hw.h.orig	2008-09-29 14:20:55.00000=
0000 +0200
+++ linux-2.6.26.2/drivers/net/e1000e/hw.h	2008-09-29 14:26:38.000000000 =
+0200
@@ -323,6 +323,7 @@
 #define E1000_DEV_ID_82571PT_QUAD_COPPER	0x10D5
 #define E1000_DEV_ID_82571EB_QUAD_FIBER		0x10A5
 #define E1000_DEV_ID_82571EB_QUAD_COPPER_LP	0x10BC
+#define E1000_DEV_ID_82571EB_QUAD_COPPER_BP	0x10A0
 #define E1000_DEV_ID_82571EB_SERDES_DUAL	0x10D9
 #define E1000_DEV_ID_82571EB_SERDES_QUAD	0x10DA
 #define E1000_DEV_ID_82572EI_COPPER		0x107D
--- linux-2.6.26.2/drivers/net/e1000e/netdev.c.orig	2008-09-29 14:27:01.0=
00000000 +0200
+++ linux-2.6.26.2/drivers/net/e1000e/netdev.c	2008-09-29 14:27:29.000000=
000 +0200
@@ -4560,6 +4560,7 @@
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER_LP), board_82571 =
},
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER_BP), board_82571 =
},
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_DUAL), board_82571 },
--- linux-2.6.26.2/drivers/net/e1000e/82571.c.orig	2008-09-29 14:27:42.00=
0000000 +0200
+++ linux-2.6.26.2/drivers/net/e1000e/82571.c	2008-09-29 14:28:04.0000000=
00 +0200
@@ -274,6 +274,7 @@
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LP:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER_BP:
 	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 		adapter->flags |=3D FLAG_IS_QUAD_PORT;
 		/* mark the first port */

--------------070705000604020800030303
Content-Type: text/x-vcard; charset=utf-8;
 name="sven.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="sven.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
adr;quoted-printable:;;Weidestra=3DC3=3D9Fe 19;Hannover;Niedersachsen;304=
53;Deutschland
email;internet:sven@anduras.de
tel;home:+49 (0)511 / 2123090
tel;cell:+49 (0)170 / 8091180
x-mozilla-html:FALSE
url:http://staff.anduras.de/anders
version:2.1
end:vcard


--------------070705000604020800030303--

--------------enigC70DAC593F24B1AC64A4EAA3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkr4eq8ACgkQ5lKZ7Feg4Eeh8QCgixJ5xbD+eeS84sPDtJkU9CyH
rhcAoJfkvs29LyStoYzRK8Y01Pn2oqmK
=8aMd
-----END PGP SIGNATURE-----

--------------enigC70DAC593F24B1AC64A4EAA3--
