From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] iwlwifi: fix typo 'IWL_WATCHHDOG_DISABLED'
Date: Wed, 30 May 2012 09:08:29 +0200
Message-ID: <1338361709.1780.3.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 7c5ba4a830cbb730770129b0004e2a06e47dbac5 ("iwlwifi: move queue
watchdog into transport") introduced the named constant
'IWL_WATCHHDOG_DISABLED'. Rename it to 'IWL_WATCHDOG_DISABLED'.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Just something I noticed while researching another issue. Compile tested
(by compiling iwl-1000.0, iwl-5000.o and iwl-agn.o).

 drivers/net/wireless/iwlwifi/iwl-1000.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-config.h |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index 2629a66..2b7f615 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -64,7 +64,7 @@ static const struct iwl_base_params iwl1000_base_params = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_EXT_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.wd_timeout = IWL_WATCHHDOG_DISABLED,
+	.wd_timeout = IWL_WATCHDOG_DISABLED,
 	.max_event_log_size = 128,
 };
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 8e26bc8..a355ade 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -62,7 +62,7 @@ static const struct iwl_base_params iwl5000_base_params = {
 	.led_compensation = 51,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.wd_timeout = IWL_WATCHHDOG_DISABLED,
+	.wd_timeout = IWL_WATCHDOG_DISABLED,
 	.max_event_log_size = 512,
 	.no_idle_support = true,
 };
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index ec36e2b..7eaa979 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1539,7 +1539,7 @@ static struct iwl_op_mode *iwl_op_mode_dvm_start(struct iwl_trans *trans,
 		trans_cfg.queue_watchdog_timeout =
 			priv->cfg->base_params->wd_timeout;
 	else
-		trans_cfg.queue_watchdog_timeout = IWL_WATCHHDOG_DISABLED;
+		trans_cfg.queue_watchdog_timeout = IWL_WATCHDOG_DISABLED;
 	trans_cfg.command_names = iwl_dvm_cmd_strings;
 
 	ucode_flags = fw->ucode_capa.flags;
diff --git a/drivers/net/wireless/iwlwifi/iwl-config.h b/drivers/net/wireless/iwlwifi/iwl-config.h
index 67b28aa..5f54742 100644
--- a/drivers/net/wireless/iwlwifi/iwl-config.h
+++ b/drivers/net/wireless/iwlwifi/iwl-config.h
@@ -113,7 +113,7 @@ enum iwl_led_mode {
 #define IWL_MAX_PLCP_ERR_THRESHOLD_DISABLE	0
 
 /* TX queue watchdog timeouts in mSecs */
-#define IWL_WATCHHDOG_DISABLED	0
+#define IWL_WATCHDOG_DISABLED	0
 #define IWL_DEF_WD_TIMEOUT	2000
 #define IWL_LONG_WD_TIMEOUT	10000
 #define IWL_MAX_WD_TIMEOUT	120000
-- 
1.7.7.6
