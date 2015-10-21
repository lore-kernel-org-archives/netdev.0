From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 00/15] Fix warnings reported by coccicheck
Date: Wed, 21 Oct 2015 20:25:22 +0530
Message-ID: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix various warning reported by coccicheck:

make coccicheck M=drivers/net/wireless


Punit Vara (15):
  net: wireless: ath: use | instead of + for summing bitmasks
  net: wireless: ath: Remove unnecessary semicolon
  net: wireless: ath: Remove unnecessary semicolon
  net: wireless: ipw2x00: use | instead of + for summing bitmasks
  net: wireless: ti: Return flow can be simplified for
    wl1271_cmd_interrogate
  net: wireless: rtwifi: Remove duplicated arguments to |
  net: wireless: brcm80211: Remove duplicated arguments to |
  net: wireless: simplify return flow for usb_msg_control
  net: wireless: simplify return flow for zd1201_setconfig16
  net: wireless: ath: simplify return flow for
    carl9170_regwrite_result()
  net: wireless: iwlegacy: Remove unneeded variable ret
  net: wireless: brcm80211: Remove unneeded variable which return 0
  net: wireless: brcm80211: Remove unneeded variable ret_code returning
    0
  net: wireless: ath: Remove unneeded variable ret returning 0
  net: wireless: ath: Remove unneeded variable ret returning 0

 drivers/net/wireless/at76c50x-usb.c               |  5 +----
 drivers/net/wireless/ath/ath10k/htt_rx.c          |  2 +-
 drivers/net/wireless/ath/ath10k/pci.c             | 10 +++++-----
 drivers/net/wireless/ath/ath10k/wmi.h             |  2 +-
 drivers/net/wireless/ath/ath5k/eeprom.c           |  4 ++--
 drivers/net/wireless/ath/carl9170/phy.c           |  7 +------
 drivers/net/wireless/ath/wcn36xx/main.c           |  3 +--
 drivers/net/wireless/brcm80211/brcmsmac/channel.c |  1 -
 drivers/net/wireless/brcm80211/brcmsmac/main.c    |  3 +--
 drivers/net/wireless/brcm80211/brcmsmac/stf.c     |  5 ++---
 drivers/net/wireless/ipw2x00/libipw_rx.c          |  4 ++--
 drivers/net/wireless/iwlegacy/3945-mac.c          |  5 +----
 drivers/net/wireless/rtlwifi/debug.c              |  6 +++---
 drivers/net/wireless/ti/wlcore/acx.c              |  6 +-----
 drivers/net/wireless/zd1201.c                     |  6 +-----
 15 files changed, 23 insertions(+), 46 deletions(-)

--
2.5.3
