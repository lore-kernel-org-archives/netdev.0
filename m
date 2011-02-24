From: David Miller <davem@davemloft.net>
Subject: [PATCH 19/26] xfrm: Const'ify ptr args to xfrm_state_ok.
Date: Wed, 23 Feb 2011 23:16:17 -0800 (PST)
Message-ID: <20110223.231617.35043889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:15:41 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E559524C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:16:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3a4221a..f766e5f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1933,7 +1933,7 @@ xfrm_secpath_reject(int idx, struct sk_buff *skb, const struct flowi *fl)
  */
 
 static inline int
-xfrm_state_ok(struct xfrm_tmpl *tmpl, struct xfrm_state *x,
+xfrm_state_ok(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x,
 	      unsigned short family)
 {
 	if (xfrm_state_kern(x))
-- 
1.7.4.1

