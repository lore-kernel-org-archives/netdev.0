From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Utilize dsa_slave_dev_check()
Date: Tue, 19 Sep 2017 18:00:37 -0700
Message-ID: <20170920010038.12393-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of open coding the check.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d51b10450e1b..6fc9eb094267 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1294,7 +1294,7 @@ static int dsa_slave_netdevice_event(struct notifier_block *nb,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
-	if (dev->netdev_ops != &dsa_slave_netdev_ops)
+	if (!dsa_slave_dev_check(dev))
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_CHANGEUPPER)
-- 
2.9.3
