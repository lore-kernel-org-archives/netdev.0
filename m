From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH v2 net-next 04/10] r8169:add support more chips to get mac address from backup mac address register
Date: Wed, 1 Oct 2014 23:17:15 +0800
Message-ID: <1412176641-24393-4-git-send-email-hau@realtek.com>
References: <1412176641-24393-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:48787 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbaJAPRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 11:17:47 -0400
In-Reply-To: <1412176641-24393-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTL8168FB RTL8168G RTL8168GU RTL8411 RTL8411B RTL8106EUS RTL8402 can
support get mac address from backup mac address register.

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 86c55a0..c1e9661 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7704,7 +7704,16 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u64_stats_init(&tp->tx_stats.syncp);
 
 	/* Get MAC address */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_45 ||
+	if (tp->mac_version == RTL_GIGA_MAC_VER_35 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_36 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_37 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_38 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_40 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_41 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_42 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_43 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_44 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_45 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_46 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_47 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_48) {
-- 
1.8.3.2
