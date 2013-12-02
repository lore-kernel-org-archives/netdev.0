From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH] ipv6: fix third arg of anycast_dst_alloc(), must be bool.
Date: Mon,  2 Dec 2013 11:28:49 +0100
Message-ID: <1385980129-16471-1-git-send-email-fx.lebail@yahoo.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:21503 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087Ab3LBKgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 05:36:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 12c97d8..d5fa5b8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2613,7 +2613,7 @@ static void init_loopback(struct net_device *dev)
 			if (sp_ifa->rt)
 				continue;
 
-			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
+			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
 
 			/* Failure cases are ignored */
 			if (!IS_ERR(sp_rt)) {
