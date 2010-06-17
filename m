From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-06-17
Date: Thu, 17 Jun 2010 17:02:42 -0400
Message-ID: <20100617210242.GB2368@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Another week, another bunch of patches intende for 2.6.36...
This week's batch includes the usual updates to ath5k, ath9k,
iwlwifi, rt2x00, and other drivers.  Also included are a lot of
cleanup/maintenance for mac80211 from Johannes and some IBSS-related
changes from Teemu, as well as a number of other patches from a
variety of contributors.

Please let me know if there are problems!

John

P.S.  This also includes a pull of the 2.6.35 bits I sent yesterday
in order to resolve some merge conflicts.

---

The following changes since commit 4de57826810fd2cfeb2ab5c7d003ff9116b8f7ee:
  Amit Kumar Salecha (1):
        qlcnic: fix register access

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Bruno Randolf (17):
      ath5k: more debug prints for resets
      ath5k: rename ath5k_txbuf_free() to ath5k_txbuf_free_skb()
      ath5k: fix some comment typos
      ath5k: fix rx descriptor debugging
      ath5k: print more errors when decriptor setup fails
      ath5k: reset more pointers after we free skbs
      ath5k: unify rx descriptor error handling
      ath5k: split descriptor handling and frame receive
      ath5k: move checks and stats into new function
      ath5k: use direct function calls for descriptors when possible
      ath5k: cosmetic changes in ath5k_hw_proc_5212_rx_status()
      ath5k: remove pointless rx error overlay struct
      ath5k: review and add comments for descriptors
      ath5k: update 5210/5211 frame types
      ath5k: take descriptor differences between 5210 and 5211 into account
      ath5k: review RX descriptor functions
      ath5k: report PHY error frames only for chips which need it

Christoph Fritz (1):
      mac80211: fix warn, enum may be used uninitialized

Dor Shaish (1):
      iwlwifi: Fix null pointer referencing in iwl_dbgfs_rx_queue_read.

Emmanuel Grumbach (2):
      iwlwifi: rename rxq->dma_addr
      iwlwifi: rename iwl4965_rx_mpdu_res_start

Felix Fietkau (20):
      ath9k: fix mac80211 queue lookup for waking up queues
      ath9k_htc: use common WMM AC definitions instead of ath9k ones
      ath9k: remove duplicate WMM AC definitions
      ath9k: remove declarations of some nonexistant functions
      ath9k: make ath_get_hal_qnum static
      ath9k: fix extending the rx timestamp with the hardware TSF
      ath9k: fix queue stopping threshold
      ath9k: add a debugfs entry for ignoring CCA on the extension channel in HT40
      ath9k_hw: remove a useless function for setting the mac address
      ath9k_hw: add register definitions related to PA predistortion
      ath9k_hw: add support for parsing PA predistortion related EEPROM fields
      ath9k_hw: add functions for controlling PA predistortion calibration
      ath9k: implement PA predistortion support
      ath9k_hw: remove ATH9K_CAP_CIPHER
      ath9k_hw: remove ATH9K_CAP_TXPOW
      ath9k_hw: remove ATH9K_CAP_TKIP_MIC
      ath9k_hw: remove ATH9K_CAP_TKIP_SPLIT
      ath9k_hw: remove ATH9K_CAP_MCAST_KEYSRCH
      ath9k/ath9k_htc: remove redundand checks for dual-stream tx support
      ath9k_hw: remove ATH9K_CAP_DS

Helmut Schaa (9):
      rt2x00: clarify meaning of txdone flags
      rt2x00: don't use TXDONE_FALLBACK as success indicator
      rt2x00: only set TXDONE_FALLBACK in rt2800pci if the frame was retried
      rt2x00: Fix IEEE80211_TX_CTL_MORE_FRAMES handling
      rt2x00: Add comment about BBP1_TX_POWER
      rt2x00: Fix TX_STA_FIFO handling
      rt2x00: Fix typo in rt2800_config_txpower
      rt2x00: provide mac80211 a suitable max_rates value
      rt2x00: Fix tx status reporting when falling back to the lowest rate

Ivo van Doorn (5):
      rt2x00: Enable fallback rates for rt61pci and rt73usb
      rt2x00: Update author rt2800lib
      rt2x00: Limit TX done looping to number of TX ring entries
      rt2x00: Enable HW crypto by default
      rt2x00: Synchronize WCID initialization with legacy driver

Joerg Albert (1):
      p54pci: add Symbol AP-300 minipci adapters pciid

Johannes Berg (27):
      iwlwifi: trace full RX
      iwlwifi: print warning about disconnected antennas
      cfg80211/mac80211: allow action frame TX/RX in IBSS
      mac80211: simplify station/aggregation code
      mac80211: use common skb queue
      mac80211: use common work struct
      mac80211: use common work function
      mac80211: common work skb freeing
      mac80211: pull mgmt frame rx into rx handler
      mac80211: always process blockack action from workqueue
      mac80211: move blockack stop due to fragmentation
      mac80211: move aggregation callback processing
      mac80211: use RCU for RX aggregation
      mac80211: use RCU for TX aggregation
      mac80211: remove non-irqsafe aggregation callbacks
      mac80211: refcount aggregation queue stop
      mac80211: make TX aggregation start/stop request async
      mac80211: move BA session work
      mac80211: defer RX agg session teardown to work
      mac80211: fix RX aggregation timer
      mac80211: change RX aggregation locking
      mac80211: defer TX agg session teardown to work
      mac80211: change TX aggregation locking
      mac80211: allow drivers to sleep in ampdu_action
      mac80211: update aggregation documentation
      mac80211: fix mgmt frame accounting
      mac80211: bracket driver tracing

John W. Linville (3):
      iwlwifi: cancel scan watchdog in iwl_bg_abort_scan
      zd1211rw: change ZD_REGDOMAIN_JAPAN_* naming
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Jouni Malinen (2):
      mac80211: Protect Deauthentication frame when using MFP
      mac80211: Use a separate CCMP PN receive counter for management frames

Juuso Oikarinen (2):
      mac80211: Fix circular locking dependency in ARP filter handling
      mac80211: Fix ps-qos network latency handling

Kouhei Sutou (1):
      zd1211rw: add 0x49 -> JP regulatory domain map

Leann Ogasawara (1):
      p54usb: Comment out duplicate Medion MD40900 device id

Luis R. Rodriguez (12):
      ath9k_hw: move clock definitions from hw.c to hw.h
      ath9k_hw: fix clock rate calculations for ANI
      ath9k_hw: clear MIB interrupt causes when skipping ANI adjustments
      ath9k_hw: allow for spliting up ANI operations by family
      ath9k_hw: add register definitions for the new ANI
      ath9k_hw: inform ANI calibration when scanning
      ath9k: add new ANI implementation for AR9003
      ath9k_hw: enable ANI for AR9003
      ath9k_hw: reduce delay on programming INI on AR9003
      ath9k_hw: update 5 GHz tx gain tables for femless and high power PA
      ath9k: enable AR9003 PCI IDs
      ath9k_hw: avoid setting cwmin/cwmax to 0 for IBSS for AR9003

Prarit Bhargava (1):
      libertas_tf: Fix warning in lbtf_rx for stats struct

Reinette Chatre (1):
      iwlwifi: serialize station management actions

Shanyu Zhao (1):
      iwlagn: verify flow id in compressed BA packet

Sujith (1):
      ath9k_htc: Fix ampdu_action callback

Teemu Paasikivi (3):
      mac80211: Set basic rates while joining ibss network
      mac80211: Set changed basic rates flag
      mac80211: remove BSS from cfg80211 list when leaving IBSS

Tim Gardner (1):
      hostap: Protect against initialization interrupt

Wey-Yi Guy (1):
      iwlwifi: cancel run time calibration work when going down

Zhu Yi (1):
      wireless: orphan ipw2x00 drivers

ubuntu-A+nqLdfjWwLR7s880joybQ@public.gmane.org (1):
      ipw2200: Enable LED by default

 Documentation/networking/README.ipw2200            |    2 +-
 MAINTAINERS                                        |   10 +-
 drivers/net/b44.c                                  |  144 ++--
 drivers/net/wireless/ath/ath5k/Makefile            |    1 +
 drivers/net/wireless/ath/ath5k/ani.c               |   20 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   19 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    2 -
 drivers/net/wireless/ath/ath5k/base.c              |  373 +++++----
 drivers/net/wireless/ath/ath5k/caps.c              |    7 -
 drivers/net/wireless/ath/ath5k/debug.c             |   79 ++-
 drivers/net/wireless/ath/ath5k/debug.h             |    9 +-
 drivers/net/wireless/ath/ath5k/desc.c              |  152 ++--
 drivers/net/wireless/ath/ath5k/desc.h              |  310 ++++----
 drivers/net/wireless/ath/ath5k/dma.c               |   13 -
 drivers/net/wireless/ath/ath5k/eeprom.c            |    3 +-
 drivers/net/wireless/ath/ath5k/gpio.c              |    7 -
 drivers/net/wireless/ath/ath5k/pcu.c               |   24 -
 drivers/net/wireless/ath/ath5k/phy.c               |   82 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    9 -
 drivers/net/wireless/ath/ath5k/reset.c             |   64 +--
 drivers/net/wireless/ath/ath5k/sysfs.c             |  116 +++
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ani.c               |  743 +++++++++++++++++-
 drivers/net/wireless/ath/ath9k/ani.h               |   78 ++-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |  372 +++++++++-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  118 ++-
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |    6 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    7 +
 .../{ar9003_initvals.h => ar9003_2p0_initvals.h}   |  254 +++---
 .../{ar9003_initvals.h => ar9003_2p2_initvals.h}   |  433 +++++-----
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   13 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  165 ++++-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   13 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.h        |    5 +
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |  714 +++++++++++++++++
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  513 ++++++++++---
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |  298 ++++++--
 drivers/net/wireless/ath/ath9k/ath9k.h             |   85 ++-
 drivers/net/wireless/ath/ath9k/beacon.c            |    3 +-
 drivers/net/wireless/ath/ath9k/common.c            |  314 +-------
 drivers/net/wireless/ath/ath9k/common.h            |   77 +--
 drivers/net/wireless/ath/ath9k/debug.c             |   68 ++-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |   29 +
 drivers/net/wireless/ath/ath9k/eeprom.h            |    5 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |  618 ++++++++--------
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    1 +
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   58 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    2 +
 drivers/net/wireless/ath/ath9k/htc.h               |   37 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   23 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  168 +++-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  491 +++++++------
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   86 ++-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    3 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |   16 +
 drivers/net/wireless/ath/ath9k/hw.c                |  185 ++----
 drivers/net/wireless/ath/ath9k/hw.h                |   91 ++-
 drivers/net/wireless/ath/ath9k/init.c              |   54 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   14 +-
 drivers/net/wireless/ath/ath9k/mac.h               |   13 +-
 drivers/net/wireless/ath/ath9k/main.c              |  411 ++++------
 drivers/net/wireless/ath/ath9k/pci.c               |    1 +
 drivers/net/wireless/ath/ath9k/rc.c                |  184 +++--
 drivers/net/wireless/ath/ath9k/recv.c              |  296 +++++++-
 drivers/net/wireless/ath/ath9k/reg.h               |   62 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    3 -
 drivers/net/wireless/ath/ath9k/xmit.c              |  144 ++--
 drivers/net/wireless/b43/dma.c                     |   69 +-
 drivers/net/wireless/b43legacy/dma.c               |   49 +-
 drivers/net/wireless/hostap/hostap_cs.c            |   15 +-
 drivers/net/wireless/hostap/hostap_hw.c            |   13 +
 drivers/net/wireless/hostap/hostap_wlan.h          |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |   18 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    7 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    6 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945-debugfs.c    |   28 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |  203 +-----
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   83 ++-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   58 ++-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  345 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     |   27 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |   26 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  230 ++----
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   82 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |  123 +++
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  327 +++++++--
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   34 +
 drivers/net/wireless/iwlwifi/iwl-calib.c           |    7 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  266 +++----
 drivers/net/wireless/iwlwifi/iwl-core.h            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   88 +--
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   80 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   27 +
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   10 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   41 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   76 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |   29 +
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   33 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  145 +---
 drivers/net/wireless/iwmc3200wifi/hal.c            |    2 +-
 drivers/net/wireless/iwmc3200wifi/rx.c             |    4 +-
 drivers/net/wireless/libertas/cmd.c                |   37 +-
 drivers/net/wireless/libertas/cmdresp.c            |   30 +-
 drivers/net/wireless/libertas/decl.h               |    2 +-
 drivers/net/wireless/libertas/dev.h                |    6 +
 drivers/net/wireless/libertas/ethtool.c            |   24 +-
 drivers/net/wireless/libertas/if_sdio.c            |   58 ++
 drivers/net/wireless/libertas/if_usb.c             |   12 +-
 drivers/net/wireless/libertas/main.c               |   79 ++-
 drivers/net/wireless/libertas/scan.c               |    2 +-
 drivers/net/wireless/libertas_tf/if_usb.c          |    5 +-
 drivers/net/wireless/libertas_tf/main.c            |    2 +-
 drivers/net/wireless/mwl8k.c                       |   12 +-
 drivers/net/wireless/orinoco/hermes_dld.c          |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    4 +-
 drivers/net/wireless/orinoco/wext.c                |    4 +-
 drivers/net/wireless/p54/eeprom.c                  |    4 +-
 drivers/net/wireless/p54/p54pci.c                  |    2 +
 drivers/net/wireless/p54/p54spi.c                  |    5 +-
 drivers/net/wireless/p54/p54usb.c                  |    6 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |   11 +-
 drivers/net/wireless/rndis_wlan.c                  |   36 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   17 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   17 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   31 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   57 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  210 +++---
 drivers/net/wireless/rt2x00/rt2800lib.h            |   13 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |  136 ++--
 drivers/net/wireless/rt2x00/rt2800pci.h            |   19 -
 drivers/net/wireless/rt2x00/rt2800usb.c            |  106 ++--
 drivers/net/wireless/rt2x00/rt2800usb.h            |   37 -
 drivers/net/wireless/rt2x00/rt2x00.h               |   42 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   12 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   23 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h           |    7 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c             |   47 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   26 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |   51 ++-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    8 +
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   43 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |    9 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   33 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   19 -
 drivers/net/wireless/rt2x00/rt61pci.c              |   59 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   51 +-
 drivers/net/wireless/wl12xx/Kconfig                |    4 +-
 drivers/net/wireless/wl12xx/wl1251_main.c          |    4 +-
 drivers/net/wireless/wl12xx/wl1251_sdio.c          |   40 +-
 drivers/net/wireless/wl12xx/wl1271.h               |   31 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |   41 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |   28 +-
 drivers/net/wireless/wl12xx/wl1271_event.c         |   10 +-
 drivers/net/wireless/wl12xx/wl1271_ini.h           |  123 +++
 drivers/net/wireless/wl12xx/wl1271_main.c          |   95 ++-
 drivers/net/wireless/wl12xx/wl1271_sdio.c          |    2 +-
 drivers/net/wireless/wl12xx/wl1271_testmode.c      |   11 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c            |   36 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h            |    1 +
 drivers/net/wireless/zd1211rw/zd_mac.c             |    5 +-
 drivers/net/wireless/zd1211rw/zd_mac.h             |    3 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |    2 +-
 drivers/ssb/driver_chipcommon.c                    |   25 +
 drivers/ssb/driver_chipcommon_pmu.c                |   17 +-
 drivers/ssb/main.c                                 |   76 +--
 drivers/ssb/pci.c                                  |   15 +-
 include/linux/nl80211.h                            |    2 +-
 include/linux/ssb/ssb.h                            |  159 +----
 include/net/cfg80211.h                             |  122 +++-
 include/net/mac80211.h                             |   81 +--
 net/mac80211/Kconfig                               |    7 +
 net/mac80211/Makefile                              |    4 +
 net/mac80211/agg-rx.c                              |  123 ++--
 net/mac80211/agg-tx.c                              |  554 ++++++++------
 net/mac80211/cfg.c                                 |   75 ++-
 net/mac80211/debugfs.c                             |  154 ++---
 net/mac80211/debugfs_key.c                         |    2 +-
 net/mac80211/debugfs_sta.c                         |   65 +-
 net/mac80211/driver-ops.h                          |   95 ++-
 net/mac80211/driver-trace.h                        |  188 +++---
 net/mac80211/ht.c                                  |   50 +-
 net/mac80211/ibss.c                                |  109 ++--
 net/mac80211/ieee80211_i.h                         |   71 +-
 net/mac80211/iface.c                               |  188 ++++-
 net/mac80211/key.c                                 |  290 ++------
 net/mac80211/key.h                                 |   30 +-
 net/mac80211/main.c                                |  116 +++-
 net/mac80211/mesh.c                                |   73 +--
 net/mac80211/mesh.h                                |    2 -
 net/mac80211/mesh_hwmp.c                           |    4 +-
 net/mac80211/mesh_pathtbl.c                        |    4 +-
 net/mac80211/mlme.c                                |  200 +----
 net/mac80211/pm.c                                  |   18 +-
 net/mac80211/rate.h                                |   13 +
 net/mac80211/rc80211_minstrel_ht.c                 |  824 ++++++++++++++++++++
 net/mac80211/rc80211_minstrel_ht.h                 |  128 +++
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |  120 +++
 net/mac80211/rx.c                                  |  175 +++--
 net/mac80211/sta_info.c                            |   22 +-
 net/mac80211/sta_info.h                            |   97 ++-
 net/mac80211/status.c                              |    2 +-
 net/mac80211/tx.c                                  |   93 ++-
 net/mac80211/util.c                                |   31 +-
 net/mac80211/work.c                                |    4 +-
 net/mac80211/wpa.c                                 |    8 +-
 net/wireless/chan.c                                |    5 +-
 net/wireless/core.h                                |    1 +
 net/wireless/mlme.c                                |    8 +-
 net/wireless/nl80211.c                             |   58 ++-
 218 files changed, 11254 insertions(+), 6435 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/sysfs.c
 copy drivers/net/wireless/ath/ath9k/{ar9003_initvals.h => ar9003_2p0_initvals.h} (87%)
 rename drivers/net/wireless/ath/ath9k/{ar9003_initvals.h => ar9003_2p2_initvals.h} (78%)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_paprd.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_ini.h
 create mode 100644 net/mac80211/rc80211_minstrel_ht.c
 create mode 100644 net/mac80211/rc80211_minstrel_ht.h
 create mode 100644 net/mac80211/rc80211_minstrel_ht_debugfs.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-06-17.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
