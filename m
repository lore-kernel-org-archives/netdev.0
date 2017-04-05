From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: usbnet: Remove unused driver_name variable
Date: Tue,  4 Apr 2017 18:16:57 -0700
Message-ID: <20170405011657.1637-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Oliver Neukum <oneukum@suse.com>,
        linux-usb@vger.kernel.org (open list:USB NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With GCC 6.3, we can get the following warning:

drivers/net/usb/usbnet.c:85:19: warning: 'driver_name' defined but not
used [-Wunused-const-variable=]
 static const char driver_name [] = "usbnet";
                   ^~~~~~~~~~~

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/usb/usbnet.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9890656af735..1cc945cbeaa3 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -82,8 +82,6 @@
 // randomly generated ethernet address
 static u8	node_id [ETH_ALEN];
 
-static const char driver_name [] = "usbnet";
-
 /* use ethtool to change the level for any given device */
 static int msg_level = -1;
 module_param (msg_level, int, 0);
-- 
2.9.3
