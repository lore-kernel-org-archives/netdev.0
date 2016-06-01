From: Colin King <colin.king@canonical.com>
Subject: [PATCH] rtl8xxxu: fix typo on variable name, compare against correct variable
Date: Wed,  1 Jun 2016 17:23:45 +0100
Message-ID: <1464798225-7315-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54626 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbcFAQX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:23:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

path_b_ok is being assigned but immediately after path_a_ok is being
compared to the value 0x03.  This appears to be a typo on the
variable name, compare path_b_ok instead.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
index fe19ace..b04cf30 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
@@ -1149,7 +1149,7 @@ static void rtl8192eu_phy_iqcalibrate(struct rtl8xxxu_priv *priv,
 
 		for (i = 0; i < retry; i++) {
 			path_b_ok = rtl8192eu_rx_iqk_path_b(priv);
-			if (path_a_ok == 0x03) {
+			if (path_b_ok == 0x03) {
 				val32 = rtl8xxxu_read32(priv,
 							REG_RX_POWER_BEFORE_IQK_B_2);
 				result[t][6] = (val32 >> 16) & 0x3ff;
-- 
2.8.1
