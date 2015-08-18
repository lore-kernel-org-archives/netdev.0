From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbe: TRIVIAL fix up double 'the' and comment style
Date: Tue, 18 Aug 2015 14:09:22 -0700
Message-ID: <1439932162-1995-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63944 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868AbbHRVJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:28 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3e6a931..7906234 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -248,8 +248,7 @@ static void ixgbe_check_minimum_link(struct ixgbe_adapter *adapter,
 	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
 	struct pci_dev *pdev;
 
-	/* determine whether to use the the parent device
-	 */
+	/* determine whether to use the parent device */
 	if (ixgbe_pcie_from_parent(&adapter->hw))
 		pdev = adapter->pdev->bus->parent->self;
 	else
-- 
2.4.3
