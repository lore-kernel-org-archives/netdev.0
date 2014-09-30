From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH net-next 04/10] r8168:add support more chips to get mac address from backup mac address register
Date: Tue, 30 Sep 2014 23:00:24 +0800
Message-ID: <1412089230-10208-4-git-send-email-hau@realtek.com>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412089230-10208-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RTL8168FB RTL8168G RTL8168GU RTL8411 RTL8411B RTL8106EUS RTL8402 can
get mac address from backup mac address register.

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f7b0c7d8..b4cbc6c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7705,7 +7705,16 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
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
