From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/16] i40e: Use BIT() macro for priority map parsing
Date: Tue, 13 Oct 2015 23:59:43 -0700
Message-ID: <1444805996-3877-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47517 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020AbbJNG77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 02:59:59 -0400
In-Reply-To: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Replace one left over (1 << up) in the i40e_dcb.c file with the BIT()
macro.

Change-ID: I39492a400a2cee5ac566143a5b436cc478bea0db
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 6fa07ef..251a841 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -393,7 +393,7 @@ static void i40e_parse_cee_app_tlv(struct i40e_cee_feat_tlv *tlv,
 	for (i = 0; i < dcbcfg->numapps; i++) {
 		app = (struct i40e_cee_app_prio *)(tlv->tlvinfo + offset);
 		for (up = 0; up < I40E_MAX_USER_PRIORITY; up++) {
-			if (app->prio_map & (1 << up))
+			if (app->prio_map & BIT(up))
 				break;
 		}
 		dcbcfg->app[i].priority = up;
-- 
2.4.3
