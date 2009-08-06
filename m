From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-08-06
Date: Thu, 6 Aug 2009 15:02:00 -0400
Message-ID: <20090806190200.GJ26809@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34937 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbZHFTQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 15:16:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another big round of updates intended for 2.6.32...mostly the u=
sual
suspects, although it looks like Luis has been exceptionally busy with
both ath9k and regulatory enforcement bits.  Jussi has a number of
rndis_wlan changes, and of course Johannes has a number of patches as
well.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit e4c4e448cf557921ffbbbd6d6ddac81fdcea=
cb4f:
  Eric Dumazet (1):
        neigh: Convert garbage collection from softirq to workqueue

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Andrey Yurovsky (1):
      libertas: check valid bits in SPI bus mode reg

Bob Copeland (3):
      mac80211: disable beacons before removing the associated interfac=
e
      ath5k: update PCU opmode whenever a new interface is added
      ath5k: fix CAB queue operation

Daniel C Halperin (1):
      iwlwifi: clear iwl_cmd_meta structure before use

G=E1bor Stefanik (1):
      b43: implement baseband init for LP-PHY <=3D rev1

Holger Schurig (1):
      orinoco: enable cfg80211 "set_channel" operation

Igor Perminov (1):
      mac80211: FIF_PSPOLL filter flag

Ivo van Doorn (1):
      rt2x00: Fix build error when crypto support is disabled

Jay Sternberg (1):
      iwlwifi: remove duplicated version info from sysfs

Johannes Berg (8):
      mac80211: disable software retry for now
      cfg80211: keep track of current_bss for userspace SME
      mac80211: fix sparse warnings/errors
      iwlwifi: don't export symbols not needed in other modules
      cfg80211: fix NETDEV_UNREGISTER notifier
      mac80211: fix powersave
      cfg80211: lower dynamic PS timeout to 100ms
      cfg80211: clear SSID on disconnect/no connection

Julia Lawall (1):
      drivers/net/wireless: Use DIV_ROUND_CLOSEST

Jussi Kivilinna (10):
      usbnet: allow "minidriver" to prevent urb unlinking on usbnet_sto=
p
      rndis_wlan: stop workers on rndis_wlan_stop() and restore on rndi=
s_wlan_reset()
      rndis_wlan: clear cfg80211 scan on rndis_wlan_stop()
      rndis_wlan: reset device and restore multicast list on rndis_wlan=
_reset()
      rndis_wlan: set current packet filter to zero on stop
      rndis_wlan: add rndis_set/query_oid debugging
      rndis_host: allow rndis_wlan to see all indications
      rndis_wlan: handle 802.11 indications from device
      rndis_wlan: add missing padding to struct rndis_80211_remove_key
      rndis_wlan: rework key handling

Larry Finger (2):
      b43: Work around mac80211 race condition
      b43legacy: Work around mac80211 race condition

Luis R. Rodriguez (51):
      ath9k: re-order cancelling of work on mac80211 workqueue
      ath9k: move cancel_delayed_work_sync() out of ath_deinit_leds()
      ath9k: move workqueue cancels to stop callback
      ar76c50x-usb: cancel promisc work during mac80211 stop
      at76c50x-usb: cancel scan work at stop callback
      ar9170: remove unneeded flush_workqueue()
      wext: remove extra return on wireless_nlevent_init()
      ath: depend on cfg80211
      ath: simplify kconfig dependency and add documentation
      ath: use menuconfig to put ath stuff in its own page
      ath5k: remove EXPERIMENTAL marker
      wireless: use menuconfig for WLAN_PRE80211 and WLAN_80211
      rt2x00: move experimental on kconfig only to rt2800usb
      ar9170: remove EXPERIMENTAL marker
      at76c50x-usb: remove unneeded flush_workqueue() at usb disconnect
      mac80211: redefine usage of the mac80211 workqueue
      cfg80211: use goto out on country IE reg hint failure
      cfg80211: do not iterate over rdev list on country IE hint
      cfg80211: decouple regulatory variables from cfg80211_mutex
      cfg80211: enable country IE support to all cfg80211 drivers
      iwlwifi: remove usage of orig_flags
      ath9k: remove usage of AR_SREV_*() wrapper to detect supported hw
      ath9k: use a switch for revising supported hw mac revisions
      ath9k: propagate hw initialization errors
      ath9k: move memory allocation of ath_hw to ath_init()
      ath9k: move devid cache setting to ath_init()
      ath9k: move cache setting of softc ah prior to attach
      ath9k: call hw initializer directly
      ath9k: pass only one argument to hw attach
      ath9k: move hw macrevision checker to helper
      ath9k: rename ath9k_hw_newstate() to ath9k_hw_init_defaults()
      ath9k: rename ath9k_hw_set_defaults() to ath9k_hw_init_config()
      ath9k: remove debug message for no memoery on ath_init()
      ath9k: break up hw initialization into a few more helpers
      ath9k: describe hw initialization better
      ath9k: distinguish between device initialization and ath_softc in=
it
      ath9k: remove !NULL check before kfree()
      ath9k: use helper macro to kfree and nullify on ath9k_hw_rfdetach=
()
      ath9k: rename ath9k_hw_rfdetach() to ath9k_hw_rf_free()
      ath9k: rename ath9k_hw_ani_detach() to ath9k_hw_ani_disable()
      ath9k: set ah to null after freeing
      ath9k: set sc->sc_ah to NULL after freeing it
      ath9k: call ath9k_hw_detach() once upon hw init failure
      ath9k: remove dangling error check on keycache reset on hw init
      ath9k: remove spurious check for channel on keycache reset
      ath9k: Remove _t postfix for ar9287_eeprom structure
      ath9k: add ar9271 revision and subrevision ID helpers
      ath9k: add initvals and registry definitions for AR9271
      ath9k: add initial hardware support for ar9271
      ath9k: cancel xmit poll work at stop() callback
      ath9k: fix compile warning on ath9k_hw_AR9287_check_eeprom()

Maithili Hinge (1):
      libertas: Fix WEP association failure with open source wpa_suppli=
cant 0.5.10

Maxim Levitsky (2):
      mac80211: Retry probe request few times
      mac80211: Increase timeouts for station polling

Michael Buesch (1):
      b43: Fix unaligned 32bit SHM-shared access

Pavel Roskin (2):
      rt61pci: fix module reloading
      rt2x00: cancel all work on disconnect

Tomas Winkler (1):
      rfkill: add the GPS radio type

Vasanthakumar Thiagarajan (3):
      ath9k: Update rate control for 11NA HT40 mode
      ath9k: Maintain monotonicity of PER while going across different =
phy
      ath9k: Remove unused ath9k_hw_intrget()

Wey-Yi Guy (2):
      iwlwifi: Distinguish power amplifier for 6000 series
      iwlwifi: remove deprecated 6000 series adapters

Zhu Yi (3):
      iwmc3200wifi: fix set_wpa_version and set_auth_type order
      iwmc3200wifi: set WEP key static flag correctly
      iwmc3200wifi: avoid setting default key for 802.1X and RSNA

gregor kowski (1):
      b43: remove wrong probe_resp_plcp write

 drivers/net/usb/rndis_host.c                 |   48 ++-
 drivers/net/usb/usbnet.c                     |   32 +-
 drivers/net/wireless/Kconfig                 |    4 +-
 drivers/net/wireless/at76c50x-usb.c          |   18 +-
 drivers/net/wireless/ath/Kconfig             |   21 +-
 drivers/net/wireless/ath/ar9170/Kconfig      |    4 +-
 drivers/net/wireless/ath/ar9170/led.c        |   11 +-
 drivers/net/wireless/ath/ar9170/main.c       |   29 +-
 drivers/net/wireless/ath/ath5k/Kconfig       |    3 +-
 drivers/net/wireless/ath/ath5k/base.c        |    8 +-
 drivers/net/wireless/ath/ath9k/Kconfig       |    1 -
 drivers/net/wireless/ath/ath9k/ahb.c         |    2 +-
 drivers/net/wireless/ath/ath9k/ani.c         |    6 +-
 drivers/net/wireless/ath/ath9k/ani.h         |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h       |    2 +-
 drivers/net/wireless/ath/ath9k/calib.c       |  106 ++++-
 drivers/net/wireless/ath/ath9k/eeprom.c      |  175 +++++--
 drivers/net/wireless/ath/ath9k/eeprom.h      |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c          |  368 +++++++++------
 drivers/net/wireless/ath/ath9k/hw.h          |   11 +-
 drivers/net/wireless/ath/ath9k/initvals.h    |  666 ++++++++++++++++++=
++++++++
 drivers/net/wireless/ath/ath9k/main.c        |   89 +++--
 drivers/net/wireless/ath/ath9k/pci.c         |    2 +-
 drivers/net/wireless/ath/ath9k/phy.c         |   53 +--
 drivers/net/wireless/ath/ath9k/phy.h         |    3 +
 drivers/net/wireless/ath/ath9k/rc.c          |    7 +-
 drivers/net/wireless/ath/ath9k/reg.h         |   37 ++
 drivers/net/wireless/ath/ath9k/virtual.c     |   17 +-
 drivers/net/wireless/ath/ath9k/xmit.c        |    2 +-
 drivers/net/wireless/b43/b43.h               |   11 +
 drivers/net/wireless/b43/dma.c               |   21 +-
 drivers/net/wireless/b43/main.c              |   42 ++-
 drivers/net/wireless/b43/phy_common.c        |    9 +-
 drivers/net/wireless/b43/phy_common.h        |    5 +
 drivers/net/wireless/b43/phy_lp.c            |   94 ++++-
 drivers/net/wireless/b43/phy_lp.h            |   11 +-
 drivers/net/wireless/b43/phy_n.c             |    3 +-
 drivers/net/wireless/b43/pio.c               |    2 +-
 drivers/net/wireless/b43legacy/dma.c         |   22 +-
 drivers/net/wireless/b43legacy/main.c        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c      |   14 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |   48 ++-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |   51 +--
 drivers/net/wireless/iwlwifi/iwl-core.c      |    6 -
 drivers/net/wireless/iwlwifi/iwl-core.h      |    3 +
 drivers/net/wireless/iwlwifi/iwl-csr.h       |   10 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   17 +-
 drivers/net/wireless/iwlwifi/iwl-led.c       |    1 -
 drivers/net/wireless/iwlwifi/iwl-rx.c        |    1 -
 drivers/net/wireless/iwlwifi/iwl-sta.c       |    1 -
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    1 +
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |    9 +-
 drivers/net/wireless/iwmc3200wifi/commands.c |   49 ++-
 drivers/net/wireless/libertas/if_spi.c       |    2 +-
 drivers/net/wireless/libertas/wext.c         |    2 +
 drivers/net/wireless/orinoco/cfg.c           |   41 ++
 drivers/net/wireless/p54/led.c               |    5 +-
 drivers/net/wireless/p54/main.c              |    2 +-
 drivers/net/wireless/p54/p54spi.c            |    4 +-
 drivers/net/wireless/p54/txrx.c              |    2 +-
 drivers/net/wireless/rndis_wlan.c            |  617 ++++++++++++++++++=
+++---
 drivers/net/wireless/rt2x00/Kconfig          |    8 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    8 +-
 drivers/net/wireless/rt2x00/rt2x00link.c     |    8 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      |   22 +-
 drivers/net/wireless/rt2x00/rt61pci.c        |    5 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c   |    2 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c  |   10 +-
 drivers/net/wireless/strip.c                 |    9 +-
 drivers/net/wireless/zd1211rw/zd_mac.c       |    2 +-
 include/linux/rfkill.h                       |    1 +
 include/linux/usb/rndis_host.h               |   13 +-
 include/linux/usb/usbnet.h                   |    6 +-
 include/net/cfg80211.h                       |   14 -
 include/net/mac80211.h                       |   58 ++-
 net/mac80211/driver-trace.c                  |    3 +
 net/mac80211/ibss.c                          |    6 +-
 net/mac80211/ieee80211_i.h                   |    9 +-
 net/mac80211/iface.c                         |   36 ++-
 net/mac80211/main.c                          |   40 ++-
 net/mac80211/mesh.c                          |   10 +-
 net/mac80211/mesh_hwmp.c                     |    4 +-
 net/mac80211/mlme.c                          |  113 +++--
 net/mac80211/pm.c                            |    8 +-
 net/mac80211/scan.c                          |    8 +-
 net/mac80211/tx.c                            |    2 +-
 net/mac80211/util.c                          |   41 ++
 net/rfkill/core.c                            |    4 +-
 net/wireless/core.c                          |   24 +-
 net/wireless/core.h                          |    8 +-
 net/wireless/mlme.c                          |   38 +-
 net/wireless/reg.c                           |  107 ++---
 net/wireless/reg.h                           |   15 +
 net/wireless/sme.c                           |   55 ++-
 net/wireless/wext.c                          |    1 -
 96 files changed, 2757 insertions(+), 796 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-08-06.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
