From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 42/53] netfilter: nf_queue: whitespace cleanup
Date: Mon, 26 Sep 2016 01:06:52 +0200
Message-ID: <1474844823-2026-43-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54792 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034731AbcIYXID (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:08:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B0249C882F
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A0989DA81F
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 77B14DA845
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:59 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

A future patch will modify the hook drop and outfn functions.  This will
cause the line lengths to take up too much space.  This is simply a
readability change.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_queue.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 903dca050fb6..8fe85b98b5c8 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -22,10 +22,10 @@ struct nf_queue_entry {
 
 /* Packet queuing */
 struct nf_queue_handler {
-	int			(*outfn)(struct nf_queue_entry *entry,
-					 unsigned int queuenum);
-	void			(*nf_hook_drop)(struct net *net,
-						struct nf_hook_ops *ops);
+	int		(*outfn)(struct nf_queue_entry *entry,
+				 unsigned int queuenum);
+	void		(*nf_hook_drop)(struct net *net,
+					struct nf_hook_ops *ops);
 };
 
 void nf_register_queue_handler(struct net *net, const struct nf_queue_handler *qh);
-- 
2.1.4
