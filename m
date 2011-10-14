From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH] r8169: fix wrong eee setting for rlt8111evl
Date: Fri, 14 Oct 2011 14:14:37 +0800
Message-ID: <1318572877-1549-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct the wrong parameter for setting EEE for RTL8111E-VL.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c236670..27f7ebc 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2859,7 +2859,7 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0004);
 	rtl_writephy(tp, 0x1f, 0x0007);
 	rtl_writephy(tp, 0x1e, 0x0020);
-	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_w1w0_phy(tp, 0x15, 0x0000, 0x0100);
 	rtl_writephy(tp, 0x1f, 0x0002);
 	rtl_writephy(tp, 0x1f, 0x0000);
 	rtl_writephy(tp, 0x0d, 0x0007);
-- 
1.7.6.2
