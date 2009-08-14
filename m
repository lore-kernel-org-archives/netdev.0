From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-08-14
Date: Fri, 14 Aug 2009 10:13:15 -0400
Message-ID: <20090814141315.GI2650@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55199 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781AbZHNOPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 10:15:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Yet another round of updates intended for 2.6.32...

-- sdio support fo wl1251
-- other wl1251 fixes
-- new driver for wl1271
-- some orinoco fixes
-- some work on LP-PHY support for b43 (finally...hooray!)
-- add new FIF_PSPOLL filter flag
-- mesh mode fixes
-- ath9k, ath5k, mac80211 updates, etc...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit c458bc50e31631f7e9333ea6f1832fc54d4e=
2c1e:
  Eilon Greenstein (1):
        bnx2x: update version to 1.52.1

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Andrey Yurovsky (1):
      mac80211: Use correct sign for mesh active path refresh.

Bob Copeland (8):
      wl1251: separate bus i/o code into io.c
      wl1251: use wiphy_dev instead of wl->spi->dev
      wl1251: introduce wl1251_if_operations struct
      wl1251: make wl1251_set_partition bus agnostic
      wl1251: move module probe methods into spi.c
      wl1251: split spi interface into separate module
      wl1251: add sdio support
      wl1251: make irq handling interface specific

Christian Lamparter (2):
      p54: Write outside array bounds
      p54: implement rfkill

Daniel Mack (1):
      libertas: name the network device wlan%d

David Kilroy (6):
      orinoco: prefer_port3 can be a single bit
      orinoco: use local types for auth alg and sequence length
      orinoco: pass orinoco_set_tkip_key the sequence lengths
      orinoco: move disassociation to hw.c
      orinoco: add function to retrieve current bssid
      orinoco: consolidate storage of WEP and TKIP keys

David Woo (2):
      mac80211: Mark a destination sequence number as valid when a PREQ=
 is received.
      mac80211: Fix invalid length passed to IE parser for PLINK CONFIR=
M frames

G=E1bor Stefanik (12):
      b43: Add LP 2063 radio init
      b43: Typo fixes & minor cleanup
      b43: Fix fallout from the IEEE80211_IF_TYPE to NL80211_IFTYPE cha=
nge.
      b43: LP-PHY: Implement STX synchronization
      b43: Implement LP-PHY baseband table initialization
      b43: Update LP-PHY rev2+ baseband init to match the specs
      ssb: Implement the remaining rev.8 SPROM vars needed for LP-PHY
      b43: Fix a typo in the sync_stx routine
      b43: LP-PHY: Implement reading band SPROM
      b43: Implement RC calibration for rev.2+ LP PHYs
      b43: LP-PHY: Refactor TX gain table I/O
      b43: Implement RC calibration for rev.0/1 LP-PHYs

Igor Perminov (3):
      rt2x00: Fix for race condition while update beacon
      rt2x00: FIF_PSPOLL filter flag support
      rt2x00: Fix beacon de-synchronization while update beacon

Ivo van Doorn (3):
      rt2x00: Remove usage of deprecated radio_enabled & IEEE80211_CONF=
_CHANGE_RADIO_ENABLED
      rt2x00: Use IEEE80211_TX_CTL_MORE_FRAMES flag
      rt2x00: Align ieee80211 header to 4-byte boundary for PCI devices

Javier Cardona (7):
      mac80211: Improve dequeing from mpath frame queue.
      mac80211: Use 3-address format for mesh broadcast frames.
      mac80211: Update the station failed frames average when minstrel =
is used.
      mac80211: Early detection of broken mesh paths when using minstre=
l.
      mac80211: Assign a default mesh beaconing interval.
      mac80211: Move mpath and mpp growth to mesh workqueue.
      mac80211: Fix unresolved mesh frames queued without valid control=
=2Evif

Joe Perches (1):
      MAINTAINERS: NETWORKING [WIRELESS] additional patterns

Joerg Albert (1):
      ath5k: fix missing output in monitor mode after ifconfig up

Johannes Berg (19):
      mac80211: stay authenticated after disassoc
      cfg80211: fix nl80211 disconnected events
      cfg80211: fix SME association after disassociation
      cfg80211: validate channel settings across interfaces
      cfg80211: use reassociation when possible
      nl80211: add generation number to all dumps
      mac80211: explain TX retry and status
      mac80211: document TX powersave filter requirements
      mac80211: allow DMA optimisation
      cfg80211: fix alignment problem in scan request
      iwlwifi: refactor some thermal throttle code
      iwlwifi: automatically adjust sleep level
      cfg80211: fix locking for SIWFREQ
      cfg80211: add missing device list locking
      mac80211: take statistics before encryption
      mac80211: sequence number micro-optimisation
      mac80211: small tx code cleanup
      cfg80211: check for and abort dangling scan requests
      cfg80211: allow driver to override PS default

Julia Lawall (1):
      drivers/net/wireless/ath/ath5k: Change constant name

Jussi Kivilinna (1):
      usbnet: add rx queue pausing

Kalle Valo (18):
      wl1251: remove fixed address support from spi commands
      wl1251: remove wl1251_ops
      wl1251: reorder wl1251_cmd_join() arguments
      wl1251: use beacon interval and dtim period provided by mac80211
      wl1251: remove wait parameter from wl1251_cmd_join()
      wl1251: initialise default channel to zero
      wl1251: add channel to wl1251_cmd_join() parameters
      wl1251: create wl1251_join()
      wl1251: fix channel setting in wl1251_op_config()
      wl1251: move wl1251_acx_wake_up_conditions() to wl1251_ps_set_mod=
e()
      wl1251: use workqueue provided by mac80211
      wl1251: rename reg.h to wl1251_reg.h
      wl1251: remove Luciano as maintainer
      wl1251: add hw scan completed debug message
      wl1251: hack to disable filters for fixing association
      iwl3945: fix compilation error in iwl3945_pass_packet_to_mac80211=
()
      wl1251: remove wl1251_ops.c
      wl1251: remove unused definitions from wl1251_reg.h

Lars Ericsson (2):
      rt2x00: Fix quality houskeeping for software diversity
      rt2x00: Fix rounding errors in RSSI average calculation

Luciano Coelho (4):
      wl1271: add wl1271 driver files
      wl1271: add wl1271 to Kconfig and the Makefile
      MAINTAINERS: add information for wl1271 wireless driver
      wl1271: fix compiler warnings on 64 bit archs

Luis R. Rodriguez (8):
      ath9k: use new FIF_PSPOLL configure filter
      zd1211rw: make it clear we don't use leds.h LED stuff
      mac80211: fix compilation of mesh (although its disabled)
      ath9k: Fix regression on receiving PS poll frames
      ath: add common ath_rxbuf_alloc() and make ath9k use it
      ath5k: use common ath.ko ath_rxbuf_alloc()
      ath5k: use bit shift operators for cache line size
      ath9k: update kconfig to indicate support for AR9002 family

Michael Buesch (2):
      b43: Fix hardware key index handling
      rtl818x: Add some documentation to the TX desc flags

Nick Kossifidis (5):
      ath5k: Check EEPROM before tweaking SERDES
      ath5k: Linear PCDAC code fixes
      ath5k: Wakeup fixes
      ath5k: Preserve pcicfg bits during attach
      ath5k: Use SWI to trigger calibration

Pat Erley (1):
      mac80211: remove max_bandwidth

Pavel Roskin (1):
      cfg80211: fix disassociation warning due to misuse of wdev->curre=
nt_bss

Reinette Chatre (3):
      iwlwifi: re-introduce per device debugging
      iwlwifi: revert uCode Alive notification with timeout
      iwlwifi: fix missing EXPORT_SYMBOL

Samuel Ortiz (1):
      cfg80211: Set WEP ciphers

Sujith (15):
      ath9k: Remove unneeded assignment of protocol field
      ath9k: Cleanup function return types
      ath9k: Try to fix whitespace damage
      ath9k: Remove a few DEBUG mesages
      ath9k: Split eeprom.c into manageable pieces
      ath9k: Cleanup ath9k_hw_4k_set_gain() interface
      ath9k: Add macros for Antenna Diversity
      ath9k: Clean antenna configuration for 4K EEPROM chips
      ath9k: Cleanup TX power calculation for 4K chips
      ath9k: Remove local chainmask variable
      ath9k: Update beacon RSSI
      ath9k: Remove has_hw_phycounters
      ath9k: Remove duplicate variables
      ath9k: Fix bug in PCI resume
      ath9k: Set HW state properly

Thadeu Lima de Souza Cascardo (1):
      trivial: remove duplicate "different" from comment

Wey-Yi Guy (10):
      iwlwifi: name changed from "fat" to "ht40"
      iwlwifi: new debugging feature for dumping data traffic
      iwlwifi: Traffic type and counter for debugFs
      iwlwifi: tx/rx queue pointer information
      iwlwifi: uCode statistics notification counter
      iwlwifi: Display sensitivity and chain noise information
      iwlwifi: fix thermal throttling locking problem
      iwlwifi: fix legacy thermal throttling power index
      iwlwifi: handle the case when set power fail
      iwlwifi: display correct critical temperature infomation

Zhu Yi (1):
      wireless: display wext SSID when connected by cfg80211

gregor kowski (1):
      b43: remove wrong probe_resp_plcp write

 MAINTAINERS                                        |   14 +-
 drivers/net/usb/usbnet.c                           |   44 +-
 drivers/net/wireless/ath/Kconfig                   |    4 +-
 drivers/net/wireless/ath/ath.h                     |   30 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |   17 +
 drivers/net/wireless/ath/ath5k/attach.c            |   60 +-
 drivers/net/wireless/ath/ath5k/base.c              |  138 +-
 drivers/net/wireless/ath/ath5k/base.h              |    6 +-
 drivers/net/wireless/ath/ath5k/eeprom.c            |   10 +
 drivers/net/wireless/ath/ath5k/eeprom.h            |    4 +
 drivers/net/wireless/ath/ath5k/phy.c               |   47 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    2 +-
 drivers/net/wireless/ath/ath5k/reset.c             |  155 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    8 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +
 drivers/net/wireless/ath/ath9k/ani.c               |  195 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    1 -
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            | 3870 +-----------=
--------
 drivers/net/wireless/ath/ath9k/eeprom.h            |  245 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         | 1186 ++++++
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       | 1183 ++++++
 drivers/net/wireless/ath/ath9k/eeprom_def.c        | 1385 +++++++
 drivers/net/wireless/ath/ath9k/hw.c                |   11 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   19 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   17 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    8 +-
 drivers/net/wireless/ath/ath9k/main.c              |    7 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    4 +-
 drivers/net/wireless/ath/ath9k/phy.c               |   12 +-
 drivers/net/wireless/ath/ath9k/phy.h               |   21 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   48 +-
 drivers/net/wireless/ath/main.c                    |   36 +
 drivers/net/wireless/b43/b43.h                     |   11 +-
 drivers/net/wireless/b43/main.c                    |  210 +-
 drivers/net/wireless/b43/phy_lp.c                  |  768 ++++-
 drivers/net/wireless/b43/phy_lp.h                  |   19 +
 drivers/net/wireless/b43/tables_lpphy.c            | 2151 +++++++++++-
 drivers/net/wireless/b43/tables_lpphy.h            |   13 +
 drivers/net/wireless/b43/xmit.c                    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   72 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   81 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  129 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   29 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  354 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   54 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   28 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  951 +++++-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |  104 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   54 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   34 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    2 -
 drivers/net/wireless/iwlwifi/iwl-led.c             |    3 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |  496 ++--
 drivers/net/wireless/iwlwifi/iwl-power.h           |   80 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   21 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    8 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   16 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  101 +-
 drivers/net/wireless/libertas/main.c               |    3 +-
 drivers/net/wireless/orinoco/hw.c                  |  120 +-
 drivers/net/wireless/orinoco/hw.h                  |    7 +-
 drivers/net/wireless/orinoco/main.c                |   35 +-
 drivers/net/wireless/orinoco/orinoco.h             |   16 +-
 drivers/net/wireless/orinoco/wext.c                |  173 +-
 drivers/net/wireless/p54/fwio.c                    |    5 +-
 drivers/net/wireless/p54/main.c                    |    7 +-
 drivers/net/wireless/p54/txrx.c                    |    6 +
 drivers/net/wireless/rndis_wlan.c                  |   13 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |    2 -
 drivers/net/wireless/rt2x00/rt2500pci.c            |    2 -
 drivers/net/wireless/rt2x00/rt2500usb.c            |   15 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   33 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   22 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   14 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |  154 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   72 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   30 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   10 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   10 +-
 drivers/net/wireless/rtl818x/rtl818x.h             |   14 +-
 drivers/net/wireless/wl12xx/Kconfig                |   38 +-
 drivers/net/wireless/wl12xx/Makefile               |   13 +-
 drivers/net/wireless/wl12xx/wl1251.h               |   78 +-
 drivers/net/wireless/wl12xx/wl1251_acx.c           |   84 +-
 drivers/net/wireless/wl12xx/wl1251_acx.h           |  146 +
 drivers/net/wireless/wl12xx/wl1251_boot.c          |  266 ++-
 drivers/net/wireless/wl12xx/wl1251_boot.h          |    1 +
 drivers/net/wireless/wl12xx/wl1251_cmd.c           |   62 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.h           |    4 +-
 drivers/net/wireless/wl12xx/wl1251_event.c         |    7 +-
 drivers/net/wireless/wl12xx/wl1251_init.c          |  213 ++
 drivers/net/wireless/wl12xx/wl1251_init.h          |    2 +
 drivers/net/wireless/wl12xx/wl1251_io.c            |  196 +
 drivers/net/wireless/wl12xx/wl1251_io.h            |   64 +
 drivers/net/wireless/wl12xx/wl1251_main.c          |  375 ++-
 drivers/net/wireless/wl12xx/wl1251_ops.c           |  728 ----
 drivers/net/wireless/wl12xx/wl1251_ops.h           |  165 -
 drivers/net/wireless/wl12xx/wl1251_ps.c            |   18 +-
 .../net/wireless/wl12xx/{reg.h =3D> wl1251_reg.h}    |  100 -
 drivers/net/wireless/wl12xx/wl1251_rx.c            |    9 +-
 drivers/net/wireless/wl12xx/wl1251_sdio.c          |  205 ++
 drivers/net/wireless/wl12xx/wl1251_spi.c           |  327 +-
 drivers/net/wireless/wl12xx/wl1251_spi.h           |   56 +-
 drivers/net/wireless/wl12xx/wl1251_tx.c            |   64 +-
 drivers/net/wireless/wl12xx/wl1271.h               |  407 ++
 drivers/net/wireless/wl12xx/wl1271_acx.c           |  961 +++++
 drivers/net/wireless/wl12xx/wl1271_acx.h           | 1221 ++++++
 drivers/net/wireless/wl12xx/wl1271_boot.c          |  541 +++
 drivers/net/wireless/wl12xx/wl1271_boot.h          |   72 +
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |  813 ++++
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |  464 +++
 drivers/net/wireless/wl12xx/wl1271_debugfs.c       |  518 +++
 drivers/net/wireless/wl12xx/wl1271_debugfs.h       |   33 +
 drivers/net/wireless/wl12xx/wl1271_event.c         |  125 +
 drivers/net/wireless/wl12xx/wl1271_event.h         |  110 +
 drivers/net/wireless/wl12xx/wl1271_init.c          |  397 ++
 drivers/net/wireless/wl12xx/wl1271_init.h          |  115 +
 drivers/net/wireless/wl12xx/wl1271_main.c          | 1397 +++++++
 drivers/net/wireless/wl12xx/wl1271_ps.c            |  142 +
 drivers/net/wireless/wl12xx/wl1271_ps.h            |   35 +
 .../net/wireless/wl12xx/{reg.h =3D> wl1271_reg.h}    |  222 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c            |  200 +
 drivers/net/wireless/wl12xx/wl1271_rx.h            |  121 +
 drivers/net/wireless/wl12xx/wl1271_spi.c           |  382 ++
 drivers/net/wireless/wl12xx/wl1271_spi.h           |  113 +
 drivers/net/wireless/wl12xx/wl1271_tx.c            |  378 ++
 drivers/net/wireless/wl12xx/wl1271_tx.h            |  130 +
 drivers/net/wireless/zd1211rw/zd_chip.c            |    6 +-
 drivers/net/wireless/zd1211rw/zd_chip.h            |    6 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |    4 +-
 drivers/ssb/pci.c                                  |   53 +-
 include/linux/nl80211.h                            |   17 +-
 include/linux/ssb/ssb.h                            |   44 +-
 include/linux/ssb/ssb_regs.h                       |   66 +-
 include/linux/usb/usbnet.h                         |    6 +
 include/net/cfg80211.h                             |   26 +-
 include/net/mac80211.h                             |   29 +-
 net/mac80211/Kconfig                               |    8 +-
 net/mac80211/cfg.c                                 |    4 +
 net/mac80211/ieee80211_i.h                         |    6 +-
 net/mac80211/main.c                                |   16 +-
 net/mac80211/mesh.c                                |  145 +-
 net/mac80211/mesh.h                                |   30 +-
 net/mac80211/mesh_hwmp.c                           |   17 +-
 net/mac80211/mesh_pathtbl.c                        |  151 +-
 net/mac80211/mesh_plink.c                          |    2 +-
 net/mac80211/mlme.c                                |   31 +-
 net/mac80211/rc80211_minstrel.c                    |   16 +-
 net/mac80211/rx.c                                  |   45 +-
 net/mac80211/scan.c                                |   10 +-
 net/mac80211/sta_info.c                            |    2 +
 net/mac80211/tx.c                                  |  158 +-
 net/wireless/Makefile                              |    3 +-
 net/wireless/chan.c                                |   89 +
 net/wireless/core.c                                |   21 +-
 net/wireless/core.h                                |   14 +-
 net/wireless/ibss.c                                |   61 +-
 net/wireless/mlme.c                                |   17 +-
 net/wireless/nl80211.c                             |   88 +-
 net/wireless/reg.c                                 |    5 +-
 net/wireless/scan.c                                |   31 +-
 net/wireless/sme.c                                 |  104 +-
 net/wireless/util.c                                |   16 +-
 net/wireless/wext-compat.c                         |   55 +-
 net/wireless/wext-compat.h                         |    3 +-
 net/wireless/wext-sme.c                            |   83 +-
 175 files changed, 21316 insertions(+), 7692 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath.h
 create mode 100644 drivers/net/wireless/ath/ath9k/eeprom_4k.c
 create mode 100644 drivers/net/wireless/ath/ath9k/eeprom_9287.c
 create mode 100644 drivers/net/wireless/ath/ath9k/eeprom_def.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_io.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_io.h
 delete mode 100644 drivers/net/wireless/wl12xx/wl1251_ops.c
 delete mode 100644 drivers/net/wireless/wl12xx/wl1251_ops.h
 copy drivers/net/wireless/wl12xx/{reg.h =3D> wl1251_reg.h} (81%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_sdio.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_acx.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_acx.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_boot.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_boot.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_cmd.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_cmd.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_debugfs.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_debugfs.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_event.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_event.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_init.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_init.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_main.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_ps.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_ps.h
 rename drivers/net/wireless/wl12xx/{reg.h =3D> wl1271_reg.h} (93%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_rx.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_rx.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_spi.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_spi.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_tx.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_tx.h
 create mode 100644 net/wireless/chan.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-08-14.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
