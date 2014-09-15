From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 4/5] net_sched: use tcindex_filter_result_init()
Date: Mon, 15 Sep 2014 14:06:49 -0700
Message-ID: <1410815210-6693-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:60642 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758976AbaIOVHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:07:09 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so7021501pdj.24
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:07:09 -0700 (PDT)
In-Reply-To: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index f276de5..4ec99a6 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -261,10 +261,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	}
 	cp->h = p->h;
 
-	memset(&new_filter_result, 0, sizeof(new_filter_result));
-	tcf_exts_init(&new_filter_result.exts,
-		      TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
-
+	tcindex_filter_result_init(&new_filter_result);
 	tcindex_filter_result_init(&cr);
 	if (old_r)
 		cr.res = r->res;
-- 
1.8.3.1
