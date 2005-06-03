From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/4] [PKT_SCHED] Dump classification result for basic classifier
Date: Fri, 03 Jun 2005 23:12:44 +0200
Message-ID: <20050603211315.818843000@axs>
References: <20050603211241.593114000@axs>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline; filename=cls_basic_dump_classid
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: ematch/net/sched/cls_basic.c
===================================================================
--- ematch.orig/net/sched/cls_basic.c
+++ ematch/net/sched/cls_basic.c
@@ -261,6 +261,9 @@ static int basic_dump(struct tcf_proto *
 	rta = (struct rtattr *) b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
+	if (f->res.classid)
+		RTA_PUT_U32(skb, TCA_BASIC_CLASSID, f->res.classid);
+
 	if (tcf_exts_dump(skb, &f->exts, &basic_ext_map) < 0 ||
 	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
 		goto rtattr_failure;
