From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] e1000e: cosmetic change to boolean comparisons
Date: Fri, 24 Feb 2012 02:13:06 -0800
Message-ID: <1330078389-8203-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756843Ab2BXKNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:18 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Recent discussions on LKML, kernel-janitors, linux-wireless and netdev
have suggested boolean comparisons should use logical operators instead of
equality comparisons with true/false.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index bc960fe..3c2daa7 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -458,7 +458,7 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		return ret_val;
 	}
 
-	if (hw->dev_spec.e80003es2lan.mdic_wa_enable == true) {
+	if (hw->dev_spec.e80003es2lan.mdic_wa_enable) {
 		/*
 		 * The "ready" bit in the MDIC register may be incorrectly set
 		 * before the device has completed the "Page Select" MDI
@@ -529,7 +529,7 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		return ret_val;
 	}
 
-	if (hw->dev_spec.e80003es2lan.mdic_wa_enable == true) {
+	if (hw->dev_spec.e80003es2lan.mdic_wa_enable) {
 		/*
 		 * The "ready" bit in the MDIC register may be incorrectly set
 		 * before the device has completed the "Page Select" MDI
-- 
1.7.7.6
