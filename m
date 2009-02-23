From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] ppp_generic: Simplify tx_dropped stats
Date: Mon, 23 Feb 2009 16:59:43 +0200
Message-ID: <20090223145942.8588.78220.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:58029 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754580AbZBWO7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 09:59:47 -0500
Received: from unknown (HELO [127.0.0.1]) (paulius.zaleckas@[217.147.39.138])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Feb 2009 14:59:43 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Local variable dev = ppp->dev

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
---

 drivers/net/ppp_generic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 7b2728b..78606f5 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -908,7 +908,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
  outf:
 	kfree_skb(skb);
-	++ppp->dev->stats.tx_dropped;
+	++dev->stats.tx_dropped;
 	return 0;
 }
 

