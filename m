From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] wireless: mwifiex: Fix typo in wireless/mwifiex driver
Date: Fri, 30 Nov 2012 22:08:31 +0900
Message-ID: <1354280911-4866-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: bzhao@marvell.com, linux-wireless@vger.kernel.org,
	trivial@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling typo in wireless/mwifiex driver.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/wireless/mwifiex/sta_ioctl.c | 2 +-
 drivers/net/wireless/mwifiex/usb.c       | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireless/mwifiex/sta_ioctl.c
index 552d72e..21035e6 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -463,7 +463,7 @@ int mwifiex_enable_hs(struct mwifiex_adapter *adapter)
 	}
 
 	if (adapter->hs_activated) {
-		dev_dbg(adapter->dev, "cmd: HS Already actived\n");
+		dev_dbg(adapter->dev, "cmd: HS Already activated\n");
 		return true;
 	}
 
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwifiex/usb.c
index 22a5916..5eb3b33 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -351,7 +351,7 @@ static int mwifiex_usb_probe(struct usb_interface *intf,
 	card->udev = udev;
 	card->intf = intf;
 
-	pr_debug("info: bcdUSB=%#x Device Class=%#x SubClass=%#x Protocl=%#x\n",
+	pr_debug("info: bcdUSB=%#x Device Class=%#x SubClass=%#x Protocol=%#x\n",
 		 udev->descriptor.bcdUSB, udev->descriptor.bDeviceClass,
 		 udev->descriptor.bDeviceSubClass,
 		 udev->descriptor.bDeviceProtocol);
-- 
1.8.0.1.347.gf94c325
