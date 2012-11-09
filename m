From: Kirill Smelkov <kirr@navytux.spb.ru>
Subject: [PATCH] r8169: Kill RX_BUF_SIZE macro
Date: Fri,  9 Nov 2012 23:29:08 +0400
Message-ID: <1352489348-5861-1-git-send-email-kirr@navytux.spb.ru>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, Kirill Smelkov <kirr@navytux.spb.ru>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward4.mail.yandex.net ([77.88.46.9]:39540 "EHLO
	forward4.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278Ab2KITgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 14:36:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 6f0333b8 (r8169: use 50% less ram for RX ring) RX_BUF_SIZE is not
used and should be gone.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Kirill Smelkov <kirr@navytux.spb.ru>
---
 drivers/net/ethernet/realtek/r8169.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d6c6cfb..029a028 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -84,7 +84,6 @@ static const int multicast_filter_limit = 32;
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
-#define RX_BUF_SIZE	1536	/* Rx Buffer size */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
-- 
1.8.0.337.g4cdca5d
