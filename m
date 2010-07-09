From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] tproxy: the length of lines should be within 80
Date: Fri,  9 Jul 2010 13:31:20 +0800
Message-ID: <1278653480-21304-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:37791 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab0GIFe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 01:34:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tproxy: the length of lines should be within 80

According to the Documentation/CodingStyle, the length of lines should be
within 80.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/netfilter/xt_TPROXY.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index e1a0ded..c61294d 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -37,8 +37,10 @@ tproxy_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		return NF_DROP;
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-				   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
-				   hp->source, tgi->lport ? tgi->lport : hp->dest,
+				   iph->saddr,
+				   tgi->laddr ? tgi->laddr : iph->daddr,
+				   hp->source,
+				   tgi->lport ? tgi->lport : hp->dest,
 				   par->in, true);
 
 	/* NOTE: assign_sock consumes our sk reference */
