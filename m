From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] i40e: Increase pf reset max loop limit
Date: Fri, 27 Mar 2015 03:02:51 -0700
Message-ID: <1427450573-13945-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13066 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbbC0KDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 06:03:16 -0400
In-Reply-To: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

In some circumstances the firmware can take longer to be ready after a reset than
we're currently waiting. This patch increases the polling loop limiter to much
longer than expected.

Change-ID: I4b2c4c100dfa4abb77d02e5ecdec1cdd253b8c7e
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index b7cacde..d596f66 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -859,7 +859,7 @@ static enum i40e_media_type i40e_get_media_type(struct i40e_hw *hw)
 }
 
 #define I40E_PF_RESET_WAIT_COUNT_A0	200
-#define I40E_PF_RESET_WAIT_COUNT	110
+#define I40E_PF_RESET_WAIT_COUNT	200
 /**
  * i40e_pf_reset - Reset the PF
  * @hw: pointer to the hardware structure
-- 
1.9.3
