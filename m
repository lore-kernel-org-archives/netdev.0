From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] make tcf_proto_lookup_ops() static
Date: Thu, 21 Oct 2004 18:44:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021184426.L2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Make tcf_proto_lookup_ops() static, it's only used in cls_api.c.

Signed-off-by: Chris Wright <chrisw@osdl.org>

===== net/sched/cls_api.c 1.14 vs edited =====
--- 1.14/net/sched/cls_api.c	2004-10-20 01:37:15 -07:00
+++ edited/net/sched/cls_api.c	2004-10-21 18:35:52 -07:00
@@ -52,7 +52,7 @@
 
 /* Find classifier type by string name */
 
-struct tcf_proto_ops * tcf_proto_lookup_ops(struct rtattr *kind)
+static struct tcf_proto_ops * tcf_proto_lookup_ops(struct rtattr *kind)
 {
 	struct tcf_proto_ops *t = NULL;
 
