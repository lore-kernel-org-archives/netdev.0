From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] e1000e: potentially incorrect return for e1000_init_hw_ich8lan
Date: Mon, 13 Feb 2012 13:47:48 -0800
Message-ID: <1329169670-5403-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45312 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754393Ab2BMVsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:48:00 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

In the unlikely event that e1000_setup_link_ich8lan() returns an error,
the returned error code value is not propagated to the caller of
e1000_init_hw_ich8lan().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e2c546d..c4d65b8 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3276,7 +3276,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	 */
 	e1000_clear_hw_cntrs_ich8lan(hw);
 
-	return 0;
+	return ret_val;
 }
 /**
  *  e1000_initialize_hw_bits_ich8lan - Initialize required hardware bits
-- 
1.7.7.6
