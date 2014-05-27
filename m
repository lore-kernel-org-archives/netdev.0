From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] e1000e: Cleanup parenthesis around return value
Date: Tue, 27 May 2014 02:12:26 -0700
Message-ID: <1401181951-31358-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17026 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169AbaE0JMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:43 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index b75862d..8894ab8 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1637,9 +1637,9 @@ static bool e1000_check_mng_mode_ich8lan(struct e1000_hw *hw)
 	u32 fwsm;
 
 	fwsm = er32(FWSM);
-	return ((fwsm & E1000_ICH_FWSM_FW_VALID) &&
+	return (fwsm & E1000_ICH_FWSM_FW_VALID) &&
 		((fwsm & E1000_FWSM_MODE_MASK) ==
-		 (E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT)));
+		 (E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT));
 }
 
 /**
-- 
1.9.3
