From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] rtl8xxxu: remove unneeded assignments
Date: Fri, 10 Jun 2016 14:57:34 +0100
Message-ID: <1465567054-32664-1-git-send-email-luisbg@osg.samsung.com>
Cc: Jes.Sorensen@redhat.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

reg_eac and reg_ecc are only used if candidate is bigger than 0, and in
that case new values will be given to them. Removing the unused
assignments.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
index fe19ace..984af46 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
@@ -1249,11 +1249,9 @@ static void rtl8192eu_phy_iq_calibrate(struct rtl8xxxu_priv *priv)
 		reg_e94 = result[i][0];
 		reg_e9c = result[i][1];
 		reg_ea4 = result[i][2];
-		reg_eac = result[i][3];
 		reg_eb4 = result[i][4];
 		reg_ebc = result[i][5];
 		reg_ec4 = result[i][6];
-		reg_ecc = result[i][7];
 	}
 
 	if (candidate >= 0) {
-- 
2.5.3
