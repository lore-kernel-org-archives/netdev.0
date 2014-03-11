From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8169: fix the incorrect tx descriptor version
Date: Tue, 11 Mar 2014 15:11:59 +0800
Message-ID: <1394521919-4257-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tx descriptor version of RTL8111B belong to RTL_TD_0.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e977965..3ff7bc3 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -209,7 +209,7 @@ static const struct {
 	[RTL_GIGA_MAC_VER_16] =
 		_R("RTL8101e",		RTL_TD_0, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_17] =
-		_R("RTL8168b/8111b",	RTL_TD_1, NULL, JUMBO_4K, false),
+		_R("RTL8168b/8111b",	RTL_TD_0, NULL, JUMBO_4K, false),
 	[RTL_GIGA_MAC_VER_18] =
 		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_19] =
-- 
1.8.4.2
