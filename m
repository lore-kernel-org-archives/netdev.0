From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 8/9] r8169:update rtl8105e ephy parameter
Date: Wed, 10 Dec 2014 00:46:02 +0800
Message-ID: <1418143563-7652-9-git-send-email-hau@realtek.com>
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

Update rtl8105e ephy parameter to improve pcie compatibility.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 42eda35..56bcd96 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6450,7 +6450,8 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
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
