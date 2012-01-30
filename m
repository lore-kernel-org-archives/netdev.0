From: "Devendra.Naga" <devendra.aaru@gmail.com>
Subject: [PATCH 1/1] wireless: remove return in _rtl_pci_switch_clk_req
Date: Mon, 30 Jan 2012 07:46:31 -0500
Message-ID: <1327927591-28070-1-git-send-email-devendra.aaru@gmail.com>
Cc: "Devendra.Naga" <devendra.aaru@gmail.com>
To: <Larry.Finger@lwfinger.net>, <chaoming_li@realsil.com.cn>,
	<linville@tuxdriver.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Devendra.Naga" <devendra.aaru@gmail.com>

the return value from _rtl_pci_switch_clk_req is not used by any of its callers.

Signed-off-by: Devendra.Naga <devendra.aaru@gmail.com>
---
 drivers/net/wireless/rtlwifi/pci.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 4326fd1..35f4a0d 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -198,7 +198,7 @@ static bool _rtl_pci_platform_switch_device_pci_aspm(
 }
 
 /*When we set 0x01 to enable clk request. Set 0x0 to disable clk req.*/
-static bool _rtl_pci_switch_clk_req(struct ieee80211_hw *hw, u8 value)
+static void _rtl_pci_switch_clk_req(struct ieee80211_hw *hw, u8 value)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
@@ -208,7 +208,6 @@ static bool _rtl_pci_switch_clk_req(struct ieee80211_hw *hw, u8 value)
 	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192SE)
 		udelay(100);
 
-	return true;
 }
 
 /*Disable RTL8192SE ASPM & Disable Pci Bridge ASPM*/
-- 
1.7.5.4
