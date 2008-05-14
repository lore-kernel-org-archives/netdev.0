From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-05-14
Date: Wed, 14 May 2008 17:42:35 -0400
Message-ID: <20080514214234.GA11429@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Here is another round of updates destined for 2.6.27.  These are
mostly driver updates, especially for iwlwifi.

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 99dd1a2b8347ac2ae802300b7862f6f7bcf17139:
  David S. Miller (1):
        Merge branch 'upstream-next' of master.kernel.org:/.../jgarzik/netdev-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (2):
      iwlwifi : Set monitor mode for 4965
      iwlwifi : Set monitor mode for 3945

Andrew Morton (1):
      wireless: fix "iwlwifi: unify init driver flow"

Bill Moss (1):
      iwl3945: do not delay hardware scan if it is a direct scan

Bob Copeland (1):
      ath5k: Fix loop variable initializations

Bruno Randolf (3):
      zd1211rw: initial IBSS support
      mac80211: use hardware flags for signal/noise units
      mac80211: make rx radiotap header more flexible

Emmanuel Grumbach (1):
      iwlwifi: move iwl4965_init_alive_start to iwl-4965.c

Eric W. Biederman (1):
      wireless: Add missing locking to cfg80211_dev_rename

Ester Kummer (4):
      iwlwifi: move per driverdebug_level to per device
      iwlwifi: move debug_level to sysfs/bus/pci/devices
      iwlwifi: update levels of debug prints
      iwlwifi: adding parameter of fw_restart

Harvey Harrison (6):
      mac80211: remove unnecessary byteshifts in frame control testing
      wireless: use get/put_unaligned_* helpers
      mac80211: tkip.c use kernel-provided infrastructure
      b43: replace limit_value macro with clamp_val
      b43legacy: replace limit_value macro with clamp_val
      b43: use the bitrev helpers rather than rolling a private one

Holger Schurig (1):
      libertas: remove lbs_get_data_rate()

Huang Weiyi (1):
      b43: nphy.c remove duplicated include

Ivo van Doorn (1):
      mac80211: Set IEEE80211_TXPD_REQ_TX_STATUS for all TX frames

Johannes Berg (3):
      mac80211: require four hardware queues for QoS/HT
      mac80211: proper STA info locking
      mac80211: fix queue constant confusion

Paulius Zaleckas (3):
      airo: use netstats in net_device structure
      arlan: use netstats in net_device structure
      atmel: use netstats in net_device structure

Ron Rindjunsky (7):
      iwlwifi: map A-MPDU HW queue to mac80211 A-MPDU SW queue
      iwlwifi-5000: rename iwl5000_init_nic to iwl5000_init_config
      iwlwifi: create disable SCD Tx FIFOs handler
      iwlwifi: move NIC init and Tx queues init to iwlcore
      iwlwifi: handle shared memory Rx index access
      iwlwifi: remove 4965 prefix from iwl4965_kw and iwl4965_tx_queue
      iwlwifi: fix spinlock used before initialized

Tomas Winkler (10):
      iwlwifi: move RX code to iwl-rx.c
      iwlwifi: don't override association channel with control channel
      iwlwifi: remove 4965 from station_entry
      iwlwifi: debugfs EEPROM dump
      iwlwifi: remove 4965 from rx_packet
      iwlwifi: generalize iwl4965_send_add_station function
      iwlwifi-5000: add build_addsta_hcmd handler for 5000 HW
      iwlwifi: move iwl4965_set_rxon_ht into iwlcore
      iwlwifi: compile iwl-sta into iwlcore
      iwlwifi: add device sysfs version entry

 drivers/net/wireless/adm8211.c              |    7 +-
 drivers/net/wireless/airo.c                 |   57 +-
 drivers/net/wireless/arlan-main.c           |   40 +-
 drivers/net/wireless/arlan.h                |    1 -
 drivers/net/wireless/ath5k/base.c           |   25 +-
 drivers/net/wireless/ath5k/hw.c             |    6 +-
 drivers/net/wireless/atmel.c                |   46 +-
 drivers/net/wireless/b43/b43.h              |   16 -
 drivers/net/wireless/b43/lo.c               |    4 +-
 drivers/net/wireless/b43/main.c             |   16 +-
 drivers/net/wireless/b43/nphy.c             |    2 -
 drivers/net/wireless/b43/phy.c              |   51 +-
 drivers/net/wireless/b43/xmit.c             |    5 +-
 drivers/net/wireless/b43legacy/b43legacy.h  |   17 -
 drivers/net/wireless/b43legacy/main.c       |   15 +-
 drivers/net/wireless/b43legacy/phy.c        |   14 +-
 drivers/net/wireless/b43legacy/radio.c      |   12 +-
 drivers/net/wireless/b43legacy/xmit.c       |    4 +-
 drivers/net/wireless/iwlwifi/Kconfig        |    4 +-
 drivers/net/wireless/iwlwifi/Makefile       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   18 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h  |   10 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |   36 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |  661 +++++-----------
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   51 ++-
 drivers/net/wireless/iwlwifi/iwl-commands.h |   48 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c     |  220 +++++-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   45 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h    |   22 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |   44 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |  101 ++--
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |  422 ++++++++++
 drivers/net/wireless/iwlwifi/iwl-sta.c      |   61 ++-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |  373 +++++++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   58 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c | 1135 +++++++--------------------
 drivers/net/wireless/libertas/cmd.c         |   32 -
 drivers/net/wireless/libertas/cmd.h         |    1 -
 drivers/net/wireless/libertas/main.c        |   12 +-
 drivers/net/wireless/p54/p54common.c        |    7 +-
 drivers/net/wireless/rt2x00/rt2400pci.c     |    5 +-
 drivers/net/wireless/rt2x00/rt2500pci.c     |    6 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |    6 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    4 +-
 drivers/net/wireless/rt2x00/rt61pci.c       |    5 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    5 +-
 drivers/net/wireless/rtl8180_dev.c          |    9 +-
 drivers/net/wireless/rtl8187_dev.c          |   10 +-
 drivers/net/wireless/zd1211rw/zd_mac.c      |   29 +-
 include/linux/ieee80211.h                   |   32 +-
 include/net/mac80211.h                      |   47 +-
 net/ieee80211/ieee80211_rx.c                |    2 +-
 net/mac80211/cfg.c                          |    2 +
 net/mac80211/debugfs_sta.c                  |   17 +-
 net/mac80211/ieee80211_i.h                  |    6 +-
 net/mac80211/iface.c                        |    3 +-
 net/mac80211/key.c                          |    4 +-
 net/mac80211/main.c                         |   41 +-
 net/mac80211/mesh_hwmp.c                    |    2 +-
 net/mac80211/mesh_plink.c                   |   88 +-
 net/mac80211/mlme.c                         |   71 +-
 net/mac80211/rx.c                           |  214 ++++--
 net/mac80211/sta_info.c                     |   14 +-
 net/mac80211/sta_info.h                     |   74 ++-
 net/mac80211/tkip.c                         |  145 ++---
 net/mac80211/tx.c                           |   30 +-
 net/mac80211/wext.c                         |   28 +-
 net/wireless/core.c                         |   33 +-
 net/wireless/radiotap.c                     |   16 +-
 71 files changed, 2529 insertions(+), 2126 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-rx.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-tx.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-05-14.patch.gz

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
