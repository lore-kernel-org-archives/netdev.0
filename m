From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v3 6/7] nf_queue_handler: whitespace cleanup
Date: Wed, 21 Sep 2016 11:35:06 -0400
Message-ID: <1474472107-12992-7-git-send-email-aconole@bytheb.org>
References: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33639 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757834AbcIUPfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:35:50 -0400
Received: by mail-yw0-f194.google.com with SMTP id g192so3090420ywh.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:35:49 -0700 (PDT)
In-Reply-To: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A future patch will modify the hook drop and outfn functions.  This will
cause the line lengths to take up too much space.  This is simply a
readability change.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 include/net/netfilter/nf_queue.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index cc8a11f..66b3f3f 100644
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
2.7.4
