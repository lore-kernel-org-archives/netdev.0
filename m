From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/18] i40e: Change unknown event error msg to ignore message
Date: Tue,  5 Apr 2016 13:17:32 -0700
Message-ID: <1459887455-146634-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43343 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759989AbcDEURm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:42 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

There's no real error in an unknown event from the Firmware, we're just
posting a useful FYI notice, so this patch simply removes the "Error" word.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 98bc749..3841005 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6371,7 +6371,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 			break;
 		default:
 			dev_info(&pf->pdev->dev,
-				 "ARQ Error: Unknown event 0x%04x received\n",
+				 "ARQ: Unknown event 0x%04x ignored\n",
 				 opcode);
 			break;
 		}
-- 
2.5.5
