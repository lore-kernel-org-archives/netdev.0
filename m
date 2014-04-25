From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/13] igb: Cleanups to fix assignment in if error
Date: Thu, 24 Apr 2014 18:02:54 -0700
Message-ID: <1398387783-30414-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58806 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906AbaDYBDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 21:03:17 -0400
In-Reply-To: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes ERROR:ASSIGN_IN_IF found with checkpatch file check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 299ac14..6469f97 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4056,7 +4056,8 @@ static void igb_check_wvbr(struct igb_adapter *adapter)
 	switch (hw->mac.type) {
 	case e1000_82576:
 	case e1000_i350:
-		if (!(wvbr = rd32(E1000_WVBR)))
+		wvbr = rd32(E1000_WVBR);
+		if (!wvbr)
 			return;
 		break;
 	default:
-- 
1.9.0
