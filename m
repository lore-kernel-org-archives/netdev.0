From: David Miller <davem@davemloft.net>
Subject: [PATCH 18/20] xfrm: Mark flowi arg to
 xfrm_dst_{alloc_copy,update_origin}() const.
Date: Tue, 22 Feb 2011 19:55:01 -0800 (PST)
Message-ID: <20110222.195501.232764342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752992Ab1BWDyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:25 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B8C1824C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:55:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a558dc7..21d29e7b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1506,7 +1506,7 @@ free_dst:
 }
 
 static int inline
-xfrm_dst_alloc_copy(void **target, void *src, int size)
+xfrm_dst_alloc_copy(void **target, const void *src, int size)
 {
 	if (!*target) {
 		*target = kmalloc(size, GFP_ATOMIC);
@@ -1530,7 +1530,7 @@ xfrm_dst_update_parent(struct dst_entry *dst, struct xfrm_selector *sel)
 }
 
 static int inline
-xfrm_dst_update_origin(struct dst_entry *dst, struct flowi *fl)
+xfrm_dst_update_origin(struct dst_entry *dst, const struct flowi *fl)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
-- 
1.7.4.1

