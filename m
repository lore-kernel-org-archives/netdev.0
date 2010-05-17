From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-05-17
Date: Mon, 17 May 2010 14:26:53 -0400
Message-ID: <20100517182653.GC2436@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

One last big batch intended for 2.6.35 -- these have all been in
linux-next for several days.  Included are the usual driver updates for
iwlwifi, ath9k, and rt2x00 along with a smattering of other bits
(including some trivial fixups).

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 278554bd6579206921f5d8a523649a7a57f8850d:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../davem/net-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git for-davem

Abhijeet Kolekar (3):
      iwl3945: fix scan races
      iwl3945: add plcp error checking
      mac80211: fix paged defragmentation

Dan Carpenter (3):
      wl1271: add missing spin_lock()
      wl1271: fix notifier interface supported test
      wl1271: remove some unneeded code

Felix Fietkau (4):
      ath9k: use debugfs_remove_recursive() instead of keeping pointers to all entries
      ath9k: add debugfs files for reading/writing the rx and tx chainmask
      ath9k: add debugfs files for reading/writing registers
      ath9k_hw: clean up EEPROM endian handling on AR9003

Gertjan van Wingerde (6):
      rt2x00: Consistently name skb frame descriptor skbdesc.
      rt2x00: Fix beacon descriptor writing for rt61pci.
      rt2x00: Re-order tx descriptor writing code in drivers.
      rt2x00: Simplify TXD handling of beacons.
      rt2x00: Dump beacons under a different identifier than TX frames.
      rt2x00: In debugfs frame dumping allow the TX descriptor to be part of the skb.

Johannes Berg (34):
      iwlagn: wait for asynchronous firmware loading
      iwlwifi: use vif iwl_bss_info_changed
      iwl3945: use iwl3945_add_bcast_station
      iwlwifi: pass address to iwl_remove_station
      iwlwifi: manage IBSS station properly
      iwlagn: show and store firmware build number
      iwl3945: remove ucode access indirection
      iwlwifi: remove ucode virtual functions
      iwlwifi: move eeprom version printout to eeprom init
      iwlagn: prepare for new firmware file format
      iwlagn: implement loading a new firmware file type
      iwlwifi: remove rts_threshold
      iwlagn: move iwl_get_ra_sta_id to 4965
      iwlagn: use vif->type to check station
      iwlwifi: apply filter flags directly
      iwlwifi: push virtual interface through
      iwlagn: use virtual interface in TX aggregation handling
      iwlwifi: remove useless priv->vif check
      iwlwifi: use vif in iwl_ht_conf
      iwlwifi: note that priv->bssid is used only by 3945
      iwlwifi: fix iwl_sta_init_lq station ID
      iwlwifi: split allocation/sending local station LQ
      iwlwifi: rework broadcast station management
      iwlwifi: track station IDs
      iwlwifi: add iwl_sta_id()
      iwlwifi: use iwl_find_station less
      iwlagn: use iwl_sta_id() for aggregation
      iwlwifi: use iwl_sta_id() for TKIP key update
      iwlwifi: move iwl_find_station() to 4965
      iwlwifi: rename iwl_add_local_station
      iwlwifi: remove pointless HT check
      iwlwifi: clear driver stations when going down
      mac80211: don't process work item with wrong frame
      mac80211: add offload channel switch support

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6 into for-davem

Julia Lawall (1):
      drivers/net/wireless/hostap: Drop memory allocation cast

Luis R. Rodriguez (2):
      ath5k: drop warning on jumbo frames
      ath9k_hw: new initialization values for AR9003

Reinette Chatre (3):
      Merge branch 'wireless-2.6' into wireless-next-2.6
      iwlwifi: make bcast LQ command available for later restore actions
      iwlagn: work around rate scaling reset delay

Shanyu Zhao (2):
      iwlwifi: rename 6000 series Gen2 devices to Gen2a
      iwlwifi: dump firmware build info in error case

Steve Tanner (1):
      ar9170usb: add vendor and device ID for Qwest/Actiontec 802AIN Wireless N USB Network Adapter

Sujith.Manoharan-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org (5):
      ath9k_htc: Lock sta_notify() callback
      ath9k_htc: Allocate URBs properly
      ath9k_htc: Reorder HTC initialization
      ath9k_htc: Fix target ready race condition
      ath9k_htc: Fix array overflow

Vasanthakumar Thiagarajan (2):
      ath9k: Fix bug in handling rx frames with invalid descriptor content
      ath9k: Remove unused rx_edma in ath_rx_addbuffer_edma()

Wey-Yi Guy (11):
      iwlwifi: remove powersave debugfs if it is not supported
      iwlwifi: rename "tx_power" to "chain_tx_power"
      iwlwifi: remove device type checking for tx power in debugfs
      iwlwifi: use .cfg to enable/disable continuous ucode trace
      iwlwifi: use cfg to configure calibration operation
      iwlwifi: give correct return information for tx power debugfs
      iwlwifi: wimax co-exist code clean up
      iwlwifi: checking for all the possible failure cases
      iwlwifi: "tx power per chain" are part of ucode_tx_stats
      iwlwifi: provide more comments for cfg structure
      mac80211: check channel switch mode for future frames transmit

 drivers/net/wireless/ath/ar9170/usb.c            |    2 +
 drivers/net/wireless/ath/ath5k/base.c            |   12 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c   |  174 +++----
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h   |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_initvals.h |  268 ++++++------
 drivers/net/wireless/ath/ath9k/debug.c           |  236 ++++++++--
 drivers/net/wireless/ath/ath9k/debug.h           |    8 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c         |   58 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_init.c    |    7 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |    4 +
 drivers/net/wireless/ath/ath9k/htc_hst.c         |   51 +-
 drivers/net/wireless/ath/ath9k/htc_hst.h         |   15 +-
 drivers/net/wireless/ath/ath9k/recv.c            |    3 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c    |    3 +-
 drivers/net/wireless/hostap/hostap_ioctl.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c          |    9 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c          |  147 ++++--
 drivers/net/wireless/iwlwifi/iwl-3945.h          |   22 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c          |  100 +++--
 drivers/net/wireless/iwlwifi/iwl-5000.c          |   27 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c          |   51 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c   |   16 +
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c       |   31 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c        |   29 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c     |  109 +++--
 drivers/net/wireless/iwlwifi/iwl-agn.c           |  556 +++++++++++++++-------
 drivers/net/wireless/iwlwifi/iwl-agn.h           |   14 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |  199 +++-----
 drivers/net/wireless/iwlwifi/iwl-core.h          |   60 ++-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |   66 +--
 drivers/net/wireless/iwlwifi/iwl-dev.h           |   89 +++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c        |    7 +
 drivers/net/wireless/iwlwifi/iwl-power.c         |    5 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c           |  456 ++++++++----------
 drivers/net/wireless/iwlwifi/iwl-sta.h           |   60 ++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |  163 ++++---
 drivers/net/wireless/rt2x00/rt2400pci.c          |   26 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |   26 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |   55 ++-
 drivers/net/wireless/rt2x00/rt2800pci.c          |   14 +-
 drivers/net/wireless/rt2x00/rt2800usb.c          |    8 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c        |   21 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h         |    3 +
 drivers/net/wireless/rt2x00/rt2x00pci.c          |    9 -
 drivers/net/wireless/rt2x00/rt2x00queue.c        |   15 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h        |    3 +
 drivers/net/wireless/rt2x00/rt2x00usb.c          |    8 -
 drivers/net/wireless/rt2x00/rt61pci.c            |   35 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |   71 ++--
 drivers/net/wireless/wl12xx/wl1271_main.c        |    5 +-
 include/net/mac80211.h                           |   39 ++
 net/mac80211/driver-ops.h                        |   11 +
 net/mac80211/driver-trace.h                      |   49 ++
 net/mac80211/ieee80211_i.h                       |    3 +-
 net/mac80211/mlme.c                              |   59 +++-
 net/mac80211/rx.c                                |    6 +
 net/mac80211/work.c                              |   27 +-
 60 files changed, 2152 insertions(+), 1442 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-05-17.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
