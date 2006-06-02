From: akpm@osdl.org
Subject: [patch 17/17] recent match: missing refcnt initialization
Date: Thu, 01 Jun 2006 20:32:39 -0700
Message-ID: <200606020328.k523SLLJ028871@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9909 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751210AbWFBD2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:33 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/ipv4/netfilter/ipt_recent.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN net/ipv4/netfilter/ipt_recent.c~recent-match-missing-refcnt-initialization net/ipv4/netfilter/ipt_recent.c
--- devel/net/ipv4/netfilter/ipt_recent.c~recent-match-missing-refcnt-initialization	2006-06-01 20:31:51.000000000 -0700
+++ devel-akpm/net/ipv4/netfilter/ipt_recent.c	2006-06-01 20:31:51.000000000 -0700
@@ -262,6 +262,7 @@ ipt_recent_checkentry(const char *tablen
 		    GFP_KERNEL);
 	if (t == NULL)
 		goto out;
+	t->refcnt = 1;
 	strcpy(t->name, info->name);
 	INIT_LIST_HEAD(&t->lru_list);
 	for (i = 0; i < ip_list_hash_size; i++)
_
