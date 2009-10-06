From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sb1250-mac: duplicate setting of bit V_MAC_RX_PL_THRSH(4)
 in sbmac_channel_start()
Date: Tue, 06 Oct 2009 22:07:15 +0200
Message-ID: <4ACBA373.7040506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:41031 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757507AbZJFT7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 15:59:07 -0400
Received: by ewy17 with SMTP id 17so4310590ewy.39
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2009 12:58:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bit V_MAC_RX_PL_THRSH(4) was already set a few lines higher.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Please review. Maybe it should be replaced by something else?

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 508551f..7269a87 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -1476,7 +1476,6 @@ static void sbmac_channel_start(struct sbmac_softc *s)
 		V_MAC_TX_RL_THRSH(4) |
 		V_MAC_RX_PL_THRSH(4) |
 		V_MAC_RX_RD_THRSH(4) |	/* Must be '4' */
-		V_MAC_RX_PL_THRSH(4) |
 		V_MAC_RX_RL_THRSH(8) |
 		0;
 
