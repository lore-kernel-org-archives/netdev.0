From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/16] i40e: Increase reset delay
Date: Sat,  6 Dec 2014 05:02:07 -0800
Message-ID: <1417870933-17248-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8816 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679AbaLFNC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:02:59 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Increase reset delay to ensure all internal caches are properly flushed
in worst case scenario.

Change-ID: I6f059a9e024fbf9ef1debd32497eed21369957fc
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index b601b3c..ec63bcb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -791,7 +791,7 @@ static enum i40e_media_type i40e_get_media_type(struct i40e_hw *hw)
 }
 
 #define I40E_PF_RESET_WAIT_COUNT_A0	200
-#define I40E_PF_RESET_WAIT_COUNT	100
+#define I40E_PF_RESET_WAIT_COUNT	110
 /**
  * i40e_pf_reset - Reset the PF
  * @hw: pointer to the hardware structure
-- 
1.9.3
