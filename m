From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 07/11] r8169:update rtl8168f pcie ephy parameter
Date: Thu, 8 Jan 2015 00:40:22 +0800
Message-ID: <1420648826-12972-8-git-send-email-hau@realtek.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41855 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbbAGQkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:40:41 -0500
In-Reply-To: <1420648826-12972-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8168f may return to PCIe L0 from PCIe L0s low power mode too slow.
The following ephy parameters are for this issue.
{ 0x00, 0x0000,	0x0008 }
{ 0x0c, 0x3df0,	0x0200 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1874583..bafa132 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5852,7 +5852,9 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 		{ 0x06, 0x00c0,	0x0020 },
 		{ 0x08, 0x0001,	0x0002 },
 		{ 0x09, 0x0000,	0x0080 },
-		{ 0x19, 0x0000,	0x0224 }
+		{ 0x19, 0x0000,	0x0224 },
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 }
 	};
 
 	rtl_hw_start_8168f(tp);
-- 
1.9.1
