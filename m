From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 05/11] net: usb: dm9601: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Mar 2017 23:18:51 +0100
Message-ID: <1489702737-2401-6-git-send-email-tremyfr@gmail.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: oliver@neukum.org, jacmet@sunsite.dk,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        gregkh@linuxfoundation.org, davem@davemloft.net,
        robert.foss@collabora.com, allan@asix.com.tw, grundler@google.com,
        jarod@redhat.com, peter.chen@nxp.com, stefan.bruens@rwth-aachen.de,
        akpm@linux-foundation.org, adobriyan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/dm9601.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 0b4bdd3..fea1b64 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -281,9 +281,9 @@ static int dm9601_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 	.set_msglevel	= usbnet_set_msglevel,
 	.get_eeprom_len	= dm9601_get_eeprom_len,
 	.get_eeprom	= dm9601_get_eeprom,
-	.get_settings	= usbnet_get_settings,
-	.set_settings	= usbnet_set_settings,
 	.nway_reset	= usbnet_nway_reset,
+	.get_link_ksettings	= usbnet_get_link_ksettings,
+	.set_link_ksettings	= usbnet_set_link_ksettings,
 };
 
 static void dm9601_set_multicast(struct net_device *net)
-- 
1.7.4.4
