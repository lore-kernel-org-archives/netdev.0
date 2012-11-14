From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-11-14
Date: Wed, 14 Nov 2012 14:05:11 -0500
Message-ID: <20121114190510.GA6128@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34687 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161019Ab2KNTQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 14:16:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 5bdf502dd9c8fd60dddaabfb9a3dc1671302afd2

Dave,

This pull request is intended for the 3.8 stream...

Included is a Bluetooth pull -- Gustavo says:

"These are the Bluetooth bits for inclusion in 3.8, there is basically one =
big
thing here which is the High Speed patches from Andrei, he did a lot of wor=
k on
A2MP and management of AMP devices. The rest are mostly clean up and bug
fixes."

Also included is an NFC pull -- Samuel says:

"With this one we have:

- pn544 p2p support.
- pn544 physical and HCI layers separation. We are getting the pn544 driver
  ready to support non i2c physical layers.
- LLCP SNL (Service Name Lookup). This is the NFC p2p service discovery
  protocol.
- LLCP datagram sockets (connection less) support.
- IDR library usage for NFC devices indexes assignement.
- NFC netlink extension for setting and getting LLCP link characteristics.
- Various code style fixes and cleanups spread over the pn533, LLCP, HCI and
  pn544 code."

There are a couple of mac80211 pulls as well -- Johannes says:

"Please pull my mac80211-next tree to get the first round of new features
for 3.8. We have:
 * finally, the mac80211 multi-channel work
 * scan improvements:
   - bg scan
   - scan flush
   - forced AP scan
 * cfg80211 tracing
 * a bit of new code to allow implementing SAE (secure authentication of
   equals) in managed mode

Along with a few random improvements, features and fixes."

and...

"Please pull from mac80211-next (per below pull request) to get a few
updates. Most important is probably the fix for the WDS regression that
my previous pull request introduced. Other than that, I have some
tracing code, two mesh updates and a change to allow drivers to
calculate the AES CMAC subkeys without having to implement the GF_mulx
operation themselves."

On top of that are the usual updates to iwlwifi, ath9k, rt2x00,
brcmfmac, mwifiex, and a few others here and there.  Of note is the
addition of the ar5523 driver, ported from an original FreeBSD driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit bf0098f22ca7b59e8844ac6882bbae230d34b98d:

  ARM: net: bpf_jit_32: add VLAN instructions for BPF JIT (2012-11-13 18:21=
:10 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 5bdf502dd9c8fd60dddaabfb9a3dc1671302afd2:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-11-14 13:33:43 -0500)

----------------------------------------------------------------

Alan Cox (1):
      brcm80211: remove some truely barftastic code

Amitkumar Karwar (6):
      cfg80211: code rearrangement to avoid forward declarations
      mwifiex: use LOW_PRIORITY scan flag provided in scan request
      mwifiex: abort scan upon interface down
      mwifiex: minor cleanup and a fix in scan semaphore usage
      mwifiex: disable channel filtering for SSID specific scan from user
      Revert "mwifiex: retrieve correct max_power information in reg_notifi=
er handler"

Andrei Emeltchenko (51):
      Bluetooth: Add HCI logical link cmds definitions
      Bluetooth: A2MP: Create amp_mgr global list
      Bluetooth: AMP: Use HCI cmd to Read AMP Info
      Bluetooth: AMP: Use HCI cmd to Read Loc AMP Assoc
      Bluetooth: A2MP: Process Discover Response
      Bluetooth: AMP: Physical link struct and helpers
      Bluetooth: AMP: Remote AMP ctrl definitions
      Bluetooth: AMP: Handle create / disc phylink req
      Bluetooth: A2MP: Process A2MP Getinfo Rsp
      Bluetooth: A2MP: Process A2MP Get AMP Assoc Rsp
      Bluetooth: Choose connection based on capabilities
      Bluetooth: AMP: Add AMP key calculation
      Bluetooth: AMP: Create Physical Link
      Bluetooth: AMP: Write remote AMP Assoc
      Bluetooth: A2MP: Add fallback to normal l2cap init sequence
      Bluetooth: AMP: Process Chan Selected event
      Bluetooth: AMP: Accept Physical Link
      Bluetooth: AMP: Handle Accept phylink command status evt
      Bluetooth: Use %pMR in debug instead of batostr
      Bluetooth: Use %pMR in sprintf/seq_printf instead of batostr
      Bluetooth: Use %pMR instead of baswap in seq_show
      bluetooth: Remove unneeded batostr function
      Bluetooth: Factor out hci_queue_acl
      Bluetooth: Factor out Create Configuration Response
      Bluetooth: Use %zu print specifier for size_t type
      Bluetooth: A2MP: Correct assoc_len size
      Bluetooth: btmrvl: Correct num_block name
      Bluetooth: btmrvl: Use DIV_ROUND_UP macro
      Bluetooth: btmrvl: Fix skb buffer overflow
      Bluetooth: A2MP: Fix potential NULL dereference
      Bluetooth: AMP: Fix possible NULL dereference
      Bluetooth: Fix dereference after NULL check
      Bluetooth: AMP: Factor out amp_ctrl_add
      Bluetooth: AMP: Factor out phylink_add
      Bluetooth: AMP: Use block_mtu for AMP controller
      Bluetooth: Adjust L2CAP Max PDU size for AMP packets
      Bluetooth: L2CAP: Fix using default Flush Timeout for EFS
      Bluetooth: btmrv: Use %*ph specifier instead of print_hex_dump_bytes
      Bluetooth: Allow to set flush timeout
      Bluetooth: AMP: Handle AMP_LINK timeout
      Bluetooth: AMP: Add handle to hci_chan structure
      Bluetooth: AMP: Handle number of compl blocks for AMP_LINK
      Bluetooth: AMP: Handle AMP_LINK connection
      Bluetooth: AMP: Hanlde AMP_LINK case in conn_put
      Bluetooth: AMP: Use Loglink handle in ACL Handle field
      Bluetooth: AMP: Handle complete frames in l2cap
      Bluetooth: AMP: Drop packets when no l2cap conn exist
      Bluetooth: Send EFS Conf Rsp only for BR/EDR chan
      Bluetooth: Zero bredr pointer when chan is deleted
      Bluetooth: AMP: Get amp_mgr reference in HS hci_conn
      mwifiex: Using %*phD instead of print_hex_dump_bytes

Andy Shevchenko (1):
      rtlwifi: rtl8192ce: rtl8192cu: use %*phC to dump small buffers

Antonio Quartulli (1):
      nl/cfg80211: force scan using an AP vif if requested

Arend van Spriel (23):
      wireless: drivers: make use of WLAN_EID_VENDOR_SPECIFIC
      wireless: gelic: make use of WLAN_EID_VENDOR_SPECIFIC
      wireless: remove duplicate enum ieee80211_eid definitions
      brcmfmac: remove 'always false' condition from brcmf_c_mkiovar_bsscfg
      brcmfmac: extend struct brcmf_if with bssidx field
      brcmfmac: rework driver initialization in brcmf_bus_start()
      brcmfmac: use bssidx from struct brcmf_if for bsscfg specific commands
      brcmfmac: add function converting ieee80211_channel to chanspec
      brcmfmac: use struct brcmf_if as interface object for fwil functions
      brcmfmac: change parameter list for send_key_to_dongle()
      brcmfmac: remove brcmf_find_bssidx() function
      brcmfmac: introduce brcmf_cfg80211_vif structure
      brcmfmac: store profile information per virtual interface
      brcmfmac: use vif struct to check_sys_up() function
      brcmfmac: separate connection status from scanning status
      brcmfmac: remove debugfs functionality from wl_cfg80211.c
      brcmfmac: cleanup brcmf_cfg80211_profile structure
      brcmfmac: remove unused enumeration wl_prof_list
      brcmfmac: rename check_sys_up() to check_vif_up()
      brcmfmac: use memset when setting a broadcast mac address
      brcmfmac: add virtual interface support in brcmf_cfg80211_suspend()
      brcmfmac: remove unnecessary macro usage in brcmf_cfg80211_resume()
      brcmfmac: store IEs per virtual interface

Arron Wang (7):
      NFC: Set local gb and DEP registries
      NFC: Pass hardware specific HCI event to driver
      NFC: Handle pn544 continue activation
      NFC: Implement HCI DEP link up and down
      NFC: Implement HCI DEP send and receive data
      NFC: Add pn544 presence check for different targets
      NFC: Fix sparse warnings due to missing static

Ashok Nagarajan (1):
      mac80211: move out the non-statistics variable estab_plinks from mesh=
_stat

Assaf Krauss (1):
      mac80211: expose AES-CMAC subkey calculation

Avinash Patil (2):
      mwifiex: handle extended supported rates IE for AP
      mwifiex: rx path enhancement to derive priv only once

Bala Shanmugam (2):
      ath9k: Set appropriate bit for AR9565 in btc control register
      ath9k: turn off RXIQ calibration while re-calibrating radio

Beni Lev (2):
      cfg80211: add tracing to rdev-ops
      cfg80211: add cfg80211 exported function tracing

Bing Zhao (1):
      mwifiex: use sizeof(array) to print_hex_dump_bytes

Christian Lamparter (3):
      carl9170: handle traps from firmware loader
      carl9170: fix spurious transmissions in sniffer mode
      carl9170: split up carl9170_handle_mpdu

Dan Carpenter (3):
      orinoco_usb: clean up some signedness issues
      brcmfmac: Using zero instead of NULL
      ar5523: make buffer size variable unsigned

Dmitry Kasatkin (1):
      Bluetooth: Add function to derive AMP key using hmac

Emmanuel Grumbach (5):
      iwlwifi: wipe out the status of the SCD when we disable a queue
      iwlwifi: use the new macro for the SCD Q STTS bits
      iwlwifi: first deactivate a queue, then wipe out its data
      iwlwifi: don't print the Intel banner twice
      iwlwifi: don't WARN when a non empty queue is disabled

Eric Lapuyade (2):
      NFC: HCI check presence must not fail when driver doesn't support it
      NFC: Separate pn544 hci driver in HW dependant and independant parts

Franky Lin (2):
      brcmfmac: fix sparse warnings
      brcmfmac: streamline header parse code of sdio glom read

Gustavo Padovan (9):
      Bluetooth: Fix two warnings in BT_DBG
      Bluetooth: Fix L2CAP coding style
      Bluetooth: Remove GFP_ATOMIC usage from l2cap_core.c
      Bluetooth: use l2cap_chan_set_err()
      Bluetooth: Use locked l2cap_state_change()
      Bluetooth: Call ops->teardown() without checking for NULL
      Bluetooth: Move bt_accept_enqueue() to l2cap_sock.c
      Bluetooth: Add chan->ops->defer()
      Bluetooth: Rename __l2cap_connect() to l2cap_connect()

Hante Meuleman (6):
      brcmfmac: refactor firmware interface layer.
      brcmfmac: remove unused iswl variable.
      brcmfmac: change testmode command to use new firmware interface layer
      brcmfmac: remove redundant function brcmf_c_mkiovar_bsscfg
      brcmfmac: clean usb download code.
      brcmfmac: use fwil for default configuration setup.

Hauke Mehrtens (14):
      bcma: just do the necessary things in early register on SoCs
      bcma: init sprom struct earlier
      bcma: mark pflash as present when available
      bcma: add and use constants for the flash windows
      bcma: mark nflash if it is the boot flash
      bcma: extract drv_cc in bcma_core_mips_flash_detect()
      bcma: add some more flash chips for serial flash
      ssb: move parallel flash config into an own struct
      ssb: add attribute to indicate a parallel flash is available
      bcma: use fallback sprom if sprom on card was not valid
      bcma: add an extra pcie core struct
      bcma: do not initialize deactivated PCIe cores
      ssb: add PCI ID 0x4350
      ssb: handle BCM43222 in pmu code.

Hila Gonen (1):
      cfg80211: add wrappers for registered_device_ops

Jefferson Delfes (1):
      Bluetooth: Force the process of unpair command if disconnect failed

Johannes Berg (16):
      iwlwifi: improve oversized command warning
      iwlwifi: make data frame tracing optional
      iwlwifi: remove unused variables
      mac80211: check channel context methods
      mac80211: track whether to use channel contexts
      mac80211: use channel contexts
      mac80211: track needed RX chains for channel contexts
      mac80211: add channel context iterator
      wireless: use OR operation to set wiphy features
      mac80211: remove unimplemented mesh vendor sync
      mac80211: remove some unused code
      mac80211: use __printf attribute in debugfs
      mac80211: fix WDS channel context test
      cfg80211: add tracing for P2P Device start/stop
      mac80211: use non-atomic bitmap operation for local variable
      mac80211: complete bss_info tracing

John W. Linville (8):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth=
-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge tag 'nfc-next-3.8-1' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (4):
      mac80211: Take status code as parameter to ieee80211_send_auth
      mac80211: Add debug print on unexpect authentication state
      cfg80211: Allow user space to specify non-IEs to SAE Authentication
      mac80211: Allow station mode SAE to be implemented in user space

Kees Cook (3):
      NFC: Remove CONFIG_EXPERIMENTAL
      NFC: Remove CONFIG_EXPERIMENTAL from the LLCP Makefile
      NFC: Remove CONFIG_EXPERIMENTAL from the NCI Makefile

Larry Finger (2):
      rtlwifi: rtl8192c: rtl8192ce: Add support for B-CUT version of RTL818=
8CE
      rtlwifi: rtl8192c: rtl8192ce: rtl8192cu: rtl8192se: rtl8192de: Shorte=
n some variable names

Mahesh Palivela (3):
      ieee80211: Rename VHT cap struct
      mac80211: VHT peer STA caps
      {nl,cfg}80211: Peer STA VHT caps

Marco Porsch (2):
      mac80211: fix copy-paste typo in Kconfig
      mac80211: make client powersave independent of interface type

Mat Martineau (2):
      Bluetooth: Process create response and connect response identically
      Bluetooth: Factor out common L2CAP connection code

Michal Kazior (4):
      mac80211: introduce channel context skeleton code
      mac80211: introduce new ieee80211_ops
      mac80211: use channel context notifications
      mac80211: reuse channels for channel contexts

Mohammed Shafi Shajakhan (5):
      mac80211: Use appropriate debug wrapper
      ath9k: Ensure we set FTP_STOMP_LOW weight when WLAN is idle
      ath9k_htc: Advertise interface combinations supported
      ath9k_htc: Remove interface combination specific checks
      ath9k: Advertize beacon_int_infra_match

Peter Senna Tschudin (1):
      ath/ath9k/ar9003_eeprom.c: Remove semicolon after if

Pontus Fuchs (1):
      ar5523: Add new driver

Rajkumar Manoharan (19):
      ath9k: perform ANI cycle in idle state
      ath9k: Send WLAN channel info to BT
      ath9k: Add concurrent WLAN and BT tx support for MCI based chips
      ath9k: fill channel mode in caldata
      ath9k: adjust WLAN and BT concurrent transmission
      ath9k_hw: Enable OSLA hw fix for AR9565
      ath9k_hw: Fix selfgen chainmask for 9565
      ath9k_hw: Disable MCI stat counter by default for AR9565
      ath9k_hw: Fix frequent BT rx recovery
      ath9k_hw: Fix max rx rate drop for AR9565
      ath9k_hw: Configure new switch table for AR9565 BTCOEX
      ath9k_hw: Set default MCI config for AR9565
      ath9k: adjust duty cycle for FTP profile for AR9565
      ath9k: Add new BT profile info A2DP_Voice
      ath9k_hw: Enable hw PLL power save for AR9462
      ath9k_hw: Enable hw PLL power save for AR9565
      ath9k_hw: Fix concurrent tx on lower tx power
      ath9k_hw: validate MCI stuck after RTC wakeup
      ath9k: Dump BTCOEX tuning parameters

Rami Rosen (2):
      Bluetooth: remove unused member of hci_dev.
      mac80211: remove duplicate check in ieee80211_rx_mgmt_beacon

Sam Leffler (4):
      {nl,cfg}80211: add a flags word to scan requests
      cfg80211: add scan flag to indicate its priority
      cfg80211: add support for flushing old scan results
      mac80211: add support for tx to abort low priority scan requests

Samuel Ortiz (14):
      NFC: Avoid falling back to SYMM when sk is NULL
      NFC: Use llcp_allocate_pdu to build the DISC frames
      NFC: Add SNL frame building routine
      NFC: Initial SNL support
      NFC: Reserve LLCP ssap when replying to an SNL frame
      NFC: Check for connection less sockets when looking for a service name
      NFC: Keep connection less bound sockets alive when DEP link goes down
      NFC: Handle LLCP UI frames
      NFC: Forward LLCP datagrams to userspace
      NFC: UI frame sending routine implementation
      NFC: Implement LLCP connection less Tx path
      NFC: Return NULL when no LLCP socket for a dsap,ssap couple is found
      NFC: Use IDR library to assing NFC devices IDs
      NFC: Purge LLCP socket Tx queues when being disconnected

Sasha Levin (1):
      Bluetooth: don't attempt to free a channel that wasn't created

Stanislaw Gruszka (7):
      rt2800: use BBP_R1 for setting tx power
      rt2800: limit TX_PWR_CFG_ values to 0xc
      rt2800: compensate tx power also for non 11b rates on 2GHz
      rt2800: use eeprom OFDM 6M TX power as criterion
      rt2800: pass channel pointer to rt2800_config_txpower
      rt2800: allow to reduce tx power on devices not exporting power limit
      rt2800: comment tx power settings

Sujith Manoharan (4):
      mac80211: Notify new IBSS network creation
      cfg80211: Disallow HT/WEP in IBSS mode
      ath9k: Use a helper routine for MCI/FTP tuning
      ath9k: Fix BT_OP_SCAN usage

Sven Eckelmann (1):
      ath_hw: Use common REG_WRITE parameter order

Syam Sidhardhan (2):
      Bluetooth: Use __constant modifier for L2CAP SMP CID
      Bluetooth: Use __constant modifier for RFCOMM PSM

Szymon Janc (7):
      NFC: Use NFC_MAX_GT_LEN to check len in nci_set_local_general_bytes
      NFC: Remove not needed local variable in nci_set_local_general_bytes
      NFC: Remove unneeded LLCP function return calls
      NFC: Small nfc_hci_create_pipe refactoring
      NFC: Fix not propagating return code in nfc_hci_clear_all_pipes
      NFC: Fix style issues with logical operations
      NFC: Fix some code style and whitespace issues

Thierry Escande (3):
      NFC: Set rf_mode to NFC_RF_NONE where necessary
      NFC: Add NFC_ATTR_RF_MODE when sending device netlink properties
      NFC: Extend netlink interface for LTO, RW, and MIUX parameters support

Thomas Pedersen (1):
      mac80211: mesh STAs only process mesh beacons

Waldemar Rymarkiewicz (2):
      NFC: pn533: Fix in/out frame buffer allocation
      NFC: pn533: Remove unused arg parameter

Yuanhan Liu (1):
      bcma: suspend/resume callbacks should be conditionally compiled on CO=
NFIG_PM_SLEEP

 MAINTAINERS                                        |    6 +
 arch/mips/bcm47xx/nvram.c                          |    4 +-
 arch/mips/bcm47xx/wgt634u.c                        |    8 +-
 drivers/bcma/driver_chipcommon.c                   |   23 +-
 drivers/bcma/driver_chipcommon_nflash.c            |    3 +
 drivers/bcma/driver_chipcommon_pmu.c               |    5 +-
 drivers/bcma/driver_chipcommon_sflash.c            |   35 +-
 drivers/bcma/driver_mips.c                         |   48 +-
 drivers/bcma/driver_pci_host.c                     |   14 +-
 drivers/bcma/host_pci.c                            |    6 +-
 drivers/bcma/main.c                                |   54 +-
 drivers/bcma/sprom.c                               |    5 +-
 drivers/bluetooth/btmrvl_sdio.c                    |   28 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |    4 +-
 drivers/net/wireless/airo.c                        |    2 +-
 drivers/net/wireless/ath/Kconfig                   |    1 +
 drivers/net/wireless/ath/Makefile                  |    1 +
 drivers/net/wireless/ath/ar5523/Kconfig            |    7 +
 drivers/net/wireless/ath/ar5523/Makefile           |    1 +
 drivers/net/wireless/ath/ar5523/ar5523.c           | 1806 +++++++++++++++
 drivers/net/wireless/ath/ar5523/ar5523.h           |  152 ++
 drivers/net/wireless/ath/ar5523/ar5523_hw.h        |  431 ++++
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |    5 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   22 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   70 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    1 +
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    9 +
 drivers/net/wireless/ath/ath9k/btcoex.c            |   62 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    7 +
 drivers/net/wireless/ath/ath9k/calib.c             |    1 +
 drivers/net/wireless/ath/ath9k/debug.c             |   34 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |  110 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   17 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   20 -
 drivers/net/wireless/ath/ath9k/hw.c                |    6 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +
 drivers/net/wireless/ath/ath9k/init.c              |    1 +
 drivers/net/wireless/ath/ath9k/link.c              |   12 +-
 drivers/net/wireless/ath/ath9k/main.c              |   12 +-
 drivers/net/wireless/ath/ath9k/mci.c               |  171 +-
 drivers/net/wireless/ath/ath9k/mci.h               |   36 +
 drivers/net/wireless/ath/ath9k/recv.c              |    5 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   13 +-
 drivers/net/wireless/ath/ath9k/wow.c               |    2 +-
 drivers/net/wireless/ath/carl9170/mac.c            |   21 +-
 drivers/net/wireless/ath/carl9170/rx.c             |   51 +-
 drivers/net/wireless/ath/carl9170/usb.c            |    7 +
 drivers/net/wireless/ath/hw.c                      |   20 +-
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   73 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |    3 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |   29 -
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  453 ++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |    3 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  198 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  174 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |  336 +++
 drivers/net/wireless/brcm80211/brcmfmac/fwil.h     |   39 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   41 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 1218 +++++------
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |  145 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    2 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c      |    2 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |    6 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   95 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    3 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    8 +
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    3 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |    9 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   18 +-
 drivers/net/wireless/libertas/mesh.c               |    2 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |    8 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   20 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   21 +-
 drivers/net/wireless/mwifiex/init.c                |   19 +-
 drivers/net/wireless/mwifiex/main.c                |    8 +
 drivers/net/wireless/mwifiex/main.h                |   13 +-
 drivers/net/wireless/mwifiex/scan.c                |   55 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    4 -
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    4 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |   26 +-
 drivers/net/wireless/mwifiex/txrx.c                |   10 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   11 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |   17 +-
 drivers/net/wireless/mwifiex/util.c                |   19 +-
 drivers/net/wireless/orinoco/main.h                |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    9 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  100 +-
 drivers/net/wireless/rtlwifi/cam.c                 |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  227 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   88 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |    3 +
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   93 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |   23 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   46 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   25 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   22 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   95 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   65 +-
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   39 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   89 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   64 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   21 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   53 +-
 drivers/nfc/Makefile                               |    2 +-
 drivers/nfc/pn533.c                                |   18 +-
 drivers/nfc/pn544/Makefile                         |    7 +
 drivers/nfc/pn544/i2c.c                            |  500 +++++
 drivers/nfc/{pn544_hci.c =3D> pn544/pn544.c}         |  679 +++---
 drivers/nfc/pn544/pn544.h                          |   32 +
 drivers/ssb/b43_pci_bridge.c                       |    1 +
 drivers/ssb/driver_chipcommon_pmu.c                |    3 +
 drivers/ssb/driver_mipscore.c                      |   16 +-
 include/linux/bcma/bcma.h                          |    2 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |    5 +
 include/linux/bcma/bcma_driver_mips.h              |    3 +
 include/linux/bcma/bcma_regs.h                     |    5 +-
 include/linux/ieee80211.h                          |   47 +-
 include/linux/ssb/ssb_driver_mips.h                |   10 +-
 include/net/bluetooth/a2mp.h                       |   24 +-
 include/net/bluetooth/amp.h                        |   50 +
 include/net/bluetooth/bluetooth.h                  |    1 -
 include/net/bluetooth/hci.h                        |   40 +-
 include/net/bluetooth/hci_core.h                   |   48 +-
 include/net/bluetooth/l2cap.h                      |   14 +-
 include/net/cfg80211.h                             |   14 +
 include/net/mac80211.h                             |  114 +-
 include/net/nfc/hci.h                              |   18 +-
 include/net/nfc/nfc.h                              |    2 +-
 include/uapi/linux/nfc.h                           |   15 +
 include/uapi/linux/nl80211.h                       |   48 +
 net/bluetooth/Kconfig                              |    1 +
 net/bluetooth/Makefile                             |    2 +-
 net/bluetooth/a2mp.c                               |  459 +++-
 net/bluetooth/af_bluetooth.c                       |   10 +-
 net/bluetooth/amp.c                                |  374 ++++
 net/bluetooth/bnep/core.c                          |    3 +-
 net/bluetooth/cmtp/core.c                          |    2 +-
 net/bluetooth/hci_conn.c                           |   70 +-
 net/bluetooth/hci_core.c                           |   65 +-
 net/bluetooth/hci_event.c                          |  167 +-
 net/bluetooth/hci_sysfs.c                          |   10 +-
 net/bluetooth/hidp/core.c                          |    8 +-
 net/bluetooth/l2cap_core.c                         |  503 +++--
 net/bluetooth/l2cap_sock.c                         |   89 +-
 net/bluetooth/lib.c                                |   14 -
 net/bluetooth/mgmt.c                               |    5 +-
 net/bluetooth/rfcomm/core.c                        |   19 +-
 net/bluetooth/rfcomm/sock.c                        |    9 +-
 net/bluetooth/rfcomm/tty.c                         |    6 +-
 net/bluetooth/sco.c                                |   12 +-
 net/bluetooth/smp.c                                |    2 +-
 net/mac80211/Kconfig                               |    2 +-
 net/mac80211/Makefile                              |    1 +
 net/mac80211/aes_cmac.c                            |   17 +
 net/mac80211/cfg.c                                 |  284 +--
 net/mac80211/chan.c                                |  455 +++-
 net/mac80211/debugfs.h                             |    6 +-
 net/mac80211/debugfs_netdev.c                      |   10 +-
 net/mac80211/driver-ops.h                          |   65 +
 net/mac80211/ibss.c                                |   88 +-
 net/mac80211/ieee80211_i.h                         |  171 +-
 net/mac80211/iface.c                               |   44 +-
 net/mac80211/main.c                                |  105 +-
 net/mac80211/mesh.c                                |   52 +-
 net/mac80211/mesh.h                                |    4 +-
 net/mac80211/mesh_plink.c                          |   14 +-
 net/mac80211/mesh_sync.c                           |   55 +-
 net/mac80211/mlme.c                                |  228 +-
 net/mac80211/offchannel.c                          |    9 +-
 net/mac80211/pm.c                                  |    2 +
 net/mac80211/rate.h                                |   12 +-
 net/mac80211/rx.c                                  |   32 +-
 net/mac80211/scan.c                                |   29 +-
 net/mac80211/sta_info.c                            |   59 +-
 net/mac80211/status.c                              |   15 +-
 net/mac80211/trace.h                               |  146 +-
 net/mac80211/tx.c                                  |  281 ++-
 net/mac80211/util.c                                |  145 +-
 net/mac80211/vht.c                                 |   35 +
 net/nfc/Kconfig                                    |    4 +-
 net/nfc/core.c                                     |   33 +-
 net/nfc/hci/command.c                              |   24 +-
 net/nfc/hci/core.c                                 |   71 +-
 net/nfc/hci/llc.c                                  |    2 +-
 net/nfc/hci/llc_shdlc.c                            |    7 +-
 net/nfc/llcp/Kconfig                               |    4 +-
 net/nfc/llcp/commands.c                            |  120 +-
 net/nfc/llcp/llcp.c                                |  226 +-
 net/nfc/llcp/llcp.h                                |   13 +
 net/nfc/llcp/sock.c                                |   42 +-
 net/nfc/nci/Kconfig                                |    4 +-
 net/nfc/nci/core.c                                 |   29 +-
 net/nfc/netlink.c                                  |  157 +-
 net/nfc/nfc.h                                      |    6 +
 net/nfc/rawsock.c                                  |    1 -
 net/wireless/Makefile                              |    4 +-
 net/wireless/ap.c                                  |    3 +-
 net/wireless/chan.c                                |   16 +-
 net/wireless/core.c                                |   16 +-
 net/wireless/core.h                                |    6 +-
 net/wireless/ethtool.c                             |   15 +-
 net/wireless/ibss.c                                |    9 +-
 net/wireless/mesh.c                                |   11 +-
 net/wireless/mlme.c                                |   92 +-
 net/wireless/nl80211.c                             |  259 ++-
 net/wireless/rdev-ops.h                            |  879 ++++++++
 net/wireless/scan.c                                |  138 +-
 net/wireless/sme.c                                 |   12 +-
 net/wireless/sysfs.c                               |    5 +-
 net/wireless/trace.c                               |    7 +
 net/wireless/trace.h                               | 2296 ++++++++++++++++=
++++
 net/wireless/util.c                                |   14 +-
 net/wireless/wext-compat.c                         |   48 +-
 233 files changed, 13900 insertions(+), 4289 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ar5523/Kconfig
 create mode 100644 drivers/net/wireless/ath/ar5523/Makefile
 create mode 100644 drivers/net/wireless/ath/ar5523/ar5523.c
 create mode 100644 drivers/net/wireless/ath/ar5523/ar5523.h
 create mode 100644 drivers/net/wireless/ath/ar5523/ar5523_hw.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/fwil.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/fwil.h
 create mode 100644 drivers/nfc/pn544/Makefile
 create mode 100644 drivers/nfc/pn544/i2c.c
 rename drivers/nfc/{pn544_hci.c =3D> pn544/pn544.c} (58%)
 create mode 100644 drivers/nfc/pn544/pn544.h
 create mode 100644 include/net/bluetooth/amp.h
 create mode 100644 net/bluetooth/amp.c
 create mode 100644 net/mac80211/vht.c
 create mode 100644 net/wireless/rdev-ops.h
 create mode 100644 net/wireless/trace.c
 create mode 100644 net/wireless/trace.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQo+tmAAoJEJctW/TcYTgGzf8P/1vo4qwpullM/B+Cu0PTdiF2
OblPCPkSh24SCjhtzWaDQ9u2v5PjQMzvdooxg5RafYVcDNzkZBszXxGuZj/oixgw
P+2orNCyOxN3582eELGryVFlUnBe1wDZGnuIF386XGoPxQEHbMRd9cV5yMKbTZ+M
QU04E/cLdIy3OR0W3EWz/fC1G3kzFj2fqPFy0w90r2Y8HLJi42Z+aLdHkqAQqOpw
Xq3rN9D4P65jtJ+wRI4hTi9GhN4pk4Q+o60I8oFq0/2JtWL3yf/6eZAMBJ23Q1dw
Ep0W/8o+PFRH+JnwdkUiRhbJ6vYWqN6w5AJYrKbp8DgkNe6MIRMBdtFg5uFGtyZu
rLRosrs+DGgSkhZoxvZ1713hkoOOyUNvEFLkqgRhIMtCEAcrL0181Trx05tNvBRp
J58h3VA4wYdeFwHVHi67l8yf2ltzT8i/qhaJg0gNCv6YpCQk4/UyhVz08ME+3hXC
ZlcCASp7VJAPzZYXRzU6PM8xGVzbYRITUWxPS154nu0VF1c/QhMFKHVrluOoyMc2
2hqcxFVp8JcsFE55qY82+ZwmTZt/Sava1p3q4d4qP0ZyjdSMhrm9GaK1Zm/MO+UK
1q5lG+cc3TlZR4JZwAjpyCz+AA1YZXqA/x+3horTBZqKPsDZsF/wE6etiHqoawGI
YfTohdMK0puRfWDN+cx0
=csr8
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--
