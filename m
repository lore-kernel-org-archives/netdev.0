From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 11/12] r8152: add additional parameter for non x86 platform
Date: Tue, 4 Mar 2014 20:01:03 +0800
Message-ID: <1393934464-23675-12-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add additional parameter for non x86 platform for better throughput.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b60b3bc..e04fcbd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -313,7 +313,11 @@
 #define PCUT_STATUS		0x0001
 
 /* USB_RX_EARLY_AGG */
-#define EARLY_AGG_SUPPER	0x0e832981
+#if defined(__i386__) || defined(__x86_64__)
+	#define EARLY_AGG_SUPPER	0x0e832981
+#else
+	#define EARLY_AGG_SUPPER	0x0e835000
+#endif
 #define EARLY_AGG_HIGH		0x0e837a12
 #define EARLY_AGG_SLOW		0x0e83ffff
 
-- 
1.8.4.2
