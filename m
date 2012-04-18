From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-04-18
Date: Wed, 18 Apr 2012 15:05:22 -0400
Message-ID: <20120418190521.GB2436@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="R3G7APHDIzY6R/pk"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 59ef43e681d103a51c3727dad0315e093f07ec61

Dave,

Another batch of wireless updates intended for 3.5...

Highlights include some wl12xx refactoring, NFC HCI and SHDLC updates,
an ath6kl pull, some mesh updates, and the usual updates to iwlwifi,
ath9k, brcm80211, mwifiex, libertas, and other drivers.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 91fbe33034c184c6a60e31c2207a2f7ec2f180dc:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge (=
2012-04-18 13:21:59 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Aarthi Thiruvengadam (2):
      ath6kl: handle probe response from P2P device in P2P GO mode
      ath6kl: add debug log for AP MLME operations

Amit Beka (1):
      iwlwifi: added HBUS_TARG_TEST_REG

Amitkumar Karwar (5):
      mwifiex: set default regulatory domain
      mwifiex: display correct country information in debugfs "info"
      mwifiex: use asynchronous firmware loading
      mwifiex: code cleanup in BSS handling
      mwifiex: corrections in timestamp related code

Andreas Hartmann (1):
      rt2x00: Don't let mac80211 send a BAR when an AMPDU subframe fails

Arend van Spriel (5):
      brcm80211: fmac: make brcmf_net_attach() static
      brcm80211: fmac: remove primary mac address handling from brcmf_net_a=
ttach
      brcm80211: fmac: register primary net device with device mac address
      brcm80211: smac: do not use US as fallback regulatory hint
      brcm80211: smac: only provide valid regulatory hint

Arik Nemtsov (19):
      wlcore/wl12xx: create per-chip-family private storage
      wlcore/wl12xx: set the number of Tx descriptors per chip family
      wlcore/wl12xx: change GEM Tx-spare blocks per-vif
      wlcore/wl12xx: add hw op for calculating hw block count per packet
      wlcore/wl12xx: add hw op for setting blocks in hw_tx_desc
      wlcore/wl12xx: add hw op for setting frame length in tx_hw_desc
      wlcore/wl12xx: add global elements to convert hw-rates to standard ra=
tes
      wlcore: introduce Rx block-size alignment HW quirk
      wlcore/wl12xx: add hw op for getting rx buffer data alignment
      wlcore/wl12xx: add hw op for getting rx packet data length
      wlcore/wl12xx: split Tx completion to immediate/delayed
      wlcore/wl12xx: turn no-Tx-align quirk into Tx-align
      wlcore/wl12xx: add hw op for vif init
      wlcore/wl12xx: expand functionality of cmd_trigger HW op
      wlcore/wl12xx: add hw op to get rate-mask for AP-link in STA mode
      wlcore/wl12xx: set HT capabilities per chip-family
      wlcore: set max_rx_agg_subframes in mac80211 according to HT conf
      wlcore: add module param to prevent HW recovery
      wlcore/wl12xx: adapt FW status for multiple families

Avinash Patil (1):
      mwifiex: add support for WPS2.0

Axel Lin (1):
      net/wireless: use module_pci_driver

Bala Shanmugam (1):
      ath6kl: Set background scan period.

Ben Greear (2):
      ath9k: Use macro to decrease code when priting recv stats.
      ath9k: Gather and report IRQ sync_cause errors.

Bing Zhao (1):
      mwifiex: fix typo in RSSI_HIGH event handling

Chun-Yeow Yeoh (1):
      mac80211: fix the assignment of PREQ's MAC address for Proactive RANN

Daniel Drake (5):
      libertas: Firmware loading simplifications
      libertas: harden-up exit paths
      libertas: add asynchronous firmware loading capability
      libertas SDIO: convert to asynchronous firmware loading
      libertas USB: convert to asynchronous firmware loading

David Spinadel (4):
      iwlwifi: set size of ucode section
      iwlwifi: remove double verification of ucode sections
      iwlwifi: phy db channel to tx power channel group
      iwlwifi: expose static methods for MVM use

Don Fry (3):
      iwlwifi: complete STATUS_READY refactoring
      iwlwifi: move HCMD_ACTIVE to trans
      iwlwifi: move status definitions from iwl-shared

Dor Shaish (1):
      iwlwifi: Disabling calibrations variable

Eliad Peller (2):
      wl12xx: set do_join on BSS_CHANGED_ASSOC
      wl12xx: free ap keys only in ap mode

Emmanuel Grumbach (1):
      iwlwifi: remove uneeded include from iwl-pci.c

Eric Lapuyade (7):
      NFC: Export target lost function
      NFC: HCI support
      NFC: SHDLC implementation
      NFC: Add HCI documentation
      NFC: Fix next target_idx type and rename for clarity
      NFC: Changed target activated state logic
      NFC: Add Core support to generate tag lost event

Eyal Shapira (4):
      wl12xx: fix race between suspend/resume and recovery
      wl12xx: fix a memory leak of probereq template upon recovery
      wl12xx: adaptive sched scan dwell times
      wl12xx: increase scan timeout to 30s

Felix Fietkau (3):
      ath9k_hw: add support for 8 AP mode interfaces
      ath9k: do not register LEDs on AR913x
      ath9k: optimize the hardware hang check

Forest Bond (2):
      rtl8192de: Clean up and fix 92D cut version constants and macros.
      rtl8192de: Recognize 92D E-CUT version.

Franky Lin (3):
      brcm80211: fmac: add frame header extension support
      brcm80211: fmac: postpone dongle RF enabling.
      brcm80211: fmac: clean up chip id table

Gabor Juhos (8):
      ath9k: use ath9k_hw_update_regulatory_maxpower in ath9k_hw_def_set_tx=
power
      ath9k: use consistent value for REDUCE_SCALED_POWER_BY_THREE_CHAIN
      ath9k: introduce ath9k_hw_get_scaled_power helper
      ath9k: simplify ath9k_hw_get_scaled_power function
      ath9k: merge power correction constants
      ath9k: remove unused PWRINC_*_TO_*_CHAIN defines
      ath9k: move ath9k_hw_fbin2freq function to eeprom.h
      ath9k: use ath9k_hw_fbin2freq instead of FBIN2FREQ

Jakub Kicinski (4):
      rt2800: introduce wpdma_disable function
      rt2800: add disabling of DMA before loading firmware
      rt2800: initialize queues before giving up due to DMA error
      rt2800: zero registers of unused TX rings

Javier Cardona (4):
      mac80211: Set the correct values for hwmp (1) and airtimeLinkMetric (=
1)
      mac80211_hwsim: fixup for tsf setting
      mac80211: Choose a new toffset setpoint if a big tsf jump is detected.
      mac80211: Take into account TSF adjustment latency in Toffset setpoint

Jesper Juhl (7):
      wireless, at76c50x:: Don't needlessly test for NULL before calling re=
lease_firmware()
      wireless, atmel: remove pointless test for NULL before release_firmwa=
re() call
      ipw2200: remove a redundant NULL check before calling release_firmwar=
e()
      wireless, libertas: remove redundant NULL tests before calling releas=
e_firmware()
      wireless, mwifiex: drop redundant NULL test before call to release_fi=
rmware()
      wireless, orinoco: release_firmware() tests for NULL, remove explicit=
 tests before calls
      ipw2100: remove a redundant NULL check before calling release_firmwar=
e()

Jim Cromie (2):
      brcm80211: replace open-coded ARRAY_SIZE with the macro
      prism54: replace open-coded ARRAY_SIZE with macro

Joe Perches (1):
      ath6kl: Add __printf verification to ath6kl_printk

Johannes Berg (20):
      iwlwifi: move rx_page_order into transport
      iwlwifi: remove watchdog debugfs file
      iwlwifi: remove unneeded struct declarations
      iwlwifi: move queue watchdog into transport
      iwlwifi: move hw_params into priv
      iwlwifi: remove ack_check module parameter
      iwlwifi: split force_reset debugfs file
      iwlwifi: move eeprom into priv
      iwlwifi: create device configuration header file
      iwlwifi: introduce device family enum
      iwlwifi: dynamically determine lib_ops
      iwlwifi: make iwl_sta_fill_lq static
      iwlwifi: calculate active legacy rates per station
      cfg80211: enforce lack of interface combinations
      iwlwifi: remove no_sleep_autoadjust
      iwlwifi: remove uCode alternatives mechanism
      iwlwifi: remove antenna from mod params struct
      iwlwifi: remove iwl_tx_queue declaration
      iwlwifi: optimize struct iwl_cmd_meta layout
      iwlwifi: remove get_cmd_string

John W. Linville (4):
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'wireless-next' of git://git.kernel.org/.../iwlwifi/iwlw=
ifi
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jonathan Bither (1):
      ath5k: use compare_ether_addr on MAC addresses instead of memcmp

Julia Lawall (1):
      drivers/net/wireless/libertas/if_usb.c: add missing debugging code

Kalle Valo (11):
      ath6kl: abort normal scan when scheduled scan is started
      Merge remote branch 'wireless-next/master' into ath6kl-next
      ath6kl: set ram reserved size only for ar6003
      ath6kl: Add tx_complete() to struct htc_ep_callbacks
      ath6kl: add tx_comp_multi() to struct htc_ep_callbacks
      ath6kl: add pointer to the skb in htc_packet
      ath6kl: add rx data padding support
      ath6kl: remove void pointer from ath6kl_credit_setup()
      ath6kl: add htc ops
      ath6kl: Add HTC pipe implementation
      ath6kl: add full USB support

Larry Finger (1):
      rtlwifi: rtl8192ce: Remove false positives for kmemleak

Lorenzo Bianconi (2):
      rtlwifi: support for Belkin Surf N300 XR
      mac80211: fix an issue in ieee80211_tx_info count field management

Luciano Coelho (23):
      wireless/wl12xx/wl1251: move TI WLAN modules to a common ti subdirect=
ory
      wl12xx/wlcore: rename wl12xx to wlcore
      wl12xx/wlcore: spin out the wl12xx probe from wlcore to a new wl12xx
      wl12xx/wlcore: initial split of probe
      wl12xx/wlcore: move wl1271 struct to wlcore and add ops
      wlcore/wl12xx: implement chip-specific partition tables
      wlcore/wl12xx: implement chip-specific register tables
      wlcore/wl12xx: add chip-specific identify chip operation
      wlcore/wl12xx: move get_pg_ver to the lower driver
      wlcore/wl12xx: move top initialization to wl12xx
      wlcore/wl12xx: move MAC address reading operation to lower driver
      wlcore/wl12xx: add command trigger and event ack operations
      wlcore/wl12xx: add quirk for legacy NVS support
      wlcore: remove some unnecessary event mailbox address reads
      wlcore: add quirk to disable ELP
      wlcore/wl12xx: add prepare_read hw op for Rx data
      wlcore/wl12xx: add hw_init operation
      wlcore/wl12xx: move runtime configuration struct to the lower driver
      wlcore/wl12xx: move extended radio configuration parameters to wl12xx
      wlcore/wl12xx: use a single memory config and reset if using wl127x
      wlcore/wl12xx: move identify firmware function to a lower driver op
      Merge branch 'wl12xx-next' into for-linville
      mac80211: check IEEE80211_HW_QUEUE_CONTROL in ieee80211_check_queues()

Matt Renzelmann (1):
      hostap: GFP_ATOMIC/GFP_KERNEL cleanup

Meenakshi Venkataraman (20):
      iwlwifi: move iwlagn_hw_valid_rtc_data_addr prototype
      iwlwifi: move channel switch related functions
      iwlwifi: move iwl_free_skb and mark it static
      iwlwifi: move iwl_set_hw_rfkill_state and mark it static
      iwlwifi: move iwl_is_ht40_tx_allowed out of iwl-core.c
      iwlwifi: move iwl_set_rxon_ht to iwl-agn-rxon.c
      iwlwifi: move iwl_set_rxon_channel to iwl-agn-rxon.c
      iwlwifi: move iwl_set_flags_for_band to iwl-agn-rxon.c
      iwlwifi: move iwl_connection_init_rx_config to iwl-agn-rxon.c
      iwlwifi: move iwl_set_rate to iwl-agn-rxon.c
      iwlwifi: move iwl_chswitch_done to iwl-mac80211.c
      iwlwifi: move iwlagn_fw_error to iwl-agn.c
      iwlwifi: move iwl_set_tx_power and make it static
      iwlwifi: move iwl_send_bt_config and mark it static
      iwlwifi: move iwl_print_rx_config_cmd to iwl-agn-rxon.c
      iwlwifi: move iwl_send_statistics_request to iwl-agn.c
      iwlwifi: move iwl_force_rf_reset to iwl-agn-rx.c
      iwlwifi: move iwl_bcast_addr to iwl-agn-sta.c
      iwlwifi: move utility functions out of iwl-core.h
      iwlwifi: move scan related declarations out of iwl-core.h

Michal Kazior (1):
      mac80211: remove hw.conf.channel usage where possible

Mircea Gherzan (1):
      wl12xx: fix DMA-API-related warnings

Mohammed Shafi Shajakhan (1):
      mac80211: remove ieee80211_rx_bss_get

Pontus Fuchs (1):
      cfg80211: Add channel information to NL80211_CMD_GET_INTERFACE

Raja Mani (4):
      ath6kl: Add ARP offload related statistic info in tgt_stats
      ath6kl: Isolate host sleep mode config part from ath6kl_wow_suspend
      ath6kl: Optimize target power in deep sleep suspend
      ath6kl: Store scan request info in-advance before sending SCAN request

Rajkumar Manoharan (6):
      ath9k: fix ibss fair beacon distribution for AR9462
      ath9k: fix ibss beacon next tbtt
      cfg80211: increse bss expire time
      ath9k: reset noiseimmunity level to default
      ath9k: skip beaconing when reset work is pending
      ath9k: fix beacon descriptor

Samuel Ortiz (10):
      NFC: Add a target lost netlink event
      NFC: The core part should generate the target index
      NFC: Dump LLCP frames
      NFC: No need to apply twice the modulo op to LLCP's recv_n
      NFC: Fix LLCP TLV building routine
      NFC: Call llcp_add_header properly when sending LLCP DM or DISC
      NFC: Convert pn533 from tasklet to workqueues
      NFC: pn533 Rx chaining support
      NFC: Add MIUX to the local LLCP general bytes
      NFC: Fix LLCP link timeout typo

Stanislav Yakovlev (1):
      net/wireless: ipw2x00: add supported cipher suites to wiphy initializ=
ation

Stanislaw Gruszka (2):
      mac80211: do not scan and monitor connection in parallel
      mac80211: protect ->scanning by mutex in ieee80211_work_work()

Sujith Manoharan (2):
      ath9k_hw: Remove BTCOEX initvals
      ath9k_htc: Add Panasonic N5HBZ0000055 device id

Vasanthakumar Thiagarajan (7):
      ath6kl: Dump htc header when invalid Rx frame length is detected
      ath6kl: Configure inactivity timeout in fw
      ath6kl: Support net_stats.multicast
      ath6kl: Fix target assert in p2p bringup with multi vif
      ath6kl: Don't advertise HT40 support in 2.4 Ghz
      ath6kl: Configure htcap in fw based on the channel type in AP mode
      ath6kl: Fix 4-way handshake failure in AP and P2P GO mode

Victor Goldenshtein (1):
      wl12xx: fix station channel switch

Vivek Natarajan (2):
      ath6kl: Use vmalloc instead of kmalloc for fw
      ath6kl: Fix scan related issue on suspend-resume

Wey-Yi Guy (7):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into wireless-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into wireless-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into wireless-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into wireless-next
      iwlwifi: more generic name for bluetooth command
      iwlwifi: change the default P2P support to "Yes"
      mac80211: add function retrieve average rssi

Xose Vazquez Perez (2):
      wireless: rt2x00: rt{2500,73}usb.c put back duplicate id
      wireless: rt2x00: rt2800pci add more RT539x ids

Yoshinori Sato (1):
      ath5k: add PCI id

Zefir Kurtisi (1):
      ath9k: remove dead code

 Documentation/nfc/nfc-hci.txt                      |  155 ++
 MAINTAINERS                                        |   27 +-
 drivers/net/wireless/Kconfig                       |    3 +-
 drivers/net/wireless/Makefile                      |    4 +-
 drivers/net/wireless/adm8211.c                     |   17 +-
 drivers/net/wireless/at76c50x-usb.c                |    6 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |    2 +-
 drivers/net/wireless/ath/ath5k/base.c              |    4 +-
 drivers/net/wireless/ath/ath5k/pci.c               |   27 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |    9 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    8 +-
 drivers/net/wireless/ath/ath6kl/Makefile           |    3 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  417 ++++-
 drivers/net/wireless/ath/ath6kl/common.h           |    4 +-
 drivers/net/wireless/ath/ath6kl/core.c             |   30 +-
 drivers/net/wireless/ath/ath6kl/core.h             |   34 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |    6 +
 drivers/net/wireless/ath/ath6kl/debug.h            |    1 +
 drivers/net/wireless/ath/ath6kl/hif-ops.h          |   34 +
 drivers/net/wireless/ath/ath6kl/hif.h              |    6 +
 drivers/net/wireless/ath/ath6kl/htc-ops.h          |  113 ++
 drivers/net/wireless/ath/ath6kl/htc.h              |   98 +-
 .../net/wireless/ath/ath6kl/{htc.c =3D> htc_mbox.c}  |   85 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         | 1713 ++++++++++++++++=
++++
 drivers/net/wireless/ath/ath6kl/init.c             |   57 +-
 drivers/net/wireless/ath/ath6kl/main.c             |    4 +
 drivers/net/wireless/ath/ath6kl/sdio.c             |    2 +-
 drivers/net/wireless/ath/ath6kl/txrx.c             |   23 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |  785 +++++++++-
 drivers/net/wireless/ath/ath6kl/wmi.c              |   80 +
 drivers/net/wireless/ath/ath6kl/wmi.h              |   40 +
 drivers/net/wireless/ath/ath9k/ani.c               |    8 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    1 -
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    1 +
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |    1 -
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   52 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    1 -
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    5 -
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    2 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   14 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |   16 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    2 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   13 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  188 +--
 drivers/net/wireless/ath/ath9k/debug.h             |   23 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |   40 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |   14 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   30 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   38 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    3 +
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    2 +
 drivers/net/wireless/ath/ath9k/hw.c                |   54 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   16 +-
 drivers/net/wireless/ath/ath9k/main.c              |   11 -
 drivers/net/wireless/atmel.c                       |    3 +-
 drivers/net/wireless/atmel_pci.c                   |   13 +-
 drivers/net/wireless/b43/xmit.c                    |    3 +-
 drivers/net/wireless/b43legacy/main.c              |    2 +
 drivers/net/wireless/b43legacy/xmit.c              |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    1 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    1 +
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |    4 -
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  127 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    6 -
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    8 -
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |   36 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |    3 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   41 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   40 +-
 drivers/net/wireless/hostap/hostap_main.c          |    3 +-
 drivers/net/wireless/hostap/hostap_pci.c           |   16 +-
 drivers/net/wireless/hostap/hostap_plx.c           |   16 +-
 drivers/net/wireless/ipw2x00/ipw.h                 |   23 +
 drivers/net/wireless/ipw2x00/ipw2100.c             |    7 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    7 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   29 +-
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |  117 +--
 drivers/net/wireless/iwlwifi/iwl-2000.c            |  120 +--
 drivers/net/wireless/iwlwifi/iwl-5000.c            |  274 +---
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  229 +---
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   28 +-
 drivers/net/wireless/iwlwifi/iwl-agn-devices.c     |  756 +++++++++
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  100 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   68 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |  289 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |  339 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |  146 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  305 +++--
 drivers/net/wireless/iwlwifi/iwl-agn.h             |  183 ++-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |  227 +++
 drivers/net/wireless/iwlwifi/iwl-core.c            |  711 +--------
 drivers/net/wireless/iwlwifi/iwl-core.h            |   86 -
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    3 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  146 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   86 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   70 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  220 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   14 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   15 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |  125 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    7 +
 drivers/net/wireless/iwlwifi/iwl-pci.c             |    2 -
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |   20 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |    6 +
 drivers/net/wireless/iwlwifi/iwl-power.c           |   62 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |  227 +---
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |   44 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |   35 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |   83 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |  122 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   21 +-
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |   14 +-
 drivers/net/wireless/libertas/Makefile             |    1 +
 drivers/net/wireless/libertas/decl.h               |   11 +-
 drivers/net/wireless/libertas/dev.h                |   10 +
 drivers/net/wireless/libertas/firmware.c           |  222 +++
 drivers/net/wireless/libertas/if_cs.c              |   10 +-
 drivers/net/wireless/libertas/if_sdio.c            |  229 ++--
 drivers/net/wireless/libertas/if_spi.c             |   11 +-
 drivers/net/wireless/libertas/if_usb.c             |  265 +---
 drivers/net/wireless/libertas/main.c               |  117 +--
 drivers/net/wireless/mac80211_hwsim.c              |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c            |   31 +-
 drivers/net/wireless/mwifiex/cfp.c                 |   31 +
 drivers/net/wireless/mwifiex/debugfs.c             |    2 +-
 drivers/net/wireless/mwifiex/fw.h                  |    3 +-
 drivers/net/wireless/mwifiex/init.c                |    2 +
 drivers/net/wireless/mwifiex/ioctl.h               |    3 +-
 drivers/net/wireless/mwifiex/join.c                |   50 +-
 drivers/net/wireless/mwifiex/main.c                |  106 +-
 drivers/net/wireless/mwifiex/main.h                |   20 +-
 drivers/net/wireless/mwifiex/pcie.c                |    3 +
 drivers/net/wireless/mwifiex/scan.c                |   63 +-
 drivers/net/wireless/mwifiex/sdio.c                |    3 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   87 +-
 drivers/net/wireless/mwl8k.c                       |   13 +-
 drivers/net/wireless/orinoco/fw.c                  |    7 +-
 drivers/net/wireless/p54/p54pci.c                  |   13 +-
 drivers/net/wireless/prism54/oid_mgt.c             |    6 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   13 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   13 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   36 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |    1 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |   28 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    7 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   13 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    1 +
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   13 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |    1 +
 drivers/net/wireless/rtlwifi/pci.c                 |    2 +
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    3 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   19 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    1 +
 drivers/net/wireless/rtlwifi/rtl8192de/def.h       |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    4 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |   19 +-
 drivers/net/wireless/ti/Kconfig                    |   14 +
 drivers/net/wireless/ti/Makefile                   |    4 +
 drivers/net/wireless/{ =3D> ti}/wl1251/Kconfig       |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/Makefile      |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/acx.c         |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/acx.h         |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/boot.c        |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/boot.h        |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/cmd.c         |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/cmd.h         |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/debugfs.c     |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/debugfs.h     |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/event.c       |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/event.h       |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/init.c        |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/init.h        |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/io.c          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/io.h          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/main.c        |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/ps.c          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/ps.h          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/reg.h         |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/rx.c          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/rx.h          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/sdio.c        |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/spi.c         |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/spi.h         |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/tx.c          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/tx.h          |    0
 drivers/net/wireless/{ =3D> ti}/wl1251/wl1251.h      |    0
 .../net/wireless/{ =3D> ti}/wl1251/wl12xx_80211.h    |    0
 drivers/net/wireless/ti/wl12xx/Kconfig             |    8 +
 drivers/net/wireless/ti/wl12xx/Makefile            |    3 +
 drivers/net/wireless/ti/wl12xx/acx.c               |   53 +
 drivers/net/wireless/ti/wl12xx/acx.h               |   36 +
 drivers/net/wireless/ti/wl12xx/cmd.c               |  254 +++
 drivers/net/wireless/ti/wl12xx/cmd.h               |  112 ++
 drivers/net/wireless/ti/wl12xx/conf.h              |   50 +
 drivers/net/wireless/ti/wl12xx/main.c              | 1388 ++++++++++++++++
 drivers/net/wireless/{ =3D> ti}/wl12xx/reg.h         |  315 ++--
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |   31 +
 drivers/net/wireless/ti/wlcore/Kconfig             |   41 +
 drivers/net/wireless/ti/wlcore/Makefile            |   15 +
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/acx.c   |   42 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/acx.h   |   10 +-
 drivers/net/wireless/ti/wlcore/boot.c              |  443 +++++
 drivers/net/wireless/ti/wlcore/boot.h              |   54 +
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/cmd.c   |  285 +---
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/cmd.h   |   98 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/conf.h  |   85 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/debug.h |    1 +
 .../net/wireless/{wl12xx =3D> ti/wlcore}/debugfs.c   |    3 +-
 .../net/wireless/{wl12xx =3D> ti/wlcore}/debugfs.h   |    2 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/event.c |   31 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/event.h |    3 +-
 drivers/net/wireless/ti/wlcore/hw_ops.h            |  122 ++
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/ini.h   |    0
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/init.c  |   66 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/init.h  |    2 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/io.c    |  191 +--
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/io.h    |   88 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/main.c  |  821 ++--------
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/ps.c    |    8 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/ps.h    |    2 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/rx.c    |  130 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/rx.h    |   12 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/scan.c  |   30 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/scan.h  |    4 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/sdio.c  |    6 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/spi.c   |    4 +-
 .../net/wireless/{wl12xx =3D> ti/wlcore}/testmode.c  |    3 +-
 .../net/wireless/{wl12xx =3D> ti/wlcore}/testmode.h  |    0
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/tx.c    |  125 +-
 drivers/net/wireless/{wl12xx =3D> ti/wlcore}/tx.h    |    7 +-
 .../net/wireless/{wl12xx =3D> ti/wlcore}/wl12xx.h    |  271 +---
 .../wireless/{wl12xx =3D> ti/wlcore}/wl12xx_80211.h  |    0
 .../{wl12xx =3D> ti/wlcore}/wl12xx_platform_data.c   |    0
 drivers/net/wireless/ti/wlcore/wlcore.h            |  448 +++++
 drivers/net/wireless/wl12xx/Kconfig                |   48 -
 drivers/net/wireless/wl12xx/Makefile               |   15 -
 drivers/net/wireless/wl12xx/boot.c                 |  786 ---------
 drivers/net/wireless/wl12xx/boot.h                 |  120 --
 drivers/nfc/pn533.c                                |  228 ++-
 include/linux/ieee80211.h                          |    4 +-
 include/linux/nfc.h                                |    1 +
 include/net/cfg80211.h                             |    9 +-
 include/net/mac80211.h                             |    4 +
 include/net/nfc/hci.h                              |  198 +++
 include/net/nfc/nfc.h                              |   12 +-
 include/net/nfc/shdlc.h                            |  104 ++
 net/mac80211/cfg.c                                 |    4 +-
 net/mac80211/ieee80211_i.h                         |    6 +-
 net/mac80211/iface.c                               |    3 +-
 net/mac80211/mesh_hwmp.c                           |    5 +-
 net/mac80211/mesh_pathtbl.c                        |    2 +
 net/mac80211/mesh_sync.c                           |   32 +-
 net/mac80211/mlme.c                                |   35 +-
 net/mac80211/rc80211_minstrel.c                    |   13 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    5 +-
 net/mac80211/scan.c                                |   43 +-
 net/mac80211/status.c                              |    8 +-
 net/mac80211/tx.c                                  |    4 +-
 net/mac80211/util.c                                |   42 +-
 net/mac80211/work.c                                |   15 +-
 net/nfc/Kconfig                                    |    1 +
 net/nfc/Makefile                                   |    1 +
 net/nfc/core.c                                     |  140 ++-
 net/nfc/hci/Kconfig                                |   16 +
 net/nfc/hci/Makefile                               |    8 +
 net/nfc/hci/command.c                              |  354 ++++
 net/nfc/hci/core.c                                 |  830 ++++++++++
 net/nfc/hci/hci.h                                  |  139 ++
 net/nfc/hci/hcp.c                                  |  156 ++
 net/nfc/hci/shdlc.c                                |  945 +++++++++++
 net/nfc/llcp/commands.c                            |    8 +-
 net/nfc/llcp/llcp.c                                |   21 +-
 net/nfc/nci/core.c                                 |    2 +-
 net/nfc/nci/ntf.c                                  |   11 +-
 net/nfc/netlink.c                                  |   31 +
 net/nfc/nfc.h                                      |    1 +
 net/nfc/rawsock.c                                  |    6 +
 net/wireless/core.c                                |    4 -
 net/wireless/nl80211.c                             |   13 +
 net/wireless/scan.c                                |    2 +-
 net/wireless/util.c                                |   10 +-
 net/wireless/wext-compat.c                         |    3 +-
 290 files changed, 14493 insertions(+), 7242 deletions(-)
 create mode 100644 Documentation/nfc/nfc-hci.txt
 create mode 100644 drivers/net/wireless/ath/ath6kl/htc-ops.h
 rename drivers/net/wireless/ath/ath6kl/{htc.c =3D> htc_mbox.c} (96%)
 create mode 100644 drivers/net/wireless/ath/ath6kl/htc_pipe.c
 create mode 100644 drivers/net/wireless/ipw2x00/ipw.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-devices.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-config.h
 create mode 100644 drivers/net/wireless/libertas/firmware.c
 create mode 100644 drivers/net/wireless/ti/Kconfig
 create mode 100644 drivers/net/wireless/ti/Makefile
 rename drivers/net/wireless/{ =3D> ti}/wl1251/Kconfig (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/Makefile (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/acx.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/acx.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/boot.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/boot.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/cmd.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/cmd.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/debugfs.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/debugfs.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/event.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/event.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/init.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/init.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/io.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/io.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/main.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/ps.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/ps.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/reg.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/rx.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/rx.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/sdio.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/spi.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/spi.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/tx.c (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/tx.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/wl1251.h (100%)
 rename drivers/net/wireless/{ =3D> ti}/wl1251/wl12xx_80211.h (100%)
 create mode 100644 drivers/net/wireless/ti/wl12xx/Kconfig
 create mode 100644 drivers/net/wireless/ti/wl12xx/Makefile
 create mode 100644 drivers/net/wireless/ti/wl12xx/acx.c
 create mode 100644 drivers/net/wireless/ti/wl12xx/acx.h
 create mode 100644 drivers/net/wireless/ti/wl12xx/cmd.c
 create mode 100644 drivers/net/wireless/ti/wl12xx/cmd.h
 create mode 100644 drivers/net/wireless/ti/wl12xx/conf.h
 create mode 100644 drivers/net/wireless/ti/wl12xx/main.c
 rename drivers/net/wireless/{ =3D> ti}/wl12xx/reg.h (71%)
 create mode 100644 drivers/net/wireless/ti/wl12xx/wl12xx.h
 create mode 100644 drivers/net/wireless/ti/wlcore/Kconfig
 create mode 100644 drivers/net/wireless/ti/wlcore/Makefile
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/acx.c (97%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/acx.h (99%)
 create mode 100644 drivers/net/wireless/ti/wlcore/boot.c
 create mode 100644 drivers/net/wireless/ti/wlcore/boot.h
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/cmd.c (84%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/cmd.h (87%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/conf.h (94%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/debug.h (99%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/debugfs.c (99%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/debugfs.h (98%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/event.c (91%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/event.h (98%)
 create mode 100644 drivers/net/wireless/ti/wlcore/hw_ops.h
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/ini.h (100%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/init.c (93%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/init.h (98%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/io.c (55%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/io.h (71%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/main.c (85%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/ps.c (97%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/ps.h (98%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/rx.c (69%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/rx.h (92%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/scan.c (95%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/scan.h (98%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/sdio.c (98%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/spi.c (99%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/testmode.c (99%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/testmode.h (100%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/tx.c (90%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/tx.h (97%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/wl12xx.h (68%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/wl12xx_80211.h (100%)
 rename drivers/net/wireless/{wl12xx =3D> ti/wlcore}/wl12xx_platform_data.c=
 (100%)
 create mode 100644 drivers/net/wireless/ti/wlcore/wlcore.h
 delete mode 100644 drivers/net/wireless/wl12xx/Kconfig
 delete mode 100644 drivers/net/wireless/wl12xx/Makefile
 delete mode 100644 drivers/net/wireless/wl12xx/boot.c
 delete mode 100644 drivers/net/wireless/wl12xx/boot.h
 create mode 100644 include/net/nfc/hci.h
 create mode 100644 include/net/nfc/shdlc.h
 create mode 100644 net/nfc/hci/Kconfig
 create mode 100644 net/nfc/hci/Makefile
 create mode 100644 net/nfc/hci/command.c
 create mode 100644 net/nfc/hci/core.c
 create mode 100644 net/nfc/hci/hci.h
 create mode 100644 net/nfc/hci/hcp.c
 create mode 100644 net/nfc/hci/shdlc.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--R3G7APHDIzY6R/pk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPjxBxAAoJEJctW/TcYTgG6h8P/1mQsIYlVCo/y0AKQ/vtTWDg
uXDDbL7Lw7q19kg8avHHTZchlTGoQVG2wza4XflrdqFHG7CpihALXe8rnx4h6PPW
c89bPYhbk2ItAODDOa+Sgi9blBqYUQDeJ/xGKyz1cJN3pjWF4irBUml6fsxezOhE
MJ5Ry5YzbaYD0bSekzTVCa0ETQLZgefbr2UX0G42GwjQMnop7HvmzYj7w/XLtOub
+A9wbgzjjFQLobztxRv3mC+EEWN5VGR/17+F4tWVxj8XlA4HNGwNNqMd4MOfrggf
AIRzR1se6NifRKciB/HkH5Sh1wsq0iA0QHMByYdSQriCB1sHhS73Cj/VCPwrn5NU
l+jCdlmtOAYMb020z088q5oWKoZOO9pJLvzEgZcg3Wo86L/l/3ugCL8cj0p91Gpd
W5I7O+Pwr1PnvtZ/0lXesv5Y7e5k0jO54ubWooMJ8SQnDdI0H75GjP5QPrgbsb+j
1Y/ZfrvI0xKYWtEnFaJo2BGyoyl18azyGQodUf0ZkjyB+sdZ51yofACUPCosUOnn
uakU1awYWQ0ist0+8Yzeez/aLML8LnXBqyXBh5se0JrlbEnnrk1VxB80Ywr7jX7L
X7ucx+ZPz1rEEmaI6e3HfQo5V3lJ2vDyKjlk20gXjdXol2+IFx+/Hp22guAoPi5P
ls5T3CwNL8V1xHPeRyb4
=8Yl4
-----END PGP SIGNATURE-----

--R3G7APHDIzY6R/pk--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
