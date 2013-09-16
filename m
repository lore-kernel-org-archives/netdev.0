From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v3 3/6] ipv6: del statements for dealing with NDISC_REDIRECT
Date: Mon, 16 Sep 2013 19:52:04 +0800
Message-ID: <5236F0E4.8090701@cn.fujitsu.com>
References: <5236EFEB.60106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:18974 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757281Ab3IPLxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 07:53:03 -0400
In-Reply-To: <5236EFEB.60106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Now the route updating for redirect is done in ndisc
layer.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/icmp.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index eef8d94..4bde43c 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -91,8 +91,6 @@ static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_update_pmtu(skb, net, info, 0, 0);
-	else if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 
 	if (!(type & ICMPV6_INFOMSG_MASK))
 		if (icmp6->icmp6_type == ICMPV6_ECHO_REQUEST)
-- 
1.8.3.1
