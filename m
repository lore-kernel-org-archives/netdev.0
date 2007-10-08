From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/2] af_iucv: remove static declarations from header file.
Date: Mon, 08 Oct 2007 10:51:20 +0200
Message-ID: <20071008085506.461897000@linux.vnet.ibm.com>
References: <20071008085119.805528000@linux.vnet.ibm.com>
Cc: heicars2@linux.vnet.ibm.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:37903 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbXJHIzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 04:55:09 -0400
Content-Disposition: inline; filename=711-afiucv-statics.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 include/net/iucv/af_iucv.h |   20 --------------------
 net/iucv/af_iucv.c         |    3 +++
 2 files changed, 3 insertions(+), 20 deletions(-)

Index: net-2.6.24-uschi/include/net/iucv/af_iucv.h
===================================================================
--- net-2.6.24-uschi.orig/include/net/iucv/af_iucv.h
+++ net-2.6.24-uschi/include/net/iucv/af_iucv.h
@@ -74,28 +74,8 @@ struct iucv_sock_list {
 	atomic_t	  autobind_name;
 };
 
-static void iucv_sock_destruct(struct sock *sk);
-static void iucv_sock_cleanup_listen(struct sock *parent);
-static void iucv_sock_kill(struct sock *sk);
-static void iucv_sock_close(struct sock *sk);
-static int  iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
-			int addr_len);
-static int  iucv_sock_connect(struct socket *sock, struct sockaddr *addr,
-			      int alen, int flags);
-static int  iucv_sock_listen(struct socket *sock, int backlog);
-static int  iucv_sock_accept(struct socket *sock, struct socket *newsock,
-			     int flags);
-static int  iucv_sock_getname(struct socket *sock, struct sockaddr *addr,
-			      int *len, int peer);
-static int  iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t len);
-static int  iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t len, int flags);
 unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 			    poll_table *wait);
-static int iucv_sock_release(struct socket *sock);
-static int iucv_sock_shutdown(struct socket *sock, int how);
-
 void iucv_sock_link(struct iucv_sock_list *l, struct sock *s);
 void iucv_sock_unlink(struct iucv_sock_list *l, struct sock *s);
 int  iucv_sock_wait_state(struct sock *sk, int state, int state2,
Index: net-2.6.24-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6.24-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6.24-uschi/net/iucv/af_iucv.c
@@ -41,6 +41,9 @@ static struct proto iucv_proto = {
 	.obj_size	= sizeof(struct iucv_sock),
 };
 
+static void iucv_sock_kill(struct sock *sk);
+static void iucv_sock_close(struct sock *sk);
+
 /* Call Back functions */
 static void iucv_callback_rx(struct iucv_path *, struct iucv_message *);
 static void iucv_callback_txdone(struct iucv_path *, struct iucv_message *);

-- 
