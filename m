From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 00/20] constify wireless usb_device_id
Date: Wed,  9 Aug 2017 21:53:41 +0530
Message-ID: <1502295823-20824-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Arvind Yadav (20):
  [PATCH v2 01/20] ar5523: constify usb_device_id
  [PATCH v2 02/20] ath6kl: constify usb_device_id
  [PATCH v2 03/20] ath9k: constify usb_device_id
  [PATCH v2 04/20] carl9170: constify usb_device_id
  [PATCH v2 05/20] at76c50x: constify usb_device_id
  [PATCH v2 06/20] brcm80211: constify usb_device_id
  [PATCH v2 07/20] orinoco: constify usb_device_id
  [PATCH v2 08/20] p54: constify usb_device_id
  [PATCH v2 09/20] libertas: constify usb_device_id
  [PATCH v2 10/20] libertas_tf: constify usb_device_id
  [PATCH v2 11/20] marvell: mwifiex: constify usb_device_id
  [PATCH v2 12/20] mt7601u: constify usb_device_id
  [PATCH v2 13/20] rt2500usb: constify usb_device_id
  [PATCH v2 14/20] rt2800usb: constify usb_device_id
  [PATCH v2 15/20] rt73usb: constify usb_device_id
  [PATCH v2 16/20] rtl8187: constify usb_device_id
  [PATCH v2 17/20] realtek: rtl8xxxu: constify usb_device_id
  [PATCH v2 18/20] realtek: rtl8192cu: constify usb_device_id
  [PATCH v2 19/20] zd1201: constify usb_device_id
  [PATCH v2 20/20] zd1211rw: constify usb_device_id

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
 20 files changed, 20 insertions(+), 20 deletions(-)

-- 
2.7.4
