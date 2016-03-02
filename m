From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net v2] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_41~48
Date: Thu, 3 Mar 2016 00:59:15 +0800
Message-ID: <1456937955-2762-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For RTL8168G/RTL8168H/RTL8411B/RTL8107E, enable this flag to eliminate
message "AMD-Vi: Event logged [IO_PAGE_FAULT device=01:00.0 domain=0x0002
address=0x0000000000003000 flags=0x0050] in dmesg.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4caeacb..dd2cf37 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4933,8 +4933,6 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	case RTL_GIGA_MAC_VER_40:
-		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST | RX_EARLY_OFF);
-		break;
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
@@ -4943,8 +4941,6 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_46:
 	case RTL_GIGA_MAC_VER_47:
 	case RTL_GIGA_MAC_VER_48:
-		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
-		break;
 	case RTL_GIGA_MAC_VER_49:
 	case RTL_GIGA_MAC_VER_50:
 	case RTL_GIGA_MAC_VER_51:
-- 
1.9.1
