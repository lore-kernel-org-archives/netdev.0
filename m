From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove dead ipv6 exports
Date: Sun, 24 Oct 2004 15:41:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024134132.GA20267@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- 1.20/net/ipv6/ipv6_syms.c	2004-03-28 11:55:27 +02:00
+++ edited/net/ipv6/ipv6_syms.c	2004-10-23 14:16:58 +02:00
@@ -35,13 +35,9 @@
 EXPORT_SYMBOL(in6addr_any);
 EXPORT_SYMBOL(in6addr_loopback);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
-EXPORT_SYMBOL(ip6_find_1stfragopt);
 #ifdef CONFIG_XFRM
 EXPORT_SYMBOL(xfrm6_rcv);
 #endif
 EXPORT_SYMBOL(rt6_lookup);
 EXPORT_SYMBOL(fl6_sock_lookup);
-EXPORT_SYMBOL(ip6_append_data);
-EXPORT_SYMBOL(ip6_flush_pending_frames);
-EXPORT_SYMBOL(ip6_push_pending_frames);
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
