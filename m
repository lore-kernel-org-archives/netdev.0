From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next v2 5/8] r8169:update rtl8168dp pcie ephy parameters to improve power consumption
Date: Fri, 9 Jan 2015 23:26:03 +0800
Message-ID: <1420817166-9868-6-git-send-email-hau@realtek.com>
References: <1420817166-9868-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420817166-9868-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following parameter will disable more pcie ephy block (like pcie ephy
read/write clock.....etc ) to save more power when in aspm+clkreq mode.
{ 0x10, 0x0004,	0x0000 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 928e35a..ade7144 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5718,7 +5718,8 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
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
