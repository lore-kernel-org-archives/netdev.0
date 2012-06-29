From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Remove extraneous assignment of dst->tclassid.
Date: Thu, 28 Jun 2012 22:24:12 -0700 (PDT)
Message-ID: <20120628.222412.2093330323354885370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab2F2FYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 01:24:13 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 8BE05584BCB
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 22:24:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We already set it several lines above.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 919d69e..6a5afc7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2327,9 +2327,6 @@ local_input:
 	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
-#ifdef CONFIG_IP_ROUTE_CLASSID
-	rth->dst.tclassid = itag;
-#endif
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
-- 
1.7.10
