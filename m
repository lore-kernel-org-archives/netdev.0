From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-02-06
Date: Mon, 6 Feb 2012 15:18:27 -0500
Message-ID: <20120206201827.GH21048@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0OAP2g/MAC+5xKAE"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 8926574c4d0055ca4c4a02d1f6b2c249d01a0621

Dave,

Here is a big pull request full of wireless updates intended for 3.4!

Highlights include a round of NFC updates from Ilan Elias, a big batch
of spruce-ups from Joe Perches, and the usual round of updates from
Larry Finger (rtlwifi), Rafa=C5=82 Mi=C5=82ecki (bcma, b43), Johannes Berg
(mac80211), and a variety of other contributors.

Please let me know if there are problems!

John

---

The following changes since commit c056b734e54e12f38f34a2583a4824e6cecc16c1:

  netdev: ethernet dev_alloc_skb to netdev_alloc_skb (2012-02-06 11:52:27 -=
0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Amitkumar Karwar (1):
      mwifiex: update BSS parameters in dump_station_info()

Antonio Quartulli (6):
      mac80211: In IBSS the DA field of auth frames is different from BSSID
      mac80211: remove useless DA checking in ieee80211_rx_mgmt_probe_resp()
      ath5k: claim support for IBSS RSN
      mac80211: add a 2-way Authentication challenge to IBSS mode
      mac80211: in IBSS use the Auth frame to trigger STA reinsertion
      ath9k_htc: claim support for IBSS RSN

Avinash Patil (1):
      mwifiex: pass priv pointer instead of adapter

Christian Lamparter (2):
      carl9170: remove eeprom data injection option
      carl9170: allow users to lower output power level

Chun-Yeow Yeoh (1):
      {nl,cfg,mac}80211: Add support of setting non-forwarding entity in Me=
sh

Dan Carpenter (1):
      nfc: NULL vs zero in nci_activate_target()

Eliad Peller (2):
      mac80211: check sta_apply_parameters() return value
      mac80211: send null packet on active (psm) reconfiguration

Helmut Schaa (3):
      mac80211: Fix incorrect num_sta_ps decrement in __sta_info_destroy
      mac80211: Fix incorrect num_sta_ps decrement in ap_sta_ps_end
      mac80211: Move num_sta_ps counter decrement after synchronize_rcu

Hong Wu (2):
      wireless: Save original maximum regulatory transmission power for the=
 calucation of the local maximum transmit power
      mac80211: Fix the maximum transmit power with power constraint

Ilan Elias (10):
      NFC: Complete NCI deactivate in deactivate_ntf
      NFC: Increase NCI deactivate timeout
      NFC: Export new attributes sensb_res and sensf_res
      NFC: Add NCI data exchange timer
      NFC: Add endian annotations to nfcwilink driver
      NFC: Download TI NFC init script
      NFC: Free sk_buff if nfcwilink_send fails
      NFC: Clearly separate NCI states from flags
      NFC: NFC core layer should not set the target_idx
      NFC: Add NCI multiple targets support

Joe Perches (18):
      rtlwifi: Neaten RT_ASSERT, RT_TRACE, RTPRINT, RT_PRINT_DATA macros
      rtlwifi: Standardize RT_PRINT_DATA macro and uses
      rtlwifi: Convert RT_TRACE macro to use ##__VA_ARGS__
      rtlwifi: Convert RTPRINT macro to use ##__VA_ARGS__
      rtlwifi: Convert RT_ASSERT macro to use ##__VA_ARGS__
      rtlwifi: Remove duplicate __func__
      rtlwifi: Optimize RT_TRACE macro use of KBUILD_MODNAME for size
      rtlwifi: add CONFIG_RTLWIFI_DEBUG to remove all of the debug logging =
code
      rtlwifi: Remove incorrect logging message prefixes
      rtlwifi: Simplify chip version id logging
      brcm80211: Use normal DEBUG define
      brcmfmac: Convert printk(KERN_DEBUG to pr_debug
      brcm80211: Add and use brcmX_dbg_dump_hex
      brcmfmac: Remove useless #ifdef DEBUG
      brcm80211: Convert printk(KERN_DEBUG to pr_debug
      brcm80211: Use brcmu_dbg_hex_dump
      brcm80211: Use pr_fmt and pr_<level>
      brcmfmac: Trivial typo of "couldn" to "could" fix

Johannes Berg (10):
      mac80211: refactor __ieee80211_get_channel_mode
      mac80211: clean up aggregation destruction
      mac80211: clean up rate control code
      mac80211: make beacon filtering per virtual interface
      mac80211: make CQM RSSI support per virtual interface
      mac80211: fix a few -Wshadow warnings
      cfg80211: fix a few -Wshadow warnings
      mac80211: station state transition error handling
      iwlwifi: fix uCode event tracing
      iwlwifi: always restrict scan dwell in P2P

John W. Linville (5):
      ath5k: use bool type for no_hw_rfkill_switch module parameter
      orinoco_usb: remove version definition
      ath9k: use WARN_ON_ONCE in ath_rc_get_highest_rix
      Revert "mac80211: Do not scan for IBSS merge with a fixed BSSID."
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Julia Lawall (1):
      drivers/net/wireless/mwifiex/scan.c: convert GFP_KERNEL to GFP_ATOMIC

Kenny Hsu (4):
      iwlwifi: update testmode command of direct register access
      iwlwifi: enhance testmode command sram_read
      iwlwifi: update error dump in testmode command sram_read
      iwlwifi: add testmode cmd IWL_TM_CMD_APP2DEV_GET_FW_INFO

Larry Finger (11):
      rtlwifi: rtl8192c_common: rtl8192de: Check for allocation failures
      rtl8192cu: Remove dead code never selected
      rtlwifi: Update copyright dates
      rtl8192c_common: Update copyright dates
      rtl8192ce: Update copyright dates
      rtl8192cu: Update copyright dates
      rtl8192de: Update copyright dates
      rtl8192se: Update copyright dates
      bcma: Enable logging of SPROM offset
      rtlwifi: Move pr_fmt macros to a single location
      rtlwifi: Convert to asynchronous firmware load

Mohammed Shafi Shajakhan (1):
      mac80211: minor cleanup

Nicolas Cavallari (2):
      carl9170: claim to support IBSS RSN.
      mac80211: Do not scan for IBSS merge with a fixed BSSID.

Rafa=C5=82 Mi=C5=82ecki (11):
      ssb: SPROM: extract each core power info
      bcma: SPROM: add macro for easier extraction
      bcma: SPROM: extract power info for cores
      b43: add maskset helpers
      b43: N-PHY: implement TX power control setup
      b43: N-PHY: add helper for getting gain table
      b43: N-PHY: fix typos in RF control
      b43: N-PHY: upload PAPD PGA gain delta table
      b43: N-PHY: implement RSSI calibration for rev3+
      b43: N-PHY: trivial: change save&rest order in RSSI polling
      MAINTAINERS: update b43(legacy) mailing list

Randy Dunlap (1):
      kernel-doc: fix new warnings in cfg80211.h

Simon Wunderlich (2):
      nl80211: add support for mcs masks
      mac80211: add support for mcs masks

Stanislaw Gruszka (4):
      rt2800usb: initialize H2M_INT_SRC register
      rt2800: disable DMA after firmware load
      rt2800: zero MAC_SYS_CTRL bits during BBP and MAC reset
      rt2800usb: remove PWR_PIN_CFG=3D0x3 during init

Stephen Hemminger (1):
      brcm80211: make ethtool_ops const

Sujith Manoharan (2):
      ath9k_htc: Load firmware asynchronously
      ath9k: Print the correct channel mode

Wey-Yi Guy (5):
      iwlwifi: don't process the info from uCode if does not has ownership
      iwlwifi: Sanity check for sta_id
      iwlwifi: update Copyright
      iwlwifi: fix typo
      iwlwifi: add option to disalbe LED

Yogesh Ashok Powar (3):
      mwifiex: use bss_type and bss_num to retrieve priv
      mwifiex: derive priv from net_device instead of wiphy
      mwl8k: Configuring correct MAC address in broadcast key

 MAINTAINERS                                        |    3 +-
 drivers/bcma/sprom.c                               |  180 ++++--
 drivers/net/wireless/ath/ath5k/base.c              |    5 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    8 +
 drivers/net/wireless/ath/ath9k/hif_usb.c           |  154 +++--
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   15 +
 drivers/net/wireless/ath/ath9k/main.c              |    4 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +-
 drivers/net/wireless/ath/carl9170/carl9170.h       |    2 +-
 drivers/net/wireless/ath/carl9170/fw.c             |   33 -
 drivers/net/wireless/ath/carl9170/mac.c            |   35 +
 drivers/net/wireless/ath/carl9170/main.c           |   18 +-
 drivers/net/wireless/ath/carl9170/phy.c            |   36 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    2 +
 drivers/net/wireless/b43/b43.h                     |   12 +
 drivers/net/wireless/b43/main.c                    |   67 +--
 drivers/net/wireless/b43/phy_n.c                   |  532 ++++++++++++---
 drivers/net/wireless/b43/phy_n.h                   |    1 +
 drivers/net/wireless/b43/tables_nphy.c             |   76 ++-
 drivers/net/wireless/b43/tables_nphy.h             |   14 +-
 drivers/net/wireless/brcm80211/Makefile            |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    2 +
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    2 +
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   17 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   20 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  216 +++----
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |    2 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    6 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   36 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |    8 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   24 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  194 +++---
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |    6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    5 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |   26 +-
 .../net/wireless/brcm80211/include/brcmu_utils.h   |   15 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   30 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  103 +++-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-bus.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-cfg.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |    8 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |   64 ++-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   32 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-trans.c           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-wifi.h            |    4 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    3 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   37 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    3 +-
 drivers/net/wireless/mwifiex/decl.h                |    6 +-
 drivers/net/wireless/mwifiex/init.c                |    5 +-
 drivers/net/wireless/mwifiex/main.c                |   25 +-
 drivers/net/wireless/mwifiex/main.h                |    4 +-
 drivers/net/wireless/mwifiex/scan.c                |    8 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |    6 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |    3 +-
 drivers/net/wireless/mwifiex/txrx.c                |    6 +-
 drivers/net/wireless/mwifiex/util.c                |    3 +-
 drivers/net/wireless/mwifiex/wmm.c                 |    5 +-
 drivers/net/wireless/mwifiex/wmm.h                 |    4 +-
 drivers/net/wireless/mwl8k.c                       |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    5 -
 drivers/net/wireless/p54/main.c                    |    3 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   23 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    4 +-
 drivers/net/wireless/rtlwifi/Kconfig               |    5 +
 drivers/net/wireless/rtlwifi/base.c                |   67 +-
 drivers/net/wireless/rtlwifi/base.h                |    2 +-
 drivers/net/wireless/rtlwifi/cam.c                 |   85 ++--
 drivers/net/wireless/rtlwifi/cam.h                 |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |  174 ++++--
 drivers/net/wireless/rtlwifi/core.h                |    6 +-
 drivers/net/wireless/rtlwifi/debug.c               |    4 +-
 drivers/net/wireless/rtlwifi/debug.h               |  121 +++--
 drivers/net/wireless/rtlwifi/efuse.c               |   63 +-
 drivers/net/wireless/rtlwifi/efuse.h               |    2 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  243 ++++----
 drivers/net/wireless/rtlwifi/pci.h                 |    3 +-
 drivers/net/wireless/rtlwifi/ps.c                  |   36 +-
 drivers/net/wireless/rtlwifi/ps.h                  |    2 +-
 drivers/net/wireless/rtlwifi/rc.c                  |    4 +-
 drivers/net/wireless/rtlwifi/rc.h                  |    2 +-
 drivers/net/wireless/rtlwifi/regd.c                |   14 +-
 drivers/net/wireless/rtlwifi/regd.h                |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  191 +++---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   99 ++--
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/main.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  213 +++----
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |   26 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  279 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |   18 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |  110 ++--
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |   85 ++--
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   37 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/table.c     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/table.h     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   25 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/def.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |   26 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |  464 ++++---------
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/led.c       |   17 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/led.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |  133 ++---
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |  123 ++--
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/reg.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   73 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   34 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/table.c     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/table.h     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   44 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/def.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |  241 ++++----
 drivers/net/wireless/rtlwifi/rtl8192de/dm.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |  137 ++---
 drivers/net/wireless/rtlwifi/rtl8192de/fw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |  193 +++---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/led.c       |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192de/led.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |  684 ++++++++++------=
----
 drivers/net/wireless/rtlwifi/rtl8192de/phy.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |   97 ++--
 drivers/net/wireless/rtlwifi/rtl8192de/rf.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |   57 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/table.c     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/table.h     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   28 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   32 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |   70 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  262 ++++----
 drivers/net/wireless/rtlwifi/rtl8192se/hw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/led.c       |   22 +-
 drivers/net/wireless/rtlwifi/rtl8192se/led.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |  208 +++----
 drivers/net/wireless/rtlwifi/rtl8192se/phy.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/reg.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |   64 +--
 drivers/net/wireless/rtlwifi/rtl8192se/rf.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |   82 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/table.c     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/table.h     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   20 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.h       |    2 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   92 ++--
 drivers/net/wireless/rtlwifi/usb.h                 |    3 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    8 +-
 drivers/net/wireless/wl1251/main.c                 |    7 +-
 drivers/net/wireless/wl12xx/main.c                 |    5 +-
 drivers/nfc/nfcwilink.c                            |  305 +++++++++-
 drivers/ssb/pci.c                                  |   40 ++-
 include/linux/nfc.h                                |    7 +
 include/linux/nl80211.h                            |    8 +
 include/linux/ssb/ssb.h                            |    8 +
 include/linux/ssb/ssb_regs.h                       |   34 +
 include/net/cfg80211.h                             |    6 +-
 include/net/mac80211.h                             |   44 +-
 include/net/nfc/nci.h                              |   53 ++-
 include/net/nfc/nci_core.h                         |   26 +-
 include/net/nfc/nfc.h                              |    9 +-
 net/mac80211/cfg.c                                 |   46 +-
 net/mac80211/chan.c                                |   28 +-
 net/mac80211/debugfs.c                             |    4 -
 net/mac80211/debugfs_netdev.c                      |   35 +
 net/mac80211/debugfs_sta.c                         |    5 +-
 net/mac80211/ibss.c                                |   94 ++--
 net/mac80211/ieee80211_i.h                         |    3 +-
 net/mac80211/iface.c                               |   13 +-
 net/mac80211/main.c                                |    3 +-
 net/mac80211/mesh_hwmp.c                           |    2 +-
 net/mac80211/mesh_plink.c                          |    6 +-
 net/mac80211/mlme.c                                |   25 +-
 net/mac80211/rate.c                                |  151 ++++-
 net/mac80211/rate.h                                |    4 -
 net/mac80211/rx.c                                  |   11 +-
 net/mac80211/sta_info.c                            |   84 ++--
 net/mac80211/sta_info.h                            |   17 +-
 net/mac80211/status.c                              |    6 +-
 net/mac80211/tx.c                                  |    5 +
 net/mac80211/util.c                                |   21 +-
 net/mac80211/work.c                                |    5 +-
 net/nfc/core.c                                     |    5 -
 net/nfc/nci/core.c                                 |  118 +++-
 net/nfc/nci/data.c                                 |    4 +
 net/nfc/nci/ntf.c                                  |  337 ++++++++--
 net/nfc/nci/rsp.c                                  |   28 +-
 net/nfc/netlink.c                                  |    6 +
 net/nfc/rawsock.c                                  |   12 -
 net/wireless/mesh.c                                |    1 +
 net/wireless/nl80211.c                             |   74 ++-
 net/wireless/reg.c                                 |   19 +-
 268 files changed, 5319 insertions(+), 4040 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--0OAP2g/MAC+5xKAE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPMDWSAAoJEJctW/TcYTgGKQcP/RaFsH7JwXqdw/vApa8okGU3
ORUBoXL+AFVm+CeHPqlmc4Vk1cTik2lGtb/4ur4ueyQITg0sH04/1K6arySt2NAO
WZQvv4SjjCJ2VcKsZwrpkCFJwgwZgWIQf3QhTZSPyfLIYVfytBO0im9uX5xvDtIE
GuNAkTbKbXSWAscldaCudeIuYO9JEgjH+OqeqqUpbZ9qr0w/HdOv+xbSqao0+GtE
4pJvujrINDhMzxpJNu5pfrO5ab7CxzTQ6UZoLdSTQtvVGGj6bQ9gRdgMUzkLI4zU
qGgK0AOX9Loe/dWWdhxZhxTtAIjnE2bsDwQA9QREysrG2saZqW6yXqIOVYkbeMcv
cUTiU3Fg7kG8D9XhG9bsfr+Dv/VOUCgB7fA40e5qLZOOexyE3poULuX6wJ8w+Y5t
fErjc4vo4tBUPia09MRIxLapFl0/d6gr5L+4ZPA6IaaLPb15Evk5sLxNVTxlRB9X
IHkGgvYGfVULh1n4/pofdyUsirOYkUbsTct6WXr8hDrYLESJPa1MLiJlWgG+qhNg
BqfeMn5xzR/X1EZ3P0wg0n1g2urscZBbqyMuiH1kNRNVQlwn5+TOrB9uyqI4feK/
GSis48ZhTncfsFFP1VuMXeYc30/W4gwKDuxgL8sAZqYrOqUznUazFiD8Iln6vGY+
qtpBKReRyTNwDYUSFRlD
=LAbr
-----END PGP SIGNATURE-----

--0OAP2g/MAC+5xKAE--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
