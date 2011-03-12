From: David Miller <davem@davemloft.net>
Subject: [PATCH 21/25] ipv4: Kill fib_semantic_match declaration from
 fib_lookup.h
Date: Sat, 12 Mar 2011 15:30:11 -0800 (PST)
Message-ID: <20110312.153011.212684951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55977
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756201Ab1CLX3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:29:33 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B28D524C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:30:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This function no longer exists.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_lookup.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 84db2da..4ec3238 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -25,9 +25,6 @@ static inline void fib_alias_accessed(struct fib_alias *fa)
 }
 
 /* Exported by fib_semantics.c */
-extern int fib_semantic_match(struct fib_table *tb, struct list_head *head,
-			      const struct flowi *flp,
-			      struct fib_result *res, int prefixlen, int fib_flags);
 extern void fib_release_info(struct fib_info *);
 extern struct fib_info *fib_create_info(struct fib_config *cfg);
 extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
-- 
1.7.4.1

