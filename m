From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-07-10
Date: Fri, 10 Jul 2009 15:48:22 -0400
Message-ID: <20090710194822.GH2825@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50219 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbZGJUAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 16:00:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the usual tsunami of wireless stuff at this stage of the
development cycle for the next release.  Included are the usual
driver updates (including movement of orinoco towards cfg80211)
and many mac80211 improvements.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit e5a8a896f5180f2950695d2d0b79db348d20=
0ca4:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../davem/net-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Andrey Yurovsky (4):
      libertas: remove ps_supported flag, use fwcapinfo
      libertas: copy WPA keys to priv when associating
      libertas: correct card cleanup order in SPI driver
      libertas: fix card cleanup order in SDIO driver

Ari Kauppi (2):
      wl12xx: Fix incorrect warning message.
      wl12xx: Fix CMD_TEST regression via netlink.

Bob Copeland (7):
      ath5k: cleanup ath5k_hw struct
      ath5k: enable hardware LEDs
      ath5k: send buffered frames after the beacon
      ath5k: rework beacon configuration
      ath: remove unnecessary return in ath_regd_get_band_ctl
      ath5k: do not release irq across suspend/resume
      ath5k: write PCU registers on initial reset

Christian Lamparter (14):
      ar9170usb: module link in sysfs
      p54: redo rx_status into skb->cb
      p54: Move eeprom code
      p54: Move eeprom header
      p54: Move firmware code
      p54: Move LED code
      p54: Move LMAC interface definitions
      p54: Move mac80211 glue code
      p54: Move TX/RX code
      p54: Modify p54 files for new organization
      p54: two endian fixes
      p54spi: remove dead code and definitions
      p54usb: fix stalls caused by urb allocation failures
      p54: fix queue stall due to underrun

David Kilroy (24):
      cfg80211: add wrapper function to get wiphy from priv pointer
      cfg80211: Advertise ciphers via WE according to driver capability
      cfg80211: allow drivers that can't scan for specific ssids
      cfg80211: set WE encoding size based on available ciphers
      cfg80211: infer WPA and WPA2 support from TKIP and CCMP
      orinoco: Move firmware capability determination into hw.c
      orinoco: Move card reading code into hw.c
      orinoco: Move FID allocation to hw.c
      orinoco: use dev_err in early initialisation routines
      orinoco: firmware helpers should use dev_err and friends
      orinoco: Replace net_device with orinoco_private in driver interf=
aces
      orinoco: initialise independently of netdev
      orinoco: Change set_tkip to use orinoco_private instead of hermes=
_t
      orinoco: initiate cfg80211 conversion
      orinoco: make firmware download less verbose
      orinoco: move netdev interface creation to main driver
      airport: store irq in card private structure
      orinoco: Handle suspend/restore in core driver
      orinoco: provide generic commit function
      orinoco: convert mode setting to cfg80211
      orinoco: convert scanning to cfg80211
      orinoco: convert giwrange to cfg80211
      orinoco: remove WE nickname support
      orinoco: fix printk format specifier for size_t arguments

Gabor Juhos (2):
      ath9k: remove unnecessary clearing of SC_OP_WAIT_{BEACON,CAB} fla=
gs
      ath9k: remove ath_rx_ps_back_to_sleep helper

Helmut Schaa (1):
      mac80211: shorten the passive dwell time for sw scans

Hin-Tak Leung (1):
      zd1211rw: sort vid/pid pairs by numerical value

Ivo van Doorn (1):
      rt2x00: use wiphy rfkill interface

Jiri Slaby (2):
      ath5k: remove permissions from debugfs files
      ath9k: remove permissions from debugfs files

Joe Perches (2):
      drivers/net/wireless: Use PCI_VDEVICE
      drivers/net/wireless/ath/ath9k: Remove unnecessary semicolons

Johannes Berg (54):
      cfg80211: pass netdev to change_virtual_intf
      cfg80211: issue netlink notification when scan starts
      rt2x00: remove skb->do_not_encrypt usage
      mac80211: push rx status into skb->cb
      mac80211: improve per-sta debugfs
      cfg80211: prohibit scanning the same channel more than once
      mac80211_hwsim: clean up the skb before passing it back
      cfg80211: send wext MLME-MICHAELMICFAILURE.indication
      wext: allow returning NULL stats
      mac80211: fix todo lock
      wext: default to y
      cfg80211: move break statement to correct place
      nl80211: clean up function definitions
      cfg80211: use proper allocation flags
      cfg80211: remove wireless_dev->bssid
      mac80211: tell SME about real auth state
      wext: constify extra argument to wireless_send_event
      cfg80211: introduce nl80211 testmode command
      mac80211: remove an unused function declaration
      wireless: define AKM suites
      cfg80211: emulate connect with auth/assoc
      cfg80211: managed mode wext compatibility
      cfg80211: implement iwpower
      cfg80211: implement IWAP for WDS
      cfg80211: implement IWRATE
      cfg80211: implement get_wireless_stats
      mac80211: re-add HT disabling
      mac80211: remove auth algorithm retry
      mac80211: remove dead code, clean up
      cfg80211: send events for userspace SME
      cfg80211: reset auth algorithm
      cfg80211: assimilate and export ieee80211_bss_get_ie
      cfg80211: keep track of BSSes
      cfg80211: refuse authenticating to same BSSID twice
      nl80211: limit to one pairwise cipher for associate()
      cfg80211: fix giwrange
      iwlwifi: make software queue assignment more efficient
      iwlwifi: scan requested channels only
      iwlwifi: fix aggregation limit
      rfkill: prep for rfkill API changes
      cfg80211: let SME control reassociation vs. association
      mac80211: remove dead code from mlme
      mac80211: rework MLME for multiple authentications
      mac80211: refactor the WEP code to be directly usable
      cfg80211: fix netdev down problem
      cfg80211: dont use union for wext
      cfg80211: mlme API must be able to sleep
      cfg80211: warn again on spurious deauth
      cfg80211: properly name driver locking
      cfg80211: fix MFP bug, sparse warnings
      cfg80211: fix locking
      cfg80211: clean up naming once and for all
      cfg80211: disallow configuring unsupported interfaces
      hwsim: make testmode_cmd static

John W. Linville (1):
      mac80211_hwsim: fix-up build damage from removal of skb->dst

Jussi Kivilinna (3):
      rndis_wlan: convert get/set frag/rts to cfg80211
      usbnet: Add stop function pointer to 'struct rndis_data'.
      rndis_wlan: convert set/get txpower to cfg80211

Juuso Oikarinen (4):
      wl12xx: removed chipset interrupt source configuration from fw wa=
keup
      wl12xx: Moved wl1251 TX path implementation into chip specific fi=
les
      wl12xx: Add support for block reading from a fixed register addre=
ss
      wl12xx: Use chipset specific join commands

Kalle Valo (20):
      wl12xx: cmd and acx interface rework
      wl12xx: reserver buffer for read32()/write32() in struct wl12xx
      wl12xx: fix error handling in wl12xx_probe()
      wl12xx: reserve buffer for partition command in struct wl12xx
      wl12xx: allocate buffer spi read/write command buffer kzalloc()
      wl12xx: allocate buffer the spi busy word from struct wl12xx
      wl12xx: use wl12xx_mem_read32() to read the rx counter
      wl12xx: fix rx descriptor use
      wl12xx: protect wl12xx_op_set_rts_threshold()
      wl12xx: optimise elp wakeup and sleep calls
      wl12xx: check if elp wakeup failed
      wl12xx: enable ELP mode
      wl12xx: rename wl1251.c wl1251_ops.c
      wl12xx: rename driver to wl1251
      wl1251: remove wl1271_setup()
      wl1251: add wl1251 prefix to all 1251 files
      wl1251: rename wl12xx.h to wl1251.h
      wl12xx: remove unused wl12xx_hw_init_mem_config()
      wl1251: use wl1251 prefix everywhere
      wl1251: fix a checkpatch warning

Luciano Coelho (6):
      wl12xx: add wl12xx_spi_reg_read() and wl12xx_spi_reg_write() func=
tions
      wl12xx: moved firmware version reading routine to chip-specific f=
unctions
      wl12xx: add support for new WL1271 chip revision
      wl12xx: add support for fixed address in wl12xx_spi_read
      wl12xx: pass the wake up condition when configuring the wake up e=
vent
      wl1251: change psm enabled/disabled info to debug

Luis R. Rodriguez (1):
      ath9k: differentiate quality reporting between legacy and HT conf=
igurations

Mohamed Abbas (1):
      iwlwifi: Check HW ready before prepare card.

Reinette Chatre (3):
      iwlagn: re-enable PS support for iwlagn
      iwlwifi: add utility to print buffer when error occurs
      iwlwifi: always print buffer when error condition occurs

Roel Kluin (1):
      wireless: remove redundant tests on unsigned

Samuel Ortiz (6):
      iwmc3200wifi: invalidate keys when changing the BSSID
      iwmc3200wifi: handling wifi_if_ntfy responses
      iwmc3200wifi: cfg80211 key hooks implemetation
      iwmc3200wifi: cache keys when interface is down
      cfg80211: connect/disconnect API
      cfg80211: check for current_bss from giwrate

Senthil Balasubramanian (4):
      ath9k: remove unnecessary STATION mode check.
      ath9k: stop ani when the STA gets disconnected.
      ath9k: race condition in SCANNING state check during ANI calibrat=
ion
      ath9k: Handle different TX and RX streams properly.

Tomas Winkler (2):
      iwlwifi: drop sw_crypto from hw_params.
      iwlwifi: unify iwl_setup_rxon_timing

Vasanthakumar Thiagarajan (4):
      ath9k: Nuke unneccesary helper function to see if aggr is active
      ath9k: Remove unnecessary count for addba attempt
      ath9k: downgrade ASSERT() in ath_clone_txbuf()
      ath9k: Make sure we configure a non-zero beacon interval

Vidhya Govindan (1):
      wl12xx: Assign value to rx msdu lifetime variable

Wey-Yi Guy (3):
      iwlwifi: modify sensitivity value for 5150
      iwlwifi: no need to refer to max_nrg_cck range value
      iwlwifi: remove disable_tx_power for device > 4965

Zhu Yi (5):
      iwmc3200wifi: change coexist periodic calibration flag
      iwmc3200wifi: rfkill cleanup
      iwmc3200wifi: replace netif_rx with netif_rx_ni
      iwmc3200wifi: simplify calibration map
      iwmc3200wifi: remove B0 hardware support

 drivers/net/usb/usbnet.c                           |   14 +
 drivers/net/wireless/adm8211.c                     |    3 +-
 drivers/net/wireless/at76c50x-usb.c                |    3 +-
 drivers/net/wireless/ath/ar9170/main.c             |    6 +-
 drivers/net/wireless/ath/ar9170/usb.c              |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   21 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    3 +
 drivers/net/wireless/ath/ath5k/base.c              |  130 +-
 drivers/net/wireless/ath/ath5k/base.h              |   10 +-
 drivers/net/wireless/ath/ath5k/debug.c             |    8 +-
 drivers/net/wireless/ath/ath5k/phy.c               |    7 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    1 -
 drivers/net/wireless/ath/ath5k/reset.c             |    1 -
 drivers/net/wireless/ath/ath9k/ath9k.h             |    2 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   15 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   10 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    2 -
 drivers/net/wireless/ath/ath9k/hw.c                |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   62 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   67 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   33 +-
 drivers/net/wireless/ath/regd.c                    |    2 -
 drivers/net/wireless/b43/xmit.c                    |    3 +-
 drivers/net/wireless/b43legacy/xmit.c              |    3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   10 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   29 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   74 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c           |    7 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   63 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    6 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |    5 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   31 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   16 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   88 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c       |  235 ++-
 drivers/net/wireless/iwmc3200wifi/commands.c       |  116 +-
 drivers/net/wireless/iwmc3200wifi/commands.h       |    7 +-
 drivers/net/wireless/iwmc3200wifi/eeprom.c         |    4 -
 drivers/net/wireless/iwmc3200wifi/fw.c             |   21 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h            |   32 +-
 drivers/net/wireless/iwmc3200wifi/lmac.h           |    4 +
 drivers/net/wireless/iwmc3200wifi/main.c           |   38 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c         |   27 +-
 drivers/net/wireless/iwmc3200wifi/rx.c             |   36 +-
 drivers/net/wireless/iwmc3200wifi/sdio.c           |    6 +-
 drivers/net/wireless/iwmc3200wifi/umac.h           |    2 +
 drivers/net/wireless/iwmc3200wifi/wext.c           |  352 +---
 drivers/net/wireless/libertas/assoc.c              |    6 +
 drivers/net/wireless/libertas/dev.h                |    1 -
 drivers/net/wireless/libertas/if_cs.c              |    3 -
 drivers/net/wireless/libertas/if_sdio.c            |    5 +-
 drivers/net/wireless/libertas/if_spi.c             |    8 +-
 drivers/net/wireless/libertas/if_usb.c             |    3 +-
 drivers/net/wireless/libertas/wext.c               |    2 +-
 drivers/net/wireless/libertas_tf/main.c            |    3 +-
 drivers/net/wireless/mac80211_hwsim.c              |   81 +-
 drivers/net/wireless/mwl8k.c                       |    3 +-
 drivers/net/wireless/orinoco/Kconfig               |    1 +
 drivers/net/wireless/orinoco/Makefile              |    2 +-
 drivers/net/wireless/orinoco/airport.c             |   98 +-
 drivers/net/wireless/orinoco/cfg.c                 |  162 ++
 drivers/net/wireless/orinoco/cfg.h                 |   15 +
 drivers/net/wireless/orinoco/fw.c                  |   41 +-
 drivers/net/wireless/orinoco/hermes.c              |    2 +-
 drivers/net/wireless/orinoco/hermes.h              |    2 +-
 drivers/net/wireless/orinoco/hermes_dld.c          |   50 +-
 drivers/net/wireless/orinoco/hw.c                  |  668 +++++-
 drivers/net/wireless/orinoco/hw.h                  |   11 +-
 drivers/net/wireless/orinoco/main.c                | 1133 +++------
 drivers/net/wireless/orinoco/main.h                |    3 +-
 drivers/net/wireless/orinoco/orinoco.h             |   49 +-
 drivers/net/wireless/orinoco/orinoco_cs.c          |   96 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c      |   38 +-
 drivers/net/wireless/orinoco/orinoco_pci.c         |   38 +-
 drivers/net/wireless/orinoco/orinoco_pci.h         |   57 +-
 drivers/net/wireless/orinoco/orinoco_plx.c         |   38 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c         |   38 +-
 drivers/net/wireless/orinoco/scan.c                |  291 ++--
 drivers/net/wireless/orinoco/scan.h                |   21 +-
 drivers/net/wireless/orinoco/spectrum_cs.c         |   96 +-
 drivers/net/wireless/orinoco/wext.c                |  878 +------
 drivers/net/wireless/p54/Makefile                  |    3 +
 drivers/net/wireless/p54/eeprom.c                  |  564 ++++
 drivers/net/wireless/p54/eeprom.h                  |  226 ++
 drivers/net/wireless/p54/fwio.c                    |  698 +++++
 drivers/net/wireless/p54/led.c                     |  163 ++
 drivers/net/wireless/p54/lmac.h                    |  551 ++++
 drivers/net/wireless/p54/main.c                    |  607 +++++
 drivers/net/wireless/p54/p54.h                     |  148 +-
 drivers/net/wireless/p54/p54common.c               | 2688 ------------=
--------
 drivers/net/wireless/p54/p54common.h               |  644 -----
 drivers/net/wireless/p54/p54pci.c                  |    9 +-
 drivers/net/wireless/p54/p54spi.c                  |   50 +-
 drivers/net/wireless/p54/p54usb.c                  |   42 +-
 drivers/net/wireless/p54/txrx.c                    |  826 ++++++
 drivers/net/wireless/prism54/islpci_hotplug.c      |    4 +-
 drivers/net/wireless/rndis_wlan.c                  |  298 ++--
 drivers/net/wireless/rt2x00/Kconfig                |    8 -
 drivers/net/wireless/rt2x00/Makefile               |    1 -
 drivers/net/wireless/rt2x00/rt2400pci.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   13 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |    6 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    5 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   21 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c         |  127 -
 drivers/net/wireless/rt2x00/rt61pci.c              |    7 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    7 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c         |    5 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c         |    3 +-
 drivers/net/wireless/wl12xx/Kconfig                |   17 +-
 drivers/net/wireless/wl12xx/Makefile               |    9 +-
 drivers/net/wireless/wl12xx/acx.c                  |  689 -----
 drivers/net/wireless/wl12xx/cmd.c                  |  353 ---
 drivers/net/wireless/wl12xx/reg.h                  |    1 -
 drivers/net/wireless/wl12xx/wl1251.h               |  479 +++-
 drivers/net/wireless/wl12xx/wl1251_acx.c           |  840 ++++++
 .../net/wireless/wl12xx/{acx.h =3D> wl1251_acx.h}    |  199 +--
 .../net/wireless/wl12xx/{boot.c =3D> wl1251_boot.c}  |  114 +-
 .../net/wireless/wl12xx/{boot.h =3D> wl1251_boot.h}  |   12 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.c           |  428 ++++
 .../net/wireless/wl12xx/{cmd.h =3D> wl1251_cmd.h}    |  194 ++-
 .../wl12xx/{debugfs.c =3D> wl1251_debugfs.c}         |   60 +-
 .../wl12xx/{debugfs.h =3D> wl1251_debugfs.h}         |   16 +-
 .../wireless/wl12xx/{event.c =3D> wl1251_event.c}    |   54 +-
 .../wireless/wl12xx/{event.h =3D> wl1251_event.h}    |   12 +-
 .../net/wireless/wl12xx/{init.c =3D> wl1251_init.c}  |   78 +-
 .../net/wireless/wl12xx/{init.h =3D> wl1251_init.h}  |   27 +-
 .../net/wireless/wl12xx/{main.c =3D> wl1251_main.c}  |  638 +++--
 drivers/net/wireless/wl12xx/wl1251_netlink.c       |  679 +++++
 .../wl12xx/{debugfs.h =3D> wl1251_netlink.h}         |   15 +-
 .../net/wireless/wl12xx/{wl1251.c =3D> wl1251_ops.c} |  297 ++-
 drivers/net/wireless/wl12xx/wl1251_ops.h           |  165 ++
 drivers/net/wireless/wl12xx/{ps.c =3D> wl1251_ps.c}  |   64 +-
 drivers/net/wireless/wl12xx/{ps.h =3D> wl1251_ps.h}  |   18 +-
 drivers/net/wireless/wl12xx/{rx.c =3D> wl1251_rx.c}  |   90 +-
 drivers/net/wireless/wl12xx/{rx.h =3D> wl1251_rx.h}  |   22 +-
 .../net/wireless/wl12xx/{spi.c =3D> wl1251_spi.c}    |  179 +-
 .../net/wireless/wl12xx/{spi.h =3D> wl1251_spi.h}    |   62 +-
 drivers/net/wireless/wl12xx/{tx.c =3D> wl1251_tx.c}  |  124 +-
 drivers/net/wireless/wl12xx/{tx.h =3D> wl1251_tx.h}  |   21 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |  409 ---
 drivers/net/wireless/zd1211rw/zd_mac.c             |    3 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |   73 +-
 drivers/staging/agnx/xmit.c                        |    3 +-
 drivers/staging/stlc45xx/stlc45xx.c                |    3 +-
 drivers/staging/winbond/wb35rx.c                   |    3 +-
 include/linux/ieee80211.h                          |    4 +
 include/linux/nl80211.h                            |   96 +
 include/linux/rfkill.h                             |   14 +
 include/linux/usb/usbnet.h                         |    3 +
 include/net/cfg80211.h                             |  460 +++-
 include/net/iw_handler.h                           |    2 +-
 include/net/mac80211.h                             |   34 +-
 net/mac80211/Kconfig                               |   16 -
 net/mac80211/cfg.c                                 |  216 +-
 net/mac80211/debugfs_netdev.c                      |   46 -
 net/mac80211/debugfs_sta.c                         |   98 +-
 net/mac80211/event.c                               |   23 +-
 net/mac80211/ibss.c                                |    6 +-
 net/mac80211/ieee80211_i.h                         |  148 +-
 net/mac80211/iface.c                               |   30 +-
 net/mac80211/key.c                                 |   28 +-
 net/mac80211/main.c                                |    5 +-
 net/mac80211/mesh.c                                |    6 +-
 net/mac80211/mesh.h                                |    3 +-
 net/mac80211/mlme.c                                | 1637 +++++-------
 net/mac80211/rx.c                                  |  103 +-
 net/mac80211/scan.c                                |   29 +-
 net/mac80211/sta_info.h                            |   17 +
 net/mac80211/wep.c                                 |   52 +-
 net/mac80211/wep.h                                 |    4 -
 net/mac80211/wext.c                                |  450 +---
 net/mac80211/wpa.c                                 |    3 +-
 net/rfkill/core.c                                  |   10 +-
 net/wireless/Kconfig                               |   43 +-
 net/wireless/Makefile                              |    4 +-
 net/wireless/core.c                                |  385 ++-
 net/wireless/core.h                                |  184 ++-
 net/wireless/debugfs.c                             |   14 +-
 net/wireless/debugfs.h                             |    8 +-
 net/wireless/ibss.c                                |  158 +-
 net/wireless/mlme.c                                |  581 ++++-
 net/wireless/nl80211.c                             | 1110 ++++++---
 net/wireless/nl80211.h                             |   71 +-
 net/wireless/reg.c                                 |   48 +-
 net/wireless/scan.c                                |   75 +-
 net/wireless/sme.c                                 |  792 ++++++
 net/wireless/util.c                                |   21 +
 net/wireless/wext-compat.c                         |  496 ++++-
 net/wireless/wext-sme.c                            |  380 +++
 net/wireless/wext.c                                |   11 +-
 201 files changed, 15590 insertions(+), 12136 deletions(-)
 create mode 100644 drivers/net/wireless/orinoco/cfg.c
 create mode 100644 drivers/net/wireless/orinoco/cfg.h
 create mode 100644 drivers/net/wireless/p54/eeprom.c
 create mode 100644 drivers/net/wireless/p54/eeprom.h
 create mode 100644 drivers/net/wireless/p54/fwio.c
 create mode 100644 drivers/net/wireless/p54/led.c
 create mode 100644 drivers/net/wireless/p54/lmac.h
 create mode 100644 drivers/net/wireless/p54/main.c
 delete mode 100644 drivers/net/wireless/p54/p54common.c
 delete mode 100644 drivers/net/wireless/p54/p54common.h
 create mode 100644 drivers/net/wireless/p54/txrx.c
 delete mode 100644 drivers/net/wireless/rt2x00/rt2x00rfkill.c
 delete mode 100644 drivers/net/wireless/wl12xx/acx.c
 delete mode 100644 drivers/net/wireless/wl12xx/cmd.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_acx.c
 rename drivers/net/wireless/wl12xx/{acx.h =3D> wl1251_acx.h} (86%)
 rename drivers/net/wireless/wl12xx/{boot.c =3D> wl1251_boot.c} (67%)
 rename drivers/net/wireless/wl12xx/{boot.h =3D> wl1251_boot.h} (78%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_cmd.c
 rename drivers/net/wireless/wl12xx/{cmd.h =3D> wl1251_cmd.h} (60%)
 rename drivers/net/wireless/wl12xx/{debugfs.c =3D> wl1251_debugfs.c} (=
92%)
 copy drivers/net/wireless/wl12xx/{debugfs.h =3D> wl1251_debugfs.h} (74=
%)
 rename drivers/net/wireless/wl12xx/{event.c =3D> wl1251_event.c} (59%)
 rename drivers/net/wireless/wl12xx/{event.h =3D> wl1251_event.h} (94%)
 rename drivers/net/wireless/wl12xx/{init.c =3D> wl1251_init.c} (55%)
 rename drivers/net/wireless/wl12xx/{init.h =3D> wl1251_init.h} (55%)
 rename drivers/net/wireless/wl12xx/{main.c =3D> wl1251_main.c} (60%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_netlink.c
 rename drivers/net/wireless/wl12xx/{debugfs.h =3D> wl1251_netlink.h} (=
73%)
 rename drivers/net/wireless/wl12xx/{wl1251.c =3D> wl1251_ops.c} (66%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_ops.h
 rename drivers/net/wireless/wl12xx/{ps.c =3D> wl1251_ps.c} (55%)
 rename drivers/net/wireless/wl12xx/{ps.h =3D> wl1251_ps.h} (72%)
 rename drivers/net/wireless/wl12xx/{rx.c =3D> wl1251_rx.c} (68%)
 rename drivers/net/wireless/wl12xx/{rx.h =3D> wl1251_rx.h} (89%)
 rename drivers/net/wireless/wl12xx/{spi.c =3D> wl1251_spi.c} (63%)
 rename drivers/net/wireless/wl12xx/{spi.h =3D> wl1251_spi.h} (61%)
 rename drivers/net/wireless/wl12xx/{tx.c =3D> wl1251_tx.c} (79%)
 rename drivers/net/wireless/wl12xx/{tx.h =3D> wl1251_tx.h} (93%)
 delete mode 100644 drivers/net/wireless/wl12xx/wl12xx.h
 create mode 100644 net/wireless/sme.c
 create mode 100644 net/wireless/wext-sme.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-07-10.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
