From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-04-25
Date: Wed, 25 Apr 2012 15:14:19 -0400
Message-ID: <20120425191418.GC16900@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RASg3xLB4tUQ4RcS"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44925 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756528Ab2DYTRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 15:17:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--RASg3xLB4tUQ4RcS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 77ae367f6496b067b9ba53fbb6e8356bd71b6e3e

Dave,

This is another batch of updates intended for 3.5...

Nothing too special this round -- highlights include some iwlwifi
refactoring, some ath9k refactoring, some rtlwifi refactoring, and
some mac80211 mesh refactoring.  It must be Springtime!  Along with
all the refactoring, there is the usual variety of random tweaks here
and there in the wireless stack.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 872f24dbc604ef585ea7eec73020dcdfaffd1956:

  tipc: remove inline instances from C source files. (2012-04-24 00:41:03 -=
0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Amitkumar Karwar (1):
      mwifiex: add support for Marvell USB8797 chipset

Andrei Emeltchenko (1):
      mac80211: Adds clean sdata helper

Anisse Astier (2):
      rt2800: debugfs register access: BBP is 256 bytes big
      rt2800: add chipset revision RT5390R support

Bala Shanmugam (1):
      cfg80211: Validate legacy rateset.

Ben Greear (2):
      mac80211: Support on-channel scan option.
      ath9k: Fix compile warnings when DEBUGFS is disabled.

Daniel Drake (1):
      libertas CS: convert to asynchronous firmware loading

David Spinadel (4):
      iwlwifi: Change disable calibration bit-set to enum
      iwlwifi: Added foreward declaration for iwl_cfg in op_mode
      iwlwifi: Remove inconsistent and redundant declaration
      iwlwifi: Added debugfs calib disabled write

Don Fry (1):
      iwlwifi: revert workaround to restore 1000 rx throughput

Emmanuel Grumbach (16):
      iwlwifi: kill shrd->drv, driver points to transport
      iwlwifi: op_mode holds its pointer to the transport
      iwlwifi: op_mode holds its pointer to the config
      iwlwifi: driver holds its pointer to the config
      iwlwifi: transport holds its pointer to the config
      iwlwifi: driver holds its pointer to the transport
      iwlwifi: don't use shared for the logger any more
      iwlwifi: remove the shared area
      iwlwifi: remove unneeded includes
      iwlwifi: split between AGG_ON and AGG_STARTING
      iwlwifi: move iwl_rxon_context_id to user
      iwlwifi: make a static inline to read the RF kill register
      iwlwifi: first enable RF kill interrupt, then check register
      iwlwifi: enable RF kill interrupt in start_hw
      iwlwifi: check RF kill register when interrupts have been disabled
      iwlwifi: provide proper API to disable all interrupts

Felix Fietkau (12):
      ath9k: add possible wiphy interface combinations
      libertas: add missing include
      ath9k_hw: use standard SIFS time as reference for half/quarter channe=
ls
      ath9k_hw: increase ACK timeout for half/quarter channels
      ath9k_hw: set the PHY mode for half/quarter channels on AR9003
      ath9k_hw: increase symbol overlap window for half/quarter channels
      ath9k_hw: fix and clean up PHY activation delay
      ath9k_hw: disable Tx IQ calibration on half/quarter channels
      ath9k_hw: disable fast channel change when changing from/to half/quar=
ter mode
      ath9k_hw: increase tx abort timeout for half/quarter channels
      mac80211: rename AP variable num_sta_authorized to num_mcast_sta
      mac80211: fix num_mcast_sta counting issues

Gabor Juhos (1):
      ath9k: fix TX power reporting on AR9003 chips

Helmut Schaa (1):
      rt2x00: Use GFP_KERNEL for rx buffer allocation on USB devices

Javier Cardona (1):
      mac80211: fixup for mesh TSF adjustment latency in Toffset setpoint

Johannes Berg (22):
      iwlwifi: improve TX cache footprint
      iwlwifi: properly set basic rates
      iwlwifi: remove debugfs logspam
      iwlwifi: move debugfs registration function declarations
      iwlwifi: move iwl_have_debug_level
      iwlwifi: clean up iwl-shared.h includes
      iwlwifi: remove bt_siso_mode declaration
      iwlwifi: move TIME_UNIT
      iwlwifi: move iwl_cmd_echo_test
      iwlwifi: remove traffic log
      iwlwifi: remove TX/RX frame statistics
      iwlwifi: remove duplicate iwlagn_mod_params declaration
      iwlwifi: move driver defines to iwl-drv.h
      iwlwifi: move PLCP defines to config
      iwlwifi: move watchdog definitions to config
      iwlwifi: move eeprom versions to HW files
      iwlwifi: move antenna definitions to config
      iwlwifi: move OTP defines
      iwlwifi: clean up some hw file includes
      iwlwifi: use direct calls for transport free
      iwlwifi: clean up module parameters
      iwlwifi: use new mac80211 queue scheme

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Larry Finger (6):
      rtlwifi: Move dig_t and ps_t structs
      rtlwifi: Add dm structs to private structure
      rtlwifi: rtl8192c: Convert driver to use private dm structs
      rtlwifi: rtl8192c: Convert driver to use private ps_t struct
      rtlwifi: rtl8192de: Convert driver to use private dm structs
      rtlwifi: rtl8192se: Convert driver to use private dm struct

Luis R. Rodriguez (1):
      libertas: include sched.h on firmware.c

Michael Liang (1):
      ath9k: don't strip mic on non-encrypted frames in tkip

Rajkumar Manoharan (2):
      ath9k: simplify beacon configuration for beaconing vifs
      ath9k_hw: remove ATH_BTCOEX_CFG_MCI

Sujith Manoharan (1):
      ath9k: Fix IDLE Powersave

Thomas Pedersen (4):
      mac80211: refactor mesh peer initialization
      mac80211: refactor mesh peer rate handling
      mac80211: don't set mesh peer ht caps if ht disabled
      mac80211: fix STA channel width field

Wey-Yi Guy (3):
      mac80211: declare ieee80211_ave_rssi as EXPORT
      iwlwifi: include net/mac80211.h to avoid compiler error
      mac80211: check for non-managed interface

Xose Vazquez Perez (2):
      wireless: rt2x00: rt2800usb add more devices ids
      wireless: rt2x00: rt2800usb more devices were identified

Zefir Kurtisi (2):
      ath9k: make DFS detector pools SMP safe
      ath9k: extend DFS detector stats in dfs_debugfs

 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   17 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   64 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   28 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    3 +
 drivers/net/wireless/ath/ath9k/beacon.c            |    4 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |   14 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    1 -
 drivers/net/wireless/ath/ath9k/dfs.c               |    4 +
 drivers/net/wireless/ath/ath9k/dfs_debug.c         |   46 +
 drivers/net/wireless/ath/ath9k/dfs_debug.h         |   45 +-
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c  |  130 ++-
 drivers/net/wireless/ath/ath9k/gpio.c              |   21 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   42 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    5 +-
 drivers/net/wireless/ath/ath9k/init.c              |   21 +
 drivers/net/wireless/ath/ath9k/mac.c               |   10 +-
 drivers/net/wireless/ath/ath9k/main.c              |  105 +--
 drivers/net/wireless/ath/ath9k/recv.c              |    3 +-
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   17 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.h       |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-devices.c     |   25 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |   11 +
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   42 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |   36 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   22 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |  128 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |   18 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   61 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  308 ++----
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   26 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   28 +
 drivers/net/wireless/iwlwifi/iwl-core.c            |  297 ------
 drivers/net/wireless/iwlwifi/iwl-core.h            |  133 ---
 drivers/net/wireless/iwlwifi/iwl-debug.c           |    1 +
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   34 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  309 ++-----
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   99 +--
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  151 +++-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |   25 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   64 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   53 -
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    1 +
 drivers/net/wireless/iwlwifi/iwl-io.h              |    1 -
 drivers/net/wireless/iwlwifi/iwl-led.c             |   21 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   88 +-
 .../iwlwifi/{iwl-shared.h =3D> iwl-modparams.h}      |   78 +--
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    2 +
 drivers/net/wireless/iwlwifi/iwl-pci.c             |   60 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |    5 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |   19 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |    9 -
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |   27 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |   43 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |   11 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |   35 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |  184 ++--
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   49 +-
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |   25 +-
 drivers/net/wireless/libertas/firmware.c           |    2 +
 drivers/net/wireless/libertas/if_cs.c              |   88 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |   36 +-
 drivers/net/wireless/mwifiex/Kconfig               |   11 +
 drivers/net/wireless/mwifiex/Makefile              |    3 +
 drivers/net/wireless/mwifiex/cmdevt.c              |   63 +-
 drivers/net/wireless/mwifiex/decl.h                |    1 +
 drivers/net/wireless/mwifiex/fw.h                  |    5 +
 drivers/net/wireless/mwifiex/init.c                |   64 +-
 drivers/net/wireless/mwifiex/main.c                |   26 +-
 drivers/net/wireless/mwifiex/main.h                |   20 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |   15 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |   12 +-
 drivers/net/wireless/mwifiex/txrx.c                |   21 +-
 drivers/net/wireless/mwifiex/usb.c                 | 1052 ++++++++++++++++=
++++
 drivers/net/wireless/mwifiex/usb.h                 |   99 ++
 drivers/net/wireless/mwifiex/util.c                |   22 +
 drivers/net/wireless/mwifiex/wmm.c                 |   18 +-
 drivers/net/wireless/rt2x00/rt2800.h               |    3 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   12 +
 drivers/net/wireless/rt2x00/rt2800usb.c            |   25 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  290 +++---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h  |   35 -
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |   35 -
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |  185 ++--
 drivers/net/wireless/rtlwifi/rtl8192de/dm.h        |   51 -
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |  156 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h        |   44 -
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |    7 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   63 ++
 include/net/mac80211.h                             |    8 +
 net/mac80211/cfg.c                                 |   19 +
 net/mac80211/debugfs_netdev.c                      |    4 +-
 net/mac80211/ieee80211_i.h                         |    5 +-
 net/mac80211/iface.c                               |   19 +-
 net/mac80211/main.c                                |    4 +-
 net/mac80211/mesh.c                                |   19 +-
 net/mac80211/mesh.h                                |   14 +-
 net/mac80211/mesh_plink.c                          |  138 ++--
 net/mac80211/mesh_sync.c                           |    2 +-
 net/mac80211/rx.c                                  |    2 +
 net/mac80211/scan.c                                |   95 ++-
 net/mac80211/sta_info.c                            |   12 +-
 net/mac80211/tx.c                                  |    2 +-
 net/mac80211/util.c                                |    9 +-
 net/wireless/nl80211.c                             |    3 +
 123 files changed, 3468 insertions(+), 2565 deletions(-)
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-core.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-core.h
 rename drivers/net/wireless/iwlwifi/{iwl-shared.h =3D> iwl-modparams.h} (6=
6%)
 create mode 100644 drivers/net/wireless/mwifiex/usb.c
 create mode 100644 drivers/net/wireless/mwifiex/usb.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--RASg3xLB4tUQ4RcS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPmE0KAAoJEJctW/TcYTgGVv0P/RLQYxrC93IaVgWbipl+sfoP
gC/pIM1L0ltt7w2OuEDNlwQvzotWljLV8CssQkyhKwvuqL58i29NKn49+XnldeXl
DC1B1PYLr1sP9TPrpsUviTyUofjGXgMMob3NGLozg99gO97bUhbkBGHFlX3bbUQs
a8nwP1qaXBArxiV0FmMu8LxOenErQfuBPMZCzGJ+YfXsjbIddJ7FD7opg824s9tJ
HUDdm+BN5DRNRZt3vPfKAXUmI9eYRTW48L6zGJ2PJk5hU0WMypfU7eKzqt7XBq2S
ZEMO2PHKoo9hmDQhGeC5gtOXws5CPF6j7Ge7tbd49pL66/xo3tN6gr110DDHDxhO
qTqPToFYXY00TGdP5DRa2psa7QiAYSmhrJQ38/lLUqO+nywRZ7WmDqpxlOOR+zcK
BgLxHGkUwvS6DRYclDeqn5Q3wKBlbsx4bGRBK+LsVZ01BEYc3ya2lhCJPYZmoUmH
+YedqNXzdOK8hOR7oaGtpjKzbMMt7G8Glab3pB6qF2++dSsdkaaXr40y3BJWK2B5
seetqxVfYVxI5YHmjbhUsv84SLvY/oVbtXhq39Jo/X/Q0XEX8M3jM/wFUjtYQkFY
5T5ww51Qq62PUARV8S74jdz/ZsMZv9RrJ8lC2ZbCV8zWkgQbBOyKpvbgFQOjT5b0
xxpbrstb+6aQxp2AaKTZ
=sqfH
-----END PGP SIGNATURE-----

--RASg3xLB4tUQ4RcS--
