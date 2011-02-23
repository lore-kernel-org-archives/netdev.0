From: David Miller <davem@davemloft.net>
Subject: [PATCH 19/20] xfrm: Mark flowi arg to
 xfrm_resolve_and_create_bundle() const.
Date: Tue, 22 Feb 2011 19:55:06 -0800 (PST)
Message-ID: <20110222.195506.229731476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32869
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753765Ab1BWDy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:29 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2473924C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:55:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 21d29e7b..ef899a8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1586,7 +1586,7 @@ static int xfrm_expand_policies(const struct flowi *fl, u16 family,
 
 static struct xfrm_dst *
 xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
-			       struct flowi *fl, u16 family,
+			       const struct flowi *fl, u16 family,
 			       struct dst_entry *dst_orig)
 {
 	struct net *net = xp_net(pols[0]);
-- 
1.7.4.1

