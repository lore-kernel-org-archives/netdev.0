From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 1/4] drivers/net/fec: Cleanup
Date: Mon, 21 Mar 2011 17:37:33 +0100
Message-ID: <cae922ff2a4ba144baf3d50f5d9fddd13d50e68b.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <u.kleine-koenig@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:58246 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab1CUQjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 12:39:55 -0400
In-Reply-To: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
In-Reply-To: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Whitespace cleanup
- Convert indentation spaces to TABs
- Spelling fixes

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/fec.c |    9 +++---
 drivers/net/fec.h |   78 ++++++++++++++++++++++++++-------------------=
-------
 2 files changed, 43 insertions(+), 44 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 885d8ba..f00ee7f 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -96,7 +96,7 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address")=
;
 #elif defined (CONFIG_M5272C3)
 #define	FEC_FLASHMAC	(0xffe04000 + 4)
 #elif defined(CONFIG_MOD5272)
-#define FEC_FLASHMAC 	0xffc0406b
+#define FEC_FLASHMAC	0xffc0406b
 #else
 #define	FEC_FLASHMAC	0
 #endif
@@ -210,10 +210,10 @@ struct fec_enet_private {
 #define FEC_MMFR_ST		(1 << 30)
 #define FEC_MMFR_OP_READ	(2 << 28)
 #define FEC_MMFR_OP_WRITE	(1 << 28)
-#define FEC_MMFR_PA(v)		((v & 0x1f) << 23)
-#define FEC_MMFR_RA(v)		((v & 0x1f) << 18)
+#define FEC_MMFR_PA(v)		(((v) & 0x1f) << 23)
+#define FEC_MMFR_RA(v)		(((v) & 0x1f) << 18)
 #define FEC_MMFR_TA		(2 << 16)
-#define FEC_MMFR_DATA(v)	(v & 0xffff)
+#define FEC_MMFR_DATA(v)	((v) & 0xffff)
=20
 #define FEC_MII_TIMEOUT		1000 /* us */
=20
@@ -472,7 +472,6 @@ fec_stop(struct net_device *ndev)
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 }
=20
-
 static void
 fec_timeout(struct net_device *ndev)
 {
diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index ace318d..8697556 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -97,51 +97,51 @@ struct bufdesc {
  *	The following definitions courtesy of commproc.h, which where
  *	Copyright (c) 1997 Dan Malek (dmalek@jlc.net).
  */
-#define BD_SC_EMPTY     ((ushort)0x8000)        /* Recieve is empty */
-#define BD_SC_READY     ((ushort)0x8000)        /* Transmit is ready *=
/
-#define BD_SC_WRAP      ((ushort)0x2000)        /* Last buffer descrip=
tor */
-#define BD_SC_INTRPT    ((ushort)0x1000)        /* Interrupt on change=
 */
-#define BD_SC_CM        ((ushort)0x0200)        /* Continous mode */
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
 */
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
 /* Buffer descriptor control/status used by Ethernet transmit.
 */
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
-#define BD_ENET_TX_STATS        ((ushort)0x03ff)        /* All status =
bits */
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
+#define BD_ENET_TX_STATS	((ushort)0x03ff)	/* All status bits */
=20
=20
 /*********************************************************************=
*******/
--=20
1.5.6.5

