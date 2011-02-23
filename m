From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/20] xfrm: Mark flowi arg to xfrm_state_look_at() const.
Date: Tue, 22 Feb 2011 19:54:33 -0800 (PST)
Message-ID: <20110222.195433.115915021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751755Ab1BWDx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:56 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 979F924C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 220ebc0..bffe83d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -746,7 +746,7 @@ static void xfrm_hash_grow_check(struct net *net, int have_hash_collision)
 }
 
 static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_state *x,
-			       struct flowi *fl, unsigned short family,
+			       const struct flowi *fl, unsigned short family,
 			       xfrm_address_t *daddr, xfrm_address_t *saddr,
 			       struct xfrm_state **best, int *acq_in_progress,
 			       int *error)
-- 
1.7.4.1

