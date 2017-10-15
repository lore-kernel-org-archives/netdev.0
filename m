From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Fix typo in if ... else if ... else construct
Date: Sat, 14 Oct 2017 20:58:21 -0500
Message-ID: <20171015015821.14839-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Ping-Ke Shih <pkshih@realtek.com>,
        Yan-Hsuan Chuang <yhchuang@realtek.com>,
        Birming Chiu <birming@realtek.com>,
        Shaofu <shaofu@realtek.com>,
        Steven Ting <steventing@realtek.com>, kbuild-all@01.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36076 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbdJOB62 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:58:28 -0400
Received: by mail-oi0-f66.google.com with SMTP id s185so5315107oif.3
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 18:58:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kbuild test robot reports two conditions with no effect (if == else).
These are the result of copy and paste typographical errors.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Ping-Ke Shih <pkshih@realtek.com>
Cc: Yan-Hsuan Chuang <yhchuang@realtek.com>
Cc: Birming Chiu <birming@realtek.com>
Cc: Shaofu <shaofu@realtek.com>
Cc: Steven Ting <steventing@realtek.com>
Cc: kbuild-all@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/staging/rtlwifi/base.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtlwifi/base.c b/drivers/staging/rtlwifi/base.c
index b88b0e8edd3d..1a0331cf63ee 100644
--- a/drivers/staging/rtlwifi/base.c
+++ b/drivers/staging/rtlwifi/base.c
@@ -920,7 +920,7 @@ static u8 _rtl_get_vht_highest_n_rate(struct ieee80211_hw *hw,
 		else if ((tx_mcs_map  & 0x000c) >> 2 ==
 			IEEE80211_VHT_MCS_SUPPORT_0_8)
 			hw_rate =
-			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_2SS_MCS9];
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_2SS_MCS8];
 		else
 			hw_rate =
 			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_2SS_MCS9];
@@ -932,7 +932,7 @@ static u8 _rtl_get_vht_highest_n_rate(struct ieee80211_hw *hw,
 		else if ((tx_mcs_map  & 0x0003) ==
 			IEEE80211_VHT_MCS_SUPPORT_0_8)
 			hw_rate =
-			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_1SS_MCS9];
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_1SS_MCS8];
 		else
 			hw_rate =
 			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_1SS_MCS9];
-- 
2.12.3
