From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/3] [IPV6] ROUTE: Fix size of fib6_rule_policy.
Date: Sat, 26 Aug 2006 00:09:19 +0900 (JST)
Message-ID: <20060826.000919.82157954.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55562 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1422684AbWHYPHa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 11:07:30 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6] ROUTE: Fix size of fib6_rule_policy.

It should not be RTA_MAX+1 but FRA_MAX+1.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/fib6_rules.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index b4cd5c0..3d64c71 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -135,7 +135,7 @@ #endif
 	return 1;
 }
 
-static struct nla_policy fib6_rule_policy[RTA_MAX+1] __read_mostly = {
+static struct nla_policy fib6_rule_policy[FRA_MAX+1] __read_mostly = {
 	[FRA_IFNAME]	= { .type = NLA_STRING },
 	[FRA_PRIORITY]	= { .type = NLA_U32 },
 	[FRA_SRC]	= { .minlen = sizeof(struct in6_addr) },

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
