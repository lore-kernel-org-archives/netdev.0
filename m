From: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] update for net-next: iwlwifi: Remove inconsistent and redundant declaration
Date: Thu, 19 Apr 2012 13:36:00 -0700
Message-ID: <1334867760-2815-1-git-send-email-wey-yi.w.guy@intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Spinadel <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Spinadel <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Remove declaration of iwl_alloc_traffic_mem from iwl-agn.h,
from methods that was exposed to support MVM.

MVM doesn't have to use this declaration.

CC: netdev
Signed-off-by: David Spinadel <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
