From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-06-18
Date: Thu, 18 Jun 2015 08:49:50 +0300
Message-ID: <871th98t1d.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's one more pull request I would like to get to 4.2 if possible.
Nothing major this time, just small stuff all over. Please let me know
if you have any problems.

Kalle

The following changes since commit c39c4c6abb89d24454b63798ccbae12b5382=
06a5:

  tcp: double default TSQ output bytes limit (2015-06-04 01:09:36 -0700=
)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-06-18

for you to fetch changes up to 40b503c76481aecf811a29a14a80c13b429b5e14=
:

  brcmfmac: make brcmf_p2p_detach() call conditional (2015-06-16 11:35:=
10 +0300)

----------------------------------------------------------------
Major changes:

mwifiex:

* enhancements for AP mode: support verbose information in station
  dump command and also information about AP link.
* enable power save by default

brcmfmac:

* fix module reload issue for PCIe
* improving msgbuf protocol for PCIe devices
* rework .get_station() cfg80211 callback operation
* determine interface combinations upon device feature support

ath9k:

* ath9k_htc: add support of channel switch

wil6210:

* add modparam for bcast ring size
* support hidden SSID
* add per-MCS Rx stats

----------------------------------------------------------------
Amitkumar Karwar (1):
      mwifiex: add missing break statement in switch case

Arend van Spriel (10):
      brcmfmac: remove chipinfo debugfs entry
      brcmfmac: remove watchdog reset from brcmf_pcie_buscoreprep()
      brcmfmac: use debugfs_create_devm_seqfile() helper function
      brcmfmac: rework .get_station() callback
      brcmfmac: have sdio return -EIO when device communication is not =
possible
      brcmfmac: free ifp for non-netdev interface in p2p module
      brcmfmac: move p2p attach/detach functions
      brcmfmac: assure p2pdev is unregistered upon driver unload
      brcmfmac: fix double free of p2pdev interface
      brcmfmac: make brcmf_p2p_detach() call conditional

Avinash Patil (12):
      mwifiex: verbose logging for association failure messages
      mwifiex: correct bss_type assignment
      mwifiex: support AP reset after bss_stop
      mwifiex: enable 11d after bss reset
      mwifiex: reset 11h active flag when chandef does not require dfs
      mwifiex: disable CAC upon radar detection event
      mwifiex: parse power constraint IE from Tail
      mwifiex: support downloading IEs from tail
      mwifiex: drop block-ack action frames
      mwifiex: advertise PS ON by default support to cfg80211
      mwifiex: update AP WMM settings from BSS_START event
      mwifiex: update current config_band info in start_ap

Brent Taylor (1):
      ath6kl: Fix multiple clients associating in AP mode

Chun-Yeow Yeoh (1):
      ath9k_htc: add support of channel switch

Chunfan Chen (1):
      mwifiex: handle BT coex event to adjust Rx BA window size

=46elix Fietkau (1):
      ath9k: fix DMA stop sequence for AR9003+

Hamad Kadmany (1):
      wil6210: Support hidden SSID

Hans Ulli Kroll (1):
      rtlwifi: fix tm_trigger usage

Hante Meuleman (1):
      brcmfmac: Update msgbuf read pointer quicker.

Jakub Kicinski (5):
      mt7601u: unify paged and non-paged RX dma paths
      mt7601u: watch out for invalid-length frames
      mt7601u: don't cleanup device second time after .resume()
      mt7601u: set promiscous mode based on FIF_OTHER_BSS
      mt7601u: don't warn about devices without per-rate power table

Julia Lawall (1):
      wl1251: drop unneeded goto

Kalle Valo (1):
      Merge ath-next from ath.git

Michal Kazior (9):
      ath10k: move cycle_count macro
      ath10k: handle cycle counter wraparound
      ath10k: fix inconsistent survey reports
      ath10k: add missing firmware declarations
      ath10k: fix possible ps sleep crash
      ath10k: fix ar->rx_channel updating logic
      ath10k: remove ath10k_chanctx struct
      ath10k: fix channel switching
      ath10k: prevent memory leak in wmi rx ops

Pontus Fuchs (2):
      brcmfmac: Check if firmware supports p2p
      brcmfmac: Build wiphy mode and interface combinations dynamically

Rafa=C5=82 Mi=C5=82ecki (6):
      brcmfmac: support NVRAMs containing pci devpaths (instead of pcie=
)
      brcmfmac: set wiphy perm_addr to hardware MAC address
      brcmfmac: use direct data pointer in NVRAM parser struct
      b43: fix support for 14e4:4321 PCI dev with BCM4321 chipset
      bcma: make calls to PCI hostmode functions config-safe
      bcma: lower dependency of BCMA_DRIVER_PCI_HOSTMODE

Raja Mani (2):
      ath10k: free wmi mgmt event skb when parsing fails
      ath10k: remove unused variable 'id' in ath10k_pci_tx_pipe_cleanup=
()

Rajkumar Manoharan (1):
      ath10k: bypass PLL setting on target init for QCA9888

Stanislaw Gruszka (2):
      MAINTAINERS: remove rt2x00.serialmonkey.com list and web page
      rt2800: fix assigning same WCID for different stations

Taehee Yoo (8):
      rtlwifi: rtl8192cu: Fix performance issue.
      rtlwifi: rtl8192cu: remove IS_HARDWARE_TYPE_8192CE and IS_HARDWAR=
E_TYPE_8192CU
      rtlwifi: rtl8192cu: remove _InitBeaconParameters().
      rtlwifi: rtl8192cu: remove INTF_PCI and INTF_USB
      rtlwifi: rtl8192cu: remove duplicated routine in _rtl92c_phy_rf60=
52_config_parafile
      rtlwifi: rtl8192cu: debug message change "RTL8192CE" to "RTL8192C=
U"
      rtlwifi: rtl8192cu: Fix variable isfirst_ampdu
      rtlwifi: rtl8192c: Add init codes for "fw_version" and "fw_subver=
sion".

Vladimir Kondratiev (5):
      wil6210: modparam for bcast ring size
      wil6210: add NIC memory region mac_rgf_ext
      wil6210: add per-MCS Rx stats
      wil6210: platform hooks for modile init/exit
      wil6210: reorder init sequence

Xinming Hu (6):
      mwifiex: add cfg80211 get_channel handler
      mwifiex: maintain station statistic in uap mode
      mwifiex: add sta_list firmware command
      mwifiex: dump station support in uap mode
      mwifiex: using right tid for addressing ra_list
      mwifiex: do not decrease tx_pending for AMSDU packet once more

Zhaoyang Liu (1):
      mwifiex: change debug dump issue since skb maybe null

 MAINTAINERS                                        |    2 -
 drivers/bcma/Kconfig                               |   12 +-
 drivers/net/wireless/ath/ath10k/core.c             |   17 ++
 drivers/net/wireless/ath/ath10k/core.h             |   27 +-
 drivers/net/wireless/ath/ath10k/hw.c               |   21 ++
 drivers/net/wireless/ath/ath10k/hw.h               |    6 +
 drivers/net/wireless/ath/ath10k/mac.c              |  211 +++++-------=
-
 drivers/net/wireless/ath/ath10k/pci.c              |    6 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |    3 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   40 +--
 drivers/net/wireless/ath/ath10k/wmi.h              |    1 -
 drivers/net/wireless/ath/ath6kl/wmi.h              |    2 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   19 ++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   17 ++
 drivers/net/wireless/ath/ath9k/main.c              |   12 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   46 ++-
 drivers/net/wireless/ath/wil6210/debugfs.c         |    8 +-
 drivers/net/wireless/ath/wil6210/main.c            |    2 +
 drivers/net/wireless/ath/wil6210/netdev.c          |    3 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   99 +++---
 drivers/net/wireless/ath/wil6210/txrx.c            |    2 +
 drivers/net/wireless/ath/wil6210/wil6210.h         |    9 +-
 drivers/net/wireless/ath/wil6210/wil_platform.c    |   14 +-
 drivers/net/wireless/ath/wil6210/wil_platform.h    |    3 +
 drivers/net/wireless/ath/wil6210/wmi.c             |    5 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |   10 +-
 drivers/net/wireless/b43/main.c                    |    4 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |  315 +++++++++++-=
--------
 .../net/wireless/brcm80211/brcmfmac/commonring.c   |   19 +-
 .../net/wireless/brcm80211/brcmfmac/commonring.h   |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/core.c     |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/debug.c    |   50 +---
 drivers/net/wireless/brcm80211/brcmfmac/feature.c  |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/feature.h  |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |   50 ++--
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   79 +++--
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   12 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  203 +++++++-----=
-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |   16 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |    6 +
 drivers/net/wireless/mediatek/mt7601u/dma.c        |   74 ++---
 drivers/net/wireless/mediatek/mt7601u/eeprom.c     |    4 +
 drivers/net/wireless/mediatek/mt7601u/init.c       |    3 +
 drivers/net/wireless/mediatek/mt7601u/mac.c        |    8 +-
 drivers/net/wireless/mediatek/mt7601u/main.c       |    1 +
 drivers/net/wireless/mediatek/mt7601u/usb.c        |    9 +-
 drivers/net/wireless/mwifiex/11h.c                 |   32 +-
 drivers/net/wireless/mwifiex/11n.c                 |  104 ++++++-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   85 +++++-
 drivers/net/wireless/mwifiex/cfg80211.c            |  130 +++++++-
 drivers/net/wireless/mwifiex/cmdevt.c              |    5 +-
 drivers/net/wireless/mwifiex/decl.h                |    7 +-
 drivers/net/wireless/mwifiex/fw.h                  |   62 +++-
 drivers/net/wireless/mwifiex/ie.c                  |  102 ++++---
 drivers/net/wireless/mwifiex/ioctl.h               |    1 +
 drivers/net/wireless/mwifiex/join.c                |   30 +-
 drivers/net/wireless/mwifiex/main.h                |   37 ++-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   26 ++
 drivers/net/wireless/mwifiex/sta_event.c           |   62 ++++
 drivers/net/wireless/mwifiex/txrx.c                |   21 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   57 +++-
 drivers/net/wireless/mwifiex/uap_event.c           |   68 +++++
 drivers/net/wireless/mwifiex/uap_txrx.c            |   18 +-
 drivers/net/wireless/mwifiex/util.c                |   56 +++-
 drivers/net/wireless/rt2x00/rt2800.h               |   10 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |   57 ++--
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   16 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   51 ++--
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   15 -
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h       |    3 -
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |   28 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   22 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c        |   14 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    1 +
 drivers/net/wireless/ti/wl1251/acx.c               |    3 -
 include/linux/bcma/bcma_driver_pci.h               |   11 +
 86 files changed, 1740 insertions(+), 902 deletions(-)

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
