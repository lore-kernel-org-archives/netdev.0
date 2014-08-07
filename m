From: Nick Krause <xerofoiify@gmail.com>
Subject: [PATCH] rtl8150: Check if RSR is already defined
Date: Thu,  7 Aug 2014 07:24:54 +0200
Message-ID: <1407389095-31426-1-git-send-email-xerofoiify@gmail.com>
To: Petko Manolov <petkan@nucleusys.com>,
	linux-usb@vger.kernel.org (open list:USB RTL8150 DRIVER),
	netdev@vger.kernel.org (open list:USB RTL8150 DRIVER),
	linux-kernel@vger.kernel.org (open list)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am getting the following warn

drivers/net/usb/rtl8150.c:30:0: warning: "RSR" redefined
arch/xtensa/include/asm/processor.h:189:0: note: this is the location of the previous definition

I wanted to remove RSR as it is not being used but it is not clear if being used
for documenting purpose. undefining should be enough.

Signed-off-by: Nick Krause <xerofoify@gmail.com>
---
 drivers/net/usb/rtl8150.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6e87e57..7d9a6ba 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -21,6 +21,10 @@
 #define DRIVER_AUTHOR "Petko Manolov <petkan@users.sourceforge.net>"
 #define DRIVER_DESC "rtl8150 based usb-ethernet driver"
 
+#ifdef RSR
+#undef RSR
+#endif
+
 #define	IDR			0x0120
 #define	MAR			0x0126
 #define	CR			0x012e
-- 
2.0.1
