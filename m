From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Sparse fixes for NETROM
Date: Wed, 2 Mar 2005 21:47:53 +0100
Message-ID: <20050302204753.GA5985@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Moving nr_init_timers prototype to where all the other prototypes
already are.

Index: bk-afu/include/net/netrom.h
===================================================================
--- bk-afu.orig/include/net/netrom.h	2005-03-01 00:49:26.108296048 +0000
+++ bk-afu/include/net/netrom.h	2005-03-01 00:54:52.707645400 +0000
@@ -221,6 +221,7 @@
 extern void nr_disconnect(struct sock *, int);
 
 /* nr_timer.c */
+extern void nr_init_timers(struct sock *sk);
 extern void nr_start_heartbeat(struct sock *);
 extern void nr_start_t1timer(struct sock *);
 extern void nr_start_t2timer(struct sock *);
Index: bk-afu/net/netrom/af_netrom.c
===================================================================
--- bk-afu.orig/net/netrom/af_netrom.c	2005-03-01 00:49:26.088299088 +0000
+++ bk-afu/net/netrom/af_netrom.c	2005-03-01 00:55:31.325774552 +0000
@@ -63,7 +63,6 @@
 static DEFINE_SPINLOCK(nr_list_lock);
 
 static struct proto_ops nr_proto_ops;
-void nr_init_timers(struct sock *sk);
 
 static struct sock *nr_alloc_sock(void)
 {
