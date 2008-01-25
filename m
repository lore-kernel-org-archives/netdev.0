From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] [TIPC]: declare proto_ops structures as 'const'.
Date: Sat, 26 Jan 2008 00:37:53 +0100
Message-ID: <1201304273-21332-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Paul Maloy <jon.maloy@ericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:36787 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752266AbYAYXeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 18:34:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Allan Stephens <allan.stephens@windriver.com>
CC: Jon Paul Maloy <jon.maloy@ericsson.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/tipc/socket.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 24ddfd2..2290903 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -71,9 +71,9 @@ struct tipc_sock {
 static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf);
 static void wakeupdispatch(struct tipc_port *tport);
 
-static struct proto_ops packet_ops;
-static struct proto_ops stream_ops;
-static struct proto_ops msg_ops;
+static const struct proto_ops packet_ops;
+static const struct proto_ops stream_ops;
+static const struct proto_ops msg_ops;
 
 static struct proto tipc_proto;
 
@@ -1615,7 +1615,7 @@ static int getsockopt(struct socket *sock,
  * Protocol switches for the various types of TIPC sockets
  */
 
-static struct proto_ops msg_ops = {
+static const struct proto_ops msg_ops = {
 	.owner 		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.release	= release,
@@ -1636,7 +1636,7 @@ static struct proto_ops msg_ops = {
 	.sendpage	= sock_no_sendpage
 };
 
-static struct proto_ops packet_ops = {
+static const struct proto_ops packet_ops = {
 	.owner 		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.release	= release,
@@ -1657,7 +1657,7 @@ static struct proto_ops packet_ops = {
 	.sendpage	= sock_no_sendpage
 };
 
-static struct proto_ops stream_ops = {
+static const struct proto_ops stream_ops = {
 	.owner 		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.release	= release,
@@ -1678,7 +1678,7 @@ static struct proto_ops stream_ops = {
 	.sendpage	= sock_no_sendpage
 };
 
-static struct net_proto_family tipc_family_ops = {
+static const struct net_proto_family tipc_family_ops = {
 	.owner 		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.create		= tipc_create
-- 
1.5.3.7

