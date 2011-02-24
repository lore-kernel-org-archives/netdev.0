From: David Miller <davem@davemloft.net>
Subject: [PATCH 20/26] xfrm: Const'ify ptr args to xfrm_policy_ok.
Date: Wed, 23 Feb 2011 23:16:33 -0800 (PST)
Message-ID: <20110223.231633.15238617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:15:56 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3A76924C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:16:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f766e5f..2de0bc2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1956,7 +1956,7 @@ xfrm_state_ok(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x,
  * Otherwise "-2 - errored_index" is returned.
  */
 static inline int
-xfrm_policy_ok(struct xfrm_tmpl *tmpl, struct sec_path *sp, int start,
+xfrm_policy_ok(const struct xfrm_tmpl *tmpl, const struct sec_path *sp, int start,
 	       unsigned short family)
 {
 	int idx = start;
-- 
1.7.4.1

