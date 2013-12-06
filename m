From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-12-06
Date: Fri, 6 Dec 2013 13:49:20 -0500
Message-ID: <20131206184920.GG13285@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tjCHc7DPkfUGtrlw"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tjCHc7DPkfUGtrlw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.14 stream...

For the mac80211 bits, Johannes says:

"I have various improvements/cleanups/fixes all over, but the shortlog
shows that Luis's regulatory work and mesh work from the cozybit folks
are the biggest ones, along with the CSA fixes."

Along with that, we have big batches of updates to brcmfmac, rtlwifi,
and ath9k.  There are updates to wcn36xx, rt2x00, and a handful of
others as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit d70f2cf520cf8c86c6b467fc5dcea524ec51dc2f:

  macvlan: Support creating macvtaps from macvlans (2013-12-05 19:59:02 -05=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to d86804cb70f93ca5e4c0fb13402962fbfb705c53:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-12-06 10:37:24 -0500)

----------------------------------------------------------------

Alexey Khoroshilov (1):
      libertas sdio: claim device before calling sdio_disable_func()

Amitkumar Karwar (1):
      mwifiex: improvements in mwifiex_ret_tx_power_cfg()

Andrei Otcheretianski (1):
      cfg80211: aggregate mgmt_tx parameters into a struct

Arend van Spriel (18):
      brcmfmac: add separate function for passing bus tx overhead
      brcmfmac: replace dongle command list with .preinit() callback
      brcmfmac: start netif queues only when setup is completed successful
      brcmfmac: reduce logging noise accessing SDIO SleepCSR register
      brcmsmac: select CONFIG_BCMA when possible
      brcmfmac: support hardware extension header in trace_brcmf_sdpcm_hdr()
      brcmfmac: determine sd host controller related variable earlier
      brcmfmac: fix driver build issue when CONFIG_BRCMDBG is not set
      brcmfmac: determine alignment values during probe
      brcmfmac: use platform specific alignment in SDIO
      brcmfmac: remove redundant ioctl handlers
      brcmfmac: provide firmware version in ethtool driver info
      brcmfmac: remove unnecessary EXPORT_SYMBOL() usage
      brcmfmac: move firmware related structures to fwil_types.h
      brcmfmac: move firmware command code definitions
      brcmfmac: remove some unused definitions
      brcmfmac: move firmware event related defines to fweh.h
      brcmfmac: expose chip information through debugfs

Arik Nemtsov (1):
      nl80211: better document NL80211_CMD_TDLS_MGMT

Avri Altman (1):
      mac80211: update ht flag if bss configuration changed

Bob Copeland (10):
      mac80211: fix off-by-one in llid check.
      mac80211: hold sta->lock across plink switch statements
      mac80211: mesh: factor out common plink close/estab code
      mac80211: mesh_plink: group basic fitness checks
      mac80211: mesh: rewrite rssi_threshold_check in C
      mac80211: mesh_plink: collapse the two switch statements together
      mac80211: mesh_plink: don't ignore holding timer
      mac80211: return -ENOMEM in mesh_plink_frame_tx
      mac80211: remove unused mesh_mgmt_ies_add() prototype
      mac80211: mesh: only get tsf if we need it

Chun-Yeow Yeoh (6):
      mac80211: use put_unaligned_le16 for precedence value in mesh
      mac80211: use put_unaligned_le16 in mesh_plink_frame_tx
      mac80211: use put_unaligned_le in mesh when necessary
      wcn36xx: enable beacon change using BSS_CHANGED_BEACON
      wcn36xx: set self STA default HT parameters
      wcn36xx: fix typo error

Dan Carpenter (1):
      ath9k: fix SC_OP_INVALID test in ath9k_tx99_init()

Eliad Peller (1):
      mac80211: add min required channel definition field

Eugene Krasnikov (1):
      wcn36xx: Fix logging macro with unnecessary semicolon

Eyal Shapira (1):
      mac80211: enable easier manipulation of VHT beamforming caps

Felix Fietkau (6):
      cfg80211: fix reporting 5/10 MHz support to user space
      ath9k: use a timer to put hardware into full sleep
      ath9k: optimize ath_drain_all_txq
      ath9k: optimize ath9k_flush
      ath9k_hw: fix TSF save/restore around chip reset
      ath9k_hw: allow fast channel change when only CHANNEL_HT changes

Franky Lin (3):
      brcmfmac: remove empty brcmf_proto_stop
      brcmfmac: add firmware and nvram file name for bcm4339
      brcmfmac: add host tx glomming support

Hante Meuleman (5):
      brcmfmac: Update fwsignal to fix out of order tx.
      brcmfmac: rename dhd_cdc to bcdc
      brcmfmac: removed dhd_proto.h.
      brcmfmac: Dynamically register a protocol layer.
      brcmfmac: Use consistent naming for BCDC.

Hauke Mehrtens (1):
      brcmsmac: remove dependency on CRC8 and CRC_CCITT

Janusz Dziedzic (7):
      mac80211_hwsim: use debugfs_remove_recursive
      mac80211_hwsim: Add iface comb for DFS
      mac80211_hwsim: VHT add 160MHz width support
      cfg80211: add helper functions for start/end freq
      cfg80211: DFS check chandef usable before CAC
      cfg80211/mac80211: DFS setup chandef for cac event
      cfg80211: allow beaconing after DFS CAC

Jing Wang (1):
      wl1251: return -ENOMEM if kzalloc fails

Jingoo Han (5):
      wireless: ipw2100: remove unnecessary pci_set_drvdata()
      wireless: prism54: remove unnecessary pci_set_drvdata()
      wireless: rt2x00: remove unnecessary pci_set_drvdata()
      wireless: libertas: remove unnecessary spi_set_drvdata()
      bcma: pci: remove unnecessary pci_set_drvdata()

Johannes Berg (6):
      mac80211: remove useless tests for array
      cfg80211: add missing break in cfg80211_get_chan_state()
      cfg80211: don't allow drivers to unset NL80211_FEATURE_SCAN_FLUSH
      mac80211: verify ieee80211_key_replace() arguments
      mac80211_hwsim: use CLOCK_MONOTONIC_RAW
      mac80211: remove sta_info_flush() from interface teardown

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Karl Beldan (5):
      mac80211: do not compute offset from ssn in Rx AMPDU reordering buffer
      mac80211_hwsim: claim CCK support for HT clients
      mac80211: minstrel_ht: replace some occurences of MCS_GROUP_RATES
      mac80211: minstrels: spare numerous useless calls to get_random_bytes
      mac80211: minstrel_ht: do not sample unsupported rates

Kevin Lo (3):
      rt2x00: rt2800lib: Update BBP register initialization for RT53xx
      rt2x00: rt2800lib: update RF registers for RT5390
      rt2x00: rt2800lib: no need to write RF register 3 twice for RT5592

Larry Finger (15):
      rtl8187: Increase RX queue depth
      rtlwifi: Remove unused calls to rtl_is_special_data()
      rtlwifi: rtl8192c: Prevent reconnect attempts if not connected
      rtlwifi: rtl8192cu: Add new firmware
      rtlwifi: Redo register save locations
      rtlwifi: Set the link state
      rtlwifi: rtl8192c: Add new definitions in the dm_common header
      rtlwifi: Increase the RX queue length for USB drivers
      rtlwifi: Update beacon statistics for USB driver
      rtlwifi: rtl8192c: Add routines to save/restore power index registers
      rtlwifi: rtl8192cu: Update the power index registers
      rtlwifi: rtl8192cu: Fix some code in RF handling
      rtlwifi: Add missing code to PWDB statics routine
      rtlwifi: rtl8192c: Update dynamic gain calculations
      rtlwifi: rtl8188ee: Fix typo in code

Lorenzo Bianconi (1):
      ath9k: fix retry chain initialization in tx99 code

Luciano Coelho (1):
      mac80211: move csa_chandef to sdata

Luis R. Rodriguez (40):
      cfg80211: consolidate passive-scan and no-ibss flags
      cfg80211: force WIPHY_FLAG_CUSTOM_REGULATORY on wiphy_apply_custom_re=
gulatory()
      cfg80211: remove second argument from reg_process_hint()
      cfg80211: add function helpers to genregdb.awk
      cfg80211: fix parsing when db.txt ends on a rule
      cfg80211: enforce disabling channels by custom or strict settings
      cfg80211: check regulatory request alpha2 early
      cfg80211: processing core regulatory hints on its own
      cfg80211: process user regulatory requests on its own
      cfg80211: process driver regulatory requests on its own
      cfg80211: process country IE regulatory requests on their own
      cfg80211: process non country IE conflicting first
      cfg80211: add helper for kfree'ing last_request
      cfg80211: add helper for kfree'ing and assigning last_request
      cfg80211: add helper for calling CRDA
      cfg80211: allow only the core to request to update the world regdom
      cfg80211: move core reg_notfier() check to source
      cfg80211: pass the last_request to __set_regdom()
      cfg80211: set core regulatory updates on its own
      cfg80211: set user regulatory updates on its own
      cfg80211: set driver regulatory updates on its own
      cfg80211: rename __set_regdom() to reg_set_rd_country_ie()
      cfg80211: move regulatory flags to their own variable
      cfg80211: add flags to define country IE processing rules
      cfg80211: add an option to disable processing country IEs
      cfg80211: use enum nl80211_dfs_regions for dfs_region everywhere
      cfg80211: intersection dfs regions when intersecting regdomains
      cfg80211: distinguish unset DFS region from unknown
      cfg80211: replace print_dfs_region() with reg_dfs_region_str() helper
      brcm80211: fix usage of freq_reg_info()
      rtlwifi: fix usage of freq_reg_info()
      ath: fix logic on ath_reg_apply_active_scan_flags()
      ath: clean up ath_reg_apply_active_scan_flags()
      ath: rename ath_reg_apply_active_scan_flags() to ath_reg_apply_ir_fla=
gs()
      ath: simplify ath_reg_apply_beaconing_flags()
      ath: move the channel for ath_reg_apply_beaconing_flags() into helper
      ath: fix usage of freq_reg_info()
      ath: move dynamic_country_user_possible() to the top
      ath: dynamic user allow check helper to the top
      ath: fix dynamic user regulatory domain support

Mark Cave-Ayland (3):
      rtlwifi: Bring _rtl92c_phy_iq_calibrate() in line with the vendor dri=
ver
      rtlwifi: rtl8192cu: Bring rtl92cu_phy_bb_config() up to date
      rtlwifi: rtl8192cu: Update table.c

Matti Gottlieb (1):
      mac80211: Tx frame latency statistics

Max Stepanov (1):
      mac80211: add generic cipher scheme support

Michal Kazior (1):
      mac80211: fix rx_nss calculation for drivers with hw rc

NeilBrown (1):
      libertas/sdio: make sure card enters power-off when firmware is loade=
d.

Simon Wunderlich (5):
      cfg80211: protect beacon changing functions with wdev-lock
      mac80211: modify beacon using sdata/wdev-lock, not rtnl lock
      cfg80211/mac80211/ath6kl: acquire wdev lock outside ch_switch_notify
      mac80211: don't cancel csa finalize work within stop_ap
      mac80211: don't leak next beacon when csa is aborted

Solomon Peachy (2):
      cw1200: Make the "scan failed" message into a warning
      wireless: cw1200: Use consistent internal locking conventions

Stanislaw Gruszka (1):
      iwl3945: do not print RFKILL message

Sujith Manoharan (26):
      ath9k: Add WB335 PCI IDs
      ath9k: Identify Killer Wireless cards
      ath9k: Fix TX99 config option usage
      ath9k: Fix wow.c compilation
      ath9k: Add a config option for WoW
      ath9k: Use CONFIG_ATH9K_WOW
      ath9k: Add an initialization routine for WoW
      ath9k: Add SERDES initvals for AR9462 2.1
      ath9k: Remove unused AR9462 2.0 initvals
      ath9k: Remove pcieSerDesWrite
      ath9k: Apply CUS227 specific TX gain values
      ath9k: Update MAINTAINERS
      ath9k: Separate routines for PCOEM and SoC calibration
      ath9k: Remove RTT/MCI code from SoC calibration
      ath9k: Remove unnecessary check
      ath9k: Fix Carrier Leak calibration for SoC chips
      ath9k: Fix TX IQ calibration for SoC chips
      ath9k: Cleanup IQ calibration for PCOEM chips
      ath9k: Add initvals for AR9565 1.1
      ath9k: Add version macros for AR9565 1.1
      ath9k: Attach INI arrays for AR9565 v1.1
      ath9k: Remove duplicate initvals for AR9462 v2.1
      ath9k: Update initvals for AR9300 v2.2
      ath9k: Update initvals for AR9580 v1.0
      ath9k: Update AR9340 initvals
      ath9k: Fix initvals for freq 2484

Thomas Pedersen (7):
      mac80211: consolidate calls to plink_frame_tx
      mac80211: factor peering frame processing into own function
      mac80211: consolidate rcu unlocks in plink frame rx
      mac80211: assign sta plid early
      mac80211: factor out peering FSM
      mac80211: factor out plink event gathering
      mac80211: clean up mesh local link ID generation

 Documentation/networking/regulatory.txt            |    4 +-
 MAINTAINERS                                        |   19 +-
 drivers/bcma/host_pci.c                            |    1 -
 drivers/net/wireless/ath/ath10k/mac.c              |    4 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   11 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   10 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    8 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |   31 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  114 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  122 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    9 +-
 drivers/net/wireless/ath/ath9k/ar9003_wow.c        |  422 ++++++
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |  390 ++---
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |   32 +-
 .../net/wireless/ath/ath9k/ar9462_2p1_initvals.h   | 1559 +---------------=
----
 .../net/wireless/ath/ath9k/ar9565_1p1_initvals.h   |   64 +
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |  559 ++++---
 drivers/net/wireless/ath/ath9k/ath9k.h             |   56 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  115 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   24 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    5 +-
 drivers/net/wireless/ath/ath9k/init.c              |   26 +-
 drivers/net/wireless/ath/ath9k/main.c              |  541 +------
 drivers/net/wireless/ath/ath9k/pci.c               |   45 +
 drivers/net/wireless/ath/ath9k/reg.h               |   12 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |  264 ++++
 drivers/net/wireless/ath/ath9k/wow.c               |  589 ++++----
 drivers/net/wireless/ath/ath9k/xmit.c              |    7 +
 drivers/net/wireless/ath/regd.c                    |  378 ++---
 drivers/net/wireless/ath/wcn36xx/hal.h             |    2 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |    3 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |   21 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |    2 +-
 drivers/net/wireless/brcm80211/Kconfig             |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c     |  384 +++++
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.h     |   24 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    3 -
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   51 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  482 +-----
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   15 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |  392 -----
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   22 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |   36 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |    2 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  194 +--
 .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |   42 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  462 +++---
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |   54 +
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |    7 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.h     |   61 +
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |  304 ++++
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  173 ++-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/proto.c    |   62 +
 drivers/net/wireless/brcm80211/brcmfmac/proto.h    |   57 +
 .../net/wireless/brcm80211/brcmfmac/tracepoint.h   |   33 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    4 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   29 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |   38 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   66 +-
 drivers/net/wireless/cw1200/cw1200_sdio.c          |    4 +-
 drivers/net/wireless/cw1200/scan.c                 |   15 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |    5 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    8 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |   11 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    8 +-
 drivers/net/wireless/iwlegacy/common.c             |    4 +-
 drivers/net/wireless/iwlegacy/debug.c              |    8 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |    8 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    6 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    4 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |    6 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    4 +-
 drivers/net/wireless/libertas/if_sdio.c            |    6 +-
 drivers/net/wireless/libertas/if_spi.c             |    1 -
 drivers/net/wireless/mac80211_hwsim.c              |  101 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   25 +-
 drivers/net/wireless/mwifiex/scan.c                |    4 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   35 +-
 drivers/net/wireless/prism54/islpci_dev.c          |    1 -
 drivers/net/wireless/prism54/islpci_hotplug.c      |    2 -
 drivers/net/wireless/rt2x00/rt2800lib.c            |   37 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    3 -
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |    2 +-
 drivers/net/wireless/rtlwifi/base.c                |    3 +-
 drivers/net/wireless/rtlwifi/core.c                |   11 +
 drivers/net/wireless/rtlwifi/pci.c                 |    2 -
 drivers/net/wireless/rtlwifi/regd.c                |   61 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  327 ++--
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h  |   14 +
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   39 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |    9 +
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.h        |    3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   29 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/table.c     |   40 +-
 drivers/net/wireless/rtlwifi/stats.c               |   14 +
 drivers/net/wireless/rtlwifi/usb.c                 |    8 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   33 +-
 drivers/net/wireless/ti/wl1251/acx.c               |  209 +--
 drivers/net/wireless/ti/wl12xx/scan.c              |    2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |    3 +-
 drivers/net/wireless/ti/wlcore/scan.c              |   12 +-
 include/linux/ieee80211.h                          |    8 +-
 include/net/cfg80211.h                             |   76 +-
 include/net/mac80211.h                             |   40 +
 include/net/regulatory.h                           |   80 +-
 include/uapi/linux/nl80211.h                       |   47 +-
 net/mac80211/cfg.c                                 |  123 +-
 net/mac80211/chan.c                                |  141 +-
 net/mac80211/debugfs.c                             |  168 +++
 net/mac80211/debugfs_sta.c                         |  134 ++
 net/mac80211/ibss.c                                |    6 +-
 net/mac80211/ieee80211_i.h                         |   43 +-
 net/mac80211/iface.c                               |   14 +-
 net/mac80211/key.c                                 |   62 +-
 net/mac80211/key.h                                 |   13 +-
 net/mac80211/main.c                                |  147 +-
 net/mac80211/mesh.c                                |    7 +-
 net/mac80211/mesh.h                                |    6 +-
 net/mac80211/mesh_hwmp.c                           |   91 +-
 net/mac80211/mesh_pathtbl.c                        |    7 +-
 net/mac80211/mesh_plink.c                          |  708 ++++-----
 net/mac80211/mesh_ps.c                             |    3 +-
 net/mac80211/mesh_sync.c                           |   28 +-
 net/mac80211/mlme.c                                |   43 +-
 net/mac80211/rate.h                                |    4 +-
 net/mac80211/rc80211_minstrel.c                    |    3 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   22 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |    3 +-
 net/mac80211/rx.c                                  |   88 +-
 net/mac80211/scan.c                                |   10 +-
 net/mac80211/sta_info.c                            |   40 +-
 net/mac80211/sta_info.h                            |   38 +-
 net/mac80211/status.c                              |   78 +
 net/mac80211/trace.h                               |   21 +-
 net/mac80211/tx.c                                  |   41 +-
 net/mac80211/util.c                                |   95 +-
 net/mac80211/vht.c                                 |    7 +-
 net/mac80211/wpa.c                                 |  116 ++
 net/mac80211/wpa.h                                 |    2 +
 net/wireless/chan.c                                |  203 ++-
 net/wireless/core.c                                |    6 +-
 net/wireless/core.h                                |   18 +-
 net/wireless/genregdb.awk                          |   45 +-
 net/wireless/ibss.c                                |    4 +-
 net/wireless/mesh.c                                |    3 +-
 net/wireless/mlme.c                                |   20 +-
 net/wireless/nl80211.c                             |  107 +-
 net/wireless/nl80211.h                             |    2 +-
 net/wireless/rdev-ops.h                            |   12 +-
 net/wireless/reg.c                                 |  802 ++++++----
 net/wireless/reg.h                                 |    3 +-
 net/wireless/trace.h                               |   15 +-
 161 files changed, 7162 insertions(+), 6258 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_wow.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9565_1p1_initvals.h
 create mode 100644 drivers/net/wireless/ath/ath9k/tx99.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_proto.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/proto.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/proto.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--tjCHc7DPkfUGtrlw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSohwwAAoJEJctW/TcYTgG2XAP/iUklTQnF9l11welI8z2KCHy
F5ap7zyYdAuB/bZ3P7IDzfzjGSgqs3BRv7aPi2vze8mdn0MCsGLjGqTG7otDrsqV
gnB/NbQcaIahq3ouW/54lzAvkqt5lXvUXUvKbXNUS7qm6Ujypn+xcVCaLRazoAR0
ZZimLDDJdGpI9/LpXYM7+dpUiTF7CGub0d5Q3osWEkDnm3lpsFir2GvF8JKkrUNd
bqePtLaRWyUaN8zRszkgYNAeQ0Tr6YU7cBh6EDPP0zzd0seS06Ky9bGxUnntekrV
exrNz+3vTh/Oaf/MnaSfubYb885umPJuTTF4suTYkmWkzPt3v4lQdYdHxJaR1TD/
XMF3lmMAhVJ1jzPcGNtzpkntqs9Qx+JMbeSpz13761WlS2he6YXT66uuWwolT35b
z9Acs6BaOPBWoRK7LLTVub6tFrV67Pb1o8lfmzT8i1ePwKb+8KuBVVUrMOzODUjp
z6R4oiWD3d1sSEey+u1nGB993Veso+6oh71UyN269c7UiMNqrUOqEKVmVxxGuZyM
THymmSJ+1KOQBsD6674qLh5bqJy6Q3j5kj0g5MJ3COzMrRaoJziu5afI4eY4zS8k
mkehaDFmSPaTQFSsX3uRVgUPf+czfz2bgwRVv74Jvy84daGc3ssPD9/Us1++9kNi
z0//p3MiXVlZxSFJ6Nmu
=iJT6
-----END PGP SIGNATURE-----

--tjCHc7DPkfUGtrlw--
