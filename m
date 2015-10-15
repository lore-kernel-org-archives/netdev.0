From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] i40e/i40evf: remove redundant declarations of a variable and a function
Date: Thu, 15 Oct 2015 02:39:58 -0700
Message-ID: <1444902004-14433-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17991 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416AbbJOJma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:30 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Remove a variable declaration inside an if block hiding an existing
declaration at the start of the function.

Also remove a forward function declaration that is no longer needed due
to code re-organization.

Change-ID: I12954668b722718074949c93d74cd20eaacd93e4
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  | 3 ---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b311391..ed70a3f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -90,9 +90,6 @@ static const struct i40e_stats i40e_gstrings_misc_stats[] = {
 	I40E_VSI_STAT("tx_linearize", tx_linearize),
 };
 
-static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
-				 struct ethtool_rxnfc *cmd);
-
 /* These PF_STATs might look like duplicates of some NETDEV_STATs,
  * but they are separate.  This device supports Virtualization, and
  * as such might have several netdevs supporting VMDq and FCoE going
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index feb9ad5..f156226 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1628,7 +1628,7 @@ static void i40evf_reset_task(struct work_struct *work)
 	/* extra wait to make sure minimum wait is met */
 	msleep(I40EVF_RESET_WAIT_MS);
 	if (i == I40EVF_RESET_WAIT_COUNT) {
-		struct i40evf_mac_filter *f, *ftmp;
+		struct i40evf_mac_filter *ftmp;
 		struct i40evf_vlan_filter *fv, *fvtmp;
 
 		/* reset never finished */
-- 
2.4.3
