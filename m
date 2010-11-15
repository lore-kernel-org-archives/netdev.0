From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-11-15
Date: Mon, 15 Nov 2010 16:25:21 -0500
Message-ID: <20101115212520.GD2297@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the traditional first huge pull request intended for the 2.6.38=
!

Included are the usual batch of updates to various wireless drivers.
=46or good measure, Luis also gives us a few wireless regulatory contro=
l
patches as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1f4f067f99cbb2af7af7a67bd025a9fb58b5=
156c:

  enic: Fix build warnings (2010-11-15 11:13:19 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Andreas Herrmann (1):
      bitops: Provide generic sign_extend32 function

Ben Greear (1):
      ath5k: Print stats as unsigned ints.

Blaise Gassend (1):
      mac80211_hwsim: Incorporate txpower into rssi

Bruno Randolf (2):
      ath5k: Optimize descriptor alignment
      ath5k: Add channel time to survey data

Christian Lamparter (7):
      carl9170: import hw/fw header updates
      carl9170: initialize HW aMPDU parameters properly
      carl9170: fix spurious restart due to high latency
      carl9170: stop stale uplink BA sessions
      carl9170: configurable beacon rates
      carl9170: tx path review
      carl9170: use generic sign_extend32

Eliad Peller (5):
      mac80211: refactor debugfs function generation code
      wl1271: set wl->vif only if add_interface succeeded.
      wl1271: refactor debugfs function generation code
      wl1271: handle HW watchdog interrupt
      wl1271: add recover testmode command

=46elix Fietkau (13):
      ath9k_hw: optimize interrupt mask changes
      ath9k_hw: small optimization in ar9002_hw_get_isr
      ath9k_hw: optimize tx status descriptor processing
      ath9k: optimize/fix ANI RSSI processing
      ath9k: remove a redundant call to ath9k_hw_gettsf32
      ath9k_hw: make ath9k_hw_gettsf32 static
      ath9k_hw: optimize all descriptor access functions
      ath9k_hw: initialize regulatory->max_power_level in set_txpower f=
or AR9003
      ath9k_hw: extend ath9k_hw_set_txpowerlimit to test channel txpowe=
r
      ath9k: initialize per-channel tx power limits instead of hardcodi=
ng them
      ath9k_hw: fix potential spurious tx error bit interpretation
      mac80211: minstrel_ht - reduce the overhead of rate sampling
      ath9k: rework tx queue selection and fix queue stopping/waking

Gery Kahn (1):
      wl1271: ref_clock cosmetic changes

Grazvydas Ignotas (3):
      wl1251: add power callback to wl1251_if_operations
      wl1251: add runtime PM support for SDIO
      wl1251: use wl12xx_platform_data to pass data

Hauke Mehrtens (1):
      carl9170: fix typos

Helmut Schaa (6):
      rt2x00: Add TXOP_CTRL_CFG register definition
      rt2x00: Sync Tx and RX ring sizes with legacy drivers
      rt2x00: Wait up to one second on rt2800 for WPDMA to be ready
      rt2x00: Reduce tx descriptor size
      rt2x00: Optimize rt2x00debug_dump_frame when frame dumping is not=
 active
      rt2x00: Fix hw crypto in AP mode for some devices

Herton Ronaldo Krzesinski (9):
      rtl8187: remove redundant initialization of ARFR
      rtl8187: remove setting of beacon/atim registers from initializat=
ion
      rtl8187: fix wrong register initialization in 8187B
      rtl8187: avoid redundant write to register FF72 (RFSW_CTRL)
      rtl8187: move pll reset at start out of ANAPARAM write
      rtl8187: don't set RTL818X_CONFIG3_GNT_SELECT flag on 8187B
      rtl8187: consolidate anaparam on/off write sequences
      rtl8187: remove uneeded setting of anaparam write
      rtl8187: restore anaparam registers after reset with 8187B

Ido Yariv (4):
      wl1271: TX aggregation optimization
      wl1271: Fix TX starvation
      wl1271: Allocate TX descriptors more efficiently
      wl1271: Fix TX queue low watermark handling

Ivo van Doorn (9):
      rt2x00: Rename rt2x00queue_timeout
      rt2x00: Remove failsave from rt2x00usb_watchdog_tx_dma
      rt2x00: Implement flush callback
      rt2x00: Fix MCU_SLEEP arguments
      rt2x00: Fix crash on USB unplug
      rt2x00: Rename queue->lock to queue->index_lock
      rt2x00: Fix rt2x00queue_kick_tx_queue arguments
      rt2x00: Remove rt2x00lib_toggle_rx
      rt2x00: Add watchdog functions for HW queue

Jesper Juhl (1):
      mac80211: Remove redundant checks for NULL before calls to crypto=
_free_cipher()

Johannes Berg (10):
      iwlwifi: make mac80211 ops a device config
      iwlagn: don't resend RXON timing
      iwlagn: new RXON processing for modern devices
      iwlwifi: fix IBSS beaconing
      iwlwifi: implement switching iftype while up
      iwlagn: fix non-5000+ build
      iwlagn: fix needed chains calculation
      iwlagn: fix RXON issues
      iwlagn: re-enable calibration
      iwlagn: fix RXON HT

John W. Linville (3):
      b43: remove extraneous code in free_ringmemory
      rt2x00pci: do not use GFP_DMA
      iwlwifi: Convert to new PCI PM framework

Juuso Oikarinen (3):
      wl1271: Fix RX path stall
      wl1271: Fix scan failure detection
      wl1271: Check interface state in op_* functions

Lalith Suresh (1):
      rt2x00: Fix comments in rt73usb.h and rt61pci.h

Larry Finger (1):
      ssb: Clear RETRY_TIMEOUT in PCI Configuration for normal devices

Luciano Coelho (1):
      wl1271: exit ELP mode when setting enabled rates in tx

Luis R. Rodriguez (16):
      ath9k: fix sparse complaint on aphy for debugfs
      ath: make ath_hw_keysetmac() static
      ath: make ath_hw_set_keycache_entry() static
      ath5k: make ath5k_update_bssid_mask_and_opmode() static
      cfg80211: pass the reg hint initiator to helpers
      cfg80211: fix allowing country IEs for WIPHY_FLAG_STRICT_REGULATO=
RY
      cfg80211: fix disabling channels based on hints
      cfg80211: add debug prints for when we ignore regulatory hints
      cfg80211: add debug print when disabling a channel on a custom re=
gd
      cfg80211: add debug print when processing a channel
      cfg80211: prefix REG_DBG_PRINT() with cfg80211
      ath: add a ATH_DBG_WARN()
      ath9k: add a debug warning when we cannot stop RX
      ath9k: simplify hw reset locking
      ath9k: move the PCU lock to the sc structure
      ath9k: content DMA start / stop through the PCU lock

Mark Einon (14):
      rt2x00: checkpatch.pl error fixes for rt2400pci.h
      rt2x00: checkpatch.pl error fixes for rt2500pci.h
      rt2x00: checkpatch.pl error fixes for rt2500usb.c
      rt2x00: checkpatch.pl error fixes for rt2800.h
      rt2x00: checkpatch.pl error fixes for rt2800lib.c
      rt2x00: checkpatch.pl error fixes for rt2800pci.h
      rt2x00: checkpatch.pl error fixes for rt2800usb.c
      rt2x00: checkpatch.pl error fixes for rt2800usb.h
      rt2x00: checkpatch.pl error fixes for rt2x00config.c
      rt2x00: checkpatch.pl error fixes for rt2x00dev.c
      rt2x00: checkpatch.pl error fixes for rt2x00lib.h
      rt2x00: checkpatch.pl error fixes for rt2x00link.c
      rt2x00: checkpatch.pl error fixes for rt2x00queue.c
      rt2x00: checkpatch.pl error fixes for rt73usb.c

Mohammed Shafi Shajakhan (2):
      ath9k: Remove the median function in rate control
      ath9k: Properly assign boolean types

Nicolas Kaiser (1):
      wireless/wl1271: remove redundant if-statement v2

Nishant Sarmukadam (1):
      mwl8k: force AP mode to use non-AMPDU frames

Rafael J. Wysocki (1):
      ath9k: Convert to new PCI PM framework

Rafa=C5=82 Mi=C5=82ecki (8):
      b43: N-PHY: define channel table struct for rev3+ devices
      b43: N-PHY: define registers names for 2056 radio
      b43: N-PHY: define registers names for 2056 radio
      b43: N-PHY: fix 2055 radio init
      b43: define known SPROM boardflags2 bits
      b43: N-PHY: determine usage of radio regulatory workaround correc=
tly
      b43: N-PHY: improve 2055 radio initialization
      b43legacy: rfkill: use status register based on core revision (no=
t PHY's)

Rajkumar Manoharan (1):
      ath9k_htc: Handle monitor mode properly for HTC devices

Shahar Levi (3):
      wl1271: 11n Support, Add Definitions
      wl1271: 11n Support, ACX Commands
      wl1271: 11n Support, functionality and configuration ability

Shanyu Zhao (2):
      iwlwifi: seperate disconnected antenna function
      iwlwifi: disable disconnected antenna for advanced bt coex

Stanislaw Gruszka (7):
      iwlwifi: warn when send tx power settings during scan
      iwlwifi: send tx_power_cmd synchronously
      iwlwifi: fix set_tx_power vs scan
      iwlwifi: avoid commit rxon during scan in iwlagn_configure_filter
      iwlwifi: avoid commit rxon during scan in iwlagn_bt_traffic_chang=
e_work
      iwlwifi: defer update power mode while scan
      iwlwifi: avoid commit rxon during scan in iwl_set_no_assoc

Stephen Hemminger (1):
      rfkill: remove dead code

Teemu Paasikivi (1):
      wl1271: Fix warning about unsupported RX rate

Thadeu Lima de Souza Cascardo (1):
      rtl8187b: do not do per packet TX AGC

Wey-Yi Guy (11):
      iwlagn: turn dynamic smps on while BT is on
      iwlwifi: add new devices to Kconfig
      iwlagn: use 6000g2b uCode for 130 series devices
      iwlagn: update PCI ID for 6000g2b series devices
      iwlagn: update PCI ID for 6000g2a series devices
      iwlagn: update PCI ID for 100 series devices
      iwlwifi: Legacy isr only used by legacy devices
      iwlwifi: put all the isr related function under ops
      iwlwifi: legacy tx_cmd_protection function
      iwlwifi: resending QoS command when HT changes
      iwlagn: enable shadow register

Winkler, Tomas (1):
      iwlwlifi: update rx write pointer w/o request mac access in the C=
AM mode

maximilian attems (2):
      zd1211rw: add 2 missing usb id's
      zd1201: Add missing id

 arch/arm/mach-omap2/board-omap3pandora.c       |   32 +-
 drivers/net/wireless/ath/ath5k/base.c          |   24 +-
 drivers/net/wireless/ath/ath5k/debug.c         |   30 +-
 drivers/net/wireless/ath/ath5k/desc.h          |   18 +-
 drivers/net/wireless/ath/ath5k/phy.c           |    8 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c    |   14 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c    |  123 ++--
 drivers/net/wireless/ath/ath9k/ar9002_phy.c    |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   20 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c    |   69 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.h    |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |   14 +-
 drivers/net/wireless/ath/ath9k/ath9k.h         |   14 +-
 drivers/net/wireless/ath/ath9k/beacon.c        |   12 +-
 drivers/net/wireless/ath/ath9k/common.c        |   15 +-
 drivers/net/wireless/ath/ath9k/common.h        |   14 +-
 drivers/net/wireless/ath/ath9k/debug.c         |   48 +-
 drivers/net/wireless/ath/ath9k/debug.h         |    5 +-
 drivers/net/wireless/ath/ath9k/eeprom.h        |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c     |    9 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c   |   27 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |   62 +-
 drivers/net/wireless/ath/ath9k/gpio.c          |   10 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |   70 +--
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c  |    9 +-
 drivers/net/wireless/ath/ath9k/hw.c            |    9 +-
 drivers/net/wireless/ath/ath9k/hw.h            |   16 +-
 drivers/net/wireless/ath/ath9k/init.c          |   88 +-
 drivers/net/wireless/ath/ath9k/mac.c           |   86 ++-
 drivers/net/wireless/ath/ath9k/mac.h           |   13 +-
 drivers/net/wireless/ath/ath9k/main.c          |  167 ++---
 drivers/net/wireless/ath/ath9k/pci.c           |   40 +-
 drivers/net/wireless/ath/ath9k/rc.c            |   31 +-
 drivers/net/wireless/ath/ath9k/recv.c          |   42 +-
 drivers/net/wireless/ath/ath9k/virtual.c       |    3 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |  102 +--
 drivers/net/wireless/ath/carl9170/carl9170.h   |    5 +-
 drivers/net/wireless/ath/carl9170/fwcmd.h      |   13 +-
 drivers/net/wireless/ath/carl9170/hw.h         |    7 +-
 drivers/net/wireless/ath/carl9170/mac.c        |   56 +-
 drivers/net/wireless/ath/carl9170/main.c       |   19 +-
 drivers/net/wireless/ath/carl9170/phy.c        |   17 +-
 drivers/net/wireless/ath/carl9170/phy.h        |   24 +-
 drivers/net/wireless/ath/carl9170/tx.c         |   80 ++-
 drivers/net/wireless/ath/carl9170/usb.c        |    2 +-
 drivers/net/wireless/ath/carl9170/version.h    |    6 +-
 drivers/net/wireless/ath/debug.h               |    2 +
 drivers/net/wireless/ath/key.c                 |    9 +-
 drivers/net/wireless/b43/b43.h                 |   13 +
 drivers/net/wireless/b43/dma.c                 |    5 -
 drivers/net/wireless/b43/phy_n.c               |   14 +-
 drivers/net/wireless/b43/radio_2055.c          |    8 +-
 drivers/net/wireless/b43/radio_2056.c          |   51 ++
 drivers/net/wireless/b43/radio_2056.h          | 1081 ++++++++++++++++=
+++++++-
 drivers/net/wireless/b43legacy/rfkill.c        |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig           |    3 +
 drivers/net/wireless/iwlwifi/Makefile          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c        |   13 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c        |   22 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c        |  352 +++++++-
 drivers/net/wireless/iwlwifi/iwl-5000.c        |   26 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   46 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c   |  230 +++---
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |   53 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c    |  619 ++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c     |   32 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |  493 ++---------
 drivers/net/wireless/iwlwifi/iwl-agn.h         |   41 +-
 drivers/net/wireless/iwlwifi/iwl-core.c        |  841 ++++------------=
---
 drivers/net/wireless/iwlwifi/iwl-core.h        |   70 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h         |    2 +
 drivers/net/wireless/iwlwifi/iwl-dev.h         |    3 +
 drivers/net/wireless/iwlwifi/iwl-led.c         |    2 +
 drivers/net/wireless/iwlwifi/iwl-legacy.c      |  662 +++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-legacy.h      |   79 ++
 drivers/net/wireless/iwlwifi/iwl-power.c       |   95 ++-
 drivers/net/wireless/iwlwifi/iwl-power.h       |    3 +
 drivers/net/wireless/iwlwifi/iwl-rx.c          |   47 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c        |   11 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c          |   49 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |   49 +-
 drivers/net/wireless/mac80211_hwsim.c          |    5 +-
 drivers/net/wireless/mwl8k.c                   |    7 +-
 drivers/net/wireless/rt2x00/rt2400pci.c        |   14 +-
 drivers/net/wireless/rt2x00/rt2400pci.h        |    6 +-
 drivers/net/wireless/rt2x00/rt2500pci.c        |   20 +-
 drivers/net/wireless/rt2x00/rt2500pci.h        |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c        |   22 +-
 drivers/net/wireless/rt2x00/rt2800.h           |   61 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c        |   43 +-
 drivers/net/wireless/rt2x00/rt2800pci.c        |   16 +-
 drivers/net/wireless/rt2x00/rt2800pci.h        |   12 +-
 drivers/net/wireless/rt2x00/rt2800usb.c        |   66 ++-
 drivers/net/wireless/rt2x00/rt2800usb.h        |    4 +-
 drivers/net/wireless/rt2x00/rt2x00.h           |    1 +
 drivers/net/wireless/rt2x00/rt2x00config.c     |    8 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c      |   10 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c        |   37 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h        |    3 +-
 drivers/net/wireless/rt2x00/rt2x00link.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c        |   52 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c        |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c      |   39 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h      |   33 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h        |    2 -
 drivers/net/wireless/rt2x00/rt2x00usb.c        |   25 +-
 drivers/net/wireless/rt2x00/rt61pci.c          |   28 +-
 drivers/net/wireless/rt2x00/rt61pci.h          |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c          |   22 +-
 drivers/net/wireless/rt2x00/rt73usb.h          |    2 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |  140 ++--
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |   22 -
 drivers/net/wireless/wl1251/main.c             |   15 +-
 drivers/net/wireless/wl1251/sdio.c             |  101 ++-
 drivers/net/wireless/wl1251/spi.c              |    9 +
 drivers/net/wireless/wl1251/wl1251.h           |    1 +
 drivers/net/wireless/wl12xx/Kconfig            |   12 +-
 drivers/net/wireless/wl12xx/wl1271.h           |   13 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c       |   83 ++
 drivers/net/wireless/wl12xx/wl1271_acx.h       |   89 ++-
 drivers/net/wireless/wl12xx/wl1271_boot.c      |   10 +-
 drivers/net/wireless/wl12xx/wl1271_debugfs.c   |  215 +++---
 drivers/net/wireless/wl12xx/wl1271_event.c     |    2 -
 drivers/net/wireless/wl12xx/wl1271_main.c      |  220 ++++-
 drivers/net/wireless/wl12xx/wl1271_rx.c        |   28 +-
 drivers/net/wireless/wl12xx/wl1271_rx.h        |    2 +-
 drivers/net/wireless/wl12xx/wl1271_scan.c      |    5 +-
 drivers/net/wireless/wl12xx/wl1271_testmode.c  |   12 +
 drivers/net/wireless/wl12xx/wl1271_tx.c        |  132 ++-
 drivers/net/wireless/wl12xx/wl1271_tx.h        |    3 +-
 drivers/net/wireless/zd1201.c                  |    1 +
 drivers/net/wireless/zd1211rw/zd_usb.c         |    2 +
 drivers/ssb/pcihost_wrapper.c                  |    7 +
 include/linux/bitops.h                         |   11 +
 include/linux/nl80211.h                        |    6 +-
 include/linux/rfkill.h                         |   31 -
 include/linux/wl12xx.h                         |    8 +
 include/net/cfg80211.h                         |   15 +-
 net/mac80211/aes_ccm.c                         |    3 +-
 net/mac80211/aes_cmac.c                        |    3 +-
 net/mac80211/debugfs.c                         |   60 +-
 net/mac80211/debugfs.h                         |    2 +
 net/mac80211/debugfs_key.c                     |   19 +-
 net/mac80211/debugfs_sta.c                     |   26 +-
 net/mac80211/rc80211_minstrel_ht.c             |   16 +-
 net/rfkill/core.c                              |   14 -
 net/wireless/reg.c                             |  134 +++-
 148 files changed, 5604 insertions(+), 2949 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-legacy.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-legacy.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-11-15.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
