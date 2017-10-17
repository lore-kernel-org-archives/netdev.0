From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: remove ifdef SPEED_25000
Date: Tue, 17 Oct 2017 11:21:06 -0700
Message-ID: <20171017182119.71989-3-jeffrey.t.kirsher@intel.com>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39952 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934568AbdJQSVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:42 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This 'ifdef' doesn't accomplish anything so remove it.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 06514a76ff91..c250116e5e22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -531,12 +531,7 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		ks->base.speed = SPEED_40000;
 		break;
 	case I40E_LINK_SPEED_25GB:
-#ifdef SPEED_25000
 		ks->base.speed = SPEED_25000;
-#else
-		netdev_info(netdev,
-			    "Speed is 25G, display not supported by this version of ethtool.\n");
-#endif
 		break;
 	case I40E_LINK_SPEED_20GB:
 		ks->base.speed = SPEED_20000;
-- 
2.14.2
