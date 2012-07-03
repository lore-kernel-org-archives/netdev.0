From: David Miller <davem@davemloft.net>
Subject: [PATCH 18/19] xfrm: No need to copy generic neighbour pointer.
Date: Tue, 03 Jul 2012 02:47:08 -0700 (PDT)
Message-ID: <20120703.024708.149685625457655218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656Ab2GCJrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:47:08 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5EA7A58411E
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:47:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nobody reads it any longer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a28a3f9..6e97855 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1500,9 +1500,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	if (!dev)
 		goto free_dst;
 
-	/* Copy neighbour for reachability confirmation */
-	dst_set_neighbour(dst0, neigh_clone(dst_get_neighbour_noref(dst)));
-
 	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);
 	xfrm_init_pmtu(dst_prev);
 
-- 
1.7.10
