From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 03/11] net: usb: sr9800: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Mar 2017 23:18:49 +0100
Message-ID: <1489702737-2401-4-git-send-email-tremyfr@gmail.com>
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
 drivers/net/usb/sr9800.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index a50df0d..a696b62 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -524,9 +524,9 @@ static int sr_set_mac_address(struct net_device *net, void *p)
 	.set_wol	= sr_set_wol,
 	.get_eeprom_len	= sr_get_eeprom_len,
 	.get_eeprom	= sr_get_eeprom,
-	.get_settings	= usbnet_get_settings,
-	.set_settings	= usbnet_set_settings,
 	.nway_reset	= usbnet_nway_reset,
+	.get_link_ksettings	= usbnet_get_link_ksettings,
+	.set_link_ksettings	= usbnet_set_link_ksettings,
 };
 
 static int sr9800_link_reset(struct usbnet *dev)
-- 
1.7.4.4
