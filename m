From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 02/16] net: fec: remove unused interrupt FEC_ENET_TS_TIMER
Date: Tue,  5 Apr 2016 19:25:48 -0700
Message-ID: <1459909562-22865-3-git-send-email-troy.kisky@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33595 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462AbcDFC2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:13 -0400
Received: by mail-pa0-f45.google.com with SMTP id zm5so22816653pac.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:12 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC_ENET_TS_TIMER is not checked in the interrupt routine
so there is no need to enable it.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

---
v3: New patch

Frank Li said "TS_TIMER should never be triggered."
when discussing another patch.
---
 drivers/net/ethernet/freescale/fec.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 195122e..6dd0ba8 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -374,8 +374,8 @@ struct bufdesc_ex {
 #define FEC_ENET_TS_AVAIL       ((uint)0x00010000)
 #define FEC_ENET_TS_TIMER       ((uint)0x00008000)
 
-#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII | FEC_ENET_TS_TIMER)
-#define FEC_NAPI_IMASK	(FEC_ENET_MII | FEC_ENET_TS_TIMER)
+#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII)
+#define FEC_NAPI_IMASK	FEC_ENET_MII
 #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
 
 /* ENET interrupt coalescing macro define */
-- 
2.5.0
