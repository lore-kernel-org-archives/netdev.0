From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] netfilter: missing module license in the nf_reject_ipvX modules
Date: Mon, 20 Oct 2014 10:10:33 +0200
Message-ID: <1413792639-3954-2-git-send-email-pablo@netfilter.org>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40026 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbaJTIJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 04:09:17 -0400
In-Reply-To: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.

Fixes: c8d7b98 ("netfilter: move nf_send_resetX() code to nf_reject_ipvX modules")
Reported-by: Dave Young <dyoung@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_reject_ipv4.c |    3 +++
 net/ipv6/netfilter/nf_reject_ipv6.c |    4 ++++
 2 files changed, 7 insertions(+)

diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index b023b4e..92b303d 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -6,6 +6,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/module.h>
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/route.h>
@@ -125,3 +126,5 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
 	kfree_skb(nskb);
 }
 EXPORT_SYMBOL_GPL(nf_send_reset);
+
+MODULE_LICENSE("GPL");
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 5f5f043..20d9def 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -5,6 +5,8 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#include <linux/module.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #include <net/ip6_fib.h>
@@ -161,3 +163,5 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 		ip6_local_out(nskb);
 }
 EXPORT_SYMBOL_GPL(nf_send_reset6);
+
+MODULE_LICENSE("GPL");
-- 
1.7.10.4
