From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/32] rt2x00: use enumerations
Date: Fri, 28 Apr 2006 00:02:50 +0200
Message-ID: <200604280002.51286.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1333986.trE16NyeyK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751777AbWD0WBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:43 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:43 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1333986.trE16NyeyK
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

The led_mode defines are equal in all drivers,
and should be placed in the common rt2x00.h header.
Make the led_mode, tx_status and dev_state defines
into enumerations.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	20=
06-04-27 00:52:56.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
h	2006-04-27 21:25:33.000000000 +0200
@@ -936,11 +936,6 @@ struct rt2x00_pci{
 	 * Led status
 	 */
 	u8					led_mode;
=2D#define LED_MODE_DEFAULT			0
=2D#define LED_MODE_TXRX_ACTIVITY 			1
=2D#define LED_MODE_SINGLE				2
=2D#define LED_MODE_ASUS				3
=2D#define LED_MODE_ALPHA				4
=20
 	/*
 	 * EEPROM BBP data.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-27 00:52:56.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
h	2006-04-27 21:25:33.000000000 +0200
@@ -1192,11 +1192,6 @@ struct rt2x00_pci{
 	 * Led status
 	 */
 	u8					led_mode;
=2D#define LED_MODE_DEFAULT			0
=2D#define LED_MODE_TXRX_ACTIVITY 			1
=2D#define LED_MODE_SINGLE				2
=2D#define LED_MODE_ASUS				3
=2D#define LED_MODE_ALPHA				4
=20
 	/*
 	 * EEPROM BBP data.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-27 00:52:56.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-27 21:25:33.000000000 +0200
@@ -691,11 +691,6 @@ struct rt2x00_usb{
 	 * Led status
 	 */
 	u8					led_mode;
=2D#define LED_MODE_DEFAULT			0
=2D#define LED_MODE_TXRX_ACTIVITY 			1
=2D#define LED_MODE_SINGLE				2
=2D#define LED_MODE_ASUS				3
=2D#define LED_MODE_ALPHA				4
=20
 	/*
 	 * EEPROM BBP data.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:23:26.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 21:25:33.000000000 +0200
@@ -96,11 +96,34 @@ static int rt2x00_debug_level =3D 0;
 /*
  * TX result flags.
  */
=2D#define TX_SUCCESS			0
=2D#define TX_SUCCESS_RETRY		1
=2D#define TX_FAIL_RETRY			2
=2D#define TX_FAIL_INVALID			3
=2D#define TX_FAIL_OTHER			4
+enum TX_STATUS {
+	TX_SUCCESS			=3D 0,
+	TX_SUCCESS_RETRY		=3D 1,
+	TX_FAIL_RETRY			=3D 2,
+	TX_FAIL_INVALID			=3D 3,
+	TX_FAIL_OTHER			=3D 4,
+};
+
+/*
+ * Led mode values.
+ */
+enum led_mode {
+	LED_MODE_DEFAULT		=3D 0,
+	LED_MODE_TXRX_ACTIVITY 		=3D 1,
+	LED_MODE_SIGNAL_STRENGTH	=3D 2,
+	LED_MODE_ASUS			=3D 3,
+	LED_MODE_ALPHA			=3D 4,
+};
+
+/*
+ * Device states
+ */
+enum dev_state {
+	STATE_DEEP_SLEEP		=3D 0,
+	STATE_SLEEP			=3D 1,
+	STATE_STANDBY			=3D 2,
+	STATE_AWAKE			=3D 3,
+};
=20
 /*
  * Macros for determining which is the lowest or highest bit

--nextPart1333986.trE16NyeyK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+LaqndE37Em0gRAnOlAJwJ5mskUk8FfcAXttUCgROMTXz+KgCgpE6h
U1nnt+D8J98e0cE8C2Ho18I=
=ty4S
-----END PGP SIGNATURE-----

--nextPart1333986.trE16NyeyK--
