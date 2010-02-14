From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [net-next PATCH 0/2] usbnet: convert dev(dbg|err|warn|info) macros to netdev_<>
Date: Sun, 14 Feb 2010 15:01:45 -0800
Message-ID: <cover.1266187669.git.joe@perches.com>
References: <20100212.123837.56526847.davem@davemloft.net>
Cc: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100212.123837.56526847.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add some consistency to log messages
Use the net netif_<> macros

Joe Perches (2):
  usbnet: Convert dev(dbg|err|warn|info) macros to netdev_<level>
  drivers/net/usb: Use netif_<level> logging facilities

 drivers/net/usb/asix.c       |   97 +++++++++--------
 drivers/net/usb/cdc_eem.c    |   10 +-
 drivers/net/usb/cdc_ether.c  |   22 ++--
 drivers/net/usb/dm9601.c     |   49 +++++----
 drivers/net/usb/int51x1.c    |   15 ++--
 drivers/net/usb/net1080.c    |  109 +++++++++-----------
 drivers/net/usb/pegasus.c    |  170 +++++++++++++-----------------
 drivers/net/usb/rndis_host.c |   24 ++---
 drivers/net/usb/smsc95xx.c   |  221 ++++++++++++++++++---------------------
 drivers/net/usb/usbnet.c     |  238 +++++++++++++++++++-----------------------
 include/linux/usb/usbnet.h   |   21 ----
 11 files changed, 448 insertions(+), 528 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
