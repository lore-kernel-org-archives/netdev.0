From: "David S. Miller" <davem@davemloft.net>
Subject: [RFC v2 PATCH 01/11] net: dst->rt_next is unused.
Date: Tue, 31 Oct 2017 23:10:44 +0900
Message-ID: <20171031141054.9954-2-davem@davemloft.net>
References: <20171031141054.9954-1-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [106.252.28.196] ([106.252.28.196]:51314 "EHLO davemloft.net"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751918AbdJaOUf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 10:20:35 -0400
In-Reply-To: <20171031141054.9954-1-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 2f53ecc2c296..1551fdeadc7a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -100,7 +100,6 @@ struct dst_entry {
 	struct lwtunnel_state   *lwtstate;
 	union {
 		struct dst_entry	*next;
-		struct rtable __rcu	*rt_next;
 		struct rt6_info __rcu	*rt6_next;
 		struct dn_route __rcu	*dn_next;
 	};
-- 
2.13.6
