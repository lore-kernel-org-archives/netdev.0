From: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Subject: [PATCH] iwlwifi: Remove inconsistent and redundant declaration
Date: Thu, 19 Apr 2012 13:46:38 -0700
Message-ID: <1334868398-7095-1-git-send-email-wey-yi.w.guy@intel.com>
Cc: netdev@vger.kernel.org, David Spinadel <david.spinadel@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50820 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab2DSUvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 16:51:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Spinadel <david.spinadel@intel.com>

Remove declaration of iwl_alloc_traffic_mem from iwl-agn.h,
from methods that was exposed to support MVM.

MVM doesn't have to use this declaration.

CC: netdev@vger.kernel.org
Signed-off-by: David Spinadel <david.spinadel@intel.com>
Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.h b/drivers/net/wireless/iwlwifi/iwl-agn.h
index 67cd123..3d6f3e2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.h
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.h
@@ -510,7 +510,6 @@ void iwl_setup_deferred_work(struct iwl_priv *priv);
 int iwl_send_wimax_coex(struct iwl_priv *priv);
 int iwl_send_bt_env(struct iwl_priv *priv, u8 action, u8 type);
 void iwl_debug_config(struct iwl_priv *priv);
-int iwl_alloc_traffic_mem(struct iwl_priv *priv);
 void iwl_set_hw_params(struct iwl_priv *priv);
 void iwl_init_context(struct iwl_priv *priv, u32 ucode_flags);
 int iwl_init_drv(struct iwl_priv *priv);
-- 
1.7.0.4
