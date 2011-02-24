From: David Miller <davem@davemloft.net>
Subject: [PATCH 24/26] xfrm: Const'ify xfrm_address_t args to
 __xfrm_state_lookup{,_byaddr}.
Date: Wed, 23 Feb 2011 23:17:31 -0800 (PST)
Message-ID: <20110223.231731.212684029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:16:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A637C24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:17:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index ac6c48a..8a57a1e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -678,7 +678,10 @@ xfrm_init_tempstate(struct xfrm_state *x, const struct flowi *fl,
 	return 0;
 }
 
-static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
+static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark,
+					      const xfrm_address_t *daddr,
+					      __be32 spi, u8 proto,
+					      unsigned short family)
 {
 	unsigned int h = xfrm_spi_hash(net, daddr, spi, proto, family);
 	struct xfrm_state *x;
@@ -700,7 +703,10 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_ad
 	return NULL;
 }
 
-static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark, xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
+static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark,
+						     const xfrm_address_t *daddr,
+						     const xfrm_address_t *saddr,
+						     u8 proto, unsigned short family)
 {
 	unsigned int h = xfrm_src_hash(net, daddr, saddr, family);
 	struct xfrm_state *x;
-- 
1.7.4.1

