From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-10-04
Date: Fri, 4 Oct 2013 14:16:07 -0400
Message-ID: <20131004181607.GK3142@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TRYliJ5NKNqkz5bu"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51749 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3JDSaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 14:30:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TRYliJ5NKNqkz5bu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of patches intended for the 3.13 stream!

Regarding the Bluetooth bits, Gustavo says:

"The big work here is from Marcel and Johan. They did a lot of work
in the L2CAP, HCI and MGMT layers. The most important ones are the
addition of a new MGMT command to enable/disable LE advertisement
and the introduction of the HCI user channel to allow applications
to get directly and exclusive access to Bluetooth devices."

As to the ath10k bits, Kalle says:

"Bartosz dropped support for qca98xx hw1.0 hardware from ath10k, it's
just too much to support it. Michal added support for the new firmware
interface. Marek fixed WEP in AP and IBSS mode. Rest of the changes are
minor fixes or cleanups."

And also:

"Major changes are:

* throughput improvements including aligning the RX frames correctly and
  optimising HTT layer (Michal)

* remove qca98xx hw1.0 support (Bartosz)

* add support for firmware version 999.999.0.636 (Michal)

* firmware htt statistics support (Kalle)

* fix WEP in AP and IBSS mode (Marek)

* fix a mutex unlock balance in debugfs file (Shafi)

And of course there's a lot of smaller fixes and cleanup."

For the wl12xx bits, Luca says:

"Here are some patches intended for 3.13.  Eliad is upstreaming a bunch
of patches that have been pending in the internal tree.  Mostly bugfixes
and other small improvements."

Along with that...

Arend and friends bring us a batch of brcmfmac updates, Larry Finger
offers some rtlwifi refactoring, and Sujith sends the usual batch of
ath9k updates.  As usual, there are a number of other small updates
=66rom a variety of players as well.

Please let me know if there are any problems!

Thanks,

John

---

The following changes since commit
96f817fedec48b59c9e8b22141cec4e56ad47913:

  tcp: shrink tcp6_timewait_sock by one cache line (2013-10-03
  17:43:39 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git
  for-davem

for you to fetch changes up to
c522ddf1aea71c2cb8ea4876697bc69bdfb5446f:

  Merge branch 'master' of
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
  into for-davem (2013-10-04 13:26:50 -0400)

----------------------------------------------------------------

Albert Pool (1):
      ar5523: Add USB ID of D-Link WUA-2340 rev A1

Amitkumar Karwar (4):
      Bluetooth: btmrvl: add btmrvl_send_sync_cmd() function
      Bluetooth: btmrvl: get rid of struct btmrvl_cmd
      Bluetooth: btmrvl: add setup handler
      Bluetooth: btmrvl: add calibration data download support

Arend van Spriel (2):
      brcmfmac: fix sparse error 'bad constant expression'
      brcmfmac: rework rx path bus interface

Arik Nemtsov (3):
      wlcore: ROC on AP channel before auth reply
      wlcore: re-enable idle handling
      wlcore: always register dummy hardirq

Bartosz Markowski (5):
      ath10k: Remove qca98xx hw1.0 support
      ath10k: update supported FW build version
      ath10k: set the UART baud rate to 19200
      ath10k: remove obsolete INIT STATUS definitions
      ath10k: define ath10k_debug_start/_stop as static inline

Catalin Iacob (1):
      rtlwifi: remove duplicate declarations and macros in headers

Chris Metcalf (1):
      ath9k: mark wmi_event_swba as __packed

Dave Jones (1):
      ath10k: add missing braces to ath10k_pci_tx_pipe_cleanup

DoHyun Pyun (8):
      Bluetooth: Add the definition and structure for Set Reserved LT_ADDR
      Bluetooth: Add the definition and structure for Delete Reserved LT_AD=
DR
      Bluetooth: Add the definition and structure for Set CSB Data
      Bluetooth: Add the structure for Write Sync Train Parameters
      Bluetooth: Add the definition and structure for Set CSB
      Bluetooth: Add the definition for Start Synchronization Train
      Bluetooth: Add the definition and stcuture for Sync Train Complete
      Bluetooth: Add the definition for Slave Page Response Timeout

Eliad Peller (2):
      wlcore: remove unsupported channels
      wlcore: clarify and fix regulatory domain bit translation

Franky Lin (4):
      brcmfmac: sync firmware event list
      brcmfmac: add BCM4339 SDIO interface support
      brcmfmac: add valid core index check in related functions
      brcmfmac: reserve memory for bus layer in sk_buff::cb

Gabor Juhos (1):
      rt2x00: rt2800lib: fix band selection and LNA PE control for RT3593 P=
CIe cards

Gustavo Padovan (1):
      Merge git://git.kernel.org/.../bluetooth/bluetooth

Hante Meuleman (1):
      brcmfmac: Use fw filename and nvram based of devid for sdio.

Janusz Dziedzic (2):
      ath10k: setup peer UAPSD flag correctly
      ath10k: check allocation errors in CE

Jingoo Han (21):
      wireless: ath10k: remove unnecessary pci_set_drvdata()
      mwifiex: Remove casting the return value which is a void pointer
      wireless: ath5k: use dev_get_platdata()
      wireless: ath9k: use dev_get_platdata()
      wireless: brcmfmac: use dev_get_platdata()
      wireless: cw1200: use dev_get_platdata()
      wireless: libertas: use dev_get_platdata()
      wireless: wl1251: use dev_get_platdata()
      wireless: wlcore: use dev_get_platdata()
      wireless: wl12xx: use dev_get_platdata()
      wireless: rtlwifi: remove unnecessary pci_set_drvdata()
      wireless: iwlegacy: remove unnecessary pci_set_drvdata()
      wireless: adm8211: remove unnecessary pci_set_drvdata()
      wireless: airo: remove unnecessary pci_set_drvdata()
      wireless: ath10k: remove unnecessary pci_set_drvdata()
      wireless: wil6210: remove unnecessary pci_set_drvdata()
      wireless: ipw2x00: remove unnecessary pci_set_drvdata()
      wireless: mwl8k: remove unnecessary pci_set_drvdata()
      wireless: orinoco: remove unnecessary pci_set_drvdata()
      wireless: p54pci: remove unnecessary pci_set_drvdata()
      wireless: rtl818x: remove unnecessary pci_set_drvdata()

Johan Hedberg (23):
      Bluetooth: Remove unused event mask struct
      Bluetooth: Fix double error response for l2cap_create_chan_req
      Bluetooth: Fix L2CAP error return used for failed channel lookups
      Bluetooth: Fix L2CAP Disconnect response for unknown CID
      Bluetooth: Fix L2CAP command reject reason
      Bluetooth: Fix sending responses to identified L2CAP response packets
      Bluetooth: Fix responding to invalid L2CAP signaling commands
      Bluetooth: Fix waiting for clearing of BT_SK_SUSPEND flag
      Bluetooth: Add synchronization train parameters reading support
      Bluetooth: Add event mask page 2 setting support
      Bluetooth: Add clarifying comment to bt_sock_wait_state()
      Bluetooth: Clean up socket locking in l2cap_sock_recvmsg
      Bluetooth: Fix busy return for mgmt_set_powered in some cases
      Bluetooth: Move mgmt response convenience functions to a better locat=
ion
      Bluetooth: Use async request for LE enable/disable
      Bluetooth: Add new mgmt setting for LE advertising
      Bluetooth: Add new mgmt_set_advertising command
      Bluetooth: Refactor hci_dev_open to a separate hci_dev_do_open functi=
on
      Bluetooth: Fix workqueue synchronization in hci_dev_open
      Bluetooth: Introduce a new HCI_BREDR_ENABLED flag
      Bluetooth: Add a new mgmt_set_bredr command
      Bluetooth: Fix REJECTED vs NOT_SUPPORTED mgmt responses
      Bluetooth: Fix advertising data flags with disabled BR/EDR

Johannes Berg (1):
      iwlwifi: pcie: fix merge damage

John W. Linville (5):
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge tag 'for-linville-20131001' of git://github.com/kvalo/ath
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kalle Valo (22):
      ath10k: remove un ar_pci->cacheline_sz field
      ath10k: pci: make host_ce_config_wlan[] more readable
      ath10k: make target_ce_config_wlan more readable
      ath10k: remove void pointer from struct ath10k_pci_compl
      ath10k: convert ath10k_pci_reg_read/write32() to take struct ath10k
      ath10k: clean up ath10k_ce_completed_send_next_nolock()
      ath10k: convert ath10k_pci_wake() to return
      ath10k: simplify ath10k_ce_init() wake up handling
      ath10k: check chip id from the soc register during probe
      ath10k: add chip_id file to debugfs
      ath10k: add trace event ath10k_htt_stats
      ath10k: implement ath10k_debug_start/stop()
      ath10k: add htt_stats_enable debugfs file
      ath10k: add BMI log level
      ath10k: rename ATH10K_DBG_CORE to BOOT
      ath10k: cleanup debug messages in core.c
      ath10k: add boot debug messages to pci.c and ce.c
      ath10k: add boot debug messages to htc.c
      ath10k: add boot messages to htt.c
      ath10k: clean mac.c debug messages
      ath10k: print phymode as a string
      ath10k: delete struct ce_sendlist

Kevin Lo (1):
      rt2x00: Fix rf register for RT3070

Larry Finger (16):
      rtlwifi: rtl8192cu: Convert driver to use rtl_process_phyinfo()
      rtlwifi: rtl8192du: Fix smatch errors in /rtl8192de/dm.c
      rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
      rtlwifi: rtl8192cu: Fix smatch warning in rtl8192cu/trx.c
      rtlwifi: rtl8192_common: Fix smatch errors and warnings in rtl8192c/d=
m_common.c
      rtlwifi: Fix smatch warning in pci.c
      rtlwifi: Fix smatch warnings in usb.c
      rtlwifi: rtl8188ee: Fix smatch warning in rtl8188ee/hw.c
      rtlwifi: Remove all remaining references to variable 'noise' in rtl_s=
tats struct
      rtlwifi: Implement a common rtl_phy_scan_operation_backup() routine
      rtlwifi: rtl8192cu: Convert to use new rtl_phy_scan_operation_backup(=
) routine
      rtlwifi: rtl8192ce: Convert driver to use new rtl_phy_scan_operation_=
backup() routine
      rtlwifi: rtl8192c: Remove rtl8192c_phy_scan_operation_backup()
      rtlwifi: rtl8192ce: Convert driver to use new rtl_phy_scan_operation_=
backup() routine
      rtlwifi: rtl8723ae: Convert driver to use new rtl_phy_scan_operation_=
backup() routine
      rtlwifi: rtl8188ee: Convert driver to use new rtl_phy_scan_operation_=
backup() routine

Marcel Holtmann (35):
      Bluetooth: Refactor raw socket filter into more readable code
      Bluetooth: Fix handling of getpeername() for HCI sockets
      Bluetooth: Fix handling of getsockname() for HCI sockets
      Bluetooth: Report error for HCI reset ioctl when device is down
      Bluetooth: Fix error handling for HCI socket options
      Bluetooth: Restrict ioctls to HCI raw channel sockets
      Bluetooth: Introduce user channel flag for HCI devices
      Bluetooth: Introduce new HCI socket channel for user operation
      Bluetooth: Use devname:vhci module alias for virtual HCI driver
      Bluetooth: Add support creating virtual AMP controllers
      Bluetooth: Disable upper layer connections when user channel is active
      Bluetooth: Use GFP_KERNEL when cloning SKB in a workqueue
      Bluetooth: Only schedule raw queue when user channel is active
      Bluetooth: Use only 2 bits for controller type information
      Bluetooth: Replace BDADDR_LOCAL with BDADDR_NONE
      Bluetooth: Provide high speed configuration option
      Bluetooth: Send new settings event when changing high speed option
      Bluetooth: Require CAP_NET_ADMIN for HCI User Channel operation
      Bluetooth: Enable -D__CHECK_ENDIAN__ for sparse by default
      Bluetooth: Restrict disabling of HS when controller is powered off
      Bluetooth: Add management command for setting static address
      Bluetooth: Increment management interface revision
      Bluetooth: Fix memory leak with L2CAP signal channels
      Bluetooth: Restrict SSP setting changes to BR/EDR enabled controllers
      Bluetooth: Allow setting static address even if LE is disabled
      Bluetooth: Restrict loading of link keys to BR/EDR capable controllers
      Bluetooth: Restrict loading of long term keys to LE capable controlle=
rs
      Bluetooth: Allow changing device class when BR/EDR is disabled
      Bluetooth: Fix switch statement order for L2CAP fixed channels
      Bluetooth: Don't copy L2CAP LE signalling to raw sockets
      Bluetooth: SMP packets are only valid on LE connections
      Bluetooth: L2CAP connectionless channels are only valid for BR/EDR
      Bluetooth: Drop packets on ATT fixed channel on BR/EDR
      Bluetooth: Check minimum length of SMP packets
      Bluetooth: Only one command per L2CAP LE signalling is supported

Marek Puzyniak (1):
      ath10k: fix WEP in AP and IBSS mode

Michal Kazior (36):
      ath10k: clean up monitor start code
      ath10k: use sizeof(*var) in kmalloc
      ath10k: clean up PCI completion states
      ath10k: print errcode when CE ring setup fails
      ath10k: fix HTT service setup
      ath10k: implement 802.3 SNAP rx decap type A-MSDU handling
      ath10k: plug possible memory leak in WMI
      ath10k: add support for firmware newer than 636
      ath10k: add support for HTT 3.0
      ath10k: use inline ce_state structure
      ath10k: remove ce_op_state
      ath10k: remove unused ce_attr parameters
      ath10k: rename hif_ce_pipe_info to ath10k_pci_pipe
      ath10k: rename ce_state to ath10k_ce_pipe
      ath10k: rename ce_ring_state to ath10k_ce_ring
      ath10k: prevent CE from looping indefinitely
      ath10k: simplify HTC credits calculation
      ath10k: add HTC TX credits replenishing notification
      ath10k: make WMI commands block by design
      ath10k: simplify HTC command submitting
      ath10k: improve beacon submission latency
      ath10k: remove wmi pending count limit
      ath10k: remove wmi event worker thread
      ath10k: fix tracing build for ath10k_wmi_cmd
      ath10k: fix num_sends_allowed replenishing
      ath10k: use num_pending_tx instead of msdu id bitmap
      ath10k: avoid needless memset on TX path
      ath10k: decouple HTT TX completions
      ath10k: cleanup HTT TX functions
      ath10k: use msdu headroom to store txfrag
      ath10k: report A-MSDU subframes individually
      ath10k: document decap modes
      ath10k: cleanup RX decap handling
      ath10k: fix Native Wifi decap mode RX
      ath10k: align RX frames properly
      ath10k: replenish HTT RX buffers in a tasklet

Mohammed Shafi Shajakhan (1):
      ath10k: Fix mutex unlock balance

Peter Senna Tschudin (2):
      Bluetooth: Fix assignment of 0/1 to bool variables
      wireless: rtlwifi: Replace variable with a break

Sachin Kamat (1):
      net: ath9k: Use NULL instead of false

Stanislaw Gruszka (2):
      rt2800: comment enable radio initialization sequence
      rt2800: add support for radio chip RF3070

Sujith Manoharan (21):
      ath10k: Calculate correct peer PHY mode for VHT
      ath9k: Update initvals for AR9565 1.0
      ath9k: Bypass EEPROM for diversity cap for AR9565
      ath9k: Fix antenna diversity init for AR9565
      ath9k: Use correct RX gain table for AR9565
      ath9k: Add support for AR9565 v1.0.1 LNA diversity
      ath9k: Enable antenna diversity for WB335
      ath9k: Identify CUS252 cards
      ath9k: Identify WB335 Antenna configuration
      ath9k: Fix regulatory compliance for AR9462/AR9565
      ath9k: Add and use initvals for channel 14
      ath9k: Update AR9485 1.1 initvals
      ath9k: Add DELL 1707 to supported card table
      ath9k: Fix calibration for AR9462
      ath9k: Fix issue with parsing malformed CFP IE
      ath9k: Handle abnormal NAV in AP mode
      ath9k: Use bitops for calibration flags
      ath9k: Fix PeakDetect calibration for AR9462
      ath9k: Fix NF calibration for single stream cards
      ath9k: Handle FATAL interrupts correctly
      ath9k: Remove incorrect diversity initialization

Victor Goldenshtein (4):
      wlcore: cleanup scan debug prints
      wlcore: fix unsafe dereference of the wlvif
      wl18xx: fix boot process in high temperature environment
      wl18xx: print new RDL versions during boot

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800usb: add new devices

Yair Shapira (2):
      wlcore: add new plt power-mode: CHIP_AWAKE
      wlcore: disable elp sleep while in plt mode

Zefir Kurtisi (1):
      ath9k: replace snprintf() with scnprintf()

 drivers/bluetooth/Makefile                         |   2 +
 drivers/bluetooth/btmrvl_drv.h                     |  12 +-
 drivers/bluetooth/btmrvl_main.c                    | 269 ++++++----
 drivers/bluetooth/btmrvl_sdio.c                    |  15 +-
 drivers/bluetooth/btmrvl_sdio.h                    |   2 +
 drivers/bluetooth/hci_vhci.c                       | 170 +++++--
 drivers/net/wireless/adm8211.c                     |   1 -
 drivers/net/wireless/airo.c                        |   1 -
 drivers/net/wireless/ath/ar5523/ar5523.c           |   1 +
 drivers/net/wireless/ath/ath10k/bmi.c              |  42 +-
 drivers/net/wireless/ath/ath10k/ce.c               | 382 ++++++--------
 drivers/net/wireless/ath/ath10k/ce.h               | 120 +----
 drivers/net/wireless/ath/ath10k/core.c             |  70 ++-
 drivers/net/wireless/ath/ath10k/core.h             |  35 +-
 drivers/net/wireless/ath/ath10k/debug.c            | 144 +++++-
 drivers/net/wireless/ath/ath10k/debug.h            |  14 +-
 drivers/net/wireless/ath/ath10k/htc.c              | 241 +++------
 drivers/net/wireless/ath/ath10k/htc.h              |   5 +-
 drivers/net/wireless/ath/ath10k/htt.c              |  19 +-
 drivers/net/wireless/ath/ath10k/htt.h              |  13 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           | 314 ++++++------
 drivers/net/wireless/ath/ath10k/htt_tx.c           | 285 ++++++-----
 drivers/net/wireless/ath/ath10k/hw.h               |  25 +-
 drivers/net/wireless/ath/ath10k/mac.c              | 244 +++++----
 drivers/net/wireless/ath/ath10k/pci.c              | 446 +++++++++-------
 drivers/net/wireless/ath/ath10k/pci.h              |  73 ++-
 drivers/net/wireless/ath/ath10k/rx_desc.h          |  24 +-
 drivers/net/wireless/ath/ath10k/trace.h            |  32 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |  67 +--
 drivers/net/wireless/ath/ath10k/txrx.h             |   5 +-
 drivers/net/wireless/ath/ath10k/wmi.c              | 232 ++++-----
 drivers/net/wireless/ath/ath10k/wmi.h              |  71 ++-
 drivers/net/wireless/ath/ath5k/ahb.c               |  15 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   4 +-
 drivers/net/wireless/ath/ath9k/antenna.c           |  36 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   5 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   4 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   3 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  92 +++-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  34 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   2 +
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   5 +
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   6 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  32 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   4 +
 drivers/net/wireless/ath/ath9k/ar9003_rtt.c        |  58 ++-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   | 218 ++++++--
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   |  24 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |  20 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   2 +
 drivers/net/wireless/ath/ath9k/calib.c             |  14 +-
 drivers/net/wireless/ath/ath9k/debug.c             | 446 ++++++++--------
 drivers/net/wireless/ath/ath9k/debug.h             |  12 +-
 drivers/net/wireless/ath/ath9k/dfs_debug.c         |  25 +-
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c  |   2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |  10 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   8 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |  12 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |  22 +-
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     | 456 ++++++++---------
 drivers/net/wireless/ath/ath9k/hw.c                |  59 ++-
 drivers/net/wireless/ath/ath9k/hw.h                |  26 +-
 drivers/net/wireless/ath/ath9k/init.c              |  20 +
 drivers/net/wireless/ath/ath9k/link.c              |  12 +-
 drivers/net/wireless/ath/ath9k/main.c              |  10 +-
 drivers/net/wireless/ath/ath9k/pci.c               | 195 ++++++-
 drivers/net/wireless/ath/ath9k/rc.c                |  32 +-
 drivers/net/wireless/ath/ath9k/wmi.h               |   2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   2 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   1 -
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  13 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   2 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   2 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  38 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 234 +++++----
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |   5 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |   2 +
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |  28 +
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |   8 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   5 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   1 +
 drivers/net/wireless/cw1200/cw1200_spi.c           |   4 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   2 -
 drivers/net/wireless/iwlegacy/3945-mac.c           |   2 -
 drivers/net/wireless/iwlegacy/4965-mac.c           |   2 -
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   8 +-
 drivers/net/wireless/libertas/if_spi.c             |   2 +-
 drivers/net/wireless/mwifiex/pcie.c                |   6 +-
 drivers/net/wireless/mwl8k.c                       |   2 -
 drivers/net/wireless/orinoco/orinoco_nortel.c      |   2 -
 drivers/net/wireless/orinoco/orinoco_pci.c         |   2 -
 drivers/net/wireless/orinoco/orinoco_plx.c         |   2 -
 drivers/net/wireless/orinoco/orinoco_tmd.c         |   2 -
 drivers/net/wireless/p54/p54pci.c                  |   1 -
 drivers/net/wireless/rt2x00/rt2800.h               |   2 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |  49 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |  17 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   1 -
 drivers/net/wireless/rtlwifi/base.c                |  29 ++
 drivers/net/wireless/rtlwifi/base.h                |   2 +-
 drivers/net/wireless/rtlwifi/efuse.c               |  18 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   4 -
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       |  28 -
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |   1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |   3 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |   1 -
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  25 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  30 --
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |   4 -
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |   2 -
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |   4 -
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |  20 -
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       | 187 +------
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   2 -
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |  18 -
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |  28 -
 drivers/net/wireless/rtlwifi/rtl8192de/phy.h       |   4 -
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   1 -
 drivers/net/wireless/rtlwifi/rtl8192se/reg.h       |   5 -
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |  29 --
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |   1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |   3 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |   1 -
 drivers/net/wireless/rtlwifi/usb.c                 |   6 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   2 -
 drivers/net/wireless/ti/wl1251/spi.c               |   2 +-
 drivers/net/wireless/ti/wl12xx/main.c              |   2 +-
 drivers/net/wireless/ti/wl18xx/main.c              |  95 +++-
 drivers/net/wireless/ti/wl18xx/reg.h               |  33 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |  58 ++-
 drivers/net/wireless/ti/wlcore/main.c              | 158 +++++-
 drivers/net/wireless/ti/wlcore/ps.c                |   4 +
 drivers/net/wireless/ti/wlcore/scan.c              |  27 +-
 drivers/net/wireless/ti/wlcore/spi.c               |   2 +-
 drivers/net/wireless/ti/wlcore/testmode.c          |  13 +-
 drivers/net/wireless/ti/wlcore/tx.c                |  27 +-
 drivers/net/wireless/ti/wlcore/tx.h                |   3 +
 drivers/net/wireless/ti/wlcore/wlcore.h            |   2 +
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |  11 +
 include/net/bluetooth/bluetooth.h                  |   5 +-
 include/net/bluetooth/hci.h                        |  81 ++-
 include/net/bluetooth/hci_core.h                   |   2 +-
 include/net/bluetooth/l2cap.h                      |   1 +
 include/net/bluetooth/mgmt.h                       |  11 +
 net/bluetooth/Makefile                             |   2 +
 net/bluetooth/af_bluetooth.c                       |  41 ++
 net/bluetooth/hci_conn.c                           |   4 +
 net/bluetooth/hci_core.c                           | 189 +++++--
 net/bluetooth/hci_event.c                          |  17 +-
 net/bluetooth/hci_sock.c                           | 204 ++++++--
 net/bluetooth/l2cap_core.c                         | 162 +++---
 net/bluetooth/l2cap_sock.c                         |  20 +-
 net/bluetooth/mgmt.c                               | 562 ++++++++++++++++-=
----
 net/bluetooth/rfcomm/sock.c                        |   7 +-
 net/bluetooth/smp.c                                |  15 +-
 162 files changed, 4802 insertions(+), 3186 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--TRYliJ5NKNqkz5bu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSTwXnAAoJEJctW/TcYTgG3SgP/jFjKTBt8MjJPUBU/O1dBRox
Y0IHUzGUHsVTpakp+/+EjUFxvnT2QiyxnZ9rwh9R9HUtD9rpGCql93IkS8AekXHv
B4zkzLeM17egkYHrxEzNWZq5FdBWVCKAP8qH3StYmIatpcBmSrWIihWEKkXaVXmS
LbWx6JTMRribjd9jwVVrmnwuJ5soWQDrcn3Q6uiLik1JOy+uvq1s4nqLc2pYrp8J
Rw7ItU87QyrqokB+g/6igrKyiuIB08Y3YJAq8DnQbrPHYS8zyJ4lyZSy0oHuMVZz
0QfiuhvF68ry+4poJJ+kcZos7HCYufkjJfoTxwDQXEEYGSlPXibrFn1a5iAEh6kj
es6Y52EwzK1C9/+n1g0N+PAFV5Fp1EwsQy10O9nhc8CIDOF0wAzGl8zn1yzKm1BO
n4p3QzJs3IdmLlH8WhVC2sZp/mmAJeZ/HVuj47TpwdzF8WXUzJwdlDPiwR/ppl+p
OvGtdwYg9ZhsMaJCVJOH7hoILtgWDIXCXmDYakFYfMHtvhJHxFIlyYT5dS+hVFCE
raaWQY4UuTDiNKHPv+lJCytMBPxp35EYXbbf/Zk6AmmPNMhVwQU3LioaQaAbJh8j
j+WKGHN2mb5Q0+YM2cFz3DwGjw2T1904AVk8PaaFwov641q80TnpEmrWKxnTjKrx
TgqROu6P46pm3yp/bril
=eYDy
-----END PGP SIGNATURE-----

--TRYliJ5NKNqkz5bu--
