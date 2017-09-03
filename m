From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/47] netfilter: remove prototype of netfilter_queue_init
Date: Mon,  4 Sep 2017 00:40:13 +0200
Message-ID: <1504478435-13160-3-git-send-email-pablo@netfilter.org>
References: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52696 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753236AbdICWkw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:40:52 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 56F0E190F63
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 494C9B502D
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:25 +0200 (CEST)
In-Reply-To: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taehee Yoo <ap420073@gmail.com>

The netfilter_queue_init() has been removed.
so we can remove the prototype of that.

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_internals.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index bfa742da83af..19f00a47a710 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -15,7 +15,6 @@
 int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 	     struct nf_hook_entry **entryp, unsigned int verdict);
 unsigned int nf_queue_nf_hook_drop(struct net *net);
-int __init netfilter_queue_init(void);
 
 /* nf_log.c */
 int __init netfilter_log_init(void);
-- 
2.1.4
