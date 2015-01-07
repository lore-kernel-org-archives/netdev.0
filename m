From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 09/11] r8169:update rtl8105e pcie ephy parameter
Date: Thu, 8 Jan 2015 00:40:24 +0800
Message-ID: <1420648826-12972-10-git-send-email-hau@realtek.com>
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

rtl8105e may return to PCIe L0 from PCIe L0s low power mode too slow.
The following ephy parameters are for this issue.
{ 0x05,	0, 0x2000 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e92eece..ce98d2a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6403,7 +6403,8 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 		{ 0x03,	0, 0x0001 },
 		{ 0x19,	0, 0x0100 },
 		{ 0x19,	0, 0x0004 },
-		{ 0x0a,	0, 0x0020 }
+		{ 0x0a,	0, 0x0020 },
+		{ 0x05,	0, 0x2000 }
 	};
 
 	/* Force LAN exit from ASPM if Rx/Tx are not idle */
-- 
1.9.1
