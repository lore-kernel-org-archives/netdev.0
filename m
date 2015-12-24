From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 1/2] r8169:Fix typo in setting RTL8168H PHY parameter
Date: Thu, 24 Dec 2015 21:15:26 +0800
Message-ID: <1450962927-19077-2-git-send-email-hau@realtek.com>
References: <1450962927-19077-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450962927-19077-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function "rtl8168h_2_hw_phy_config", there is a typo in setting
RTL8168H PHY parameter.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 79ef799..11cc32b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3947,7 +3947,7 @@ static void rtl8168h_2_hw_phy_config(struct rtl8169_private *tp)
 	data = (ioffset_p3<<12)|(ioffset_p2<<8)|(ioffset_p1<<4)|(ioffset_p0);
 
 	if ((ioffset_p3 != 0x0f) || (ioffset_p2 != 0x0f) ||
-	    (ioffset_p1 != 0x0f) || (ioffset_p0 == 0x0f)) {
+	    (ioffset_p1 != 0x0f) || (ioffset_p0 != 0x0f)) {
 		rtl_writephy(tp, 0x1f, 0x0bcf);
 		rtl_writephy(tp, 0x16, data);
 		rtl_writephy(tp, 0x1f, 0x0000);
-- 
1.9.1
