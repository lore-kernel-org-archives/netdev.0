From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v3 2/5] alx: add constants for the stats fields
Date: Mon,  6 Jan 2014 17:33:40 +0100
Message-ID: <1389026023-18743-3-git-send-email-sd@queasysnail.net>
References: <1389026023-18743-1-git-send-email-sd@queasysnail.net>
Cc: bhutchings@solarflare.com, johannes@sipsolutions.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:43926 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755679AbaAFQfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 11:35:12 -0500
In-Reply-To: <1389026023-18743-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/alx/reg.h | 52 +++++++++++++++++++++++++++++++---
 1 file changed, 48 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/reg.h b/drivers/net/ethernet/atheros/alx/reg.h
index e4358c9..af006b4 100644
--- a/drivers/net/ethernet/atheros/alx/reg.h
+++ b/drivers/net/ethernet/atheros/alx/reg.h
@@ -404,15 +404,59 @@
 
 /* MIB */
 #define ALX_MIB_BASE					0x1700
+
 #define ALX_MIB_RX_OK					(ALX_MIB_BASE + 0)
+#define ALX_MIB_RX_BCAST				(ALX_MIB_BASE + 4)
+#define ALX_MIB_RX_MCAST				(ALX_MIB_BASE + 8)
+#define ALX_MIB_RX_PAUSE				(ALX_MIB_BASE + 12)
+#define ALX_MIB_RX_CTRL					(ALX_MIB_BASE + 16)
+#define ALX_MIB_RX_FCS_ERR				(ALX_MIB_BASE + 20)
+#define ALX_MIB_RX_LEN_ERR				(ALX_MIB_BASE + 24)
+#define ALX_MIB_RX_BYTE_CNT				(ALX_MIB_BASE + 28)
+#define ALX_MIB_RX_RUNT					(ALX_MIB_BASE + 32)
+#define ALX_MIB_RX_FRAG					(ALX_MIB_BASE + 36)
+#define ALX_MIB_RX_SZ_64B				(ALX_MIB_BASE + 40)
+#define ALX_MIB_RX_SZ_127B				(ALX_MIB_BASE + 44)
+#define ALX_MIB_RX_SZ_255B				(ALX_MIB_BASE + 48)
+#define ALX_MIB_RX_SZ_511B				(ALX_MIB_BASE + 52)
+#define ALX_MIB_RX_SZ_1023B				(ALX_MIB_BASE + 56)
+#define ALX_MIB_RX_SZ_1518B				(ALX_MIB_BASE + 60)
+#define ALX_MIB_RX_SZ_MAX				(ALX_MIB_BASE + 64)
+#define ALX_MIB_RX_OV_SZ				(ALX_MIB_BASE + 68)
+#define ALX_MIB_RX_OV_RXF				(ALX_MIB_BASE + 72)
+#define ALX_MIB_RX_OV_RRD				(ALX_MIB_BASE + 76)
+#define ALX_MIB_RX_ALIGN_ERR				(ALX_MIB_BASE + 80)
+#define ALX_MIB_RX_BCCNT				(ALX_MIB_BASE + 84)
+#define ALX_MIB_RX_MCCNT				(ALX_MIB_BASE + 88)
 #define ALX_MIB_RX_ERRADDR				(ALX_MIB_BASE + 92)
+
 #define ALX_MIB_TX_OK					(ALX_MIB_BASE + 96)
+#define ALX_MIB_TX_BCAST				(ALX_MIB_BASE + 100)
+#define ALX_MIB_TX_MCAST				(ALX_MIB_BASE + 104)
+#define ALX_MIB_TX_PAUSE				(ALX_MIB_BASE + 108)
+#define ALX_MIB_TX_EXC_DEFER				(ALX_MIB_BASE + 112)
+#define ALX_MIB_TX_CTRL					(ALX_MIB_BASE + 116)
+#define ALX_MIB_TX_DEFER				(ALX_MIB_BASE + 120)
+#define ALX_MIB_TX_BYTE_CNT				(ALX_MIB_BASE + 124)
+#define ALX_MIB_TX_SZ_64B				(ALX_MIB_BASE + 128)
+#define ALX_MIB_TX_SZ_127B				(ALX_MIB_BASE + 132)
+#define ALX_MIB_TX_SZ_255B				(ALX_MIB_BASE + 136)
+#define ALX_MIB_TX_SZ_511B				(ALX_MIB_BASE + 140)
+#define ALX_MIB_TX_SZ_1023B				(ALX_MIB_BASE + 144)
+#define ALX_MIB_TX_SZ_1518B				(ALX_MIB_BASE + 148)
+#define ALX_MIB_TX_SZ_MAX				(ALX_MIB_BASE + 152)
+#define ALX_MIB_TX_SINGLE_COL				(ALX_MIB_BASE + 156)
+#define ALX_MIB_TX_MULTI_COL				(ALX_MIB_BASE + 160)
+#define ALX_MIB_TX_LATE_COL				(ALX_MIB_BASE + 164)
+#define ALX_MIB_TX_ABORT_COL				(ALX_MIB_BASE + 168)
+#define ALX_MIB_TX_UNDERRUN				(ALX_MIB_BASE + 172)
+#define ALX_MIB_TX_TRD_EOP				(ALX_MIB_BASE + 176)
+#define ALX_MIB_TX_LEN_ERR				(ALX_MIB_BASE + 180)
+#define ALX_MIB_TX_TRUNC				(ALX_MIB_BASE + 184)
+#define ALX_MIB_TX_BCCNT				(ALX_MIB_BASE + 188)
 #define ALX_MIB_TX_MCCNT				(ALX_MIB_BASE + 192)
+#define ALX_MIB_UPDATE					(ALX_MIB_BASE + 196)
 
-#define ALX_RX_STATS_BIN				ALX_MIB_RX_OK
-#define ALX_RX_STATS_END				ALX_MIB_RX_ERRADDR
-#define ALX_TX_STATS_BIN				ALX_MIB_TX_OK
-#define ALX_TX_STATS_END				ALX_MIB_TX_MCCNT
 
 #define ALX_ISR						0x1600
 #define ALX_ISR_DIS					BIT(31)
-- 
1.8.5.2
