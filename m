From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] net/sched: act_mirred: remove duplicated include from act_mirred.c
Date: Mon,  6 Feb 2017 16:07:13 +0000
Message-ID: <20170206160713.7610-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35394 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752674AbdBFQHU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:07:20 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so7182797pfa.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 08:07:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Remove duplicated include.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/sched/act_mirred.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 84682f0..af49c7d 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -28,8 +28,6 @@
 #include <linux/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_mirred.h>
 
-#include <linux/if_arp.h>
-
 #define MIRRED_TAB_MASK     7
 static LIST_HEAD(mirred_list);
 static DEFINE_SPINLOCK(mirred_list_lock);
