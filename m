From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ip6gre: add a rtnl link alias for ip6gretap
Date: Wed, 24 Sep 2014 11:03:00 +0200
Message-ID: <1411549380-4337-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:46926 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbaIXJDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 05:03:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this alias, we don't need to load manually the module before adding an
ip6gretap interface with iproute2.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 5f19dfbc4c6a..d172ec4ec9d3 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1724,4 +1724,5 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
 MODULE_DESCRIPTION("GRE over IPv6 tunneling device");
 MODULE_ALIAS_RTNL_LINK("ip6gre");
+MODULE_ALIAS_RTNL_LINK("ip6gretap");
 MODULE_ALIAS_NETDEV("ip6gre0");
-- 
2.1.0
