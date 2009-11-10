From: Joe Perches <joe@perches.com>
Subject: [PATCH] niu.c: Use correct length in strncmp
Date: Mon, 09 Nov 2009 20:05:45 -0800
Message-ID: <1257825945.12852.89.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1295 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbZKJEFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 23:05:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Untested, no hardware

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index d6c7ac6..d0f96bc 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -8144,7 +8144,7 @@ static void __devinit niu_vpd_parse_version(struct niu *np)
 	int i;
 
 	for (i = 0; i < len - 5; i++) {
-		if (!strncmp(s + i, "FCode ", 5))
+		if (!strncmp(s + i, "FCode ", 6))
 			break;
 	}
 	if (i >= len - 5)


