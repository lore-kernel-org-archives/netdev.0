From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/20] xfrm: Mark flowi arg to xfrm_tmpl_resolve{,_one}()
 const.
Date: Tue, 22 Feb 2011 19:54:55 -0800 (PST)
Message-ID: <20110222.195455.245415121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756212Ab1BWDyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:19 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2803724C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 84e4f74..3d45456 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1157,9 +1157,8 @@ xfrm_get_saddr(struct net *net, xfrm_address_t *local, xfrm_address_t *remote,
 /* Resolve list of templates for the flow, given policy. */
 
 static int
-xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
-		      struct xfrm_state **xfrm,
-		      unsigned short family)
+xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
+		      struct xfrm_state **xfrm, unsigned short family)
 {
 	struct net *net = xp_net(policy);
 	int nx;
@@ -1214,9 +1213,8 @@ fail:
 }
 
 static int
-xfrm_tmpl_resolve(struct xfrm_policy **pols, int npols, struct flowi *fl,
-		  struct xfrm_state **xfrm,
-		  unsigned short family)
+xfrm_tmpl_resolve(struct xfrm_policy **pols, int npols, const struct flowi *fl,
+		  struct xfrm_state **xfrm, unsigned short family)
 {
 	struct xfrm_state *tp[XFRM_MAX_DEPTH];
 	struct xfrm_state **tpp = (npols > 1) ? tp : xfrm;
-- 
1.7.4.1

