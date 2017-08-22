From: Colin King <colin.king@canonical.com>
Subject: [PATCH] rtlwifi: rtl8821ae: fix spelling mistake: "faill" -> "failed"
Date: Tue, 22 Aug 2017 13:59:04 +0100
Message-ID: <20170822125904.13292-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ping-Ke Shih <pkshih@realtek.com>,
        Joe Perches <joe@perches.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:51686 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932638AbdHVNAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 09:00:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in RT_TRACE message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
index b84b4fa7b71c..f2b2c549e5b2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
@@ -98,7 +98,7 @@ static int _rtl8821ae_fw_free_to_go(struct ieee80211_hw *hw)
 
 	if (counter >= FW_8821AE_POLLING_TIMEOUT_COUNT) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "chksum report faill ! REG_MCUFWDL:0x%08x .\n",
+			 "chksum report fail! REG_MCUFWDL:0x%08x .\n",
 			  value32);
 		goto exit;
 	}
-- 
2.14.1
