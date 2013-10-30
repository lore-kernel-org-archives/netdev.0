From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH] route: Exporting ip6_route_add() so that Bluetooth 6LoWPAN can use it
Date: Wed, 30 Oct 2013 11:17:17 +0200
Message-ID: <1383124637-15533-1-git-send-email-jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46757 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab3J3JRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 05:17:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c979dd9..d7c200f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1662,6 +1662,7 @@ out:
 		dst_free(&rt->dst);
 	return err;
 }
+EXPORT_SYMBOL_GPL(ip6_route_add);
 
 static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 {
-- 
1.7.11.7
