From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 06/11] r8169:update rtl8168evl pcie ephy parameter
Date: Thu, 8 Jan 2015 00:40:21 +0800
Message-ID: <1420648826-12972-7-git-send-email-hau@realtek.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41854 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbbAGQkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:40:40 -0500
In-Reply-To: <1420648826-12972-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8168evl may return to PCIe L0 from PCIe L0s low power mode too slow.
The following ephy parameters are for this issue.
{ 0x0c, 0x0100,	0x0020 }
{ 0x10, 0x0004,	0x0000 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 48d1f78..1874583 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5778,7 +5778,9 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168e_2[] = {
 		{ 0x09, 0x0000,	0x0080 },
-		{ 0x19, 0x0000,	0x0224 }
+		{ 0x19, 0x0000,	0x0224 },
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 }
 	};
 
 	rtl_csi_access_enable_1(tp);
-- 
1.9.1
