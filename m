From: pablo@netfilter.org
Subject: [PATCH 3/4] netfilter: nfnetlink_queue: fix sparse warning due to missing include
Date: Sun, 24 Jun 2012 01:53:28 +0200
Message-ID: <1340495609-26250-4-git-send-email-pablo@netfilter.org>
References: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39300 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756247Ab2FWXyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2012 19:54:39 -0400
In-Reply-To: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes a sparse warning due to missing include header file.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_ct.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_queue_ct.c b/net/netfilter/nfnetlink_queue_ct.c
index 01247b7..ab61d66 100644
--- a/net/netfilter/nfnetlink_queue_ct.c
+++ b/net/netfilter/nfnetlink_queue_ct.c
@@ -12,6 +12,7 @@
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_queue.h>
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nfnetlink_queue.h>
 
 struct nf_conn *nfqnl_ct_get(struct sk_buff *entskb, size_t *size,
 			     enum ip_conntrack_info *ctinfo)
-- 
1.7.10
