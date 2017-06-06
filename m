From: Seraphime Kirkovski <kirkseraph@gmail.com>
Subject: [PATCH] net: wireless: intel: iwlwifi: dvm: remove unused defines
Date: Wed,  7 Jun 2017 01:20:27 +0200
Message-ID: <20170606232031.28893-1-kirkseraph@gmail.com>
Cc: Seraphime Kirkovski <kirkseraph@gmail.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org (open list:INTEL WIRELESS WIFI LINK
        (iwlwifi)), netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: johannes.berg@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Those constants have been unused for quite some time now.

Signed-off-by: Seraphime Kirkovski <kirkseraph@gmail.com>
---
 I've compile-tested it.

 drivers/net/wireless/intel/iwlwifi/dvm/commands.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/dvm/commands.h b/drivers/net/wireless/intel/iwlwifi/dvm/commands.h
index 2ab2773655a8..37d2ba5ae852 100644
--- a/drivers/net/wireless/intel/iwlwifi/dvm/commands.h
+++ b/drivers/net/wireless/intel/iwlwifi/dvm/commands.h
@@ -1446,13 +1446,6 @@ struct agg_tx_status {
  *   or rate table color was changed during frame retries
  * refer tlc rate info
  */
-
-#define IWL50_TX_RES_INIT_RATE_INDEX_POS	0
-#define IWL50_TX_RES_INIT_RATE_INDEX_MSK	0x0f
-#define IWL50_TX_RES_RATE_TABLE_COLOR_POS	4
-#define IWL50_TX_RES_RATE_TABLE_COLOR_MSK	0x70
-#define IWL50_TX_RES_INV_RATE_INDEX_MSK	0x80
-
 /* refer to ra_tid */
 #define IWLAGN_TX_RES_TID_POS	0
 #define IWLAGN_TX_RES_TID_MSK	0x0f
-- 
2.11.0
