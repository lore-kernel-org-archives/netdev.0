From: akpm@linux-foundation.org
Subject: [patch 7/8] net/ipv4/netfilter/ip_tables.c: lower printk severity
Date: Mon, 09 Jul 2007 11:51:13 -0700
Message-ID: <200707091851.l69IpDYm001743@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	da-x@monatomic.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60889 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757843AbXGISvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:51:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Aloni <da-x@monatomic.org>

Signed-off-by: Dan Aloni <da-x@monatomic.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv4/netfilter/ip_tables.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipv4/netfilter/ip_tables.c~net-ipv4-netfilter-ip_tablesc-lower-printk-severity net/ipv4/netfilter/ip_tables.c
--- a/net/ipv4/netfilter/ip_tables.c~net-ipv4-netfilter-ip_tablesc-lower-printk-severity
+++ a/net/ipv4/netfilter/ip_tables.c
@@ -2331,7 +2331,7 @@ static int __init ip_tables_init(void)
 	if (ret < 0)
 		goto err5;
 
-	printk("ip_tables: (C) 2000-2006 Netfilter Core Team\n");
+	printk(KERN_INFO "ip_tables: (C) 2000-2006 Netfilter Core Team\n");
 	return 0;
 
 err5:
_
