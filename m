From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 3/9] e1000: Move extern function definitions to
	e1000.h
Date: Fri, 11 Jul 2008 15:17:13 -0700
Message-ID: <20080711221713.3255.5508.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5313 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756536AbYGKWRP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:15 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h         |   11 ++++++++++-
 drivers/net/e1000/e1000_ethtool.c |   13 -------------
 2 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 31feae1..20188af 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -353,9 +353,18 @@ enum e1000_state_t {
 extern char e1000_driver_name[];
 extern const char e1000_driver_version[];
 
+extern int e1000_up(struct e1000_adapter *adapter);
+extern void e1000_down(struct e1000_adapter *adapter);
+extern void e1000_reinit_locked(struct e1000_adapter *adapter);
+extern void e1000_reset(struct e1000_adapter *adapter);
+extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
+extern int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
+extern int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
+extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
+extern void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
+extern void e1000_update_stats(struct e1000_adapter *adapter);
 extern void e1000_power_up_phy(struct e1000_adapter *);
 extern void e1000_set_ethtool_ops(struct net_device *netdev);
 extern void e1000_check_options(struct e1000_adapter *adapter);
 
-
 #endif /* _E1000_H_ */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 966d52a..e262605 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -29,21 +29,8 @@
 /* ethtool support for e1000 */
 
 #include "e1000.h"
-
 #include <asm/uaccess.h>
 
-extern int e1000_up(struct e1000_adapter *adapter);
-extern void e1000_down(struct e1000_adapter *adapter);
-extern void e1000_reinit_locked(struct e1000_adapter *adapter);
-extern void e1000_reset(struct e1000_adapter *adapter);
-extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
-extern int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
-extern int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
-extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
-extern void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
-extern void e1000_update_stats(struct e1000_adapter *adapter);
-
-
 struct e1000_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;

