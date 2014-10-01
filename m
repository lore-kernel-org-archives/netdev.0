From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 2/2] r8152: disable power cut for RTL8153
Date: Wed, 1 Oct 2014 13:25:11 +0800
Message-ID: <1394712342-15778-53-Taiwan-albertk@realtek.com>
References: <1394712342-15778-51-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-51-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The firmware would be clear when the power cut is enabled for
RTL8153.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 18b9e0d..604ef21 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3397,7 +3397,7 @@ static void rtl8153_unload(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
-	r8153_power_cut_en(tp, true);
+	r8153_power_cut_en(tp, false);
 }
 
 static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
-- 
1.9.3
