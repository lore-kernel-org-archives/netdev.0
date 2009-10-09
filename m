From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-10-09
Date: Fri, 9 Oct 2009 17:05:55 -0400
Message-ID: <20091009210555.GC22861@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39960 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934424AbZJIVQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 17:16:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the usual big first post-window pull request for -next...
Mostly it is the usual suspects, lots of iwlwifi and ath* along
with a smattering of other bits.  There are even a few from me! :-)
Most of these have spent several days banging-around in -next (which
helped to find some Kconfig problems).

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit d519e17e2d01a0ee9abe083019532061b4438065:
  Andy Gospodarek (1):
        net: export device speed and duplex via sysfs

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (2):
      iwlwifi/iwl3945 : unify apm stop operation
      iwlwifi: replace iwl_poll_direct_bit with iwl_poll_bit for CSR access

Amitkumar Karwar (2):
      libertas: Add auto deep sleep support for SD8385/SD8686/SD8688
      libertas: Use lbs_is_cmd_allowed() check in command handling routines.

Christian Lamparter (1):
      iwlwifi: drop lib80211 dependency

Daniel C Halperin (3):
      iwlwifi: clean up rs_tx_status
      iwlwifi: do not clear TX info flags when receiving BlockAckResponse
      iwlwifi: add aggregation tables to the rate scaling algorithm

Holger Schurig (5):
      nl80211: report age of scan results
      libertas: separate libertas' Kconfig in it's own file
      libertas: first stab at cfg80211 support
      libertas: remove extraneous select FW_LOADER
      libertas: depend on CONFIG_CFG80211

Huaxu Wan (2):
      iwlwifi: add module firmware info for 1000 series
      iwlwifi: clear the translate table area

Jaswinder Singh Rajput (1):
      b43: Comment unused functions lpphy_restore_dig_flt_state and lpphy_disable_rx_gain_override

Joerg Albert (3):
      ar9170: fixed coding style, moved define
      ar9170: add heavy clip handling
      ar9170: handle overflow in tsf_low register during get_tsf

Johannes Berg (10):
      iwlwifi: clean up ht config a little
      iwlwifi: clean up ht config naming
      iwlwifi: clarify and clean up chain settings
      iwlwifi: fix a typo
      iwlwifi: default to using all chains
      iwlwifi: support idle for 6000 series hw
      wext: refactor
      iwlwifi: device tracing
      iwlwifi: LED cleanup
      wireless: make wireless drivers select core

John W. Linville (6):
      wireless: implement basic ethtool support for cfg80211 devices
      mac80211: support ETHTOOL_GPERMADDR
      iwmc3200wifi: support ETHTOOL_GPERMADDR
      ipw2200: support ETHTOOL_GPERMADDR
      orinoco: support ETHTOOL_GPERMADDR
      net/wireless/ethtool.h: drop unnecessary include of linux/ethtool.h

Kalle Valo (3):
      wl1251: remove wl1251_netlink.h
      cfg80211: add firmware and hardware version to wiphy
      at76c50x-usb: set firmware and hardware version in wiphy

Larry Finger (1):
      staging: Add proper selection of WIRELESS_EXT and WEXT_PRIV

Luis R. Rodriguez (68):
      ath9k: use ath_hw for DPRINTF() and debug init/exit
      ath9k: move btcoex core driver info to its own struct
      ath9k: move hw specific btcoex info to ath_hw
      ath9k: split bluetooth hardware coex init into two helpers
      ath9k: move driver core helpers to main.c
      ath9k: split ath9k_hw_btcoex_enable() into two helpers
      ath9k: replaces SC_OP_BTCOEX_ENABLED with a bool
      ath9k: move bt_stomp_type to driver core
      ath9k: remove unused bt_duty_cycle
      ath9k: rename btcoex_scheme to just scheme
      ath9k: rename ath_btcoex_info to ath_btcoex_hw
      ath9k: simplify ath_btcoex_bt_stomp()
      ath9k: now move ath9k_hw_btcoex_set_weight() to btcoex.c
      ath9k: move ath_btcoex_config and ath_bt_mode to btcoex.c
      ath9k: rename ath_btcoex_supported() to ath9k_hw_btcoex_supported()
      ath9k: move ps helpers onto core driver when reseting tsf
      ath9k: move ath9k_ps_wakeup() and ath9k_ps_restore() to main.c
      ath9k: avoid usage of ath9k_hw_setpower() on hw.c
      ath9k: move ath9k_hw_setpower() to main.c
      ath9k: rename driver core and hw power save helpers
      ath: move ath_bcast_mac to common header
      atheros: use get_unaligned_le*() for bssid mask setting
      ath9k: make ath9k_hw_setbssidmask() and ath9k_hw_write_associd() use ath_hw
      ath9k: Use ath9k_hw_setbssidmask() on reset
      ath9k: use ath9k_hw_write_associd() on reset
      atheros/ath9k: move macaddr, curaid, curbssid and bssidmask to common
      ar9170: make use of common macaddr and curbssid
      ath5k: use common curbssid, bssidmask and macaddr
      ath5k: initialize eeprom struct early on attach
      ath9k: move ath_common to ath_hw
      ath5k: move ath_common to ath5k_hw
      ath9k: Define bus agnostic bluetooth coex prep helper
      atheros/ath9k: add common read/write ops and port ath9k to use it
      ath5k: allocate ath5k_hw prior to initializing hw
      ath5k: define ath_common ops
      atheros: define shared bssidmask setting
      atheros: add ieee80211_hw to ath_common
      ath9k: separate core driver and hw timer code
      atheros: add common debug printing
      atheros: move tx/rx chainmask to ath_common
      ath9k: remove ath9k 25 MHz HT40 spacing stuff
      ath9k: remove ath9k_ht_macmode
      ath9k: move ATH_AMPDU_LIMIT_MAX to hw.h
      ath9k: remove driver ASSERT, just use BUG_ON()
      ath9k: clarify what hw code is and remove ath9k.h from a few files
      ath9k: move ATH9K_RSSI_BAD to hw.h
      atheros: move bus ops to ath_common
      ath9k: make ath9k_common_ops const
      ath9k: use common read/write ops on pci and debug code
      ath9k: move hw code to its own module
      ath9k_hw: print device ID if not supported
      ath9k_hw: add AR9271 srev and device ID to allow hw to support ar9271
      atheros: define a common priv struct
      ath5k: fix regression on setting bssid mask on association
      ath5k: use ath_hw_setbssidmask() for bssid mask setting upon assoc
      ath5k: fix regression introduced upon the removal of AR5K_HIGH_ID()
      ath5k: simplify passed params to ath5k_hw_set_associd()
      ath5k: remove temporary low_id and high_id vars on ath5k_hw_set_associd()
      ath5k: fix regression which triggers an SME join upon assoc
      ath5k: enable Power-Save Polls by setting the association ID
      ath9k: move common->debug_mask setting to ath_init_softc()
      ath9k: initialize hw prior to debugfs
      ath9k: add helper to un-init the hw properly
      ath9k: add a helper to clean the core driver upon module unload
      ath9k: move ath_cleanup() below helpers to avoid forward declarations
      ath9k: rename ath_beaconq_setup() to ath9k_hw_beaconq_setup()
      ath9k: use right parameter for MODULE_PARM_DESC() for debug
      libertas: remove double assignment of dev->netdev_ops

Rafael J. Wysocki (1):
      Wireless / ath5k: Simplify suspend and resume callbacks

Randy Dunlap (1):
      wireless: fix CFG80211_WEXT build problems

Senthil Balasubramanian (5):
      ath9k: Allow PSPOLL only when the interface is configured in AP mode
      ath9k: Handle ATH9K_BEACON_RESET_TSF properly
      ath9k: Reduce PLL Settle time and eliminate redundant PLL calls.
      ath9k: Advertise midband for AR5416 devices
      ath9k: Fix bugs in handling TX power

Sujith (2):
      ath9k: Update INI release for AR9287
      ath9k: Fix RTC reset for AR5416

Vasanthakumar Thiagarajan (1):
      ath9k: Update initvals

Vivek Natarajan (1):
      ath9k: Add Calibration checks

Wey-Yi Guy (19):
      iwlwifi: modify LED blink index table
      iwlwifi: remove un-supported eeprom parameters
      iwlwifi: separate nic_config for different NIC
      iwlwifi: separate set_hw_params function for 6000 series
      iwlwifi: Adjust blink rate to compensate Clock difference
      iwlwifi: show NVM version in debugfs
      iwlwifi: Use RTS/CTS as the preferred protection mechanism for 6000 series
      iwlwifi: allow user change protection mechanism for HT
      iwlwifi: EEPROM version for 1000 and 6000 series
      iwlwifi: use S_IRUGO and S_IWUSR in module parameters
      iwlwifi: send cmd to uCode to configure valid tx antenna
      iwlwifi: update PCI Subsystem ID for 1000 series
      iwlwifi: update PCI Subsystem ID for 6000 series
      iwlwifi: add LED mode to support different LED behavior
      iwlwifi: Chain Noise Calibration for 6000 series
      iwlwifi: reliable entering of critical temperature state
      iwlwifi: change valid EEPROM version for 1000 series
      iwlwifi: set default aggregation frame count limit to 31
      iwlwifi: validate the signature for EEPROM and OTP

 drivers/net/wireless/Kconfig                 |   84 +-
 drivers/net/wireless/at76c50x-usb.c          |   10 +
 drivers/net/wireless/ath/Kconfig             |    8 +
 drivers/net/wireless/ath/Makefile            |    9 +-
 drivers/net/wireless/ath/ar9170/ar9170.h     |    4 +-
 drivers/net/wireless/ath/ar9170/cmd.c        |    3 +-
 drivers/net/wireless/ath/ar9170/cmd.h        |    1 +
 drivers/net/wireless/ath/ar9170/hw.h         |    2 +
 drivers/net/wireless/ath/ar9170/mac.c        |   15 +-
 drivers/net/wireless/ath/ar9170/main.c       |   30 +-
 drivers/net/wireless/ath/ar9170/phy.c        |   99 ++-
 drivers/net/wireless/ath/ath.h               |   41 +
 drivers/net/wireless/ath/ath5k/ath5k.h       |   40 +-
 drivers/net/wireless/ath/ath5k/attach.c      |   31 +-
 drivers/net/wireless/ath/ath5k/base.c        |  116 ++-
 drivers/net/wireless/ath/ath5k/base.h        |   12 -
 drivers/net/wireless/ath/ath5k/initvals.c    |    4 +-
 drivers/net/wireless/ath/ath5k/pcu.c         |  193 +---
 drivers/net/wireless/ath/ath5k/reg.h         |    8 +-
 drivers/net/wireless/ath/ath5k/reset.c       |   16 +-
 drivers/net/wireless/ath/ath9k/Kconfig       |    8 +
 drivers/net/wireless/ath/ath9k/Makefile      |   27 +-
 drivers/net/wireless/ath/ath9k/ahb.c         |   19 +-
 drivers/net/wireless/ath/ath9k/ani.c         |  141 ++-
 drivers/net/wireless/ath/ath9k/ath9k.h       |   73 +-
 drivers/net/wireless/ath/ath9k/beacon.c      |  112 +-
 drivers/net/wireless/ath/ath9k/btcoex.c      |  383 ++----
 drivers/net/wireless/ath/ath9k/btcoex.h      |   64 +-
 drivers/net/wireless/ath/ath9k/calib.c       |  391 ++++---
 drivers/net/wireless/ath/ath9k/calib.h       |    2 +
 drivers/net/wireless/ath/ath9k/debug.c       |   55 +-
 drivers/net/wireless/ath/ath9k/debug.h       |   36 +-
 drivers/net/wireless/ath/ath9k/eeprom.c      |    8 +-
 drivers/net/wireless/ath/ath9k/eeprom.h      |    9 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c   |   90 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c |   97 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c  |  183 ++-
 drivers/net/wireless/ath/ath9k/hw.c          |  595 +++++-----
 drivers/net/wireless/ath/ath9k/hw.h          |   63 +-
 drivers/net/wireless/ath/ath9k/initvals.h    |   72 +-
 drivers/net/wireless/ath/ath9k/mac.c         |  162 ++-
 drivers/net/wireless/ath/ath9k/mac.h         |   11 +-
 drivers/net/wireless/ath/ath9k/main.c        |  841 +++++++++----
 drivers/net/wireless/ath/ath9k/pci.c         |   37 +-
 drivers/net/wireless/ath/ath9k/phy.c         |   50 +-
 drivers/net/wireless/ath/ath9k/phy.h         |    1 +
 drivers/net/wireless/ath/ath9k/rc.c          |   33 +-
 drivers/net/wireless/ath/ath9k/recv.c        |   62 +-
 drivers/net/wireless/ath/ath9k/reg.h         |    5 +-
 drivers/net/wireless/ath/ath9k/virtual.c     |   22 +-
 drivers/net/wireless/ath/ath9k/xmit.c        |  113 +-
 drivers/net/wireless/ath/debug.c             |   32 +
 drivers/net/wireless/ath/debug.h             |   77 ++
 drivers/net/wireless/ath/hw.c                |  126 ++
 drivers/net/wireless/ath/reg.h               |   27 +
 drivers/net/wireless/b43/phy_lp.c            |    6 +
 drivers/net/wireless/hostap/Kconfig          |    2 +
 drivers/net/wireless/ipw2x00/Kconfig         |    7 +-
 drivers/net/wireless/ipw2x00/ipw2200.c       |    1 +
 drivers/net/wireless/iwlwifi/Kconfig         |   28 +-
 drivers/net/wireless/iwlwifi/Makefile        |   12 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c      |   35 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c  |  371 +-----
 drivers/net/wireless/iwlwifi/iwl-3945-led.h  |   22 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |   65 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c      |   71 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |  127 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |  245 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-led.c   |   85 ++
 drivers/net/wireless/iwlwifi/iwl-agn-led.h   |   32 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |  466 ++++----
 drivers/net/wireless/iwlwifi/iwl-agn.c       |  124 ++-
 drivers/net/wireless/iwlwifi/iwl-calib.c     |   66 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   12 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |  209 ++--
 drivers/net/wireless/iwlwifi/iwl-core.h      |   31 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h       |    7 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h     |    2 -
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |   17 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   31 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c  |   13 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h  |  178 +++
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |   45 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h    |   17 +-
 drivers/net/wireless/iwlwifi/iwl-io.h        |   16 +-
 drivers/net/wireless/iwlwifi/iwl-led.c       |  323 +----
 drivers/net/wireless/iwlwifi/iwl-led.h       |   46 +-
 drivers/net/wireless/iwlwifi/iwl-power.c     |  149 ++-
 drivers/net/wireless/iwlwifi/iwl-power.h     |    3 +
 drivers/net/wireless/iwlwifi/iwl-scan.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-tx.c        |   26 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |   28 +-
 drivers/net/wireless/iwmc3200wifi/main.c     |    2 +
 drivers/net/wireless/libertas/Kconfig        |   39 +
 drivers/net/wireless/libertas/Makefile       |   15 +-
 drivers/net/wireless/libertas/README         |   26 +-
 drivers/net/wireless/libertas/cfg.c          |  198 +++
 drivers/net/wireless/libertas/cfg.h          |   16 +
 drivers/net/wireless/libertas/cmd.c          |  106 ++-
 drivers/net/wireless/libertas/cmdresp.c      |   12 +
 drivers/net/wireless/libertas/decl.h         |    3 +
 drivers/net/wireless/libertas/defs.h         |    2 +
 drivers/net/wireless/libertas/dev.h          |   19 +
 drivers/net/wireless/libertas/host.h         |    1 +
 drivers/net/wireless/libertas/if_cs.c        |    3 +
 drivers/net/wireless/libertas/if_sdio.c      |   56 +
 drivers/net/wireless/libertas/if_sdio.h      |    3 +-
 drivers/net/wireless/libertas/if_spi.c       |    3 +
 drivers/net/wireless/libertas/if_usb.c       |    3 +
 drivers/net/wireless/libertas/main.c         |  171 ++-
 drivers/net/wireless/libertas/wext.c         |   54 +-
 drivers/net/wireless/orinoco/Kconfig         |    4 +-
 drivers/net/wireless/orinoco/main.c          |    1 +
 drivers/net/wireless/wl12xx/wl1251_netlink.h |   30 -
 drivers/staging/rtl8187se/Kconfig            |    3 +-
 drivers/staging/rtl8192e/Kconfig             |    3 +-
 drivers/staging/vt6655/Kconfig               |    4 +-
 drivers/staging/vt6656/Kconfig               |    4 +-
 include/linux/nl80211.h                      |    2 +
 include/net/cfg80211.h                       |    9 +-
 include/net/iw_handler.h                     |   14 +-
 include/net/net_namespace.h                  |    2 +-
 include/net/wext.h                           |   49 +-
 net/core/net-sysfs.c                         |    6 +-
 net/mac80211/iface.c                         |    5 +-
 net/socket.c                                 |    4 +-
 net/wireless/Kconfig                         |   50 +-
 net/wireless/Makefile                        |   10 +-
 net/wireless/core.c                          |   17 +-
 net/wireless/ethtool.c                       |   45 +
 net/wireless/ethtool.h                       |    6 +
 net/wireless/ibss.c                          |   10 +-
 net/wireless/mlme.c                          |    2 +-
 net/wireless/nl80211.c                       |    6 +-
 net/wireless/scan.c                          |    6 +-
 net/wireless/sme.c                           |   12 +-
 net/wireless/wext-core.c                     | 1063 +++++++++++++++
 net/wireless/wext-priv.c                     |  248 ++++
 net/wireless/wext-proc.c                     |  155 +++
 net/wireless/wext-spy.c                      |  231 ++++
 net/wireless/wext.c                          | 1775 --------------------------
 142 files changed, 6953 insertions(+), 5229 deletions(-)
 create mode 100644 drivers/net/wireless/ath/debug.c
 create mode 100644 drivers/net/wireless/ath/debug.h
 create mode 100644 drivers/net/wireless/ath/hw.c
 create mode 100644 drivers/net/wireless/ath/reg.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-led.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-led.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-devtrace.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-devtrace.h
 create mode 100644 drivers/net/wireless/libertas/Kconfig
 create mode 100644 drivers/net/wireless/libertas/cfg.c
 create mode 100644 drivers/net/wireless/libertas/cfg.h
 delete mode 100644 drivers/net/wireless/wl12xx/wl1251_netlink.h
 create mode 100644 net/wireless/ethtool.c
 create mode 100644 net/wireless/ethtool.h
 create mode 100644 net/wireless/wext-core.c
 create mode 100644 net/wireless/wext-priv.c
 create mode 100644 net/wireless/wext-proc.c
 create mode 100644 net/wireless/wext-spy.c
 delete mode 100644 net/wireless/wext.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-10-09.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
