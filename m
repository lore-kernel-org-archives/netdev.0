From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 07/14] i40evf: don't guess device name
Date: Fri, 14 Feb 2014 14:58:01 -0800
Message-ID: <1392418688-23895-8-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50864 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202AbaBNXB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:27 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

We don't need to set an interface name here; the net core will do
that, and then it will get renamed by udev anyway.

Change-ID: I839a17837d19bedd1f490bff32ac5b85b4bfd97f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index a64570e..4a75e84 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2086,8 +2086,6 @@ static void i40evf_init_task(struct work_struct *work)
 
 	netif_carrier_off(netdev);
 
-	strcpy(netdev->name, "eth%d");
-
 	adapter->vsi.id = adapter->vsi_res->vsi_id;
 	adapter->vsi.seid = adapter->vsi_res->vsi_id; /* dummy */
 	adapter->vsi.back = adapter;
-- 
1.8.5.GIT
