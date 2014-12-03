From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/12] netfilter: nf_log_ipv6: correct typo in module description
Date: Wed,  3 Dec 2014 13:55:36 +0100
Message-ID: <1417611342-25257-7-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48645 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbaLCMxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:37 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Noonan <steven@uplinklabs.net>

It incorrectly identifies itself as "IPv4" packet logging.

Signed-off-by: Steven Noonan <steven@uplinklabs.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_log_ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 7fc34d1..ddf07e6 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -422,6 +422,6 @@ module_init(nf_log_ipv6_init);
 module_exit(nf_log_ipv6_exit);
 
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
-MODULE_DESCRIPTION("Netfilter IPv4 packet logging");
+MODULE_DESCRIPTION("Netfilter IPv6 packet logging");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NF_LOGGER(AF_INET6, 0);
-- 
1.7.10.4
