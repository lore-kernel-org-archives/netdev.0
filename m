From: David Miller <davem@davemloft.net>
Subject: [PATCH 05/26] xfrm: Const'ify address arguments to
 __xfrm_dst_lookup()
Date: Wed, 23 Feb 2011 23:13:10 -0800 (PST)
Message-ID: <20110223.231310.183051154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932381Ab1BXHMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:33 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 88B9424C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4827c8d..5f19ae6 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -92,8 +92,8 @@ int xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
 }
 
 static inline struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos,
-						  xfrm_address_t *saddr,
-						  xfrm_address_t *daddr,
+						  const xfrm_address_t *saddr,
+						  const xfrm_address_t *daddr,
 						  int family)
 {
 	struct xfrm_policy_afinfo *afinfo;
-- 
1.7.4.1

