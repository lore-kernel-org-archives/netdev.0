From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: setsockopt(IPIPPROTO_IPV6,IPV6_MINHOPCOUNT) forgot to set return value
Date: Sun, 11 Nov 2012 06:52:34 +0100
Message-ID: <20121111055234.GA28043@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46601 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab2KKFwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 00:52:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ipv6_sockglue.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ba6d13d..e02faed 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -827,6 +827,7 @@ pref_skip_coa:
 		if (val < 0 || val > 255)
 			goto e_inval;
 		np->min_hopcount = val;
+		retv = 0;
 		break;
 	case IPV6_DONTFRAG:
 		np->dontfrag = valbool;
