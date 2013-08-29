From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-08-29
Date: Thu, 29 Aug 2013 14:53:53 -0400
Message-ID: <20130829185352.GB2300@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51401 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754405Ab3H2TAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 15:00:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept this batch of updates intended for the 3.12 stream.

For the mac80211 bits, Johannes says this:

"This time I have various improvements all over the place: IBSS, mesh,
testmode, AP client powersave handling, one of the rare rfkill patches
and some code cleanup."

Also for mac80211:

"And I also have some more changes for -next, just a few small fixes and
improvements, nothing really stands out."

And for iwlwifi:

"This time I have some powersave work (notably uAPSD support), CQM
offloads, support for a new firmware API and various code cleanups."

Regarding the Bluetooth bits, Gustavo says:

"Patches to 3.12, here we have:

* implementation of a proper tty_port for RFCOMM devices, this fixes some
issues people were seeing lately in the kernel.
* Add voice_setting option for SCO, it is used for SCO Codec selection
* bugfixes, small improvements and clean ups"

For the NFC bits, Samuel says:

"With this one we have:

- A few pn533 improvements and minor fixes. Testing our pn533 driver
  against Google's NCI stack triggered a few issues that we fixed now.
  We also added Tx fragmentation support to this driver.

- More NFC secure element handling. We added a GET_SE netlink command
  for getting all the discovered secure elements, and we defined 2
  additional secure element netlink event (transaction and connectivity).
  We also fixed a couple of typos and copy-paste bugs from the secure
  element handling code.

- Firmware download support for the pn544 driver. This chipset can enter a
  special mode where it's waiting for firmware blobs to replace the
  already flashed one. We now support that mode."

With repect to the ath tree, Kalle says:

"New features in ath10k are rx/tx checsumming in hw and survey scan
implemented by Michal. Also he made fixes to different areas of the
driver, most notable being fixing the case when using two streams and
reducing the number of interface combinations to avoid firmware crashes.
Bartosz did a clean related to how we handle SoC power save in PCI
layer.

For ath6kl Mohammed and Vasanth sent each a patch to fix two infrequent
crashes."

I also pulled the wireless tree into wireless-next to support a
request from Johannes.  On top of all that, there are the usual
sort of driver updates.  The mwifiex, brcmfmac, brcmsmac, ath9k,
and rt2x00 drivers all get some attention, as does the bcma bus and
a few other random bits here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4c9d546f6c522f541dfb01e192ab7101eca0053b:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git=
/bwh/sfc-next (2013-08-29 01:56:01 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 0d8165e9fca119b804de2cf35674e07c36c9704f:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-08-29 14:08:24 -0400)

----------------------------------------------------------------

Alexander Bondar (3):
      iwlwifi: mvm: Fix beacon filtering enablement via debugfs
      iwlwifi: mvm: Add basic uAPSD client support
      iwlwifi: mvm: Add PBW snoozing enablement

Amitkumar Karwar (1):
      mwifiex: fix driver unload problem for usb chipsets

Andrea Merello (1):
      Update e-mail address for Andrea Merello (resubmit)

Andrei Otcheretianski (1):
      iwlwifi: mvm: Implement CQM offloading

Andy Shevchenko (1):
      Bluetooth: use DIV_ROUND_UP in suitable places in btmrvl_sdio

Antonio Quartulli (1):
      mac80211: ibss - do not scan if not needed when creating an IBSS

Arend van Spriel (17):
      brcmfmac: use irq safe spinlock in brcmf_sdbrcm_txdata()
      brcmfmac: .txdata() bus callback should not call brcmf_txcomplete()
      brcmfmac: add AMPDU reordering functionality
      brcmfmac: ignore IF event if firmware indicates it
      brcmfmac: add support for manual TDLS operations
      brcmsmac: cosmetic change in phy_lcn.c
      brcmsmac: change pa_gain for bcm4313 iPA
      brcmsmac: use ARRAY_SIZE in phytbl_lcn.c
      brcmsmac: add debug info message providing phy and radio info
      brcmsmac: update transmit gain table for lcn phy
      brcmsmac: change lcnphy receive i/q calibration routine
      brcmsmac: fix TSSI idle estimation
      brcmsmac: avoid calling set_txpwr_by_index() twice
      brcmsmac: rework switch control table init including iPA BT-combo
      brcmsmac: correct phy registers for TSSI-based power control
      brcmsmac: reinitialize TSSI power control upon channel switch
      brcmsmac: add support for BCM4313 iPA variant

Arron Wang (2):
      NFC: Fix secure element state check
      NFC: Update secure element state

Avinash Patil (2):
      mwifiex: fix ext_capab IE structure definition
      mwifiex: drop gratuitous ARP frames

Bartosz Markowski (1):
      ath10k: add SoC power save option to PCI features map

Benjamin Tissoires (2):
      Bluetooth: hidp: implement hidinput_input_event callback
      Bluetooth: hidp: remove wrong send_report at init

Bing Zhao (2):
      mwifiex: do not create AP and P2P interfaces upon driver loading
      mwifiex: break a long line into two lines

Bob Copeland (1):
      mac80211: assign seqnums for group QoS frames

Chun-Yeow Yeoh (2):
      mac80211: allow lowest basic rate for unicast management for mesh
      mac80211: only respond to probe request with mesh ID

Dan Carpenter (2):
      iwlwifi: pcie: returning positive instead of negative
      NFC: hci: Fix enable/disable confusion

David Spinadel (2):
      cfg80211: add wdev to testmode cmd
      mac80211: add vif to testmode cmd

Djalal Harouni (1):
      ath5k: debugfs: NULL-terminate strings

Eliad Peller (1):
      iwlwifi: mvm: don't clear tbl->win mistakenly

Eric Lapuyade (5):
      NFC: Move nfc_fw_download_done() definition from private to public
      NFC: pn544: i2c: Add firmware download mode power-on support
      NFC: netlink: Add result of firmware operation to completion event
      NFC: pn544: Add firmware operations hci ops
      NFC: pn544: i2c: Add firmware download implementation for pn544

Eyal Shapira (4):
      iwlwifi: mvm: remove rate_scale_data debugfs entry
      iwlwifi: mvm: remove unused fields of iwl_rs_rate_info
      iwlwifi: mvm: remove MIMO3 from rate scale code
      iwlwifi: mvm: remove unused param of rs_dbgfs_set_mcs

Eytan Lifshitz (1):
      iwlwifi: mvm: add support to the new FW time event API

Felix Fietkau (8):
      ath9k: fix rx descriptor related race condition
      ath9k: shrink a few data structures by reordering fields
      ath9k: remove ath9k_sta_remove_debugfs
      ath9k: simplify debugfs chainmask handling
      ath9k: avoid accessing MRC registers on single-chain devices
      ath9k: simplify ath_tid_drain
      ath9k: reset buffer stale flag in ath_tx_get_tid_subframe
      mac80211: add a flag to indicate CCK support for HT clients

Franky Lin (4):
      brcmfmac: abstract tx packet processing functions
      brcmfmac: remove align from brcmf_bus structure
      brcmfmac: streamline sdio bus header code
      brcmfmac: use configurable sdio bus header length for tx packet

Fr=E9d=E9ric Dalleau (10):
      Bluetooth: Use hci_connect_sco directly
      Bluetooth: Remove unused mask parameter in sco_conn_defer_accept
      Bluetooth: Add Bluetooth socket voice option
      Bluetooth: Add constants for SCO airmode
      Bluetooth: Use voice setting in deferred SCO connection request
      Bluetooth: Parameters for outgoing SCO connections
      Bluetooth: Add constants and macro declaration for transparent data
      Bluetooth: Prevent transparent SCO on older devices
      Bluetooth: Handle specific error for SCO connection fallback
      Bluetooth: Add SCO connection fallback

Gabor Juhos (12):
      rt2x00: rt2800lib: introduce rt2800_get_txwi_rxwi_size helper
      rt2x00: rt2800pci: fix AUX_CTRL register setup for RT3090/3390/3593/5=
592
      rt2x00: rt2800: rename HW_BEACON_OFFSET macro
      rt2x00: rt2800lib: pass beacon index to rt2800_clear_beacon_register
      rt2x00: rt2800lib: fix frequency offset boundary calculation
      rt2x00: rt2800lib: optimize frequency offset adjustment
      rt2x00: rt2800lib: use a MCU command for frequency adjustment on USB =
devices
      rt2x00: rt2800lib: use step-by-step frequency offset adjustment on MM=
IO devices
      rt2x00: rt2800lib: move rt2800_adjust_freq_offset function
      rt2x00: rt2800lib: adjust frequency offset for RF3053
      rt2x00: rt2800lib: add rt2800_hw_beacon_base helper
      rt2x00: rt2800lib: don't hardcode beacon offsets

Gianluca Anzolin (6):
      Bluetooth: Take proper tty_struct references
      Bluetooth: Remove the device from the list in the destructor
      Bluetooth: Move the tty initialization and cleanup out of open/close
      Bluetooth: Implement .activate, .shutdown and .carrier_raised methods
      Bluetooth: Fix the reference counting of tty_port
      Bluetooth: Purge the dlc->tx_queue to avoid circular dependency

Gustavo Padovan (1):
      Bluetooth: Add missing braces to an "else if"

Hante Meuleman (2):
      brcmfmac: always use worker thread for tx data.
      brcmfmac: no fws locking outside fws module.

Hauke Mehrtens (6):
      bcma: change max PCI read request size to 128
      bcma: add method to power up and down the PCIe core by wifi driver
      brcmsmac: use bcma PCIe up and down functions
      bcma: do not export bcma_core_pci_extend_L1timer()
      bcma: add bcma_core_pci_power_save()
      b43: call PCIe up and down functions

Helmut Schaa (1):
      ath9k_htc: Restore skb headroom when returning skb to mac80211

Ido Yariv (3):
      iwlwifi: pcie: Refactor iwl_queue_space
      iwlwifi: pcie: Refactor iwl_rxq_space
      iwlwifi: pcie: Remove duplicate code from pcie irq handlers

Jingoo Han (1):
      Bluetooth: replace strict_strtol() with kstrtol()

Johan Almbladh (1):
      mac80211: perform power save processing before decryption

Johan Hedberg (1):
      Bluetooth: Fix getting SCO socket options in deferred state

Johannes Berg (10):
      wireless: make TU conversion macros available
      nl80211: clean up CQM settings code
      mac80211: add control port protocol TX control flag
      iwlwifi: mvm: refactor resume from WoWLAN code
      mac80211: add APIs to allow keeping connections after WoWLAN
      mac80211: add missing channel context release
      mac80211: minstrel_ht: don't use control.flags in TX status path
      mac80211: move setting WIPHY_FLAG_SUPPORTS_SCHED_SCAN into drivers
      mac80211: ignore (E)CSA in probe response frames
      mac80211: fix change_interface queue assignments

John W. Linville (12):
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge tag 'nfc-next-3.12-1' of git://git.kernel.org/.../sameo/nfc-next
      brcmsmac: Fix WARNING caused by lack of calls to dma_mapping_error()
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth=
-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      ath9k: ar9003_eeprom.c:3618 fix variable name typo
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Luciano Coelho (4):
      iwlwifi: pcie: don't swallow error codes in iwl_trans_pcie_alloc()
      iwlwifi: use a macro for default probe length
      iwlwifi: Kconfig: fix help texts wrt 7260 and 3160 devices
      iwlwifi: return -ENOMEM instead of NULL when OOM in iwl_drv_start()

Luis Henriques (1):
      net: rfkill: Do not ignore errors from regulator_enable()

Marcel Holtmann (2):
      Bluetooth: Fix simple whitespace vs tab style issue
      Bluetooth: Set different event mask for LE-only controllers

Mark Schulte (1):
      rtlwifi: sparse warnings: cast to restricted type

Masami Ichikawa (1):
      rt2800usb: Add WLI-UC-G300HP's Product ID.

Matti Gottlieb (1):
      iwlwifi: introduce external debug level

Michal Kazior (11):
      ath10k: improve tx throughput on slow machines
      ath10k: detect the number of spatial streams supported by hw
      ath10k: implement rx checksum offloading
      ath10k: implement tx checksum offloading
      ath10k: implement get_survey()
      ath10k: prevent using invalid ringbuffer indexes
      ath10k: make sure to use passive scan when n_ssids is 0
      ath10k: advertise more conservative intf combinations
      ath10k: zero arvif memory on add_interface()
      ath10k: fix failpath in MSI-X setup
      ath10k: fix device teardown

Mikel Astiz (3):
      Bluetooth: Add HCI authentication capabilities macros
      Bluetooth: Use defines in in hci_get_auth_req()
      Bluetooth: Use defines instead of integer literals

Mohammed Shafi Shajakhan (1):
      ath6kl: Fix invalid pointer access on fuzz testing with AP mode

Oleksij Rempel (1):
      ath9k_htc: do not use bulk on EP3 and EP4

Olivier Guiter (3):
      NFC: pn533: Add extended information frame decoding support
      NFC: pn533: Split large Tx frames in chunks
      NFC: pn533: Store the correct frame size (normal vs ext)

Samuel Ortiz (12):
      MAINTAINERS: Change the NFC subsystem status to Supported
      NFC: Document secure element addition/removal netlink events
      NFC: Define secure element connectivity and transaction events
      NFC: pn533: Fix hardware busy loop when establishing the LLCP link
      NFC: pn533: Fix the pn533 polling loop
      NFC: pn533: Request System code from SENSF_REQ
      NFC: pn533: Unconditionaly select the highest p2p bit rate
      NFC: pn533: Enable AUTO RFCA
      NFC: Fix SE discovery failure warning condition
      NFC: Add a GET_SE netlink API
      NFC: pn533: Add delay between each poll frame
      NFC: pn533: Add some polling entropy

Simon Wunderlich (12):
      mac80211: fix ieee80211_sta_process_chanswitch for 5/10 MHz channels
      mac80211: move ibss presp generation in own function
      ath9k: always use SIFS times from OFDM for 5/10 MHz
      ath9k: use chandef instead of channel_type
      ath9k: report 5/10 MHz channels
      ath9k: set 5/10 MHz supported channels and fix bitrate
      ath9k: announce that ath9k supports 5/10 MHz
      ath5k: report 5/10 MHz channels
      ath5k: set 5/10 MHz supported channels and fix duration
      ath5k: enable support for 5 MHz and 10 MHz channels
      ath9k: enable CSA functionality in ath9k
      mac80211: ibss: fix ignored channel parameter

Solomon Peachy (2):
      cw1200: Display the correct default reference clock.
      cw1200: When debug is enabled, display all wakeup conditions for the =
wait_event_interruptible_timeout() call.

Stanislaw Gruszka (2):
      iwl4965: fix rfkill set state regression
      rt2800: fix wrong TX power compensation

Sujith Manoharan (28):
      ath9k: Use a subroutine to check for "mybeacon"
      ath9k: Fix phy error handling for DFS
      ath9k: Discard invalid frames early
      ath9k: Fix RX crypto processing
      ath9k: Fix TSF processing
      ath9k: Reorder some functions
      ath9k: Fix PHY error processing
      ath9k: Fix RX debug statistics
      ath9k: Fix RX packet counter
      ath9k: Fix RX beacon processing
      ath9k: Move the RX poll check to preprocess()
      ath9k: Handle corrupt descriptors properly
      ath9k: Fix error condition for corrupt descriptors
      ath9k: Remove unused function argument
      ath9k: Handle invalid RSSI
      ath9k: Identify first subframe in an A-MPDU
      ath9k: Optimize LNA check
      ath9k: Use lockless variant to initialize RX fifo
      ath9k: Enable PLL fix only for AR9340/AR9330
      ath9k: Add support for AR9485 1.2
      ath9k: Add antenna diversity tweak for CUS198
      ath9k: Add one more PCI ID for CUS198
      ath9k: Fix ASPM for AR9462
      ath9k: Fix ASPM workaround usage
      ath9k: Fix TX poll work locking
      ath9k: Fix DEBUG_FS dependency for ath9k
      ath9k: Remove unused ANI commands
      ath9k: Enable D3/L1 ASPM fix for AR9462

Thierry Escande (1):
      NFC: Fix missing static declarations

Tobias Waldekranz (1):
      mwifiex: add missing endian conversions

Vasanthakumar Thiagarajan (1):
      ath6kl: Fix race in heart beat polling

Vladimir Kondratiev (2):
      wil6210: let IP stack re-check HW TCP/UDP csum errors
      cfg80211: add flags to cfg80211_rx_mgmt()

Wei Yongjun (2):
      mac80211_hwsim: fix error return code in init_mac80211_hwsim()
      zd1201: fix error return code

 Documentation/DocBook/80211.tmpl                   |   1 +
 MAINTAINERS                                        |   2 +-
 drivers/bcma/driver_pci.c                          |  65 ++-
 drivers/bcma/driver_pci_host.c                     |   6 +
 drivers/bluetooth/btmrvl_debugfs.c                 |   6 +-
 drivers/bluetooth/btmrvl_sdio.c                    |   4 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   5 +
 drivers/net/wireless/ath/ath10k/core.h             |   8 +
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  40 ++
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   2 +
 drivers/net/wireless/ath/ath10k/mac.c              |  79 +++-
 drivers/net/wireless/ath/ath10k/pci.c              |  70 ++-
 drivers/net/wireless/ath/ath10k/pci.h              |  11 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  87 +++-
 drivers/net/wireless/ath/ath10k/wmi.h              |   5 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |   1 +
 drivers/net/wireless/ath/ath5k/base.c              |  59 ++-
 drivers/net/wireless/ath/ath5k/base.h              |   2 +-
 drivers/net/wireless/ath/ath5k/debug.c             |  24 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   2 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |   2 +
 drivers/net/wireless/ath/ath5k/qcu.c               |  25 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   3 +
 drivers/net/wireless/ath/ath6kl/main.c             |   3 +
 drivers/net/wireless/ath/ath6kl/testmode.c         |   3 +-
 drivers/net/wireless/ath/ath6kl/testmode.h         |   7 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |   7 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   2 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   3 -
 drivers/net/wireless/ath/ath9k/ani.h               |  13 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   2 -
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  29 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   9 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  39 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   1 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   8 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   2 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |  24 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |  21 +
 drivers/net/wireless/ath/ath9k/common.c            |  67 +--
 drivers/net/wireless/ath/ath9k/common.h            |   3 +-
 drivers/net/wireless/ath/ath9k/debug.c             | 104 +----
 drivers/net/wireless/ath/ath9k/debug.h             |   4 -
 drivers/net/wireless/ath/ath9k/hif_usb.c           |  38 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   5 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |  10 +
 drivers/net/wireless/ath/ath9k/hw.c                |  19 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   2 +
 drivers/net/wireless/ath/ath9k/init.c              |  39 +-
 drivers/net/wireless/ath/ath9k/link.c              |   2 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   4 +-
 drivers/net/wireless/ath/ath9k/mac.h               |   2 +
 drivers/net/wireless/ath/ath9k/main.c              |  29 +-
 drivers/net/wireless/ath/ath9k/pci.c               |  67 +++
 drivers/net/wireless/ath/ath9k/rc.c                |   9 +-
 drivers/net/wireless/ath/ath9k/recv.c              | 506 ++++++++++++-----=
----
 drivers/net/wireless/ath/ath9k/reg.h               |   6 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  32 +-
 drivers/net/wireless/ath/carl9170/main.c           |   3 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  12 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   2 +-
 drivers/net/wireless/b43/main.c                    |  14 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  16 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   1 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  31 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   8 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    | 279 ++++++++++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 481 ++++++++++++-----=
---
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |   4 +
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |  21 +
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c | 228 +++++-----
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |   4 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   1 -
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  61 ++-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |  21 -
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |   3 -
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |  15 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  12 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  | 399 ++++++++++------
 .../wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c   | 405 +++++++++--------
 .../wireless/brcm80211/brcmsmac/phy/phytbl_lcn.h   |   1 +
 drivers/net/wireless/cw1200/bh.c                   |   4 +-
 drivers/net/wireless/cw1200/main.c                 |   2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   2 +-
 drivers/net/wireless/iwlwifi/Kconfig               |  13 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   2 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   2 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   7 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  10 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   5 +
 drivers/net/wireless/iwlwifi/mvm/constants.h       |   9 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              | 151 +++---
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  17 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |  24 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          | 228 +++++++---
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  29 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  27 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           | 199 +++++++-
 drivers/net/wireless/iwlwifi/mvm/rs.c              | 474 +++--------------=
--
 drivers/net/wireless/iwlwifi/mvm/rs.h              |  64 +--
 drivers/net/wireless/iwlwifi/mvm/rx.c              |  61 ++-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      | 103 +++--
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   9 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   6 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  43 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  31 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  38 +-
 drivers/net/wireless/mac80211_hwsim.c              |   5 +-
 drivers/net/wireless/mwifiex/11n.c                 |  16 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |   3 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   1 +
 drivers/net/wireless/mwifiex/decl.h                |   9 +
 drivers/net/wireless/mwifiex/fw.h                  |   2 +-
 drivers/net/wireless/mwifiex/init.c                |   1 +
 drivers/net/wireless/mwifiex/main.c                |  14 -
 drivers/net/wireless/mwifiex/main.h                |   3 +-
 drivers/net/wireless/mwifiex/sdio.c                |   6 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   2 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |  49 ++
 drivers/net/wireless/mwifiex/usb.c                 |  50 +-
 drivers/net/wireless/mwifiex/util.c                |   4 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   5 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            | 142 ++++--
 drivers/net/wireless/rt2x00/rt2800lib.h            |   4 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |  19 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |  12 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   6 +-
 drivers/net/wireless/rtl818x/rtl8180/grf5101.c     |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/grf5101.h     |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/max2820.c     |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/max2820.h     |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/rtl8225.c     |   4 +-
 drivers/net/wireless/rtl818x/rtl8180/sa2400.c      |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/sa2400.h      |   2 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   6 +-
 drivers/net/wireless/rtl818x/rtl8187/rtl8187.h     |   4 +-
 drivers/net/wireless/rtl818x/rtl8187/rtl8225.c     |   4 +-
 drivers/net/wireless/rtl818x/rtl8187/rtl8225.h     |   4 +-
 drivers/net/wireless/rtl818x/rtl818x.h             |   4 +-
 drivers/net/wireless/rtlwifi/ps.c                  |  16 +-
 drivers/net/wireless/ti/wlcore/main.c              |   3 +-
 drivers/net/wireless/ti/wlcore/testmode.c          |   3 +-
 drivers/net/wireless/ti/wlcore/testmode.h          |   3 +-
 drivers/net/wireless/zd1201.c                      |   8 +-
 drivers/nfc/nfcsim.c                               |   6 +-
 drivers/nfc/pn533.c                                | 389 ++++++++++++----
 drivers/nfc/pn544/i2c.c                            | 360 ++++++++++++++-
 drivers/nfc/pn544/mei.c                            |   2 +-
 drivers/nfc/pn544/pn544.c                          |  20 +-
 drivers/nfc/pn544/pn544.h                          |   7 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211.h    |   2 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c |   2 +-
 .../rtl8187se/ieee80211/ieee80211_softmac.c        |   2 +-
 .../rtl8187se/ieee80211/ieee80211_softmac_wx.c     |   2 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |   2 +-
 drivers/staging/rtl8187se/r8180.h                  |   2 +-
 drivers/staging/rtl8187se/r8180_93cx6.h            |   2 +-
 drivers/staging/rtl8187se/r8180_core.c             |   4 +-
 drivers/staging/rtl8187se/r8180_hw.h               |   2 +-
 drivers/staging/rtl8187se/r8180_rtl8225.h          |   2 +-
 drivers/staging/rtl8187se/r8180_rtl8225z2.c        |   2 +-
 drivers/staging/rtl8187se/r8180_wx.c               |   2 +-
 drivers/staging/rtl8187se/r8180_wx.h               |   2 +-
 drivers/staging/rtl8192e/rtl8192e/r8192E_dev.c     |   2 +-
 drivers/staging/rtl8192e/rtl8192e/r8192E_dev.h     |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_cam.c        |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_cam.h        |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c       |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.h       |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_eeprom.c     |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_eeprom.h     |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_ethtool.c    |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_pci.c        |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_pci.h        |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_ps.c         |   2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_ps.h         |   2 +-
 drivers/staging/rtl8192e/rtllib.h                  |   2 +-
 drivers/staging/rtl8192e/rtllib_debug.h            |   2 +-
 drivers/staging/rtl8192e/rtllib_rx.c               |   2 +-
 drivers/staging/rtl8192e/rtllib_softmac.c          |   2 +-
 drivers/staging/rtl8192e/rtllib_softmac_wx.c       |   2 +-
 drivers/staging/rtl8192e/rtllib_tx.c               |   2 +-
 drivers/staging/rtl8192u/authors                   |   2 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211.h     |   2 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |   2 +-
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c |   2 +-
 .../rtl8192u/ieee80211/ieee80211_softmac_wx.c      |   2 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c  |   2 +-
 drivers/staging/rtl8192u/r8180_93cx6.c             |   2 +-
 drivers/staging/rtl8192u/r8180_93cx6.h             |   2 +-
 drivers/staging/rtl8192u/r8180_pm.c                |   2 +-
 drivers/staging/rtl8192u/r8180_pm.h                |   2 +-
 drivers/staging/rtl8192u/r8190_rtl8256.h           |   2 +-
 drivers/staging/rtl8192u/r8192U.h                  |   2 +-
 drivers/staging/rtl8192u/r8192U_core.c             |   2 +-
 drivers/staging/rtl8192u/r8192U_hw.h               |   2 +-
 drivers/staging/rtl8192u/r8192U_wx.c               |   2 +-
 drivers/staging/rtl8192u/r8192U_wx.h               |   2 +-
 include/linux/bcma/bcma_driver_pci.h               |  24 +-
 include/linux/ieee80211.h                          |   4 +
 include/linux/platform_data/brcmfmac-sdio.h        |   6 +
 include/net/bluetooth/bluetooth.h                  |   8 +
 include/net/bluetooth/hci.h                        |   7 +
 include/net/bluetooth/hci_core.h                   |  10 +-
 include/net/bluetooth/sco.h                        |   1 +
 include/net/cfg80211.h                             |   8 +-
 include/net/mac80211.h                             | 110 ++++-
 include/net/nfc/nfc.h                              |   3 +
 include/uapi/linux/nfc.h                           |  20 +
 include/uapi/linux/nl80211.h                       |  16 +
 net/bluetooth/hci_conn.c                           |  62 ++-
 net/bluetooth/hci_core.c                           |  14 +-
 net/bluetooth/hci_event.c                          |  29 +-
 net/bluetooth/hidp/core.c                          |  40 +-
 net/bluetooth/l2cap_core.c                         |   3 +-
 net/bluetooth/rfcomm/tty.c                         | 271 +++++------
 net/bluetooth/sco.c                                |  85 +++-
 net/mac80211/cfg.c                                 |  15 +-
 net/mac80211/ibss.c                                | 226 +++++----
 net/mac80211/ieee80211_i.h                         |   3 -
 net/mac80211/iface.c                               |  19 +-
 net/mac80211/key.c                                 | 154 ++++++-
 net/mac80211/main.c                                |   3 -
 net/mac80211/mesh.c                                |   3 +
 net/mac80211/mlme.c                                |  20 +-
 net/mac80211/rate.c                                |  23 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   5 +-
 net/mac80211/rx.c                                  | 407 +++++++++--------
 net/mac80211/tx.c                                  |  14 +-
 net/mac80211/util.c                                |   2 +-
 net/nfc/core.c                                     |  22 +-
 net/nfc/hci/core.c                                 |   2 +-
 net/nfc/netlink.c                                  |  95 +++-
 net/nfc/nfc.h                                      |   5 +-
 net/rfkill/rfkill-regulator.c                      |   8 +-
 net/wireless/mlme.c                                |   4 +-
 net/wireless/nl80211.c                             |  80 ++--
 net/wireless/nl80211.h                             |   2 +-
 net/wireless/rdev-ops.h                            |   5 +-
 net/wireless/trace.h                               |   8 +-
 241 files changed, 5440 insertions(+), 2926 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSH5jAAAoJEJctW/TcYTgGOacP/iEfcLhjEvjaqxVDZGaC6fG+
94Ja0L1z8bwUIWm3Q2s/8Hqx6X3Q6c281/O3pCXX/htIqQBvJ7fzoOQaOg2Rbj+H
eC+xZoiWu4LHWI53inbeX73nLJKePpNMsaYyj5r2uHCNvZfTeY1kvkc6cio4ASd6
qwcwg11YTN0kRAg15+SwKSmjJSEyHmtd5BGATJGHWCJ6WBKyu8xsmPb2PRyXjp7y
N9/IvcgLLChfpfnBHaRJJ6wUU4j/79y/+gD8y3ePnuH8zj0+0bSvDgxVz/pSMlwl
9uSINPOChavyVbSTKSN7e1QWjtlKAqRp8EQjPOXkVZ8+x3bTkvNCFHu5s912mc++
lwTaZ1sabHxeoqIl/X9iAns0ZFcZcgK6eOMrEHAR2/gpSxHV5/5V75XhYyGt/HND
9GDvLzB9K8072FlgVKauypcXlFTh1rLJaty5ZZ5FkESAyyn9InmY/VdI1DWt8Pkj
41JBA3LfJmuHKDajhtY5Q/lmfRqv7y6rsdv9CI4Fh6I+PmGHHd7FQXcspDiFGPxe
iuF2p99I9IpBhs1IBPBVGYkgyelOoGL0zgHx/TyJNwEgF1JFHpZRv6U4CoCtOCLT
Vf49i0sVkH2pTQYO+BoLif5shW2dz3NHq4RrZC8GL4vzCyyEctVPPOkHCIQ+ez5A
5GgWdVpulSpaj4RRFANh
=NINg
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
