From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 00/35] constify net usb_device_id
Date: Tue,  8 Aug 2017 21:25:27 +0530
Message-ID: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org, wg@grandegger.com, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

[PATCH 10/35] :Fix checkpatch.pl error.
ERROR: space prohibited before open square bracket '['.

Arvind Yadav (35):
  [PATCH 01/35] can: ems_usb: constify usb_device_id
  [PATCH 02/35] can: esd_usb2: constify usb_device_id
  [PATCH 03/35] can: peak_usb: constify usb_device_id
  [PATCH 04/35] net: irda: irda-usb: constify usb_device_id
  [PATCH 05/35] net: irda: kingsun: constify usb_device_id
  [PATCH 06/35] net: irda: ks959: constify usb_device_id
  [PATCH 07/35] net: irda: ksdazzle: constify usb_device_id
  [PATCH 08/35] net: irda: mcs7780: constify usb_device_id
  [PATCH 09/35] net: irda: stir4200: constify usb_device_id
  [PATCH 10/35] net: usb: catc: constify usb_device_id and and fix space before '[' error
  [PATCH 11/35] net: usb: cdc-phonet: constify usb_device_id
  [PATCH 12/35] net: usb: ipheth: constify usb_device_id
  [PATCH 13/35] net: usb: kaweth: constify usb_device_id
  [PATCH 14/35] net: usb: r8152: constify usb_device_id
  [PATCH 15/35] net: usb: rtl8150: constify usb_device_id
  [PATCH 16/35] wireless: ath: ar5523: constify usb_device_id
  [PATCH 17/35] wireless: ath: ath6kl: constify usb_device_id
  [PATCH 18/35] wireless: ath: ath9k: constify usb_device_id
  [PATCH 19/35] wireless: ath: carl9170: constify usb_device_id
  [PATCH 20/35] wireless: atmel: at76c50x: constify usb_device_id
  [PATCH 21/35] wireless: broadcom: brcm80211: constify usb_device_id
  [PATCH 22/35] wireless: intersil: orinoco: constify usb_device_id
  [PATCH 23/35] wireless: intersil: p54: constify usb_device_id
  [PATCH 24/35] wireless: marvell: libertas: constify usb_device_id
  [PATCH 25/35] wireless: marvell: libertas_tf: constify usb_device_id
  [PATCH 26/35] wireless: marvell: mwifiex: constify usb_device_id
  [PATCH 27/35] wireless: mediatek: mt7601u: constify usb_device_id
  [PATCH 28/35] wireless: ralink: rt2500usb: constify usb_device_id
  [PATCH 29/35] wireless: ralink: rt2800usb: constify usb_device_id
  [PATCH 30/35] wireless: ralink: rt73usb: constify usb_device_id
  [PATCH 31/35] wireless: realtek: rtl8187: constify usb_device_id
  [PATCH 32/35] wireless: realtek: rtl8xxxu: constify usb_device_id
  [PATCH 33/35] wireless: realtek: rtl8192cu: constify usb_device_id
  [PATCH 34/35] wireless: zydas: zd1201: constify usb_device_id
  [PATCH 35/35] wireless: zydas: zd1211rw: constify usb_device_id

 drivers/net/can/usb/ems_usb.c                          | 2 +-
 drivers/net/can/usb/esd_usb2.c                         | 2 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.c           | 2 +-
 drivers/net/irda/irda-usb.c                            | 2 +-
 drivers/net/irda/kingsun-sir.c                         | 2 +-
 drivers/net/irda/ks959-sir.c                           | 2 +-
 drivers/net/irda/ksdazzle-sir.c                        | 2 +-
 drivers/net/irda/mcs7780.c                             | 2 +-
 drivers/net/irda/stir4200.c                            | 2 +-
 drivers/net/usb/catc.c                                 | 2 +-
 drivers/net/usb/cdc-phonet.c                           | 2 +-
 drivers/net/usb/ipheth.c                               | 2 +-
 drivers/net/usb/kaweth.c                               | 2 +-
 drivers/net/usb/r8152.c                                | 2 +-
 drivers/net/usb/rtl8150.c                              | 2 +-
 drivers/net/wireless/ath/ar5523/ar5523.c               | 2 +-
 drivers/net/wireless/ath/ath6kl/usb.c                  | 2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c               | 2 +-
 drivers/net/wireless/ath/carl9170/usb.c                | 2 +-
 drivers/net/wireless/atmel/at76c50x-usb.c              | 2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c | 2 +-
 drivers/net/wireless/intersil/orinoco/orinoco_usb.c    | 2 +-
 drivers/net/wireless/intersil/p54/p54usb.c             | 2 +-
 drivers/net/wireless/marvell/libertas/if_usb.c         | 2 +-
 drivers/net/wireless/marvell/libertas_tf/if_usb.c      | 2 +-
 drivers/net/wireless/marvell/mwifiex/usb.c             | 2 +-
 drivers/net/wireless/mediatek/mt7601u/usb.c            | 2 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c         | 2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c         | 2 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c           | 2 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c     | 2 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c    | 2 +-
 drivers/net/wireless/zydas/zd1201.c                    | 2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_usb.c           | 2 +-
 35 files changed, 35 insertions(+), 35 deletions(-)

-- 
2.7.4

