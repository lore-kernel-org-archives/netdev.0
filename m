From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40e: Use new 40G speeds
Date: Tue, 14 Apr 2015 21:51:50 -0700
Message-ID: <1429073511-27664-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10570 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbbDOEwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:15 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The kernel has added SPEED_40000 for ethtool.
Go ahead and use the new #define.

Change-ID: Ic7e16e5c9e91085afe539f11ee1b7668adc4d0ef
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7d60587..4cbaaeb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -356,8 +356,7 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 	/* Set speed and duplex */
 	switch (link_speed) {
 	case I40E_LINK_SPEED_40GB:
-		/* need a SPEED_40000 in ethtool.h */
-		ethtool_cmd_speed_set(ecmd, 40000);
+		ethtool_cmd_speed_set(ecmd, SPEED_40000);
 		break;
 	case I40E_LINK_SPEED_20GB:
 		ethtool_cmd_speed_set(ecmd, SPEED_20000);
-- 
1.9.3
