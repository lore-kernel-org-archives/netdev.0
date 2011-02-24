From: David Miller <davem@davemloft.net>
Subject: [PATCH 25/26] xfrm: Remove unused 'saddr' and 'daddr' args to
 xfrm_state_look_at.
Date: Wed, 23 Feb 2011 23:17:45 -0800 (PST)
Message-ID: <20110223.231745.258111779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:17:08 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id C617A24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:17:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 8a57a1e..9d9ac7c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -754,7 +754,6 @@ static void xfrm_hash_grow_check(struct net *net, int have_hash_collision)
 
 static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_state *x,
 			       const struct flowi *fl, unsigned short family,
-			       xfrm_address_t *daddr, xfrm_address_t *saddr,
 			       struct xfrm_state **best, int *acq_in_progress,
 			       int *error)
 {
@@ -820,7 +819,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
 		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi))
-			xfrm_state_look_at(pol, x, fl, encap_family, daddr, saddr,
+			xfrm_state_look_at(pol, x, fl, encap_family,
 					   &best, &acquire_in_progress, &error);
 	}
 	if (best)
@@ -836,7 +835,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
 		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi))
-			xfrm_state_look_at(pol, x, fl, encap_family, daddr, saddr,
+			xfrm_state_look_at(pol, x, fl, encap_family,
 					   &best, &acquire_in_progress, &error);
 	}
 
-- 
1.7.4.1

