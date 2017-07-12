From: martinbj2008@gmail.com
Subject: [PATCH v1 net-next 5/5] drop_monitor: increase version when ns support is ready
Date: Wed, 12 Jul 2017 18:40:53 +0800
Message-ID: <1499856053-30475-5-git-send-email-zhangjunweimartin@didichuxing.com>
References: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
Cc: netdev@vger.kernel.org, martinbj2008@gmail.com,
        zhangjunweimartin@didichuxing.com
To: nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36178 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756342AbdGLKlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 06:41:25 -0400
Received: by mail-pg0-f66.google.com with SMTP id y129so2561830pgy.3
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 03:41:24 -0700 (PDT)
In-Reply-To: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
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
index 5828bf2..064128b 100644
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
