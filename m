From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] igb: Use ARRAY_SIZE instead fo sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 10:25:30 +0530
Message-ID: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:57229 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbbF3Ezy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 00:55:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ARRAY_SIZE instead fo sizeof(a)/sizeof(a[0])

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Yogesh Narayan Gaur <yn.gaur@samsung.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index c1bb64d..e399b3c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -37,8 +37,7 @@ static s32  igb_set_master_slave_mode(struct e1000_hw *hw);
 static const u16 e1000_m88_cable_length_table[] = {
 	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
 #define M88E1000_CABLE_LENGTH_TABLE_SIZE \
-	(sizeof(e1000_m88_cable_length_table) / \
-	sizeof(e1000_m88_cable_length_table[0]))
+	ARRAY_SIZE(e1000_m88_cable_length_table)
 
 static const u16 e1000_igp_2_cable_length_table[] = {
 	0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
@@ -50,8 +49,7 @@ static const u16 e1000_igp_2_cable_length_table[] = {
 	83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
 	104, 109, 114, 118, 121, 124};
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
-	(sizeof(e1000_igp_2_cable_length_table) / \
-	 sizeof(e1000_igp_2_cable_length_table[0]))
+	ARRAY_SIZE(e1000_igp_2_cable_length_table)
 
 /**
  *  igb_check_reset_block - Check if PHY reset is blocked
-- 
1.7.9.5
