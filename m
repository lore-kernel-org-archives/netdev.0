From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 1/5] net-next:asix:PHY_MODE_RTL8211CL should be 0xC
Date: Tue, 15 Nov 2011 09:12:39 -0800
Message-ID: <1321377163-26308-1-git-send-email-grundler@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>,
	Grant Grundler <grundler@google.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@google.com>

Use correct value for rtl phy support.
(rtl phy are in AX88178 devices like NWU220G and USB2-ET1000).

Signed-off-by: Allan Chou <allan@asix.com.tw>
Tested-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/asix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index e81e22e..873860d 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -163,7 +163,7 @@
 #define MARVELL_CTRL_TXDELAY	0x0002
 #define MARVELL_CTRL_RXDELAY	0x0080
 
-#define	PHY_MODE_RTL8211CL	0x0004
+#define	PHY_MODE_RTL8211CL	0x000C
 
 /* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
 struct asix_data {
-- 
1.7.3.1
