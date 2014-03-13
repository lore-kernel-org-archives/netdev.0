From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 2/2] r8152: reduce the numbers of the bulks
Date: Thu, 13 Mar 2014 20:05:42 +0800
Message-ID: <1394712342-15778-3-Taiwan-albertk@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394712342-15778-1-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-1-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is not necessary to have many transfer buffers. Reduce the number
from 10 to 4.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 756c0a6..b6bde59 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -421,8 +421,8 @@ enum rtl_register_content {
 	FULL_DUP	= 0x01,
 };
 
-#define RTL8152_MAX_TX		10
-#define RTL8152_MAX_RX		10
+#define RTL8152_MAX_TX		4
+#define RTL8152_MAX_RX		4
 #define INTBUFSIZE		2
 #define CRC_SIZE		4
 #define TX_ALIGN		4
-- 
1.8.4.2
