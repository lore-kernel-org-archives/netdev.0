From: akpm@linux-foundation.org
Subject: [patch 2/4] make sunrpc/xprtsock.c:xs_setup_{udp,tcp}() static
Date: Wed, 21 Nov 2007 15:02:14 -0800
Message-ID: <200711212302.lALN2Eoj013604@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59126 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753237AbXKUXC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:02:29 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>

xs_setup_{udp,tcp}() can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/sunrpc/xprtsock.h |    6 ------
 net/sunrpc/xprtsock.c           |    4 ++--
 2 files changed, 2 insertions(+), 8 deletions(-)

diff -puN include/linux/sunrpc/xprtsock.h~make-sunrpc-xprtsockcxs_setup_udptcp-static include/linux/sunrpc/xprtsock.h
--- a/include/linux/sunrpc/xprtsock.h~make-sunrpc-xprtsockcxs_setup_udptcp-static
+++ a/include/linux/sunrpc/xprtsock.h
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
 
diff -puN net/sunrpc/xprtsock.c~make-sunrpc-xprtsockcxs_setup_udptcp-static net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c~make-sunrpc-xprtsockcxs_setup_udptcp-static
+++ a/net/sunrpc/xprtsock.c
@@ -1828,7 +1828,7 @@ static struct rpc_xprt *xs_setup_xprt(st
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
+static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
@@ -1894,7 +1894,7 @@ struct rpc_xprt *xs_setup_udp(struct xpr
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
+static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
_
