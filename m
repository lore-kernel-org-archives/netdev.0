From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.6.0-test4][NET] 3c509.c: remove device.name field
Date: 23 Aug 2003 18:43:29 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061644409.1141.18.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch removes the device name field which is no longer present.


--- linux-2.6.0-test4/drivers/net/3c509.c	2003-08-23 13:14:30.000000000 +0530
+++ linux-2.6.0-test4-nvk/drivers/net/3c509.c	2003-08-23 18:34:35.000000000 +0530
@@ -629,8 +629,6 @@
 			   el3_mca_adapter_names[mdev->index], slot + 1);
 
 		/* claim the slot */
-		strncpy(device->name, el3_mca_adapter_names[mdev->index],
-				sizeof(device->name));
 		mca_device_set_claim(mdev, 1);
 
 		if_port = pos4 & 0x03;
