From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] mark vcc_remove_socket static
Date: Sun, 24 Oct 2004 15:26:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024132642.GA20003@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- 1.33/include/linux/atmdev.h	2004-10-21 06:51:48 +02:00
+++ edited/include/linux/atmdev.h	2004-10-23 16:06:06 +02:00
@@ -395,7 +395,6 @@
 void atm_dev_deregister(struct atm_dev *dev);
 void shutdown_atm_dev(struct atm_dev *dev);
 void vcc_insert_socket(struct sock *sk);
-void vcc_remove_socket(struct sock *sk);
 
 
 /*
--- 1.55/net/atm/common.c	2004-10-21 06:50:41 +02:00
+++ edited/net/atm/common.c	2004-10-23 16:06:20 +02:00
@@ -57,7 +57,7 @@
 	write_unlock_irq(&vcc_sklist_lock);
 }
 
-void vcc_remove_socket(struct sock *sk)
+static void vcc_remove_socket(struct sock *sk)
 {
 	write_lock_irq(&vcc_sklist_lock);
 	sk_del_node_init(sk);
@@ -86,7 +86,6 @@
 EXPORT_SYMBOL(vcc_hash);
 EXPORT_SYMBOL(vcc_sklist_lock);
 EXPORT_SYMBOL(vcc_insert_socket);
-EXPORT_SYMBOL(vcc_remove_socket);
 
 static void vcc_sock_destruct(struct sock *sk)
 {
