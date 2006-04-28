From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 5/6] rt2x00 update: Apply correct endian annotation for structures that are DMA'ed to device.
Date: Fri, 28 Apr 2006 16:52:28 +0200
Message-ID: <200604281652.29040.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6593430.tnqShC799O";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:61151 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S965221AbWD1Ov1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:51:27 -0400
Received: by nproxy.gmail.com with SMTP id n29so1594528nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:51:27 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6593430.tnqShC799O
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Use __le32 annotations for all fields in the descriptor,
since these should always be treated as little endian.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	20=
06-04-28 15:09:48.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
h	2006-04-28 15:59:24.000000000 +0200
@@ -739,7 +739,7 @@
  * TX descriptor format for TX, PRIO, ATIM and Beacon Ring.
  */
 struct txd{
=2D	u32	word0;
+	__le32				word0;
 #define TXD_W0_OWNER_NIC		FIELD32(0x00000001)
 #define TXD_W0_VALID			FIELD32(0x00000002)
 #define TXD_W0_RESULT			FIELD32(0x0000001c)
@@ -753,32 +753,32 @@ struct txd{
 #define TXD_W0_AGC			FIELD32(0x00ff0000)
 #define TXD_W0_R2			FIELD32(0xff000000)
=20
=2D	u32	word1;
+	__le32				word1;
 #define TXD_W1_BUFFER_ADDRESS		FIELD32(0xffffffff)
=20
=2D	u32	word2;
+	__le32				word2;
 #define TXD_W2_BUFFER_LENGTH		FIELD32(0x0000ffff)
 #define TXD_W2_DATABYTE_COUNT		FIELD32(0xffff0000)
=20
=2D	u32	word3;
+	__le32				word3;
 #define TXD_W3_PLCP_SIGNAL		FIELD32(0x0000ffff)
 #define TXD_W3_PLCP_SERVICE		FIELD32(0xffff0000)
=20
=2D	u32	word4;
+	__le32				word4;
 #define TXD_W4_PLCP_LENGTH_LOW		FIELD32(0x0000ffff)
 #define TXD_W4_PLCP_LENGTH_HIGH		FIELD32(0xffff0000)
=20
=2D	u32	word5;
+	__le32				word5;
 #define TXD_W5_BBCR4			FIELD32(0x0000ffff)
 #define TXD_W5_AGC_REG			FIELD32(0x007f0000)
 #define TXD_W5_AGC_REG_VALID		FIELD32(0x00800000)
 #define TXD_W5_XXX_REG			FIELD32(0x7f000000)
 #define TXD_W5_XXX_REG_VALID		FIELD32(0x80000000)
=20
=2D	u32	word6;
+	__le32				word6;
 #define TXD_W6_SK_BUFF			FIELD32(0xffffffff)
=20
=2D	u32	word7;
+	__le32				word7;
 #define TXD_W7_RESERVED			FIELD32(0xffffffff)
 } __attribute__ ((packed));
=20
@@ -786,7 +786,7 @@ struct txd{
  * RX descriptor format for RX Ring.
  */
 struct rxd{
=2D	u32	word0;
+	__le32				word0;
 #define RXD_W0_OWNER_NIC		FIELD32(0x00000001)
 #define RXD_W0_UNICAST_TO_ME		FIELD32(0x00000002)
 #define RXD_W0_MULTICAST		FIELD32(0x00000004)
@@ -796,30 +796,30 @@ struct rxd{
 #define RXD_W0_PHYSICAL_ERROR		FIELD32(0x00000080)
 #define RXD_W0_DATABYTE_COUNT		FIELD32(0xffff0000)
=20
=2D	u32	word1;
+	__le32				word1;
 #define RXD_W1_BUFFER_ADDRESS		FIELD32(0xffffffff)
=20
=2D	u32	word2;
+	__le32				word2;
 #define RXD_W2_BUFFER_LENGTH		FIELD32(0x0000ffff)
 #define RXD_W2_BBR0			FIELD32(0x00ff0000)
 #define RXD_W2_RSSI			FIELD32(0xff000000)
=20
=2D	u32	word3;
+	__le32				word3;
 #define RXD_W3_BBR2			FIELD32(0x000000ff)
 #define RXD_W3_BBR3			FIELD32(0x0000ff00)
 #define RXD_W3_BBR4			FIELD32(0x00ff0000)
 #define RXD_W3_BBR5			FIELD32(0xff000000)
=20
=2D	u32	word4;
+	__le32				word4;
 #define RXD_W4_RX_END_TIME		FIELD32(0xffffffff)
=20
=2D	u32	word5;
+	__le32				word5;
 #define RXD_W5_RESERVED			FIELD32(0xffffffff)
=20
=2D	u32	word6;
+	__le32				word6;
 #define RXD_W6_RESERVED			FIELD32(0xffffffff)
=20
=2D	u32	word7;
+	__le32				word7;
 #define RXD_W7_RESERVED			FIELD32(0xffffffff)
 } __attribute__ ((packed));
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-28 15:09:48.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
h	2006-04-28 15:58:29.000000000 +0200
@@ -987,7 +987,7 @@
  * TX descriptor format for TX, PRIO, ATIM and Beacon Ring.
  */
 struct txd{
=2D	u32	word0;
+	__le32				word0;
 #define TXD_W0_OWNER_NIC		FIELD32(0x00000001)
 #define TXD_W0_VALID			FIELD32(0x00000002)
 #define TXD_W0_RESULT			FIELD32(0x0000001c)
@@ -1002,40 +1002,40 @@ struct txd{
 #define TXD_W0_DATABYTE_COUNT		FIELD32(0x0fff0000)
 #define TXD_W0_CIPHER_ALG		FIELD32(0xe0000000)
=20
=2D	u32	word1;
+	__le32				word1;
 #define TXD_W1_BUFFER_ADDRESS		FIELD32(0xffffffff)
=20
=2D	u32	word2;
+	u32				word2;
 #define TXD_W2_IV_OFFSET		FIELD32(0x0000003f)
 #define TXD_W2_AIFS			FIELD32(0x000000c0)
 #define TXD_W2_CWMIN			FIELD32(0x00000f00)
 #define TXD_W2_CWMAX			FIELD32(0x0000f000)
=20
=2D	u32	word3;
+	__le32				word3;
 #define TXD_W3_PLCP_SIGNAL		FIELD32(0x000000ff)
 #define TXD_W3_PLCP_SERVICE		FIELD32(0x0000ff00)
 #define TXD_W3_PLCP_LENGTH_LOW		FIELD32(0x00ff0000)
 #define TXD_W3_PLCP_LENGTH_HIGH		FIELD32(0xff000000)
=20
=2D	u32	word4;
+	__le32				word4;
 #define TXD_W4_IV			FIELD32(0xffffffff)
=20
=2D	u32	word5;
+	__le32				word5;
 #define TXD_W5_EIV			FIELD32(0xffffffff)
=20
=2D	u32	word6;
+	__le32				word6;
 #define TXD_W6_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word7;
+	__le32				word7;
 #define TXD_W7_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word8;
+	__le32				word8;
 #define TXD_W8_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word9;
+	__le32				word9;
 #define TXD_W9_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word10;
+	__le32				word10;
 #define TXD_W10_RTS			FIELD32(0x00000001)
 #define TXD_W10_TX_RATE			FIELD32(0x000000fe)
 } __attribute__ ((packed));
@@ -1044,7 +1044,7 @@ struct txd{
  * RX descriptor format for RX Ring.
  */
 struct rxd{
=2D	u32	word0;
+	__le32				word0;
 #define RXD_W0_OWNER_NIC		FIELD32(0x00000001)
 #define RXD_W0_UNICAST_TO_ME		FIELD32(0x00000002)
 #define RXD_W0_MULTICAST		FIELD32(0x00000004)
@@ -1059,36 +1059,36 @@ struct rxd{
 #define RXD_W0_DATABYTE_COUNT		FIELD32(0x0fff0000)
 #define RXD_W0_CIPHER_ALG		FIELD32(0xe0000000)
=20
=2D	u32	word1;
+	__le32				word1;
 #define RXD_W1_BUFFER_ADDRESS		FIELD32(0xffffffff)
=20
=2D	u32	word2;
+	__le32				word2;
 #define RXD_W2_BBR0			FIELD32(0x000000ff)
 #define RXD_W2_RSSI			FIELD32(0x0000ff00)
 #define RXD_W2_TA			FIELD32(0xffff0000)
=20
=2D	u32	word3;
+	__le32				word3;
 #define RXD_W3_TA			FIELD32(0xffffffff)
=20
=2D	u32	word4;
+	__le32				word4;
 #define RXD_W4_IV			FIELD32(0xffffffff)
=20
=2D	u32	word5;
+	__le32				word5;
 #define RXD_W5_EIV			FIELD32(0xffffffff)
=20
=2D	u32	word6;
+	__le32				word6;
 #define RXD_W6_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word7;
+	__le32				word7;
 #define RXD_W7_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word8;
+	__le32				word8;
 #define RXD_W8_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word9;
+	__le32				word9;
 #define RXD_W9_KEY			FIELD32(0xffffffff)
=20
=2D	u32	word10;
+	__le32				word10;
 #define RXD_W10_DROP			FIELD32(0x00000001)
 } __attribute__ ((packed));
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-28 15:09:48.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-28 15:58:57.000000000 +0200
@@ -553,7 +553,7 @@
  * TX descriptor format for TX, PRIO, ATIM and Beacon Ring.
  */
 struct txd{
=2D	u32	word0;
+	__le32				word0;
 #define TXD_W0_PACKET_ID		FIELD32(0x0000000f)
 #define TXD_W0_RETRY_LIMIT		FIELD32(0x000000f0)
 #define TXD_W0_MORE_FRAG		FIELD32(0x00000100)
@@ -566,22 +566,22 @@ struct txd{
 #define TXD_W0_CIPHER			FIELD32(0x20000000)
 #define TXD_W0_KEY_ID			FIELD32(0xc0000000)
=20
=2D	u32	word1;
+	__le32				word1;
 #define TXD_W1_IV_OFFSET		FIELD32(0x0000003f)
 #define TXD_W1_AIFS			FIELD32(0x000000c0)
 #define TXD_W1_CWMIN			FIELD32(0x00000f00)
 #define TXD_W1_CWMAX			FIELD32(0x0000f000)
=20
=2D	u32	word2;
+	__le32				word2;
 #define TXD_W2_PLCP_SIGNAL		FIELD32(0x000000ff)
 #define TXD_W2_PLCP_SERVICE		FIELD32(0x0000ff00)
 #define TXD_W2_PLCP_LENGTH_LOW		FIELD32(0x00ff0000)
 #define TXD_W2_PLCP_LENGTH_HIGH		FIELD32(0xff000000)
=20
=2D	u32	word3;
+	__le32				word3;
 #define TXD_W3_IV			FIELD32(0xffffffff)
=20
=2D	u32	word4;
+	__le32				word4;
 #define TXD_W4_EIV			FIELD32(0xffffffff)
 } __attribute__ ((packed));
=20
@@ -589,7 +589,7 @@ struct txd{
  * RX descriptor format for RX Ring.
  */
 struct rxd{
=2D	u32	word0;
+	__le32				word0;
 #define RXD_W0_UNICAST_TO_ME		FIELD32(0x00000002)
 #define RXD_W0_MULTICAST		FIELD32(0x00000004)
 #define RXD_W0_BROADCAST		FIELD32(0x00000008)
@@ -601,14 +601,14 @@ struct rxd{
 #define RXD_W0_CI_ERROR			FIELD32(0x00000200)
 #define RXD_W0_DATABYTE_COUNT		FIELD32(0x0fff0000)
=20
=2D	u32	word1;
+	__le32				word1;
 #define RXD_W1_SIGNAL			FIELD32(0x000000ff)
 #define RXD_W1_RSSI			FIELD32(0x0000ff00)
=20
=2D	u32	word2;
+	__le32				word2;
 #define RXD_W2_IV			FIELD32(0xffffffff)
=20
=2D	u32	word3;
+	__le32				word3;
 #define RXD_W3_EIV			FIELD32(0xffffffff)
 } __attribute__ ((packed));
=20

--nextPart6593430.tnqShC799O
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiwtaqndE37Em0gRAm/SAJ4ipt2/Xu9IeAC2yQb7YBFPsqr+ZACfTDKq
t2ZC8bII6yTX2Huy90Qlsg0=
=l3c+
-----END PGP SIGNATURE-----

--nextPart6593430.tnqShC799O--
