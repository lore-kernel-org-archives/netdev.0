From: roel kluin <roel.kluin@gmail.com>
Subject: [PATCH?] atl1e: WAKE_MCAST 2x. 1st WAKE_UCAST?
Date: Thu, 07 Aug 2008 12:24:42 -0400
Message-ID: <489B21CA.7010508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com, jgarzik@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754462AbYHGNNw@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

untested, is it right?
---
WAKE_MCAST bit tested twice, test WAKE_UCAST first.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index cdc3b85..619c658 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -355,7 +355,7 @@ static int atl1e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
-			    WAKE_MCAST | WAKE_BCAST | WAKE_MCAST))
+			    WAKE_UCAST | WAKE_MCAST | WAKE_BCAST))
 		return -EOPNOTSUPP;
 	/* these settings will always override what we currently have */
 	adapter->wol = 0;
