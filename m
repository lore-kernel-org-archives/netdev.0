From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/13] igb: Replace 1/0 return values with true/false
Date: Thu, 24 Apr 2014 18:03:02 -0700
Message-ID: <1398387783-30414-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbaDYBDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 21:03:21 -0400
In-Reply-To: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes issues found by updated coccicheck.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index f1c01be..333a2b0 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1206,11 +1206,11 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 				"pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
 				reg, val, (_test[pat] & write & mask));
 			*data = reg;
-			return 1;
+			return true;
 		}
 	}
 
-	return 0;
+	return false;
 }
 
 static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
@@ -1226,10 +1226,10 @@ static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 			"set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
 			reg, (val & mask), (write & mask));
 		*data = reg;
-		return 1;
+		return true;
 	}
 
-	return 0;
+	return false;
 }
 
 #define REG_PATTERN_TEST(reg, mask, write) \
-- 
1.9.0
