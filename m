From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] ixgbevf: Message formatting cleanups
Date: Fri, 19 Mar 2010 06:00:31 -0700
Message-ID: <20100319130031.9799.3151.stgit@localhost.localdomain>
References: <20100319125950.9799.70157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:38062
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752289Ab0CSNAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 09:00:49 -0400
In-Reply-To: <20100319125950.9799.70157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Clean up some text output formatting.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 3de93ae..d6cbd94 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2419,7 +2419,7 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 		if (!netif_carrier_ok(netdev)) {
 			hw_dbg(&adapter->hw, "NIC Link is Up %s, ",
 			       ((link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-				"10 Gbps" : "1 Gbps"));
+				"10 Gbps\n" : "1 Gbps\n"));
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 		} else {
@@ -2695,7 +2695,7 @@ static int ixgbevf_open(struct net_device *netdev)
 		if (hw->adapter_stopped) {
 			err = IXGBE_ERR_MBX;
 			printk(KERN_ERR "Unable to start - perhaps the PF"
-			       "Driver isn't up yet\n");
+			       " Driver isn't up yet\n");
 			goto err_setup_reset;
 		}
 	}

