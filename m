From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2 3/6] ipv6: del statements for dealing with NDISC_REDIRECT
Date: Fri, 13 Sep 2013 11:00:41 +0800
Message-ID: <52327FD9.8080108@cn.fujitsu.com>
References: <52327F00.4040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:35768 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab3IMDBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 23:01:40 -0400
In-Reply-To: <52327F00.4040802@cn.fujitsu.com>
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
