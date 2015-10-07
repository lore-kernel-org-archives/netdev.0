From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/18] i40e: Fix for truncated interrupt name
Date: Wed,  7 Oct 2015 15:47:03 -0700
Message-ID: <1444258032-41476-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:48647 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753741AbbJGWr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:26 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch extends the size of the text available for the interrupt names.
Without this patch, all the descriptive data available for the Flow
Director interrupts is truncated.

Change-ID: I2ac458f23ac3b4ea8f1edf73edc283b1d3704c7f
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 44837ec..a54577a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -97,7 +97,7 @@
 #define I40E_MAX_USER_PRIORITY        8
 #define I40E_DEFAULT_MSG_ENABLE       4
 #define I40E_QUEUE_WAIT_RETRY_LIMIT   10
-#define I40E_INT_NAME_STR_LEN        (IFNAMSIZ + 9)
+#define I40E_INT_NAME_STR_LEN        (IFNAMSIZ + 16)
 
 /* Ethtool Private Flags */
 #define I40E_PRIV_FLAGS_NPAR_FLAG	BIT(0)
-- 
2.4.3
