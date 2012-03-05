From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-03-05
Date: Mon, 5 Mar 2012 16:07:41 -0500
Message-ID: <20120305210740.GI18128@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HcAYCG3uE/tztfnV"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 051d3b50430160a86cbe4a2deef219c8038bd03f

Dave,

This is another (and maybe the last) large batch of updates
intended for 3.4.  This includes the usual sorts of enhancements and
refactoring, touching ath9k, brcm80211, iwlwifi, iwlegacy, wl12xx,
and a handful of others.  The Intel drivers in particular saw a lot
of attention, due to some ongoing refactoring there.  Johannes also
chimes-in with some mac80211 enhancements and refactoring as well.

I have not included any Bluetooth updates, due to the unresoled
coding style issues of which you are already aware.  Also, I have
pulled from the wireless tree to avoid some build breakage.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ffcb97388b1d41b1db063eb041cb9af408662127:

  Merge branch 'master' of git://gitorious.org/linux-can/linux-can-next (20=
12-03-04 21:59:39 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Amit Beka (4):
      iwlwifi: testmode new indirect RW API
      iwlwifi: added reply data to testmode HCMD send
      iwlwifi: fixes to testmode indirect access
      iwlwifi: send testmode hcmd reply with rx header

Amitkumar Karwar (3):
      mwifiex: reset encryption mode flag before association
      mwifiex: remove redundant scan operation
      mwifiex: remove unnecessary enum MWIFIEX_802_11_WEP_STATUS

Antonio Quartulli (1):
      mac80211_hwsim: correctly line up a multiline printk

Arend van Spriel (14):
      brcm80211: update the maintainers listed for brcm80211 drivers
      brcm80211: smac: fix unintended fallthru in wlc_phy_radio_init_2057()
      brcm80211: smac: remove redundant assignments from txpwrctrl_pwr_setu=
p_nphy
      brcm80211: smac: fix endless retry of A-MPDU transmissions
      brcm80211: smac: remove smatch warnings from brcmsmac code
      brcm80211: fmac: resolve smatch issues in brcmfmac code
      brcm80211: fmac: use specific types in struct brcmf_bus
      brcm80211: fmac: move module entry points to dhd_linux.c
      brcm80211: fmac: only return success in brcmf_sdbrcm_bus_init() when =
true
      brcm80211: fmac: update bus state in common driver part
      brcm80211: fmac: change allocation flag in brcmf_enq_event() function
      brcm80211: fmac: use spinlock calls saving irq flags in brcmf_enq_eve=
nt()
      brcm80211: fmac: add USB support for bcm43235/6/8 chipsets
      brcm80211: fmac: make sdio firmware filename specific

Christian Lamparter (1):
      carl9170: fix frame delivery if sta is in powersave mode

Dan Carpenter (2):
      wl12xx: remove some dead code in wl1271_plt_init()
      brcm80211: fmac: fix a couple checking after dereference bugs

Danny Kukawka (1):
      iwlwifi: iwl-agn.h included twice

Devendra.Naga (1):
      rtlwifi/rtl8192c: in _rtl92c_phy_calculate_bit_shift remove comparing=
 bitmask against 1

Don Fry (10):
      iwlwifi: create iwl_nic structure
      iwlwifi: move ucode_ver to iwl_nic
      iwlwifi: move fw_index from iwl_priv to iwl_nic
      iwlwifi: move firmware_name to iwl_nic
      iwlwifi: move firmware_loading_complete to iwl_nic
      iwlwifi: Move ucode pointers to iwl_fw
      iwlwifi: change args to ucode routines
      iwlwifi: move event and err pointers to iwl_nic
      iwlwifi: changes args to iwl_nic for firmware operations
      iwlwifi: save ucode capabilities in iwl_fw

Eliad Peller (21):
      wl12xx: check bss_conf->assoc on CHANGED_BSSID
      wl12xx: remove wl1271_tx_update_filters
      Revert "wl12xx: Change claiming of the SDIO bus"
      wl12xx: don't release/claim sdio on suspend/resume
      wl12xx: fw api change - add role_id to set_template
      wl12xx: use dev_role_id for scans
      wl12xx: fw api change - add role_id to tsf_info
      wl12xx: fw api change - update cmd/acx/event enums
      wl12xx: add TX_HW_ATTR_HOST_ENCRYPT flag
      wl12xx: add new coex params
      wl12xx: consider encryption and QoS in auto arp template
      wl12xx: Revert "wl12xx: disable auto-arp"
      wl12xx: configure arp filtering only after association
      wl12xx: declare support for hw scan while idle
      wl12xx: don't fail on AP scan
      wl12xx: Use a dedicated fw for PLT
      wl12xx: dynamically change fw according to number of active roles
      wl12xx: enter forced-psm on fw change
      wl12xx: delete wl->vif (and allow multiple vifs)
      mac80211: don't queue monitor work for HW_CONNECTION_MONITOR
      mac80211: remove redundant monitor_work enqueueing

Emmanuel Grumbach (27):
      iwlwifi: kill iwl_down and s/__iwl_down/iwl_down
      iwlwifi: iwl_set_hw_params returns always 0
      iwlwifi: use enhance_sensitivity from iwl_fw
      iwlwifi: document the transport layer
      iwlwifi: the transport knows its state
      iwlwifi: SRAM size moves from hw_params to cfg
      iwlwifi: parse_tlv functions set the fw_version string
      iwlwifi: move content of iwl_probe to post fetch_fw
      iwlwifi: introducing the drv object's flows
      iwlwifi: drv object can release its own memory
      iwlwifi: rename iwl_remove to iwl_op_mode_dvm_stop
      iwlwifi: virtualize the op_mode
      iwlwifi: use sparse compliant __aligned__ attribute
      iwlwifi: virtualize op_mode's free skb
      iwlwifi: virtualize op_mode's rx
      iwlwifi: virtualize op_mode's stop/start queue
      iwlwifi: virtualize op_mode's set_hw_rf_kill
      iwlwifi: virtualize op_mode's fw_error
      iwlwifi: remove a few dereferences to iwl_priv from the tansport
      iwlwifi: move eeprom defines to iwl-eeprom.c
      iwlwifi: eeprom gets transport and not bus
      iwlwifi: kill iwl_bus.h
      iwlwifi: remove iwl_print_rx_config_cmd from shared
      iwlwifi: remove iwl_reset_traffic_log from shared
      iwlwifi: document the operational mode
      iwlwifi: iwl-trans.h doesn't need all these includes
      iwlwifi: fix IDI compilation

Eyal Shapira (12):
      wl12xx: remove PS management code
      wl12xx: add support for HW dynamic PS
      wl12xx: add dynamic_ps_timeout debugfs file
      wl12xx: remove 2 unused parameters in wl1271_ps_set_mode()
      wl12xx: enable/disable BET with AUTO_PS/ACTIVE
      wl12xx: change WLVIF_FLAG_PSM name and remove WLVIF_FLAG_PSM_REQUESTED
      wl12xx: Set different wake up conditions in case of suspend
      wl12xx: add suspend_listen_interval debugfs file
      wl12xx: add forced_ps mode
      wl12xx: add forced_ps debugfs file
      wl12xx: use split scan for normal scan
      wl12xx: add split_scan_timeout debugfs file

Felix Fietkau (1):
      ath9k_hw: remove duplicate initvals

Florian Fainelli (1):
      zd1211rw: wait between setting hash table and powering radio on

Franky Lin (1):
      brcm80211: fmac: make sure cancel_work_sync only called after INIT_WO=
RK

Gertjan van Wingerde (1):
      rt2x00: Add support for D-Link DWA-127 to rt2800usb.

Greg Dietsche (4):
      iwlegacy: Kconfig: Move Debugging Options
      iwlegacy: Kconfig: Change Debug Option to be more clear
      iwlegacy: remove enum iw_calib and related code
      iwlegacy: remove unused enum il4965_calib_enabled_state

Ido Reis (1):
      wl12xx: increase max probe-req template size to WL1271_CMD_TEMPL_MAX_=
SIZE

Ido Yariv (3):
      wl12xx: Acquire lock before stopping plt
      wl12xx: Power off after flushing work
      wl12xx: Fix potential interrupt storm

Jakub Kicinski (3):
      mac80211: use proper sub_if_data on suspend path
      rt2800: Add documentation on MCU requests
      rt2800pci: Fix 'Error - MCU request failed' during initialization

Johannes Berg (15):
      iwlwifi: trace debug messages
      iwlwifi: move workqueue to priv
      iwlwifi: give PCIe its own lock
      cfg80211: restructure AP/GO mode API
      mac80211: clean up asm/unaligned.h inclusion
      mac80211: fix associated vs. idle race
      mac80211: fix auth/assoc data & timer leak
      mac80211: fix sta_info_flush() return value
      mac80211: remove local_to_hw
      iwlwifi: move uCode flags handling to op_mode
      cfg80211: remove cookies from callbacks
      mac80211: dont call cfg80211 from ieee80211_send_deauth_disassoc
      mac80211: fix ieee80211_set_disassoc() sending DelBA
      mac80211: make deauth/disassoc sequence more natural
      mac80211: handle non-bufferable MMPDUs correctly

John Li (4):
      rt2x00:Fix typo
      rt2x00:Add debug message for new chipset
      rt2x00:Add VCO recalibration
      rt2x00:Add RT5372 chipset support

John W. Linville (5):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'wireless-next' of git://git.kernel.org/.../iwlwifi/iwlw=
ifi
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      carl9170: fix breakage from "mac80211: handle non-bufferable MMPDUs c=
orrectly"
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jonathan Bither (1):
      ath5k:Remove __raw_read and __raw_write

Larry Finger (2):
      rtlwifi: rtl8192c-common: rtl8192se: rtl8192de: Simplify if statements
      rtlwifi: Fix breakage in debug functions when built as a module

Luciano Coelho (11):
      wl1251: fix sparse warning
      wl1251: convert 32-bit values to le32 before writing to the chip
      wl1251: enable sparse endianess check by default
      wl12xx: enable sparse endianess check by default
      wl12xx: cancel delayed elp work and clear flags when stopping PLT
      wl12xx: move partition table definition to io.c
      wl12xx: read chip ID and HW PG version during probe
      wl12xx: use two MAC addresses based on the NVS or from fuse ROM
      wl12xx: add testmode operation to read the BD_ADDR from Fuse ROM
      wl12xx: remove unnecessary shadow declaration
      wl12xx: fix typo in fwlog module param description

Masanari Iida (1):
      wireless: Fix typo in mac80211_hwsim.c

Meenakshi Venkataraman (1):
      iwlwifi: enable receiving beacons when not associated

Mohammed Shafi Shajakhan (2):
      ath9k: remove obsolete comments
      ath9k: remove unnecessary PS wrappers

Nicolas Cavallari (1):
      carl9170: Fix memory accounting when sta is in power-save mode.

Pavel Roskin (1):
      ath9k: avoid useless cast from (struct ath_rateset *) to (u8 *) and b=
ack

Pontus Fuchs (3):
      wl12xx: Make sure HW is available in sched scan ops
      wl12xx: Set IEEE80211_TX_RC_MCS on MCS rates on TX complete.
      wl12xx: Set IEEE80211_TX_RC_SHORT_GI if short GI was used on

Rafa=C5=82 Mi=C5=82ecki (1):
      brcm80211: fmac: use correct firmware filename

Stanislav Yakovlev (2):
      net/wireless: ipw2x00: Use IW_HANDLER macro from linux/wireless.h
      ipw2x00: remove ipw2100_rates_11b[]

Stanislaw Gruszka (24):
      iwlegacy: dump stack when fail to gain access to the device
      iwlegacy: always check if got h/w access before write
      iwlegacy: cleanup/fix memory barriers
      iwlegacy: use writeb,writel,readl directly
      iwlegacy: regulatory_bands is not an ops
      iwlegacy: gather all 4965 handlers in one place
      iwlegacy: move debugfs_ops to il_priv
      iwlegacy: remove temp_ops
      iwlegacy: merge eeprom_ops into lib_ops
      iwlegacy: remove il_apm_ops
      iwlegacy: merge il_lib_ops into il_ops
      iwlegacy: merge all ops structures into one
      iwlegacy: get rid of tx/rx traffic log
      iwlegacy: improve mac operation debuggability a bit
      iwleagcy: remove old comments
      iwleagcy: fix ident code damage
      iwlegacy: do not grab nic access if rfkill
      iwlegacy: check correct il_poll_bit error value
      iwlegacy: small il4965_set_hw_ready cleanup
      iwlegacy: enable only rfkill interrupt when rfkill switch is on durin=
g IFF_UP
      iwlegacy: small queue initializations cleanup
      iwlegacy: s/S_RF_KILL_HW/S_RFKILL/g
      iwlegacy: s/il_txq_mem/il_free_txq_mem/g
      iwlegacy: remove il_is_rfkill_hw

Sujith Manoharan (35):
      ath9k: Remove unnecessary variable initialization
      ath9k: Merge wiphy and misc debugfs files
      ath9k: Add a debugfs file to display reset statistics
      ath9k: Prettify recv debugfs file output
      ath9k: Fix phyerr debug statistics
      ath9k: Remove unused initvals
      ath9k: Initialize NF values properly
      ath9k: Fix programming SYNTH4 for AR9462
      ath9k: Fix descriptor length for AR9462
      ath9k: Remove AR9462 v1.0 support
      ath9k: Cleanup MCI init/deinit routines
      ath9k: Initialize MCI params using a helper
      ath9k: Move BTCOEX init/deinit functions to gpio.c
      ath9k: Use proper start/stop routines for BTCOEX
      ath9k: Process BTCOEX interrupts using a helper
      ath9k: Calculate ampdu limit using a helper
      ath9k: Use CONFIG_ATH9K_BTCOEX_SUPPORT
      ath9k: Initialize BTCOEX scheme using a helper
      ath9k_hw: Use a helper function to get MCI ISR
      ath9k_hw: Handle MCI power state using a helper
      ath9k_hw: Setup MCI calibration using a helper
      ath9k_hw: Cleanup MCI bits from ath9k_hw_reset()
      ath9k_hw: Cleanup MCI bits from hw.h
      ath9k_hw: Cleanup MCI function declarations
      ath9k_hw: Use CONFIG_ATH9K_BTCOEX_SUPPORT
      ath9k_htc: Start/stop btcoex using a helper
      ath9k_htc: Init BTCOEX inside htc_drv_gpio.c
      ath9k_htc: Use CONFIG_ATH9K_BTCOEX_SUPPORT
      ath9k: Remove ATH_BTCOEX_CFG_NONE checks
      ath9k: Remove ATH9K_HW_CAP_MCI checks
      ath9k: Modify ATH9K_BTCOEX_SUPPORT
      ath9k_hw: Cleanup MCI reset routine
      ath9k_hw: Remove HW revision checks
      ath9k_hw: MCI whitespace/debug cleanup
      ath9k: Cleanup mci.c

Tim Gardner (1):
      rtlwifi: rtl8192se firmware load can overflow target buffer

Tristan Pourcelot (1):
      Correcting typos in rtlwifi/base.c

Wey-Yi Guy (4):
      iwlwifi: log as error when error detected
      iwlwifi: remove un-necessary return
      iwlwifi: one more sku added to 6x35 series
      iwlwifi: update pci subsystem id

Zefir Kurtisi (1):
      ath9k: decouple RX error checking for DFS

 MAINTAINERS                                        |    1 -
 drivers/net/wireless/ath/ath5k/ahb.c               |   20 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |    4 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   10 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   82 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   16 +-
 drivers/net/wireless/ath/ath9k/Makefile            |   10 +-
 drivers/net/wireless/ath/ath9k/ar9001_initvals.h   |  270 ---
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  107 +-
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |   98 --
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   42 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    4 -
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   88 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   48 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.h        |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        | 1250 ++++++-------
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |  233 +++
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   15 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   23 +-
 .../net/wireless/ath/ath9k/ar9462_1p0_initvals.h   | 1833 ----------------=
----
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |  465 -----
 drivers/net/wireless/ath/ath9k/ath9k.h             |   35 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |   77 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    4 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  373 ++---
 drivers/net/wireless/ath/ath9k/gpio.c              |  123 ++-
 drivers/net/wireless/ath/ath9k/htc.h               |   21 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |   73 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   32 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   15 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  178 +--
 drivers/net/wireless/ath/ath9k/hw.h                |  208 +--
 drivers/net/wireless/ath/ath9k/init.c              |   67 +-
 drivers/net/wireless/ath/ath9k/main.c              |   36 +-
 drivers/net/wireless/ath/ath9k/mci.c               |  290 +---
 drivers/net/wireless/ath/ath9k/mci.h               |    5 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    6 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    5 -
 drivers/net/wireless/ath/ath9k/xmit.c              |   19 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    9 +-
 drivers/net/wireless/brcm80211/Kconfig             |   17 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    6 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   14 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   17 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   59 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   32 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      | 1623 +++++++++++++++++
 drivers/net/wireless/brcm80211/brcmfmac/usb.h      |   84 +
 drivers/net/wireless/brcm80211/brcmfmac/usb_rdl.h  |   75 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   13 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    1 -
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   28 +-
 drivers/net/wireless/brcm80211/brcmsmac/srom.c     |   14 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |  101 +-
 drivers/net/wireless/iwlegacy/3945-debug.c         |    6 +
 drivers/net/wireless/iwlegacy/3945-mac.c           |  108 +-
 drivers/net/wireless/iwlegacy/3945.c               |  133 +-
 drivers/net/wireless/iwlegacy/3945.h               |    8 +-
 drivers/net/wireless/iwlegacy/4965-calib.c         |   16 +-
 drivers/net/wireless/iwlegacy/4965-debug.c         |    6 +
 drivers/net/wireless/iwlegacy/4965-mac.c           |  592 +++++--
 drivers/net/wireless/iwlegacy/4965.c               |  402 +----
 drivers/net/wireless/iwlegacy/4965.h               |   21 +-
 drivers/net/wireless/iwlegacy/Kconfig              |   78 +-
 drivers/net/wireless/iwlegacy/common.c             |  548 ++-----
 drivers/net/wireless/iwlegacy/common.h             |  247 +--
 drivers/net/wireless/iwlegacy/debug.c              |  260 ++--
 drivers/net/wireless/iwlwifi/Makefile              |    3 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   18 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   28 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   18 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |    5 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   20 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  144 ++-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   29 +-
 drivers/net/wireless/iwlwifi/iwl-bus.h             |  145 --
 drivers/net/wireless/iwlwifi/iwl-cfg.h             |    2 +
 drivers/net/wireless/iwlwifi/iwl-core.c            |   38 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-debug.c           |  127 ++
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   84 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   11 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   33 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   65 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  103 ++
 drivers/net/wireless/iwlwifi/iwl-drv.h             |  123 ++
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  156 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   83 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |  198 +++
 drivers/net/wireless/iwlwifi/iwl-pci.c             |   70 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |   45 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |  432 +++--
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   64 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |    6 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |   88 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |   11 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |   46 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  207 ++-
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |  394 ++---
 drivers/net/wireless/iwlwifi/iwl-ucode.h           |   46 +-
 drivers/net/wireless/iwlwifi/iwl-wifi.h            |   37 +
 drivers/net/wireless/mac80211_hwsim.c              |   10 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    9 +-
 drivers/net/wireless/mwifiex/fw.h                  |    5 -
 drivers/net/wireless/mwifiex/init.c                |    2 +-
 drivers/net/wireless/mwifiex/join.c                |    5 +-
 drivers/net/wireless/mwifiex/main.h                |    2 +-
 drivers/net/wireless/mwifiex/scan.c                |   47 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   10 +-
 drivers/net/wireless/p54/txrx.c                    |    2 +-
 drivers/net/wireless/rt2x00/Kconfig                |    2 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   25 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  245 +++-
 drivers/net/wireless/rt2x00/rt2800lib.h            |    1 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |   37 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   16 +
 drivers/net/wireless/rt2x00/rt2x00.h               |   13 +
 drivers/net/wireless/rt2x00/rt2x00config.c         |    3 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    4 +
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   13 +
 drivers/net/wireless/rt2x00/rt2x00link.c           |   39 +
 drivers/net/wireless/rtlwifi/Kconfig               |    2 +-
 drivers/net/wireless/rtlwifi/base.c                |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  156 +--
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |  187 +--
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   40 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    3 +-
 drivers/net/wireless/wl1251/Makefile               |    2 +
 drivers/net/wireless/wl1251/boot.c                 |    2 -
 drivers/net/wireless/wl1251/io.h                   |    9 +-
 drivers/net/wireless/wl1251/wl1251.h               |    2 +-
 drivers/net/wireless/wl12xx/Makefile               |    2 +
 drivers/net/wireless/wl12xx/acx.c                  |   17 +-
 drivers/net/wireless/wl12xx/acx.h                  |  149 +-
 drivers/net/wireless/wl12xx/boot.c                 |  105 +-
 drivers/net/wireless/wl12xx/boot.h                 |   10 -
 drivers/net/wireless/wl12xx/cmd.c                  |  143 ++-
 drivers/net/wireless/wl12xx/cmd.h                  |  148 +-
 drivers/net/wireless/wl12xx/conf.h                 |   51 +-
 drivers/net/wireless/wl12xx/debug.h                |    1 +
 drivers/net/wireless/wl12xx/debugfs.c              |  241 +++-
 drivers/net/wireless/wl12xx/event.c                |  154 +--
 drivers/net/wireless/wl12xx/event.h                |   20 +-
 drivers/net/wireless/wl12xx/init.c                 |   55 +-
 drivers/net/wireless/wl12xx/io.c                   |   59 +
 drivers/net/wireless/wl12xx/io.h                   |    2 +
 drivers/net/wireless/wl12xx/main.c                 |  674 +++++---
 drivers/net/wireless/wl12xx/ps.c                   |   34 +-
 drivers/net/wireless/wl12xx/ps.h                   |    2 +-
 drivers/net/wireless/wl12xx/reg.h                  |   27 +
 drivers/net/wireless/wl12xx/rx.c                   |    2 +-
 drivers/net/wireless/wl12xx/scan.c                 |   56 +-
 drivers/net/wireless/wl12xx/scan.h                 |    2 +-
 drivers/net/wireless/wl12xx/sdio.c                 |   29 +-
 drivers/net/wireless/wl12xx/spi.c                  |    8 +-
 drivers/net/wireless/wl12xx/testmode.c             |   50 +
 drivers/net/wireless/wl12xx/tx.c                   |   75 +-
 drivers/net/wireless/wl12xx/tx.h                   |    5 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |   46 +-
 drivers/net/wireless/wl12xx/wl12xx_80211.h         |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |   12 +-
 include/linux/nl80211.h                            |   34 +-
 include/net/cfg80211.h                             |   76 +-
 include/net/mac80211.h                             |   17 +-
 net/mac80211/cfg.c                                 |  158 +-
 net/mac80211/ibss.c                                |    1 -
 net/mac80211/ieee80211_i.h                         |   15 +-
 net/mac80211/iface.c                               |    2 +
 net/mac80211/key.c                                 |    1 +
 net/mac80211/main.c                                |    6 +-
 net/mac80211/mesh.h                                |    1 -
 net/mac80211/mesh_hwmp.c                           |    1 +
 net/mac80211/mlme.c                                |  189 ++-
 net/mac80211/pm.c                                  |    2 +-
 net/mac80211/rx.c                                  |    1 +
 net/mac80211/sta_info.c                            |    8 +-
 net/mac80211/status.c                              |    1 +
 net/mac80211/tx.c                                  |   32 +-
 net/mac80211/util.c                                |    2 +-
 net/wireless/mlme.c                                |    6 +-
 net/wireless/nl80211.c                             |  255 ++--
 191 files changed, 8729 insertions(+), 8823 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/ath9k/ar9462_1p0_initvals.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/usb.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/usb.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/usb_rdl.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-bus.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-debug.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-drv.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-drv.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-op-mode.h

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--HcAYCG3uE/tztfnV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPVSscAAoJEJctW/TcYTgGJf4QAIToWv2jWyHvQffP32pn5Q9H
N8QksOtZikjDtUXXXHqlzhsV8zrQBxjpMpVmj2P/2JLNUqcV5dcjao9G+ayWOnha
R4FCOXLUdyKL1FwWf8wvaAjWRBqEoFuLAWvj652nUqrzgL2ZfbPTai3Zxk2up4ju
ij34gP1Q53gQuKDNtrHkm4Q5ODmyvpETWthhL0eQUxZZWTpKsfJ5LTIpM1KCLuTD
diz+joosFKrB1PAggIhthHBveva1etud4lzZH0fO06v80Q6xslumpe/KvpSgweeD
GDmluuscBPD4VJRJV8RMDuM1cqR6Q3WjEMR0VDpYppqqO/xKwF0x+G/ji3X9ERF2
b8S1g+WZpoGuKDKRijk/8kJQb/KDlOluEhve9Ze/L8BHVhOdJ5F2n+xr23sQjUD9
9DFKFxVf3Qp4LVfoI2Xic4kV7h4OAp4ALmjUNJem7iq4W9s/unf8Gza02vGcYeIE
aDavl1Tzyc7GnZed6S4CZT1+Esms0uG5zTwhIJST0Vs26JCtes1vh08GMr2T0Yfh
oIsJvFgO/dPnbaVCc4u/wuu58ML0+NFFDnFwf6cPluM+wyc/QH0U0gdE+q2LsVeV
4LAf5undwBoNUoJ/xsIfJicKPsu/st7dFkjhyEADuekP3gKtvZU83X/EDDVaIglk
JdknreiIZtK+hVMZRS5P
=cUUR
-----END PGP SIGNATURE-----

--HcAYCG3uE/tztfnV--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
