From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 0/3] r8152: configuration setting
Date: Wed, 7 Sep 2016 16:12:19 +0800
Message-ID: <1394712342-15778-215-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some people prefer to use ECM mode rather than vendor mode. Therefore, I add
CONFIG_RTL8152_CONFIG_VALUE in Kconfig. Then, the users could choose the USB
configuration value which they want. The default is to support vendor mode
only.

Hayes Wang (3):
  r8152: check hw version first
  r8152: support ECM mode
  r8152: add CONFIG_RTL8152_CONFIG_VALUE

 drivers/net/usb/Kconfig |  13 ++
 drivers/net/usb/r8152.c | 383 +++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 345 insertions(+), 51 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
