From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] route: remove unsed variable in __mkroute_input
Date: Thu,  9 Jul 2015 12:46:35 +0900
Message-ID: <1436413595-21154-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbbGIDqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 23:46:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flags local variable in __mkroute_input is not used as a variable.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv4/route.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d0362a2..04c83de 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1546,7 +1546,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
-	unsigned int flags = 0;
 	bool do_cache;
 	u32 itag = 0;
 
@@ -1610,7 +1609,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	}
 
 	rth->rt_genid = rt_genid_ipv4(dev_net(rth->dst.dev));
-	rth->rt_flags = flags;
+	rth->rt_flags = 0;
 	rth->rt_type = res->type;
 	rth->rt_is_input = 1;
 	rth->rt_iif 	= 0;
-- 
2.4.3
