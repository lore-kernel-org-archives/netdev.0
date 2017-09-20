From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH v4 2/3] net: fec: remove unused interrupt FEC_ENET_TS_TIMER
Date: Tue, 19 Sep 2017 17:33:08 -0700
Message-ID: <1505867589-11784-2-git-send-email-troy.kisky@boundarydevices.com>
References: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, lznuaa@gmail.com,
        Troy Kisky <troy.kisky@boundarydevices.com>
To: fugang.duan@nxp.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wsip-98-189-142-135.oc.oc.cox.net ([98.189.142.135]:59441 "EHLO
        office-server2" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750872AbdITBRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 21:17:00 -0400
In-Reply-To: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC_ENET_TS_TIMER is not checked in the interrupt routine
so there is no need to enable it.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
Acked-by: Fugang Duan <fugang.duan@nxp.com>

---
v4: Added Acked-by

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 38c7b21..ede1876 100644
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
2.7.4
