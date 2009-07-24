From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-07-24
Date: Fri, 24 Jul 2009 15:36:25 -0400
Message-ID: <20090724193625.GB2711@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45398 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbZGXTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 15:45:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest huge round of wireless patches intended for 2.6.32.
It hits all the usual areas (i.e. drivers, mac80211, and cfg80211) with
patches from all the usual suspects.  This includes the reworking of
mac80211 to eliminate the confusing "master netdev".

=46WIW, my laptop has been happy with it.  Most of the bits here have b=
een
in -next for at least a few days.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 74d154189d597b91da4322996dbf4f5c3d15=
44ab:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../davem/net-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Christian Lamparter (8):
      p54: re-enable power save feature
      p54: generate channel list dynamically
      ar9170: implement transmit aggregation
      p54: remove useless code
      p54: fix beaconing related firmware crash
      p54: fix a fw crash caused by statistic feedback
      mac80211: do not monitor the connection while scanning
      mac80211: fix spare warnings in driver-trace.h

Gabor Juhos (5):
      ath9k: serialize ath9k_hw_setpower calls
      ath9k: uninline ath9k_ps_{wakeup,restore} functions
      ath9k: serialize ath9k_ps_{wakeup,restore} calls
      ath9k: wake up the chip for TSF reset
      ath9k: make use ath9k_hw_wait int ath9k_hw_reset_tsf

G=E1bor Stefanik (1):
      cfg80211: fix disabling WPA via wext (SIOCSIWAUTH)

Helmut Schaa (1):
      cfg80211: update misleading comment

Hin-Tak Leung (2):
      zd1211rw: adding Accton Technology Corp (083a:e501) as a ZD1211B =
device
      rtl8187: updating Kconfig with info of branded devices

Ivo van Doorn (1):
      rt2x00: Remove DEVICE_STATE_DISABLED_RADIO_HW

Javier Cardona (2):
      mac80211: Assign next hop address to pending mesh frames
      mac80211: Fix regression in mesh forwarding path.

Jay Sternberg (2):
      iwlwifi: Handle new firmware file with ucode build number in head=
er
      iwlwifi: update 1000 series API version to match firmware

Jiri Slaby (1):
      wireless: wl12xx, fix lock imbalance

Joe Perches (1):
      MAINTAINERS: Update rtl8180 patterns

Johannes Berg (25):
      mac80211: fix sparse warning
      mac80211: driver operation debugging
      cfg80211: fix race in giwrate
      cfg80211: fix two buglets
      nl80211: introduce new key attributes
      cfg80211: rework key operation
      mac80211: fix multi-use timer
      mac80211: monitor the connection
      cfg80211: fix a locking bug
      mac80211: mesh: fix two small problems
      cfg80211: fix wext stats
      mac80211_hwsim: report fixed signal strength
      cfg80211: don't look at wdev->ssid for giwessid
      cfg80211: fix wext setting SSID
      nl80211: report BSS status
      cfg80211: fix more bugs in mlme handling
      mac80211: cancel the connection monitor timers/work
      cfg80211: fix unregistration
      iwlwifi: make some logging functions static/unexport
      wireless: remove print_mac uses
      cfg80211: don't optimise wext calls too much
      net: export __dev_addr_sync/__dev_addr_unsync
      mac80211: remove master netdev
      net: remove unused skb->do_not_encrypt
      mac80211: fix ieee80211_xmit call context

Julia Lawall (1):
      drivers/net: Drop unnecessary NULL test

Kalle Valo (3):
      wl1251: remove accidentally added wl1251_netlink.c
      wl1251: remove wl1251_plt_start/stop()
      MAINTAINERS: add wl1251 wireless driver

Larry Finger (2):
      hostap_cs: Enable shared interrupts
      p54: Eliminate unnecessary initialization

Luis Correia (1):
      rt2x00: Comment spellchecking

Luis R. Rodriguez (21):
      mac80211: drop frames for sta with no valid rate
      ath9k: downgrade assert in rc.c for invalid rate
      iwlwifi: remove rs_get_rate workaround
      ath9k: cleanup try count for MRR in rate control
      ath9k: remove unused min rate calculation code
      ath9k: remove unused stepdown when looking for the next rate
      ath9k: remove pointless wrapper ath_rc_rate_getidx()
      ath9k: rename ath_rc_get_nextlowervalid_txrate()
      ath9k: remove unused ath_rc_isvalid_txmask()
      ath9k: remove ATH9K_MODE_11B
      ath9k: remap ATH9K_MODE_*
      ath9k: rename ath_rc_ratefind_ht() to ath_rc_get_highest_rix()
      ath9k: remove unnecessary IEEE80211_TX_CTL_NO_ACK checks
      mac80211: make minstrel/pid RC use ieee80211_is_data(fc)
      iwlwifi: use ieee80211_is_data(fc)
      mac80211: add helper for management / no-ack frame rate decision
      ath9k: remove rate control wraper
      ath9k: disable radio when all devices are marked idle
      cfg80211: treat ieee80211_regdom hints as user hints
      ath9k: do not stop the queues in driver stop
      adm8211: remove uneeded code during suspend/resume

Marcin Slusarz (1):
      wireless: fix supported cards for rtl8187

Pavel Roskin (1):
      ath5k: fix values for bus error bits in ISR2

Reinette Chatre (7):
      iwlwifi: fix permissions on debugfs files
      iwl3945: cleanup number of queues settings
      iwlagn: fix minimum number of queues setting
      iwlagn: do not send key clear commands when rfkill enabled
      iwlwifi: make debug level more user friendly
      iwlwifi: clarify hardware error message
      iwlwifi: inform user about rfkill state changes

Roel Kluin (1):
      arlan: inverted logic?

Samuel Ortiz (1):
      iwmc3200wifi: cfg80211 managed mode port

Senthil Balasubramanian (3):
      ath9k: Manipulate and report the correct RSSI
      ath9k: RX stucks during heavy traffic in HT40 mode.
      ath9k: Fix TX hang issue with Atheros chipsets

Stefan Steuerwald (1):
      rt2x00: Implement set_tim callback for all drivers

Stefan Weil (1):
      wl12xx: fix spelling

Vasanthakumar Thiagarajan (7):
      ath9k: Remove dead code in rate control
      ath9k: Remove unused members from rate control structure
      ath9k: Use probe interval instead of rssi reduce interval
      ath9k: Nuke struct ath_tx_ratectrl_state
      ath9k: Remove bogus assert in ath_clone_txbuf()
      ath9k: Handle tx desc shortage more appropriately
      ath9k: Remove pointless ath9k_ps_restore() in ath_detach()

Vivek Natarajan (1):
      ath9k: Add AR9287 based chipsets' register information.

Wey-Yi Guy (9):
      iwlwifi: move show_qos to debugfs
      iwlagn: modify digital SVR for 1000
      iwlwifi: fix rx signal quality reporting in dmesg
      iwlwifi: make led functions generic
      iwlwifi: add led debugfs function
      iwlwifi: Led blinking counting both tx and rx
      iwlwifi: checking unknown HW type
      iwlwifi: uCode Alive notification with timeout
      iwlwifi: change iwl_enable/disable_interrupts to "inline"

Zhu Yi (15):
      cfg80211: fix NULL dereference in IBSS SIOCGIWAP
      iwmc3200wifi: fix UMAC INIT_COMPLETE notification handling
      iwmc3200wifi: hardware does not support IP checksum
      iwmc3200wifi: set cipher_suites before registering wiphy
      iwmc3200wifi: use correct debug level
      iwmc3200wifi: remove setting WEP keys before setting essid suppor=
t
      iwmc3200wifi: make iwm_send_wifi_if_cmd return 0 on success
      iwmc3200wifi: remove key caches in driver
      cfg80211: remove WARN_ON in __cfg80211_sme_scan_done
      cfg80211: set_default_key only for WEP
      cfg80211: fix typo of IWEVASSOCRESPIE
      iwmc3200wifi: use cfg80211_connect_result to send req/resp IE
      iwmc3200wifi: fix cfg80211_connect_result is called in IBSS
      iwmc3200wifi: fix a use-after-free bug
      cfg80211: avoid setting default_key if add_key fails

 MAINTAINERS                                  |   11 +-
 drivers/net/wireless/Kconfig                 |    6 +-
 drivers/net/wireless/adm8211.c               |   17 -
 drivers/net/wireless/arlan-main.c            |    2 +-
 drivers/net/wireless/ath/ar9170/ar9170.h     |   52 ++
 drivers/net/wireless/ath/ar9170/main.c       |  609 ++++++++++++++++++=
++++-
 drivers/net/wireless/ath/ath5k/reg.h         |   12 +-
 drivers/net/wireless/ath/ath9k/ath9k.h       |   48 +-
 drivers/net/wireless/ath/ath9k/calib.c       |   13 +-
 drivers/net/wireless/ath/ath9k/calib.h       |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom.c      |   20 +-
 drivers/net/wireless/ath/ath9k/hw.c          |   70 +++-
 drivers/net/wireless/ath/ath9k/hw.h          |   18 +-
 drivers/net/wireless/ath/ath9k/initvals.h    |   47 +-
 drivers/net/wireless/ath/ath9k/mac.c         |   30 +-
 drivers/net/wireless/ath/ath9k/main.c        |   35 ++-
 drivers/net/wireless/ath/ath9k/rc.c          |  609 ++++++++----------=
------
 drivers/net/wireless/ath/ath9k/rc.h          |   29 +-
 drivers/net/wireless/ath/ath9k/recv.c        |   25 +-
 drivers/net/wireless/ath/ath9k/reg.h         |   93 ++++
 drivers/net/wireless/ath/ath9k/virtual.c     |   17 +
 drivers/net/wireless/ath/ath9k/xmit.c        |   76 +++-
 drivers/net/wireless/b43/main.c              |    4 +-
 drivers/net/wireless/hostap/hostap_cs.c      |    3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c       |    3 -
 drivers/net/wireless/iwlwifi/iwl-1000.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h   |    7 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c   |   24 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |   52 ++-
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    3 -
 drivers/net/wireless/iwlwifi/iwl-4965.c      |   67 +++-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |   60 +++-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |  165 ++++---
 drivers/net/wireless/iwlwifi/iwl-core.c      |  424 ++++++++--------
 drivers/net/wireless/iwlwifi/iwl-core.h      |   18 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h     |   16 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |   69 +++-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   40 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |    6 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h   |   21 +
 drivers/net/wireless/iwlwifi/iwl-led.c       |   34 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c       |   19 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |   89 ++--
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |  270 ++++++++---
 drivers/net/wireless/iwmc3200wifi/commands.c |   52 +--
 drivers/net/wireless/iwmc3200wifi/hal.c      |   16 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h      |    5 +
 drivers/net/wireless/iwmc3200wifi/main.c     |    7 +
 drivers/net/wireless/iwmc3200wifi/rx.c       |   96 +++--
 drivers/net/wireless/iwmc3200wifi/umac.h     |    6 +
 drivers/net/wireless/iwmc3200wifi/wext.c     |  320 ++-----------
 drivers/net/wireless/libertas/assoc.c        |   10 +-
 drivers/net/wireless/mac80211_hwsim.c        |    8 +-
 drivers/net/wireless/mwl8k.c                 |    6 +-
 drivers/net/wireless/p54/eeprom.c            |  327 ++++++++++---
 drivers/net/wireless/p54/fwio.c              |   23 +-
 drivers/net/wireless/p54/lmac.h              |    7 +
 drivers/net/wireless/p54/main.c              |  112 +++--
 drivers/net/wireless/p54/p54.h               |    3 +
 drivers/net/wireless/p54/txrx.c              |   80 +++-
 drivers/net/wireless/rt2x00/rt2400pci.c      |    1 +
 drivers/net/wireless/rt2x00/rt2400pci.h      |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c      |    1 +
 drivers/net/wireless/rt2x00/rt2500pci.h      |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c      |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.h      |    2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c      |    9 +-
 drivers/net/wireless/rt2x00/rt2800usb.h      |    2 +-
 drivers/net/wireless/rt2x00/rt2x00.h         |    7 +-
 drivers/net/wireless/rt2x00/rt2x00config.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    3 +-
 drivers/net/wireless/rt2x00/rt2x00link.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      |   14 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h    |   10 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h      |    4 +-
 drivers/net/wireless/rt2x00/rt61pci.c        |    3 +-
 drivers/net/wireless/rt2x00/rt61pci.h        |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c        |    1 +
 drivers/net/wireless/rt2x00/rt73usb.h        |    4 +-
 drivers/net/wireless/wl12xx/wl1251_acx.c     |    4 +-
 drivers/net/wireless/wl12xx/wl1251_main.c    |   61 +---
 drivers/net/wireless/wl12xx/wl1251_netlink.c |  679 ------------------=
--------
 drivers/net/wireless/wl12xx/wl1251_ops.c     |    4 +-
 drivers/net/wireless/wl12xx/wl1251_rx.h      |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c       |    1 +
 include/linux/nl80211.h                      |   52 ++
 include/linux/skbuff.h                       |    6 +-
 include/net/cfg80211.h                       |   20 +-
 include/net/mac80211.h                       |   37 ++
 net/core/dev.c                               |    2 +
 net/core/skbuff.c                            |    3 -
 net/mac80211/Kconfig                         |   12 +
 net/mac80211/Makefile                        |    3 +
 net/mac80211/agg-tx.c                        |    3 -
 net/mac80211/cfg.c                           |    2 +-
 net/mac80211/debugfs.c                       |    2 +-
 net/mac80211/driver-ops.h                    |   85 +++-
 net/mac80211/driver-trace.c                  |    6 +
 net/mac80211/driver-trace.h                  |  648 ++++++++++++++++++=
++++++
 net/mac80211/ibss.c                          |    9 +-
 net/mac80211/ieee80211_i.h                   |   47 +-
 net/mac80211/iface.c                         |   51 +-
 net/mac80211/main.c                          |  120 +-----
 net/mac80211/mesh.c                          |    5 +-
 net/mac80211/mesh_hwmp.c                     |    9 +-
 net/mac80211/mesh_pathtbl.c                  |   26 +-
 net/mac80211/mlme.c                          |  308 ++++++++++---
 net/mac80211/rate.c                          |   31 ++-
 net/mac80211/rc80211_minstrel.c              |   23 +-
 net/mac80211/rc80211_pid_algo.c              |   12 +-
 net/mac80211/rx.c                            |   55 ++-
 net/mac80211/scan.c                          |   19 +-
 net/mac80211/tx.c                            |  323 ++++++-------
 net/mac80211/util.c                          |   68 +--
 net/mac80211/wep.c                           |    6 +-
 net/mac80211/wep.h                           |    3 +
 net/mac80211/wme.c                           |    6 +-
 net/mac80211/wme.h                           |    3 +-
 net/wireless/core.c                          |   21 +-
 net/wireless/core.h                          |   32 +-
 net/wireless/ibss.c                          |   84 +++-
 net/wireless/mlme.c                          |   24 +-
 net/wireless/nl80211.c                       |  428 +++++++++++++---
 net/wireless/reg.c                           |   25 +-
 net/wireless/sme.c                           |  112 +++--
 net/wireless/util.c                          |   45 ++-
 net/wireless/wext-compat.c                   |  202 +++++---
 net/wireless/wext-sme.c                      |   76 ++--
 134 files changed, 4999 insertions(+), 3237 deletions(-)
 delete mode 100644 drivers/net/wireless/wl12xx/wl1251_netlink.c
 create mode 100644 net/mac80211/driver-trace.c
 create mode 100644 net/mac80211/driver-trace.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-07-24.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
