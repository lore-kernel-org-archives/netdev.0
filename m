From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] mark inet_family_ops static
Date: Tue, 7 Sep 2004 17:19:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907151918.GB9735@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

except for a stale extern in net/sctp/protocol.c it's not referenced
anywhere outside af_inet.c


--- 1.74/net/ipv4/af_inet.c	2004-07-07 07:01:31 +02:00
+++ edited/net/ipv4/af_inet.c	2004-09-07 13:47:22 +02:00
@@ -837,7 +837,7 @@
 	.sendpage =	inet_sendpage,
 };
 
-struct net_proto_family inet_family_ops = {
+static struct net_proto_family inet_family_ops = {
 	.family = PF_INET,
 	.create = inet_create,
 	.owner	= THIS_MODULE,
@@ -1157,7 +1157,6 @@
 EXPORT_SYMBOL(inet_bind);
 EXPORT_SYMBOL(inet_dgram_connect);
 EXPORT_SYMBOL(inet_dgram_ops);
-EXPORT_SYMBOL(inet_family_ops);
 EXPORT_SYMBOL(inet_getname);
 EXPORT_SYMBOL(inet_ioctl);
 EXPORT_SYMBOL(inet_listen);
--- 1.72/net/sctp/protocol.c	2004-08-13 01:41:13 +02:00
+++ edited/net/sctp/protocol.c	2004-09-07 13:47:08 +02:00
@@ -81,8 +81,6 @@
 kmem_cache_t *sctp_chunk_cachep;
 kmem_cache_t *sctp_bucket_cachep;
 
-extern struct net_proto_family inet_family_ops;
-
 extern int sctp_snmp_proc_init(void);
 extern int sctp_snmp_proc_exit(void);
 extern int sctp_eps_proc_init(void);
