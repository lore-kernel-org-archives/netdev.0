From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-02-09
Date: Mon, 9 Feb 2009 15:23:14 -0500
Message-ID: <20090209202314.GF6069@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another round of update intended for 2.6.30.  Along with a few mac80211
updates, there is the usual ton of driver updates with no real unifying
theme.  FWIW, this has spent a little time in linux-next already.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit aa6320d336971171df1d13c1c284facf10804881:
  Herbert Xu (1):
        gro: Optimise TCP packet reception

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Alina Friedrichsen (2):
      mac80211: Creating new IBSS with fixed BSSID
      mac80211: IBSS join rework

Andrey Borzenkov (1):
      orinoco: checkpatch cleanup

Danny Kukawka (5):
      iwlwifi: fix led naming
      ath9k: fix led naming
      b43legacy: fix led naming
      rt2x00: fix led naming
      iwlwifi: another led naming fix

Felix Fietkau (1):
      ath5k: properly free rx dma descriptors

Harvey Harrison (1):
      wireless: replace uses of __constant_{endian}

Ivo van Doorn (4):
      rt2x00: Move intf_work to mac82011 workqueue
      rt2x00: Add kill_tx_queue callback function
      rt2x00: Validate firmware in driver
      Add new rt73usb USB ID

Jay Sternberg (7):
      iwlwifi: add new HW_REV_TYPEs for Intel WiFi Link 100, 6000 and 6050 Series
      iwlwifi: simplify parameter setting to allow support for 6000 series
      iwlwifi: parametrize configuration of the PLL for exclusion on 6000
      iwlwifi: correct API command overlap
      iwlwifi: define structures and functions externally for customization
      iwlwifi: remove chain noise calibration functions from 6000 family
      ipw2x00: correct Kconfig to prevent following entries from not indenting

Johannes Berg (3):
      mac80211: remove HW_SIGNAL_DB
      mac80211: convert to net_device_ops
      mac80211: convert master interface to netdev_ops

Luis R. Rodriguez (6):
      ath9k: replace usage of internal wireless_modes for conf
      ath9k: move check for radar freqs into a helper
      ath9k: remove passive scan on 5 GHz if country IE knows better
      mac80211: do not TX injected frames when not allowed
      cfg80211: add get reg command
      ath9k: fix reg_notifier() flags used upon a country IE

Michael Buesch (6):
      b43: Add LP-PHY register definitions
      b43: Add LP-PHY baseband init for >=rev2
      b43: Add LP 2062 radio init
      ssb: Add PMU support
      b43: Port spec bugfixes for the LP baseband init
      b43: (b2062) Fix crystal frequency calculations

Mike Rapoport (1):
      libertas: if_spi: add ability to call board specific setup/teardown methods

Roel Kluin (1):
      libertas: pos[4] tested twice, 2nd should be pos[5]

Samuel Ortiz (1):
      iwl3945: Getting rid of the *39_rxon iwl_priv fields

Sujith (7):
      ath9k: Fix lockdep warning
      mac80211: Reset assoc_scan_tries after an unsuccessful scan run
      ath9k: Fix typo in checking for chip revision
      ath9k: Remove a bunch of unused macros
      ath9k: Cleanup get_rate() interface
      ath9k: Handle mac80211's RC flags for MCS rates
      ath9k: Add debugfs files for printing TX rate details

Tomas Winkler (1):
      iwlwifi: don't use implicit priv in IWL_DEBUG

Vasanthakumar Thiagarajan (2):
      ath9k: Fix LED blink pattern
      mac80211: Remove bss information of the current AP when it goes out of range

Vivek Natarajan (1):
      ath9k: Enable MIB and TIM interrupts for station mode.

Winkler, Tomas (4):
      iwlwifi: suppress unused variable warning when compiling w/o IWLWIFI_DEBUG
      iwlwifi: iwl3945_send_tx_power must be static
      iwlwifi: check return value of pci_enable_device
      iwlwifi: unify iwlagn and 3945 power save management

 drivers/net/wireless/ath5k/base.c                 |   15 +-
 drivers/net/wireless/ath9k/core.h                 |   35 +-
 drivers/net/wireless/ath9k/debug.c                |  100 ++
 drivers/net/wireless/ath9k/hw.c                   |    2 +-
 drivers/net/wireless/ath9k/mac.c                  |    3 -
 drivers/net/wireless/ath9k/main.c                 |  102 ++-
 drivers/net/wireless/ath9k/rc.c                   |  173 ++-
 drivers/net/wireless/ath9k/reg.h                  |   11 -
 drivers/net/wireless/ath9k/regd.c                 |   33 +-
 drivers/net/wireless/ath9k/xmit.c                 |  136 +--
 drivers/net/wireless/b43/Makefile                 |    1 +
 drivers/net/wireless/b43/phy_lp.c                 |  220 ++++-
 drivers/net/wireless/b43/phy_lp.h                 |  315 +++++-
 drivers/net/wireless/b43/tables_lpphy.c           |  333 +++++
 drivers/net/wireless/b43/tables_lpphy.h           |   23 +
 drivers/net/wireless/b43legacy/leds.c             |    8 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c     |    4 +-
 drivers/net/wireless/hostap/hostap_ap.c           |    8 +-
 drivers/net/wireless/hostap/hostap_ioctl.c        |    6 +-
 drivers/net/wireless/ipw2x00/Kconfig              |    1 +
 drivers/net/wireless/ipw2x00/ipw2200.c            |    2 +-
 drivers/net/wireless/iwlwifi/Makefile             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-100.c            |    5 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c       |   14 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c        |   86 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c           |  130 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h           |    8 -
 drivers/net/wireless/iwlwifi/iwl-4965.c           |  130 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c           |  165 ++--
 drivers/net/wireless/iwlwifi/iwl-6000.c           |   42 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd-check.c |  109 --
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c         |  104 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c            |  644 +++--------
 drivers/net/wireless/iwlwifi/iwl-calib.c          |   85 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-core.c           |  482 +++++++-
 drivers/net/wireless/iwlwifi/iwl-core.h           |   26 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h            |    3 +
 drivers/net/wireless/iwlwifi/iwl-debug.h          |  103 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h            |   19 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-io.h             |   20 +-
 drivers/net/wireless/iwlwifi/iwl-led.c            |   22 +-
 drivers/net/wireless/iwlwifi/iwl-led.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c          |   35 +-
 drivers/net/wireless/iwlwifi/iwl-power.h          |   28 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c             |   37 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c           |   62 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.c       |    8 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c            |   36 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c             |   54 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c       | 1392 ++++++---------------
 drivers/net/wireless/libertas/if_spi.c            |   15 +
 drivers/net/wireless/libertas/scan.c              |    2 +-
 drivers/net/wireless/orinoco/airport.c            |   35 +-
 drivers/net/wireless/orinoco/hermes.c             |  102 +-
 drivers/net/wireless/orinoco/hermes.h             |   35 +-
 drivers/net/wireless/orinoco/hermes_dld.c         |    4 +-
 drivers/net/wireless/orinoco/orinoco.c            |    2 +-
 drivers/net/wireless/orinoco/orinoco.h            |   17 +-
 drivers/net/wireless/orinoco/orinoco_cs.c         |   31 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c     |    7 +-
 drivers/net/wireless/orinoco/orinoco_pci.c        |    5 +-
 drivers/net/wireless/orinoco/orinoco_pci.h        |   10 +-
 drivers/net/wireless/orinoco/orinoco_plx.c        |    3 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c        |    2 +-
 drivers/net/wireless/orinoco/spectrum_cs.c        |   15 +-
 drivers/net/wireless/rt2x00/rt2400pci.c           |   30 +-
 drivers/net/wireless/rt2x00/rt2500pci.c           |   30 +-
 drivers/net/wireless/rt2x00/rt2500usb.c           |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h              |    9 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c           |    7 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c      |   27 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h           |   13 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c           |    6 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c         |   19 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h           |   10 +
 drivers/net/wireless/rt2x00/rt2x00usb.c           |   62 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h           |   11 +
 drivers/net/wireless/rt2x00/rt61pci.c             |   66 +-
 drivers/net/wireless/rt2x00/rt73usb.c             |   31 +-
 drivers/net/wireless/zd1211rw/zd_mac.c            |    2 +-
 drivers/ssb/Makefile                              |    1 +
 drivers/ssb/driver_chipcommon.c                   |   14 +-
 drivers/ssb/driver_chipcommon_pmu.c               |  508 ++++++++
 include/linux/nl80211.h                           |    4 +
 include/linux/spi/libertas_spi.h                  |    7 +
 include/linux/ssb/ssb_driver_chipcommon.h         |  224 ++++
 include/net/mac80211.h                            |   22 +-
 net/mac80211/iface.c                              |   47 +-
 net/mac80211/main.c                               |   29 +-
 net/mac80211/mlme.c                               |   48 +-
 net/mac80211/rx.c                                 |   19 +-
 net/mac80211/tx.c                                 |   21 +
 net/mac80211/wext.c                               |    3 +-
 net/wireless/nl80211.c                            |   81 ++
 net/wireless/reg.c                                |    2 +-
 net/wireless/reg.h                                |    2 +
 101 files changed, 4269 insertions(+), 2798 deletions(-)
 create mode 100644 drivers/net/wireless/b43/tables_lpphy.c
 create mode 100644 drivers/net/wireless/b43/tables_lpphy.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-hcmd-check.c
 create mode 100644 drivers/ssb/driver_chipcommon_pmu.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-02-09.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
