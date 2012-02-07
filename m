From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] e1000e: cleanup e1000_set_phys_id
Date: Tue,  7 Feb 2012 04:33:54 -0800
Message-ID: <1328618038-5008-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30741 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756133Ab2BGMeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:15 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Use the existing hw pointer.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index f43af46..fd2ba38 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1856,11 +1856,11 @@ static int e1000_set_phys_id(struct net_device *netdev,
 		break;
 
 	case ETHTOOL_ID_ON:
-		adapter->hw.mac.ops.led_on(&adapter->hw);
+		hw->mac.ops.led_on(hw);
 		break;
 
 	case ETHTOOL_ID_OFF:
-		adapter->hw.mac.ops.led_off(&adapter->hw);
+		hw->mac.ops.led_off(hw);
 		break;
 	}
 	return 0;
-- 
1.7.7.6
