From: David Miller <davem@davemloft.net>
Subject: [PATCH 22/26] xfrm: Const'ify xfrm_address_t args to xfrm_*_hash.
Date: Wed, 23 Feb 2011 23:17:02 -0800 (PST)
Message-ID: <20110223.231702.116380094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38741
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:16:25 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 914A424C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:17:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 555bedd..0383d83 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -50,8 +50,8 @@ static void xfrm_audit_state_replay(struct xfrm_state *x,
 #endif /* CONFIG_AUDITSYSCALL */
 
 static inline unsigned int xfrm_dst_hash(struct net *net,
-					 xfrm_address_t *daddr,
-					 xfrm_address_t *saddr,
+					 const xfrm_address_t *daddr,
+					 const xfrm_address_t *saddr,
 					 u32 reqid,
 					 unsigned short family)
 {
@@ -59,15 +59,16 @@ static inline unsigned int xfrm_dst_hash(struct net *net,
 }
 
 static inline unsigned int xfrm_src_hash(struct net *net,
-					 xfrm_address_t *daddr,
-					 xfrm_address_t *saddr,
+					 const xfrm_address_t *daddr,
+					 const xfrm_address_t *saddr,
 					 unsigned short family)
 {
 	return __xfrm_src_hash(daddr, saddr, family, net->xfrm.state_hmask);
 }
 
 static inline unsigned int
-xfrm_spi_hash(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
+xfrm_spi_hash(struct net *net, const xfrm_address_t *daddr,
+	      __be32 spi, u8 proto, unsigned short family)
 {
 	return __xfrm_spi_hash(daddr, spi, proto, family, net->xfrm.state_hmask);
 }
-- 
1.7.4.1

