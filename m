From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH net] net: route: add missing nla_policy entry for RTA_MARK attribute
Date: Mon, 27 Feb 2017 20:59:39 +0800
Message-ID: <1488200379-31417-1-git-send-email-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <zlpnobody@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:45533 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751390AbdB0OIu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 09:08:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

This will add stricter validating for RTA_MARK attribute.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
---
 net/ipv4/fib_frontend.c | 1 +
 net/ipv6/route.c        | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b39a791..42bfd08 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -622,6 +622,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
 	[RTA_ENCAP]		= { .type = NLA_NESTED },
 	[RTA_UID]		= { .type = NLA_U32 },
+	[RTA_MARK]		= { .type = NLA_U32 },
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54f426..d94f1df 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2891,6 +2891,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_ENCAP]		= { .type = NLA_NESTED },
 	[RTA_EXPIRES]		= { .type = NLA_U32 },
 	[RTA_UID]		= { .type = NLA_U32 },
+	[RTA_MARK]		= { .type = NLA_U32 },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
-- 
2.5.5
