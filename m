From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove secure_ipv6_id
Date: Tue, 7 Sep 2004 17:17:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907151753.GA9735@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

looks like the ipv6 code doesn't need this one anymore


--- 1.54/drivers/char/random.c	2004-09-03 11:08:21 +02:00
+++ edited/drivers/char/random.c	2004-09-07 15:51:23 +02:00
@@ -2279,19 +2279,7 @@
 	return seq;
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);
-
-__u32 secure_ipv6_id(__u32 *daddr)
-{
-	struct keydata *keyptr;
-
-	keyptr = check_and_rekey(get_seconds());
-
-	return halfMD4Transform(daddr, keyptr->secret);
-}
-
-EXPORT_SYMBOL(secure_ipv6_id);
 #endif
-
 
 __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
 				 __u16 sport, __u16 dport)
--- 1.3/include/linux/random.h	2003-09-21 23:50:34 +02:00
+++ edited/include/linux/random.h	2004-09-07 14:07:58 +02:00
@@ -67,8 +67,6 @@
 extern __u32 secure_tcpv6_sequence_number(__u32 *saddr, __u32 *daddr,
 					  __u16 sport, __u16 dport);
 
-extern __u32 secure_ipv6_id(__u32 *daddr);
-
 #ifndef MODULE
 extern struct file_operations random_fops, urandom_fops;
 #endif
