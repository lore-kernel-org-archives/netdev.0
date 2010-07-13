From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-07-13
Date: Tue, 13 Jul 2010 16:36:40 -0400
Message-ID: <20100713203639.GE3835@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53531 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757062Ab0GMUpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 16:45:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest batch of wireless LAN goodies intended for 2.6.36.
It is more-or-less the usual batch of driver updates, including ath9k,
iwlwifi, rt2x00, and wl1271.  The usual flurry of mac80211 updates is
missing, due mostly to Johannes attending to a personal obligation of a
happy nature. :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 242647bcf8464860f173f3d4d4ab3490d3558518:

  hso: remove driver version (2010-07-12 21:21:27 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git for-davem

Ameya Palande (1):
      wl12xx: Use MODULE_ALIAS macro at correct postion for SPI bus

Amitkumar Karwar (1):
      libertas: Added support for host sleep feature

Christian Lamparter (1):
      p54: update MAINTAINERS

Dan Carpenter (2):
      prism54: call BUG_ON() earlier
      hostap: fixup strlen() math

Emmanuel Grumbach (1):
      iwlagn: fix the bit mask of a FH register in stop Tx DMA flow

Felix Fietkau (16):
      ath9k_hw: fix a few inconsistencies in initval array names
      ath9k_hw: reformat the ar5008, ar9001 and ar9002 initvals to match ar9003
      ath9k_hw: sync initvals for ar9001 and ar9002 with Atheros
      ath9k_hw: sanitize noise floor values properly on all chips
      ath9k_hw: clean up the noise floor calibration code to reduce code duplication
      ath9k: fix false positives in the baseband hang check
      ath9k: fix crash with WEP in ad-hoc mode
      ath9k: fix a potential buffer leak in the STA teardown path
      ath9k: fix a buffer leak in A-MPDU completion
      ath9k_hw: fix antenna diversity on AR9285
      ath9k_hw: fix a sign error in the IQ calibration code
      ath9k_hw: fix an off-by-one error in the PDADC boundaries calculation
      ath9k_hw: prevent a fast channel change after a rx DMA stuck issue
      ath9k_hw: report the TID in the tx status on AR5008-AR9002
      ath9k: validate the TID in the tx status information
      ath9k: merge noisefloor load implementations

Helmut Schaa (9):
      rt2x00: Limit txpower by eeprom values
      rt2x00: Convert rt2x00 to use threaded interrupts
      rt2x00: Allow beacon update without scheduling a work
      rt2x00: Implement broad- and multicast buffering
      rt2x00: Use pretbtt irq for fetching beacons on rt2800pci
      rt2x00: Use separate mac80211_ops for rt2800pci and rt2800usb
      rt2x00: Remove set_tim callback from PCI drivers
      rt2x00: Don't initialize beacon interval to 0 on rt2800 devices
      rt2x00: Add missing TSF sync mode for AP operation

Ivo van Doorn (8):
      rt2x00: Convert AGC value from descriptor to RSSI (dBm)
      rt2x00: Rename CONFIG_DISABLE_LINK_TUNING
      rt2x00: Disable link tuning while scanning
      rt2x00: Fix vgc_level_reg handling
      rt2x00: Implement watchdog monitoring
      rt2x00: Make rt2800_write_beacon only export to GPL
      rt2x00: Move common firmware loading into rt2800lib
      rt2x00: Move driver callback functions into the ops structure

Jay Sternberg (1):
      iwlwifi: correct descriptions of advanced ucode errors

Jiri Slaby (1):
      NET: nl80211, fix lock imbalance and netdev referencing

Johannes Berg (1):
      cfg80211: ignore spurious deauth

John W. Linville (5):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      mac80211: remove wep dependency
      MAINTAINERS: mark adm8211 as an orphan
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6 into for-davem

Juuso Oikarinen (9):
      wl1271: Remove calibration from join command
      wl1271: Add TSF handling
      wl1271: Use the ARP configuration function from mac80211
      wl1271: Use all basic rates for ps-poll, instead of just the slowest
      wl1271: Work around AP's with broken ps-poll functionality
      wl1271: Update hardware ARP filtering configuration handling
      wl1271: Disable dynamic PS based on BT co-ext sense events
      wl1271: Fix warning when disconnecting and ad-hoc network
      wl1271: Update interface to temporarily disable dynamic PS

Kulikov Vasiliy (1):
      adm8211: fix memory leak

Luciano Coelho (5):
      wl1271: read fem manufacturer value from nvs
      wl1271: moved scan operations to a separate file
      wl1271: rewritten scanning code
      wl1271: use per-channel max tx power passed by mac80211 when scanning
      wl1271: use __packed annotation

Ming Lei (2):
      minstrel_ht: fix updating rate with best probability
      minstrel_ht: fix check for downgrading of top2 rate

Rajkumar Manoharan (1):
      ath9k_htc: fix memory leak in ath9k_hif_usb_alloc_urbs

Reinette Chatre (1):
      iwlwifi: remove key information during device restart

Shanyu Zhao (1):
      iwlwifi: enable 6050 series Gen2 devices

Wey-Yi Guy (9):
      iwlwifi: fix fw_restart module parameter
      iwlwifi: add debug print for parsing firmware TLV
      iwlwifi: tx fifo queue flush command
      iwlwifi: add mac80211 flush callback support
      iwlwifi: add support for device tx flush request
      iwlwifi: debugfs file for txfifo command testing
      iwlwifi: generic parameter define for _agn device
      iwlwifi: adding enhance sensitivity table entries
      iwlagn: more generic description for iwlagn devices

 MAINTAINERS                                      |    9 +-
 drivers/net/wireless/adm8211.c                   |    5 +-
 drivers/net/wireless/ath/ath9k/ar5008_initvals.h | 1319 ++--
 drivers/net/wireless/ath/ath9k/ar5008_phy.c      |  129 +-
 drivers/net/wireless/ath/ath9k/ar9001_initvals.h | 2479 +++---
 drivers/net/wireless/ath/ath9k/ar9002_calib.c    |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c       |   12 +-
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h |10152 +++++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9002_mac.c      |    1 +
 drivers/net/wireless/ath/ath9k/ar9002_phy.c      |   69 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h      |   26 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.h      |    3 -
 drivers/net/wireless/ath/ath9k/ar9003_phy.c      |  213 +-
 drivers/net/wireless/ath/ath9k/ath9k.h           |    2 +
 drivers/net/wireless/ath/ath9k/calib.c           |  153 +-
 drivers/net/wireless/ath/ath9k/calib.h           |    7 +-
 drivers/net/wireless/ath/ath9k/common.c          |    4 +
 drivers/net/wireless/ath/ath9k/eeprom.h          |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c       |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c     |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c      |    6 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c         |    8 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h          |    6 -
 drivers/net/wireless/ath/ath9k/hw.c              |    7 +-
 drivers/net/wireless/ath/ath9k/hw.h              |   23 +-
 drivers/net/wireless/ath/ath9k/init.c            |    1 +
 drivers/net/wireless/ath/ath9k/mac.h             |    3 +
 drivers/net/wireless/ath/ath9k/main.c            |   27 +-
 drivers/net/wireless/ath/ath9k/xmit.c            |   65 +-
 drivers/net/wireless/hostap/hostap_main.c        |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig             |    9 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c          |   12 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c          |   44 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c     |  133 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c       |   82 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c        |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c           |  209 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h           |    4 +
 drivers/net/wireless/iwlwifi/iwl-commands.h      |   85 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |   31 +-
 drivers/net/wireless/iwlwifi/iwl-core.h          |    5 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h           |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |   29 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h           |    4 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h        |    4 +
 drivers/net/wireless/iwlwifi/iwl-fh.h            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c          |    1 +
 drivers/net/wireless/iwlwifi/iwl-rx.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h           |   11 +
 drivers/net/wireless/libertas/README             |   12 +
 drivers/net/wireless/libertas/cmd.c              |   61 +-
 drivers/net/wireless/libertas/cmd.h              |    2 +
 drivers/net/wireless/libertas/debugfs.c          |   66 +
 drivers/net/wireless/libertas/main.c             |   34 +-
 drivers/net/wireless/prism54/isl_ioctl.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |   69 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |   71 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |   14 +-
 drivers/net/wireless/rt2x00/rt2800.h             |   30 +-
 drivers/net/wireless/rt2x00/rt2800lib.c          |  434 +-
 drivers/net/wireless/rt2x00/rt2800lib.h          |   43 +-
 drivers/net/wireless/rt2x00/rt2800pci.c          |  229 +-
 drivers/net/wireless/rt2x00/rt2800usb.c          |  178 +-
 drivers/net/wireless/rt2x00/rt2x00.h             |   25 +-
 drivers/net/wireless/rt2x00/rt2x00config.c       |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c          |   96 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h          |   26 +-
 drivers/net/wireless/rt2x00/rt2x00link.c         |   65 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |   50 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c        |    4 +
 drivers/net/wireless/rt2x00/rt2x00queue.h        |   11 +
 drivers/net/wireless/rt2x00/rt2x00reg.h          |    5 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c          |   50 +
 drivers/net/wireless/rt2x00/rt2x00usb.h          |   10 +
 drivers/net/wireless/rt2x00/rt61pci.c            |   68 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |    7 +
 drivers/net/wireless/wl12xx/Makefile             |    2 +-
 drivers/net/wireless/wl12xx/wl1251_main.c        |    1 -
 drivers/net/wireless/wl12xx/wl1251_spi.c         |    1 +
 drivers/net/wireless/wl12xx/wl1271.h             |   24 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c         |   41 +-
 drivers/net/wireless/wl12xx/wl1271_acx.h         |   15 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c        |    4 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c         |  248 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h         |   68 -
 drivers/net/wireless/wl12xx/wl1271_conf.h        |   16 +-
 drivers/net/wireless/wl12xx/wl1271_event.c       |   99 +-
 drivers/net/wireless/wl12xx/wl1271_event.h       |    1 +
 drivers/net/wireless/wl12xx/wl1271_main.c        |  174 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c          |    6 -
 drivers/net/wireless/wl12xx/wl1271_scan.c        |  257 +
 drivers/net/wireless/wl12xx/wl1271_scan.h        |  109 +
 drivers/net/wireless/wl12xx/wl1271_spi.c         |    1 +
 net/mac80211/cfg.c                               |    5 +
 net/mac80211/main.c                              |    5 +-
 net/mac80211/rc80211_minstrel_ht.c               |    6 +-
 net/mac80211/tkip.c                              |    8 +-
 net/mac80211/tkip.h                              |    2 +-
 net/mac80211/wep.c                               |   24 +-
 net/mac80211/wep.h                               |    2 +-
 net/mac80211/wpa.c                               |    5 +-
 net/wireless/mlme.c                              |    8 +-
 net/wireless/nl80211.c                           |    2 +-
 106 files changed, 9722 insertions(+), 8517 deletions(-)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_scan.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_scan.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-07-13.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
