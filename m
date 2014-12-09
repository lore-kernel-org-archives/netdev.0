From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 3/9] r8169:update rtl8411b ephy parameter
Date: Wed, 10 Dec 2014 00:45:57 +0800
Message-ID: <1418143563-7652-4-git-send-email-hau@realtek.com>
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

Update rtl8411b ephy parameter to improve pcie compatibility.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 10aa0b1..9c946df 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6000,10 +6000,11 @@ static void rtl_hw_start_8411_2(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8411_2[] = {
 		{ 0x00, 0x0000,	0x0008 },
-		{ 0x0c, 0x3df0,	0x0200 },
+		{ 0x0c, 0x3bf0,	0x0400 },
 		{ 0x0f, 0xffff,	0x5200 },
 		{ 0x19, 0x0020,	0x0000 },
-		{ 0x1e, 0x0000,	0x2000 }
+		{ 0x1e, 0x0000,	0x2000 },
+		{ 0x06, 0x0000,	0x0010 }
 	};
 
 	rtl_hw_start_8168g(tp);
-- 
1.9.1
