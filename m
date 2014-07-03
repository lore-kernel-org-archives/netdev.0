From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: increase the tx timeout
Date: Thu, 3 Jul 2014 11:55:48 +0800
Message-ID: <1404359748-4202-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the system is too busy to complete the urb, the tx timout function
would be called. This causes the other tx urbs would be killed, too.
Increase the tx timeout to avoid it.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2543196..e9685ce 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -441,7 +441,7 @@ enum rtl_register_content {
 #define BYTE_EN_END_MASK	0xf0
 
 #define RTL8152_RMS		(VLAN_ETH_FRAME_LEN + VLAN_HLEN)
-#define RTL8152_TX_TIMEOUT	(HZ)
+#define RTL8152_TX_TIMEOUT	(5 * HZ)
 
 /* rtl8152 flags */
 enum rtl8152_flags {
-- 
1.9.3
