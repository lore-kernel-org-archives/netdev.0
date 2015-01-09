From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next v2 7/8] r8169:update rtl8402 pcie ephy parameter
Date: Fri, 9 Jan 2015 23:26:05 +0800
Message-ID: <1420817166-9868-8-git-send-email-hau@realtek.com>
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

Remove following unnecessary ephy parameter.
{ 0x1e,	0, 0x4000 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 483fa40..aa12833 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6431,8 +6431,7 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8402[] = {
-		{ 0x19,	0xffff, 0xff64 },
-		{ 0x1e,	0, 0x4000 }
+		{ 0x19,	0xffff, 0xff64 }
 	};
 
 	rtl_csi_access_enable_2(tp);
-- 
1.9.1
