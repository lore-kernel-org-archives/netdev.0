From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC 3/9] ipv6: route: export symbol ip6_route_input
Date: Fri, 26 Aug 2016 17:52:41 +0200
Message-ID: <1472226767-9904-4-git-send-email-david.lebrun@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:43347 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753444AbcHZP7P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 11:59:15 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id E2A3F67DBD8
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:52:18 +0200 (CEST)
In-Reply-To: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function ip6_route_input() is used in the seg6_iptunnel module
and thus needs to be exported when CONFIG_IPV6_SEG6_IPTUNNEL=m

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4981755..7d8d108 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1178,6 +1178,7 @@ void ip6_route_input(struct sk_buff *skb)
 	skb_dst_drop(skb);
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
+EXPORT_SYMBOL(ip6_route_input);
 
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi6 *fl6, int flags)
-- 
2.3.6
