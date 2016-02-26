From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net 3/3] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_41~48
Date: Fri, 26 Feb 2016 16:40:46 +0800
Message-ID: <1456476046-5436-4-git-send-email-hau@realtek.com>
References: <1456476046-5436-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456476046-5436-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For RTL8168G/RTL8168H/RTL8411B/RTL8107E, enable this flag to eliminate message
"AMD-Vi: Event logged [IO_PAGE_FAULT device=01:00.0 domain=0x0002
address=0x0000000000003000 flags=0x0050] in dmesg.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3e9eb64..c8f0077 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4945,8 +4945,6 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	case RTL_GIGA_MAC_VER_40:
-		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST | RX_EARLY_OFF);
-		break;
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
@@ -4955,8 +4953,6 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
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
