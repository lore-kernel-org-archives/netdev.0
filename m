From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] ipv6: add IPv6 to neighbour table overflow warning
Date: Mon, 27 Sep 2010 15:22:11 +0200
Message-ID: <20100927132211.GA8916@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-55.dex002.intermedia.net ([64.78.21.160]:20669 "EHLO
	dhost002-55.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759147Ab0I0NWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 09:22:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 and IPv6 have separate neighbour tables, so
the warning messages should be distinguishable.

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d126365..614f83e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -670,7 +670,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *dad
 
 			if (net_ratelimit())
 				printk(KERN_WARNING
-				       "Neighbour table overflow.\n");
+				       "IPv6 Neighbour table overflow.\n");
 			dst_free(&rt->dst);
 			return NULL;
 		}
-- 
1.7.1

