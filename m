From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 06/14] i40evf: remove bogus comment
Date: Fri, 14 Feb 2014 14:58:00 -0800
Message-ID: <1392418688-23895-7-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33318 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059AbaBNXBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:20 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This comment is simply not true.

Change-ID: If006b02b60984601a24257a951ae873dff568008
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 682c341..a64570e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2050,7 +2050,6 @@ static void i40evf_init_task(struct work_struct *work)
 				    NETIF_F_HW_VLAN_CTAG_FILTER;
 	}
 
-	/* The HW MAC address was set and/or determined in sw_init */
 	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
 		dev_info(&pdev->dev, "Invalid MAC address %pMAC, using random.\n",
 			 adapter->hw.mac.addr);
-- 
1.8.5.GIT
