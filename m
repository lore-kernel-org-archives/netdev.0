From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/26] xfrm: Const'ify policy arg and local selector in
 xfrm_policy_match.
Date: Wed, 23 Feb 2011 23:14:20 -0800 (PST)
Message-ID: <20110223.231420.102545352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38712
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932633Ab1BXHNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:13:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8E67D24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:14:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d097668..9f6c7a7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -869,10 +869,11 @@ EXPORT_SYMBOL(xfrm_policy_walk_done);
  *
  * Returns 0 if policy found, else an -errno.
  */
-static int xfrm_policy_match(struct xfrm_policy *pol, const struct flowi *fl,
+static int xfrm_policy_match(const struct xfrm_policy *pol,
+			     const struct flowi *fl,
 			     u8 type, u16 family, int dir)
 {
-	struct xfrm_selector *sel = &pol->selector;
+	const struct xfrm_selector *sel = &pol->selector;
 	int match, ret = -ESRCH;
 
 	if (pol->family != family ||
-- 
1.7.4.1

