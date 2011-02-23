From: David Miller <davem@davemloft.net>
Subject: [PATCH 17/20] xfrm: Mark flowi arg to xfrm_bundle_create() const.
Date: Tue, 22 Feb 2011 19:54:58 -0800 (PST)
Message-ID: <20110222.195458.70211767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753785Ab1BWDyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:22 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D545524C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3d45456..a558dc7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1390,7 +1390,7 @@ static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 					    struct xfrm_state **xfrm, int nx,
-					    struct flowi *fl,
+					    const struct flowi *fl,
 					    struct dst_entry *dst)
 {
 	struct net *net = xp_net(policy);
-- 
1.7.4.1

