From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-07-31
Date: Fri, 31 Jul 2015 15:59:00 +0300
Message-ID: <87r3no1o17.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request for 4.3. In this pull request there's I have one
revert in commit 360d9bb5ee2d ("Revert "ath9k: export HW random number
generator""), the data doesn't seem to be random enough. Please let me
know if you have any problems.

Kalle

The following changes since commit 9d7b372f0514d829b2f712aac5b85eaab2dc=
0cb2:

  Merge branch 'be2net-next' (2015-07-10 23:24:31 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-07-31

for you to fetch changes up to 360d9bb5ee2db4d409448667de606c05b3914d53=
:

  Revert "ath9k: export HW random number generator" (2015-07-31 10:25:1=
6 +0300)

----------------------------------------------------------------
Major changes:

mwifiex:

* add TX DATA Pause support
* add multichannel and TDLS channel switch support

ath10k:

* enable VHT for IBSS
* initial work to support qca99x0 and the corresponding 10.4 firmware b=
ranch

----------------------------------------------------------------
Andy Shevchenko (1):
      iwlegacy: convert hex_dump_to_buffer() to %*ph

Aniket Nagarnaik (4):
      mwifiex: fix for p2p broken link
      mwifiex: add bss mode TLV to extended scan command
      mwifiex: use maximum ssid length as 0xfe for p2p
      mwifiex: correct p2p and station interface counters

Antonio Borneo (1):
      wireless: cw1200: Remove redundant spi driver bus initialization

Avinash Patil (10):
      mwifiex: add tx data pause support
      mwifiex: update domain_info upon band change in start_ap
      mwifiex: support for bypass tx queue
      mwifiex: enable traffic only when port is open
      mwifiex: extend tx_data pause to AP interface as well
      mwifiex: support to set multichannel policy to FW
      mwifiex: advertise multichannel support to cfg80211
      mwifiex: separate interface combination for multichannel and DFS
      mwifiex: handle multichannel event
      MAINTAINERS: update for mwifiex driver maintainers

Bartosz Markowski (1):
      ath10k: fix QCA61X4 boot up

Christophe Jaillet (1):
      brcmsmac: Use kstrdup to simplify code

=46elix Fietkau (1):
      ath9k: make DMA stop related messages debug-only

Guy Mishol (1):
      wlcore: add antenna diversity reading

Hauke Mehrtens (1):
      bcma: fix build error when build as module

Janusz Dziedzic (1):
      ath10k: enable VHT for IBSS

John Linville (3):
      mwifiex: avoid freeing improper pointer in mwifiex_set_wowlan_mef=
_entry
      mwifiex: do not short circuit exit from mwifiex_set_mgmt_ies
      mwifiex: fix leak of gen_ie storage on exit from mwifiex_del_mgmt=
_ies

Kalle Valo (2):
      Merge ath-next from ath.git.
      Revert "ath9k: export HW random number generator"

Larry Finger (1):
      rtlwifi: rtl8821ae: Fix an expression that is always false

Miaoqing Pan (2):
      ath9k: Fix register definitions for QCA956x
      ath9k: export HW random number generator

Michal Kazior (10):
      ath10k: dump fw features during probing
      ath10k: print htt op_version upon driver boot
      ath10k: prevent debugfs mmio access crash kernel
      ath10k: don't set cck/ofdm scan flags
      ath10k: limit multi-vif ps more aggresivelly
      ath10k: fix hw roc expiration notifcation
      ath10k: update vdev ps state on start
      ath10k: fix per-vif queue locking
      ath10k: tweak interface combinations
      ath9k: fix moredata flag endianness in cabq tx

Nicholas Mc Guire (3):
      ath10k: mac: remove unreachable negative return check
      ath10k: txrx: remove unreachable negative return check and fixup =
type
      ipw2100: fix timeout bug - always evaluated to 0

Nik Nyby (2):
      rtlwifi: fix typo in comments
      b43: Fix typo in function name

Rafa? Mi?ecki (1):
      brcmfmac: set wiphy's addresses to provide valid MACs

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: populate bus DT subnodes as platform_device-s

Raja Mani (19):
      ath10k: remove unused variable hdr in ath10k_htt_rx_h_undecap()
      ath10k: include new wmi op version for 10.4 fw
      ath10k: add 10.4 fw wmi service bitmap definition
      ath10k: include 10.4 fw specific wmi cmd and event ids
      ath10k: set 10.4 fw exclusive wmi cmd as unsupported for other fw=
 versions
      ath10k: add 10.4 fw wmi vdev cmd ids
      ath10k: add 10.4 fw wmi pdev cmd ids
      ath10k: fill 10.4 fw wmi init cmd default values
      ath10k: handle 10.4 fw wmi mgmt rx event
      ath10k: adjust default peer limits if qcache enabled in 10.4 fw
      ath10k: handle 10.4 fw wmi ready event
      ath10k: enhance swba event handler to adapt different size tim bi=
tmap
      ath10k: handle 10.4 firmware wmi swba event
      ath10k: enable vdev and peer related operations for 10.4 fw
      ath10k: add scan support for 10.4 fw
      ath10k: add 10.4 fw specific htt msg definitions
      ath10k: advertise 10.4 fw ap and sta iface combination to mac8021=
1
      ath10k: set max spatial stream to 4 for 10.4 fw
      ath10k: configure frag desc memory to target for qca99X0

Rapha=C3=ABl Poggi (1):
      wlcore: sdio: return correct error code

Reyad Attiyat (1):
      mwifiex: usb: Fix double add error when submitting rx urb

Taehee Yoo (1):
      rtlwifi: rtl8192cu: Remove rtl8723 code

Vasanthakumar Thiagarajan (11):
      ath10k: Add a table to store hw specific values
      ath10k: Add new reg_address/mask to hw register table
      ath10k: Add hw register/values for QCA99X0 chip
      ath10k: Copy Engine related changes for QCA99X0
      ath10k: Make target cpu address to CE address conversion chip spe=
cific
      ath10k: Add chip reset sequence for QCA99X0
      ath10k: Extend CE src desc flags for interrupt indication
      ath10k: Fix BMI communication timeout for QCA99X0
      ath10k: Add support for code swap
      ath10k: Add BMI param value to execute otp to hw_param
      ath10k: Fix target to cpu address conversion logic

Vladimir Kondratiev (1):
      wil6210: restart AP upon change in privacy settings

Xinming Hu (8):
      mwifiex: block data traffic to tx paused receive address
      mwifiex: do not increase tx_pkts_queued if receive address tx pau=
sed
      mwifiex: add tdls channel switch status
      mwifiex: process tdls channel switch event
      mwifiex: add tdls config command
      mwifiex: enable tdls channel switch ext_cap
      mwifiex: enhance tdls link setup condition
      mwifiex: add cfg80211 tdls channel switch handler

Zefir Kurtisi (3):
      ath: DFS - limit number of potential PRI sequences
      ath9k: DFS - consider ext_channel pulses only in HT40 mode
      ath9k: DFS - add pulse chirp detection for FCC

 MAINTAINERS                                        |    2 +-
 drivers/bcma/main.c                                |   12 +
 drivers/net/wireless/ath/ath10k/Makefile           |    3 +-
 drivers/net/wireless/ath/ath10k/bmi.h              |    2 +-
 drivers/net/wireless/ath/ath10k/ce.c               |    1 +
 drivers/net/wireless/ath/ath10k/ce.h               |   17 +-
 drivers/net/wireless/ath/ath10k/core.c             |  111 +-
 drivers/net/wireless/ath/ath10k/core.h             |   26 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   10 +-
 drivers/net/wireless/ath/ath10k/htt.c              |   45 +
 drivers/net/wireless/ath/ath10k/htt.h              |   47 +
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    6 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   76 +-
 drivers/net/wireless/ath/ath10k/hw.c               |   86 +-
 drivers/net/wireless/ath/ath10k/hw.h               |  124 ++-
 drivers/net/wireless/ath/ath10k/mac.c              |  159 ++-
 drivers/net/wireless/ath/ath10k/mac.h              |    6 +-
 drivers/net/wireless/ath/ath10k/pci.c              |  193 +++-
 drivers/net/wireless/ath/ath10k/pci.h              |   13 +-
 drivers/net/wireless/ath/ath10k/swap.c             |  208 ++++
 drivers/net/wireless/ath/ath10k/swap.h             |   72 ++
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    3 +
 drivers/net/wireless/ath/ath10k/txrx.c             |    6 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |  142 ++-
 drivers/net/wireless/ath/ath10k/wmi.c              | 1104 ++++++++++++=
+++++++-
 drivers/net/wireless/ath/ath10k/wmi.h              |  949 ++++++++++++=
++++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   25 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    2 +
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/dfs.c               |  170 ++-
 drivers/net/wireless/ath/ath9k/recv.c              |    7 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   11 +-
 drivers/net/wireless/ath/dfs_pri_detector.c        |    2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  217 ++--
 drivers/net/wireless/ath/wil6210/wil6210.h         |    2 +
 drivers/net/wireless/b43/lo.c                      |    4 +-
 drivers/net/wireless/b43/lo.h                      |    2 +-
 drivers/net/wireless/b43/phy_g.c                   |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |   14 +
 drivers/net/wireless/brcm80211/brcmfmac/core.h     |    3 +
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    4 +-
 drivers/net/wireless/cw1200/cw1200_spi.c           |    1 -
 drivers/net/wireless/ipw2x00/ipw2100.c             |    2 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/debug.c              |    8 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  130 ++-
 drivers/net/wireless/mwifiex/decl.h                |    3 +
 drivers/net/wireless/mwifiex/fw.h                  |   93 +-
 drivers/net/wireless/mwifiex/ie.c                  |    3 +
 drivers/net/wireless/mwifiex/init.c                |    3 +-
 drivers/net/wireless/mwifiex/join.c                |    2 +
 drivers/net/wireless/mwifiex/main.c                |   63 +-
 drivers/net/wireless/mwifiex/main.h                |   38 +
 drivers/net/wireless/mwifiex/scan.c                |   14 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |   90 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    5 +
 drivers/net/wireless/mwifiex/sta_event.c           |  207 +++-
 drivers/net/wireless/mwifiex/tdls.c                |   78 +-
 drivers/net/wireless/mwifiex/txrx.c                |   22 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |    7 +-
 drivers/net/wireless/mwifiex/uap_event.c           |   13 +
 drivers/net/wireless/mwifiex/usb.c                 |    6 +-
 drivers/net/wireless/mwifiex/util.c                |   59 ++
 drivers/net/wireless/mwifiex/wmm.c                 |  156 ++-
 drivers/net/wireless/mwifiex/wmm.h                 |    8 +
 drivers/net/wireless/rtlwifi/rtl8192cu/def.h       |    9 -
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   12 -
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h       |    1 +
 drivers/net/wireless/ti/wlcore/rx.c                |    3 +-
 drivers/net/wireless/ti/wlcore/rx.h                |    3 +
 drivers/net/wireless/ti/wlcore/sdio.c              |    3 +-
 74 files changed, 4605 insertions(+), 351 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath10k/swap.c
 create mode 100644 drivers/net/wireless/ath/ath10k/swap.h

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
