From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] dummy: declare dummy devices as enumerated devices
Date: Tue, 12 Sep 2017 09:32:45 +0800
Message-ID: <1505179965-12117-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ezegomez@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:2852 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdILBcw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 21:32:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dummy device name is enumerated by the kernel, let user space be aware
of the naming scheme used by dummy devices:
(visible in /sys/class/net/<iface>/name_assign_type).

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/dummy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index d0a1f9c..e31ab3b 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -388,7 +388,7 @@ static int __init dummy_init_one(void)
 	int err;
 
 	dev_dummy = alloc_netdev(sizeof(struct dummy_priv),
-				 "dummy%d", NET_NAME_UNKNOWN, dummy_setup);
+				 "dummy%d", NET_NAME_ENUM, dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
 
-- 
1.8.3.1
