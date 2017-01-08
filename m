From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: [PATCH] cls_u32: don't bother explicitly initializing ->divisor to
 zero
Date: Sun, 8 Jan 2017 18:49:46 +0200
Message-ID: <20170108164946.GA10605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:36301 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752974AbdAHQtz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 11:49:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This struct member is already initialized to zero upon root_ht's
allocation via kzalloc().

Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
---
 net/sched/cls_u32.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index ae83c3ae..a6ec3e4b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -334,7 +334,6 @@ static int u32_init(struct tcf_proto *tp)
 	if (root_ht == NULL)
 		return -ENOBUFS;
 
-	root_ht->divisor = 0;
 	root_ht->refcnt++;
 	root_ht->handle = tp_c ? gen_new_htid(tp_c) : 0x80000000;
 	root_ht->prio = tp->prio;
-- 
2.1.4
