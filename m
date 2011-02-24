From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/26] xfrm: Const'ify policy arg to xp_net.
Date: Wed, 23 Feb 2011 23:14:40 -0800 (PST)
Message-ID: <20110223.231440.179929810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932149Ab1BXHOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:14:03 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7B13324C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:14:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1806c91..5402a1e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -506,7 +506,7 @@ struct xfrm_policy {
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
-static inline struct net *xp_net(struct xfrm_policy *xp)
+static inline struct net *xp_net(const struct xfrm_policy *xp)
 {
 	return read_pnet(&xp->xp_net);
 }
-- 
1.7.4.1

