From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/35] netfilter: rename nfnetlink_queue_core.c to nfnetlink_queue.c
Date: Sat, 17 Oct 2015 13:32:38 +0200
Message-ID: <1445081590-2924-4-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48324 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbbJQL0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:12 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have integrated the ct glue code into nfnetlink_queue without
introducing dependencies with the conntrack code.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Makefile                                      | 1 -
 net/netfilter/{nfnetlink_queue_core.c => nfnetlink_queue.c} | 0
 2 files changed, 1 deletion(-)
 rename net/netfilter/{nfnetlink_queue_core.c => nfnetlink_queue.c} (100%)

diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 4d68e72..7638c36 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -10,7 +10,6 @@ obj-$(CONFIG_NETFILTER) = netfilter.o
 
 obj-$(CONFIG_NETFILTER_NETLINK) += nfnetlink.o
 obj-$(CONFIG_NETFILTER_NETLINK_ACCT) += nfnetlink_acct.o
-nfnetlink_queue-y := nfnetlink_queue_core.o
 obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) += nfnetlink_queue.o
 obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue.c
similarity index 100%
rename from net/netfilter/nfnetlink_queue_core.c
rename to net/netfilter/nfnetlink_queue.c
-- 
2.1.4
