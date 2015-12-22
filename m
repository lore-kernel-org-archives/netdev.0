From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] net-sysfs: use to_net_dev in net_namespace()
Date: Tue, 22 Dec 2015 23:11:49 +0800
Message-ID: <d010715aeba7ecc4421b06b20f19c1f3958772db.1450796865.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use to_net_dev() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/core/net-sysfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index bca8c35..b6c8a66 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1453,8 +1453,8 @@ static void netdev_release(struct device *d)
 
 static const void *net_namespace(struct device *d)
 {
-	struct net_device *dev;
-	dev = container_of(d, struct net_device, dev);
+	struct net_device *dev = to_net_dev(d);
+
 	return dev_net(dev);
 }
 
-- 
2.5.0
