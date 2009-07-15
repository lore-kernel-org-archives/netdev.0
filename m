From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: [PATCH 2/2] net/can: add module alias to can protocol drivers
Date: Wed, 15 Jul 2009 11:12:25 +0200
Message-ID: <19037.40313.827769.602243@ipc1.ka-ro>
References: <19028.16049.907160.45293@ipc1.ka-ro>
	<20090709154533.GA27413@gondor.apana.org.au>
	<19035.23045.386506.297464@ipc1.ka-ro>
	<4A5B730B.8090902@hartkopp.net>
	<19036.9400.263297.330963@ipc1.ka-ro>
	<4A5C990E.3080703@hartkopp.net>
	<19036.41388.634723.358236@ipc1.ka-ro>
	<4A5CC626.8020800@grandegger.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Wolfgang Grandegger <wg@grandegger.com>,
	urs.thuermann@volkswagen.de, Urs Thuermann <urs@isnogud.escape.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:65200 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473AbZGOJM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 05:12:28 -0400
In-Reply-To: <19037.40189.520170.8242@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add appropriate MODULE_ALIAS() to facilitate autoloading of can protoco=
l drivers

Signed-off-by: Lothar Wassmann <LW@KARO-electronics.de>
Acked-by: Oliver Hartkopp <oliver@hartkopp.net>
---
diff -ur linux-2.6.30/net/can/bcm.c linux-2.6.30-karo/net/can/bcm.c
--- linux-2.6.30-karo.orig/net/can/bcm.c	2009-07-15 10:58:51.000000000 =
+0200
+++ linux-2.6.30-karo/net/can/bcm.c	2009-07-14 13:48:52.000000000 +0200
@@ -75,6 +75,7 @@
 MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
+MODULE_ALIAS("can-proto-2");
=20
 /* easy access to can_frame payload */
 static inline u64 GET_U64(const struct can_frame *cp)
diff -ur linux-2.6.30/net/can/raw.c linux-2.6.30-karo/net/can/raw.c
--- linux-2.6.30-karo.orig/net/can/raw.c	2009-07-15 10:59:03.000000000 =
+0200
+++ linux-2.6.30-karo/net/can/raw.c	2009-07-14 13:48:52.000000000 +0200
@@ -62,6 +62,7 @@
 MODULE_DESCRIPTION("PF_CAN raw protocol");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
+MODULE_ALIAS("can-proto-1");
=20
 #define MASK_ALL 0
=20


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
