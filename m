From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 00/11] net: usbnet: move to new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Mar 2017 23:18:46 +0100
Message-ID: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: oliver@neukum.org, jacmet@sunsite.dk,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        gregkh@linuxfoundation.org, davem@davemloft.net,
        robert.foss@collabora.com, allan@asix.com.tw, grundler@google.com,
        jarod@redhat.com, peter.chen@nxp.com, stefan.bruens@rwth-aachen.de,
        akpm@linux-foundation.org, adobriyan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated. On usbnet, it
was often implemented with usbnet_{get|set}_settings.

In this serie, I add usbnet_{get|set}_link_ksettings
in the first patch, then I update all the driver to
use this new api, and in the last patch I remove the
old api usbnet_{get|set}_settings.


Philippe Reynes (11):
  net: usb: usbnet: add new api ethtool_{get|set}_link_ksettings
  net: usb: smsc95xx: use new api ethtool_{get|set}_link_ksettings
  net: usb: sr9800: use new api ethtool_{get|set}_link_ksettings
  net: usb: cdc_ncm: use new api ethtool_{get|set}_link_ksettings
  net: usb: dm9601: use new api ethtool_{get|set}_link_ksettings
  net: usb: mcs7830: use new api ethtool_{get|set}_link_ksettings
  net: usb: sierra_net: use new api ethtool_{get|set}_link_ksettings
  net: usb: smsc75xx: use new api ethtool_{get|set}_link_ksettings
  net: usb: sr9700: use new api ethtool_{get|set}_link_ksettings
  net: usb: asix: use new api ethtool_{get|set}_link_ksettings
  net: usb: usb: remove old api ethtool_{get|set}_settings

 drivers/net/usb/asix_devices.c |   12 ++++++------
 drivers/net/usb/cdc_ncm.c      |    4 ++--
 drivers/net/usb/dm9601.c       |    4 ++--
 drivers/net/usb/mcs7830.c      |    4 ++--
 drivers/net/usb/sierra_net.c   |    4 ++--
 drivers/net/usb/smsc75xx.c     |    4 ++--
 drivers/net/usb/smsc95xx.c     |   24 ++++++++++++------------
 drivers/net/usb/sr9700.c       |    4 ++--
 drivers/net/usb/sr9800.c       |    4 ++--
 drivers/net/usb/usbnet.c       |   19 ++++++++++---------
 include/linux/usb/usbnet.h     |    8 ++++----
 11 files changed, 46 insertions(+), 45 deletions(-)

-- 
1.7.4.4
