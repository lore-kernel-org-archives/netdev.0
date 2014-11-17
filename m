From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 1/8] net: fec: indentation cleanup
Date: Mon, 17 Nov 2014 10:51:17 +0100
Message-ID: <1416217884-20911-2-git-send-email-LW@KARO-electronics.de>
References: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <fugang.duan@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53261 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaKQJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 04:51:41 -0500
In-Reply-To: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

consistently use TABs for indentation

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.h |  108 +++++++++++++++++---------=
--------
 1 file changed, 54 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index 9af296a..3047db4 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -213,60 +213,60 @@ struct bufdesc_ex {
  *	The following definitions courtesy of commproc.h, which where
  *	Copyright (c) 1997 Dan Malek (dmalek@jlc.net).
  */
-#define BD_SC_EMPTY     ((ushort)0x8000)        /* Receive is empty */
-#define BD_SC_READY     ((ushort)0x8000)        /* Transmit is ready *=
/
-#define BD_SC_WRAP      ((ushort)0x2000)        /* Last buffer descrip=
tor */
-#define BD_SC_INTRPT    ((ushort)0x1000)        /* Interrupt on change=
 */
-#define BD_SC_CM        ((ushort)0x0200)        /* Continuous mode */
-#define BD_SC_ID        ((ushort)0x0100)        /* Rec'd too many idle=
s */
-#define BD_SC_P         ((ushort)0x0100)        /* xmt preamble */
-#define BD_SC_BR        ((ushort)0x0020)        /* Break received */
-#define BD_SC_FR        ((ushort)0x0010)        /* Framing error */
-#define BD_SC_PR        ((ushort)0x0008)        /* Parity error */
-#define BD_SC_OV        ((ushort)0x0002)        /* Overrun */
-#define BD_SC_CD        ((ushort)0x0001)        /* ?? */
+#define BD_SC_EMPTY	((ushort)0x8000)	/* Receive is empty */
+#define BD_SC_READY	((ushort)0x8000)	/* Transmit is ready */
+#define BD_SC_WRAP	((ushort)0x2000)	/* Last buffer descriptor */
+#define BD_SC_INTRPT	((ushort)0x1000)	/* Interrupt on change */
+#define BD_SC_CM	((ushort)0x0200)	/* Continuous mode */
+#define BD_SC_ID	((ushort)0x0100)	/* Rec'd too many idles */
+#define BD_SC_P		((ushort)0x0100)	/* xmt preamble */
+#define BD_SC_BR	((ushort)0x0020)	/* Break received */
+#define BD_SC_FR	((ushort)0x0010)	/* Framing error */
+#define BD_SC_PR	((ushort)0x0008)	/* Parity error */
+#define BD_SC_OV	((ushort)0x0002)	/* Overrun */
+#define BD_SC_CD	((ushort)0x0001)	/* ?? */
=20
 /* Buffer descriptor control/status used by Ethernet receive.
-*/
-#define BD_ENET_RX_EMPTY        ((ushort)0x8000)
-#define BD_ENET_RX_WRAP         ((ushort)0x2000)
-#define BD_ENET_RX_INTR         ((ushort)0x1000)
-#define BD_ENET_RX_LAST         ((ushort)0x0800)
-#define BD_ENET_RX_FIRST        ((ushort)0x0400)
-#define BD_ENET_RX_MISS         ((ushort)0x0100)
-#define BD_ENET_RX_LG           ((ushort)0x0020)
-#define BD_ENET_RX_NO           ((ushort)0x0010)
-#define BD_ENET_RX_SH           ((ushort)0x0008)
-#define BD_ENET_RX_CR           ((ushort)0x0004)
-#define BD_ENET_RX_OV           ((ushort)0x0002)
-#define BD_ENET_RX_CL           ((ushort)0x0001)
-#define BD_ENET_RX_STATS        ((ushort)0x013f)        /* All status =
bits */
+ */
+#define BD_ENET_RX_EMPTY	((ushort)0x8000)
+#define BD_ENET_RX_WRAP		((ushort)0x2000)
+#define BD_ENET_RX_INTR		((ushort)0x1000)
+#define BD_ENET_RX_LAST		((ushort)0x0800)
+#define BD_ENET_RX_FIRST	((ushort)0x0400)
+#define BD_ENET_RX_MISS		((ushort)0x0100)
+#define BD_ENET_RX_LG		((ushort)0x0020)
+#define BD_ENET_RX_NO		((ushort)0x0010)
+#define BD_ENET_RX_SH		((ushort)0x0008)
+#define BD_ENET_RX_CR		((ushort)0x0004)
+#define BD_ENET_RX_OV		((ushort)0x0002)
+#define BD_ENET_RX_CL		((ushort)0x0001)
+#define BD_ENET_RX_STATS	((ushort)0x013f)	/* All status bits */
=20
 /* Enhanced buffer descriptor control/status used by Ethernet receive =
*/
-#define BD_ENET_RX_VLAN         0x00000004
+#define BD_ENET_RX_VLAN		0x00000004
=20
 /* Buffer descriptor control/status used by Ethernet transmit.
-*/
-#define BD_ENET_TX_READY        ((ushort)0x8000)
-#define BD_ENET_TX_PAD          ((ushort)0x4000)
-#define BD_ENET_TX_WRAP         ((ushort)0x2000)
-#define BD_ENET_TX_INTR         ((ushort)0x1000)
-#define BD_ENET_TX_LAST         ((ushort)0x0800)
-#define BD_ENET_TX_TC           ((ushort)0x0400)
-#define BD_ENET_TX_DEF          ((ushort)0x0200)
-#define BD_ENET_TX_HB           ((ushort)0x0100)
-#define BD_ENET_TX_LC           ((ushort)0x0080)
-#define BD_ENET_TX_RL           ((ushort)0x0040)
-#define BD_ENET_TX_RCMASK       ((ushort)0x003c)
-#define BD_ENET_TX_UN           ((ushort)0x0002)
-#define BD_ENET_TX_CSL          ((ushort)0x0001)
-#define BD_ENET_TX_STATS        ((ushort)0x0fff)        /* All status =
bits */
-
-/*enhanced buffer descriptor control/status used by Ethernet transmit*=
/
-#define BD_ENET_TX_INT          0x40000000
-#define BD_ENET_TX_TS           0x20000000
-#define BD_ENET_TX_PINS         0x10000000
-#define BD_ENET_TX_IINS         0x08000000
+ */
+#define BD_ENET_TX_READY	((ushort)0x8000)
+#define BD_ENET_TX_PAD		((ushort)0x4000)
+#define BD_ENET_TX_WRAP		((ushort)0x2000)
+#define BD_ENET_TX_INTR		((ushort)0x1000)
+#define BD_ENET_TX_LAST		((ushort)0x0800)
+#define BD_ENET_TX_TC		((ushort)0x0400)
+#define BD_ENET_TX_DEF		((ushort)0x0200)
+#define BD_ENET_TX_HB		((ushort)0x0100)
+#define BD_ENET_TX_LC		((ushort)0x0080)
+#define BD_ENET_TX_RL		((ushort)0x0040)
+#define BD_ENET_TX_RCMASK	((ushort)0x003c)
+#define BD_ENET_TX_UN		((ushort)0x0002)
+#define BD_ENET_TX_CSL		((ushort)0x0001)
+#define BD_ENET_TX_STATS	((ushort)0x0fff)	/* All status bits */
+
+/* enhanced buffer descriptor control/status used by Ethernet transmit=
 */
+#define BD_ENET_TX_INT		0x40000000
+#define BD_ENET_TX_TS		0x20000000
+#define BD_ENET_TX_PINS		0x10000000
+#define BD_ENET_TX_IINS		0x08000000
=20
=20
 /* This device has up to three irqs on some platforms */
@@ -301,7 +301,7 @@ struct bufdesc_ex {
 #define IDLE_SLOPE_2		0x200 /* BW fraction: 0.5 */
 #define IDLE_SLOPE(X)		((X =3D=3D 1) ? (IDLE_SLOPE_1 & IDLE_SLOPE_MASK=
) : \
 				(IDLE_SLOPE_2 & IDLE_SLOPE_MASK))
-#define RCMR_MATCHEN            (0x1 << 16)
+#define RCMR_MATCHEN		(0x1 << 16)
 #define RCMR_CMP_CFG(v, n)	((v & 0x7) <<  (n << 2))
 #define RCMR_CMP_1		(RCMR_CMP_CFG(0, 0) | RCMR_CMP_CFG(1, 1) | \
 				RCMR_CMP_CFG(2, 2) | RCMR_CMP_CFG(3, 3))
@@ -326,8 +326,8 @@ struct bufdesc_ex {
 #define TX_RING_SIZE		512	/* Must be power of two */
 #define TX_RING_MOD_MASK	511	/*   for this to work */
=20
-#define BD_ENET_RX_INT          0x00800000
-#define BD_ENET_RX_PTP          ((ushort)0x0400)
+#define BD_ENET_RX_INT		0x00800000
+#define BD_ENET_RX_PTP		((ushort)0x0400)
 #define BD_ENET_RX_ICE		0x00000020
 #define BD_ENET_RX_PCR		0x00000010
 #define FLAG_RX_CSUM_ENABLED	(BD_ENET_RX_ICE | BD_ENET_RX_PCR)
@@ -364,8 +364,8 @@ struct bufdesc_ex {
 #define FEC_ITR_ICFT_DEFAULT	200  /* Set 200 frame count threshold */
 #define FEC_ITR_ICTT_DEFAULT	1000 /* Set 1000us timer threshold */
=20
-#define FEC_VLAN_TAG_LEN       0x04
-#define FEC_ETHTYPE_LEN                0x02
+#define FEC_VLAN_TAG_LEN	0x04
+#define FEC_ETHTYPE_LEN		0x02
=20
 /* Controller is ENET-MAC */
 #define FEC_QUIRK_ENET_MAC		(1 << 0)
@@ -390,7 +390,7 @@ struct bufdesc_ex {
  * frames not being transmitted until there is a 0-to-1 transition on
  * ENET_TDAR[TDAR].
  */
-#define FEC_QUIRK_ERR006358            (1 << 7)
+#define FEC_QUIRK_ERR006358		(1 << 7)
 /* ENET IP hw AVB
  *
  * i.MX6SX ENET IP add Audio Video Bridging (AVB) feature support.
--=20
1.7.10.4
