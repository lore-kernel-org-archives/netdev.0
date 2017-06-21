From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] iwlwifi: mvm: add const to thermal_cooling_device_ops structure
Date: Wed, 21 Jun 2017 14:10:42 +0530
Message-ID: <1498034442-17664-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, johannes.berg@intel.com,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        linuxwifi@intel.com, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare thermal_cooling_device_ops structure as const as it is only passed
as an argument to the function thermal_cooling_device_register and this
argument is of type const. So, declare the structure as const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/tt.c b/drivers/net/wireless/intel/iwlwifi/mvm/tt.c
index 453a785..0b5a177 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/tt.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/tt.c
@@ -813,7 +813,7 @@ static int iwl_mvm_tcool_set_cur_state(struct thermal_cooling_device *cdev,
 	return ret;
 }
 
-static struct thermal_cooling_device_ops tcooling_ops = {
+static const struct thermal_cooling_device_ops tcooling_ops = {
 	.get_max_state = iwl_mvm_tcool_get_max_state,
 	.get_cur_state = iwl_mvm_tcool_get_cur_state,
 	.set_cur_state = iwl_mvm_tcool_set_cur_state,
-- 
2.7.4
