From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Use passed-in protocol in ip_route_newports().
Date: Fri, 04 Mar 2011 21:35:53 -0800 (PST)
Message-ID: <20110304.213553.71108798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53221
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821Ab1CEFfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 00:35:16 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id C1A9F24C087
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2011 21:35:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 60daf74..8905d90 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -217,7 +217,7 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 				    .fl4_dst = rt->fl.fl4_dst,
 				    .fl4_src = rt->fl.fl4_src,
 				    .fl4_tos = rt->fl.fl4_tos,
-				    .proto = rt->fl.proto,
+				    .proto = protocol,
 				    .fl_ip_sport = sport,
 				    .fl_ip_dport = dport };
 
-- 
1.7.4.1

