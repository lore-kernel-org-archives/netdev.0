From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/20] xfrm: Mark flowi arg to xfrm_init_tempstate() const.
Date: Tue, 22 Feb 2011 19:54:36 -0800 (PST)
Message-ID: <20110222.195436.48523986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752256Ab1BWDx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A3B0C24C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index bffe83d..674f278 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -656,7 +656,7 @@ void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
 EXPORT_SYMBOL(xfrm_sad_getinfo);
 
 static int
-xfrm_init_tempstate(struct xfrm_state *x, struct flowi *fl,
+xfrm_init_tempstate(struct xfrm_state *x, const struct flowi *fl,
 		    struct xfrm_tmpl *tmpl,
 		    xfrm_address_t *daddr, xfrm_address_t *saddr,
 		    unsigned short family)
-- 
1.7.4.1

