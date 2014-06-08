From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40evf: remove bogus comment
Date: Sun,  8 Jun 2014 07:33:47 -0700
Message-ID: <1402238037-20661-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64912 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbaFHOeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:04 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This comment is just plain false. VF drivers require MSI-X or they won't
get interrupts at all.

Change-ID: Iaea5e30b6926948aa834a3c506d9a9223d9e3e29
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 360a911..c8ad838 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1130,9 +1130,6 @@ static int i40evf_set_interrupt_capability(struct i40evf_adapter *adapter)
 	v_budget = min_t(int, pairs, (int)(num_online_cpus() * 2)) + NONQ_VECS;
 	v_budget = min_t(int, v_budget, (int)adapter->vf_res->max_vectors);
 
-	/* A failure in MSI-X entry allocation isn't fatal, but it does
-	 * mean we disable MSI-X capabilities of the adapter.
-	 */
 	adapter->msix_entries = kcalloc(v_budget,
 					sizeof(struct msix_entry), GFP_KERNEL);
 	if (!adapter->msix_entries) {
-- 
1.9.3
