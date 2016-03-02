From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] act_ife: fix a typo in kmemdup() parameters
Date: Wed,  2 Mar 2016 11:20:36 -0800
Message-ID: <1456946436-31494-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36246 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbcCBTUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:20:42 -0500
Received: by mail-pa0-f51.google.com with SMTP id a9so16143662pat.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 11:20:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_ife.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 6e7ec25..c589a9b 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -108,7 +108,7 @@ EXPORT_SYMBOL_GPL(ife_get_meta_u16);
 
 int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval)
 {
-	mi->metaval = kmemdup(&metaval, sizeof(u32), GFP_KERNEL);
+	mi->metaval = kmemdup(metaval, sizeof(u32), GFP_KERNEL);
 	if (!mi->metaval)
 		return -ENOMEM;
 
@@ -118,7 +118,7 @@ EXPORT_SYMBOL_GPL(ife_alloc_meta_u32);
 
 int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval)
 {
-	mi->metaval = kmemdup(&metaval, sizeof(u16), GFP_KERNEL);
+	mi->metaval = kmemdup(metaval, sizeof(u16), GFP_KERNEL);
 	if (!mi->metaval)
 		return -ENOMEM;
 
-- 
2.1.0
