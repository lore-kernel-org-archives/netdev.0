From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/sunrpc/rpcb_clnt.c: make struct rpcb_program static
Date: Wed, 13 Jun 2007 01:03:13 +0200
Message-ID: <20070612230313.GZ3588@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:33071 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753211AbXFLXDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 19:03:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global struct rpcb_program static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/sunrpc/rpcb_clnt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.22-rc4-mm2/net/sunrpc/rpcb_clnt.c.old	2007-06-12 23:25:01.000000000 +0200
+++ linux-2.6.22-rc4-mm2/net/sunrpc/rpcb_clnt.c	2007-06-12 23:25:19.000000000 +0200
@@ -118,7 +118,7 @@
 #define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
 
 static void			rpcb_getport_done(struct rpc_task *, void *);
-extern struct rpc_program	rpcb_program;
+static struct rpc_program	rpcb_program;
 
 struct rpcbind_args {
 	struct rpc_xprt *	r_xprt;
@@ -616,7 +616,7 @@
 
 static struct rpc_stat rpcb_stats;
 
-struct rpc_program rpcb_program = {
+static struct rpc_program rpcb_program = {
 	.name		= "rpcbind",
 	.number		= RPCBIND_PROGRAM,
 	.nrvers		= ARRAY_SIZE(rpcb_version),

