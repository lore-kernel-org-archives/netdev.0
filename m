From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 01/10] e1000e: demote a debugging WARN to a debug log message
Date: Wed,  2 Nov 2011 17:19:52 -0700
Message-ID: <1320279601-1276-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248Ab1KCAUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:04 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This debugging message was recently added but it does not need to be as
alarming as a WARN.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 6a17c62..e2a80a2 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -866,8 +866,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	if (test_and_set_bit(__E1000_ACCESS_SHARED_RESOURCE,
 			     &hw->adapter->state)) {
-		WARN(1, "e1000e: %s: contention for Phy access\n",
-		     hw->adapter->netdev->name);
+		e_dbg("contention for Phy access\n");
 		return -E1000_ERR_PHY;
 	}
 
-- 
1.7.6.4
