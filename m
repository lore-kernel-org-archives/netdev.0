From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-03-27
Date: Fri, 27 Mar 2009 20:29:46 -0400
Message-ID: <20090328002946.GD3823@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54726 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbZC1Aap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 20:30:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

One last batch of new stuff intended for 2.6.30.  This has spent time in
wireless-testing and linux-next, so it should be relatively solid.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 79675900cbf2c4e67e95f94983ec4ee800b83739:
  Anton Vorontsov (1):
        ucc_geth: Fix three oopses in PHY {de,}initialization code

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git

Abhijeet Kolekar (5):
      iwl3945: set TFD_QUEUE_MAX to correct value
      iwl3945: use iwl_cmd_queue_free
      iwl3945: fix checkpatch.pl errors
      iwl3945: control rate decrease
      iwl3945: replace stations with stations_39

Alina Friedrichsen (1):
      mac80211: ieee80211_ibss_commit() cleanup

Bob Copeland (4):
      ath5k: disable MIB interrupts
      ath5k: remove dummy PCI "retry timeout" fix
      ath5k: warn and correct rate for unknown hw rate indexes
      ath5k: properly drop packets from ops->tx

Christian Lamparter (9):
      p54: fix SoftLED compile dependencies
      ar9170: hardware and eeprom header files
      ar9170: ar9170: mac80211 interaction code
      ar9170: mac/bbp and phy code
      ar9170: ar9170: USB frontend driver
      ar9170: update Makefile, Kconfig and MAINTAINERS
      ar9170: simplify & deBUG tx_status queueing and reporting
      p54: Kconfig maintenance
      ar9170: single module build

Geert Uytterhoeven (1):
      wireless/p54: P54_SPI should depend on GENERIC_HARDIRQS

Helmut Schaa (1):
      mac80211: start pending scan after probe/auth/assoc timed out

Ivo van Doorn (2):
      rt2x00: Update MAINTAINERS entry: new mailinglist
      rt2x00: New USB ID for rt73usb

Johannes Berg (24):
      mac80211: remove ieee80211_num_regular_queues
      mac80211: reduce max number of queues
      mac80211: fix warnings in ieee80211_if_config
      mac80211: stop queues across suspend/resume
      wireless: radiotap updates
      nl80211: export supported commands
      mac80211: acquire sta_lock for station suspend/resume
      ieee80211: document DS bit usage
      nl80211: rework locking
      mac80211: kill IEEE80211_CONF_SHORT_SLOT_TIME
      mac80211: resume properly, add suspend/resume test
      cfg80211: accept no-op interface mode changes
      mac80211: remove mixed-cell and userspace MLME code
      mac80211: rate control status only for controlled packets
      mac80211: fix RX path
      cfg80211: fix locking in nl80211_set_wiphy
      mac80211: rewrite fragmentation
      mac80211: fix A-MPDU queue assignment
      mac80211: rework the pending packets code
      mac80211: clean up __ieee80211_tx args
      mac80211: unify and fix TX aggregation start
      mac80211: add skb length sanity checking
      mac80211: fix aggregation to not require queue stop
      mac80211/iwlwifi: move virtual A-MDPU queue bookkeeping to iwlwifi

Jouni Malinen (10):
      ath9k: Add support for multiple virtual AP interfaces
      mac80211: Fix a typo in assoc vs. reassoc check
      mac80211: Fix reassociation by not clearing previous BSSID
      nl80211: Event notifications for MLME events
      nl80211: Add MLME primitives to support external SME
      mac80211: Fix memleak in nl80211 authentication on deinit
      nl80211: Remove NL80211_CMD_SET_MGMT_EXTRA_IE
      nl80211: Add more through validation of MLME command parameters
      nl80211: Check that netif_runnin is true in cfg80211 code
      nl80211: Check iftype in cfg80211 code

Kalle Valo (6):
      mac80211: don't drop nullfunc frames during software scan
      mac80211: decrease execution of the associated timer
      mac80211: track beacons separately from the rx path activity
      mac80211: disable power save when scanning
      cfg80211: add feature to hold bss
      mac80211: add beacon filtering support

Lorenzo Nava (1):
      b43: fix b43_plcp_get_bitrate_idx_ofdm return type

Luis R. Rodriguez (8):
      ath9k: remove dummy PCI "retry timeout" fix
      mac80211_hwsim: let the reg workqueue breathe when regtest is set
      cfg80211: force last_request to be set for OLD_REG if regdom is EU
      cfg80211: fix incorrect assumption on last_request for 11d
      cfg80211: make regdom module parameter available oustide of OLD_REG
      cfg80211: remove code about country IE support with OLD_REG
      ath9k: fix dma mapping leak of rx buffer upon rmmod
      cfg80211: default CONFIG_WIRELESS_OLD_REGULATORY to n

Michael Buesch (3):
      b43: Mask PHY TX error interrupt, if not debugging
      ssb: remove EXPERIMENTAL dependencies.
      b43: Add BCM4307 PCI-ID

Mohamed Abbas (5):
      iwlagn: use changed in mac_config
      iwl3945: use changed in iwl3945_mac_config
      iwlagn: allow power level setting all the times
      iwlcore: dont commit power command if interface is not up
      iwlwifi: support 11h

Nick Kossifidis (3):
      ath5k: Choose the right initvals for RF2425
      ath5k: Convert chip specific calibration data to a generic format
      ath5k: Add tx power calibration support

Pat Erley (1):
      Add mesh point functionality to ath9k

Reinette Chatre (1):
      cfg80211/nl80211: remove usage of CONFIG_NL80211

Sujith (9):
      ath9k: Miscellaneous EEPROM handling cleanup
      ath9k: Move AR5416_VER_MASK to a common location
      ath9k: Introduce a helper function for setting board gain values
      ath9k: Change return type for set_board_values()
      ath9k: Fix bug in 4K EEPROM size calculation
      ath9k: Fill in ack signal in TX status
      ath9k: Fix bug in handling single stream stations
      ath9k: Update copyright in all the files
      mac80211: Tear down aggregation sessions for suspend/resume

Tulio Magno Quites Machado Filho (1):
      ath5k: Support LED's on Acer Extensa 5620z

Vasanthakumar Thiagarajan (6):
      ath9k: Set IEEE80211_TX_CTL_RATE_CTRL_PROBE in rate control for probe rate
      mac80211: Populate HT limitation with TKIP/WEP to the handler for SIOCSIWENCODE too
      ath9k: Keep LED on in idle state after association
      ath9k: Fix rate control update for aggregated frames
      ath9k: Fix bug in reporting status of tx rate
      ath9k: Nuke struct ath_xmit_status

Wey-Yi Guy (3):
      iwlwifi: return 0 for AMPDU_TX/RX_STOP request if NIC is going down
      iwlwifi: report error when detect failure during stop agg queue
      iwlwifi: show current driver status in user readable format

 Documentation/DocBook/mac80211.tmpl         |    6 +
 Documentation/feature-removal-schedule.txt  |   37 +-
 MAINTAINERS                                 |   10 +-
 drivers/net/wireless/Kconfig                |    1 +
 drivers/net/wireless/Makefile               |    1 +
 drivers/net/wireless/ar9170/Kconfig         |   17 +
 drivers/net/wireless/ar9170/Makefile        |    3 +
 drivers/net/wireless/ar9170/ar9170.h        |  209 ++++
 drivers/net/wireless/ar9170/cmd.c           |  129 ++
 drivers/net/wireless/ar9170/cmd.h           |   91 ++
 drivers/net/wireless/ar9170/eeprom.h        |  179 +++
 drivers/net/wireless/ar9170/hw.h            |  417 +++++++
 drivers/net/wireless/ar9170/led.c           |  171 +++
 drivers/net/wireless/ar9170/mac.c           |  452 ++++++++
 drivers/net/wireless/ar9170/main.c          | 1671 +++++++++++++++++++++++++++
 drivers/net/wireless/ar9170/phy.c           | 1240 ++++++++++++++++++++
 drivers/net/wireless/ar9170/usb.c           |  748 ++++++++++++
 drivers/net/wireless/ar9170/usb.h           |   74 ++
 drivers/net/wireless/ath5k/ath5k.h          |   35 +-
 drivers/net/wireless/ath5k/attach.c         |    2 +
 drivers/net/wireless/ath5k/base.c           |   46 +-
 drivers/net/wireless/ath5k/base.h           |    2 +-
 drivers/net/wireless/ath5k/desc.c           |    4 +
 drivers/net/wireless/ath5k/eeprom.c         |  774 +++++++++----
 drivers/net/wireless/ath5k/eeprom.h         |  128 ++-
 drivers/net/wireless/ath5k/initvals.c       |    4 +-
 drivers/net/wireless/ath5k/led.c            |    2 +
 drivers/net/wireless/ath5k/phy.c            | 1170 ++++++++++++++++++--
 drivers/net/wireless/ath5k/reg.h            |   19 +
 drivers/net/wireless/ath5k/reset.c          |   35 +-
 drivers/net/wireless/ath9k/ahb.c            |    2 +-
 drivers/net/wireless/ath9k/ani.c            |    2 +-
 drivers/net/wireless/ath9k/ani.h            |    2 +-
 drivers/net/wireless/ath9k/ath9k.h          |    9 +-
 drivers/net/wireless/ath9k/beacon.c         |   56 +-
 drivers/net/wireless/ath9k/calib.c          |    2 +-
 drivers/net/wireless/ath9k/calib.h          |    2 +-
 drivers/net/wireless/ath9k/debug.c          |    2 +-
 drivers/net/wireless/ath9k/debug.h          |    2 +-
 drivers/net/wireless/ath9k/eeprom.c         |  308 ++---
 drivers/net/wireless/ath9k/eeprom.h         |    5 +-
 drivers/net/wireless/ath9k/hw.c             |   14 +-
 drivers/net/wireless/ath9k/hw.h             |    2 +-
 drivers/net/wireless/ath9k/initvals.h       |    2 +-
 drivers/net/wireless/ath9k/mac.c            |    2 +-
 drivers/net/wireless/ath9k/mac.h            |    2 +-
 drivers/net/wireless/ath9k/main.c           |   47 +-
 drivers/net/wireless/ath9k/pci.c            |   20 +-
 drivers/net/wireless/ath9k/phy.c            |    2 +-
 drivers/net/wireless/ath9k/phy.h            |    2 +-
 drivers/net/wireless/ath9k/rc.c             |   23 +-
 drivers/net/wireless/ath9k/rc.h             |    2 +-
 drivers/net/wireless/ath9k/recv.c           |    9 +-
 drivers/net/wireless/ath9k/reg.h            |    2 +-
 drivers/net/wireless/ath9k/regd.c           |    2 +-
 drivers/net/wireless/ath9k/regd.h           |    2 +-
 drivers/net/wireless/ath9k/regd_common.h    |    2 +-
 drivers/net/wireless/ath9k/xmit.c           |   78 +-
 drivers/net/wireless/b43/main.c             |    2 +
 drivers/net/wireless/b43/xmit.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |   13 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   24 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    7 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |  179 ++--
 drivers/net/wireless/iwlwifi/iwl-core.c     |    8 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |   54 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    6 +
 drivers/net/wireless/iwlwifi/iwl-helpers.h  |   52 +
 drivers/net/wireless/iwlwifi/iwl-power.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |   18 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   38 +-
 drivers/net/wireless/libertas/radiotap.h    |   10 -
 drivers/net/wireless/libertas/rx.c          |   12 +-
 drivers/net/wireless/mac80211_hwsim.c       |    4 +-
 drivers/net/wireless/p54/Kconfig            |   39 +-
 drivers/net/wireless/p54/p54common.c        |   16 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +
 drivers/ssb/Kconfig                         |   16 +-
 drivers/ssb/b43_pci_bridge.c                |    1 +
 include/linux/ieee80211.h                   |   17 +
 include/linux/nl80211.h                     |   88 ++-
 include/linux/pci_ids.h                     |    2 +
 include/net/cfg80211.h                      |  203 +++-
 include/net/ieee80211_radiotap.h            |    4 +-
 include/net/mac80211.h                      |   84 +-
 net/mac80211/agg-rx.c                       |    8 +
 net/mac80211/agg-tx.c                       |  232 ++--
 net/mac80211/cfg.c                          |  245 ++--
 net/mac80211/debugfs.c                      |   24 +
 net/mac80211/ibss.c                         |    3 +-
 net/mac80211/ieee80211_i.h                  |   78 +-
 net/mac80211/iface.c                        |   14 +-
 net/mac80211/main.c                         |   25 +-
 net/mac80211/mlme.c                         |  259 +++--
 net/mac80211/pm.c                           |   78 ++-
 net/mac80211/rate.c                         |    6 +-
 net/mac80211/rate.h                         |    4 +-
 net/mac80211/rx.c                           |   29 +-
 net/mac80211/scan.c                         |   77 ++-
 net/mac80211/sta_info.c                     |   17 +-
 net/mac80211/sta_info.h                     |    7 +-
 net/mac80211/tx.c                           |  579 ++++++----
 net/mac80211/util.c                         |  126 +--
 net/mac80211/wep.c                          |   21 +-
 net/mac80211/wext.c                         |   33 +-
 net/mac80211/wpa.c                          |   28 +-
 net/wireless/Kconfig                        |   44 +-
 net/wireless/Makefile                       |    3 +-
 net/wireless/core.c                         |   30 +-
 net/wireless/core.h                         |    5 +
 net/wireless/mlme.c                         |   46 +
 net/wireless/nl80211.c                      |  824 +++++++++++---
 net/wireless/nl80211.h                      |   38 +-
 net/wireless/reg.c                          |   65 +-
 net/wireless/scan.c                         |   27 +-
 net/wireless/wext-compat.c                  |   11 +-
 120 files changed, 10096 insertions(+), 2091 deletions(-)
 create mode 100644 drivers/net/wireless/ar9170/Kconfig
 create mode 100644 drivers/net/wireless/ar9170/Makefile
 create mode 100644 drivers/net/wireless/ar9170/ar9170.h
 create mode 100644 drivers/net/wireless/ar9170/cmd.c
 create mode 100644 drivers/net/wireless/ar9170/cmd.h
 create mode 100644 drivers/net/wireless/ar9170/eeprom.h
 create mode 100644 drivers/net/wireless/ar9170/hw.h
 create mode 100644 drivers/net/wireless/ar9170/led.c
 create mode 100644 drivers/net/wireless/ar9170/mac.c
 create mode 100644 drivers/net/wireless/ar9170/main.c
 create mode 100644 drivers/net/wireless/ar9170/phy.c
 create mode 100644 drivers/net/wireless/ar9170/usb.c
 create mode 100644 drivers/net/wireless/ar9170/usb.h
 create mode 100644 net/wireless/mlme.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6-2009-03-27.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
