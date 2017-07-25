From: martinbj2008@gmail.com
Subject: [PATCH v2 net-next 5/5] drop_monitor: increase version when ns support is ready
Date: Tue, 25 Jul 2017 19:38:59 +0800
Message-ID: <1500982739-15805-5-git-send-email-zhangjunweimartin@didichuxing.com>
References: <1499855478-29736-1-git-send-email-zhangjunweimartin@didichuxing.com>
 <1500982739-15805-1-git-send-email-zhangjunweimartin@didichuxing.com>
Cc: netdev@vger.kernel.org,
        martin Zhang <zhangjunweimartin@didichuxing.com>
To: martinbj2008@gmail.com, davem@davemloft.net, nhorman@tuxdriver.com,
        xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38153 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdGYLjY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:39:24 -0400
Received: by mail-pg0-f65.google.com with SMTP id 125so795984pgi.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 04:39:24 -0700 (PDT)
In-Reply-To: <1500982739-15805-1-git-send-email-zhangjunweimartin@didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martin Zhang <zhangjunweimartin@didichuxing.com>

1. increase DM netlink version from 2 to 3, as it now support net ns.
2. netns ok become ture.

Signed-off-by: martin Zhang <zhangjunweimartin@didichuxing.com>
---
 net/core/drop_monitor.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index da0c88b..1892894 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -489,7 +489,8 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 static struct genl_family net_drop_monitor_family __ro_after_init = {
 	.hdrsize        = 0,
 	.name           = "NET_DM",
-	.version        = 2,
+	.version        = 3,
+	.netnsok        = 1,
 	.module		= THIS_MODULE,
 	.ops		= dropmon_ops,
 	.n_ops		= ARRAY_SIZE(dropmon_ops),
-- 
1.8.3.1
