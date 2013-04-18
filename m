From: dingtianhong <dingtianhong@huawei.com>
Subject: [PATCH] net: Remove return value from list_netdevice()
Date: Thu, 18 Apr 2013 16:17:50 +0800
Message-ID: <516FAC2E.8000602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:4242 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598Ab3DRISp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 04:18:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return value from list_netdevice() is not used and no need, so remove it.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/core/dev.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e7d68ed..58732dc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -200,7 +200,7 @@ static inline void rps_unlock(struct softnet_data *sd)
 }

 /* Device list insertion */
-static int list_netdevice(struct net_device *dev)
+static void list_netdevice(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);

@@ -214,8 +214,6 @@ static int list_netdevice(struct net_device *dev)
 	write_unlock_bh(&dev_base_lock);

 	dev_base_seq_inc(net);
-
-	return 0;
 }

 /* Device list removal
-- 
1.8.0
