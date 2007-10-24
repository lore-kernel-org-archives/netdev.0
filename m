From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make sunrpc/xprtsock.c:xs_setup_{udp,tcp}() static
Date: Wed, 24 Oct 2007 18:24:02 +0200
Message-ID: <20071024162402.GB30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>, Tom Talpey <tmt@netapp.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33365 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756474AbXJXQXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 12:23:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

xs_setup_{udp,tcp}() can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/sunrpc/xprtsock.h |    6 ------
 net/sunrpc/xprtsock.c           |    4 ++--
 2 files changed, 2 insertions(+), 8 deletions(-)

833a31c8caef70589f33be8e3a1fc9d8e01ce3c2 
diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 2c6c2c2..c2a46c4 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -9,12 +9,6 @@
 
 #ifdef __KERNEL__
 
-/*
- * Socket transport setup operations
- */
-struct rpc_xprt *xs_setup_udp(struct xprt_create *args);
-struct rpc_xprt *xs_setup_tcp(struct xprt_create *args);
-
 int		init_socket_xprt(void);
 void		cleanup_socket_xprt(void);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 02298f5..2f630a5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1828,7 +1828,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
+static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
@@ -1894,7 +1894,7 @@ struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
+static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;

