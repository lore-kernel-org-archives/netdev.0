From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 02/26] rt2x00: device IDs
Date: Sun, 3 Dec 2006 19:19:05 +0100
Message-ID: <200612031919.05789.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:57689 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758904AbWLCSTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:37 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144364nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:37 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add new rt2500usb and rt73usb device id numbers.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-base-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 16:04:27.000000000 +0100
+++ wireless-dev-base-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 16:04:14.000000000 +0100
@@ -2888,6 +2888,8 @@
 	{ USB_DEVICE(0x148f, 0x2570) },
 	{ USB_DEVICE(0x148f, 0x2573) },
 	{ USB_DEVICE(0x148f, 0x9020) },
+	/* Siemens */
+	{ USB_DEVICE(0x0681, 0x3c06) },
 	/* SMC */
 	{ USB_DEVICE(0x0707, 0xee13) },
 	/* Spairon */
Only in wireless-dev-base-rt2x00/drivers/net/wireless/d80211/rt2x00: rt2500usb.c.orig
diff -rU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-base-rt2x00/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 16:04:27.000000000 +0100
+++ wireless-dev-base-rt2x00/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 16:04:14.000000000 +0100
@@ -3219,9 +3219,20 @@
 	DRV_NAME " - " DRV_VERSION " (" DRV_RELDATE ") by " DRV_PROJECT;
 
 static struct usb_device_id rt73usb_device_table[] = {
+	/* AboCom */
+	{ USB_DEVICE(0x07b8, 0xb21d) },
+	/* Askey */
+	{ USB_DEVICE(0x1690, 0x0722) },
+	/* ASUS */
+	{ USB_DEVICE(0x0b05, 0x1723) },
 	/* Belkin */
 	{ USB_DEVICE(0x050d, 0x7050) },
 	{ USB_DEVICE(0x050d, 0x705a) },
+	/* Billionton */
+	{ USB_DEVICE(0x1631, 0xc019) },
+	/* CNet */
+	{ USB_DEVICE(0x1371, 0x9022) },
+	{ USB_DEVICE(0x1371, 0x9032) },
 	/* Conceptronic */
 	{ USB_DEVICE(0x14b2, 0x3c22) },
 	/* D-Link */
@@ -3229,18 +3240,29 @@
 	{ USB_DEVICE(0x07d1, 0x3c04) },
 	/* Gigabyte */
 	{ USB_DEVICE(0x1044, 0x8008) },
+	{ USB_DEVICE(0x1044, 0x800a) },
+	/* Huawei-3Com */
+	{ USB_DEVICE(0x1472, 0x0009) },
+	/* Hercules */
+	{ USB_DEVICE(0x06f8, 0xe010) },
 	/* Linksys */
 	{ USB_DEVICE(0x13b1, 0x0020) },
+	{ USB_DEVICE(0x13b1, 0x0023) },
 	/* MSI */
 	{ USB_DEVICE(0x0db0, 0x6877) },
+	{ USB_DEVICE(0x0db0, 0xa861) },
 	{ USB_DEVICE(0x0db0, 0xa874) },
 	/* Ralink */
 	{ USB_DEVICE(0x148f, 0x2573) },
 	{ USB_DEVICE(0x148f, 0x2671) },
 	/* Qcom */
 	{ USB_DEVICE(0x18e8, 0x6196) },
+	{ USB_DEVICE(0x18e8, 0x6229) },
 	/* Sitecom */
 	{ USB_DEVICE(0x0df6, 0x9712) },
+	{ USB_DEVICE(0x0df6, 0x90ac) },
+	/* Surecom */
+	{ USB_DEVICE(0x0769, 0x31f3) },
 	{ 0, }
 };
 
