From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/26] xfrm: Const'ify policy arg to clone_policy.
Date: Wed, 23 Feb 2011 23:14:55 -0800 (PST)
Message-ID: <20110223.231455.245392844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38719
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:14:18 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B9FB524C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:14:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9f6c7a7..f1f90af 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1105,7 +1105,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 	return 0;
 }
 
-static struct xfrm_policy *clone_policy(struct xfrm_policy *old, int dir)
+static struct xfrm_policy *clone_policy(const struct xfrm_policy *old, int dir)
 {
 	struct xfrm_policy *newp = xfrm_policy_alloc(xp_net(old), GFP_ATOMIC);
 
-- 
1.7.4.1

