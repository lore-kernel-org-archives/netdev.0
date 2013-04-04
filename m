From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net_cls: remove duplicated include from cls_api.c
Date: Thu, 4 Apr 2013 09:21:22 +0800
Message-ID: <CAPgLHd8m+ZY0DO2BZq7jj3pNLDL0feaKMPgs9xPmen=mXyKe-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: jhs@mojatatu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47506 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932459Ab3DDBVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 21:21:23 -0400
Received: by mail-bk0-f46.google.com with SMTP id je9so1205290bkc.19
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 18:21:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/sched/cls_api.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 5c81b26..8e118af 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -22,7 +22,6 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
-#include <net/netlink.h>
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <net/net_namespace.h>
