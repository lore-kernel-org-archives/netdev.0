From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net] ipv6: fix typos
Date: Sat,  7 Jan 2017 23:53:00 +0100
Message-ID: <20170107225300.19316-1-alexander@alemayhu.com>
Cc: Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:32772 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752522AbdAGWxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:53:10 -0500
Received: by mail-lf0-f51.google.com with SMTP id k86so74621868lfi.0
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 14:53:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o s/approriate/appropriate
o s/discouvery/discovery

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 net/ipv6/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8417c41d8ec8..ce5aaf448c54 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1464,7 +1464,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 	struct fib6_node *fn;
 
 	/* Get the "current" route for this destination and
-	 * check if the redirect has come from approriate router.
+	 * check if the redirect has come from appropriate router.
 	 *
 	 * RFC 4861 specifies that redirects should only be
 	 * accepted if they come from the nexthop to the target.
@@ -2768,7 +2768,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	   old MTU is the lowest MTU in the path, update the route PMTU
 	   to reflect the increase. In this case if the other nodes' MTU
 	   also have the lowest MTU, TOO BIG MESSAGE will be lead to
-	   PMTU discouvery.
+	   PMTU discovery.
 	 */
 	if (rt->dst.dev == arg->dev &&
 	    dst_metric_raw(&rt->dst, RTAX_MTU) &&
-- 
2.11.0
