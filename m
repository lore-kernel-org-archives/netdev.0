From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] mac802154: fix sparse warning for mac802154_slave_get_priv
Date: Fri, 13 Jul 2012 23:36:10 +0300
Message-ID: <1342211770-4219-1-git-send-email-silviupopescu1990@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	alex.bluesman.smirnov@gmail.com,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sparse happy by fixing the following error:
	* symbol 'mac802154_slave_get_priv' was not declared. Should it be static?

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 net/mac802154/mib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index ab59821..1cf6557 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -34,7 +34,7 @@ struct hw_addr_filt_notify_work {
 	unsigned long changed;
 };
 
-struct mac802154_priv *mac802154_slave_get_priv(struct net_device *dev)
+static struct mac802154_priv *mac802154_slave_get_priv(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 
-- 
1.7.11-rc3
