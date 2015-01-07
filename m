From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 10/11] r8169:update rtl8402 pcie ephy parameter
Date: Thu, 8 Jan 2015 00:40:25 +0800
Message-ID: <1420648826-12972-11-git-send-email-hau@realtek.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41858 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbbAGQkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:40:45 -0500
In-Reply-To: <1420648826-12972-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove following unnecessary ephy parameter.
{ 0x1e,	0, 0x4000 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ce98d2a..b8a097c 100644
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
