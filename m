From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] i40e/i40evf: Explicitly assign enum index for VSI type
Date: Thu,  8 Oct 2015 18:32:47 -0700
Message-ID: <1444354374-24351-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Serey Kong <serey.kong@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54300 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755265AbbJIBc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:59 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serey Kong <serey.kong@intel.com>

Ran into an issue where PF's VSI type list was different from VF's,
which was resulted in different enum index. The VSI type list can
be different depending on what build flag is used for PF and VF.

The change is to explicitly assign enum index for each VSI type
so that PF and VF always reference to the same VSI type event if the
enum lists are different.

Change-ID: I8c0e5fdb515f324f7964df863a458073cf467e57
Signed-off-by: Serey Kong <serey.kong@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 16 ++++++++--------
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 16 ++++++++--------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 1c0bedb..d1ec5a4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -160,14 +160,14 @@ enum i40e_set_fc_aq_failures {
 };
 
 enum i40e_vsi_type {
-	I40E_VSI_MAIN = 0,
-	I40E_VSI_VMDQ1,
-	I40E_VSI_VMDQ2,
-	I40E_VSI_CTRL,
-	I40E_VSI_FCOE,
-	I40E_VSI_MIRROR,
-	I40E_VSI_SRIOV,
-	I40E_VSI_FDIR,
+	I40E_VSI_MAIN	= 0,
+	I40E_VSI_VMDQ1	= 1,
+	I40E_VSI_VMDQ2	= 2,
+	I40E_VSI_CTRL	= 3,
+	I40E_VSI_FCOE	= 4,
+	I40E_VSI_MIRROR	= 5,
+	I40E_VSI_SRIOV	= 6,
+	I40E_VSI_FDIR	= 7,
 	I40E_VSI_TYPE_UNKNOWN
 };
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 4b5528d..a59b60f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -160,14 +160,14 @@ enum i40e_set_fc_aq_failures {
 };
 
 enum i40e_vsi_type {
-	I40E_VSI_MAIN = 0,
-	I40E_VSI_VMDQ1,
-	I40E_VSI_VMDQ2,
-	I40E_VSI_CTRL,
-	I40E_VSI_FCOE,
-	I40E_VSI_MIRROR,
-	I40E_VSI_SRIOV,
-	I40E_VSI_FDIR,
+	I40E_VSI_MAIN	= 0,
+	I40E_VSI_VMDQ1	= 1,
+	I40E_VSI_VMDQ2	= 2,
+	I40E_VSI_CTRL	= 3,
+	I40E_VSI_FCOE	= 4,
+	I40E_VSI_MIRROR	= 5,
+	I40E_VSI_SRIOV	= 6,
+	I40E_VSI_FDIR	= 7,
 	I40E_VSI_TYPE_UNKNOWN
 };
 
-- 
2.4.3
