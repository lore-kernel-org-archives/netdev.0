From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Order ports in same order as addresses in flow
 objects.
Date: Thu, 31 Mar 2011 23:35:48 -0700 (PDT)
Message-ID: <20110331.233548.71126318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754035Ab1DAGgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 02:36:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9F69324C088
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 23:35:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For consistency.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 37e77d6..c6d5fe5 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -26,8 +26,8 @@ struct flowi_common {
 
 union flowi_uli {
 	struct {
-		__be16	sport;
 		__be16	dport;
+		__be16	sport;
 	} ports;
 
 	struct {
@@ -36,8 +36,8 @@ union flowi_uli {
 	} icmpt;
 
 	struct {
-		__le16	sport;
 		__le16	dport;
+		__le16	sport;
 	} dnports;
 
 	__be32		spi;
@@ -86,8 +86,8 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->flowi4_secid = 0;
 	fl4->daddr = daddr;
 	fl4->saddr = saddr;
-	fl4->fl4_sport = sport;
 	fl4->fl4_dport = dport;
+	fl4->fl4_sport = sport;
 }
 				      
 
-- 
1.7.4.2

