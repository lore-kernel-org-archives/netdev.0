From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/26] xfrm: Const'ify local xfrm_address_t pointers in
 xfrm_policy_lookup_bytype.
Date: Wed, 23 Feb 2011 23:14:00 -0800 (PST)
Message-ID: <20110223.231400.28819971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932649Ab1BXHNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:13:24 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D2CB124C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:14:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0c503be..d097668 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -894,7 +894,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 {
 	int err;
 	struct xfrm_policy *pol, *ret;
-	xfrm_address_t *daddr, *saddr;
+	const xfrm_address_t *daddr, *saddr;
 	struct hlist_node *entry;
 	struct hlist_head *chain;
 	u32 priority = ~0U;
-- 
1.7.4.1

