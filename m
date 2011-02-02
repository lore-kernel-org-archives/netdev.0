From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-02-02
Date: Wed, 2 Feb 2011 16:53:22 -0500
Message-ID: <20110202215322.GD2500@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here we have another big batch of updates destined for 2.6.39.

A highlight is AP mode support for the wl12xx driver.  There are
also the usual updates to ath5k, ath9k, iwlwifi, rt2x00, and others.
Also included are some wireless-2.6 pulls to correct for some build breakage.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 2ba451421b23636c45fabfa522858c5c124b3673:

  bnx2x, cnic: Consolidate iSCSI/FCoE shared mem logic in bnx2x (2011-01-31 20:44:46 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Arik Nemtsov (20):
      wl12xx: Add AP related configuration to conf_drv_settings
      wl12xx: AP mode - AP specific CMD_CONFIGURE sub-commands
      wl12xx: AP mode - add AP specific event
      wl12xx: AP-mode high level commands
      wl12xx: AP mode - workaround for FW bug on station remove
      wl12xx: AP mode - init sequence
      wl12xx: AP specific RX filter configuration
      wl12xx: Add AP related definitions to HOST-FW interface
      wl12xx: Configure AP on BSS info change
      wl12xx: AP mode config in ieee80211_ops.config
      wl12xx: AP mode - change filter config
      wl12xx: AP mode - add STA add/remove ops
      wl12xx: AP mode - changes in TX path
      wl12xx: AP mode - record TX configuration settings
      wl12xx: AP mode - encryption support
      wl12xx: AP mode - fetch appropriate firmware for AP
      wl12xx: Read MAC address from NVS file on HW startup
      wl12xx: Enable AP-mode
      wl12xx: add missing MODULE_FIRMWARE statment for AP-mode FW
      wl12xx: Add channel 14 to list of supported 2ghz channels

Ben Greear (1):
      mac80211: Add sdata state and flags to debugfs.

Bob Copeland (4):
      ath5k: fix error handling in ath5k_hw_dma_stop
      ath5k: correct endianness of frame duration
      ath5k: use tracing for packet tx/rx dump
      ath5k: remove debug_dump_skb() functions

Bruno Randolf (5):
      ath5k: Use local variable for capabilities
      ath: Add function to check if 4.9GHz channels are allowed
      ath5k: Enable 802.11j 4.9GHz frequencies
      ath9k: Remove unused IEEE80211_WEP_NKID
      ath5k: Fix short and long retry configuration

Chaoming Li (1):
      rtlwifi: Fix firmware upload errors

Dan Carpenter (1):
      wl12xx: use after free in debug code

Eliad Peller (6):
      wl12xx: remove redundant debugfs_remove_recursive() call
      wl12xx: fix some sparse warnings
      wl12xx: don't join upon disassociation
      wl12xx: fix some endianess bugs
      wl12xx: wrong values are returned in gpio_power_write()
      wl12xx: disable auto-arp

Felix Fietkau (8):
      ath9k: clean up the code that wakes the mac80211 queues
      ath9k: remove the virtual wiphy debugfs interface
      ath9k: remove support for virtual wiphys
      ath9k: remove the bf->aphy field
      ath9k: fold struct ath_wiphy into struct ath_softc
      ath9k: fix tx queue index confusion in debugfs code
      ath9k: use split rx buffers to get rid of order-1 skb allocations
      ath9k: fix compile error in non-debug ath_debug_stat_tx() stub

Gertjan van Wingerde (3):
      rt2x00: Fix WPA TKIP Michael MIC failures.
      rt2x00: Copy the MAC address to the WCID entry properly.
      rt2x00: Fix FIXME comments in rt61pci and rt73usb on Michael MIC.

Guy Eilam (1):
      wl12xx: change debug_level module param sysfs permissions

Helmut Schaa (13):
      rt2x00: Refactor beacon code to make use of start- and stop_queue
      rt2x00: Introduce beacon_update_locked that requires caller locking
      rt2x00: Limit beacon updates in bss_info_changed to USB devices
      rt2x00: Make periodic beacon updates for PCI devices atomic
      rt2x00: Introduce tasklets for interrupt handling
      rt2x00: Disable txstatus tasklet by default
      rt2x00: Convert rt2800pci to use tasklets
      rt2x00: Convert rt61pci to use tasklets
      rt2x00: Convert rt2500pci interrupt handling to use tasklets
      rt2x00: Convert rt2400pci interrupt handling to use tasklets
      rt2x00: Remove interrupt thread registration
      rt2x00: Remove STATE_RADIO_IRQ_OFF_ISR and STATE_RADIO_IRQ_ON_ISR
      rt2x00: Update MAINTAINERS

Ivo van Doorn (2):
      rt2x00: Kill all tasklets during device removal
      rt2x00: Move TX/RX work into dedicated workqueue

Johannes Berg (1):
      mac80211: add MCS information to radiotap

Johannes Stezenbach (1):
      rt2x00: trivial: add \n to WARNING message

John W. Linville (3):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Julia Lawall (1):
      net/wireless/nl80211.c: Avoid call to genlmsg_cancel

Juuso Oikarinen (3):
      wl12xx: Cleanup PLT mode when module is removed
      wl12xx: Increase scan channel dwell time for passive scans
      cfg80211: Allow non-zero indexes for device specific pair-wise ciphers

Levi, Shahar (2):
      wl12xx: BA initiator support
      wl12xx: BA receiver support

Luciano Coelho (6):
      MAINTAINERS: update information for the wl12xx driver
      wl12xx: don't modify the global supported band structures
      wl12xx: lock the RCU when accessing sta via ieee80211_find_sta()
      wl12xx: add hw configuration for max supported AMDPU size
      MAINTAINERS: update information for the wl12xx driver
      wl12xx: fix warning due to missing arg in ampdu_action

Mark Einon (1):
      Trivial typo fix in comment

Mathias Krause (1):
      wl12xx: fix use after free

Mohammed Shafi Shajakhan (1):
      ath9k: Fix memory leak due to failed PAPRD frames

RA-Jay Hung (1):
      rt2x00: Correct initial value of US_CYC_CNT register for pcie interface

Rajkumar Manoharan (4):
      ath9k_hw: Fix system hang when resuming from S3/S4
      ath9k: Fix power save usage count imbalance on deinit
      ath9k: use common API to avoid code duplication
      mac80211: disable power save if an infra AP vif exists

Stanislaw Gruszka (10):
      ath9k: fix race conditions when stop device
      ath9k_htc: fix race conditions when stop device
      iwlwifi: do not set tx power when channel is changing
      iwl3945: set STATUS_READY before commit_rxon
      iwlwifi: remove unneeded __packed
      iwlwifi: introduce iwl_advanced_bt_coexist()
      iwlwifi: remove unneeded disable_hw_scan check
      iwlwifi: introduce iwl_bt_statistics
      iwl3945: do not use agn specific IWL_RATE_COUNT
      iwlwifi: correct frequency settings

Sujith Manoharan (3):
      ath9k_hw: Fix opmode initialization
      ath9k_hw: Fix INI fixup
      ath9k_hw: Add RX filters

Vivek Natarajan (5):
      ath9k_hw: Add a function to read sqsum_dvc.
      ath9k: Fix a PLL hang issue observed with AR9485.
      ath9k_hw: DDR_PLL and BB_PLL need correct setting.
      ath9k: Fix a locking related issue.
      ath9k_hw: Update PMU setting to improve ripple issue for AR9485.

 MAINTAINERS                                        |    8 +-
 drivers/bluetooth/ath3k.c                          |   75 +-
 drivers/net/wireless/ath/ath5k/Kconfig             |   11 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |   18 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    4 +-
 drivers/net/wireless/ath/ath5k/base.c              |   23 +-
 drivers/net/wireless/ath/ath5k/caps.c              |   48 +-
 drivers/net/wireless/ath/ath5k/debug.c             |   20 -
 drivers/net/wireless/ath/ath5k/debug.h             |   10 -
 drivers/net/wireless/ath/ath5k/dma.c               |    4 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    9 +
 drivers/net/wireless/ath/ath5k/pcu.c               |    4 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |   46 +-
 drivers/net/wireless/ath/ath5k/reg.h               |   15 +-
 drivers/net/wireless/ath/ath5k/trace.h             |  107 ++
 drivers/net/wireless/ath/ath9k/Makefile            |    1 -
 drivers/net/wireless/ath/ath9k/ahb.c               |   13 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   10 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    3 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   61 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   18 +-
 drivers/net/wireless/ath/ath9k/common.h            |    2 -
 drivers/net/wireless/ath/ath9k/debug.c             |  174 +---
 drivers/net/wireless/ath/ath9k/debug.h             |    5 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    6 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    3 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    3 -
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   21 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    8 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   49 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +
 drivers/net/wireless/ath/ath9k/init.c              |   30 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    2 +
 drivers/net/wireless/ath/ath9k/main.c              |  328 ++-----
 drivers/net/wireless/ath/ath9k/pci.c               |   20 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    3 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  155 ++--
 drivers/net/wireless/ath/ath9k/reg.h               |   17 +
 drivers/net/wireless/ath/ath9k/virtual.c           |  669 ------------
 drivers/net/wireless/ath/ath9k/xmit.c              |  138 ++--
 drivers/net/wireless/ath/regd.c                    |    7 +
 drivers/net/wireless/ath/regd.h                    |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   15 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |    3 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   21 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   11 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-legacy.c          |    5 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |    6 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |    5 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c         |    2 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |  165 ++-
 drivers/net/wireless/rt2x00/rt2500pci.c            |  159 ++-
 drivers/net/wireless/rt2x00/rt2500usb.c            |    4 -
 drivers/net/wireless/rt2x00/rt2800.h               |    4 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |   73 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |    1 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |  192 +++--
 drivers/net/wireless/rt2x00/rt2800usb.c            |    9 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   35 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   69 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    1 +
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   24 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |    7 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   44 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   60 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |    2 -
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    8 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  226 +++--
 drivers/net/wireless/rt2x00/rt73usb.c              |   50 +-
 drivers/net/wireless/rtlwifi/efuse.c               |   40 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   11 +-
 drivers/net/wireless/wl12xx/acx.c                  |  160 +++-
 drivers/net/wireless/wl12xx/acx.h                  |   91 ++-
 drivers/net/wireless/wl12xx/boot.c                 |   35 +-
 drivers/net/wireless/wl12xx/cmd.c                  |  308 ++++++-
 drivers/net/wireless/wl12xx/cmd.h                  |  147 +++-
 drivers/net/wireless/wl12xx/conf.h                 |   76 ++-
 drivers/net/wireless/wl12xx/debugfs.c              |   49 +-
 drivers/net/wireless/wl12xx/event.c                |    7 +-
 drivers/net/wireless/wl12xx/event.h                |    8 +-
 drivers/net/wireless/wl12xx/init.c                 |  387 ++++++--
 drivers/net/wireless/wl12xx/init.h                 |    2 +-
 drivers/net/wireless/wl12xx/main.c                 | 1116 +++++++++++++++-----
 drivers/net/wireless/wl12xx/rx.c                   |   14 +-
 drivers/net/wireless/wl12xx/rx.h                   |   11 +-
 drivers/net/wireless/wl12xx/sdio.c                 |    1 +
 drivers/net/wireless/wl12xx/spi.c                  |    3 +-
 drivers/net/wireless/wl12xx/tx.c                   |  105 ++-
 drivers/net/wireless/wl12xx/tx.h                   |   10 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |   88 ++-
 drivers/net/wireless/wl12xx/wl12xx_80211.h         |   11 +-
 include/linux/ieee80211.h                          |    2 +-
 include/net/bluetooth/hci_core.h                   |    1 +
 include/net/ieee80211_radiotap.h                   |   25 +
 net/bluetooth/hci_conn.c                           |   16 +-
 net/bluetooth/hci_core.c                           |    4 +
 net/bluetooth/hci_event.c                          |    9 +-
 net/bluetooth/l2cap.c                              |   84 +-
 net/bluetooth/rfcomm/core.c                        |    3 +-
 net/mac80211/agg-rx.c                              |   11 +-
 net/mac80211/debugfs_netdev.c                      |   14 +
 net/mac80211/main.c                                |   12 +-
 net/mac80211/mlme.c                                |    8 +
 net/mac80211/rx.c                                  |   17 +
 net/mac80211/tx.c                                  |    3 +
 net/wireless/nl80211.c                             |    6 +-
 net/wireless/util.c                                |   11 +-
 122 files changed, 3801 insertions(+), 2533 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/trace.h
 delete mode 100644 drivers/net/wireless/ath/ath9k/virtual.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2011-02-02.patch.bz2
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
