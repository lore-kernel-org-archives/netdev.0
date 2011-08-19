From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH net-next] net: reserve ooo_okay when copying skb header
Date: Fri, 19 Aug 2011 22:44:18 +0800
Message-ID: <1313765058-9315-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f170.google.com ([209.85.210.170]:63679 "EHLO
	mail-iy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635Ab1HSOpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:45:19 -0400
Received: by iye16 with SMTP id 16so5697084iye.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/skbuff.c |    1 +
 1 file changed, 1 insertion(+)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index edb66f3..e27334e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -529,6 +529,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->mac_header		= old->mac_header;
 	skb_dst_copy(new, old);
 	new->rxhash		= old->rxhash;
+	new->ooo_okay		= old->ooo_okay;
 	new->l4_rxhash		= old->l4_rxhash;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
