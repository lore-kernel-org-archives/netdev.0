From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-12-13
Date: Fri, 13 Dec 2013 13:44:48 -0500
Message-ID: <20131213184448.GB21223@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43550 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab3LMSpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:45:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates for the 3.14 stream...

For the Bluetooth bits, Gustavo says:

"This is the first batch of patches intended for 3.14. There is
nothing big here.  Most of the code are refactors, clean up, small
fixes, plus some new device id support."

And...

"More patches to 3.14. Here we have the support for Low Energy
Connection Oriented Channels (LE CoC). Basically, as the name says,
this adds supports for connection oriented channels in the same way
we already have them for BR/EDR connections so profiles/protocols
that work on top of BR/EDR can now work on LE plus a plenty of new
possibilities for LE."

For the ath10k bits, Kalle says:

"Janusz and Marek implemented DFS support to ath10k, but the code is
not enabled yet due to missing cfg80211/mac80211 patches (it will be
enabled in the next pull request). Michal did some device reset fixes
and made it possible for ath10k to share an interrupt with another
device. And lots of smaller fixes from different people."

For the iwlwifi bits, Emmanuel says:

"I have here a big rework of the rate control by Eyal. This is obviously
the biggest part of this batch.
I also have enhancement of protection flags by Avri and a few bits for
WoWLAN by Eliad and Luca. Johannes cleans up the debugfs plus a few
fixes. I provided a few things for Bluetooth coexistence.
Besides this we have an implementation for low priority scan."

Along with all that, there are big batches of updates to mwifiex and
ath9k, Jeff Kirsher's FSF address fix patches, and a handful of other
bits here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 68536053600425c24aba031c45f053d447eedd9c:

  ipv6: fix incorrect type in declaration (2013-12-12 16:14:09 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to f647a52e1576f9c92cc9c02d5756cd0207295a2b:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-12-13 13:14:28 -0500)

----------------------------------------------------------------

Alexander Bondar (1):
      iwlwifi: mvm: Add debugfs entry to generate NMI to NIC

Amitkumar Karwar (4):
      mwifiex: declare snap_type as __be16 variable
      mwifiex: remove rfc1042_eth_hdr variable
      mwifiex: fix an issue with Appletalk devices
      mwifiex: remove redundant goto exit_remove statement

Andre Guedes (5):
      Bluetooth: Check address in mgmt_disconnect_failed()
      Bluetooth: Add an extra check in mgmt_device_disconnected()
      Bluetooth: Remove link type check in hci_disconn_complete_evt()
      Bluetooth: Remove unneeded check in hci_disconn_complete_evt()
      Bluetooth: Refactor hci_disconn_complete_evt

Avri Altman (1):
      iwlwifi: mvm: fix ht protection flags

Bartosz Markowski (1):
      ath10k: expand the wmi mgmt queue limit to 128

Ben Greear (3):
      ath10k: Initialize list-head on vif creation.
      ath10k: Fix un-initialized debug objects.
      ath10k: add logging to better determine some VIF/STA creation failures

Bing Zhao (4):
      Bluetooth: btmrvl: operate on 16-bit opcodes instead of ogf/ocf
      Bluetooth: btmrvl: use cal-data from device-tree instead of conf file
      Bluetooth: btmrvl: remove cal-data byte swapping and redundant mem co=
py
      mwifiex: avoid using variable name eth_hdr

Chun-Yeow Yeoh (2):
      ath9k: enable dfs for mesh mode
      wcn36xx: enable the beaconing in mesh mode

Eliad Peller (4):
      iwlwifi: mvm: enable d3_test even if d3_test_pme_ptr is not available
      iwlwifi: mvm: disconnect on disconnection wakeup event
      iwlwifi: mvm: allow keeping connections in d3_test
      iwlwifi: mvm: fix scan offloading flag definition

Emmanuel Grumbach (6):
      iwlwifi: remove TX_CMD id from transport layer
      iwlwifi: mvm: BT Coex - fine tune the aggregation size
      iwlwifi: mvm: a few more SKUs for 7260 and 3160
      iwlwifi: mvm: dump NVM from debugfs
      iwlwifi: mvm: BT Coex - enable Sync to SCO
      iwlwifi: mvm: rs: fix compilation without CONFIG_MAC80211_DEBUGFS

Eyal Shapira (21):
      iwlwifi: mvm: fix and improve printing of rate scale table
      iwlwifi: mvm: simplify iwl_mvm_send_lq_cmd
      iwlwifi: mvm: refactor iwl_mvm_rs_rate_init
      iwlwifi: mvm: implement rate_update hook in rs
      iwlwifi: mvm: add LQ flags definitions
      iwlwifi: fix check for a single rx antenna
      iwlwifi: mvm: stop using MIMO in case BT doesn't allow it
      iwlwifi: mvm: don't enable VHT MCS9 in 20Mhz
      iwlwifi: mvm: don't configure mimo rates if nss is limited to 1
      iwlwifi: mvm: rs: improve debug prints
      iwlwifi: mvm: rs: reduce min failures to end test window
      iwlwifi: mvm: rs: update expected TPT tables if aggregation changed
      iwlwifi: mvm: rs: rename thresholds defines
      iwlwifi: mvm: rs: increase stay in column timeout
      iwlwifi: mvm: rs: remove unused timestamp field
      iwlwifi: mvm: rs: refactor to use rs_rate
      iwlwifi: mvm: rs: remove unused parameter to rs_get_supported_rates
      iwlwifi: mvm: rs: set dual_stream_ant_msk to ANT_AB always
      iwlwifi: mvm: rs: fix mapping from HT/VHT rates to legacy
      iwlwifi: mvm: rs: use the proper channel width define for legacy rate
      iwlwifi: mvm: rs: overhaul search cycle state machine

Haim Dreyfuss (1):
      iwlwifi: mvm: Implement low-priority scan

Janusz Dziedzic (1):
      ath10k: add phyerr/dfs handling

Jeff Kirsher (6):
      zd1211rw: Fix FSF address in file headers
      rt2x00: Fix FSF address in file headers
      prism54: Fix FSF address in file headers
      drivers/net/wireless: Fix FSF address in file headers
      rfkill: Fix FSF address in file headers
      nfc: Fix FSF address in file headers

Jingoo Han (1):
      bcma: pci: remove DEFINE_PCI_DEVICE_TABLE macro

Johan Hedberg (38):
      Bluetooth: Remove unnecessary 'send' parameter from smp_failure()
      Bluetooth: Remove useless smp_rand function
      Bluetooth: Remove dead code from SMP encryption function
      Bluetooth: Remove unnecessary braces from one-line if-statement
      Bluetooth: Add module parameter to enable LE CoC support
      Bluetooth: Update l2cap_global_chan_by_psm() to take a link type
      Bluetooth: Allow l2cap_chan_check_security() to be used for LE links.
      Bluetooth: Pass command length to LE signaling channel handlers
      Bluetooth: Move LE L2CAP initiator procedure to its own function
      Bluetooth: Add definitions for LE connection oriented channels
      Bluetooth: Add initial code for LE L2CAP Connect Request
      Bluetooth: Add smp_sufficient_security helper function
      Bluetooth: Refactor L2CAP connect rejection to its own function
      Bluetooth: Add basic LE L2CAP connect request receiving support
      Bluetooth: Fix L2CAP channel closing for LE connections
      Bluetooth: Add L2CAP Disconnect suppport for LE
      Bluetooth: Make l2cap_le_sig_cmd logic consistent
      Bluetooth: Add LE L2CAP flow control mode
      Bluetooth: Track LE L2CAP credits in l2cap_chan
      Bluetooth: Limit L2CAP_OPTIONS socket option usage with LE
      Bluetooth: Add new BT_SNDMTU and BT_RCVMTU socket options
      Bluetooth: Implement returning of LE L2CAP credits
      Bluetooth: Add LE flow control discipline
      Bluetooth: Reject LE CoC commands when the feature is not enabled
      Bluetooth: Introduce L2CAP channel callback for suspending
      Bluetooth: Add LE L2CAP segmentation support for outgoing data
      Bluetooth: Implement LE L2CAP reassembly
      Bluetooth: Fix LE L2CAP Connect Request handling together with SMP
      Bluetooth: Fix suspending the L2CAP socket if we start with 0 credits
      Bluetooth: Limit LE MPS to the MTU value
      Bluetooth: Fix clearing of chan->omtu for LE CoC channels
      Bluetooth: Fix CID ranges for LE CoC CID allocations
      Bluetooth: Fix validating LE PSM values
      Bluetooth: Add debugfs controls for LE CoC MPS and Credits
      Bluetooth: Simplify l2cap_chan initialization for LE CoC
      Bluetooth: Use min_t for calculating chan->mps
      Bluetooth: Fix valid LE PSM check
      Bluetooth: Fix handling of L2CAP Command Reject over LE

Johannes Berg (7):
      iwlwifi: pcie: remove useless condition test
      iwlwifi: mvm: small debugfs cleanups
      iwlwifi: mvm: move interface-specific debugfs to a new file
      iwlwifi: mvm: don't use void pointers in debugfs
      iwlwifi: mvm: refactor debugfs copy_from_user()
      iwlwifi: mvm: add iwl_mvm_sta_from_mac80211
      iwlwifi: mvm: quota command max_duration should be zero

John W. Linville (5):
      Merge tag 'for-linville-20131203' of git://github.com/kvalo/ath
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kalle Valo (6):
      ath10k: implement ath10k_pci_soc_read/write32()
      ath10k: add error handling to ath10k_pci_wait()
      ath10k: remove htt rx amsdu clear retry bit hack
      ath10k: don't show MSI registration warnings
      ath10k: make core boot messages more compact
      ath10k: show hardware and firmware info prints only once

Larry Finger (1):
      rtlwifi: rtl8192c-common: Fix sparse warning

Lorenzo Bianconi (1):
      ath9k: initialize retry chain flags in tx99 code

Luciano Coelho (2):
      iwlwifi: mvm: don't restart HW if suspending fails before D3 image is=
 loaded
      MAINTAINERS: remove myself as maintainer of TI WiLink drivers

Marcel Holtmann (6):
      Bluetooth: Fix limited discoverable mode for Zeevo modules
      Bluetooth: Set default own address type only during controller setup
      Bluetooth: Remove debug statement for features complete event
      Bluetooth: Store supported commands only during setup procedure
      Bluetooth: Increase minor version of core module
      Bluetooth: Use macros for connectionless slave broadcast features

Marek Puzyniak (2):
      ath10k: introduce DFS implementation
      ath10k: add debugfs file to control radar events blocking

Michal Kazior (37):
      ath10k: prevent starting monitor without a vdev
      ath10k: add sanity checks for monitor management
      ath10k: fix endianess in prints
      ath10k: fix NSS reporting in RX
      ath10k: fix NULL deref upon early FW crash
      ath10k: fix FW crashes on heavy TX on 10.1.389 AP FW
      ath10k: setup min channel power to a reasonable value
      ath10k: use proper tx power unit
      ath10k: respect power_level values
      ath10k: plug memory leak in wmi mgmt tx worker
      ath10k: plug memory leak on beacon tx
      ath10k: remove ar_pci->ce_count
      ath10k: don't forget to kill fw error tasklet
      ath10k: split tasklet killing function
      ath10k: rename ath10k_pci_reset_target()
      ath10k: make sure to mask all CE irqs
      ath10k: fix ath10k_ce_init() failpath
      ath10k: remove meaningless check
      ath10k: use ath10k_do_pci_wake/sleep
      ath10k: propagate ath10k_ce_disable_interrupts() errors
      ath10k: guard against CE corruption from firmware
      ath10k: re-arrange PCI init code
      ath10k: add and fix some PCI prints
      ath10k: reset device upon stopping/power down
      ath10k: fix core init failpath
      ath10k: allow dynamic bandwidth in hw rate control
      ath10k: clear tx status before submitting to mac80211
      ath10k: don't consume other's shared interrupts
      ath10k: split up pci irq code
      ath10k: don't use interrupts for BMI
      ath10k: decouple ath10k_pci_start_ce()
      ath10k: defer irq registration until hif start()
      ath10k: extract functions for legacy irq handling
      ath10k: re-add support for early fw indication
      ath10k: allow explicit MSI/MSI-X disabling
      ath10k: fix Tx status clearing
      ath10k: fix multi BSSID with WPA on FW 10.1

Michal Nazarewicz (1):
      iwlwifi: pcie: remove minor dead code

Nick Kossifidis (1):
      ath5k: Reset Tx interrupt bits also on PISR

Sujith Manoharan (18):
      Bluetooth: ath3k: Add support for another AR3012 card
      Bluetooth: ath3k: Add support for a new AR3012 device
      ath9k: Add initval arrays for DFS channels
      ath9k: Initialize baseband for DFS channels
      ath9k: Update mac_postamble for AR9003 family
      ath9k: Remove AR955x INI duplicates
      ath9k: Update AR9331 v1.1 initvals
      ath9k: Update AR9331 v1.2 initvals
      ath9k: Use a separate TX gain table for WZR-HP-G450H
      ath9k: Update high power gain table for AR9300
      ath9k: Identify duplicate AR9485 initvals
      ath9k: Identify duplicate AR9462 v2.0 initvals
      ath9k: Identify duplicate AR9565 v1.0 initvals
      ath9k: Fix regulatory compliance
      ath9k: Remove AR9330 v1.0 macro as it's not supported
      ath9k: Enable manual peak calibration for AR9331 v1.1
      ath9k: Fix internal regulator for AR955x
      ath9k: Apply tuning caps for AR9330 and AR9485

Tedd Ho-Jeong An (2):
      Bluetooth: Add support for Intel Bluetooth device [8087:0a2a]
      Bluetooth: Enable autosuspend for Intel Bluetooth device

Ujjal Roy (6):
      mwifiex: use little-endian variables in firmware structures
      mwifiex: fix rx_pending count imbalance
      mwifiex: correct RX byte count statistics
      mwifiex: correct TX byte count statistics
      mwifiex: update statistics for bridged packets on AP interface
      mwifiex: do not flood kmsg/dmesg with USB debug messages

Wei Yongjun (1):
      ath10k: fix possible memory leak in ath10k_pci_probe()

 MAINTAINERS                                        |    3 +-
 drivers/bcma/host_pci.c                            |    2 +-
 drivers/bluetooth/ath3k.c                          |    4 +
 drivers/bluetooth/btmrvl_drv.h                     |   25 +-
 drivers/bluetooth/btmrvl_main.c                    |  130 +-
 drivers/bluetooth/btmrvl_sdio.c                    |    9 +-
 drivers/bluetooth/btmrvl_sdio.h                    |    2 -
 drivers/bluetooth/btusb.c                          |    7 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   53 +-
 drivers/net/wireless/ath/ath10k/ce.h               |    2 +-
 drivers/net/wireless/ath/ath10k/core.c             |   43 +-
 drivers/net/wireless/ath/ath10k/core.h             |   23 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   94 ++
 drivers/net/wireless/ath/ath10k/debug.h            |    6 +
 drivers/net/wireless/ath/ath10k/htc.c              |   31 +-
 drivers/net/wireless/ath/ath10k/htt.c              |    4 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    1 +
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   25 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   11 +-
 drivers/net/wireless/ath/ath10k/hw.h               |    1 +
 drivers/net/wireless/ath/ath10k/mac.c              |  316 +++-
 drivers/net/wireless/ath/ath10k/pci.c              |  791 +++++----
 drivers/net/wireless/ath/ath10k/pci.h              |   14 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    6 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  302 +++-
 drivers/net/wireless/ath/ath10k/wmi.h              |   96 +-
 drivers/net/wireless/ath/ath5k/dma.c               |   11 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  191 +--
 .../wireless/ath/ath9k/ar9003_buffalo_initvals.h   |  126 ++
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   29 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   18 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    6 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    5 +-
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   |  128 +-
 .../net/wireless/ath/ath9k/ar9330_1p2_initvals.h   |  401 ++++-
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |    2 +
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |  697 +-------
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |  117 +-
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   |  540 +------
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   |   85 +-
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |   13 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    6 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +
 drivers/net/wireless/ath/ath9k/init.c              |   39 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    3 -
 drivers/net/wireless/ath/ath9k/tx99.c              |   10 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |   12 +-
 drivers/net/wireless/atmel.c                       |    7 +-
 drivers/net/wireless/atmel.h                       |    4 +-
 drivers/net/wireless/atmel_cs.c                    |    4 +-
 drivers/net/wireless/atmel_pci.c                   |    4 +-
 drivers/net/wireless/iwlwifi/dvm/rs.h              |    7 -
 drivers/net/wireless/iwlwifi/dvm/tx.c              |    1 +
 drivers/net/wireless/iwlwifi/iwl-config.h          |    6 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    3 +
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    1 +
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |   13 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   38 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |  190 +++
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  636 +-------
 drivers/net/wireless/iwlwifi/mvm/debugfs.h         |  101 ++
 drivers/net/wireless/iwlwifi/mvm/fw-api-bt-coex.h  |    1 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |   27 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |    5 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   51 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   19 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   11 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   23 +
 drivers/net/wireless/iwlwifi/mvm/quota.c           |    3 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              | 1681 ++++++++++------=
----
 drivers/net/wireless/iwlwifi/mvm/rs.h              |  150 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   55 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   14 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    6 +
 drivers/net/wireless/iwlwifi/mvm/tt.c              |    2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   11 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    8 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    5 +
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   26 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   33 +-
 drivers/net/wireless/libertas/README               |    5 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    6 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    1 +
 drivers/net/wireless/mwifiex/cmdevt.c              |    4 +-
 drivers/net/wireless/mwifiex/decl.h                |    1 +
 drivers/net/wireless/mwifiex/fw.h                  |   30 +-
 drivers/net/wireless/mwifiex/init.c                |    3 +-
 drivers/net/wireless/mwifiex/main.c                |    9 +-
 drivers/net/wireless/mwifiex/main.h                |    2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |   44 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |    1 +
 drivers/net/wireless/mwifiex/txrx.c                |   15 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |   39 +-
 drivers/net/wireless/mwifiex/usb.c                 |    4 +-
 drivers/net/wireless/mwifiex/util.c                |    5 +-
 drivers/net/wireless/p54/net2280.h                 |    3 +-
 drivers/net/wireless/prism54/isl_38xx.c            |    3 +-
 drivers/net/wireless/prism54/isl_38xx.h            |    3 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |    3 +-
 drivers/net/wireless/prism54/isl_ioctl.h           |    3 +-
 drivers/net/wireless/prism54/isl_oid.h             |    3 +-
 drivers/net/wireless/prism54/islpci_dev.c          |    3 +-
 drivers/net/wireless/prism54/islpci_dev.h          |    3 +-
 drivers/net/wireless/prism54/islpci_eth.c          |    3 +-
 drivers/net/wireless/prism54/islpci_eth.h          |    3 +-
 drivers/net/wireless/prism54/islpci_hotplug.c      |    3 +-
 drivers/net/wireless/prism54/islpci_mgt.c          |    3 +-
 drivers/net/wireless/prism54/islpci_mgt.h          |    3 +-
 drivers/net/wireless/prism54/oid_mgt.c             |    3 +-
 drivers/net/wireless/prism54/oid_mgt.h             |    3 +-
 drivers/net/wireless/prism54/prismcompat.h         |    3 +-
 drivers/net/wireless/ray_cs.c                      |    3 +-
 drivers/net/wireless/rndis_wlan.c                  |    3 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2800.h               |    4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2800mmio.c           |    4 +-
 drivers/net/wireless/rt2x00/rt2800mmio.h           |    4 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2800soc.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800usb.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    4 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    4 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |    4 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00debug.h          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h           |    4 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    4 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c           |    4 +-
 drivers/net/wireless/rt2x00/rt2x00leds.h           |    4 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mmio.c           |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mmio.h           |    4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00soc.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00soc.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    4 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |    4 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    2 +-
 drivers/net/wireless/zd1211rw/zd_chip.c            |    3 +-
 drivers/net/wireless/zd1211rw/zd_chip.h            |    3 +-
 drivers/net/wireless/zd1211rw/zd_def.h             |    3 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |    3 +-
 drivers/net/wireless/zd1211rw/zd_mac.h             |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf.c              |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf.h              |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c       |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c      |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf_rf2959.c       |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c       |    3 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |    3 +-
 drivers/net/wireless/zd1211rw/zd_usb.h             |    3 +-
 drivers/nfc/mei_phy.c                              |    4 +-
 drivers/nfc/microread/i2c.c                        |    4 +-
 drivers/nfc/microread/mei.c                        |    4 +-
 drivers/nfc/microread/microread.c                  |    4 +-
 drivers/nfc/microread/microread.h                  |    4 +-
 drivers/nfc/nfcwilink.c                            |    3 +-
 drivers/nfc/pn533.c                                |    4 +-
 drivers/nfc/pn544/i2c.c                            |    4 +-
 drivers/nfc/pn544/mei.c                            |    4 +-
 drivers/nfc/pn544/pn544.c                          |    4 +-
 drivers/nfc/pn544/pn544.h                          |    4 +-
 include/linux/ath9k_platform.h                     |    2 +
 include/linux/platform_data/pn544.h                |    3 +-
 include/net/bluetooth/bluetooth.h                  |    3 +
 include/net/bluetooth/hci.h                        |    6 +
 include/net/bluetooth/hci_core.h                   |    6 +
 include/net/bluetooth/l2cap.h                      |   45 +
 net/bluetooth/af_bluetooth.c                       |    2 +-
 net/bluetooth/hci_core.c                           |   26 +-
 net/bluetooth/hci_event.c                          |   72 +-
 net/bluetooth/l2cap_core.c                         |  744 ++++++++-
 net/bluetooth/l2cap_sock.c                         |  181 ++-
 net/bluetooth/mgmt.c                               |   17 +-
 net/bluetooth/smp.c                                |   56 +-
 net/bluetooth/smp.h                                |    1 +
 net/nfc/af_nfc.c                                   |    4 +-
 net/nfc/core.c                                     |    4 +-
 net/nfc/hci/command.c                              |    4 +-
 net/nfc/hci/core.c                                 |    4 +-
 net/nfc/hci/hci.h                                  |    4 +-
 net/nfc/hci/hcp.c                                  |    4 +-
 net/nfc/hci/llc.c                                  |    4 +-
 net/nfc/hci/llc.h                                  |    4 +-
 net/nfc/hci/llc_nop.c                              |    4 +-
 net/nfc/hci/llc_shdlc.c                            |    4 +-
 net/nfc/llcp.h                                     |    4 +-
 net/nfc/llcp_commands.c                            |    4 +-
 net/nfc/llcp_core.c                                |    4 +-
 net/nfc/llcp_sock.c                                |    4 +-
 net/nfc/nci/core.c                                 |    3 +-
 net/nfc/nci/data.c                                 |    3 +-
 net/nfc/nci/lib.c                                  |    3 +-
 net/nfc/nci/ntf.c                                  |    3 +-
 net/nfc/nci/rsp.c                                  |    3 +-
 net/nfc/netlink.c                                  |    4 +-
 net/nfc/nfc.h                                      |    4 +-
 net/nfc/rawsock.c                                  |    4 +-
 net/rfkill/core.c                                  |    4 +-
 222 files changed, 5029 insertions(+), 4302 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_buffalo_initvals.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/debugfs.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSq1WfAAoJEJctW/TcYTgG5ucQAJK5RchkIjN3LpyDQUFS2E9Y
RGcGyB/DzLtXZxvDI84V6UqYhqg3uuoH23cTV/TI9xjasg/h3SPDMjsFAaHNsX0M
7p8qCnfjHLssr4UOX/0BGLel1joZSMiZgDsMStzY4JQZy3EhgpjjZjcvzeoJi8qR
FgWjYgDCnjLAc363e603LFHaY/s1n3BZLDLbK/a1s3lcliNHjJ6xAHHaRa45S5xy
3k8FIY0X1Vwzj8Xd4nxuIJ2sdye7CRNA2Qif2kTY/UwLFYwdr3YCtEsL1FmV8LTQ
fH7ujIqlJHzz/VH+zLA00AxwGDfP+1RyVEhMw0uarzoCdycbObMhvb1VH1JSplCK
zdr3+gMNaaO3cU9iIZG7h+8gPk/K9DJco0gqIL15fcsrMDcqcJmbIvXcAf2Z4j1x
X5QV0S5pmaIlzrXBHOni8HFgfiFebP/8hoeY2Ci7E5ZNhJpoT3v5ej5qRJF/f4eW
dVMnOhRQf7zc1xVfq5FpKxHrpWoOdYWPTlrHvRwr35R1lYEiH1BOxReAsiRr/9fE
OSR8VPlCs/wdSa6YXqS3bW11NhHojaLGC4on4rSjx6dcfNDPPjXMqpuL3DY/XhlX
ihQ6zI2GmO90Zp7M8mPkhwDtL73E7+JkCn3Q+qF6m/ozBSBSvP5IShh7FQR5+KIw
oteDU4cFbEoJ7JUpOh8y
=c5ep
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--
