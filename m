From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/2] r8169: verbose error message.
Date: Wed, 18 Jul 2012 00:09:44 +0200
Message-ID: <82e316efbd1c68946c8760f930b81d73e9c4425a.1342562326.git.romieu@fr.zoreil.com>
References: <cover.1342562326.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49896 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab2GQWWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:22:53 -0400
In-Reply-To: <cover.1342562326.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1342562326.git.romieu@fr.zoreil.com>
References: <cover.1342562326.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1f27318..be4e00f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -865,7 +865,8 @@ static bool rtl_loop_wait(struct rtl8169_private *tp, const struct rtl_cond *c,
 		if (c->check(tp) == high)
 			return true;
 	}
-	netif_err(tp, drv, tp->dev, c->msg);
+	netif_err(tp, drv, tp->dev, "%s == %d (loop: %d, delay: %d).\n",
+		  c->msg, !high, n, d);
 	return false;
 }
 
-- 
1.7.10.4
