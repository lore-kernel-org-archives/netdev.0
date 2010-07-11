From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: incorrect identifier for a 8168dp
Date: Sun, 11 Jul 2010 23:48:43 +0200
Message-ID: <20100711214843.GA7922@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Hayes <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 88-137-244-105.adslgp.cegetel.net ([88.137.244.105]:36076 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754740Ab0GKV4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 17:56:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merge error.

See CFG_METHOD_8 (0x3c800000 + 0x00300000) since version 8.002.00
of Realtek's driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 96b6cfb..cdc6a5c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1316,7 +1316,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x28000000,	RTL_GIGA_MAC_VER_26 },
 
 		/* 8168C family. */
-		{ 0x7cf00000, 0x3ca00000,	RTL_GIGA_MAC_VER_24 },
+		{ 0x7cf00000, 0x3cb00000,	RTL_GIGA_MAC_VER_24 },
 		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
 		{ 0x7cf00000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
 		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_24 },
-- 
1.7.1.1

