From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 00/16] net: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:05:19 +0200
Message-ID: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>,
	brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This per-subsystem series is part of a tree wide cleanup. usb_alloc_urb() uses
kmalloc which already prints enough information on failure. So, let's simply
remove those "allocation failed" messages from drivers like we did already for
other -ENOMEM cases. gkh acked this approach when we talked about it at LCJ in
Tokyo a few weeks ago.


Wolfram Sang (16):
  net: can: usb: ems_usb: don't print error when allocating urb fails
  net: can: usb: esd_usb2: don't print error when allocating urb fails
  net: can: usb: gs_usb: don't print error when allocating urb fails
  net: can: usb: kvaser_usb: don't print error when allocating urb fails
  net: can: usb: peak_usb: pcan_usb_core: don't print error when
    allocating urb fails
  net: can: usb: usb_8dev: don't print error when allocating urb fails
  net: usb: hso: don't print error when allocating urb fails
  net: usb: lan78xx: don't print error when allocating urb fails
  net: usb: usbnet: don't print error when allocating urb fails
  net: wimax: i2400m: usb-notif: don't print error when allocating urb
    fails
  net: wireless: ath: ar5523: ar5523: don't print error when allocating
    urb fails
  net: wireless: broadcom: brcm80211: brcmfmac: usb: don't print error
    when allocating urb fails
  net: wireless: intersil: orinoco: orinoco_usb: don't print error when
    allocating urb fails
  net: wireless: marvell: libertas_tf: if_usb: don't print error when
    allocating urb fails
  net: wireless: marvell: mwifiex: usb: don't print error when
    allocating urb fails
  net: wireless: realtek: rtlwifi: usb: don't print error when
    allocating urb fails

 drivers/net/can/usb/ems_usb.c                        |  9 ++-------
 drivers/net/can/usb/esd_usb2.c                       |  3 ---
 drivers/net/can/usb/gs_usb.c                         |  9 ++-------
 drivers/net/can/usb/kvaser_usb.c                     |  7 +------
 drivers/net/can/usb/peak_usb/pcan_usb_core.c         |  6 +-----
 drivers/net/can/usb/usb_8dev.c                       |  5 +----
 drivers/net/usb/hso.c                                | 20 +++++---------------
 drivers/net/usb/lan78xx.c                            |  4 +---
 drivers/net/usb/usbnet.c                             |  5 +----
 drivers/net/wimax/i2400m/usb-notif.c                 |  1 -
 drivers/net/wireless/ath/ar5523/ar5523.c             |  9 ++-------
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c   |  8 ++------
 drivers/net/wireless/intersil/orinoco/orinoco_usb.c  |  4 +---
 drivers/net/wireless/marvell/libertas_tf/if_usb.c    | 12 +++---------
 drivers/net/wireless/marvell/mwifiex/usb.c           | 19 ++++---------------
 drivers/net/wireless/realtek/rtlwifi/usb.c           |  8 +-------
 16 files changed, 27 insertions(+), 102 deletions(-)

-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
