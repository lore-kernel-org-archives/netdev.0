From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2013-08-12
Date: Mon, 12 Aug 2013 15:53:50 -0400
Message-ID: <20130812195347.GE27408@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is a batch of updates intended for 3.12.  It is mostly driver
stuff, although Johannes Berg and Simon Wunderlich make a good
showing with mac80211 bits (particularly some work on 5/10 MHz
channel support).

The usual suspects are mostly represented.  There are lots of updates
to iwlwifi, ath9k, ath10k, mwifiex, rt2x00, wil6210, as usual.
The bcma bus gets some love this time, as do cw1200, iwl4965, and a
few other bits here and there.  I don't think there is much unusual
here, FWIW.

Please let me know if there are problems!

John

---

The following changes since commit f3dfd20860db3d0c400dd83a378176a28d3662db:

  af_unix: fix bug on large send() (2013-08-11 22:02:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 89c2af3c14ddf8ae48637a7b454d66ac5e0ca728:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-08-12 14:45:06 -0400)

----------------------------------------------------------------

Alexander Bondar (3):
      iwlwifi: mvm: Upgrade to a new power management uAPSD API
      iwlwifi: mvm: Change AM->PSM timeout for EAPOL frames
      iwlwifi: mvm: Change beacon abort escape time value

Alexey Khoroshilov (1):
      hostap: do not return positive number on failure path in prism2_open()

Amitkumar Karwar (18):
      cfg80211/nl80211: rename packet pattern related structures and enums
      cfg80211/nl80211: Add packet coalesce support
      mwifiex: add PCIe shutdown handler to avoid system hang on reboot
      mwifiex: move del_timer_sync(scan_delay_timer) call to fix memleak
      mwifiex: remove unnecessary del_timer(cmd_timer)
      mwifiex: move if_ops.cleanup_if() call
      mwifiex: add unregister_dev handler for usb interface
      mwifiex: reduce firmware poll retries
      mwifiex: replace mdelay with msleep
      mwifiex: correction in mwifiex_check_fw_status() return status
      mwifiex: remove duplicate structure host_cmd_tlv
      mwifiex: handle driver initialization error paths
      mwifiex: code rearrangement in sdio.c
      mwifiex: fix adapter pointer dereference issue
      mwifiex: rename mef macros
      mwifiex: modify mwifiex_is_pattern_supported() routine
      mwifiex: increase max supported pattern offset
      mwifiex: add packet coalesce support

Antonio Quartulli (1):
      mac80211: ibss - remove not authorized station earlier

Avinash Patil (7):
      mwifiex: rename pkt_count to ba_pkt_count in mwifiex_ra_list_tbl stru=
ct
      mwifiex: maintain outstanding packet count for RA list instead of pac=
ket size
      mwifiex: delete AP TX queues when bridged packets reach threshold
      mwifiex: correct max IE length check for WPS IE
      mwifiex: modify mwifiex_ap_sta_limits to advertise support for P2P
      ieee80211: add definition for interworking support
      mwifiex: populate rates in probe request using cfg80211_scan_request

Avri Altman (2):
      iwlwifi: mvm: new api to get signal strength
      iwlwifi: mvm: fix signal reporting for < 3 antennas

Bing Zhao (1):
      mwifiex: fix build error when CONFIG_PM is not set

Chris Wright (1):
      mac80211: fix infinite loop in ieee80211_determine_chantype

Chun-Yeow Yeoh (1):
      mac80211: set forwarding in mesh capability info

David Spinadel (1):
      iwlwifi: mvm: enable pre-scan passive to active

Eliad Peller (4):
      iwlwifi: fix some documentation typos
      iwlwifi: pcie: some little cleanups
      iwlwifi: mvm: add some missing cleanups in iwl_mvm_mac_add_interface
      iwlwifi: mvm: use designated initialization for some arrays

Emmanuel Grumbach (8):
      iwlwifi: pcie: don't disable L1 for newest NICs
      iwlwifi: mvm: better handle several several vifs in BT Coex
      iwlwifi: mvm: fix the ACK / CTS kill mask upon RSSI event
      iwlwifi: mvm: don't allocate BT_COEX cmd on stack
      iwlwifi: mvm: remove the default calibration values for 7000
      iwlwifi: mvm: register vif debugfs for AP mode too
      iwlwifi: mvm: remove obsolete flag in TX command API
      iwlwifi: mvm: advertise support for DYNAMIC / STATIC SMPS

Eran Harary (1):
      iwlwifi: mvm: fix debugfs restart if fw_restart is disabled

Eric Dumazet (1):
      iwl3945: better skb management in rx path

Eyal Shapira (2):
      iwlwifi: remove duplicate rate scale init code
      iwlwifi: mvm: remove traffic load monitoring in rs

Eytan Lifshitz (1):
      iwlwifi: mvm: add high temperature SKU thermal throttling parameters

Fabio Baltieri (1):
      mac80211: use oneshot blink API for LED triggers

Felix Fietkau (12):
      ath9k: add utility functions for accessing tid queues
      ath9k: split tid retry packets into a separate queue
      ath9k: add function for getting the tx tid for a packet
      ath9k: add CAB queue info to debugfs
      ath9k: simplify ath_tx_form_aggr
      ath9k: fix block ack window tracking check
      ath9k: prepare queueing code for handling unaggregated traffic
      ath9k: fix clearing expired A-MPDU subframes in tx completion
      ath9k: always clear ps filter bit on new assoc
      ath9k: use software queues for un-aggregated data packets
      ath9k: improve tx scheduling fairness
      ath9k: use software queueing for multicast traffic

Fred Zhou (1):
      ieee80211: add definition for 802.11ac information elements

Gabor Juhos (25):
      rt2x00: rt2800lib: introduce rt2800_eeprom_word enum
      rt2x00: rt2800lib: introduce local EEPROM access functions
      rt2x00: rt2800lib: introduce rt2800_eeprom_read_from_array helper
      rt2x00: rt2800lib: introduce rt2800_eeprom_word_index helper
      rt2x00: rt2800lib: add EEPROM map for the RT3593 chipset
      rt2x00: rt2800lib: add MAC register initialization for RT3593
      rt2x00: rt2800lib: add BBP register initialization for RT3593
      rt2x00: rt2800lib: add RFCSR register initialization for RT3593
      rt2x00: rt2800lib: add BBP post initialization for RT3593
      rt2x00: rt2800lib: add TX power configuration for RT3593
      rt2x00: rt2800lib: fix BBP1_TX_ANTENNA field configuration for 3T dev=
ices
      rt2x00: rt2800lib: fix antenna configuration for RT3593
      rt2x00: rt2800lib: add rt2800_txpower_to_dev helper
      rt2x00: rt2800lib: fix default TX power values for RT3593
      rt2x00: rt2800lib: introduce rt2800_get_txmixer_gain_{24,5}g helpers
      rt2x00: rt2800lib: hardcode TX mixer gain values for RT3593
      rt2x00: rt2800lib: fix LNA_A[12] gain values for RT3593
      rt2x00: rt2800lib: add default_power3 field for three-chain devices
      rt2x00: rt2800lib: add rf_vals for RF3053
      rt2x00: rt2800lib: add channel configuration for RF3053
      rt2x00: rt2800lib: enable VCO recalibration for RF3053
      rt2x00: rt2800lib: enable RF3053 support
      rt2x00: rt2800lib: enable RT3593 support
      rt2x00: rt2800usb: use correct [RT]XWI size for RT3593
      rt2x00: rt2800usb: add USB device ID for Linksys AE3000

Hauke Mehrtens (6):
      bcma: add some more core names
      bcma: make it possible to select SoC support without mips
      bcma: add constants for new ARM based SoCs
      bcma: return correct error code when bus scan failed
      bcma: fix handling of big addrl
      bgmac: make bgmac depend on bcm47xx

Hila Gonen (1):
      iwlwifi: mvm: Change beacon filtering command

Huawei Yang (2):
      mwifiex: remove stop_net_dev_queue operation in AP forwarding
      mwifiex: add tx info to skb when forming mgmt frame

Ilan Peer (1):
      iwlwifi: mvm: Return on inconsistency in add interface

Inbal Hacohen (1):
      iwlwifi: move dump_fh into common code

Jingoo Han (1):
      net: wireless: rt2x00: Staticize rt2x00queue_pause_queue_nocheck()

Johannes Berg (27):
      wireless: indent kernel-doc with tabs
      mac80211: add per-chain signal information to radiotap
      mac80211_hwsim: use ieee80211_free_txskb
      mac80211_hwsim: claim uAPSD support
      mac80211_hwsim: claim active monitor support
      mac80211: make active monitor injection work w/ HW queue
      iwlwifi: remove forward debugfs function declarations
      iwlwifi: mvm: remove unneeded argument from iwl_mvm_tx_protection()
      iwlwifi: pcie: make unused queue warning more readable
      ath9k: make rfkill configurable
      iwlwifi: dvm: remove P2P support
      nl80211: fix another nl80211_fam.attrbuf race
      iwlwifi: mvm: reprobe device on firmware error during restart
      iwlwifi: mvm: support six IPv6 addresses in D3
      iwlwifi: mvm: assign quota per virtual interface
      iwlwifi: mvm: split constants into separate file
      iwlwifi: mvm: report per-chain signal to mac80211
      iwlwifi: list Emmanuel in maintainers file
      mac80211: don't wait for TX status forever
      mac80211: ignore HT primary channel while connected
      cfg80211: fix P2P GO interface teardown
      mac80211: continue using disabled channels while connected
      mac80211: add debugfs for driver-buffered TID bitmap
      iwlwifi: pcie: fix resume when no opmode is present
      iwlwifi: mvm: small cleanups in quota management code
      iwlwifi: remove transport suspend/resume indirection
      brcmfmac: use CFG80211_TESTMODE_CMD

John Greene (1):
      brcmsmac: Further reduce log spam from tx phy messages

John W. Linville (9):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge tag 'for-linville-20130730' of git://github.com/kvalo/ath6kl
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kalle Valo (2):
      MAINTAINERS: add ath10k
      MAINTAINERS: update ath6kl git location

Karl Beldan (1):
      mac80211: report some VHT radiotap infos for tx status

Kirshenbaum Erez (1):
      wil6210: Enable TCP/UDP checksum HW offload

Mark Schulte (1):
      rtlwifi: rtl8192cu: fix function declaration header

Matti Gottlieb (3):
      iwlwifi: mvm: sram hex dump on NIC error
      iwlwifi: mvm: Enable user set TX power
      iwlwifi: mvm: Add RX statistics debugfs entry

Michal Kazior (34):
      ath10k: fix teardown ordering
      ath10k: fix possible deadlock
      ath10k: setup rts/frag thresholds upon vdev creation
      ath10k: do not setup rts/frag thresholds for suspended interfaces
      ath10k: remove ath10k_bus
      ath10k: fix typo in define name
      ath10k: silent warning in IBSS mode
      ath10k: lower print level for a message
      ath10k: provide errno if bmi read/write fails
      ath10k: change function to take struct ath10k as arg
      ath10k: rename hif callback
      ath10k: embed HTC struct inside ath10k
      ath10k: embed HTT struct inside ath10k
      ath10k: improve locking
      ath10k: abort scan properly if wmi_scan_stop fails
      ath10k: add missing debug prints
      ath10k: decouple pci start/stop logic
      ath10k: decouple core start/stop logic
      ath10k: allow deferred regd update
      ath10k: reset BMI state upon init
      ath10k: decouple suspend code
      ath10k: move free_vdev_map initialization
      ath10k: make sure all resources are freed upon ath10k_stop()
      ath10k: defer hw setup to start/stop mac80211 hooks
      ath10k: store firmware files in memory
      ath10k: skip fw stats debugfs interface if device is down
      ath10k: implement device recovery
      ath10k: implement fw crash simulation command
      ath10k: fix NULL dereference for injected packets
      ath10k: create debugfs interface to trigger fw crash
      ath10k: prevent HTC from being used after stopping
      ath10k: don't reset HTC endpoints unnecessarily
      ath10k: fix memleak in mac setup
      ath10k: fix rts/fragmentation threshold setup

Rafa=C5=82 Mi=C5=82ecki (1):
      ssb: drop BROKEN from SSB_SFLASH

Shuah Khan (1):
      wireless: Convert mwifiex/pcie to dev_pm_ops from legacy pm_ops

Simon Wunderlich (16):
      nl80211: enable HT overrides for ibss
      mac80211: enable HT overrides for ibss
      nl80211: add scan width to bss and scan request structs
      mac80211/rc80211: add chandef to rate initialization
      mac80211: fix timing for 5 MHz and 10 MHz channels
      mac80211: add radiotap flag and handling for 5/10 MHz
      mac80211: select and adjust bitrates according to channel mode
      cfg80211/mac80211: get mandatory rates based on scan width
      cfg80211/mac80211: use reduced txpower for 5 and 10 MHz
      mac80211: allow scanning for 5/10 MHz channels in IBSS
      mac80211: return if IBSS chandef can not be used
      nl80211: allow 5 and 10 MHz channels for IBSS
      mac80211: fix regression when initializing ibss wmm params
      mac80211: fix off-by-one regression in ibss beacon generation
      nl80211/cfg80211: add channel switch command
      mac80211: add channel switch command and beacon callbacks

Solomon Peachy (2):
      cw1200: Fix incorrect endianness annotation in a header field
      cw1200: Fix spurious BUG_ON() trigger when starting AP mode.

Stanislaw Gruszka (3):
      iwl4965: better skb management in rx path
      iwl4965: set power mode early
      iwl4965: reset firmware after rfkill off

Stone Piao (3):
      mwifiex: discard deauth and disassoc event during WPS session
      mwifiex: skip registering mgmt frame that has already registered
      mwifiex: support to send deauth for P2P client

Sujith Manoharan (34):
      ath9k: Fix RTS threshold
      ath9k: Move INI overrides to ar9003_hw_override_ini
      ath9k: Add a HW flag for FCC
      ath9k: Fix FastChannelChange for AR9462/AR9565
      ath9k: Use correct channel when switching bands
      ath9k: Program correct initvals for FCC
      ath9k: Release the RF bus after setting board values
      ath9k: Fix diversity combining for AR9285
      ath9k: Add a debugfs file for antenna diversity
      ath9k: Do a quick scan only when scan_not_start is true
      ath9k: Use a subroutine to check for short scan
      ath9k: Add ALT check for cards with GROUP-3 config
      ath9k: Use a subroutine to try LNA switch
      ath9k: Use a helper function for checking LNA options
      ath9k: Simplify checks in quick_scan
      ath9k: Use a subroutine to calculate ALT ratio
      ath9k: Add statistics for antenna diversity
      ath9k: Add information about antenna diversity
      ath9k: Print LNA combining mode during init
      ath9k: Fix antenna diversity for CUS198
      ath9k: Cleanup WLAN/BT RX diversity
      ath9k: Add a HW capability for WLAN/BT RX diversity
      ath9k: Rename ath9k_hw_antctrl_shared_chain_lnadiv
      ath9k: Enable WLAN/BT Ant Diversity for WB225/WB195
      ath9k: Program HW for WB195 diversity
      ath9k: Remove "shared_chain_lnadiv"
      ath9k: Set SWCOM value for CUS198
      ath9k: Support ANT diversity for WB225
      ath9k: Remove ath_ant_comb_update()
      ath9k: Fix antenna control init for AR9485
      ath9k: Add more PCI IDs for WB225 cards
      ath9k: Fix build failure
      ath9k: Fix BTCOEX usage for RX diversity
      ath9k: Run the LNA combining algorithm properly

Vladimir Kondratiev (7):
      wil6210: Align WMI header with latest FW
      wil6210: fix wrong index in wil_vring_free
      wil6210: Optimize Tx completion
      wil6210: Introduce struct for sw context
      wil6210: fix subtle race in wil_tx_vring
      wil6210: fix error path in wil_tx_vring
      wil6210: drop -Werror compiler flag

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800usb: add RT3573 devices

 MAINTAINERS                                        |    2 +-
 drivers/bcma/Kconfig                               |   10 +-
 drivers/bcma/main.c                                |    2 +-
 drivers/bcma/scan.c                                |   28 +-
 drivers/net/ethernet/broadcom/Kconfig              |    2 +-
 drivers/net/wireless/ath/ath.h                     |    2 +-
 drivers/net/wireless/ath/ath10k/bmi.c              |   12 +-
 drivers/net/wireless/ath/ath10k/bmi.h              |    1 +
 drivers/net/wireless/ath/ath10k/ce.c               |    2 +-
 drivers/net/wireless/ath/ath10k/core.c             |  321 +++--
 drivers/net/wireless/ath/ath10k/core.h             |   50 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   87 +-
 drivers/net/wireless/ath/ath10k/hif.h              |   49 +-
 drivers/net/wireless/ath/ath10k/htc.c              |   61 +-
 drivers/net/wireless/ath/ath10k/htc.h              |    8 +-
 drivers/net/wireless/ath/ath10k/htt.c              |   27 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    3 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    3 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   12 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  409 +++++-
 drivers/net/wireless/ath/ath10k/mac.h              |    1 +
 drivers/net/wireless/ath/ath10k/pci.c              |  304 ++--
 drivers/net/wireless/ath/ath10k/pci.h              |    4 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   40 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   19 +
 drivers/net/wireless/ath/ath9k/Kconfig             |   10 +
 drivers/net/wireless/ath/ath9k/antenna.c           |  672 +++++----
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   67 +
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   26 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    2 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  184 ++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    5 -
 drivers/net/wireless/ath/ath9k/ath9k.h             |   44 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  206 ++-
 drivers/net/wireless/ath/ath9k/debug.h             |   29 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   19 +
 drivers/net/wireless/ath/ath9k/hw-ops.h            |   11 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   96 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    9 +-
 drivers/net/wireless/ath/ath9k/init.c              |   32 +-
 drivers/net/wireless/ath/ath9k/main.c              |   19 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   90 +-
 drivers/net/wireless/ath/ath9k/phy.h               |    7 +
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +
 drivers/net/wireless/ath/ath9k/recv.c              |   44 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  501 ++++---
 drivers/net/wireless/ath/wil6210/Makefile          |    3 -
 drivers/net/wireless/ath/wil6210/debugfs.c         |    4 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    2 +
 drivers/net/wireless/ath/wil6210/trace.h           |   22 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  160 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |   20 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   27 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   20 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    6 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    4 +-
 drivers/net/wireless/cw1200/sta.c                  |    7 +-
 drivers/net/wireless/cw1200/wsm.h                  |    2 +-
 drivers/net/wireless/hostap/hostap_main.c          |    4 +-
 drivers/net/wireless/iwlegacy/3945-rs.c            |    1 +
 drivers/net/wireless/iwlegacy/3945.c               |   31 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   34 +-
 drivers/net/wireless/iwlegacy/4965-rs.c            |    1 +
 drivers/net/wireless/iwlegacy/common.c             |    1 +
 drivers/net/wireless/iwlwifi/Kconfig               |   17 -
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    6 -
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |   15 -
 drivers/net/wireless/iwlwifi/dvm/dev.h             |    7 -
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  172 +--
 drivers/net/wireless/iwlwifi/dvm/main.c            |   62 -
 drivers/net/wireless/iwlwifi/dvm/rs.c              |    6 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |    6 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |  105 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   19 -
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   11 +
 drivers/net/wireless/iwlwifi/iwl-config.h          |    4 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   19 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   67 +
 drivers/net/wireless/iwlwifi/iwl-io.h              |    3 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    8 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   25 +-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    2 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |  162 ++-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |   71 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   66 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  254 +++-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |   49 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |  143 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |    5 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |    2 -
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   27 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   55 -
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |    3 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   57 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   85 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   58 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |  198 ++-
 drivers/net/wireless/iwlwifi/mvm/power_legacy.c    |  319 ++++
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   27 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  179 +--
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   16 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   97 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    2 +
 drivers/net/wireless/iwlwifi/mvm/sta.c             |    3 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   32 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    4 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   23 +
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   24 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    1 -
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  118 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   22 +-
 drivers/net/wireless/mac80211_hwsim.c              |   10 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    4 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  176 ++-
 drivers/net/wireless/mwifiex/cfp.c                 |   42 +-
 drivers/net/wireless/mwifiex/decl.h                |    3 +-
 drivers/net/wireless/mwifiex/fw.h                  |   70 +-
 drivers/net/wireless/mwifiex/ie.c                  |    2 +-
 drivers/net/wireless/mwifiex/init.c                |   14 +-
 drivers/net/wireless/mwifiex/ioctl.h               |   43 +-
 drivers/net/wireless/mwifiex/join.c                |    1 +
 drivers/net/wireless/mwifiex/main.c                |   96 +-
 drivers/net/wireless/mwifiex/main.h                |    8 +-
 drivers/net/wireless/mwifiex/pcie.c                |   39 +-
 drivers/net/wireless/mwifiex/scan.c                |   63 +-
 drivers/net/wireless/mwifiex/sdio.c                |  213 ++-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   77 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +
 drivers/net/wireless/mwifiex/sta_event.c           |   10 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   11 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |  130 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |   70 +-
 drivers/net/wireless/mwifiex/usb.c                 |    8 +
 drivers/net/wireless/mwifiex/wmm.c                 |   16 +-
 drivers/net/wireless/rt2x00/Kconfig                |    6 +
 drivers/net/wireless/rt2x00/rt2800.h               |  274 +++-
 drivers/net/wireless/rt2x00/rt2800lib.c            | 1524 ++++++++++++++++=
++--
 drivers/net/wireless/rt2x00/rt2800usb.c            |   39 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    1 +
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    2 +-
 drivers/net/wireless/rtlwifi/rc.c                  |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |    3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h        |    3 -
 drivers/net/wireless/ti/wlcore/main.c              |   10 +-
 drivers/ssb/Kconfig                                |    2 +-
 drivers/ssb/driver_chipcommon_sflash.c             |    8 +-
 include/linux/bcma/bcma.h                          |   17 +
 include/linux/ieee80211.h                          |    9 +
 include/net/cfg80211.h                             |  197 ++-
 include/net/ieee80211_radiotap.h                   |    4 +
 include/net/mac80211.h                             |   67 +-
 include/uapi/linux/nl80211.h                       |  183 ++-
 net/mac80211/cfg.c                                 |  232 ++-
 net/mac80211/chan.c                                |   58 +
 net/mac80211/debugfs_sta.c                         |    9 +
 net/mac80211/driver-ops.h                          |   13 +
 net/mac80211/ht.c                                  |   53 +-
 net/mac80211/ibss.c                                |  184 ++-
 net/mac80211/ieee80211_i.h                         |   67 +-
 net/mac80211/iface.c                               |   11 +-
 net/mac80211/led.c                                 |   19 +-
 net/mac80211/led.h                                 |    4 +-
 net/mac80211/main.c                                |   15 +-
 net/mac80211/mesh.c                                |    7 +-
 net/mac80211/mesh_plink.c                          |    2 +-
 net/mac80211/mlme.c                                |  152 +-
 net/mac80211/rate.c                                |   46 +-
 net/mac80211/rate.h                                |   22 +-
 net/mac80211/rc80211_minstrel.c                    |   33 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   15 +-
 net/mac80211/rc80211_pid_algo.c                    |    1 +
 net/mac80211/rx.c                                  |   97 +-
 net/mac80211/scan.c                                |   72 +-
 net/mac80211/status.c                              |   90 +-
 net/mac80211/trace.h                               |   26 +
 net/mac80211/tx.c                                  |  108 +-
 net/mac80211/util.c                                |  216 ++-
 net/wireless/core.c                                |   10 +
 net/wireless/core.h                                |    2 +
 net/wireless/mesh.c                                |    5 +-
 net/wireless/nl80211.c                             |  486 ++++++-
 net/wireless/nl80211.h                             |    2 +
 net/wireless/rdev-ops.h                            |   12 +
 net/wireless/scan.c                                |   31 +-
 net/wireless/trace.h                               |   45 +-
 net/wireless/util.c                                |   14 +-
 190 files changed, 8855 insertions(+), 3321 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/constants.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/power_legacy.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJSCT1LAAoJEJctW/TcYTgGZ7AP/1El2Raqa7X0QHuGLhfATpyi
HK7qtypEuRlDXmy8q5O5zTz+v4BREzZWM81r6cz2QmHIOgrfqXd4tBYWuUGy0F9l
NYH7TQb0VJagSRUOTPRv8gQkp41hu9uu0qNbqNzDwoGv7VSXLRSPPud7ay8zyeG5
RW4HQtRM3xWMPOf0U1Z+ZxxlttEBZnfVngpg4gIfqDKkHa9T6jfd3tJGU2jkHFE4
QQy0X/wXj+4J5thpFMVXbsWfDqzDUwLpi9Tb2LDfa9fS60sQTH4F/zNJCc7DuwdG
Ode8MXzHyuVUOoHe+XBY/t4fpMkFk/GEQE1isSfjkO+JB+zHLJyh+xFPk9XWVAxY
kRbyA09Km0Lwg5d7D1+ondGolYTFiZjZ+yo0FXACb3sCwA+RjnVNotTUEQ/wjxNy
AMbLXkIPl+wo1VMg8O86TZ0SKg5EHglcDh8xWddHgKI1jAYY7ERvlDrvHC+lb6ev
xk4qdh7FdP9EeNdHyL1wL6fmCk0NIOpMPjnf5L3iBSE3e1wkrpJBFjy1ACfPywWK
AjDiVhoyhdvc8dT0hicFpdlL+jKU+o0oPpD5XsHNKTGQGmOyp8xMLkoVY9dApF0W
Po6nQPr7UqCWDMQJ9XlxYCPdl3oC00KyEjhckzgteXhMff2sIHnuZ2AzVaJPcEnT
MhUuqR18pfeGV46GQ3PW
=whnv
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
