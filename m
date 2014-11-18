From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] usbnet: rtl8150: remove unused variable
Date: Tue, 18 Nov 2014 18:29:59 +0530
Message-ID: <1416315599-16939-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

we were just returning the initial value of res, instead now
we are returning the value directly.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/usb/rtl8150.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6e87e57..d37b7dc 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -753,14 +753,13 @@ static int rtl8150_open(struct net_device *netdev)
 static int rtl8150_close(struct net_device *netdev)
 {
 	rtl8150_t *dev = netdev_priv(netdev);
-	int res = 0;
 
 	netif_stop_queue(netdev);
 	if (!test_bit(RTL8150_UNPLUG, &dev->flags))
 		disable_net_traffic(dev);
 	unlink_all_urbs(dev);
 
-	return res;
+	return 0;
 }
 
 static void rtl8150_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *info)
-- 
1.8.1.2
