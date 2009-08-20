From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-08-20
Date: Thu, 20 Aug 2009 13:26:11 -0400
Message-ID: <20090820172611.GE2657@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

The relentless march of wireless patches for 2.6.32 continues...  In
this batch, further implementation of the LP-PHY support for b43 along
with the usual batches of driver updates and the like -- iwlwifi, ath9k=
,
rt2x00, mwl8k, and others.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 1758c0947605211ef953cc91d6bbdf847a21=
b822:
  Oliver Hartkopp (1):
        can: Use WARN_ONCE() instead of BUG_ON() for sanity check in re=
ceive path

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Andrey Yurovsky (1):
      libertas: don't use dynamic-sized array

Benoit PAPILLAULT (1):
      rt2x00: Add support for retry rates

Bob Copeland (2):
      wl1251: correct definitions for 0th bit defines
      wl1251: halt the embedded CPU before loading firmware

Christian Lamparter (2):
      p54: disable PS by default
      ar9170: refactor configure_filter

Daniel C Halperin (7):
      iwlwifi: remove unused HT configuration entry tx_chan_width
      iwlwifi: include HT configuration when adding stations through rs=
_rate_init
      iwlwifi: refactor packet reception code
      iwlwifi: configure HT40 channels in iwl_mac_config
      iwlwifi: check short GI support per-station rather than globally
      iwlwifi: use station HT capabilities and BSS operating mode for G=
reen-field
      iwlwifi: fix erroneous use of iwl_rx_packet.len as a length

Daniel Walker (1):
      mac80211: New stat counters for multicast and unicast forwarded f=
rames

David Kilroy (2):
      cfg80211: fix leaks of wdev->conn->ie
      orinoco: remove spare whitespace

G=E1bor Stefanik (21):
      b43: Update dummy transmission to match V4 specs
      b43: LP-PHY: Initialize TX power control
      b43: LP-PHY: Implement channel switching for rev2+/B2063 radio
      b43: LP-PHY: Implement channel switching for rev0/1/B2062 radio
      ssb: Fix typo in the rev8 SPROM extraction routine
      b43: Add LP-PHY firmware loading support
      b43: Make LP-PHY testable
      b43: LP-PHY: Don't adjust gain table for rev2+ when setting chann=
el
      b43: LP-PHY: Update TX gain override for a spec typo fix
      b43: LP-PHY: Fix another TX power control abuse
      b43: Handle B43_PHYTYPE_LP in RX path
      b43: LP-PHY: Update baseband init for recent spec changes
      b43: LP-PHY: Fix a spec error in the B2062 channel switch routine
      b43: LP-PHY: Update code for spec fixes, and fix a few typos
      b43: LP-PHY: Fix a bug in the B2062 channel tune path
      b43: LP-PHY: Update B2062 radio init with recent spec changes
      b43: LP-PHY: Remove BROKEN from B43_PHY_LP
      b43: LP-PHY: Fix reading old mode in the set TX power control rou=
tine
      b43: LP-PHY: Fix setting TX power control mode during RC calibrat=
ion
      b43: LP-PHY: Two small spec updates
      b43: LP-PHY: Implement spec updates and remove resolved FIXMEs

Ivo van Doorn (8):
      rt2x00: Fix RFKILL polling
      rt2x00: Fix for rt2800usb for SHARED_KEY_TABLE initializations
      rt2x00: Add new RF chip defines
      rt2x00: Set SKBDESC_L2_PADDED in RX path
      rt2x00: wireless CLI ID and packet ID must not be 0
      rt2x00: Fix MCS register intialization
      rt2x00: configure_filter() callback is allowed to sleep
      rt2x00: bss_info_changed() callback is allowed to sleep

Javier Cardona (1):
      mac80211: Decouple fail_avg stats used by mesh from rate control =
algorithm.

Johannes Berg (8):
      iwlwifi: remove unused members of iwl_ht_info
      iwlwifi: disable PS by default
      cfg80211: fix deadlock
      cfg80211: report userspace SME connected event properly
      mac80211: allow configure_filter callback to sleep
      mac80211: remove deprecated API
      cfg80211: fix dangling scan request checking
      mac80211: fix register_hw error path

John W. Linville (2):
      rc80211_pid_algo.c: remove unused variable declaration
      wl1271: remove print_mac usage

Jussi Kivilinna (1):
      cfg80211: export cfg80211_wext_siwfreq

Lennert Buytenhek (29):
      mwl8k: remove various unused struct members and defines
      mwl8k: s/IEEE80211_ADDR_LEN/ETH_ALEN/g
      mwl8k: sort firmware command list by opcode, and trim unused comm=
ands
      mwl8k: various coding style cleanups
      mwl8k: remove MWL8K_RADIO_* defines
      mwl8k: remove MWL8K_RADIO_*_PREAMBLE defines
      mwl8k: remove MWL8K_WMM_* defines
      mwl8k: remove MWL8K_*_SLOTTIME defines
      mwl8k: fix mwl8k_configure_filter() parameter lifetime issue
      mwl8k: ->add_interface() is not called for monitor interfaces
      mwl8k: dma header manipulations can't fail
      mwl8k: don't touch 'command done' interrupt during firmware load
      mwl8k: don't hardcode the number of transmit queues
      mwl8k: no need to hold ->tx_lock while setting the hardware inter=
rupt mask
      mwl8k: implement idle mode
      mwl8k: mwl8k_txq_xmit() rework
      mwl8k: mwl8k_queue_work() cleanup
      mwl8k: fix firmware command serialisation
      mwl8k: get rid of mwl8k_start() workqueue use
      mwl8k: get rid of mwl8k_stop() workqueue use
      mwl8k: get rid of mwl8k_config() workqueue use
      mwl8k: get rid of mwl8k_bss_info_changed() workqueue use
      mwl8k: get rid of mwl8k_set_rts_threshold() workqueue use
      mwl8k: get rid of mwl8k_conf_tx() workqueue use
      mwl8k: get rid of mwl8k_get_stats() workqueue use
      mwl8k: get rid of mwl8k_configure_filter() workqueue use
      mwl8k: remove mwl8k_queue_work()
      mwl8k: update copyright and version number
      MAINTAINERS: add information for mwl8k wireless driver

Luis R. Rodriguez (1):
      ath: move regulatory info into shared common structure

Reinette Chatre (2):
      iwlwifi: prevent read outside array bounds
      ipw2x00: fix sparse warnings

Sujith (1):
      ath9k: Fix TX poll cancelling

Vasanthakumar Thiagarajan (2):
      ath9k: Fix bug in retrieving average beacon rssi
      ath9k: Nuke struct ath9k_node_stats

Vivek Natarajan (5):
      ath9k: Add open loop power control support for AR9287.
      ath9k: Set AR_WA for AR9287 as it improves consistency in through=
put.
      ath9k: Enable LEDs for AR9287 chipsets.
      ath9k: Fix ref power interpolation logic for AR9287 chipsets.
      ath9k: Updates for AR9287_12 version of chipset.

Wey-Yi Guy (2):
      iwlwifi: traverse linklist to find the valid OTP block
      iwlwifi: add thermal throttling support to 5150

Zhu Yi (2):
      iwlwifi: cleanup HT40 extension channels setup
      cfg80211: allow cfg80211_connect_result with bssid =3D=3D NULL

gregor kowski (1):
      b43: add hardware tkip

 MAINTAINERS                                  |    6 +
 drivers/net/wireless/adm8211.c               |   42 +-
 drivers/net/wireless/at76c50x-usb.c          |   12 +-
 drivers/net/wireless/ath/ar9170/ar9170.h     |   16 +-
 drivers/net/wireless/ath/ar9170/mac.c        |   22 +-
 drivers/net/wireless/ath/ar9170/main.c       |  112 +--
 drivers/net/wireless/ath/ath.h               |   18 +
 drivers/net/wireless/ath/ath5k/ath5k.h       |    3 -
 drivers/net/wireless/ath/ath5k/base.c        |   78 +-
 drivers/net/wireless/ath/ath5k/base.h        |   13 +
 drivers/net/wireless/ath/ath5k/phy.c         |    3 +-
 drivers/net/wireless/ath/ath9k/ani.c         |    6 +-
 drivers/net/wireless/ath/ath9k/ani.h         |   20 +-
 drivers/net/wireless/ath/ath9k/ath9k.h       |   14 +-
 drivers/net/wireless/ath/ath9k/calib.c       |   44 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c   |    8 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c |   28 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c  |   14 +-
 drivers/net/wireless/ath/ath9k/hw.c          |   81 +-
 drivers/net/wireless/ath/ath9k/hw.h          |    2 +-
 drivers/net/wireless/ath/ath9k/main.c        |   52 +-
 drivers/net/wireless/ath/ath9k/pci.c         |    6 +-
 drivers/net/wireless/ath/ath9k/phy.h         |    7 +
 drivers/net/wireless/ath/ath9k/recv.c        |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h         |    9 +-
 drivers/net/wireless/ath/regd.h              |   20 +-
 drivers/net/wireless/b43/Kconfig             |   14 +-
 drivers/net/wireless/b43/dma.c               |    2 +-
 drivers/net/wireless/b43/lo.c                |    2 +-
 drivers/net/wireless/b43/main.c              |  205 +++-
 drivers/net/wireless/b43/main.h              |    2 +-
 drivers/net/wireless/b43/phy_g.c             |    6 +-
 drivers/net/wireless/b43/phy_lp.c            | 1042 ++++++++++++++++--
 drivers/net/wireless/b43/phy_lp.h            |   25 +-
 drivers/net/wireless/b43/pio.c               |    4 +-
 drivers/net/wireless/b43/tables_lpphy.c      |   12 +-
 drivers/net/wireless/b43/wa.c                |    4 +-
 drivers/net/wireless/b43/xmit.c              |   29 +-
 drivers/net/wireless/b43/xmit.h              |    3 +-
 drivers/net/wireless/b43legacy/main.c        |    4 +-
 drivers/net/wireless/ipw2x00/ipw2100.c       |   14 +-
 drivers/net/wireless/ipw2x00/ipw2200.c       |   73 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |   11 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c      |    3 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |    9 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |   25 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |  116 +--
 drivers/net/wireless/iwlwifi/iwl-commands.h  |    3 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |   74 +-
 drivers/net/wireless/iwlwifi/iwl-core.h      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   20 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |  222 +++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h    |   10 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |  207 ++---
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    5 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |    2 +
 drivers/net/wireless/libertas/assoc.c        |    8 +-
 drivers/net/wireless/libertas_tf/main.c      |   37 +-
 drivers/net/wireless/mac80211_hwsim.c        |    4 +-
 drivers/net/wireless/mwl8k.c                 | 1530 ++++++++----------=
--------
 drivers/net/wireless/orinoco/wext.c          |    2 +-
 drivers/net/wireless/p54/main.c              |    8 +-
 drivers/net/wireless/rt2x00/rt2500usb.c      |    1 -
 drivers/net/wireless/rt2x00/rt2800usb.c      |   19 +-
 drivers/net/wireless/rt2x00/rt2800usb.h      |   10 +-
 drivers/net/wireless/rt2x00/rt2x00.h         |    6 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |   40 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      |   25 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h    |    2 +
 drivers/net/wireless/rt2x00/rt73usb.c        |    1 -
 drivers/net/wireless/rtl818x/rtl8180_dev.c   |   11 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c   |   11 +-
 drivers/net/wireless/wl12xx/wl1251_boot.c    |    3 +
 drivers/net/wireless/wl12xx/wl1251_main.c    |    4 +-
 drivers/net/wireless/wl12xx/wl1251_reg.h     |    4 +-
 drivers/net/wireless/wl12xx/wl1271_main.c    |    9 +-
 drivers/net/wireless/zd1211rw/zd_mac.c       |   44 +-
 drivers/ssb/pci.c                            |    2 +-
 include/net/cfg80211.h                       |    2 +
 include/net/mac80211.h                       |   36 +-
 net/mac80211/debugfs_netdev.c                |    6 +
 net/mac80211/driver-ops.h                    |   24 +-
 net/mac80211/driver-trace.h                  |   36 +-
 net/mac80211/ieee80211_i.h                   |    9 +-
 net/mac80211/iface.c                         |   15 +-
 net/mac80211/main.c                          |   32 +-
 net/mac80211/mesh.h                          |    2 +
 net/mac80211/mesh_hwmp.c                     |   21 +
 net/mac80211/rc80211_minstrel.c              |   16 +-
 net/mac80211/rc80211_pid_algo.c              |   16 +-
 net/mac80211/rx.c                            |    8 +-
 net/mac80211/scan.c                          |   16 +-
 net/mac80211/util.c                          |    2 -
 net/wireless/core.c                          |   98 ++-
 net/wireless/core.h                          |    2 +
 net/wireless/mlme.c                          |    9 +
 net/wireless/sme.c                           |   29 +-
 net/wireless/wext-compat.c                   |    1 +
 99 files changed, 2790 insertions(+), 2170 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-08-20.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
