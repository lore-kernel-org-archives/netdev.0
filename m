From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH v2 net-next 03/10] r8169:add disable/enable RTL8411B pll function
Date: Wed, 1 Oct 2014 23:17:14 +0800
Message-ID: <1412176641-24393-3-git-send-email-hau@realtek.com>
References: <1412176641-24393-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:48785 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaJAPRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 11:17:46 -0400
In-Reply-To: <1412176641-24393-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTL8411B can support disable/enable pll function.

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 93f8d3f..86c55a0 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4367,6 +4367,7 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_31:
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
+	case RTL_GIGA_MAC_VER_44:
 	case RTL_GIGA_MAC_VER_45:
 	case RTL_GIGA_MAC_VER_46:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
@@ -4394,6 +4395,7 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
+	case RTL_GIGA_MAC_VER_44:
 	case RTL_GIGA_MAC_VER_45:
 	case RTL_GIGA_MAC_VER_46:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);
-- 
1.8.3.2
