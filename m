From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/26] xfrm: Const'ify selector arg to
 xfrm_dst_update_parent.
Date: Wed, 23 Feb 2011 23:15:11 -0800 (PST)
Message-ID: <20110223.231511.70190873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:14:34 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2EC2A24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:15:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f1f90af..3a4221a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1525,7 +1525,7 @@ xfrm_dst_alloc_copy(void **target, const void *src, int size)
 }
 
 static int inline
-xfrm_dst_update_parent(struct dst_entry *dst, struct xfrm_selector *sel)
+xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
-- 
1.7.4.1

