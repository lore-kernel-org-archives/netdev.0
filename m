From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 2/9] r8169:update rtl8168gu ephy parameter
Date: Wed, 10 Dec 2014 00:45:56 +0800
Message-ID: <1418143563-7652-3-git-send-email-hau@realtek.com>
References: <1418143563-7652-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418143563-7652-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update rtl8168gu ephy parameter to improve pcie compatibility.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b77efcb..10aa0b1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5976,10 +5976,15 @@ static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168g_2[] = {
-		{ 0x00, 0x0000,	0x0008 },
-		{ 0x0c, 0x3df0,	0x0200 },
-		{ 0x19, 0xffff,	0xfc00 },
-		{ 0x1e, 0xffff,	0x20eb }
+		{ 0x00, 0x0008,	0x0000 },
+		{ 0x0c, 0x37d0,	0x0820 },
+		{ 0x1e, 0x0000,	0x0001 },
+		{ 0x19, 0x8000,	0x0000 },
+		{ 0x19, 0xffff,	0x7c00 },
+		{ 0x1e, 0xffff,	0x20eb },
+		{ 0x0d, 0xffff,	0x1666 },
+		{ 0x00, 0x0000,	0x0080 },
+		{ 0x06, 0xffff,	0xf050 }
 	};
 
 	rtl_hw_start_8168g(tp);
-- 
1.9.1
