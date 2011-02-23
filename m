From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/20] xfrm: Mark flowi arg to xfrm_expand_policies() const.
Date: Tue, 22 Feb 2011 19:54:53 -0800 (PST)
Message-ID: <20110222.195453.179953100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752992Ab1BWDyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:16 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8119824C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4a5092a..84e4f74 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -941,7 +941,7 @@ fail:
 }
 
 static struct xfrm_policy *
-__xfrm_policy_lookup(struct net *net, struct flowi *fl, u16 family, u8 dir)
+__xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
 	struct xfrm_policy *pol;
@@ -1542,7 +1542,7 @@ xfrm_dst_update_origin(struct dst_entry *dst, struct flowi *fl)
 #endif
 }
 
-static int xfrm_expand_policies(struct flowi *fl, u16 family,
+static int xfrm_expand_policies(const struct flowi *fl, u16 family,
 				struct xfrm_policy **pols,
 				int *num_pols, int *num_xfrms)
 {
-- 
1.7.4.1

