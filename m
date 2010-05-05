From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-05-05
Date: Wed, 5 May 2010 16:35:29 -0400
Message-ID: <20100505203528.GB2603@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40137 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756078Ab0EEUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 16:45:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another enormous batch intended for 2.6.35...  This is mostly the 'usua=
l
suspects' -- driver updates from Intel, Atheros, Nokia, and the rt2x00
guys, mac80211 stuff from Johannes, and a variety of other bits.  One
noteworth bit is the addition of the orinoco_usb driver.

Please let me know if there are problems!

=C2=A1Ol=C3=A9!

Thanks,

John

---

The following changes since commit 0a12761bcd5646691c5d16dd93df84d1b884=
9285:
  David S. Miller (1):
        forcedeth: Kill NAPI config options.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6 for-davem

Abhijeet Kolekar (2):
      iwlwifi: reset pci retry timeout
      iwl3945: add ucode statistics

Benoit Papillault (1):
      ath9k: Added get_survey callback in order to get channel noise

Dan Carpenter (1):
      iwl: cleanup: remove unneeded error handling

Dan Williams (1):
      libertas: fix 8686 firmware loading regression

Daniel Halperin (1):
      iwlwifi: set AMPDU status variables correctly

David Kilroy (6):
      orinoco: add hermes_ops
      orinoco: allow driver to specify netdev_ops
      orinoco: encapsulate driver locking
      orinoco: add orinoco_usb driver
      orinoco_usb: avoid in_atomic
      orinoco_usb: implement fw download

=46elix Fietkau (13):
      mac80211: fix handling of 4-address-mode in ieee80211_change_ifac=
e
      ath9k_hw: update initvals for AR9003
      ath9k_hw: fix pll clock setting for 5ghz on AR9003
      ath9k_hw: fix typo in the AR9003 EEPROM data structure definition
      ath9k_hw: update EEPROM data structure for AR9280
      ath9k_hw: fix fast clock handling for 5GHz channels
      ath9k: wake queue after processing edma rx frames
      ath9k_hw: use the configured power limit for AR9003
      ath9k_hw: Fix typos in tx rate power level parsing for AR9003
      ath9k_hw: Fix endian bug in an AR9003 EEPROM field
      ath9k_hw: fix noisefloor timeout handling on AR9003
      cfg80211: add ap isolation support
      mac80211: implement ap isolation support

Gertjan van Wingerde (4):
      rt2x00: Remove rt2x00pci.h include from rt2800lib.
      rt2x00: Enable RT30xx by default.
      rt2x00: Fix HT40+/HT40- setting in rt2800.
      rt2x00: Register frame length in TX entry descriptor instead of L=
2PAD.

Hans de Goede (1):
      p54pci: fix regression from prevent stuck rx-ring on slow system

Helmut Schaa (6):
      rt2x00: rt2800lib: disable HT40 for now as it causes reception pr=
oblems
      rt2x00: rt2800: use tx_power2 in rt2800_config_channel_rf3xxx
      rt2x00: fix typo in rt2800.h
      rt2x00: rt2800lib: Fix rx path on SoC devices
      rt2x00: rt2800lib: Remove redundant check for RT2872
      rt2x00: rt2800lib: update rfcsr & bbp init code for SoC devices

Johannes Berg (9):
      mac80211: give virtual interface to hw_scan
      mac80211: notify driver about IBSS status
      mac80211: tell driver about IBSS merge
      iwlwifi: work around passive scan issue
      mac80211: fix ieee80211_find_sta[_by_hw]
      mac80211: allow controlling aggregation manually
      mac80211: improve IBSS scanning
      mac80211_hwsim: fix double-scan detection
      mac80211: use fixed channel in ibss join when appropriate

John W. Linville (25):
      ssb: do not read SPROM if it does not exist
      MAINTAINERS: add entry for include/linux/iw_handler.h
      mwl8k: remove usage of deprecated noise value
      ar9170: remove usage of deprecated noise value
      ath5k: remove usage of deprecated noise value
      ath9k: remove usage of deprecated noise value
      b43: remove usage of deprecated noise value
      b43legacy: remove usage of deprecated noise value
      libertas_tf: remove usage of deprecated noise value
      p54: remove usage of deprecated noise value
      rt2x00: remove usage of deprecated noise value
      wl1251: remove usage of deprecated noise value
      rtl8180: use cached queue mapping for skb in rtl8180_tx
      rtl8180: fix tx status reporting
      libertas_tf: avoid warning about pr_fmt redefinition
      mac80211: remove deprecated noise field from ieee80211_rx_status
      iwmc3200wifi: cleanup unneeded debugfs error handling
      rt2x00: remove now unused noise field from struct rxdone_entry_de=
sc
      b43: Added get_survey callback in order to get channel noise
      b43legacy: Added get_survey callback in order to get channel nois=
e
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      iwmc3200wifi: fix busted iwm_debugfs_init definition
      rtl8180: use SET_IEEE80211_PERM_ADDR
      rtl8187: use SET_IEEE80211_PERM_ADDR
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Juuso Oikarinen (5):
      mac80211: Fix sta->last_tx_rate setting with no-op rate control d=
evices
      mac80211: Determine dynamic PS timeout based on ps-qos network la=
tency
      cfg80211: Remove default dynamic PS timeout value
      wl1271: Improve command polling
      wl1271: Rewrite hardware keep-alive handling

Larry Finger (1):
      ssb: Make bus registration failure not be silent

Luciano Coelho (1):
      wl1271: fix a bunch of sparse warnings

Luis R. Rodriguez (2):
      ath9k_hw: disable TX IQ calibration for AR9003
      ath9k_hw: Fix TX interrupt mitigation settings

Rafa=C5=82 Mi=C5=82ecki (3):
      ssb: Look for SPROM at different offset on higher rev CC
      ssb: Use relative offsets for SPROM
      ssb: Fix order of definitions and some text space indents

Reinette Chatre (2):
      Merge branch 'wireless-2.6' into wireless-next-2.6
      iwlwifi: recalculate average tpt if not current

Saravanan Dhanabal (1):
      wl1271: Configure QOS nullfunc template for U-APSD

Shanyu Zhao (2):
      mac80211: fix rts threshold check
      iwlwifi: set correct AC to swq_id for aggregation

Stanislaw Gruszka (2):
      mac80211: do not wip out old supported rates
      mac80211: fix supported rates IE if AP doesn't give us it's rates

Steve deRosier (1):
      libertastf: add configurable debug messages

Sujith (14):
      ath9k_htc: Simplify TX URB management
      ath9k_htc: Handle device unplug properly
      ath9k_htc: Use multiple register writes
      ath9k_htc: Cancel running timers before disabling HW
      ath9k_hw: Remove pointless ANI deinit
      ath9k_htc: Pass correct private pointer
      ath9k_htc: Use USB reboot
      ath9k_htc: Process command data properly
      ath9k_htc: Increase WMI timeout value
      ath9k_htc: Fix WMI command race
      ath9k_htc: Really fix device hotunplug
      ath9k_htc: Remove unnecessary powersave restore
      ath9k_htc: Validate TX Endpoint ID
      ath9k_htc: Simplify RX IRQ handler

Vasanthakumar Thiagarajan (1):
      ath9k_hw: Fix usec to hw clock conversion in 5Ghz for ar9003

Vivek Natarajan (2):
      ath9k_htc: Handle CONF_IDLE during unassociated state to save pow=
er.
      ath9k: Avoid corrupt frames being forwarded to mac80211.

Wey-Yi Guy (4):
      iwlwifi: remove get_stats callback function
      iwlwifi: remove outdated comments
      iwlwifi: set hw parameters based on device type
      iwlwifi: greenfield support only true for 11n devices

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800usb: be in sync with latest windows drive=
rs.

 MAINTAINERS                                      |    1 +
 drivers/net/wireless/Kconfig                     |    6 +
 drivers/net/wireless/at76c50x-usb.c              |    1 +
 drivers/net/wireless/ath/ar9170/main.c           |    4 +-
 drivers/net/wireless/ath/ath5k/base.c            |    6 +-
 drivers/net/wireless/ath/ath9k/ani.c             |    9 -
 drivers/net/wireless/ath/ath9k/ani.h             |    1 -
 drivers/net/wireless/ath/ath9k/ar5008_initvals.h |    2 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c      |    5 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c       |    5 +
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h |    8 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c      |   16 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c    |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c   |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_initvals.h |  265 ++--
 drivers/net/wireless/ath/ath9k/ar9003_mac.c      |    3 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c      |   16 +-
 drivers/net/wireless/ath/ath9k/common.c          |    1 -
 drivers/net/wireless/ath/ath9k/eeprom.h          |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c      |    2 +
 drivers/net/wireless/ath/ath9k/hif_usb.c         |  149 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h         |    1 -
 drivers/net/wireless/ath/ath9k/htc.h             |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c    |    8 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |   84 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c    |   59 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c         |    5 +-
 drivers/net/wireless/ath/ath9k/hw.c              |   27 +-
 drivers/net/wireless/ath/ath9k/hw.h              |    8 +-
 drivers/net/wireless/ath/ath9k/mac.c             |   10 +-
 drivers/net/wireless/ath/ath9k/main.c            |   20 +
 drivers/net/wireless/ath/ath9k/wmi.c             |   11 +-
 drivers/net/wireless/ath/ath9k/wmi.h             |    4 +-
 drivers/net/wireless/ath/ath9k/xmit.c            |    2 +
 drivers/net/wireless/b43/main.c                  |   21 +-
 drivers/net/wireless/b43/xmit.c                  |    1 -
 drivers/net/wireless/b43legacy/main.c            |   21 +-
 drivers/net/wireless/b43legacy/xmit.c            |    1 -
 drivers/net/wireless/iwlwifi/Makefile            |    1 +
 drivers/net/wireless/iwlwifi/iwl-1000.c          |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945-debugfs.c  |  500 ++++++
 drivers/net/wireless/iwlwifi/iwl-3945-debugfs.h  |   60 +
 drivers/net/wireless/iwlwifi/iwl-3945.c          |   72 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h          |    2 +
 drivers/net/wireless/iwlwifi/iwl-5000.c          |   73 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c          |   73 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c       |   23 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c        |   20 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c        |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c           |   14 -
 drivers/net/wireless/iwlwifi/iwl-commands.h      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-core.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |   18 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h           |    5 +
 drivers/net/wireless/iwlwifi/iwl-scan.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |    6 +-
 drivers/net/wireless/iwmc3200wifi/bus.h          |    2 +-
 drivers/net/wireless/iwmc3200wifi/debug.h        |    7 +-
 drivers/net/wireless/iwmc3200wifi/debugfs.c      |  110 +--
 drivers/net/wireless/iwmc3200wifi/sdio.c         |   17 +-
 drivers/net/wireless/libertas/if_sdio.c          |    4 +-
 drivers/net/wireless/libertas_tf/cmd.c           |  203 ++-
 drivers/net/wireless/libertas_tf/deb_defs.h      |  104 ++
 drivers/net/wireless/libertas_tf/if_usb.c        |  251 +++-
 drivers/net/wireless/libertas_tf/libertas_tf.h   |    2 +
 drivers/net/wireless/libertas_tf/main.c          |   91 +-
 drivers/net/wireless/mac80211_hwsim.c            |    6 +-
 drivers/net/wireless/mwl8k.c                     |    6 +-
 drivers/net/wireless/orinoco/Kconfig             |    7 +
 drivers/net/wireless/orinoco/Makefile            |    1 +
 drivers/net/wireless/orinoco/airport.c           |    8 +-
 drivers/net/wireless/orinoco/cfg.c               |    2 +-
 drivers/net/wireless/orinoco/fw.c                |   10 +-
 drivers/net/wireless/orinoco/hermes.c            |  286 ++++-
 drivers/net/wireless/orinoco/hermes.h            |   62 +-
 drivers/net/wireless/orinoco/hermes_dld.c        |  243 +---
 drivers/net/wireless/orinoco/hw.c                |   63 +-
 drivers/net/wireless/orinoco/main.c              |  137 +-
 drivers/net/wireless/orinoco/orinoco.h           |   30 +-
 drivers/net/wireless/orinoco/orinoco_cs.c        |    6 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c    |    2 +-
 drivers/net/wireless/orinoco/orinoco_pci.c       |    2 +-
 drivers/net/wireless/orinoco/orinoco_plx.c       |    2 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c       |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c       | 1800 ++++++++++++++=
++++++++
 drivers/net/wireless/orinoco/spectrum_cs.c       |    7 +-
 drivers/net/wireless/orinoco/wext.c              |    6 +-
 drivers/net/wireless/p54/main.c                  |    3 +-
 drivers/net/wireless/p54/p54pci.c                |   16 +-
 drivers/net/wireless/p54/txrx.c                  |    1 -
 drivers/net/wireless/rt2x00/Kconfig              |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2800.h             |   11 +-
 drivers/net/wireless/rt2x00/rt2800lib.c          |   91 +-
 drivers/net/wireless/rt2x00/rt2800pci.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2800usb.c          |   13 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c          |    1 -
 drivers/net/wireless/rt2x00/rt2x00queue.c        |    6 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h        |    6 +-
 drivers/net/wireless/rt2x00/rt61pci.c            |    5 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |    2 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c       |   13 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c       |   10 +-
 drivers/net/wireless/wl12xx/wl1251_main.c        |    2 +-
 drivers/net/wireless/wl12xx/wl1251_rx.c          |    6 -
 drivers/net/wireless/wl12xx/wl1271_acx.c         |    2 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c        |    8 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c         |   14 +-
 drivers/net/wireless/wl12xx/wl1271_conf.h        |    2 +-
 drivers/net/wireless/wl12xx/wl1271_main.c        |   97 +-
 drivers/ssb/driver_chipcommon.c                  |    2 +
 drivers/ssb/main.c                               |    3 +
 drivers/ssb/pci.c                                |   14 +-
 drivers/ssb/sprom.c                              |   14 +
 include/linux/nl80211.h                          |    5 +
 include/linux/ssb/ssb.h                          |    4 +
 include/linux/ssb/ssb_driver_chipcommon.h        |   15 +
 include/linux/ssb/ssb_regs.h                     |  239 ++--
 include/net/cfg80211.h                           |    4 +
 include/net/mac80211.h                           |   21 +-
 net/mac80211/cfg.c                               |   18 +-
 net/mac80211/debugfs_sta.c                       |   65 +-
 net/mac80211/driver-ops.h                        |    5 +-
 net/mac80211/driver-trace.h                      |    9 +-
 net/mac80211/ibss.c                              |   27 +-
 net/mac80211/ieee80211_i.h                       |    3 +-
 net/mac80211/main.c                              |   19 +-
 net/mac80211/mlme.c                              |   21 +
 net/mac80211/rx.c                                |    2 -
 net/mac80211/scan.c                              |   53 +-
 net/mac80211/sta_info.c                          |   17 +-
 net/mac80211/status.c                            |    7 +
 net/mac80211/tx.c                                |    5 +-
 net/mac80211/work.c                              |   28 +-
 net/wireless/core.c                              |    3 +-
 net/wireless/nl80211.c                           |    4 +
 140 files changed, 4751 insertions(+), 1368 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-debugfs.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-debugfs.h
 create mode 100644 drivers/net/wireless/libertas_tf/deb_defs.h
 create mode 100644 drivers/net/wireless/orinoco/orinoco_usb.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-04-23.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
