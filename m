From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] fib6_rules: fix indentation
Date: Sun, 8 Sep 2013 17:09:43 +0200
Message-ID: <20130908150943.GR21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:57868 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365Ab3IHPv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 11:51:29 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1VIgcR-0004cP-4M
	for netdev@vger.kernel.org; Sun, 08 Sep 2013 17:09:43 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change just removes two tabs from the source file.

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 net/ipv6/fib6_rules.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index a6c58ce..e275916 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -138,8 +138,8 @@ static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg
 	return false;
 
 suppress_route:
-		ip6_rt_put(rt);
-		return true;
+	ip6_rt_put(rt);
+	return true;
 }
 
 static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
-- 
1.7.10.4
