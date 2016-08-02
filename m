From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0707/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:38:33 +0800
Message-ID: <20160802113833.29188-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	grundler@chromium.org, lporzio@micron.com
To: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 941ec99..74f9c4b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -117,10 +117,10 @@ module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
 module_param(tx_queues, int, 0);
 MODULE_PARM_DESC(tx_queues, "Max number of transmit queues (default = 16)");
-module_param_named(num_grat_arp, num_peer_notif, int, 0644);
+module_param_named(num_grat_arp, num_peer_notif, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(num_grat_arp, "Number of peer notifications to send on "
 			       "failover event (alias of num_unsol_na)");
-module_param_named(num_unsol_na, num_peer_notif, int, 0644);
+module_param_named(num_unsol_na, num_peer_notif, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(num_unsol_na, "Number of peer notifications to send on "
 			       "failover event (alias of num_grat_arp)");
 module_param(miimon, int, 0);
-- 
2.9.2
