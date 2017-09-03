From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/47] netfilter: xtables: Remove unused variable in compat_copy_entry_from_user()
Date: Mon,  4 Sep 2017 00:28:57 +0200
Message-ID: <1504477763-12205-2-git-send-email-pablo@netfilter.org>
References: <1504477763-12205-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51460 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753111AbdICW3h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:29:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 77A86190F62
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:29:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 67D21CE372
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:29:10 +0200 (CEST)
In-Reply-To: <1504477763-12205-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taehee Yoo <ap420073@gmail.com>

The target variable is not used in the compat_copy_entry_from_user().
So It can be removed.

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 2 --
 net/ipv4/netfilter/ip_tables.c  | 2 --
 2 files changed, 4 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 0bc3c3d73e61..cf520d30cb94 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1117,7 +1117,6 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 			    struct xt_table_info *newinfo, unsigned char *base)
 {
 	struct xt_entry_target *t;
-	struct xt_target *target;
 	struct arpt_entry *de;
 	unsigned int origsize;
 	int h;
@@ -1132,7 +1131,6 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 
 	de->target_offset = e->target_offset - (origsize - *size);
 	t = compat_arpt_get_target(e);
-	target = t->u.kernel.target;
 	xt_compat_target_from_user(t, dstptr, size);
 
 	de->next_offset = e->next_offset - (origsize - *size);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2a55a40211cb..f47e8dad5e95 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1355,7 +1355,6 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 			    struct xt_table_info *newinfo, unsigned char *base)
 {
 	struct xt_entry_target *t;
-	struct xt_target *target;
 	struct ipt_entry *de;
 	unsigned int origsize;
 	int h;
@@ -1374,7 +1373,6 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 
 	de->target_offset = e->target_offset - (origsize - *size);
 	t = compat_ipt_get_target(e);
-	target = t->u.kernel.target;
 	xt_compat_target_from_user(t, dstptr, size);
 
 	de->next_offset = e->next_offset - (origsize - *size);
-- 
2.1.4
