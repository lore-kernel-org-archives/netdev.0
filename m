From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-06-12
Date: Tue, 12 Jun 2012 16:05:01 -0400
Message-ID: <20120612200500.GC1932@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

commit 0440507bbc44149e63bbfb9df730ba3820371904

Dave,

This is the first big wireless pull request intended for 3.6.
This includes big updates for the ti bits (expecially regarding
wl18xx support), a large batch of NFC changes (particularly for
pn533 hardware support), and the usual large amount of updates for
ath9k and iwlwifi, as well as a variety of other bits here and there.
In order to fix/avoid some merge problems, this also includes a pull
of some wireless fixes that have already been sent for 3.5.

Please let me know if there are problems!

John

---

The following changes since commit 8d242488ce4627dd7e6333caab56df11ea25e239:

  phy: Use pr_<level> (2012-06-11 16:58:24 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git for-davem

Albert Pool (1):
      rt2800usb: 2001:3c17 is an RT3370 device

Alex Hung (1):
      rfkill: Add the capability to switch all devices of all type in __rfkill_switch_all().

Amitkumar Karwar (2):
      mwifiex: fix simultaneous scan and Tx traffic problem
      mwifiex: scan less channels per scan command to improve Tx traffic

Arik Nemtsov (44):
      wl18xx: create per-chip-family private storage
      wl18xx: set the number of Tx descriptors
      wl18xx: set normal/GEM Tx spare block counts
      wl18xx: implement hw op for calculating hw block count per packet
      wl18xx: implement hw op for setting blocks in hw_tx_desc
      wl18xx: implement hw op for setting frame length in tx_hw_desc
      wl18xx: define HW-rate translation elements/tables
      wl18xx: add fw_status private data
      wl18xx: set Rx block-size alignment quirk
      wl18xx: implement hw op for getting rx buffer data alignment
      wl18xx: implement hw op for getting rx packet data length
      wl18xx: implement immediate Tx completion
      wlcore/wl18xx: add hw op for setting Tx HW checksum
      wlcore/wl18xx: add hw op for Rx HW checksum
      wlcore: track current channel type per vif
      wl18xx: send channel type to FW on role start
      wl18xx: ipmlement ap_rate_mask hw op
      wlcore: support peer MIMO rates
      wlcore/wl18xx: enable MIMO/wide-chan rates in AP-mode rate config
      wl18xx: set HT capabilities
      wl18xx: add module param for overriding HT caps
      wl18xx: read FW pc on recovery
      wl18xx: disable FW log functionality
      wl18xx: implement hw op to read PG version
      wl18xx: init Tx-released index to 0 on HW init
      wl18xx: don't upload NVS to FW
      wl18xx: change board type enum according to new FW
      wlcore/wl12xx/18xx: split fw_status struct into two
      wlcore: fix sparse warnings related to static functions
      wlcore: fix dynamic_ps_timeout time regression
      wlcore: fixes for connection_loss_work
      wl18xx: add dependency on mac80211
      wlcore: remove duplicate BUG_ON during recovery
      mac80211: allow low-level drivers to set netdev feature bits
      wlcore/wl12xx/wl18xx: introduce quirk to remove TKIP header space
      wlcore/wl12xx/wl18xx: handle spare blocks spacial cases per arch
      wlcore: add stop reason bitmap for waking/starting queues
      wlcore: stop queues on Tx flush
      wlcore/wl12xx/wl18xx: implement op_set_key per HW arch
      mac80211: add stations after AP start on reconfig
      wl18xx: allow FW-log by default for PG2.0
      wl18xx: align wl18xx_conf_phy with FW variant and remove it
      wl18xx: clean up phy module parameters
      wlcore/wl12xx/wl18xx: make NVS file optional for wl18xx

Assaf Azulay (2):
      wl18xx: change default tcp_checksum to false
      wlcore: increase number of BA sessions to 3

Avinash Patil (2):
      mwifiex: invalidate bss config before setting channel for uAP
      mwifiex: support NL80211_HIDDEN_SSID_ZERO_LEN for uAP

Ben Greear (1):
      ath9k: Support ethtool getstats api.

Bing Zhao (1):
      mwifiex: shorten per channel scan time

Chris Yungmann (1):
      brcm80211: brcmsmac: fixed checkpatch and sparse warnings

Chun-Yeow Yeoh (1):
      mac80211: Add missing mesh parameter dot11MeshForwarding for debugfs

Dan Carpenter (2):
      brcm80211: remove an unneeded NULL check
      brcm80211: brcmu_pkt_buf_free_skb() should handle NULL

Don Fry (1):
      iwlwifi: implement dynamic opmode loading

Eliad Peller (13):
      wlcore: use the original elp time in forced_ps mode
      wlcore: use correct link for bcast/multicast frames
      wlcore: flush before stopping AP
      wlcore: set wl->ht_cap per-band
      wlcore: flush tx on CHANGE_CHANNEL
      wlcore: increase WL1271_EVENT_TIMEOUT
      mac80211: use offchannel queue only when supported
      mac80211: fail authentication when AP denied authentication
      nl80211: add new rssi event to indicate beacon loss
      mac80211: remove ieee80211_get_operstate()
      wl12xx: send beacon loss events to userspace
      wl12xx/wl18xx: add erp protection IE to the beacon filter
      wlcore: compare ssid_len before comparing ssids

Emmanuel Grumbach (12):
      iwlwifi: fix prints in iwl_rx_handle
      iwlwifi: s/iwlagn_txq_free_tfd/iwl_txq_free_tfd
      iwlwifi: s/iwlagn_unmap_tfd/iwl_unmap_tfd
      iwlwifi: SCD_INT_MSK is obsolete - don't update it
      iwlwifi: first config the SCD queues, then activate them
      iwlwifi: use iwl_trans_set_wr_ptrs to init the queues
      iwlwifi: s/txq_agg_disable/txq_disable
      iwlwifi: s/txq_setup/txq_enable
      iwlwifi: update mask value for SCD queue config
      iwlwifi: allocate Tx cmd pool per device
      iwlwifi: fix rf configuration
      iwlwifi: configure the SKU in the HW

Eyal Shapira (2):
      wlcore: add support macros to easily add conf debugfs entries
      wlcore: add debugfs control over rx interrupt pacing

Grant Erickson (1):
      wl12xx: Add support for an external 26 MHz crystal source

Gregory Greenman (1):
      iwlwifi: Move IWL_MASK macro to transport.

Hauke Mehrtens (1):
      ssb: recognize ARM Cortex M3

Holger Schurig (1):
      mac80211: send beacon loss events to userspace

Ido Reis (6):
      wl18xx: fix PHY_INIT addresses mem size
      wl18xx: support PG2 version of the chip
      wl18xx: FW/PHY arguments added for PG2
      wl18xx: PG2.0 HW Watch dog interrupt support
      wl18xx: pad only last frame in aggregration buffer for PG2
      wl18xx: update fw statistics

Igal Chernobelsky (1):
      wlcore: modify bss loss parameters

Ilan Peer (3):
      iwlwifi: Check BSS ctx active before call mac80211
      iwlwifi: handle race condition in ROC flow
      iwlwifi: clear STATUS_SCAN_HW when PAN_PARAMS fails

Joe Perches (3):
      net: mac80211: Convert printk(KERN_DEBUG to pr_debug
      net: mac80211: Add and use ht_vdbg debugging macro
      net: mac80211: Add and use ibss_vdbg debugging macro

Johannes Berg (36):
      iwlwifi: add __printf argument checking
      iwlwifi: properly handle device_set_wakeup_enable
      iwlwifi: move IWL_CMD_FAILED_MSK
      iwlwifi: move notification wait into core
      iwlwifi: clean up coding style in PCIe transport
      wireless: remove wext sysfs
      cfg80211: deprecate CFG80211_WEXT
      mac80211: simplify association HT parameters
      mac80211: clean up ieee80211_set_channel
      mac80211: move ieee80211_set_channel function
      cfg80211: simplify cfg80211_can_beacon_sec_chan API
      cfg80211: provide channel to start_ap function
      cfg80211: disallow setting channel on WDS interfaces
      cfg80211: provide channel to join_mesh function
      iwlwifi: make a lot of functions static
      iwlwifi: use mac80211 channel in connection init
      iwlwifi: trust mac80211 channel setting
      iwlwifi: use mac80211 channels for reset scan
      iwlwifi: use mac80211 channel for radar check
      iwlwifi: give HT format to mac80211/radiotap
      iwlwifi: move PCIe into subdirectory
      iwlwifi: trust mac80211 HT40 setting
      iwlwifi: move DVM code into subdirectory
      iwlwifi: unify tx_chains_num setting
      iwlwifi: move ht40 bitmap into config
      iwlwifi: add iwl_set_bits_mask
      iwlwifi: refactor EEPROM reading/parsing
      iwlwifi: configure PHY version for 1000 series
      iwlwifi: move RF config into NIC config
      iwlwifi: remove extern opmode ops declarations
      cfg80211: clarify set_channel APIs
      mac80211: print info when disabling HT
      cfg80211: validate remain-on-channel time better
      wireless: update wireless URLs
      mac80211: do remain-on-channel while idle
      mac80211: unify SW/offload remain-on-channel

John W. Linville (5):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      wl18xx: avoid some -Wformat warnings
      Merge tag 'nfc-next-3.6-1' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next into for-davem

Jonas Gorski (1):
      ssb: add missing PCI ID for b/g/n single band BCM4322

Luciano Coelho (58):
      wl18xx: add new module
      wlcore_sdio/wl18xx: use SDIO revision number to identify wl18xx chips
      wl18xx: add empty operations struct
      wl18xx: add partition table
      wl18xx: add register table
      wl18xx: add identify chip operation
      wl18xx: add some boot operations and hw-specific configurations
      wl18xx: add trigger command and ack event operations
      wl18xx: add hw_init operation
      wl18xx: add runtime configuration parameters
      wl18xx: add board type module argument
      wl18xx: translate and write the board type to SCR_PAD2
      wl18xx: read clock frequency and do top init accordingly
      wlcore: rename wl12xx.h to wlcore_i.h
      wlcore/wl12xx: move ref_clock and tcxo_clock elements to wl12xx
      wlcore/wl12xx: move rx_mem_pool_addr element to wl12xx
      wlcore/wl12xx: add plt_init op and move the code to wl12xx
      wl18xx: add plt_init operation
      wl18xx: change the low_band_component_type for HDK boards
      wl18xx: add number of antennas and dc2dc type as module params
      wl18xx: add module parameter to disable TCP checksum
      wl18xx: derive the MAC address from the BD_ADDR in fuse ROM
      wl18xx: add a module parameter to control 11a support
      wlcore: add module parameter to dump SDIO reads and writes
      wl18xx: copy the default configuration before checking the board_type
      wl18xx: changed default board_type to HDK
      wlcore: add space for private area when allocating fw_status
      wl18xx: change low_band_component_type value for COM8
      wlcore: reorder identify_chip and get_hw_info
      wl18xx: disable MCS_13 for wl18xx PG 1.0
      wlcore: update beacon and probe_resp templates when rates change
      wlcore: use all AP basic rates as default
      wlcore: abstract debugfs fw_stats to be handled by the lower drivers
      wlcore: add debugfs macro to help print fw statistics arrays
      wl12xx: implement fw status debugfs entries
      wl18xx: implement fw status debugfs entries
      wlcore: create private static_data area and add operation to parse it
      wl18xx: print the PHY firmware version from the private static data
      wlcore: print the interrupt status when recovery is triggered
      wl18xx: don't use MIMO when ht_mode is set to wide
      wlcore: use proper values for supported local rates
      wl18xx: add module parameter to force SISO 20MHz
      wl18xx: add power limit reference value to mac_and_phy settings
      wl18xx: export low/high band component values as module params
      wl18xx: export pwr_limit_reference_11_abg value as a module parameter
      wlcore/wl12xx/wl18xx: move lower driver debugfs to a subdir
      wlcore: increase aggregation buffer size by one page
      wl18xx: increase tx_ba_win_size to 64
      wl18xx: use new fw stats structures
      wlcore/wl12xx/wl18xx: don't use TX align quirk for wl127x
      wl18xx: add support to clear FW statistics
      wlcore: export raw binary with the FW statistics in debugfs
      wlcore/wl18xx/wl12xx: use u8 instead of bool for host_fast_wakeup_support
      wlcore: use u8 instead of enum for bcn_filt_mode
      wlcore/wl18xx: the conf structs must be packed so they can be exported
      wlcore/wl18xx: export conf struct in a debugfs file
      wl18xx: read configuration structure from a binary file
      Merge branch 'wl12xx-next' into for-linville

Meenakshi Venkataraman (2):
      iwlwifi: fix debug print in iwl_sta_calc_ht_flags
      iwlwifi: add debugging to shadow registers and fix typo

Mohammed Shafi Shajakhan (1):
      ath9k: Fix modal EEPROM dump

Paul Bolle (1):
      iwlwifi: fix typo 'IWL_WATCHHDOG_DISABLED'

Pontus Fuchs (1):
      mac80211: Clear wowlan flag when drv_suspend returns failure

Rajkumar Manoharan (10):
      ath9k_hw: update ar9462 initval table to fix rx
      ath9k: cleanup MCI indentation
      ath9k_hw: fix IQ calibration chain index
      ath9k_hw: program BT to control SPDT
      ath9k_hw: configure ar9462 switching regulator
      ath9k_hw: fix BT RF performance
      ath9k: BT coex performance tuning for AR9462
      ath: do not update cycle counters with sleep mode
      ath9k_hw: fix power state for MCI
      ath9k: improve BT FTP/PAN performance

Samuel Ortiz (29):
      NFC: Take a reference on the LLCP local pointer when creating a socket
      NFC: Socket linked list
      NFC: Move LLCP receiver window value to socket structure
      NFC: Move LLCP MIU extension value to socket structure
      NFC: LLCP's MIUX is 10 bytes long, not 7
      NFC: Export LLCP general bytes getter
      NFC: Add target mode protocols to the polling loop startup routine
      NFC: Implement pn533 target mode polling loop
      NFC: Add target mode activation netlink event
      NFC: Set the NFC device RF mode appropriately
      NFC: Introduce target mode tx ops
      NFC: Introduce target mode rx data callback
      NFC: Implement the pn533 target mode data fetching routine
      NFC: Implement the pn533 target mode Tx op
      NFC: Don't hold a NULL connecting LLCP socket lock
      NFC: Call the DEP link down ops even when in target mode
      NFC: Reset poll mod list when stopping pn533 poll
      NFC: Unregister device if pn533 initial configuration fails
      NFC: Configure pn533 RF timings
      NFC: Add passive initiator data for pn533
      NFC: Add type A and type F parameters for pn533 target mode
      NFC: Implement pn533 polling loop
      NFC: Requeue lost LLCP frames
      NFC: Send a receiver ready frame only to reply to an I frame
      NFC: Switch to Initiator mode when getting NFC_ATTR_PROTOCOLS
      NFC: Destroy LLCP timout workqueue when releasing the link
      NFC: Set the proper baud rate when trying to activate pn533 targets
      NFC: Convert pn533 from semaphore to mutex
      NFC: Monitor pn533 target mode

Stanislav Yakovlev (1):
      net/wireless: ipw2200: introduce ipw_read_eeprom function

Stanislaw Gruszka (3):
      rt2x00: claim RSN IBSS support
      iwl4965: claim RSN IBSS support
      mac80211: configure 11b/g channel access rules for legacy APs

Sujith Manoharan (18):
      ath9k: Prune ath9k_init_device
      ath9k: Handle ASPM properly
      ath9k: Setup MCI interrupts properly
      ath9k_hw: Fix AR_RTC_KEEP_AWAKE usage
      ath9k_hw: Fix MCI usage
      ath9k_hw: Cleanup power mode API
      ath9k: Add MCI interrupt to debugfs statistics
      ath9k_hw: Fix variable usage
      ath9k: Remove SC_OP_OFFCHANNEL
      ath9k: Use separate operational flags for BTCOEX
      ath9k: Group link monitoring logic
      ath9k: Fix work handling
      ath9k: Move LNA code to antenna.c
      ath9k: Use atomic operations
      ath9k: Handle fatal interrupts properly
      ath9k: Fix powersave locking
      ath9k: Resync beacons properly
      ath9k_hw: Initvals update for AR9462

Thomas Pedersen (1):
      mac80211: allow channel change while mesh is down

Victor Goldenshtein (5):
      wl12xx: fix fm_coex parameters configuration
      wl18xx: fix fm_coex parameters configuration
      wlcore: don't enable BET for high basic rates
      wlcore: wait for roc complete only for the first roc command
      wlcore: set channels 12-14 as pactive for sched scan

Vivek Natarajan (1):
      ath9k: Ensure a fair beacon distribution in IBSS mode

Yoni Divinsky (5):
      wlcore: use psd_type indexing according to spec
      wl12xx: set the irq polarity before loading the fw
      wlcore: fix the CONF_TX_AC_ANY_TID to be 0xff
      wlcore: do not send stop fwlog cmd if fw is hanged
      wlcore: add role_id to all the sched_scan commands

Zefir Kurtisi (1):
      ath9k: fix/add bits for spectral scanning

Zero.Lin (1):
      rt2x00:Add RT5392 chipset support

villacis-5itmuRygkZmgSpxsJD1C4w@public.gmane.org (1):
      rt2x00: Add support for RT5360 based PCI devices.

 Documentation/feature-removal-schedule.txt         |   22 +-
 MAINTAINERS                                        |   18 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   36 +-
 drivers/net/wireless/ath/ath6kl/core.h             |    3 -
 drivers/net/wireless/ath/ath6kl/main.c             |    1 -
 drivers/net/wireless/ath/ath9k/Makefile            |    4 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |    2 +-
 drivers/net/wireless/ath/ath9k/antenna.c           |  776 +++++++++++
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   20 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    5 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |  457 ++++---
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   32 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |    5 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   49 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   23 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |   10 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    4 +
 drivers/net/wireless/ath/ath9k/debug.c             |    9 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    4 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   36 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  212 ++--
 drivers/net/wireless/ath/ath9k/hw.h                |   10 +-
 drivers/net/wireless/ath/ath9k/init.c              |   18 +-
 drivers/net/wireless/ath/ath9k/link.c              |  502 +++++++
 drivers/net/wireless/ath/ath9k/main.c              |  692 +++-------
 drivers/net/wireless/ath/ath9k/mci.c               |   65 +-
 drivers/net/wireless/ath/ath9k/mci.h               |   11 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    7 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  768 +----------
 drivers/net/wireless/ath/ath9k/reg.h               |    2 +
 drivers/net/wireless/ath/ath9k/xmit.c              |   51 +-
 drivers/net/wireless/b43legacy/main.c              |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |    3 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |    2 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    2 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |    2 +
 drivers/net/wireless/ipw2x00/ipw2200.c             |   23 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   13 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    5 +
 drivers/net/wireless/iwlwifi/Makefile              |   32 +-
 drivers/net/wireless/iwlwifi/dvm/Makefile          |   13 +
 .../net/wireless/iwlwifi/{iwl-agn.h => dvm/agn.h}  |   94 +--
 .../iwlwifi/{iwl-agn-calib.c => dvm/calib.c}       |   24 +-
 .../iwlwifi/{iwl-agn-calib.h => dvm/calib.h}       |    4 +-
 .../iwlwifi/{iwl-commands.h => dvm/commands.h}     |    7 +-
 .../iwlwifi/{iwl-debugfs.c => dvm/debugfs.c}       |   31 +-
 .../net/wireless/iwlwifi/{iwl-dev.h => dvm/dev.h}  |  148 +--
 .../iwlwifi/{iwl-agn-devices.c => dvm/devices.c}   |  178 +---
 .../net/wireless/iwlwifi/{iwl-led.c => dvm/led.c}  |    5 +-
 .../net/wireless/iwlwifi/{iwl-led.h => dvm/led.h}  |    0
 .../wireless/iwlwifi/{iwl-agn-lib.c => dvm/lib.c}  |   18 +-
 .../iwlwifi/{iwl-mac80211.c => dvm/mac80211.c}     |  144 +-
 .../net/wireless/iwlwifi/{iwl-agn.c => dvm/main.c} |  420 ++----
 .../wireless/iwlwifi/{iwl-power.c => dvm/power.c}  |   11 +-
 .../wireless/iwlwifi/{iwl-power.h => dvm/power.h}  |    2 +-
 .../wireless/iwlwifi/{iwl-agn-rs.c => dvm/rs.c}    |   50 +-
 .../wireless/iwlwifi/{iwl-agn-rs.h => dvm/rs.h}    |    3 +-
 .../wireless/iwlwifi/{iwl-agn-rx.c => dvm/rx.c}    |   10 +-
 .../iwlwifi/{iwl-agn-rxon.c => dvm/rxon.c}         |   52 +-
 .../wireless/iwlwifi/{iwl-scan.c => dvm/scan.c}    |  111 +-
 .../wireless/iwlwifi/{iwl-agn-sta.c => dvm/sta.c}  |   60 +-
 .../iwlwifi/{iwl-testmode.c => dvm/testmode.c}     |   21 +-
 .../iwlwifi/{iwl-testmode.h => dvm/testmode.h}     |    0
 .../wireless/iwlwifi/{iwl-agn-tt.c => dvm/tt.c}    |   13 +-
 .../wireless/iwlwifi/{iwl-agn-tt.h => dvm/tt.h}    |    2 +-
 .../wireless/iwlwifi/{iwl-agn-tx.c => dvm/tx.c}    |   58 +-
 .../wireless/iwlwifi/{iwl-ucode.c => dvm/ucode.c}  |   34 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   28 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   28 +-
 drivers/net/wireless/iwlwifi/iwl-debug.c           |    6 +
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   17 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c        |    5 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |    1 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  115 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |  900 ++++++++++++
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |  138 ++
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.c     |  463 +++++++
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.h     |   70 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          | 1148 ---------------
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |  269 ----
 drivers/net/wireless/iwlwifi/iwl-io.c              |   37 +
 drivers/net/wireless/iwlwifi/iwl-io.h              |    2 +
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   56 +-
 .../wireless/iwlwifi/{iwl-1000.c => pcie/1000.c}   |   19 +-
 .../wireless/iwlwifi/{iwl-2000.c => pcie/2000.c}   |   22 +-
 .../wireless/iwlwifi/{iwl-5000.c => pcie/5000.c}   |   20 +-
 .../wireless/iwlwifi/{iwl-6000.c => pcie/6000.c}   |   24 +-
 .../net/wireless/iwlwifi/{iwl-cfg.h => pcie/cfg.h} |    0
 .../net/wireless/iwlwifi/{iwl-pci.c => pcie/drv.c} |    5 +-
 .../{iwl-trans-pcie-int.h => pcie/internal.h}      |   21 +-
 .../iwlwifi/{iwl-trans-pcie-rx.c => pcie/rx.c}     |   75 +-
 .../iwlwifi/{iwl-trans-pcie.c => pcie/trans.c}     |  293 ++---
 .../iwlwifi/{iwl-trans-pcie-tx.c => pcie/tx.c}     |  147 ++-
 drivers/net/wireless/libertas/cfg.c                |   39 +-
 drivers/net/wireless/libertas/dev.h                |    1 +
 drivers/net/wireless/libertas/mesh.c               |    7 +-
 drivers/net/wireless/mwifiex/init.c                |   65 +
 drivers/net/wireless/mwifiex/main.c                |    4 +-
 drivers/net/wireless/mwifiex/main.h                |   11 +-
 drivers/net/wireless/mwifiex/scan.c                |   59 +-
 drivers/net/wireless/orinoco/cfg.c                 |    9 +-
 drivers/net/wireless/rt2x00/rt2800.h               |    8 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |   27 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c            |    3 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    2 +
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   14 +-
 drivers/net/wireless/ti/Kconfig                    |    1 +
 drivers/net/wireless/ti/Makefile                   |    1 +
 drivers/net/wireless/ti/wl12xx/Makefile            |    2 +-
 drivers/net/wireless/ti/wl12xx/acx.h               |  237 ++++
 drivers/net/wireless/ti/wl12xx/cmd.c               |    8 +-
 drivers/net/wireless/ti/wl12xx/debugfs.c           |  243 ++++
 drivers/net/wireless/ti/wl12xx/debugfs.h           |   28 +
 drivers/net/wireless/ti/wl12xx/main.c              |  242 +++-
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |    8 +
 drivers/net/wireless/ti/wl18xx/Kconfig             |    7 +
 drivers/net/wireless/ti/wl18xx/Makefile            |    3 +
 drivers/net/wireless/ti/wl18xx/acx.c               |  111 ++
 drivers/net/wireless/ti/wl18xx/acx.h               |  291 ++++
 drivers/net/wireless/ti/wl18xx/conf.h              |   92 ++
 drivers/net/wireless/ti/wl18xx/debugfs.c           |  403 ++++++
 drivers/net/wireless/ti/wl18xx/debugfs.h           |   28 +
 drivers/net/wireless/ti/wl18xx/io.c                |   60 +
 drivers/net/wireless/ti/wl18xx/io.h                |   28 +
 drivers/net/wireless/ti/wl18xx/main.c              | 1463 ++++++++++++++++++++
 drivers/net/wireless/ti/wl18xx/reg.h               |  191 +++
 drivers/net/wireless/ti/wl18xx/tx.c                |  127 ++
 drivers/net/wireless/ti/wl18xx/tx.h                |   46 +
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |   88 ++
 drivers/net/wireless/ti/wlcore/acx.c               |    8 +-
 drivers/net/wireless/ti/wlcore/acx.h               |  254 +----
 drivers/net/wireless/ti/wlcore/boot.c              |   57 +-
 drivers/net/wireless/ti/wlcore/boot.h              |    1 +
 drivers/net/wireless/ti/wlcore/cmd.c               |   62 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |   13 +-
 drivers/net/wireless/ti/wlcore/conf.h              |   93 +-
 drivers/net/wireless/ti/wlcore/debugfs.c           |  390 ++----
 drivers/net/wireless/ti/wlcore/debugfs.h           |   87 ++
 drivers/net/wireless/ti/wlcore/event.c             |   24 +-
 drivers/net/wireless/ti/wlcore/hw_ops.h            |   78 ++
 drivers/net/wireless/ti/wlcore/init.c              |    3 +
 drivers/net/wireless/ti/wlcore/main.c              |  504 ++++----
 drivers/net/wireless/ti/wlcore/ps.c                |   21 +-
 drivers/net/wireless/ti/wlcore/rx.c                |   11 +-
 drivers/net/wireless/ti/wlcore/rx.h                |    7 +-
 drivers/net/wireless/ti/wlcore/scan.c              |   52 +-
 drivers/net/wireless/ti/wlcore/scan.h              |   19 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |   35 +-
 drivers/net/wireless/ti/wlcore/tx.c                |  185 ++-
 drivers/net/wireless/ti/wlcore/tx.h                |   49 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   70 +-
 .../wireless/ti/wlcore/{wl12xx.h => wlcore_i.h}    |   44 +-
 drivers/nfc/pn533.c                                |  662 ++++++++--
 drivers/nfc/pn544_hci.c                            |   10 +-
 drivers/ssb/b43_pci_bridge.c                       |    1 +
 drivers/ssb/scan.c                                 |    2 +
 include/linux/nfc.h                                |   12 +
 include/linux/nl80211.h                            |    8 +
 include/linux/ssb/ssb.h                            |    1 +
 include/net/cfg80211.h                             |   45 +-
 include/net/mac80211.h                             |   44 +-
 include/net/nfc/hci.h                              |    3 +-
 include/net/nfc/nfc.h                              |   14 +-
 include/net/nfc/shdlc.h                            |    3 +-
 net/core/net-sysfs.c                               |   74 -
 net/mac80211/Makefile                              |    1 -
 net/mac80211/agg-rx.c                              |   30 +-
 net/mac80211/agg-tx.c                              |  109 +--
 net/mac80211/cfg.c                                 |  579 +++++----
 net/mac80211/chan.c                                |    4 +
 net/mac80211/debugfs_netdev.c                      |    3 +-
 net/mac80211/ibss.c                                |  114 +-
 net/mac80211/ieee80211_i.h                         |   92 +-
 net/mac80211/iface.c                               |   42 +-
 net/mac80211/main.c                                |   17 +-
 net/mac80211/mesh.c                                |    3 +-
 net/mac80211/mesh_hwmp.c                           |    2 +-
 net/mac80211/mesh_pathtbl.c                        |    2 +-
 net/mac80211/mesh_plink.c                          |    2 +-
 net/mac80211/mesh_sync.c                           |    2 +-
 net/mac80211/mlme.c                                |  189 ++--
 net/mac80211/offchannel.c                          |  280 ++++-
 net/mac80211/pm.c                                  |    1 +
 net/mac80211/rx.c                                  |   22 +-
 net/mac80211/scan.c                                |    4 +-
 net/mac80211/sta_info.c                            |   23 +-
 net/mac80211/status.c                              |   30 +-
 net/mac80211/tkip.c                                |   21 +-
 net/mac80211/tx.c                                  |   14 +-
 net/mac80211/util.c                                |  117 +-
 net/mac80211/work.c                                |  370 -----
 net/nfc/core.c                                     |  119 ++-
 net/nfc/hci/core.c                                 |   13 +-
 net/nfc/hci/shdlc.c                                |    6 +-
 net/nfc/llcp/commands.c                            |   54 +-
 net/nfc/llcp/llcp.c                                |  421 ++++---
 net/nfc/llcp/llcp.h                                |   26 +-
 net/nfc/llcp/sock.c                                |   47 +-
 net/nfc/nci/core.c                                 |   15 +-
 net/nfc/netlink.c                                  |   81 +-
 net/nfc/nfc.h                                      |   12 +-
 net/rfkill/core.c                                  |    2 +-
 net/wireless/Kconfig                               |   14 -
 net/wireless/chan.c                                |   55 +-
 net/wireless/core.h                                |   12 +-
 net/wireless/mesh.c                                |   91 ++-
 net/wireless/mlme.c                                |    2 -
 net/wireless/nl80211.c                             |  129 ++-
 net/wireless/wext-compat.c                         |   21 +-
 net/wireless/wext-sme.c                            |   10 +-
 219 files changed, 12126 insertions(+), 7378 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/antenna.c
 create mode 100644 drivers/net/wireless/ath/ath9k/link.c
 create mode 100644 drivers/net/wireless/iwlwifi/dvm/Makefile
 rename drivers/net/wireless/iwlwifi/{iwl-agn.h => dvm/agn.h} (81%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-calib.c => dvm/calib.c} (98%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-calib.h => dvm/calib.h} (98%)
 rename drivers/net/wireless/iwlwifi/{iwl-commands.h => dvm/commands.h} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-debugfs.c => dvm/debugfs.c} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-dev.h => dvm/dev.h} (84%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-devices.c => dvm/devices.c} (78%)
 rename drivers/net/wireless/iwlwifi/{iwl-led.c => dvm/led.c} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-led.h => dvm/led.h} (100%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-lib.c => dvm/lib.c} (98%)
 rename drivers/net/wireless/iwlwifi/{iwl-mac80211.c => dvm/mac80211.c} (92%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn.c => dvm/main.c} (87%)
 rename drivers/net/wireless/iwlwifi/{iwl-power.c => dvm/power.c} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-power.h => dvm/power.h} (98%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-rs.c => dvm/rs.c} (98%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-rs.h => dvm/rs.h} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-rx.c => dvm/rx.c} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-rxon.c => dvm/rxon.c} (97%)
 rename drivers/net/wireless/iwlwifi/{iwl-scan.c => dvm/scan.c} (94%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-sta.c => dvm/sta.c} (97%)
 rename drivers/net/wireless/iwlwifi/{iwl-testmode.c => dvm/testmode.c} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-testmode.h => dvm/testmode.h} (100%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-tt.c => dvm/tt.c} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-tt.h => dvm/tt.h} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-agn-tx.c => dvm/tx.c} (96%)
 rename drivers/net/wireless/iwlwifi/{iwl-ucode.c => dvm/ucode.c} (93%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom-read.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom-read.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom.h
 rename drivers/net/wireless/iwlwifi/{iwl-1000.c => pcie/1000.c} (89%)
 rename drivers/net/wireless/iwlwifi/{iwl-2000.c => pcie/2000.c} (92%)
 rename drivers/net/wireless/iwlwifi/{iwl-5000.c => pcie/5000.c} (90%)
 rename drivers/net/wireless/iwlwifi/{iwl-6000.c => pcie/6000.c} (93%)
 rename drivers/net/wireless/iwlwifi/{iwl-cfg.h => pcie/cfg.h} (100%)
 rename drivers/net/wireless/iwlwifi/{iwl-pci.c => pcie/drv.c} (99%)
 rename drivers/net/wireless/iwlwifi/{iwl-trans-pcie-int.h => pcie/internal.h} (95%)
 rename drivers/net/wireless/iwlwifi/{iwl-trans-pcie-rx.c => pcie/rx.c} (96%)
 rename drivers/net/wireless/iwlwifi/{iwl-trans-pcie.c => pcie/trans.c} (91%)
 rename drivers/net/wireless/iwlwifi/{iwl-trans-pcie-tx.c => pcie/tx.c} (88%)
 create mode 100644 drivers/net/wireless/ti/wl12xx/debugfs.c
 create mode 100644 drivers/net/wireless/ti/wl12xx/debugfs.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/Kconfig
 create mode 100644 drivers/net/wireless/ti/wl18xx/Makefile
 create mode 100644 drivers/net/wireless/ti/wl18xx/acx.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/acx.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/conf.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/debugfs.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/debugfs.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/io.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/io.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/main.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/reg.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/tx.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/tx.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/wl18xx.h
 rename drivers/net/wireless/ti/wlcore/{wl12xx.h => wlcore_i.h} (95%)
 delete mode 100644 net/mac80211/work.c

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
