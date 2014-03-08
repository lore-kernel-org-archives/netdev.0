From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] igb: fix warning if !CONFIG_IGB_HWMON
Date: Sat,  8 Mar 2014 01:25:41 -0800
Message-ID: <1394270741-29926-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23968 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645AbaCHJ0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:26:04 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning about code defined but never used if IGB_HWMON not defined.

Reported-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 1da4e87..fa36fe1 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2711,6 +2711,7 @@ static const u8 e1000_emc_therm_limit[4] = {
 	E1000_EMC_DIODE3_THERM_LIMIT
 };
 
+#ifdef CONFIG_IGB_HWMON
 /**
  *  igb_get_thermal_sensor_data_generic - Gathers thermal sensor data
  *  @hw: pointer to hardware structure
@@ -2833,6 +2834,7 @@ static s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw)
 	return status;
 }
 
+#endif
 static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.init_hw              = igb_init_hw_82575,
 	.check_for_link       = igb_check_for_link_82575,
-- 
1.8.3.1
