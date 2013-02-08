From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2013-02-08
Date: Fri, 8 Feb 2013 14:18:43 -0500
Message-ID: <20130208191843.GF2116@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept this pull request intended for the 3.9 stream!

Included are a mac80211 pull, an iwlwifi pull (actually two -- one
was a fast-forward), a wl12xx pull, and a couple of Bluetooth pulls.

On mac80211, Johannes says:

"I've included
 * AKM definitions from Bing,
 * mesh fixes from Thomas, including a fix from him for me breaking his
   patch while applying,
 * channel check fix from Simon,
 * an old patch from Yoni Divinsky who doesn't even work for TI any
   more, to configure the WEP TX key for ARP offload etc.
 * MAC ACL API from Vasanth
 * a fix for the infamous chanctx_conf warning from Arnd
 * from myself, a fix for my previous aggregation changes, some cleanup
   and some improvements and fixes for WoWLAN"

On iwlwifi, Johannes says:

"Two small changes for iwlwifi-next, one to update all our Copyright
notices and one to provide the RX page order."

And also:

"So what I have here is some cleanups, preparations and the new MVM
(multi-virtual MAC) driver itself and (this is new) some work on the
transport API as well as a message flooding fix."

On wl12xx, Luca says:

"Lots of bugfixes and improvements in our TI wireless drivers,
including support for multi-channel.  Intended for 3.9."

On Bluetooth, Gustavo says:

"This is my first pull request to 3.9. The biggest changes here are from Jo=
han
Hedberg who made a lot of fixes in the Management interface. The issues aro=
se
due to a new test tool we wrote and the usage of the Management interface as
default in BlueZ 5. The rest of the patches are more clean ups and small
fixes."

And also:

"Here goes another batch intended for 3.9, the majority of the patch here a=
re
=66rom Johan who is fixing many issues in the management interface that have
appeared lately. The rest of the patches are just small improvements, fixes
and clean ups."

Along with those are the usual variety of updates/enhancements to
the mwl8k, mwifiex, ath9k, rtlwifi, and rt2x00 drivers as well as
a few updates for the ssb and bcma busses.  I don't think there are
any big headliners there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit b285109dde7b873b5dc671ef1b3ae3090f4bc72f:

  Merge branch 'tg3' (2013-02-07 23:48:33 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to f5237f278f30a92401539a54f87ee0c717b6f818:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-02-08 13:16:17 -0500)

----------------------------------------------------------------

Alexey Khoroshilov (1):
      mwifiex: don't return zero on failure paths in mwifiex_pcie_init()

Anatol Pomozov (1):
      rtl8723ae: Fix misspellings sucess->success

Andre Guedes (3):
      Bluetooth: Reduce critical section in sco_conn_ready
      Bluetooth: Remove unneeded locking
      Bluetooth: Refactor mgmt_pending_foreach

Andrei Emeltchenko (4):
      Bluetooth: AMP: Send A2MP Create Phylink Rsp after Assoc write
      Bluetooth: AMP: Clean up logical link create / accept
      Bluetooth: AMP: Remove dead code
      Bluetooth: AMP: Use set_bit / test_bit for amp_mgr state

Arik Nemtsov (23):
      wlcore: use new set bandwidth command to adjusting channel BW
      wlcore/wl18xx/wl12xx: separate channel count between chips
      wlcore/wl12xx: make sure session id is always zero for AP
      wlcore: clear roc_vif on iface removal
      wlcore: take the mutex before resetting Tx queues
      wlcore: consolidate free_link and always call it
      wlcore: initialize per-link FW freed blocks correctly
      wlcore: track wlvif inside per-link structure
      wlcore: count packets held per AC in each vif
      wlcore: track FW-allocated packets per link
      wlcore: improved Tx scheduling algorithm
      wl18xx: set last Tx rate from FW status
      wlcore: remove support for injected Tx
      wlcore: improve handling for Rx errors
      wlcore: set 5Ghz probe-req template for DFS channels
      wlcore/wl18xx: change priority calculations for links
      wl18xx: limit Tx for the AP single-STA-in-PSM case
      wlcore: use link count for single-STA-PSM optimization
      wlcore: use separate HW queue for each AC in each vif
      wlcore: don't take mutex before stopping queues
      wlcore: consolidate Rx BA bitmap management to links struct
      wl18xx: support MIMO only if HT mode is not forced to SISO
      wl18xx: count HW block spare based correctly on keys

Arnd Bergmann (1):
      mac80211: avoid a build warning

Avinash Patil (1):
      mwifiex: fix invalid access of PCIe RxBD ring buffer descriptor

Bing Zhao (4):
      ieee80211: define AKM suite selectors type 5, 6 and 7
      mwifiex: do not overwrite error code from lower layer driver
      mwifiex: do not reconfigure tx buffer size in firmware while associat=
ing
      mwifiex: remove max_tx_buf_size

Christian Lamparter (3):
      iwlegacy: fix antenna bitmask
      iwl4965: report A-MPDU status
      ath9k: report A-MPDU status

Chuansheng Liu (1):
      wlcore: Fix the usage of wait_for_completion_timeout

Chun-Yeow Yeoh (1):
      rt2x00: allow AP and mesh mode to operate simultaneously

Cyril Roelandt (1):
      mwifiex: avoid out of bounds access in mwifiex_get_common_rates.

Eliad Peller (36):
      wlcore: start sta role on CHANGED_BSSID
      wlcore: workaround start_sta problem in wl12xx fw
      wlcore: implement .remain_on_channel() callback
      wlcore: get channel from bss_conf instead of hw->conf
      wlcore: add chanctx implementation
      wlcore: initiate ROC/CROC on sta state updates
      wlcore: set active psm on association
      wlcore: specify correct supported_rates
      wlcore: reconfigure rate policy on association
      wlcore: refactor CHANGED_HT handling
      wlcore: configure the remote rates with our own rates
      wlcore: print role_id on bss_info_changed
      wlcore: don't leak wl->mbox
      wlcore: don't call ieee80211_sched_scan_stopped directly
      wlcore: make scan scan configuration functions more generic
      wl18xx: change fw name and temporarily fail loading
      wlcore: update commands enum to new fw api
      wlcore: split 18xx and 12xx scan mechanism
      wl18xx: increase MAX_CHANNELS_5GHZ
      wlcore: update acx enum
      wlcore: update channel_switch/stop_channel_switch commands
      wlcore: update events enum/struct to new fw api
      wlcore: pass wmm configuration to the fw
      wlcore: save session_id per-link
      wlcore: call ieee80211_sched_scan_stopped on interface removal
      wl18xx: make driver operational again
      wlcore: configure dwell times according to scan type
      wlcore: don't stop fwlog if dbgpins are used
      wlcore: use sta_state-based ROCs for AP mode
      wlcore: mask out CCK rates when starting GO
      wlcore: move ps change handling to .bss_info_changed()
      wlcore: allow fw commands to fail
      wlcore: allow ACX_BA_SESSION_RX_SETUP to fail
      wlcore: remove WLCORE_QUIRK_NO_ELP
      wl18xx: declare support for greenfield ht_cap
      wlcore: add ACX_PEER_CAP command

Emmanuel Grumbach (2):
      iwlwifi: provide RX page order
      mac80211: provide the vif in rssi_callback

Eyal Shapira (2):
      wlcore: increase scan dwell times if no activity
      wlcore: support scan reports during periodic scan

Guenter Roeck (1):
      net: iwlegacy: remove unused variable

Gustavo Padovan (1):
      Bluetooth: Fix uuid output in debugfs

Hauke Mehrtens (2):
      ssb: add gpio_to_irq
      bcma: add gpio_to_irq

Ido Reis (1):
      wl18xx: update default mac/phy parameters

Ido Yariv (1):
      wlcore: Always pass DMA-able buffers to mmc functions

Janusz.Dziedzic-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org (1):
      wlcore: SPI - fix spi transfer_list

Johan Hedberg (36):
      Bluetooth: Fix missing command complete event for mgmt_confirm_name
      Bluetooth: Fix missing command complete for mgmt_load_long_term_keys
      Bluetooth: Fix checking for valid device class values
      Bluetooth: Fix accepting set_dev_class for non-BR/EDR controllers
      Bluetooth: Move non-critical sections outside of the dev lock
      Bluetooth: Fix checking for exact values of boolean mgmt parameters
      Bluetooth: Fix returning proper command status for start_discovery
      Bluetooth: Fix sending incorrect new_settings for mgmt_set_powered
      Bluetooth: Add a new workqueue for hci_request operations
      Bluetooth: Use req_workqueue for hci_request operations
      Bluetooth: Fix using system-global workqueue when not necessary
      Bluetooth: Fix Class of Device indication when powering off
      Bluetooth: Fix checking for correct mgmt_load_link_keys parameters
      Bluetooth: Fix returning proper mgmt status for Load LTKs
      Bluetooth: Fix checking for proper key->master value in Load LTKs
      Bluetooth: Refactor valid LTK data testing into its own function
      Bluetooth: Check for valid key->authenticated value for LTKs
      Bluetooth: Add helper functions for testing bdaddr types
      Bluetooth: Fix checking for valid address type values in mgmt commands
      Bluetooth: Fix checking for valid disconnect parameters in unpair_dev=
ice
      Bluetooth: Fix returning proper cmd_complete for mgmt_disconnect
      Bluetooth: Fix returning proper cmd_complete for mgmt_block/unblock
      Bluetooth: Add LE Local Features reading support
      Bluetooth: Add support for reading LE White List Size
      Bluetooth: Add support for reading LE supported states
      Bluetooth: Store UUIDs in the same order that they were added
      Bluetooth: Simplify UUIDs clearing code
      Bluetooth: Keep track of UUID type upon addition
      Bluetooth: Simplify UUID removal code
      Bluetooth: Simplify UUID16 list generation for EIR
      Bluetooth: Remove useless eir_len variable from EIR creation
      Bluetooth: Refactor UUID-16 list generation into its own function
      Bluetooth: Add support for 32-bit UUIDs in EIR data
      Bluetooth: Add support for 128-bit UUIDs in EIR data
      Bluetooth: Fix link security setting when powering on
      Bluetooth: Increment Management interface revision

Johannes Berg (14):
      mac80211: remove ARP filter enable/disable logic
      mac80211: improve aggregation debug messages
      mac80211: allow drivers to access IPv6 information
      iwlwifi: update copyright
      mac80211: fix aggregation state with current drivers
      mac80211: remove redundant check
      iwlwifi: include debugfs.h
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: add 7000 series device configuration
      iwlwifi: clean up CMD_MODE enum
      iwlwifi: fix calibration parser
      iwlwifi: add NVM and PHY DB code for new MVM driver
      iwlwifi: add the MVM driver
      iwlwifi: lower BT coex aggregation message severity

John W. Linville (6):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Julia Lawall (2):
      drivers/net/wireless/ti/wlcore/main.c: eliminate possible double powe=
r off
      drivers/net/wireless/iwlegacy/4965-mac.c: adjust duplicate test

Kees Cook (1):
      drivers/net/wireless/ti/wl1251: remove CONFIG_EXPERIMENTAL

Larry Finger (7):
      rtlwifi: Eliminate two empty routines
      rtlwifi: Fix many compile warnings when using W=3D1
      rtlwifi: Fix warnings in usb.c
      rtlwifi: rtl8192c: Fix W=3D1 warning
      rtlwifi: rtl8192cu: Fix W=3D1 build warning
      rtlwifi: rtl8192de: Fix W=3D1 build warnings
      rtlwifi: rtl8723ae: Fix W=3D1 compile warnings

Lilach Edelstein (2):
      iwlwifi: add iwl_set_bits_mask to transport API
      iwlwifi: move register access lock into transport

Luciano Coelho (11):
      wlcore: avoid using goto in normal code flow
      wlcore: remove a bunch of unnecessary parentheses
      wlcore: gather information about firmware stability
      wlcore/wl12xx: move wl12xx chip ID defines to the lower driver
      wlcore/wl12xx: remove deprecated FW version check
      wlcore: change way of checking the firmware version
      wl12xx: ignore some of the firmware version fields
      wlcore/wl12xx/wl18xx: verify multi-role and single-role fw versions
      wl18xx: ignore irrelevant firmware version fields
      Merge branch 'wl12xx-next' into for-linville
      Merge branch 'wl12xx-next' into for-linville

Rafa=C5=82 Mi=C5=82ecki (5):
      ssb: trivial: use pflash helper variable
      ssb: register platform device for parallel flash
      bcma: register platform device for parallel flash
      bcma: Xflash: reorder includes to make pr_fmt work
      bcma: cc: fix (and rename) define of NAND flash type

Rami Rosen (2):
      Bluetooth: Remove unnecessary include l2cap.h
      Bluetooth: remove an unused variable in a header file

Simon Wunderlich (4):
      cfg80211: fix channel check in cfg80211_can_use_iftype_chan
      ath9k: add debug parameters for spectral scan
      ath9k: drop spectral packets after processing them
      ath9k: reorder error codes for spectral

Stanislaw Gruszka (5):
      rt2x00: print chip and firmware version by default
      rt2x00: print warning, notice and info as default
      rt2800usb: move "TX status missed" messages to debug level
      rt2x00: remove NOTICE
      iwlegacy: check for dma mapping errors

Sven Eckelmann (7):
      ath9k: Update spectral scan output data
      ath9k: Select RELAY for ATH9K_DEBUGFS
      ath9k: Only process fft samples when ATH9K_DEBUGFS is enabled
      ath9k: Only add fix_rssi_inv_only when spectral code is used
      ath9k: Only remove spectral scan relay file when it was created
      ath9k: Fix sparse __CHECK_ENDIAN__ for spectral code
      ath9k: Remove unused variables in ath_mci_cleanup

Szymon Janc (3):
      Bluetooth: mgmt: Remove not needed restriction on add/remove OOB data
      Bluetooth: mgmt: Avoid using magic number in status code
      Bluetooth: Fix pair device command reply if adapter is powered off

Thomas Pedersen (3):
      mac80211: clean up mesh sta allocation warning
      mac80211: support mesh rate updates
      mac80211: fix mesh_sta_info_get() reshuffle damage

Tushar Behera (1):
      wlcore: Remove redundant check on unsigned variable

Vasanthakumar Thiagarajan (2):
      cfg80211: Move the definition of struct mac_address up
      cfg80211/nl80211: add API for MAC address ACLs

Victor Goldenshtein (3):
      wlcore: add new reg-domain configuration command
      wlcore: remove unnecessary WARN_ON in wl12xx_tx_reset
      wlcore: restore default channel configuration

Vladimir Kondratiev (14):
      wil6210: Detect FW error
      wil6210: rearrange IRQ debug printing
      wil6210: remove raw wil_dbg() calls
      wil6210: Refactor rx init/fini
      wil6210: Count Tx statistics on Tx completion
      wil6210: Fix: Tx stall
      wil6210: Call skb_orphan() right before Rx indication
      wil6210: Fix "don't scan after connect" logic
      wil6210: Separate common code for mbox regs caching to function
      wil6210: Reorder reset preparation sequence
      wil6210: fix checkpatch CamelCase warnings
      wil6210: checkpatch warnings
      wil6210: Never delete Rx chain with firmware
      wil6210: fix wil_vring_init_tx status

Wei Yongjun (2):
      wlcore: spi: use platform_device_unregister in wl1271_remove()
      wlcore: sdio: use platform_device_unregister in wl1271_remove()

Xose Vazquez Perez (2):
      wireless: rt2x00: rt2800usb add/identify ids
      wireless: rt2x00: rt2800pci add id

Yair Shapira (3):
      wlcore/wl18xx/wl12xx: add recovery settings to conf
      wl18xx: support 2nd set of mac/phy tx-power params
      wl18xx: fix a bug in wl->num_rx_desc initialization

Yogesh Ashok Powar (10):
      mwl8k: Stop bsses before hw specific commands
      mwl8k: Do not call mwl8k_cmd_set_rf_channel unconditionally
      mwl8k: Move tx/rx antenna configuration to mwl8k_probe_hw
      mwl8k: Announce simultaneous AP-STA support on AP fw
      mwl8k: Allow adding station interface on AP firmware
      mwl8k: set mac type to MWL8K_MAC_TYPE_SECONDARY_CLIENT
      mwl8k: Enable hw encryption for STA mode on AP fw
      mwl8k: Add/Del self entry for AP interface only
      mwl8k: Choose interface specific calls on vif type
      mwl8k: Do not call STA specific cmds not supported by the AP fw

Yoni Divinsky (1):
      mac80211: add op to configure default key id

 drivers/bcma/bcma_private.h                        |    1 +
 drivers/bcma/driver_chipcommon_nflash.c            |    4 +-
 drivers/bcma/driver_chipcommon_sflash.c            |    4 +-
 drivers/bcma/driver_gpio.c                         |   11 +
 drivers/bcma/driver_mips.c                         |   38 +-
 drivers/bcma/main.c                                |    8 +
 drivers/net/wireless/ath/ath9k/Kconfig             |    1 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |   17 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  193 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/init.c              |    9 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    8 +-
 drivers/net/wireless/ath/ath9k/main.c              |   23 +-
 drivers/net/wireless/ath/ath9k/mci.c               |    2 -
 drivers/net/wireless/ath/ath9k/recv.c              |   80 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    9 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   55 +-
 drivers/net/wireless/ath/wil6210/main.c            |   63 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   31 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    4 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  107 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   22 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  107 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    5 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |   39 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   57 +-
 drivers/net/wireless/iwlegacy/4965.c               |    3 -
 drivers/net/wireless/iwlegacy/commands.h           |    3 +-
 drivers/net/wireless/iwlegacy/common.h             |    1 +
 drivers/net/wireless/iwlwifi/Kconfig               |   14 +-
 drivers/net/wireless/iwlwifi/Makefile              |    3 +
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    4 +-
 drivers/net/wireless/iwlwifi/dvm/calib.c           |    4 +-
 drivers/net/wireless/iwlwifi/dvm/calib.h           |    4 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |    4 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |    2 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c         |    2 +-
 drivers/net/wireless/iwlwifi/dvm/led.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/led.h             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    9 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   42 +-
 drivers/net/wireless/iwlwifi/dvm/power.c           |    2 +-
 drivers/net/wireless/iwlwifi/dvm/power.h           |    2 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |    7 +-
 drivers/net/wireless/iwlwifi/dvm/rs.h              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |    2 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |    2 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/testmode.c        |    4 +-
 drivers/net/wireless/iwlwifi/dvm/tt.c              |    8 +-
 drivers/net/wireless/iwlwifi/dvm/tt.h              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    5 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   27 +-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |   18 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |   13 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.c     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.h     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    5 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   20 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   93 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   15 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.h      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |  346 +++
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |   80 +
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    6 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |  514 ++++
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |   82 +
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-test.c            |   21 +-
 drivers/net/wireless/iwlwifi/iwl-test.h            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   52 +-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |   10 +
 drivers/net/wireless/iwlwifi/mvm/binding.c         |  197 ++
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  841 ++++++
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  378 +++
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |  282 ++
 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h      |  369 +++
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |  140 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |  312 ++
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  561 ++++
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |  380 +++
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |  580 ++++
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  949 ++++++
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  644 ++++
 drivers/net/wireless/iwlwifi/mvm/led.c             |  134 +
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |  951 ++++++
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        | 1310 +++++++++
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  500 ++++
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |  311 ++
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  679 +++++
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |  292 ++
 drivers/net/wireless/iwlwifi/mvm/power.c           |  207 ++
 drivers/net/wireless/iwlwifi/mvm/quota.c           |  178 ++
 drivers/net/wireless/iwlwifi/mvm/rs.c              | 3096 ++++++++++++++++=
++++
 drivers/net/wireless/iwlwifi/mvm/rs.h              |  393 +++
 drivers/net/wireless/iwlwifi/mvm/rx.c              |  355 +++
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  437 +++
 drivers/net/wireless/iwlwifi/mvm/sta.c             | 1211 ++++++++
 drivers/net/wireless/iwlwifi/mvm/sta.h             |  368 +++
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |  569 ++++
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |  214 ++
 drivers/net/wireless/iwlwifi/mvm/tx.c              |  916 ++++++
 drivers/net/wireless/iwlwifi/mvm/utils.c           |  472 +++
 drivers/net/wireless/iwlwifi/pcie/1000.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/2000.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/5000.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/6000.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/7000.c           |  111 +
 drivers/net/wireless/iwlwifi/pcie/cfg.h            |    6 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   10 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    6 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    3 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   95 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |    2 +-
 drivers/net/wireless/mwifiex/11n.c                 |   39 -
 drivers/net/wireless/mwifiex/11n.h                 |    2 -
 drivers/net/wireless/mwifiex/README                |    1 -
 drivers/net/wireless/mwifiex/debugfs.c             |    2 -
 drivers/net/wireless/mwifiex/init.c                |    1 -
 drivers/net/wireless/mwifiex/ioctl.h               |    1 -
 drivers/net/wireless/mwifiex/join.c                |    6 +-
 drivers/net/wireless/mwifiex/main.h                |    1 -
 drivers/net/wireless/mwifiex/pcie.c                |    6 +-
 drivers/net/wireless/mwifiex/sdio.c                |   10 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    5 +-
 drivers/net/wireless/mwifiex/usb.c                 |    4 +-
 drivers/net/wireless/mwifiex/util.c                |    2 +-
 drivers/net/wireless/mwl8k.c                       |  167 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c            |   20 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    6 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    6 +-
 drivers/net/wireless/rtlwifi/rc.c                  |   15 -
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   |    2 -
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |   20 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |    2 -
 drivers/net/wireless/rtlwifi/usb.c                 |    4 -
 drivers/net/wireless/rtlwifi/wifi.h                |    2 +-
 drivers/net/wireless/ti/wl1251/Kconfig             |    2 +-
 drivers/net/wireless/ti/wl12xx/Makefile            |    2 +-
 drivers/net/wireless/ti/wl12xx/cmd.c               |   37 +
 drivers/net/wireless/ti/wl12xx/cmd.h               |   20 +
 drivers/net/wireless/ti/wl12xx/event.c             |  116 +
 drivers/net/wireless/ti/wl12xx/event.h             |  111 +
 drivers/net/wireless/ti/wl12xx/main.c              |  192 +-
 drivers/net/wireless/ti/wl12xx/scan.c              |  501 ++++
 drivers/net/wireless/ti/wl12xx/scan.h              |  140 +
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |   40 +-
 drivers/net/wireless/ti/wl18xx/Makefile            |    2 +-
 drivers/net/wireless/ti/wl18xx/acx.c               |   87 +-
 drivers/net/wireless/ti/wl18xx/acx.h               |   55 +-
 drivers/net/wireless/ti/wl18xx/cmd.c               |   80 +
 drivers/net/wireless/ti/wl18xx/cmd.h               |   52 +
 drivers/net/wireless/ti/wl18xx/conf.h              |   21 +-
 drivers/net/wireless/ti/wl18xx/event.c             |  111 +
 drivers/net/wireless/ti/wl18xx/event.h             |   77 +
 drivers/net/wireless/ti/wl18xx/main.c              |  267 +-
 drivers/net/wireless/ti/wl18xx/scan.c              |  326 +++
 drivers/net/wireless/ti/wl18xx/scan.h              |  127 +
 drivers/net/wireless/ti/wl18xx/tx.c                |   54 +-
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |   50 +-
 drivers/net/wireless/ti/wlcore/acx.c               |   15 +-
 drivers/net/wireless/ti/wlcore/acx.h               |    1 -
 drivers/net/wireless/ti/wlcore/boot.c              |   77 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |  419 ++-
 drivers/net/wireless/ti/wlcore/cmd.h               |   81 +-
 drivers/net/wireless/ti/wlcore/conf.h              |  110 +-
 drivers/net/wireless/ti/wlcore/debugfs.c           |   10 +-
 drivers/net/wireless/ti/wlcore/event.c             |  326 +--
 drivers/net/wireless/ti/wlcore/event.h             |   99 +-
 drivers/net/wireless/ti/wlcore/hw_ops.h            |   41 +
 drivers/net/wireless/ti/wlcore/init.c              |   19 +-
 drivers/net/wireless/ti/wlcore/io.h                |   12 +-
 drivers/net/wireless/ti/wlcore/main.c              | 1592 ++++++----
 drivers/net/wireless/ti/wlcore/ps.c                |   11 +-
 drivers/net/wireless/ti/wlcore/rx.c                |   33 +-
 drivers/net/wireless/ti/wlcore/rx.h                |    3 +-
 drivers/net/wireless/ti/wlcore/scan.c              |  696 ++---
 drivers/net/wireless/ti/wlcore/scan.h              |  144 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |    3 +-
 drivers/net/wireless/ti/wlcore/spi.c               |    5 +-
 drivers/net/wireless/ti/wlcore/tx.c                |  298 +-
 drivers/net/wireless/ti/wlcore/tx.h                |   35 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |  118 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   49 +-
 drivers/ssb/driver_gpio.c                          |   22 +
 drivers/ssb/driver_mipscore.c                      |   48 +-
 drivers/ssb/main.c                                 |    8 +
 drivers/ssb/ssb_private.h                          |    4 +
 include/linux/bcma/bcma_driver_chipcommon.h        |    2 +-
 include/linux/bcma/bcma_driver_mips.h              |    9 +-
 include/linux/ieee80211.h                          |    5 +-
 include/linux/ssb/ssb_driver_mips.h                |    5 +
 include/net/bluetooth/a2mp.h                       |    4 +-
 include/net/bluetooth/bluetooth.h                  |   23 +
 include/net/bluetooth/hci.h                        |   18 +
 include/net/bluetooth/hci_core.h                   |    5 +
 include/net/bluetooth/l2cap.h                      |    1 -
 include/net/cfg80211.h                             |   42 +-
 include/net/mac80211.h                             |   31 +-
 include/uapi/linux/nl80211.h                       |   51 +-
 net/bluetooth/a2mp.c                               |   42 +-
 net/bluetooth/amp.c                                |   25 +-
 net/bluetooth/bnep/core.c                          |    1 -
 net/bluetooth/hci_core.c                           |   30 +-
 net/bluetooth/hci_event.c                          |   64 +-
 net/bluetooth/hci_sysfs.c                          |   22 +-
 net/bluetooth/l2cap_core.c                         |    5 -
 net/bluetooth/mgmt.c                               |  489 +++-
 net/bluetooth/sco.c                                |   18 +-
 net/mac80211/agg-rx.c                              |   14 +-
 net/mac80211/agg-tx.c                              |   61 +-
 net/mac80211/driver-ops.h                          |   36 +-
 net/mac80211/ieee80211_i.h                         |    3 +-
 net/mac80211/iface.c                               |    3 -
 net/mac80211/key.c                                 |    5 +-
 net/mac80211/main.c                                |   64 +-
 net/mac80211/mesh_plink.c                          |  168 +-
 net/mac80211/mlme.c                                |   42 +-
 net/mac80211/sta_info.c                            |    5 -
 net/mac80211/trace.h                               |   53 +-
 net/mac80211/tx.c                                  |    8 +-
 net/wireless/core.c                                |    5 +
 net/wireless/nl80211.c                             |  116 +
 net/wireless/rdev-ops.h                            |   12 +
 net/wireless/trace.h                               |   18 +
 net/wireless/util.c                                |    3 +-
 249 files changed, 26303 insertions(+), 3190 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/Makefile
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/binding.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/d3.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/debugfs.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/led.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/mac80211.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/mvm.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/nvm.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/ops.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/power.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/quota.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/rs.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/rs.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/rx.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/scan.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/sta.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/sta.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/time-event.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/time-event.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/tx.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/utils.c
 create mode 100644 drivers/net/wireless/iwlwifi/pcie/7000.c
 create mode 100644 drivers/net/wireless/ti/wl12xx/event.c
 create mode 100644 drivers/net/wireless/ti/wl12xx/event.h
 create mode 100644 drivers/net/wireless/ti/wl12xx/scan.c
 create mode 100644 drivers/net/wireless/ti/wl12xx/scan.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/cmd.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/cmd.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/event.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/event.h
 create mode 100644 drivers/net/wireless/ti/wl18xx/scan.c
 create mode 100644 drivers/net/wireless/ti/wl18xx/scan.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIbBAEBAgAGBQJRFU+TAAoJEJctW/TcYTgGAbQP9RubTR6FCIKFidH4IpFKZNI7
y8UEaqnaUusARG4xPotZWf6CQ+gIwdNCavHPKAW14matt3CbNz83S46577hxNrBJ
XwCc9iSxSuyqx+5v38TMm0y0Q5APUzf/mHGk1sB4RUsdL+WjrIrBUdt5ABsKhw77
b0Lm2oOdQKXUl+EGc8qK46cX4s50N9v3ZtCtXwy5iLW553c2sAz0cPOYgb5JZmsa
CYvV4dxUVfJBmfwzcNDH/LXFqi9q5RM9cYa9T4LekrG+NCOMQhV/t7ylFMt6g0iG
AuvPsEPYr9/PVUN1wUcEswwOB5H10hjk6BiLotsXRhyR0/rJVth5xAXFqphKSnUQ
F82JqX4Cg3UD73oQLHbK69NL8n6xo0uUMjSUubKBF6OJXMSJbJHXIOPek3/DddmL
51P9Nrl3JVpgUkio8C3/vgsJ/k8hgo/l2zjKBRa1Ab4eWs8+fTz0nlTfbs4dI1GG
bEjSgDw37oT6hgdZyi94FPTqrtfer58OZtSOmSJvrZ2sTpUQ2vKLY8sGzmYjBpSH
SLYwNFU6W9yPX9Axwe469K55sLnmQFQMQ5zl0tnNf/jvOacsqCW5cWu/W0eUqOR7
vpGL4crJc4DtcnkESyUyyixlQG4geIrBKaHXaKRvOWhul61bHgqqCH+/qzMkCWLe
PVI2IXNZSkW+RU46v18=
=sUvC
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
