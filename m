From: =?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph@boehmwalder.at>
Subject: [PATCH 3/3] wireless: iwlwifi: wrap macro into braces
Date: Wed,  4 Oct 2017 17:57:00 +0200
Message-ID: <20171004155700.18048-4-christoph@boehmwalder.at>
References: <20171004155700.18048-1-christoph@boehmwalder.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph@boehmwalder.at>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        luciano.coelho@intel.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004155700.18048-1-christoph@boehmwalder.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macros should always be wrapped in braces, so fix this instance.

Signed-off-by: Christoph Böhmwalder <christoph@boehmwalder.at>
---
 drivers/net/wireless/intel/iwlwifi/iwl-io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-io.c b/drivers/net/wireless/intel/iwlwifi/iwl-io.c
index efb1998dcabd..0211963b3e71 100644
--- a/drivers/net/wireless/intel/iwlwifi/iwl-io.c
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-io.c
@@ -252,7 +252,7 @@ IWL_EXPORT_SYMBOL(iwl_force_nmi);
 
 static const char *get_rfh_string(int cmd)
 {
-#define IWL_CMD(x) case x: return #x
+#define IWL_CMD(x) { case x: return #x; }
 #define IWL_CMD_MQ(arg, reg, q) { if (arg == reg(q)) return #reg; }
 
 	int i;
-- 
2.13.5
