From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] rtlwifi: Remove incorrect logging message prefixes
Date: Fri,  6 Jan 2012 11:31:42 -0800
Message-ID: <0f80cb0e369db8c8884d4a1d46e70a60c1dfb19c.1325878172.git.joe@perches.com>
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pr_fmt() adds them.  These are unnecessary and wrong.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c  |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c  |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 943f3d4..71c7aca 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -84,7 +84,7 @@ void rtl92c_read_chip_version(struct ieee80211_hw *hw)
 		}
 	}
 	rtlhal->version  = (enum version_8192c)chip_version;
-	pr_info("rtl8192cu: Chip version 0x%x\n", chip_version);
+	pr_info("Chip version 0x%x\n", chip_version);
 	switch (rtlhal->version) {
 	case VERSION_NORMAL_TSMC_CHIP_92C_1T2R:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index 022f065..364aa40 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -154,9 +154,9 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
 	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
 	if (!rtlpriv->psc.inactiveps)
-		pr_info("rtl8192ce: Power Save off (module option)\n");
+		pr_info("Power Save off (module option)\n");
 	if (!rtlpriv->psc.fwctrl_lps)
-		pr_info("rtl8192ce: FW Power Save off (module option)\n");
+		pr_info("FW Power Save off (module option)\n");
 	rtlpriv->psc.reg_fwctrl_lps = 3;
 	rtlpriv->psc.reg_max_lps_awakeintvl = 5;
 	/* for ASPM, you can close aspm through
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index a933aef..5795a54 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -168,9 +168,9 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
 	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
 	if (!rtlpriv->psc.inactiveps)
-		pr_info("rtl8192ce: Power Save off (module option)\n");
+		pr_info("Power Save off (module option)\n");
 	if (!rtlpriv->psc.fwctrl_lps)
-		pr_info("rtl8192ce: FW Power Save off (module option)\n");
+		pr_info("FW Power Save off (module option)\n");
 	rtlpriv->psc.reg_fwctrl_lps = 3;
 	rtlpriv->psc.reg_max_lps_awakeintvl = 5;
 	/* for ASPM, you can close aspm through
-- 
1.7.8.111.gad25c.dirty
