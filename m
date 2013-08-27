From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: nf_defrag_ipv6.o included twice
Date: Wed, 28 Aug 2013 00:53:32 +0200
Message-ID: <1377644018-15685-3-git-send-email-pablo@netfilter.org>
References: <1377644018-15685-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44061 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466Ab3H0WyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 18:54:06 -0400
In-Reply-To: <1377644018-15685-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Hintz <nlhintz@hotmail.com>

'nf_defrag_ipv6' is built as a separate module; it shouldn't be
included in the 'nf_conntrack_ipv6' module as well.

Signed-off-by: Nathan Hintz <nlhintz@hotmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 2d11fcc..ad13bf0 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -14,7 +14,7 @@ obj-$(CONFIG_NF_NAT_IPV6) += ip6table_nat.o
 nf_conntrack_ipv6-y  :=  nf_conntrack_l3proto_ipv6.o nf_conntrack_proto_icmpv6.o
 
 # l3 independent conntrack
-obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o nf_defrag_ipv6.o
+obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o
 
 nf_nat_ipv6-y		:= nf_nat_l3proto_ipv6.o nf_nat_proto_icmpv6.o
 obj-$(CONFIG_NF_NAT_IPV6) += nf_nat_ipv6.o
-- 
1.7.10.4
