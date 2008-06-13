From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-06-13
Date: Fri, 13 Jun 2008 17:41:14 -0400
Message-ID: <20080613214114.GA1077@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another slew of updates intended for 2.6.27...please let me know if
there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 030352a9c7715780b2c01033ae9afe56249bb7cc:
  David S. Miller (1):
        Merge branch 'davem-next' of master.kernel.org:/.../jgarzik/netdev-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Akinobu Mita (1):
      airo: use simple_read_from_buffer()

Assaf Krauss (2):
      iwlwifi enabling IBSS (Ad-Hoc) mode
      iwlwifi: Fix mode changes (ad-hoc <--> managed)

Emmanuel Grumbach (13):
      iwlwifi: removes the RUN_TIME_CALIB ifdef
      iwlwifi: clean up in setup/cancel deferred work
      iwlwifi: add possibility to disable tx_power calibration
      iwlwifi: remove redundant flags regarding to FAT channel
      iwlwifi: fix bug when moving from 11gn to 11a or 11an to 11g
      iwlwifi: fix resart flow after fw error
      iwlwifi: add bad length check for WEP keys
      iwlwifi: move iwl4965_rf_kill_ct_config to iwl-core.c
      iwlwifi: retfactor get_temperature functions
      iwlwifi: remove dead code iwl4965_calc_db_from_ratio
      iwlwifi: general code clean up
      iwlwifi: remove iwlcore_low_level_notify
      iwlwifi: unify SW rf-kill flow

Ester Kummer (1):
      iwlwifi: adding channels to sysfs

Gertjan van Wingerde (4):
      rt2x00: Cleanup struct skb_frame_desc.
      rt2x00: Centralize RX packet alignment handling in rt2x00lib.
      rt2x00: Fix double usage of skb->cb in USB RX path.
      rt2x00: Rework alignment check.

Harvey Harrison (11):
      mac80211: add helpers for frame control testing
      mac80211: remove ieee80211_get_morefrag
      mac80211: make ieee80211_get_hdrlen_from_skb return unsigned
      mac80211: add utility function to get header length
      mac80211: wpa.c use new access helpers
      mac80211: use new helpers in util.c - ieee80211_get_bssid()
      mac80211: wme.c use new helpers
      mac80211: rx.c use new helpers
      mac80211: tkip.c consolidate tkip IV writing in helper
      mac80211: tkip.c fold ieee80211_gen_rc4key into its one caller
      mac80211: tkip.c use a local struct tkip_ctx in ieee80211_get_tkip_key

Holger Schurig (4):
      libertas: fix interrupt issue
      libertas: document register meanings
      libertas: check for old, unsupported hardware
      libertas: rename some registers to clarify their meaning

Ivo van Doorn (14):
      rt2x00: Calculate register offset during compile time
      rt2x00: Cleanup/optimize set_state() function callback function
      rt2x00: Move led initialization into function
      rt2x00: Remove CTS/RTS check in tx()
      rt2x00: Removed unused descriptor read in txdone
      rt2x00: Make rt2x00_set/get_field macros
      rt2x00: Release rt2x00 2.1.7
      rt2x00: Fix queue initialization
      rt2x00: Implement rt2x00usb_kick_tx_queue()
      rt2x00: Move generic TX frame writing code into rt2x00queue
      rt2x00: Don't kick TX queue after each frame
      rt2x00: Use __builtin_choose_expr() instead of ?:
      rt2x00: Clear IEEE80211_TX_CTL_USE_RTS_CTS flag for RTS frame
      rt2x00: Remove unused defines

Jouni Malinen (4):
      mac80211_hwsim: 802.11 radio simulator for mac80211
      mac80211_hwsim: Clean up documentation
      mac80211_hwsim: Minor cleanup
      mac80211_hwsim: Shared TX code for received frames and Beacons

Jussi Kivilinna (6):
      rndis_wlan: do link-down state change in worker thread
      rndis_wlan: update carrier flag when link state changes
      rndis_wlan: check if set_multicast_list work is already scheduled
      rndis_wlan: cleanup: rename and remove local pointers
      rndis_wlan: use kzalloc to allocate private data
      rndis_wlan: preallocate command buffer for set/get_oid

Michael Buesch (1):
      nl80211: Fix comment merge error

Mohamed Abbas (1):
      iwlwifi: fix resume SW RF-kill

Robert P. J. Day (1):
      rndis_wlan: Use kernel-supplied ARRAY_SIZE() macro.

Ron Rindjunsky (6):
      iwlwifi: removing IWL4965_HT config
      iwlwifi: map sw and hw ampdu queues
      iwlwifi: use ieee80211_conf to examine rate capabilities
      iwlwifi: fix allow iwlwifi to aggregate according to tid load
      mac80211: do not fragment while aggregation is in use
      iwlwifi: remove 4965 prefix from iwl4965_ucode

Tomas Winkler (9):
      iwlwifi: add TX aggregation code for 5000 HW
      iwlwifi: remove unused flag
      iwlwifi: format log prints for easier parsing
      iwlwifi: refactor tx aggregation response flow
      iwlwifi: refactor setting tx power
      iwlwifi: move scan to iwl-scan.c iwlcore
      iwlwifi: move rate helpers to iwlcore
      iwlwifi: cleans up scanning code
      mac80211: fix beacon interval value

Tony Vroon (1):
      mac80211: implement EU regulatory domain

Vladimir Koutny (1):
      mac80211: eliminate IBSS warning in rate_lowest_index()

Zhu Yi (1):
      iwlwifi: fix software rf_kill problem when interface is down

 Documentation/networking/mac80211_hwsim/README     |   67 ++
 .../networking/mac80211_hwsim/hostapd.conf         |   11 +
 .../networking/mac80211_hwsim/wpa_supplicant.conf  |   10 +
 drivers/net/wireless/Kconfig                       |   13 +
 drivers/net/wireless/Makefile                      |    2 +
 drivers/net/wireless/airo.c                        |   15 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   36 -
 drivers/net/wireless/iwlwifi/Makefile              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   36 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |   15 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c         |  103 +--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h         |    2 -
 drivers/net/wireless/iwlwifi/iwl-4965.c            |  388 ++-----
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |  244 +++-
 drivers/net/wireless/iwlwifi/iwl-calib.c           |    4 -
 drivers/net/wireless/iwlwifi/iwl-calib.h           |   29 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   72 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  303 ++++--
 drivers/net/wireless/iwlwifi/iwl-core.h            |   71 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    3 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   10 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |  163 +---
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   31 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |  111 --
 drivers/net/wireless/iwlwifi/iwl-rfkill.c          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.h          |    1 -
 drivers/net/wireless/iwlwifi/iwl-rx.c              |    2 -
 drivers/net/wireless/iwlwifi/iwl-scan.c            |  921 +++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   53 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |   16 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   65 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   40 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c        | 1243 +++-----------------
 drivers/net/wireless/libertas/if_cs.c              |  162 ++-
 drivers/net/wireless/mac80211_hwsim.c              |  514 ++++++++
 drivers/net/wireless/rndis_wlan.c                  |  167 ++--
 drivers/net/wireless/rt2x00/rt2400pci.c            |   95 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    2 -
 drivers/net/wireless/rt2x00/rt2500pci.c            |   91 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    2 -
 drivers/net/wireless/rt2x00/rt2500usb.c            |   98 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |    2 -
 drivers/net/wireless/rt2x00/rt2x00.h               |   13 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   21 +
 drivers/net/wireless/rt2x00/rt2x00lib.h            |    1 +
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   30 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |   72 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   11 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  113 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   27 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |  134 ++-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |  165 +--
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   22 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  111 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    2 -
 drivers/net/wireless/rt2x00/rt73usb.c              |  112 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    2 -
 drivers/net/wireless/rtl8187_dev.c                 |    2 +-
 include/linux/ieee80211.h                          |  407 ++++++-
 include/linux/nl80211.h                            |    8 +-
 include/net/mac80211.h                             |    8 +-
 net/mac80211/ieee80211_i.h                         |    2 +-
 net/mac80211/main.c                                |    3 +-
 net/mac80211/mlme.c                                |   17 +-
 net/mac80211/rx.c                                  |   29 +-
 net/mac80211/tkip.c                                |   85 +-
 net/mac80211/tkip.h                                |    4 +-
 net/mac80211/tx.c                                  |    8 +-
 net/mac80211/util.c                                |   81 +-
 net/mac80211/wme.c                                 |   18 +-
 net/mac80211/wpa.c                                 |   71 +-
 net/wireless/reg.c                                 |   18 +
 74 files changed, 3854 insertions(+), 2972 deletions(-)
 create mode 100644 Documentation/networking/mac80211_hwsim/README
 create mode 100644 Documentation/networking/mac80211_hwsim/hostapd.conf
 create mode 100644 Documentation/networking/mac80211_hwsim/wpa_supplicant.conf
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-scan.c
 create mode 100644 drivers/net/wireless/mac80211_hwsim.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-06-13.patch.bz2
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
