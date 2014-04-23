From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] ixgbevf: remove 82599 from the module description
Date: Wed, 23 Apr 2014 04:15:18 -0700
Message-ID: <1398251726-13638-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038AbaDWLPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:35 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch removes 82599 from the description of the ixgbevf module
since the VF driver is supported on other parts as well.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index d0799e8..eacce3a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -85,7 +85,7 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbevf_pci_tbl) = {
 MODULE_DEVICE_TABLE(pci, ixgbevf_pci_tbl);
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
-MODULE_DESCRIPTION("Intel(R) 82599 Virtual Function Driver");
+MODULE_DESCRIPTION("Intel(R) 10 Gigabit Virtual Function Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-- 
1.9.0
