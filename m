From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Export rtm_ipv4_policy.
Date: Tue, 04 Jul 2017 07:18:15 -0700 (PDT)
Message-ID: <20170704.071815.1571286541262131188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752051AbdGDOSX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 10:18:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The MPLS code now needs it.

Fixes: 397fc9e5cefe ("mpls: route get support")
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_frontend.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4e678fa..1b5860f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -626,6 +626,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_UID]		= { .type = NLA_U32 },
 	[RTA_MARK]		= { .type = NLA_U32 },
 };
+EXPORT_SYMBOL_GPL(rtm_ipv4_policy);
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 			     struct nlmsghdr *nlh, struct fib_config *cfg,
-- 
2.9.4
