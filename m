From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 03/10] net: make net_class ro_after_init
Date: Fri, 18 Aug 2017 13:46:21 -0700
Message-ID: <20170818204628.17147-4-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35373 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751935AbdHRUqj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:39 -0400
Received: by mail-pg0-f42.google.com with SMTP id v189so70888033pgd.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:39 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The net_class in sysfs is only modified on init.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/net-sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 40937ee63f14..99061b0a1ebd 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1511,7 +1511,7 @@ static const void *net_namespace(struct device *d)
 	return dev_net(dev);
 }
 
-static struct class net_class = {
+static struct class net_class __ro_after_init = {
 	.name = "net",
 	.dev_release = netdev_release,
 	.dev_groups = net_class_groups,
-- 
2.11.0
