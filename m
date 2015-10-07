From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/4] net: Export fib6_get_table and nd_tbl
Date: Wed,  7 Oct 2015 09:50:38 -0700
Message-ID: <1444236640-2410-3-git-send-email-dsa@cumulusnetworks.com>
References: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36171 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019AbbJGQuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:50:50 -0400
Received: by pablk4 with SMTP id lk4so26304383pab.3
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:50:50 -0700 (PDT)
In-Reply-To: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/ip6_fib.c | 1 +
 net/ipv6/ndisc.c   | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 7d2e0023c72d..09fddf70cca4 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -264,6 +264,7 @@ struct fib6_table *fib6_get_table(struct net *net, u32 id)
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(fib6_get_table);
 
 static void __net_init fib6_tables_init(struct net *net)
 {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7089c305245c..b3292db05198 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -147,6 +147,7 @@ struct neigh_table nd_tbl = {
 	.gc_thresh2 =	 512,
 	.gc_thresh3 =	1024,
 };
+EXPORT_SYMBOL_GPL(nd_tbl);
 
 static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
 {
-- 
1.9.1
