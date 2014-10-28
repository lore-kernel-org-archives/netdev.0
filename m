From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/2] r8152: rename tx_underun
Date: Tue, 28 Oct 2014 14:05:51 +0800
Message-ID: <1394712342-15778-67-Taiwan-albertk@realtek.com>
References: <1394712342-15778-66-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-66-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace tx_underun with tx_underrun for checkpatch.pl.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e3d84c3..fdea194 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -486,7 +486,7 @@ struct tally_counter {
 	__le64	rx_broadcast;
 	__le32	rx_multicast;
 	__le16	tx_aborted;
-	__le16	tx_underun;
+	__le16	tx_underrun;
 };
 
 struct rx_desc {
@@ -3420,7 +3420,7 @@ static void rtl8152_get_ethtool_stats(struct net_device *dev,
 	data[9] = le64_to_cpu(tally.rx_broadcast);
 	data[10] = le32_to_cpu(tally.rx_multicast);
 	data[11] = le16_to_cpu(tally.tx_aborted);
-	data[12] = le16_to_cpu(tally.tx_underun);
+	data[12] = le16_to_cpu(tally.tx_underrun);
 }
 
 static void rtl8152_get_strings(struct net_device *dev, u32 stringset, u8 *data)
-- 
1.9.3
