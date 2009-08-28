From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-08-28
Date: Fri, 28 Aug 2009 15:11:19 -0400
Message-ID: <20090828191119.GD32694@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another huge batch of updates/changes/etc intended for 2.6.32...  This
includes the usual driver updates and miscellaneous fixes, etc.
Highlights in this batch include more LP-PHY support for b43 and the
completion of the cfg80211 API conversion for rndis_wlan.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 7c6a3ed5bd61ec981c8a0d0111cfd435adf3=
f2b7:
  Ursula Braun (1):
        qeth: display "undefined" value of sysfs-attribute "layer2"

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (1):
      iwlwifi: fix remove key error

Arnd Hannemann (2):
      mac80211: Remove unnused throughput field from minstrel_rate.
      mac80211: Fix output of minstrels rc_stats

Bob Copeland (4):
      ath5k: clean up filter flags setting
      ath5k: use the skb->cb directly for RX status
      ath5k: add hardware CCMP encyption support
      ath5k: clarify srev comparison for CCMP check

Christian Lamparter (1):
      p54: fix broadcast buffering in AP mode

Dan Williams (1):
      libertas: clean up and clarify get_common_rates

Daniel C Halperin (2):
      iwlwifi: clear rate control flags on non-HT packet
      iwlwifi: set HT flags in ieee80211_rx_status for received packets

G=E1bor Stefanik (8):
      iwlwifi: Make injection of non-broadcast frames work again
      b43: LP-PHY: Fix a few typos in the RC calibration code
      b43: LP-PHY: Fix and simplify Qdiv roundup
      b43: Fix and update LP-PHY code
      ssb: Implement PMU LDO control and use it in b43
      b43: LP-PHY: Revert to the original PHY register write routine
      b43: Enable LP-PHY support by default and remove Kconfig warning
      b43: Implement antenna diversity support for LP-PHY

Herton Ronaldo Krzesinski (2):
      rtl8187: fix circular locking (rtl8187_stop/rtl8187_work)
      rtl8187: Implement rfkill support

Ivo van Doorn (1):
      rt2x00: Cleanup rt2x00mac_bss_info_changed()

Jaswinder Singh Rajput (1):
      PRISM54: fix compilation warning

Javier Cardona (2):
      mac80211: Update mesh config IE to 11s draft 3.02
      ath9k: Add support FIF_OTHER_BSS filtering mode.

Joerg Albert (2):
      ar9170: cleanup of bss_info_changed and beacon config
      ar9170: remove unnecessary call to ar9170_set_beacon_timers

Johannes Berg (8):
      mac80211: fix configure_filter invocation after stop
      cfg80211: check lost scans later, fix bug
      cfg80211: make spurious warnings less likely, configurable
      cfg80211: clean up properly on interface type change
      mac80211: remove tasklet enable/disable
      mac80211: fix RX skb leaks
      mac80211: fix scan cancel on ifdown
      iwlwifi: fix ICT irq table endianness

John W. Linville (3):
      libipw: switch from ieee80211_* to libipw_* naming policy
      mac80211: remove ieee80211_rx namespace hack
      libipw: initiate cfg80211 API conversion

Jouni Malinen (1):
      mac80211: Check pending scan request after having processed mgd w=
ork

Jussi Kivilinna (20):
      rndis_wlan: fix broken logic in add_wep_key()
      rndis_wlan: set cipher suites for cfg80211
      rndis_wlan: ignore OID_802_11_ADD_KEY triggered media connect ind=
ications
      rndis_wlan: get bssid scan list before new scan
      rndis_wlan: resize bssid list if too small
      rndis_wlan: increase scan timer delay
      rndis_wlan: move link up/down work to separate functions
      rndis_wlan: use is_zero_ether_addr() and is_broadcast_ether_addr(=
)
      rndis_wlan: set ieee80211_ptr->iftype in rndis_change_virtual_int=
f
      rndis_wlan: enable infrastructure before setting random essid
      rndis_wlan: add cfg80211 connect, disconnect, join_ibss and leave=
_ibss
      rndis_wlan: add cfg80211 set_channel
      rndis_wlan: add cfg80211 key handling
      rndis_wlan: add cfg80211 get_station
      rndis_wlan: add cfg80211 dump_station
      rndis_wlan: rename wireless stats worker to device poller
      rndis_wlan: remove unneeded SIOCSIWCOMMIT
      rndis_wlan: convert mic failure wireless event to cfg80211
      rndis_wlan: disable IWEVPMKIDCAND wireless event
      rndis_wlan: use cfg80211_wext_handler

Kiran Divekar (1):
      libertas: add NULL check on return value of get_zeroed_page

Lennert Buytenhek (4):
      mwl8k: fix inverted error test in mwl8k_bss_info_changed()
      mwl8k: fix pci dma mapping leak in mwl8k_post_cmd() error path
      mwl8k: missing endian conversion when printing firmware command r=
esult
      mwl8k: separate driver and device info reporting during probe

Marcos Chaparro (1):
      ath5k: add led pin configuration for compaq c700 laptop

Marek Vasut (1):
      libertas: Add support for Marvell Libertas CF8305

Pavel Roskin (2):
      ath5k: fix uninitialized value use in ath5k_eeprom_read_turbo_mod=
es()
      ath5k: don't use PCI ID to find the chip revision

Reinette Chatre (2):
      ipw2x00: update contact information
      MAINTAINERS: Update ipw2x00 and iwlwifi entries

Roel Kluin (3):
      libertas: Read buffer overflow
      nl80211: jump to out_err upon unsupported iftype
      ath9k: Fix read buffer overflow

Sujith (6):
      ath9k: Fix chainmask selection during scanning
      ath9k: Reduce the frequency of PA offset calibration
      ath9k: Fix bugs in programming registers during PA CAL
      ath9k: Handle PA cal usage properly
      ath9k: Update INITVALs for AR9285
      ath9k: Wrap DMA dump function with PS wakeup/restore

Vasanthakumar Thiagarajan (8):
      ath9k: Split ath9k_hw_btcoex_enable() into two logical pieces
      ath9k: Move btcoex stuff from hw.[ch] to new btcoex.[ch]
      ath9k: Configure btcoex register during every reset
      ath9k: Move btcoex related data to a separate struct
      ath9k: Determine btcoex scheme type based on chip version
      ath9k: Remove hw capability bit meant for btcoex
      ath9k: Add infrastructure for generic hw timers
      ath9k: Add Bluetooth Coexistence 3-wire support

Wey-Yi Guy (9):
      iwlwifi: set default tx power user limit to minimal
      iwlwifi: do not allow set tx power over channel power limit
      iwlwifi: name changes from "tx_power_channel_lmt" to "tx_power_de=
vice_lmt"
      iwlwifi: error checking for setting tx_power in sysfs
      iwlwifi: change IWL6000_UCODE_API_MAX to v4
      iwlwifi: show current tx power
      iwlwifi: remove duplicated define
      iwlwifi: read enhanced tx power info from EEPROM image
      iwlwifi: fix unloading driver while scanning

 MAINTAINERS                                        |   14 +-
 drivers/net/wireless/ath/ar9170/ar9170.h           |    1 +
 drivers/net/wireless/ath/ar9170/mac.c              |   24 +-
 drivers/net/wireless/ath/ar9170/main.c             |   20 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |    4 +-
 drivers/net/wireless/ath/ath5k/attach.c            |   21 +-
 drivers/net/wireless/ath/ath5k/base.c              |  121 +-
 drivers/net/wireless/ath/ath5k/eeprom.c            |   29 +-
 drivers/net/wireless/ath/ath5k/led.c               |    2 +
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    5 +
 drivers/net/wireless/ath/ath9k/btcoex.c            |  319 +++++
 drivers/net/wireless/ath/ath9k/btcoex.h            |   98 ++
 drivers/net/wireless/ath/ath9k/calib.c             |   35 +-
 drivers/net/wireless/ath/ath9k/calib.h             |    7 +
 drivers/net/wireless/ath/ath9k/debug.c             |    4 +
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |   16 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  239 +++-
 drivers/net/wireless/ath/ath9k/hw.h                |   58 +-
 drivers/net/wireless/ath/ath9k/initvals.h          |   10 +-
 drivers/net/wireless/ath/ath9k/main.c              |   40 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    7 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   64 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    9 +-
 drivers/net/wireless/b43/Kconfig                   |    4 +-
 drivers/net/wireless/b43/main.c                    |    3 +-
 drivers/net/wireless/b43/phy_a.c                   |    2 +-
 drivers/net/wireless/b43/phy_common.c              |   27 +-
 drivers/net/wireless/b43/phy_common.h              |   13 +-
 drivers/net/wireless/b43/phy_g.c                   |    2 +-
 drivers/net/wireless/b43/phy_lp.c                  |  129 +-
 drivers/net/wireless/b43/phy_lp.h                  |    3 +
 drivers/net/wireless/b43/tables_lpphy.c            |   79 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |  206 ++--
 drivers/net/wireless/ipw2x00/ipw2100.h             |   16 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             | 1043 ++++++++----=
---
 drivers/net/wireless/ipw2x00/ipw2200.h             |   16 +-
 .../net/wireless/ipw2x00/{ieee80211.h =3D> libipw.h} |  666 +++++-----
 drivers/net/wireless/ipw2x00/libipw_geo.c          |   82 +-
 drivers/net/wireless/ipw2x00/libipw_module.c       |  124 ++-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |  403 +++---
 drivers/net/wireless/ipw2x00/libipw_tx.c           |   70 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c           |   94 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    5 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   15 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   19 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   55 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   54 +
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  252 ++++
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   80 ++-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   10 +
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   10 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |    9 +-
 drivers/net/wireless/libertas/assoc.c              |   57 +-
 drivers/net/wireless/libertas/debugfs.c            |   28 +
 drivers/net/wireless/libertas/if_cs.c              |   39 +-
 drivers/net/wireless/mwl8k.c                       |   30 +-
 drivers/net/wireless/p54/txrx.c                    |    3 +
 drivers/net/wireless/prism54/islpci_eth.c          |    4 +-
 drivers/net/wireless/rndis_wlan.c                  | 1411 +++++++++---=
--------
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    8 -
 drivers/net/wireless/rtl818x/Makefile              |    2 +-
 drivers/net/wireless/rtl818x/rtl8187.h             |    1 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c         |   31 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c        |    4 +-
 drivers/net/wireless/rtl818x/rtl8187_rfkill.c      |   63 +
 drivers/net/wireless/rtl818x/rtl8187_rfkill.h      |    8 +
 drivers/net/wireless/rtl818x/rtl818x.h             |    5 +-
 drivers/ssb/driver_chipcommon_pmu.c                |   94 ++
 include/linux/ieee80211.h                          |    2 +-
 include/linux/ssb/ssb_driver_chipcommon.h          |   10 +
 include/net/iw_handler.h                           |    6 +-
 include/net/mac80211.h                             |   11 +-
 net/mac80211/driver-ops.h                          |   14 +-
 net/mac80211/ieee80211_i.h                         |    8 +
 net/mac80211/iface.c                               |   41 +-
 net/mac80211/main.c                                |    2 -
 net/mac80211/mesh.c                                |   49 +-
 net/mac80211/mlme.c                                |   28 +-
 net/mac80211/pm.c                                  |   13 +-
 net/mac80211/rc80211_minstrel.h                    |    1 -
 net/mac80211/rc80211_minstrel_debugfs.c            |    2 +-
 net/mac80211/rx.c                                  |   39 +-
 net/mac80211/scan.c                                |    9 +-
 net/mac80211/util.c                                |   10 +
 net/wireless/Kconfig                               |   17 +
 net/wireless/core.c                                |   58 +-
 net/wireless/core.h                                |   17 +-
 net/wireless/ibss.c                                |    4 +-
 net/wireless/nl80211.c                             |   18 +-
 net/wireless/scan.c                                |   21 +-
 net/wireless/sme.c                                 |   12 +-
 net/wireless/util.c                                |  108 ++
 net/wireless/wext-compat.c                         |   16 +-
 100 files changed, 4299 insertions(+), 2659 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/btcoex.c
 create mode 100644 drivers/net/wireless/ath/ath9k/btcoex.h
 rename drivers/net/wireless/ipw2x00/{ieee80211.h =3D> libipw.h} (54%)
 create mode 100644 drivers/net/wireless/rtl818x/rtl8187_rfkill.c
 create mode 100644 drivers/net/wireless/rtl818x/rtl8187_rfkill.h

Omnibus patch available here:

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
