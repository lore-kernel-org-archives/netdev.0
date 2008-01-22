From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/06]: mark classifier ops __read_mostly
Date: Tue, 22 Jan 2008 15:56:10 +0100 (MET)
Message-ID: <20080122145544.6862.41766.sendpatchset@localhost.localdomain>
References: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50738 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbYAVO4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:56:12 -0500
In-Reply-To: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: mark classifier ops __read_mostly

Additionally remove unnecessary NULL initilizations of the next pointer.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4cf7dba2c890608fee47fe46487c79abf322dc82
tree 4f29f07adbaf0dfe78f6148205644b6b2dbd1717
parent 8b868a47c5bedb1daa8534ae60c2d89fcad26781
author Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:30 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:30 +0100

 net/sched/cls_api.c     |    2 +-
 net/sched/cls_basic.c   |    2 +-
 net/sched/cls_fw.c      |    3 +--
 net/sched/cls_route.c   |    3 +--
 net/sched/cls_tcindex.c |    3 +--
 net/sched/cls_u32.c     |    3 +--
 6 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index e537736..9eeb3c6 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -31,7 +31,7 @@
 
 /* The list of all installed classifier types */
 
-static struct tcf_proto_ops *tcf_proto_base;
+static struct tcf_proto_ops *tcf_proto_base __read_mostly;
 
 /* Protects list of registered TC modules. It is pure SMP lock. */
 static DEFINE_RWLOCK(cls_mod_lock);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 8dbcf27..b31f9f9 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -271,7 +271,7 @@ rtattr_failure:
 	return -1;
 }
 
-static struct tcf_proto_ops cls_basic_ops = {
+static struct tcf_proto_ops cls_basic_ops __read_mostly = {
 	.kind		=	"basic",
 	.classify	=	basic_classify,
 	.init		=	basic_init,
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 8adbd6a..b450387 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -370,8 +370,7 @@ rtattr_failure:
 	return -1;
 }
 
-static struct tcf_proto_ops cls_fw_ops = {
-	.next		=	NULL,
+static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.kind		=	"fw",
 	.classify	=	fw_classify,
 	.init		=	fw_init,
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 0a8409c..e70edd0 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -590,8 +590,7 @@ rtattr_failure:
 	return -1;
 }
 
-static struct tcf_proto_ops cls_route4_ops = {
-	.next		=	NULL,
+static struct tcf_proto_ops cls_route4_ops __read_mostly = {
 	.kind		=	"route",
 	.classify	=	route4_classify,
 	.init		=	route4_init,
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 471909e..e36977b 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -485,8 +485,7 @@ rtattr_failure:
 	return -1;
 }
 
-static struct tcf_proto_ops cls_tcindex_ops = {
-	.next		=	NULL,
+static struct tcf_proto_ops cls_tcindex_ops __read_mostly = {
 	.kind		=	"tcindex",
 	.classify	=	tcindex_classify,
 	.init		=	tcindex_init,
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index c390082..7bf3cd4 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -751,8 +751,7 @@ rtattr_failure:
 	return -1;
 }
 
-static struct tcf_proto_ops cls_u32_ops = {
-	.next		=	NULL,
+static struct tcf_proto_ops cls_u32_ops __read_mostly = {
 	.kind		=	"u32",
 	.classify	=	u32_classify,
 	.init		=	u32_init,
