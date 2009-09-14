From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: constify remaining proto_ops
Date: Tue, 15 Sep 2009 02:23:23 +0400
Message-ID: <20090914222323.GC31565@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:40370 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755116AbZINW3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 18:29:46 -0400
Received: by ey-out-2122.google.com with SMTP id 25so682942eya.19
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 15:29:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/pppol2tp.c |    4 ++--
 net/dccp/ipv6.c        |    2 +-
 net/iucv/af_iucv.c     |    4 ++--
 net/rds/af_rds.c       |    2 +-
 net/rose/af_rose.c     |    4 ++--
 5 files changed, 8 insertions(+), 8 deletions(-)

--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -229,7 +229,7 @@ static void pppol2tp_tunnel_free(struct pppol2tp_tunnel *tunnel);
 static atomic_t pppol2tp_tunnel_count;
 static atomic_t pppol2tp_session_count;
 static struct ppp_channel_ops pppol2tp_chan_ops = { pppol2tp_xmit , NULL };
-static struct proto_ops pppol2tp_ops;
+static const struct proto_ops pppol2tp_ops;
 
 /* per-net private data for this module */
 static int pppol2tp_net_id;
@@ -2574,7 +2574,7 @@ static const struct file_operations pppol2tp_proc_fops = {
  * Init and cleanup
  *****************************************************************************/
 
-static struct proto_ops pppol2tp_ops = {
+static const struct proto_ops pppol2tp_ops = {
 	.family		= AF_PPPOX,
 	.owner		= THIS_MODULE,
 	.release	= pppol2tp_release,
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1158,7 +1158,7 @@ static const struct inet6_protocol dccp_v6_protocol = {
 	.flags		= INET6_PROTO_NOPOLICY | INET6_PROTO_FINAL,
 };
 
-static struct proto_ops inet6_dccp_ops = {
+static const struct proto_ops inet6_dccp_ops = {
 	.family		   = PF_INET6,
 	.owner		   = THIS_MODULE,
 	.release	   = inet6_release,
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -34,7 +34,7 @@
 
 static char iucv_userid[80];
 
-static struct proto_ops iucv_sock_ops;
+static const struct proto_ops iucv_sock_ops;
 
 static struct proto iucv_proto = {
 	.name		= "AF_IUCV",
@@ -1682,7 +1682,7 @@ static void iucv_callback_shutdown(struct iucv_path *path, u8 ipuser[16])
 	bh_unlock_sock(sk);
 }
 
-static struct proto_ops iucv_sock_ops = {
+static const struct proto_ops iucv_sock_ops = {
 	.family		= PF_IUCV,
 	.owner		= THIS_MODULE,
 	.release	= iucv_sock_release,
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -359,7 +359,7 @@ static struct proto rds_proto = {
 	.obj_size = sizeof(struct rds_sock),
 };
 
-static struct proto_ops rds_proto_ops = {
+static const struct proto_ops rds_proto_ops = {
 	.family =	AF_RDS,
 	.owner =	THIS_MODULE,
 	.release =	rds_release,
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -63,7 +63,7 @@ int sysctl_rose_window_size             = ROSE_DEFAULT_WINDOW_SIZE;
 static HLIST_HEAD(rose_list);
 static DEFINE_SPINLOCK(rose_list_lock);
 
-static struct proto_ops rose_proto_ops;
+static const struct proto_ops rose_proto_ops;
 
 ax25_address rose_callsign;
 
@@ -1515,7 +1515,7 @@ static struct net_proto_family rose_family_ops = {
 	.owner		=	THIS_MODULE,
 };
 
-static struct proto_ops rose_proto_ops = {
+static const struct proto_ops rose_proto_ops = {
 	.family		=	PF_ROSE,
 	.owner		=	THIS_MODULE,
 	.release	=	rose_release,
