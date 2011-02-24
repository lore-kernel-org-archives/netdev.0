From: David Miller <davem@davemloft.net>
Subject: [PATCH 17/26] xfrm: Const'ify xfrm_tmpl and xfrm_state args to
 xfrm_state_addr_cmp.
Date: Wed, 23 Feb 2011 23:15:27 -0800 (PST)
Message-ID: <20110223.231527.232745116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:14:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 75CBE24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:15:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5402a1e..f6d2f63 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -970,21 +970,21 @@ xfrm_addr_any(const xfrm_address_t *addr, unsigned short family)
 }
 
 static inline int
-__xfrm4_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x)
+__xfrm4_state_addr_cmp(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x)
 {
 	return	(tmpl->saddr.a4 &&
 		 tmpl->saddr.a4 != x->props.saddr.a4);
 }
 
 static inline int
-__xfrm6_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x)
+__xfrm6_state_addr_cmp(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x)
 {
 	return	(!ipv6_addr_any((struct in6_addr*)&tmpl->saddr) &&
 		 ipv6_addr_cmp((struct in6_addr *)&tmpl->saddr, (struct in6_addr*)&x->props.saddr));
 }
 
 static inline int
-xfrm_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x, unsigned short family)
+xfrm_state_addr_cmp(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x, unsigned short family)
 {
 	switch (family) {
 	case AF_INET:
-- 
1.7.4.1

