From: =?UTF-8?q?L=2E=20Alberto=20Gim=C3=A9nez?= <agimenez@sysvalve.es>
Subject: [PATCH] ipheth.c: Enable IP header alignment
Date: Sun,  1 May 2011 13:00:55 +0200
Message-ID: <1304247656-21086-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dgiagio@gmail.com, dborca@yahoo.com, davem@davemloft.net,
	pmcenery@gmail.com, david.hill@ubisoft.com,
	linux-usb@vger.kernel.org (open list:USB SUBSYSTEM),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David Hill <david.hill@ubisoft.com>

Since commit ea812ca1b06113597adcd8e70c0f84a413d97544, NET_IP_ALIGN cha=
nged from
2 to 0. Some people have reported that tethering stopped working and Da=
vid Hill
submited a patch that seems to fix the problem.

I have no more an iPhone device to test it, so it is only compile-teste=
d.

Signed-off-by: L. Alberto Gim=C3=A9nez <agimenez@sysvalve.es>
---
 drivers/net/usb/ipheth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 7d42f9a..711346b 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -54,6 +54,9 @@
 #include <linux/usb.h>
 #include <linux/workqueue.h>
=20
+#undef  NET_IP_ALIGN
+#define NET_IP_ALIGN 2
+
 #define USB_VENDOR_APPLE        0x05ac
 #define USB_PRODUCT_IPHONE      0x1290
 #define USB_PRODUCT_IPHONE_3G   0x1292
--=20
1.7.5
