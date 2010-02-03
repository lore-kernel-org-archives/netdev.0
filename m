From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-02-03
Date: Wed, 3 Feb 2010 16:19:01 -0500
Message-ID: <20100203211900.GJ2882@tuxdriver.com>
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

Another huge batch of updates intended for 2.6.34, mostly the usual bit=
s
by the usual suspects.  This batch does contain a number of mac80211
fixes that (presumably) originated in OpenWRT and a number of steps
toward N-phy support in b43, along with the usual driver updates from
Intel, Atheros, and many others.  And, of course, Johannes makes his
usual strong showing. :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 730dd70549e0ec755dd55615ba5cfc38a482=
a947:
  Rafa=C5=82 Mi=C5=82ecki (1):
        b43: N-PHY: drop unused definition, uncomment needed call

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (3):
      iwlwifi: disable tx on beacon update notification
      cfg80211: fix channel setting for wext
      iwlwifi: enable DC calibration

Andriy Tkachuk (3):
      mac80211: Account HT Control field in Data frame hdrlen according=
 to 802.11n-2009
      lib80211: Cosmetics - make room for MIC/CRC near the actual calcu=
lation
      lib80211: Introduce TKIP_HDR_LEN define for code clarity

Benoit Papillault (3):
      mac80211: check that ieee80211_set_power_mgmt only handles STA in=
terfaces.
      mac80211: removed useless code in IBSS management
      mac80211: Fixed a bug in IBSS merge

Bob Copeland (4):
      mac80211: fix sign error in pid controller
      mac80211: pid: replace open-coded msecs_to_jiffies
      ath5k: dont use external sleep clock in AP mode
      ath5k: fix setup for CAB queue

Christian Lamparter (4):
      p54pci: rx frame length check
      p54pci: handle dma mapping errors
      p54pci: move tx cleanup into tasklet
      p54pci: revise tx locking

Dan Carpenter (1):
      iwlwifi: silence buffer overflow warning

Daniel Halperin (2):
      iwlwifi: fix throughput degradation in aggregation mode
      iwlwifi: optimize power saving

=46elix Fietkau (10):
      mac80211: add missing sanity checks for action frames
      mac80211: fix queue selection for data frames on monitor interfac=
es
      mac80211: fix WMM AC default for non-QoS data frames
      ath9k: fix RTS/CTS handling
      mac80211: fix rx data handling for non-data frames on multiple vi=
fs
      ath9k: improve max rate retry handling
      mac80211: fix WARN_ON in the new work code
      mac80211: fix sta lookup for received action frames on an AP VLAN
      mac80211: fix monitor mode tx radiotap header handling
      mac80211: fix sta lookup with AP VLAN interfaces and injected fra=
mes

Hamish Guthrie (3):
      ps3_gelic_wireless: Remove PS3 gelic legacy wpa support
      ps3_gelic_wireless: fix directed ssid scan
      ps3_gelic_wireless: Remove superfluous debug info

Henry Zhangh (1):
      iwlwifi: Fix A band scanning when associated

Hin-Tak Leung (1):
      zd1211rw: adding 0409:0248 to supported device list

Johannes Berg (27):
      mac80211: fix endian error
      cfg80211: fix refcount imbalance when wext is disabled
      mac80211: move and rename misc tx handler
      mac80211: clear TX control on filtered frames
      mac80211: remove useless setting of IEEE80211_TX_INTFL_DONT_ENCRY=
PT
      mac80211: move control.hw_key assignment
      mac80211: re-enable re-transmission of filtered frames
      cfg80211: rcu-ify rdev and wdev
      mac80211: pass vif and station to update_tkip_key
      cfg80211: export multiple MAC addresses in sysfs
      mac80211: add missing key check
      iwlwifi: is no longer experimental
      iwlwifi: reorder device setup
      iwlwifi: clean up debugfs code
      iwlwifi: fix sparse warning
      iwlwifi: check endianness annotations by default
      mac80211: fix sw crypto
      mac80211: track work started through callbacks
      mac80211: fill jiffies/vif on filtered frames
      cfg80211: export cfg80211_find_ie
      mac80211: wait for beacon before enabling powersave
      iwlwifi: fix locking in iwl_mac_add_interface
      iwlwifi: no need to test iw_mode in power saving
      iwlagn: simplify ucode loading
      iwlwifi: remove bg_up work
      iwlwifi: remove unused work structs
      iwlwifi: fix typo in IWL_CCK_RATES_MASK

John W. Linville (7):
      Merge git://git.kernel.org/.../linville/wireless-2.6
      libertas/assoc.c: rearrange some strange line breaks
      mac80211: avoid NULL ptr deref when using WEP
      libertas: add comment re: v10 firmware key handling
      rtl8180: implement get_tsf op for mac80211
      cfg80211: fix wext-compat for setting rate to 'auto'
      ps3_gelic_wireless: fix format warning

Jouni Malinen (1):
      nl80211: Allow association to change channels during reassociatio=
n

Kalle Valo (2):
      mac80211: fix tx select key null pointer crash with hostapd
      mac80211: fix update_tkip_key() documentation about the context

Larry Finger (2):
      b43: N PHY: Fix compilation after removal of typdef b43_c32
      rtl8187: Add callback for get_tsf

Lennert Buytenhek (1):
      mac80211: fix queue selection for packets injected via monitor in=
terface

Luca Verdesca (1):
      ath5k: adding LED support for AR5BXB63 cards

Luis R. Rodriguez (4):
      ath9k: make tx power config changes take effect immediatley
      cfg80211: avoid flushing the global workqueue for core reg hints
      cfg80211: add regulatory hint disconnect support
      ath9k: add support for 802.11n bonded out AR2427

Michael Buesch (1):
      b43: Workaround circular locking in hw-tkip key update callback

Pavel Roskin (5):
      ath: make gcc check format arguments of ath_print(), fix all misu=
ses
      ath9k: allocate string buffer in read_file_dma() by kmalloc()
      mac80211: reduce stack usage in sta_ht_capa_read()
      mac80211: reduce stack usage in sta_agg_status_read()
      ath9k: fix access to freed data on unload

Rafa=C5=82 Mi=C5=82ecki (28):
      b43: N-PHY: implement RX PHY cleanup and setup
      b43: N-PHY: implement TX PHY cleanup and setup
      b43: N-PHY: implement MIMO config update
      b43: N-PHY: implement stopping playback
      b43: N-PHY: implement chain selection
      b43: N-PHY: move RF sequence declarations top, add missing calls
      b43: N-PHY: store seq mode for proper restoring (follow specs)
      b43: N-PHY: add writing one element tables
      b43: N-PHY: implement and add multi-dimensional table writing
      b43: N-PHY: implement and add reading one element tables
      b43: N-PHY: implement and add multi-dimensional table reading
      b43: N-PHY: silence warnings, add missing call
      b43: check band width
      b43: N-PHY: implement overriding RF control
      b43: N-PHY: add running samples
      b43: N-PHY: add setting power amplifier filters
      b43: N-PHY: add TX tone
      b43: N-PHY: fix one bit off in parsing RF Ctrl Override arguments
      b43: make cordic common (LP-PHY and N-PHY need it)
      b43: update cordic code to match current specs
      b43: N-PHY: use cordic to generate samples
      b43: N-PHY: update general workarounds
      b43: N-PHY: add workarounds for gain control
      b43: N-PHY: split RSSI selection into two per-PHY-revision functi=
ons
      b43: N-PHY: add RSSI selection for newer PHYs
      b43: N-PHY: fix Cal TX IQ LO for newer PHYs
      b43: N-PHY: add TX radio setup for newer PHYs
      b43: N-PHY: implement setting RF sequence

Reinette Chatre (6):
      iwlwifi: add license to tracing files
      iwlwifi: update copyright year to 2010
      iwlwifi: cleanup station adding code
      iwlwifi: make broadcast station addition generic
      iwlwifi: cleanup spectrum measurement command support
      iwlwifi: iwl_power_update_mode always hold mutex

Samuel Ortiz (2):
      iwmc3200wifi: Add UMAC wifi headers to the pmkid command
      libertas: Set/clear WPA keys before the WEP ones

Stanislaw Gruszka (1):
      airo: fix setting zero length WEP key

Trieu 'Andrew' Nguyen (1):
      iwlwifi: Tune radio to prevent unexpected behavior

Vasanthakumar (1):
      mac80211: Don't call rate control when HW handles it

Vasanthakumar Thiagarajan (1):
      ath9k: Fix wifi disconnection when collocated bt scan is active

Vivek Natarajan (1):
      ath9k: Handle full sleep in ps_restore.

Wey-Yi Guy (18):
      iwlwifi: Fix throughput stall issue in HT mode for 5000
      iwlwifi: fix clear statistics counter command
      iwlwifi: format and show statistics counter from uCode
      iwlwifi: add num_of_sos_stats to statistics counter
      iwlwifi: correct return code for log_event
      iwlwifi: set interrupt coalescing timer range and default
      iwlwifi: software w/a for h/w bug cause Rx bit get clear
      iwlwifi: display flowhandler register when sw error or on-demand
      iwlwifi: remove extra statistics request from debugfs
      iwlwifi: configure missed beacon threshold
      iwlwifi: add function to reset/tune radio if needed
      iwlwifi: Logic to control how frequent radio should be reset if n=
eeded
      iwlwifi: bit field description for BT Config command
      iwlwifi: module parameter to enable/disable bt co-exist
      iwlwifi: sysassert identifier change
      iwlwifi: update sensitivity calibration data for 6x00 series
      iwlwifi: update sensitivity calibration data for 5x00 series
      iwlwifi: update sensitivity calibration data for 1000 series

Zhu Yi (1):
      iwlwifi: fix iwl_queue_used bug when read_ptr =3D=3D write_ptr

 arch/powerpc/configs/ppc64_defconfig         |    1 -
 arch/powerpc/configs/ps3_defconfig           |    1 -
 drivers/net/Kconfig                          |   14 -
 drivers/net/ps3_gelic_wireless.c             |  149 +---
 drivers/net/wireless/airo.c                  |   34 +-
 drivers/net/wireless/ath/ath.h               |    1 -
 drivers/net/wireless/ath/ath5k/ath5k.h       |    2 +-
 drivers/net/wireless/ath/ath5k/base.c        |   22 +-
 drivers/net/wireless/ath/ath5k/led.c         |    2 +
 drivers/net/wireless/ath/ath5k/qcu.c         |    5 +-
 drivers/net/wireless/ath/ath5k/reset.c       |    5 +-
 drivers/net/wireless/ath/ath9k/ahb.c         |   12 +-
 drivers/net/wireless/ath/ath9k/ath9k.h       |    8 +-
 drivers/net/wireless/ath/ath9k/btcoex.h      |    2 +
 drivers/net/wireless/ath/ath9k/debug.c       |   43 +-
 drivers/net/wireless/ath/ath9k/gpio.c        |   30 +-
 drivers/net/wireless/ath/ath9k/hw.c          |    7 +-
 drivers/net/wireless/ath/ath9k/hw.h          |    1 +
 drivers/net/wireless/ath/ath9k/init.c        |    7 +-
 drivers/net/wireless/ath/ath9k/main.c        |   18 +-
 drivers/net/wireless/ath/ath9k/pci.c         |   19 +-
 drivers/net/wireless/ath/ath9k/rc.c          |   12 +-
 drivers/net/wireless/ath/ath9k/recv.c        |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h         |    6 +-
 drivers/net/wireless/ath/ath9k/xmit.c        |   39 +-
 drivers/net/wireless/ath/debug.h             |    8 +-
 drivers/net/wireless/b43/main.c              |   28 +-
 drivers/net/wireless/b43/phy_common.c        |   45 +
 drivers/net/wireless/b43/phy_common.h        |   10 +
 drivers/net/wireless/b43/phy_lp.c            |   52 +-
 drivers/net/wireless/b43/phy_n.c             | 1264 ++++++++++++++++++=
+++-----
 drivers/net/wireless/b43/phy_n.h             |    7 +
 drivers/net/wireless/b43/tables_nphy.c       |  167 ++++
 drivers/net/wireless/b43/tables_nphy.h       |   27 +
 drivers/net/wireless/iwlwifi/Kconfig         |   14 +-
 drivers/net/wireless/iwlwifi/Makefile        |    3 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c      |   78 ++-
 drivers/net/wireless/iwlwifi/iwl-3945-fh.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |   11 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |   84 +-
 drivers/net/wireless/iwlwifi/iwl-6000-hw.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |   28 +-
 drivers/net/wireless/iwlwifi/iwl-agn-led.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-led.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |   86 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-calib.h     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   54 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |  194 ++++-
 drivers/net/wireless/iwlwifi/iwl-core.h      |   25 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h     |   62 +--
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   | 1267 +++++++++++++++---=
--------
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   48 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c  |   26 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h  |   26 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h        |   23 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-io.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-power.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |  104 ++-
 drivers/net/wireless/iwlwifi/iwl-scan.c      |  192 ++++-
 drivers/net/wireless/iwlwifi/iwl-spectrum.c  |  198 ----
 drivers/net/wireless/iwlwifi/iwl-spectrum.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c       |  150 ++-
 drivers/net/wireless/iwlwifi/iwl-sta.h       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |   57 +-
 drivers/net/wireless/iwmc3200wifi/commands.c |    4 +
 drivers/net/wireless/iwmc3200wifi/commands.h |    1 +
 drivers/net/wireless/libertas/assoc.c        |   78 +-
 drivers/net/wireless/mac80211_hwsim.c        |    8 +-
 drivers/net/wireless/mwl8k.c                 |   14 +-
 drivers/net/wireless/p54/p54pci.c            |   82 +-
 drivers/net/wireless/p54/p54pci.h            |    6 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c   |    9 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c   |   11 +-
 drivers/net/wireless/wl12xx/wl1251.h         |    3 -
 drivers/net/wireless/wl12xx/wl1251_main.c    |   25 +-
 drivers/net/wireless/zd1211rw/zd_usb.c       |    1 +
 include/linux/ieee80211.h                    |    2 +
 include/net/cfg80211.h                       |   38 +-
 include/net/mac80211.h                       |   22 +-
 include/net/regulatory.h                     |    1 +
 net/mac80211/cfg.c                           |    3 +
 net/mac80211/debugfs_sta.c                   |   26 +-
 net/mac80211/driver-ops.h                    |   14 +-
 net/mac80211/driver-trace.h                  |   15 +-
 net/mac80211/ibss.c                          |   22 +-
 net/mac80211/ieee80211_i.h                   |    1 -
 net/mac80211/iface.c                         |   12 +-
 net/mac80211/mlme.c                          |   31 +-
 net/mac80211/rate.h                          |    4 +
 net/mac80211/rc80211_pid_algo.c              |   10 +-
 net/mac80211/rx.c                            |   49 +-
 net/mac80211/scan.c                          |    4 -
 net/mac80211/status.c                        |   35 +-
 net/mac80211/tkip.c                          |   23 +-
 net/mac80211/tx.c                            |   50 +-
 net/mac80211/wep.c                           |   17 +-
 net/mac80211/work.c                          |   19 +-
 net/mac80211/wpa.c                           |   57 +-
 net/wireless/core.c                          |   42 +-
 net/wireless/core.h                          |    3 +-
 net/wireless/lib80211_crypt_ccmp.c           |    2 +-
 net/wireless/lib80211_crypt_tkip.c           |   23 +-
 net/wireless/nl80211.c                       |    4 +-
 net/wireless/reg.c                           |  161 ++++-
 net/wireless/reg.h                           |   18 +
 net/wireless/scan.c                          |   38 +-
 net/wireless/sme.c                           |   41 +
 net/wireless/sysfs.c                         |   20 +
 net/wireless/util.c                          |    5 +-
 net/wireless/wext-compat.c                   |    2 +-
 131 files changed, 3887 insertions(+), 2045 deletions(-)
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-spectrum.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-02-03.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
