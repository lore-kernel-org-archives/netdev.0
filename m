From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-03-19
Date: Fri, 19 Mar 2010 16:45:08 -0400
Message-ID: <20100319204507.GF9552@tuxdriver.com>
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

Here is the first big dump of wireless bit for the 2.6.35 cycle...

Included are the usual driver updates, etc.  In particular, the Intel
and Nokia guys have been busy as usual. :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1c01fe14a87332cc88266fbd6e598319322e=
b96f:
  Jiri Pirko (1):
        net: forbid underlaying devices to change its type

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (1):
      iwl3945: check ucode load error code

Alban Browaeys (2):
      rt2x00: txdone implementation supporting hw encryption.
      rt2x00: Fix TX status reporting for rt2800pci.

Andres Salomon (1):
      mac80211: give warning if building w/out rate ctrl algorithm

Andrew Blaich (1):
      ath5k: fixing retries in ath5k_hw_setup_4word_tx_desc

Benoit Papillault (1):
      ath5k: Fix TX/RX padding for all frames

Bruno Randolf (11):
      mac80211: fix rates setup on IBSS merge
      ath5k: add antenna statistics and debugfs file for antenna settin=
gs
      ath5k: preserve antenna settings
      ath5k: remove double opmode definition
      ath5k: remove ah_magic
      ath5k: remove ah_mac_revision
      ath5k: remove ah_gpio_npins
      ath5k: add debugfs file frameerrors
      ath5k: IQ calibration for AR5211 is slightly different
      ath5k: Minor EEPROM documentation updates
      mac80211: (really) fix rates setup on IBSS merge

Christian Lamparter (1):
      p54: Enable HW_REPORTS_TX_ACK_STATUS

=46elix Fietkau (4):
      minstrel: simplify and fix debugfs code
      minstrel: make the rate control ops reusable from another rc impl=
ementation
      ath9k: fix rate control tx status handling for A-MPDU
      mac80211: optimize tx status processing

Grazvydas Ignotas (3):
      wl1251: make local symbols static
      wl1251: fix ELP_CTRL register accesses when using SDIO
      wl1251: reduce eeprom read wait time

Helmut Schaa (2):
      mac80211: Improve software scan timing
      rt2x00: fix warning when building rt2800pci with just soc support

Johannes Berg (20):
      mac80211: deprecate RX status noise
      mac80211: use different MAC addresses for virtual interfaces
      iwlagn: move ICT code into separate file
      iwlwifi: move 3945 specific data into union
      iwlwifi: move ICT data to agn part of union
      iwlagn: remove write-only variables
      iwlwifi: remove superfluous channel check
      iwlwifi: remove dead code from iwl_mac_reset_tsf
      iwlwifi: remove frame dropping
      iwlwifi: remove never-changing priv->rates_mask variable
      iwlwifi: remove priv->active_rate_basic
      iwlwifi: remove IBSS channel sanity check
      iwlwifi: remove sanity check
      iwlwifi: clear up AC/FIFO debug output
      iwlwifi: move 3945 clip groups to 3945 data
      iwlwifi: remove alive start adhoc restart
      iwlwifi: remove STATUS_MODE_PENDING
      iwlagn: move sysfs flags and filter_flags files to debugfs
      iwlwifi: change WEP key protection to use mutex
      iwlwifi: clean up queue/fifo handling

John W. Linville (4):
      ath5k: remove some dead functions
      ath5k: remove dead source in ath5k_combine_linear_pcdac_curves
      ath5k: remove unused beacon timer code
      Revert "mac80211: fix rates setup on IBSS merge"

Jussi Kivilinna (4):
      rndis_wlan: copy only useful data from rndis_command respond
      rndis_wlan: remove unused variables from priv structure
      rndis_wlan: get max_num_pmkids from device
      rndis_wlan: Implement cfg80211 PMKSA API

Juuso Oikarinen (12):
      wl1271: Improvements to the TX path
      wl1271: Fix ad-hoc mode neighborhood detection
      wl1271: Fix queue stopping/waking for TX path
      wl1271: Remove annoying PSM entry/exit kernel traces
      wl1271: Aggregate RX acknowledgements to FW
      wl1271: Don't mask interrupts while handling interrupt
      wl1271: Implement looped IRQ handling
      wl1271: Update TX packet life time handling with higher resolutio=
n time
      wl1271: Clean up firmware block allocation calculation
      wl1271: Clean up TX security sequence number handling
      wl1271: Disable host TX rate control
      wl1271: Remove tx-power level workaround

Kalle Valo (1):
      wl1271: don't get received frames from hardware in PLT mode

Larry Finger (1):
      ssb: Export ssb_chipco_gpio_control - needed by N PHY code

Matthieu CASTET (2):
      airo : fix printing status info
      airo : Print of firmware version

Pavel Roskin (6):
      ath5k: remove stale function declarations, make some functions st=
atic
      ath5k: remove useless "extern" from function declarations
      ath5k: move ath5k_hw_register_timeout() into reset.c
      ath9k: never read from the AR_IMR_S2 register
      orinoco: disable support for prism chipset by default
      ipw2x00: replace "ieee80211" with "libipw" where appropriate

Rafa=C5=82 Mi=C5=82ecki (10):
      b43: N-PHY: add some registers and structs definitions
      b43: N-PHY: initialize super switch
      b43: N-PHY: turn radio on/off (rfkill)
      b43: N-PHY: update writing channel-specific radio registers
      b43: N-PHY: update post init of 2055 radio
      b43: N-PHY: switch to chanspec struct
      b43: N-PHY: adjust gain table
      b43: N-PHY: isloate 2055 radio setup
      b43: N-PHY: implement chanspec setup
      b43: N-PHY: switch to chanspec ops

Reinette Chatre (1):
      iwlwifi: remove needlessly exported symbols

Stewart Malik (1):
      DRIVER: Libertas: Fixed coding style in rx.c

Teemu Paasikivi (10):
      wl1271: Moved module basics to wl1271_spi.c
      wl1271: Added functions to enable/disable interrupt handling
      wl1271: Implemented abstraction of IO functions.
      wl1271: Inlined IO functions
      wl1271: Removed wl1271_spi.h and made some functions static
      wl1271: Divided driver to two separate modules
      wl1271: Initial SDIO implementation
      wl1271: Changed access to fw status register to use raw read
      wl1271: Fixed unloading of the wl1271_sdio module
      wl1271: Changed wl1271_sdio to be selectable only on ARM

Wey-Yi Guy (4):
      iwlwifi: remove un-necessary parameters
      iwlwifi: remove duplicate function
      iwlwifi: remove unnecessary parameter in scan function
      iwlwifi: add internal short scan support for 3945

Zhu Yi (7):
      iwmc3200wifi: refuse to associate on unallowed channels
      iwmc3200wifi: remove "_safe" for some list_for_each_entry usage
      iwmc3200wifi: add ftrace event tracing support
      iwmc3200wifi: protect rx_tickets and rx_packets[] lists
      iwmc3200wifi: increase concatenated buffer
      iwmc3200wifi: mark some pmksa functions static
      iwmc3200wifi: typo fix and code cleanup

florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org (3):
      Document the rfkill sysfs ABI
      enhance sysfs rfkill interface
      rename new rfkill sysfs knobs

 Documentation/ABI/obsolete/sysfs-class-rfkill |   29 ++
 Documentation/ABI/stable/sysfs-class-rfkill   |   67 ++++
 Documentation/feature-removal-schedule.txt    |   18 +
 Documentation/rfkill.txt                      |   44 +--
 drivers/net/wireless/airo.c                   |   37 ++-
 drivers/net/wireless/ath/ath5k/ath5k.h        |  257 +++++---------
 drivers/net/wireless/ath/ath5k/attach.c       |    5 +-
 drivers/net/wireless/ath/ath5k/base.c         |  150 +++++++--
 drivers/net/wireless/ath/ath5k/base.h         |   20 +
 drivers/net/wireless/ath/ath5k/caps.c         |    3 -
 drivers/net/wireless/ath/ath5k/debug.c        |  212 +++++++++++
 drivers/net/wireless/ath/ath5k/debug.h        |    2 +
 drivers/net/wireless/ath/ath5k/desc.c         |   18 +-
 drivers/net/wireless/ath/ath5k/eeprom.c       |    4 +-
 drivers/net/wireless/ath/ath5k/eeprom.h       |   88 ++++--
 drivers/net/wireless/ath/ath5k/pcu.c          |  306 +----------------
 drivers/net/wireless/ath/ath5k/phy.c          |   43 +--
 drivers/net/wireless/ath/ath5k/qcu.c          |   17 -
 drivers/net/wireless/ath/ath5k/reg.h          |    2 +-
 drivers/net/wireless/ath/ath5k/reset.c        |   38 ++-
 drivers/net/wireless/ath/ath9k/hw.c           |   16 +-
 drivers/net/wireless/ath/ath9k/hw.h           |    1 +
 drivers/net/wireless/ath/ath9k/mac.c          |    6 +-
 drivers/net/wireless/ath/ath9k/rc.c           |    8 +-
 drivers/net/wireless/ath/ath9k/rc.h           |    1 -
 drivers/net/wireless/ath/ath9k/xmit.c         |    4 +-
 drivers/net/wireless/b43/b43.h                |    1 +
 drivers/net/wireless/b43/phy_n.c              |  463 +++++++++++++++++=
++------
 drivers/net/wireless/b43/phy_n.h              |   21 +-
 drivers/net/wireless/b43/tables_nphy.h        |    9 +
 drivers/net/wireless/ipw2x00/ipw2100.c        |   10 +-
 drivers/net/wireless/ipw2x00/ipw2200.c        |   18 +-
 drivers/net/wireless/ipw2x00/libipw.h         |   14 +-
 drivers/net/wireless/ipw2x00/libipw_module.c  |   13 +-
 drivers/net/wireless/iwlwifi/Makefile         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h    |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c    |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c       |   42 ++-
 drivers/net/wireless/iwlwifi/iwl-4965.c       |   20 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c       |   40 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c    |  305 ++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn.c        |  110 +------
 drivers/net/wireless/iwlwifi/iwl-agn.h        |   74 ++++
 drivers/net/wireless/iwlwifi/iwl-core.c       |  418 ++---------------=
-----
 drivers/net/wireless/iwlwifi/iwl-core.h       |    8 -
 drivers/net/wireless/iwlwifi/iwl-debugfs.c    |   82 ++---
 drivers/net/wireless/iwlwifi/iwl-dev.h        |   90 +++---
 drivers/net/wireless/iwlwifi/iwl-helpers.h    |    3 +
 drivers/net/wireless/iwlwifi/iwl-prph.h       |   14 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c         |   24 --
 drivers/net/wireless/iwlwifi/iwl-scan.c       |    9 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c        |   18 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c         |  115 ++++---
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |   78 ++---
 drivers/net/wireless/iwmc3200wifi/Kconfig     |    9 +-
 drivers/net/wireless/iwmc3200wifi/Makefile    |    3 +
 drivers/net/wireless/iwmc3200wifi/cfg80211.c  |   17 +-
 drivers/net/wireless/iwmc3200wifi/commands.c  |   14 +-
 drivers/net/wireless/iwmc3200wifi/commands.h  |    1 +
 drivers/net/wireless/iwmc3200wifi/debugfs.c   |   13 +-
 drivers/net/wireless/iwmc3200wifi/hal.c       |   15 +-
 drivers/net/wireless/iwmc3200wifi/hal.h       |    5 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h       |    3 +
 drivers/net/wireless/iwmc3200wifi/main.c      |    9 +-
 drivers/net/wireless/iwmc3200wifi/rx.c        |   76 +++--
 drivers/net/wireless/iwmc3200wifi/trace.c     |    3 +
 drivers/net/wireless/iwmc3200wifi/trace.h     |  283 +++++++++++++++
 drivers/net/wireless/iwmc3200wifi/tx.c        |    8 +-
 drivers/net/wireless/iwmc3200wifi/umac.h      |    2 +-
 drivers/net/wireless/libertas/rx.c            |   50 ++--
 drivers/net/wireless/orinoco/Kconfig          |   13 +-
 drivers/net/wireless/orinoco/hw.c             |    7 +
 drivers/net/wireless/orinoco/orinoco_cs.c     |   79 +++--
 drivers/net/wireless/p54/main.c               |    1 +
 drivers/net/wireless/rndis_wlan.c             |  364 +++++++++++++++++=
+-
 drivers/net/wireless/rt2x00/rt2800pci.c       |   93 +++---
 drivers/net/wireless/wl12xx/Kconfig           |   24 ++
 drivers/net/wireless/wl12xx/Makefile          |    6 +-
 drivers/net/wireless/wl12xx/wl1251.h          |    2 +
 drivers/net/wireless/wl12xx/wl1251_boot.c     |    3 +-
 drivers/net/wireless/wl12xx/wl1251_io.h       |   20 +
 drivers/net/wireless/wl12xx/wl1251_main.c     |    4 +-
 drivers/net/wireless/wl12xx/wl1251_ps.c       |    8 +-
 drivers/net/wireless/wl12xx/wl1251_sdio.c     |   52 ++-
 drivers/net/wireless/wl12xx/wl1271.h          |   33 ++-
 drivers/net/wireless/wl12xx/wl1271_acx.c      |    8 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c     |    3 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c      |    8 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h      |    2 +-
 drivers/net/wireless/wl12xx/wl1271_event.c    |    1 -
 drivers/net/wireless/wl12xx/wl1271_io.c       |   87 ++----
 drivers/net/wireless/wl12xx/wl1271_io.h       |  122 ++++++-
 drivers/net/wireless/wl12xx/wl1271_main.c     |  336 +++++------------=
--
 drivers/net/wireless/wl12xx/wl1271_ps.c       |    1 -
 drivers/net/wireless/wl12xx/wl1271_rx.c       |   11 +-
 drivers/net/wireless/wl12xx/wl1271_sdio.c     |  307 ++++++++++++++++
 drivers/net/wireless/wl12xx/wl1271_spi.c      |  267 ++++++++++++++-
 drivers/net/wireless/wl12xx/wl1271_spi.h      |   96 -----
 drivers/net/wireless/wl12xx/wl1271_testmode.c |    1 -
 drivers/net/wireless/wl12xx/wl1271_tx.c       |   94 +++---
 drivers/net/wireless/wl12xx/wl1271_tx.h       |    4 +-
 drivers/ssb/driver_chipcommon.c               |    1 +
 include/net/mac80211.h                        |    4 +-
 net/mac80211/Kconfig                          |    9 +
 net/mac80211/debugfs_sta.c                    |    2 -
 net/mac80211/ibss.c                           |   16 +-
 net/mac80211/ieee80211_i.h                    |    1 +
 net/mac80211/iface.c                          |  116 ++++++-
 net/mac80211/rc80211_minstrel.c               |    2 +-
 net/mac80211/rc80211_minstrel.h               |   11 +
 net/mac80211/rc80211_minstrel_debugfs.c       |   41 +--
 net/mac80211/rx.c                             |    9 -
 net/mac80211/scan.c                           |   71 ++++-
 net/mac80211/sta_info.h                       |    2 -
 net/mac80211/status.c                         |   14 +-
 net/rfkill/core.c                             |   53 +++-
 120 files changed, 3964 insertions(+), 2377 deletions(-)
 create mode 100644 Documentation/ABI/obsolete/sysfs-class-rfkill
 create mode 100644 Documentation/ABI/stable/sysfs-class-rfkill
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-ict.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/trace.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/trace.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_sdio.c
 delete mode 100644 drivers/net/wireless/wl12xx/wl1271_spi.h

Omnibus patch available here:

http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.=
6-2010-03-19.patch.bz2=20

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
