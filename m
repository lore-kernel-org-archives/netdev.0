From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 04/11] r8169:update rtl8168dp pcie ephy parameter
Date: Thu, 8 Jan 2015 00:40:19 +0800
Message-ID: <1420648826-12972-5-git-send-email-hau@realtek.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420648826-12972-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add following ephy parameter. This parameter will save more power when
in ASPM mode.
{ 0x10, 0x0004,	0x0000 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0fc7e62..15a0f5b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5733,7 +5733,8 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 	static const struct ephy_info e_info_8168d_4[] = {
 		{ 0x0b, 0x0000,	0x0048 },
 		{ 0x19, 0x0020,	0x0050 },
-		{ 0x0c, 0x0100,	0x0020 }
+		{ 0x0c, 0x0100,	0x0020 },
+		{ 0x10, 0x0004,	0x0000 }
 	};
 
 	rtl_csi_access_enable_1(tp);
-- 
1.9.1
