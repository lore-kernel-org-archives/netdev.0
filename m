From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 04/15] e1000e: checkpatch error - open braces
Date: Fri, 24 Dec 2010 22:06:03 -0800
Message-ID: <1293257174-15498-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271Ab0LYGGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:06:54 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

ERROR: that open brace { should be on the previous line

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/es2lan.c  |    4 ++--
 drivers/net/e1000e/ethtool.c |    4 ++--
 drivers/net/e1000e/phy.c     |   22 +++++++++++-----------
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 79da646..b18c644 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -100,8 +100,8 @@
  * with a lower bound at "index" and the upper bound at
  * "index + 5".
  */
-static const u16 e1000_gg82563_cable_length_table[] =
-	 { 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
+static const u16 e1000_gg82563_cable_length_table[] = {
+	 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
 #define GG82563_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_gg82563_cable_length_table)
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 15c6330..affcacf 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -753,8 +753,8 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 			     int reg, int offset, u32 mask, u32 write)
 {
 	u32 pat, val;
-	static const u32 test[] =
-		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+	static const u32 test[] = {
+		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {
 		E1000_WRITE_REG_ARRAY(&adapter->hw, reg, offset,
 				      (test[pat] & write));
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 95da386..e297a23 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -42,20 +42,20 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
                                           u16 *data, bool read);
 
 /* Cable length tables */
-static const u16 e1000_m88_cable_length_table[] =
-	{ 0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+static const u16 e1000_m88_cable_length_table[] = {
+	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
 #define M88E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_m88_cable_length_table)
 
-static const u16 e1000_igp_2_cable_length_table[] =
-	{ 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21, 0, 0, 0, 3,
-	  6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41, 6, 10, 14, 18, 22,
-	  26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61, 21, 26, 31, 35, 40,
-	  44, 49, 53, 57, 61, 65, 68, 72, 75, 79, 82, 40, 45, 51, 56, 61,
-	  66, 70, 75, 79, 83, 87, 91, 94, 98, 101, 104, 60, 66, 72, 77, 82,
-	  87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121, 83, 89, 95,
-	  100, 105, 109, 113, 116, 119, 122, 124, 104, 109, 114, 118, 121,
-	  124};
+static const u16 e1000_igp_2_cable_length_table[] = {
+	0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21, 0, 0, 0, 3,
+	6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41, 6, 10, 14, 18, 22,
+	26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61, 21, 26, 31, 35, 40,
+	44, 49, 53, 57, 61, 65, 68, 72, 75, 79, 82, 40, 45, 51, 56, 61,
+	66, 70, 75, 79, 83, 87, 91, 94, 98, 101, 104, 60, 66, 72, 77, 82,
+	87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121, 83, 89, 95,
+	100, 105, 109, 113, 116, 119, 122, 124, 104, 109, 114, 118, 121,
+	124};
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_igp_2_cable_length_table)
 
-- 
1.7.3.4

