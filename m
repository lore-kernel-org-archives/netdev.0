From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 2/3] r8169:Fix typo in setting RTL8168H PHY PFM mode.
Date: Tue, 29 Dec 2015 22:13:38 +0800
Message-ID: <1451398419-4816-3-git-send-email-hau@realtek.com>
References: <1451398419-4816-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60657 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbbL2ONs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 09:13:48 -0500
In-Reply-To: <1451398419-4816-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY PFM register is in PHY page 0x0a44 register 0x11, not 0x14.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0decc1b..629f5e5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3894,7 +3894,7 @@ static void rtl8168h_1_hw_phy_config(struct rtl8169_private *tp)
 
 	/* disable phy pfm mode */
 	rtl_writephy(tp, 0x1f, 0x0a44);
-	rtl_w0w1_phy(tp, 0x14, 0x0000, 0x0080);
+	rtl_w0w1_phy(tp, 0x11, 0x0000, 0x0080);
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* Check ALDPS bit, disable it if enabled */
@@ -3967,7 +3967,7 @@ static void rtl8168h_2_hw_phy_config(struct rtl8169_private *tp)
 
 	/* disable phy pfm mode */
 	rtl_writephy(tp, 0x1f, 0x0a44);
-	rtl_w0w1_phy(tp, 0x14, 0x0000, 0x0080);
+	rtl_w0w1_phy(tp, 0x11, 0x0000, 0x0080);
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* Check ALDPS bit, disable it if enabled */
-- 
1.9.1
