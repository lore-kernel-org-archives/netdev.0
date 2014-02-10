From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH] ipv4: ipconfig.c: add parentheses in an if statement
Date: Mon, 10 Feb 2014 16:46:54 +0100
Message-ID: <1392047214-21237-1-git-send-email-fx.lebail@yahoo.com>
Cc: David Miller <davem@davemloft.net>
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:39533 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbaBJQQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 11:16:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if the 'time_before' macro expand with parentheses, the look is bad.

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
 net/ipv4/ipconfig.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index efa1138..b3e86ea 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -273,7 +273,7 @@ static int __init ic_open_devs(void)
 
 		msleep(1);
 
-		if time_before(jiffies, next_msg)
+		if (time_before(jiffies, next_msg))
 			continue;
 
 		elapsed = jiffies_to_msecs(jiffies - start);
