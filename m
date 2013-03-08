From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] e1000e: cleanup formatting of static structs
Date: Fri,  8 Mar 2013 02:07:13 -0800
Message-ID: <1362737237-13363-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27095 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933944Ab3CHKHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:34 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c | 3 ++-
 drivers/net/ethernet/intel/e1000e/ethtool.c     | 3 ++-
 drivers/net/ethernet/intel/e1000e/phy.c         | 6 ++++--
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 303aa8a..30cf42c 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -37,7 +37,8 @@
  * "index + 5".
  */
 static const u16 e1000_gg82563_cable_length_table[] = {
-	 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
+	0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF
+};
 
 #define GG82563_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_gg82563_cable_length_table)
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 9dbf5d0..a63cb59 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -754,7 +754,8 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 {
 	u32 pat, val;
 	static const u32 test[] = {
-		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
+	};
 	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {
 		E1000_WRITE_REG_ARRAY(&adapter->hw, reg, offset,
 				      (test[pat] & write));
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 0a81d14..e071ef7 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -37,7 +37,8 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] = {
-	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED
+};
 
 #define M88E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_m88_cable_length_table)
@@ -50,7 +51,8 @@ static const u16 e1000_igp_2_cable_length_table[] = {
 	66, 70, 75, 79, 83, 87, 91, 94, 98, 101, 104, 60, 66, 72, 77, 82,
 	87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121, 83, 89, 95,
 	100, 105, 109, 113, 116, 119, 122, 124, 104, 109, 114, 118, 121,
-	124};
+	124
+};
 
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_igp_2_cable_length_table)
-- 
1.7.11.7
