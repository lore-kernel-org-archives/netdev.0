From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-10-03
Date: Fri, 3 Oct 2014 14:01:52 -0400
Message-ID: <20141003180151.GE27414@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dTy3Mrz/UPE2dbVg"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dTy3Mrz/UPE2dbVg
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull tihs batch of updates intended for the 3.18 stream!

For the iwlwifi bits, Emmanuel says:

"I have here a few things that depend on the latest mac80211's changes:
RRM, TPC, Quiet Period etc...  Eyal keeps improving our rate control
and we have a new device ID. This last patch should probably have
gone to wireless.git, but at that stage, I preferred to send it to
-next and CC stable."

For (most of) the Atheros bits, Kalle says:

"The only new feature is testmode support from me. Ben added a new method
to crash the firmware with an assert for debug purposes. As usual, we
have lots of smaller fixes from Michal. Matteo fixed a Kconfig
dependency with debugfs. I fixed some warnings recently added to
checkpatch."

For the NFC bits, Samuel says:

"We've had major updates for TI and ST Microelectronics drivers, and a
few NCI related changes.

For TI's trf7970a driver:

- Target mode support for trf7970a
- Suspend/resume support for trf7970a
- DT properties additions to handle different quirks
- A bunch of fixes for smartphone IOP related issues

For ST Microelectronics' ST21NFCA and ST21NFCB drivers:

- ISO15693 support for st21nfcb
- checkpatch and sparse related warning fixes
- Code cleanups and a few minor fixes

Finally, Marvell added ISO15693 support to the NCI stack, together with a
couple of NCI fixes."

For the Bluetooth bits, Johan says:

"This 3.18 pull request replaces the one I did on Monday ("bluetooth-next
2014-09-22", which hasn't been pulled yet). The additions since the last
request are:

 - SCO connection fix for devices not supporting eSCO
 - Cleanups regarding the SCO establishment logic
 - Remove unnecessary return value from logging functions
 - Header compression fix for 6lowpan
 - Cleanups to the ieee802154/mrf24j40 driver

Here's a copy from previous request that this one replaces:

'
Here are some more patches for 3.18. They include various fixes to the
btusb HCI driver, a fix for LE SMP, as well as adding Jukka to the
MAINTAINERS file for generic 6LoWPAN (as requested by Alexander Aring).

I've held on to this pull request a bit since we were waiting for a SCO
related fix to get sorted out first. However, since the merge window is
getting closer I decided not to wait for it. If we do get the fix sorted
out there'll probably be a second small pull request later this week.
'"

And,

"Unless 3.17 gets delayed this will probably be our last -next pull request=
 for
3.18. We've got:

  - New Marvell hardware supportr
  - Multicast support for 6lowpan
  - Several of 6lowpan fixes & cleanups
  - Fix for a (false-positive) lockdep warning in L2CAP
  - Minor btusb cleanup"

On top of all that comes the usual sort of updates to ath5k, ath9k,
ath10k, brcmfmac, mwifiex, and wil6210.  This time around there are
also a number of rtlwifi updates to enable some new hardware and
to reconcile the in-kernel drivers with some newer releases of the
Realtek vendor drivers.  Also of note is some device tree work for
the bcma bus.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 7a0a260a0f6ff0226c33cf28a5cc26711ab0ae5f:

  ath9k: enable ext channel pulse detection (2014-09-16 16:18:42 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-10-02

for you to fetch changes up to 3f08e47291879fb047d7d4464d2beaedfea4eb63:

  rtlwifi: Fix static checker warnings for various drivers (2014-10-02 14:2=
6:32 -0400)

----------------------------------------------------------------
Alexander Bondar (1):
      iwlwifi: mvm: Allow schedule scan while connected

Amitkumar Karwar (4):
      Bluetooth: btmrvl: rename definitions from 88xx to 8897
      Bluetooth: btusb: remove redundant lock variable
      mwifiex: error path handling in pcie firmware dump
      mwifiex: add more dump information for PCIe interface

Andrei Otcheretianski (3):
      iwlwifi: mvm: Update TX power in TPC reports
      iwlwifi: mvm: Set RRM_ENABLED bit in scan commands
      iwlwifi: mvm: Refactor and fix max probe len computation

Arend van Spriel (1):
      brcmfmac: assure P2P discovery is disabled when setting P2P_DEVICE ma=
c address

Assaf Krauss (1):
      iwlwifi: mvm: Announce Quiet Period support

Avinash Patil (6):
      mwifiex: ensure user_scan_in not NULL while setting scan channel gap
      mwifiex: fix soft lockup during iperf UDP RX
      mwifiex: do not decrement rx_pending count twice
      mwifiex: remove unnecessary rx_q lock
      mwifiex: few more register offset entries for sdio card structure
      mwifiex: add support for SD8887 chipset

Avri Altman (1):
      iwlwifi: mvm: prepare for scheduler config command

Axel Lin (1):
      NFC: st21nfca: Convert to use devm_gpio_request_one

Ben Greear (1):
      ath10k: support firmware crash-by-assert

Bernhard Thaler (1):
      Bluetooth: Check for SCO type before setting retransmission effort

Christophe Ricard (29):
      NFC: st21nfca: Fix sparse: cast to restricted __be32
      NFC: st21nfca: Fix scripts/checkpatch.pl warnings "Missing a blank li=
ne after declarations"
      NFC: st21nfcb: Fix scripts/checkpatch.pl error "code indent should us=
e tabs where possible"
      NFC: st21nfcb: Convert to use devm_gpio_request_one
      NFC: st21nfcb: Remove double assignment of .owner in struct device_dr=
iver
      NFC: st21nfcb: Remove useless new line in nfc_err call
      NFC: st21nfcb: Remove inappropriate kfree on a previously devm_kzallo=
c pointer
      NFC: st21nfca: Fix logic when setting session_id
      NFC: st21nfca: Remove useless new line in nfc_err call
      NFC: st21nfca: Change nfcid3 generation
      NFC: st21nfca: Remove useless err =3D=3D 0 condition
      NFC: st21nfca: Remove useless IS_ERR(skb) conditions
      NFC: st21nfca: Add condition to make sure atr_req->length is valid.
      NFC: st21nfcb: Fix logic when running into i2c read retry
      NFC: st21nfca: Clean up st21nfca.h macros
      NFC: st21nfca: Clean up macros alignment
      NFC: st21nfca: fix "WARNING: else is not generally useful after a bre=
ak or return"
      NFC: st21nfcb: Remove useless headers
      NFC: st21nfca: Fix few coding style issue
      NFC: st21nfca: Fix potential skb leaks in NFC-DEP code
      NFC: st21nfca: Fix recursive fault when doing p2p in target mode.
      NFC: dts: st21nfcb_i2c: Fix invalid interrupts polarity.
      NFC: st21nfcb: Fix improper management of -EREMOTEIO error code.
      NFC: st21nfcb: Fix improper ndlc T2 management
      NFC: nci: Add support for proprietary RF Protocols
      NFC: st21nfcb: Add ISO15693 Reader/Writer support
      NFC: st21nfcb: remove error output
      NFC: st21nfca: ERR_PTR vs NULL fix
      NFC: st21nfca: Fix potential double kfree_skb error

Emil Goode (1):
      NFC: st21nfca: Remove double assignment of .owner in struct device_dr=
iver

Emmanuel Grumbach (1):
      iwlwifi: mvm: disable BT Co-running by default

Eyal Shapira (5):
      iwlwifi: mvm: choose an initial tx rate based on rssi conditions
      iwlwifi: mvm: rs: refactor to allow direct rs updating
      iwlwifi: mvm: limit aggregation size in low latency to 6
      iwlwifi: mvm: report all BA notifs to RS
      iwlwifi: mvm: rs: fix logic in case of multiple TIDs

Felix Fietkau (7):
      ath5k: add missing include for debug code
      ath9k: use ah->get_mac_revision for all SoC devices if available
      ath9k_hw: disable hardware ad-hoc flag on ar934x rev 3
      Revert "ath9k_hw: reduce ANI firstep range for older chips"
      ath9k_hw: reduce ANI spur immunity setting on HT40 extension channel
      ath9k_hw: fix PLL clock initialization for newer SoC
      ath9k: fix getting tx duration for dynack

Hante Meuleman (5):
      brcmfmac: On scan timeout do send received results.
      brcmfmac: Fix sign issue with IOCTL return code in msgbuf.
      brcmfmac: Avoid usage of GFP_ATOMIC.
      brcmfmac: Fix crash on cleanup.
      brcmfmac: Add wowl support for PCIE devices.

Hauke Mehrtens (1):
      bcma: register bcma as device tree driver

Ido Yariv (1):
      iwlwifi: mvm: support cloned tx skbs

Joe Perches (1):
      Bluetooth: Convert bt_<level> logging functions to return void

Johan Hedberg (6):
      Bluetooth: btusb: Use GFP_KERNEL in btusb_send_frame()
      Bluetooth: Fix setting correct security level when initiating SMP
      Bluetooth: Fix reason code used for rejecting SCO connections
      Bluetooth: Add retransmission effort into SCO parameter table
      Bluetooth: Rename sco_param_wideband table to esco_param_msbc
      Bluetooth: Fix lockdep warning with l2cap_chan_connect

John W. Linville (5):
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge tag 'nfc-next-3.18-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next

Jukka Rissanen (8):
      MAINTAINERS: add maintainer for generic 6LoWPAN
      Bluetooth: 6lowpan: Make sure skb exists before accessing it
      Bluetooth: 6lowpan: Ensure header compression does not corrupt IPv6 h=
eader
      Bluetooth: 6lowpan: Enable multicast support
      Bluetooth: 6lowpan: Memory leak as the skb is not freed
      Bluetooth: 6lowpan: Avoid memory leak if memory allocation fails
      Bluetooth: 6lowpan: Return EAGAIN error also for multicast packets
      Bluetooth: 6lowpan: Check transmit errors for multicast packets

Kalle Valo (12):
      ath10k: make ath10k_wmi_cmd_send() public
      ath10k: add testmode
      ath10k: fix parenthesis alignment warning in ath10k_htt_rx_alloc()
      ath10k: fix checkpatch warnings about parenthesis alignment
      ath10k: fix use of multiple blank lines
      ath10k: fix missing a blank line after declarations
      ath10k: fix space after a cast style errors
      ath10k: don't use return on void functions
      ath10k: else is not generally useful after a break or return
      ath10k: miscellaneous checkpatch fixes
      ath10k: reformat help text in ath10k_read_simulate_fw_crash()
      ath10k: use ether_addr_copy()

Larry Finger (21):
      rtlwifi: btcoexist: Fix Smatch warning
      rtlwifi: Remove extra workqueue for enter/leave power state
      rtlwifi: rtl_pci: Start modification for new drivers
      rtlwifi: Modify core.c for new drivers
      rtlwifi: Modify base.{c,h} for new drivers
      rtlwifi: Modify cam.{c,h} and efuse.{c,h} for new drivers
      rtlwifi: Update power-save routines for 062814 driver
      rtlwifi: Finish modifying core routines for new drivers
      rtlwifi: rtl8188ee: Update driver to match Realtek release of 06282014
      rtlwifi: rtl8821ae: Move driver from staging to regular tree
      rtlwifi: Fix problems with building an allyesconfig
      rtlwifi: rtl8188ee: rtl8821ae: Fix a queue locking problem
      rtlwifi: rtl8192ee: Move driver from staging to the regular tree
      rtlwifi: rtl8723ae: Update driver to match 06/28/14 Realtek version
      rtlwifi: rtl8723be: Update driver to match Realtek release of 06/28/14
      rtlwifi: rtl8192ce: rtl8192common: Update for latest version of Realt=
ek drivers
      rtlwifi: rtl8188ee: rtl8192com: rtl8192cu: rtl8192ee: rtl8723ae: rtl8=
7323be: rtl8821ae: Use common cmd_send_packet
      rtlwifi: rtl8188ee: rtl8723ae: rtl8821ae: Initialize some variables
      rtlwifi: Fix randconfig build error with next-20140930
      rtlwifi: Fix Kconfig for RTL8192EE
      rtlwifi: Fix static checker warnings for various drivers

Liad Kaufman (2):
      iwlwifi: pcie: fix HW_REV saving for 8000 series
      iwlwifi: 8000: fix fw name to account for revision

Luciano Coelho (1):
      iwlwifi: mvm: add debugfs entry to read the current temperature

Maithili Hinge (1):
      mwifiex: add client mac address while configuring keys on GO.

Marcel Holtmann (7):
      Bluetooth: btusb: Separate TX URB allocation and submission
      Bluetooth: Add BUILD_BUG_ON check for SKB control buffer size
      Bluetooth: Provide HCI command opcode information to driver
      Bluetooth: btusb: Fix old coding style issues
      Bluetooth: btusb: Split fragement receiption into separate functions
      Bluetooth: btusb: Implement driver internal packet reassembly
      Bluetooth: Remove exported hci_recv_fragment function

Mark A. Greer (44):
      NFC: digital: Add Inititor-side PSL support
      NFC: trf7970a: Add VIN voltage override support
      NFC: trf7970a: Document the 'vin-voltage-override' DTS property
      NFC: trf7970a: Move IRQ Status Read quirk to device tree
      NFC: trf7970a: Document the 'irq-status-read-quirk' DT property
      NFC: trf7970a: Add quirk to keep EN2 low
      NFC: trf7970a: Document the 'en2-rf-quirk' DT property
      NFC: trf7970a: Make gpio labels more readable
      NFC: trf7970a: Remove incorrect of_node_put() call
      NFC: trf7970a: Remove trf7970a_tg_listen_mdaa()
      NFC: trf7970a: Call spi_setup() to configure SPI communication
      NFC: trf7970a: Use spi_sync() instead of spi_write_then_read()
      NFC: trf7970a: Ignore Overflow bit in FIFO Status Register
      NFC: trf7970a: FIFO Size is really 127 bytes
      NFC: trf7970a: Remove unnecessary sleep
      NFC: trf7970a: Disable SYS_CLK Output
      NFC: trf7970a: Initialize when enabling RF
      NFC: trf7970a: Add RF technology specific guard times
      NFC: trf7970a: Recalculate driver timeout values
      NFC: trf7970a: Clear possible spurious interrupt before transmitting
      NFC: trf7970a: Remove unnecessary FIFO reset & RSSI read
      NFC: trf7970a: Prefix TX data when refilling FIFO
      NFC: trf7970a: Only fill FIFO if there is space
      NFC: trf7970a: Handle low-watermark IRQ when transmitting
      NFC: trf7970a: Reread FIFO Status Register when draining FIFO
      NFC: trf7970a: Ensure no more RX data before completing receive
      NFC: trf7970a: Return error code when turning on RF fails
      NFC: trf7970a: Rename TRF7970A_ST_OFF to TRF7970A_ST_RF_OFF
      NFC: trf7970a: Don't assume CONFIG_PM_RUNTIME is enabled
      NFC: trf7970a: Create startup and shutdown routines
      NFC: trf7970a: Add System Suspend/Resume support
      NFC: trf7970a: Delay after initialization
      NFC: trf7970a: Add '_in_' to initiator routines
      NFC: trf7970a: Don't turn off RF if its already off
      NFC: trf7970a: trf7970a_init() turns off the RF transmitter
      NFC: trf7970a: Don't turn on RF if there is already an RF field
      NFC: trf7970a: Cancel timer when error encountered
      NFC: trf7970a: Handle timeout values of zero
      NFC: trf7970a: Add Target Mode Support
      NFC: trf7970a: Add Target Mode Detection Support
      NFC: trf7970a: Remove useless local variable
      NFC: trf7970a: Remove unnecessary local variable initialization
      NFC: trf7970a: Unlock mutex before exiting trf7970a_irq()
      NFC: trf7970a: Unlock mutex before exiting _trf7970a_tg_listen()

Matteo Croce (1):
      ath10k: ATH10K_DEBUGFS depends on DEBUG_FS

Michal Kazior (11):
      ath10k: re-enable interrupts properly in hw recovery
      ath10k: fix num_legacy_stations tracking
      ath10k: kill tasklets after free_irq
      ath10k: fix monitor start/stop sequences
      ath10k: stop monitor vdev for sta assoc
      ath10k: remove diag_*_access functions
      ath10k: add device/driver strings to tracepoints
      ath10k: don't access tx_info while overwriting it
      ath10k: move fw_crash_dump allocation
      ath10k: use proper service bitmap size
      ath10k: fix debugfs_create_dir() checking

Oren Givon (1):
      iwlwifi: Add missing PCI IDs for the 7260 series

Paul Bolle (1):
      ath5k: Remove AHB bus support

Rafa=C5=82 Mi=C5=82ecki (3):
      bcma: print chip ID in a more user-friendly form
      bcma: gpio: use ChipCommon GPIO IRQ on BCM47XX arch only
      bcma: use chipcommon node from DT for SoC GPIO chip

Simon Vincent (1):
      ieee802154: 6lowpan: ensure header compression does not corrupt ipv6 =
header

Stanislaw Gruszka (2):
      rt2800: correct BBP1_TX_POWER_CTRL mask
      MAINTAINERS: change rt2x00 maintainer

Sujith Manoharan (16):
      ath9k: Cache BSS information
      ath9k: Fix p2p address management
      ath9k: Fix queue management
      ath9k: Use normal queues for offchannel frames
      ath9k: Fix offchannel queuing
      ath9k: Check early for HW reset
      ath: Add support for tracing
      ath9k: Print RoC expiration
      ath9k: Check pending frames properly
      ath9k: Fix pending frame check
      ath9k: Remove duplicate code
      ath9k: Fix queue handling in flush()
      ath9k: Pass context to ath9k_chanctx_wake_queues()
      ath9k: Add ath9k_chanctx_stop_queues()
      ath9k: Fix queue handling for channel contexts
      ath9k: Fix flushing in MCC mode

Varka Bhadram (3):
      mrf24j40: fix Missing a blank line after declarations
      mrf24j40: remove unnecessary return statement
      mrf24j40: use pr_* / dev_* instead of printk()

Vincent Cuissard (3):
      NFC: NCI: Add support of ISO15693
      NFC: NCI: Fix nci_register_device init sequence
      NFC: NCI: Fix NCI RF FRAME interface usage

Vladimir Kondratiev (3):
      wil6210: ethtool ops
      wil6210: manual FW error recovery mode
      wil6210: atomic I/O for the card memory

Xinming Hu (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8887

andrea.merello (1):
      rtl818x_pci: add RSSI information for rtl8187SE

 Documentation/devicetree/bindings/bus/bcma.txt     |   32 +
 .../devicetree/bindings/net/nfc/st21nfcb.txt       |    2 +-
 .../devicetree/bindings/net/nfc/trf7970a.txt       |    8 +
 MAINTAINERS                                        |    5 +-
 drivers/bcma/bcma_private.h                        |   14 +
 drivers/bcma/driver_gpio.c                         |    8 +-
 drivers/bcma/host_soc.c                            |   81 +
 drivers/bcma/main.c                                |   52 +-
 drivers/bcma/scan.c                                |    8 +-
 drivers/bluetooth/Kconfig                          |    4 +-
 drivers/bluetooth/btmrvl_sdio.c                    |   36 +-
 drivers/bluetooth/btusb.c                          |  515 ++-
 drivers/net/ieee802154/mrf24j40.c                  |   19 +-
 drivers/net/wireless/ath/Kconfig                   |    8 +
 drivers/net/wireless/ath/Makefile                  |    4 +
 drivers/net/wireless/ath/ath.h                     |    1 +
 drivers/net/wireless/ath/ath10k/Kconfig            |    2 +-
 drivers/net/wireless/ath/ath10k/Makefile           |    1 +
 drivers/net/wireless/ath/ath10k/bmi.h              |    1 -
 drivers/net/wireless/ath/ath10k/ce.c               |    2 -
 drivers/net/wireless/ath/ath10k/ce.h               |   13 +-
 drivers/net/wireless/ath/ath10k/core.c             |  106 +-
 drivers/net/wireless/ath/ath10k/core.h             |   25 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  102 +-
 drivers/net/wireless/ath/ath10k/debug.h            |   12 +
 drivers/net/wireless/ath/ath10k/hif.h              |    1 -
 drivers/net/wireless/ath/ath10k/htc.c              |   10 +-
 drivers/net/wireless/ath/ath10k/htc.h              |    1 -
 drivers/net/wireless/ath/ath10k/htt.c              |    2 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    3 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   54 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    2 -
 drivers/net/wireless/ath/ath10k/hw.h               |    2 +
 drivers/net/wireless/ath/ath10k/mac.c              |  192 +-
 drivers/net/wireless/ath/ath10k/pci.c              |  183 +-
 drivers/net/wireless/ath/ath10k/rx_desc.h          |    1 -
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    1 -
 drivers/net/wireless/ath/ath10k/testmode.c         |  382 ++
 drivers/net/wireless/ath/ath10k/testmode.h         |   46 +
 drivers/net/wireless/ath/ath10k/testmode_i.h       |   70 +
 drivers/net/wireless/ath/ath10k/trace.h            |  105 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    2 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  103 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   33 +-
 drivers/net/wireless/ath/ath5k/Kconfig             |   14 +-
 drivers/net/wireless/ath/ath5k/Makefile            |    1 -
 drivers/net/wireless/ath/ath5k/ahb.c               |  234 -
 drivers/net/wireless/ath/ath5k/ath5k.h             |   28 -
 drivers/net/wireless/ath/ath5k/base.c              |   14 -
 drivers/net/wireless/ath/ath5k/debug.c             |    1 +
 drivers/net/wireless/ath/ath5k/led.c               |    6 -
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    9 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |   26 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   28 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   24 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   16 +-
 drivers/net/wireless/ath/ath9k/channel.c           |   54 +-
 drivers/net/wireless/ath/ath9k/dynack.c            |    2 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    6 +
 drivers/net/wireless/ath/ath9k/hw.c                |   29 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    1 +
 drivers/net/wireless/ath/ath9k/mac.h               |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   79 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   15 +
 drivers/net/wireless/ath/ath9k/xmit.c              |   29 +-
 drivers/net/wireless/ath/main.c                    |    3 +
 drivers/net/wireless/ath/trace.c                   |   20 +
 drivers/net/wireless/ath/trace.h                   |   71 +
 drivers/net/wireless/ath/wil6210/Makefile          |    2 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    4 +
 drivers/net/wireless/ath/wil6210/debugfs.c         |   67 +
 drivers/net/wireless/ath/wil6210/ethtool.c         |  103 +
 drivers/net/wireless/ath/wil6210/interrupt.c       |   12 +-
 drivers/net/wireless/ath/wil6210/ioctl.c           |  173 +
 drivers/net/wireless/ath/wil6210/main.c            |   72 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   13 +
 drivers/net/wireless/ath/wil6210/wil6210.h         |   21 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   11 +
 drivers/net/wireless/brcm80211/brcmfmac/feature.c  |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/feature.h  |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |    4 +-
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   56 +
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |  133 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |   74 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  114 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |    7 +-
 drivers/net/wireless/brcm80211/include/defs.h      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   18 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   17 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    3 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   25 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |    3 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   60 +
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   20 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   37 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   43 +
 drivers/net/wireless/iwlwifi/mvm/ops.c             |    3 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  240 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |    4 +
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   41 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   79 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   20 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    2 +
 drivers/net/wireless/iwlwifi/mvm/tt.c              |    2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   60 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   46 +
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    4 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          |    2 +-
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/init.c                |    1 -
 drivers/net/wireless/mwifiex/main.c                |   11 +-
 drivers/net/wireless/mwifiex/main.h                |    3 +-
 drivers/net/wireless/mwifiex/pcie.c                |   25 +-
 drivers/net/wireless/mwifiex/scan.c                |   33 +-
 drivers/net/wireless/mwifiex/sdio.c                |   47 +-
 drivers/net/wireless/mwifiex/sdio.h                |  114 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/rt2x00/rt2800.h               |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   28 +-
 drivers/net/wireless/rtlwifi/Kconfig               |   29 +-
 drivers/net/wireless/rtlwifi/Makefile              |    2 +
 drivers/net/wireless/rtlwifi/base.c                |  661 ++-
 drivers/net/wireless/rtlwifi/base.h                |   55 +-
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  |    2 +-
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |    2 +-
 drivers/net/wireless/rtlwifi/cam.c                 |   61 +-
 drivers/net/wireless/rtlwifi/cam.h                 |   10 +-
 drivers/net/wireless/rtlwifi/core.c                |  888 +++-
 drivers/net/wireless/rtlwifi/core.h                |   11 +-
 drivers/net/wireless/rtlwifi/debug.c               |   10 +-
 drivers/net/wireless/rtlwifi/debug.h               |   11 +-
 drivers/net/wireless/rtlwifi/efuse.c               |  228 +-
 drivers/net/wireless/rtlwifi/efuse.h               |   17 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  853 ++--
 drivers/net/wireless/rtlwifi/pci.h                 |   56 +-
 drivers/net/wireless/rtlwifi/ps.c                  |  283 +-
 drivers/net/wireless/rtlwifi/ps.h                  |   71 +-
 .../wireless/rtlwifi/{rtl8723ae =3D> }/pwrseqcmd.h   |    6 +-
 drivers/net/wireless/rtlwifi/rc.c                  |   97 +-
 drivers/net/wireless/rtlwifi/rc.h                  |    9 +-
 drivers/net/wireless/rtlwifi/regd.c                |  108 +-
 drivers/net/wireless/rtlwifi/regd.h                |   11 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/def.h       |   66 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |  881 ++--
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h        |   23 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |  259 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h        |   29 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        | 1251 ++---
 drivers/net/wireless/rtlwifi/rtl8188ee/led.c       |   49 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/led.h       |    4 -
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       | 2151 +++++----
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |   49 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c    |  100 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |  415 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c |  139 -
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |   97 -
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h       | 2936 ++++++------
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c        |  282 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |   43 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.h        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/table.c     |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/table.h     |   12 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |  443 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h       |   83 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |  447 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |   40 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  815 ++--
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |   15 -
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |   64 -
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    3 +
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |  107 -
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/def.h       |    3 -
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   17 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |    3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192de/fw.h        |   12 -
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/Makefile    |   19 +
 drivers/net/wireless/rtlwifi/rtl8192ee/def.h       |  101 +
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c        | 1263 +++++
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h        |  267 ++
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c        |  906 ++++
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.h        |  208 +
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        | 2569 +++++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.h        |   62 +
 drivers/net/wireless/rtlwifi/rtl8192ee/led.c       |  145 +
 drivers/net/wireless/rtlwifi/rtl8192ee/led.h       |   34 +
 drivers/net/wireless/rtlwifi/rtl8192ee/phy.c       | 3219 +++++++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/phy.h       |  153 +
 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.c    |  112 +
 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.h    |  340 ++
 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h       | 2231 +++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/rf.c        |  152 +
 drivers/net/wireless/rtlwifi/rtl8192ee/rf.h        |   36 +
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c        |  399 ++
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.h        |   33 +
 drivers/net/wireless/rtlwifi/rtl8192ee/table.c     |  882 ++++
 drivers/net/wireless/rtlwifi/rtl8192ee/table.h     |   45 +
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c       | 1293 ++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h       |  860 ++++
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    4 -
 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |  197 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  422 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |   50 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  255 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |   54 +-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |  414 +-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h    |   38 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   | 1232 +++--
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |   66 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 1513 +++---
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h        |   66 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |   54 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.h       |   13 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |  884 ++--
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |   67 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |   93 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |  543 +--
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c |  129 -
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       | 2718 +++++------
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c        |  261 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |  222 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/table.c     |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/table.h     |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  460 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |  325 +-
 drivers/net/wireless/rtlwifi/rtl8723be/def.h       |  178 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |  243 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |  194 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.h        |  200 +-
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        | 1320 +++---
 drivers/net/wireless/rtlwifi/rtl8723be/hw.h        |    1 +
 drivers/net/wireless/rtlwifi/rtl8723be/led.c       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c       | 1783 ++++---
 drivers/net/wireless/rtlwifi/rtl8723be/phy.h       |  110 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c    |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h    |  131 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c |  139 -
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h |   95 -
 drivers/net/wireless/rtlwifi/rtl8723be/reg.h       | 1135 ++---
 drivers/net/wireless/rtlwifi/rtl8723be/rf.c        |  144 +-
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |   42 +-
 drivers/net/wireless/rtlwifi/rtl8723be/table.c     | 1053 ++---
 drivers/net/wireless/rtlwifi/rtl8723be/table.h     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |  314 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.h       |   34 +-
 .../net/wireless/rtlwifi/rtl8723com/dm_common.c    |   14 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |   90 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |   59 +-
 .../net/wireless/rtlwifi/rtl8723com/phy_common.c   |   57 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile    |   19 +
 drivers/net/wireless/rtlwifi/rtl8821ae/def.h       |  450 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c        | 3019 ++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h        |  356 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c        | 1857 ++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.h        |  351 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        | 4218 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.h        |   70 +
 drivers/net/wireless/rtlwifi/rtl8821ae/led.c       |  237 +
 drivers/net/wireless/rtlwifi/rtl8821ae/led.h       |   37 +
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c       | 4855 ++++++++++++++++=
++++
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.h       |  259 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c    |  182 +
 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h    |  738 +++
 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h       | 2464 ++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.c        |  465 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h        |   43 +
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c        |  484 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.h        |   34 +
 drivers/net/wireless/rtlwifi/rtl8821ae/table.c     | 4572 ++++++++++++++++=
++
 drivers/net/wireless/rtlwifi/rtl8821ae/table.h     |   60 +
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c       | 1236 +++++
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.h       |  620 +++
 drivers/net/wireless/rtlwifi/stats.c               |   50 +-
 drivers/net/wireless/rtlwifi/stats.h               |    7 +-
 drivers/net/wireless/rtlwifi/usb.c                 |    4 +-
 drivers/net/wireless/rtlwifi/wifi.h                |  238 +-
 drivers/nfc/st21nfca/i2c.c                         |   34 +-
 drivers/nfc/st21nfca/st21nfca.c                    |   59 +-
 drivers/nfc/st21nfca/st21nfca.h                    |   21 -
 drivers/nfc/st21nfca/st21nfca_dep.c                |   59 +-
 drivers/nfc/st21nfcb/i2c.c                         |   67 +-
 drivers/nfc/st21nfcb/ndlc.c                        |    6 +-
 drivers/nfc/st21nfcb/ndlc.h                        |    4 +
 drivers/nfc/st21nfcb/st21nfcb.c                    |   27 +-
 drivers/nfc/st21nfcb/st21nfcb.h                    |    2 -
 drivers/nfc/trf7970a.c                             | 1059 ++++-
 include/linux/bcma/bcma.h                          |    2 +
 include/net/bluetooth/bluetooth.h                  |    5 +-
 include/net/bluetooth/hci.h                        |    1 +
 include/net/bluetooth/hci_core.h                   |    1 -
 include/net/nfc/nci.h                              |   16 +-
 include/net/nfc/nci_core.h                         |    9 +-
 include/uapi/linux/wil6210_uapi.h                  |   87 +
 net/bluetooth/6lowpan.c                            |  145 +-
 net/bluetooth/af_bluetooth.c                       |    3 +
 net/bluetooth/hci_conn.c                           |   43 +-
 net/bluetooth/hci_core.c                           |   21 +-
 net/bluetooth/l2cap_core.c                         |   13 +-
 net/bluetooth/lib.c                                |   14 +-
 net/bluetooth/smp.c                                |    5 +-
 net/ieee802154/6lowpan_rtnl.c                      |  125 +-
 net/nfc/digital_dep.c                              |  101 +
 net/nfc/nci/core.c                                 |   21 +-
 net/nfc/nci/data.c                                 |    7 +-
 net/nfc/nci/ntf.c                                  |   40 +-
 325 files changed, 63957 insertions(+), 17040 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/bus/bcma.txt
 create mode 100644 drivers/net/wireless/ath/ath10k/testmode.c
 create mode 100644 drivers/net/wireless/ath/ath10k/testmode.h
 create mode 100644 drivers/net/wireless/ath/ath10k/testmode_i.h
 delete mode 100644 drivers/net/wireless/ath/ath5k/ahb.c
 create mode 100644 drivers/net/wireless/ath/trace.c
 create mode 100644 drivers/net/wireless/ath/trace.h
 create mode 100644 drivers/net/wireless/ath/wil6210/ethtool.c
 create mode 100644 drivers/net/wireless/ath/wil6210/ioctl.c
 rename drivers/net/wireless/rtlwifi/{rtl8723ae =3D> }/pwrseqcmd.h (92%)
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/trx.h
 create mode 100644 include/uapi/linux/wil6210_uapi.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--dTy3Mrz/UPE2dbVg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJULuSPAAoJEJctW/TcYTgGRokP/juHCkuYJAiU/ZEuqDmYC3JZ
j50wYwa+zulESA7a5MpXeoGQj/qNxbbZqD53pgVGO8hYFL6J0+wxWH9QmWsHnMo7
rcXroHw5AOoE7OY7kQNmEoBhyMNfaE7qToDb4IgRexcb/JjWCOJGz6j6hbmjIHU3
Xh7lNe0LXcTZCo+rk6SQcIJ7f3+MJ5Zvl3X/bO9heZL1AUtUH+wABN2gOudZP8xx
k4Ozy0KBJ4Nds9sqYTC60n8xIuchfq/rp/egdXxRnu5XTSHZGjTeNnOIa2/PRc4L
dN29pwjj9Ngj/vGCWIivDSTbOve2t8acbh6a+sksyxTz94T2D1MPW2cs9IreUH2Z
lfUfgR9lPcjLuttFO7jkyz4pQDd1Pi9DpkTIozTGE3knddDgXrvA6c0/wJL/6czC
GPCB0z81DTvo6GGT6d6NG0Rxaal74usgnKN/5JMDqHwXnx4gx+2kya1+rkgcUNIP
wu5EilNCGp46wxPtz8872j8V3XSZ2/AnBtAq4Bh4LGbKeV4W7+L7hSFzuRS+ogW0
UB/EETGs55vmw3fGSDl8BspKakF6l6Dc4/ptEyGB0k+/MSWZvRBKL8Ln4JruUoec
ZGg+bRF+LxQCdsq+AKWjAfVFe+GF7OGWuB2U/rXkHdOkROv5fmjP9ZQmOUZej4rU
qFR4onWXHB7ymPTXdnTf
=10CI
-----END PGP SIGNATURE-----

--dTy3Mrz/UPE2dbVg--
