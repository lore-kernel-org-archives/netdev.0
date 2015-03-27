From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] i40evf: add FW version to ethtool info
Date: Fri, 27 Mar 2015 03:02:52 -0700
Message-ID: <1427450573-13945-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13066 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207AbbC0KDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 06:03:18 -0400
In-Reply-To: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Customers reported that the firmware version information from i40evf
is unlike that of ixgbevf and was causing problems with their scripts.
To resolve this, populate the field to align with ixgbevf.

Change-ID: I9f4e24f6a76cd819bbe07087aab2b74f715ec103
Reported-by: Sourav Chatterjee <sourav.chatterjee@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index b68b731..f4e7766 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -209,7 +209,7 @@ static void i40evf_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->driver, i40evf_driver_name, 32);
 	strlcpy(drvinfo->version, i40evf_driver_version, 32);
-
+	strlcpy(drvinfo->fw_version, "N/A", 4);
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
 }
 
-- 
1.9.3
