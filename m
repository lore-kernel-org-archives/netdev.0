From: David Miller <davem@davemloft.net>
Subject: [PATCH 21/26] xfrm: Const'ify sec_path arg to
 secpath_has_nontransport.
Date: Wed, 23 Feb 2011 23:16:48 -0800 (PST)
Message-ID: <20110223.231648.242131742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38738
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:16:11 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6E86E24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:16:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2de0bc2..41a91d2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1994,7 +1994,7 @@ int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 }
 EXPORT_SYMBOL(__xfrm_decode_session);
 
-static inline int secpath_has_nontransport(struct sec_path *sp, int k, int *idxp)
+static inline int secpath_has_nontransport(const struct sec_path *sp, int k, int *idxp)
 {
 	for (; k < sp->len; k++) {
 		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT) {
-- 
1.7.4.1

