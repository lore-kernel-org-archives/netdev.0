From: akpm@linux-foundation.org
Subject: [patch 1/3] hci_usb: do not initialize static variables to 0
Date: Fri, 18 Apr 2008 13:46:51 -0700
Message-ID: <200804182046.m3IKkp7P014625@imap1.linux-foundation.org>
Cc: hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, pavel@ucw.cz,
	pavel@suse.cz
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60575 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753864AbYDRUrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 16:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Machek <pavel@ucw.cz>

hci_usb: do not initialize static variables to 0.

Signed-off-by: Pavel Machek <pavel@suse.cz>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/hci_usb.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff -puN drivers/bluetooth/hci_usb.c~hci_usb-do-not-initialize-static-variables-to-0 drivers/bluetooth/hci_usb.c
--- a/drivers/bluetooth/hci_usb.c~hci_usb-do-not-initialize-static-variables-to-0
+++ a/drivers/bluetooth/hci_usb.c
@@ -62,13 +62,13 @@
 #define URB_ZERO_PACKET 0
 #endif
 
-static int ignore = 0;
-static int ignore_dga = 0;
-static int ignore_csr = 0;
-static int ignore_sniffer = 0;
-static int disable_scofix = 0;
-static int force_scofix = 0;
-static int reset = 0;
+static int ignore;
+static int ignore_dga;
+static int ignore_csr;
+static int ignore_sniffer;
+static int disable_scofix;
+static int force_scofix;
+static int reset;
 
 #ifdef CONFIG_BT_HCIUSB_SCO
 static int isoc = 2;
_
