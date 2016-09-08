From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] qede: mark qede_set_features() static
Date: Thu,  8 Sep 2016 16:43:23 +0800
Message-ID: <1473324203-9065-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/net/ethernet/qlogic/qede/qede_main.c:2113:5: warning: no previous prototype for 'qede_set_features' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index e4bd02e..4d2ce65 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2110,7 +2110,7 @@ static void qede_vlan_mark_nonconfigured(struct qede_dev *edev)
 	edev->accept_any_vlan = false;
 }
 
-int qede_set_features(struct net_device *dev, netdev_features_t features)
+static int qede_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 	netdev_features_t changes = features ^ dev->features;
-- 
2.7.4
