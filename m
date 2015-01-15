From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] i40e/i40evf: Increase ASQ timeout
Date: Thu, 15 Jan 2015 04:19:13 -0800
Message-ID: <1421324368-6860-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:9320 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbbAOMTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:32 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Increase ASQ timeout for some scenarios with multi-function devices

Change-ID: I2d7655b19e6c6f9a7ad04deacb106ca8d53886db
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index 564d0b0..de17b6f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -148,7 +148,7 @@ static inline int i40e_aq_rc_to_posix(u32 aq_ret, u16 aq_rc)
 
 /* general information */
 #define I40E_AQ_LARGE_BUF	512
-#define I40E_ASQ_CMD_TIMEOUT	100  /* msecs */
+#define I40E_ASQ_CMD_TIMEOUT	250  /* msecs */
 
 void i40e_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
 				       u16 opcode);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index 6c31bf2..60f04e9 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -148,7 +148,7 @@ static inline int i40e_aq_rc_to_posix(u32 aq_ret, u16 aq_rc)
 
 /* general information */
 #define I40E_AQ_LARGE_BUF	512
-#define I40E_ASQ_CMD_TIMEOUT	100  /* msecs */
+#define I40E_ASQ_CMD_TIMEOUT	250  /* msecs */
 
 void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
 				       u16 opcode);
-- 
1.9.3
