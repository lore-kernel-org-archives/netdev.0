From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/20] xfrm: Mark flowi arg to
 xfrm_policy_{lookup_by_type,match}() const.
Date: Tue, 22 Feb 2011 19:54:50 -0800 (PST)
Message-ID: <20110222.195450.102569731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32854
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753629Ab1BWDyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:14 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D831524C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1e11398..4a5092a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -864,7 +864,7 @@ EXPORT_SYMBOL(xfrm_policy_walk_done);
  *
  * Returns 0 if policy found, else an -errno.
  */
-static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
+static int xfrm_policy_match(struct xfrm_policy *pol, const struct flowi *fl,
 			     u8 type, u16 family, int dir)
 {
 	struct xfrm_selector *sel = &pol->selector;
@@ -884,7 +884,7 @@ static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
 }
 
 static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
-						     struct flowi *fl,
+						     const struct flowi *fl,
 						     u16 family, u8 dir)
 {
 	int err;
-- 
1.7.4.1

