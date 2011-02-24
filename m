From: David Miller <davem@davemloft.net>
Subject: [PATCH 23/26] xfrm: Const'ify xfrm_tmpl arg to xfrm_init_tempstate.
Date: Wed, 23 Feb 2011 23:17:17 -0800 (PST)
Message-ID: <20110223.231717.200368723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932508Ab1BXHQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:16:40 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D1F8824C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:17:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0383d83..ac6c48a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -658,7 +658,7 @@ EXPORT_SYMBOL(xfrm_sad_getinfo);
 
 static int
 xfrm_init_tempstate(struct xfrm_state *x, const struct flowi *fl,
-		    struct xfrm_tmpl *tmpl,
+		    const struct xfrm_tmpl *tmpl,
 		    xfrm_address_t *daddr, xfrm_address_t *saddr,
 		    unsigned short family)
 {
-- 
1.7.4.1

