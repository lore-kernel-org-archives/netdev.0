From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-12-08
Date: Mon, 8 Dec 2014 14:32:23 -0500
Message-ID: <20141208193223.GA14086@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qxx1br4bt0+wmkIi"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37347 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbaLHTpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 14:45:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this last batch of pending wireless updates for the 3.19 tree...

For the wireless bits, Johannes says:

"This time I have Felix's no-status rate control work, which will allow
drivers to work better with rate control even if they don't have perfect
status reporting. In addition to this, a small hwsim fix from Patrik,
one of the regulatory patches from Arik, and a number of cleanups and
fixes I did myself.

Of note is a patch where I disable CFG80211_WEXT so that compatibility
is no longer selectable - this is intended as a wake-up call for anyone
who's still using it, and is still easily worked around (it's a one-line
patch) before we fully remove the code as well in the future."

For the Bluetooth bits, Johan says:

"Here's one more bluetooth-next pull request for 3.19:

 - Minor cleanups for ieee802154 & mac802154
 - Fix for the kernel warning with !TASK_RUNNING reported by Kirill A.
   Shutemov
 - Support for another ath3k device
 - Fix for tracking link key based security level
 - Device tree bindings for btmrvl + a state update fix
 - Fix for wrong ACL flags on LE links"

And...

"In addition to the previous one this contains two more cleanups to
mac802154 as well as support for some new HCI features from the
Bluetooth 4.2 specification.

=46rom the original request:

'Here's what should be the last bluetooth-next pull request for 3.19.
It's rather large but the majority of it is the Low Energy Secure
Connections feature that's part of the Bluetooth 4.2 specification. The
specification went public only this week so we couldn't publish the
corresponding code before that. The code itself can nevertheless be
considered fairly mature as it's been in development for over 6 months
and gone through several interoperability test events.

Besides LE SC the pull request contains an important fix for command
complete events for mgmt sockets which also fixes some leaks of hci_conn
objects when powering off or unplugging Bluetooth adapters.

A smaller feature that's part of the pull request is service discovery
support. This is like normal device discovery except that devices not
matching specific UUIDs or strong enough RSSI are filtered out.

Other changes that the pull request contains are firmware dump support
to the btmrvl driver, firmware download support for Broadcom BCM20702A0
variants, as well as some coding style cleanups in 6lowpan &
ieee802154/mac802154 code.'"

For the NFC bits, Samuel says:

"With this one we get:

- NFC digital improvements for DEP support: Chaining, NACK and ATN
  support added.

- NCI improvements: Support for p2p target, SE IO operand addition,
  SE operands extensions to support proprietary implementations, and
  a few fixes.

- NFC HCI improvements: OPEN_PIPE and NOTIFY_ALL_CLEARED support,
  and SE IO operand addition.

- A bunch of minor improvements and fixes for STMicro st21nfcb and
  st21nfca"

For the iwlwifi bits, Emmanuel says:

"Major works are CSA and TDLS. On top of that I have a new
firmware API for scan and a few rate control improvements.
Johannes find a few tricks to improve our CPU utilization
and adds support for a new spin of 7265 called 7265D.
Along with this a few random things that don't stand out."

And...

"I deprecate here -8.ucode since -9 has been published long ago.
Along with that I have a new activity, we have now better
a infrastructure for firmware debugging. This will allow to
have configurable probes insides the firmware.
Luca continues his work on NetDetect, this feature is now
complete. All the rest is minor fixes here and there."

For the Atheros bits, Kalle says:

"Only ath10k changes this time and no major changes. Most visible are:

o new debugfs interface for runtime firmware debugging (Yanbo)

o fix shared WEP (Sujith)

o don't rebuild whenever kernel version changes (Johannes)

o lots of refactoring to make it easier to add new hw support (Michal)

There's also smaller fixes and improvements with no point of listing
here."

In addition, there are a few last minute updates to ath5k,
ath9k, brcmfmac, brcmsmac, mwifiex, rt2x00, rtlwifi, and wil6210.
Also included is a pull of the wireless tree to pick-up the fixes
originally included in "pull request: wireless 2014-12-03"...

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 7d63a5f9b25ba6b130da8eb2d32a72b1462d0249:

  rtlwifi: Change order in device startup (2014-11-25 14:22:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-12-08

for you to fetch changes up to 81c412600f946fc1c8731685cb6c6fae8002043a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless (2014-12-08 13:58:58 -0500)

----------------------------------------------------------------

Amitkumar Karwar (9):
      Bluetooth: btmrvl: add DT bindings documentation
      Bluetooth: btmrvl: add DT-bindings for gpio-gap
      Bluetooth: btmrvl: update hs_state in interrupt handler
      mwifiex: fix sparse warning
      mwifiex: fix scan problem on big endian platforms
      mwifiex: skip delay main work logic for USB interface.
      mwifiex: add Tx status support for EAPOL packets
      mwifiex: add Tx status support for ACTION frames
      Bluetooth: btmrvl: remove extra newline character

Andreas Ruprecht (2):
      net: wireless: rtlwifi: Do not always include drivers in obj-m
      net: wireless: rtlwifi: rtl8192ee: Fix compilation of the driver

Andrei Otcheretianski (2):
      iwlwifi: mvm: Insert DS Parameter Set placeholder in probes
      iwlwifi: mvm: Handle failed beacon transmissions during CSA

Andrey Skvortsov (1):
      SSB / B44: fix WOL for BCM4401

Arend van Spriel (4):
      brcmfmac: fix static checker warning in pmklist handling
      brcmfmac: correct .disconnect() callback while connecting
      brcmutil: add helper function to format board revision
      brcmsmac: extend hardware info shown in debugfs

Arik Nemtsov (11):
      iwlwifi: mvm: expose some static APIs for use by TDLS code
      iwlwifi: pcie: support loading FW with extended mem range
      iwlwifi: mvm: declare TDLS support
      iwlwifi: mvm: add TDLS channel switch FW APIs
      iwlwifi: mvm: configure TDLS peers to FW
      iwlwifi: mvm: allow private per-STA TFD queues
      iwlwifi: mvm: disconnect TDLS peers on reconfig
      iwlwifi: mvm: use private TFD queues for TDLS stations
      iwlwifi: mvm: implement mac80211 TDLS channel-switch APIs
      iwlwifi: mvm: disconnect TDLS peers before channel switch
      cfg80211: leave invalid channels on regdomain change

Avinash Patil (4):
      mwifiex: do not delete station entries in del_sta handler
      mwifiex: delete peer station's RA list upon deauthentication
      mwifiex: guard station nodes access by station list lock
      mwifiex: do not process broadcast mac address for del_sta

Avri Altman (2):
      iwlwifi: mvm: New skip over dtim policy
      iwlwifi: mvm: Fix the keep_alive calculation

Axel Lin (1):
      NFC: llcp: Use list_for_each_entry in llcp_accept_poll

Ben Greear (3):
      ath10k: add ATH10K_DBG_WMI_PRINT debug level
      ath10k: apply chainmask settings to vdev on creation
      ath10k: use configured nss instead of max nss

Chaya Rachel Ivgy (1):
      iwlwifi: mvm: add support to MFUART loading notification

Christophe Ricard (25):
      NFC: st21nfca: Add of_st21nfca_i2c_match to MODULE_DEVICE_TABLE
      NFC: st21nfca: Remove gpio_irq field in static and dts configuration
      NFC: st21nfcb: Add of_st21nfcb_i2c_match to MODULE_DEVICE_TABLE
      NFC: st21nfcb: Remove gpio_irq field in static and dts configuration
      NFC: hci: Add se_io HCI operand
      NFC: nci: Fix sparse: symbol 'nci_get_prop_rf_protocol' was not decla=
red.
      NFC: nci: Update nci_discover_se to run proprietary commands to disco=
ver all available secure element
      NFC: nci: Update nci_enable_se to run proprietary commands to enable =
a secure element
      NFC: nci: Update nci_disable_se to run proprietary commands to disabl=
e a secure element
      NFC: nci: Add se_io NCI operand
      NFC: st21nfca: Rework st21nfca_hci_event_received to route event to r=
elevent gate.
      NFC: st21nfcb: Improve ndlc comment
      NFC: hci: Add open pipe command handler
      NFC: hci: Add support for NOTIFY_ALL_PIPE_CLEARED
      NFC: st21nfcb: Remove useless pr_info
      NFC: nci: Add status byte management in case of error.
      NFC: nci: Add management for NCI state for machine rf_deactivate_ntf
      NFC: nci: Add support for different NCI_DEACTIVATE_TYPE
      NFC: netlink: Add new netlink command NFC_CMD_ACTIVATE_TARGET
      NFC: Add se_io NFC operand
      NFC: hci: Add specific hci macro to not create a pipe
      NFC: st21nfca: Report error returned by functions instead of -ENODEV
      NFC: st21nfcb: Fix reported error
      NFC: Fix warning "warning: incorrect type in assignment"
      NFC: nci: Fix warning: cast to restricted __le16

Dan Carpenter (1):
      brcmsmac: NULL dereferences in brcms_c_detach_mfree()

David Spinadel (4):
      iwlwifi: mvm: implement UMAC scan API
      iwlwifi: mvm: go to umac scan even if lmac tlv bit is on
      iwlwifi: mvm: remove warning on unknown scan complete
      iwlwifi: mvm: remove a dangling line of documentation

Dmitry Tunin (1):
      Bluetooth: ath3k: Add support of MCI 13d3:3408 bt device

Eliad Peller (9):
      iwlwifi: mvm/trans: abort d0i3_enter in case of held ref
      iwlwifi: mvm: wake up d0i3_exit_waitq when aborting d0i3
      iwlwifi: mvm: move deferred d0i3 exit to resume_complete op
      iwlwifi: mvm: disable beacon filtering escape timer
      iwlwifi: trans: add suspend/resume ops
      iwlwifi: mvm: call iwl_trans_suspend/resume
      iwlwifi: declare d0i3 support for IWL_DEVICE_8000
      iwlwifi: mvm: add missing mvm ref debug print
      iwlwifi: pcie: refactor cmd_in_flight set/clear code

Emmanuel Grumbach (19):
      iwlwfifi: fix WANT_DEV_COREDUMP selection in Kconfig
      iwlwifi: mvm: rs - don't use the shared antenna when BT load is high
      iwlwifi: pcie: introduce delay when waking up the device
      iwlwifi: pcie: newer platform needs a OS alive indication
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: mvm: add support for WMM Access Control
      iwlwifi: mvm: BT Coex - add support for TTC / RRC
      iwlwifi: pcie: properly reset the device
      iwlwifi: update the secure mem space and for the CPUs
      Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwifi-next
      iwlwifi: deprecate -8.ucode for 3160 / 7260 / 7265
      iwlwifi: mvm: remove IWL_UCODE_TLV_CAPA_EXTENDED_BEACON
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_WOWLAN_CONFIG_TID
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_CSA_FLOW
      iwlwifi: mvm: BT Coex - change the MPLUT registers' value
      iwlwifi: don't load on 7265D with old NVM
      iwlwifi: pcie: claim ownership on the device after stop_device()
      iwlwifi: dvm: fix flush support for old firmware
      iwlwifi: mvm: update values for Smart Fifo

Eran Harary (3):
      iwlwifi: change max HT and VHT A-MPDU exponent
      iwlwifi: mvm: support ucode load for family_8000 B0 only
      iwlwifi: mvm: Ability to work with packed usniffer image

Eyal Shapira (5):
      iwlwifi: mvm: handle error from iwl_trans_update_sf
      iwlwifi: mvm: rs: fix a WARNING in case of STBC and VHT
      iwlwifi: mvm: rs: fix getting stuck in a test window
      iwlwifi: mvm: rs: consider a missing BA as a single tx failure
      iwlwifi: mvm: declare support for VHT BF info in radiotap

Felix Fietkau (15):
      mac80211: copy chandef from AP vif to VLANs
      mac80211: add more missing checks for VHT tx rates
      mac80211: minstrel_ht: move aggregation check to .get_rate()
      mac80211: add tx_status_noskb to rate_control_ops
      mac80211: minstrel: switch to .tx_status_noskb
      mac80211: minstrel_ht: switch to .tx_status_noskb
      mac80211: pass tx info to ieee80211_lost_packet instead of an skb
      mac0211: add a helper function for fixing up tx status rates
      mac80211: add ieee80211_tx_status_noskb
      ath9k_hw: fix hardware queue allocation
      ath9k: fix BE/BK queue order
      ath5k: fix hardware queue index assignment
      ath9k: prevent early IRQs from accessing hardware
      ath9k: set ATH_OP_INVALID before disabling hardware
      ath9k: do not access hardware on IRQs during reset

Franky Lin (1):
      brcmfmac: switch to single message MSI

Hante Meuleman (6):
      brcmfmac: Fix bitmap malloc bug in msgbuf.
      brcmfmac: Fix ifidx for rx data by msgbuf.
      brcmfmac: Add PCIE ids for 43602 devices.
      brcmfmac: Fix vendor cmds used interface.
      brcmfmac: Add ifidx to logging of fwil cmds.
      brcmfmac: add multiple BSS support.

Heinrich Siebmanns (1):
      Bluetooth: Add support for Broadcom BCM20702A0 variants firmware down=
load

Idan Kahlon (1):
      iwlwifi: mvm: support NVM file with header

Jakub Pawlowski (4):
      Bluetooth: Add definitions for MGMT_OP_START_SERVICE_DISCOVERY
      Bluetooth: Add extra discovery fields for storing filter information
      Bluetooth: Add logic for UUID filter handling
      Bluetooth: Add support for Start Service Discovery command

Johan Hedberg (65):
      Bluetooth: Fix setting state back to TASK_RUNNING
      Bluetooth: Fix setting conn->pending_sec_level value from link key
      Bluetooth: Convert link keys list to use RCU
      Bluetooth: Track both local and remote L2CAP fixed channel mask
      Bluetooth: Simplify Link Key Notification event handling logic
      Bluetooth: Add basic SMP defines for LE Secure Connections
      Bluetooth: Make auth_req mask dependent on SC enabled or not
      Bluetooth: Add SMP flag for SC and set it when necessary.
      Bluetooth: Update SMP security level to/from auth_req for SC
      Bluetooth: Add mgmt support for LE Secure Connections LTK types
      Bluetooth: Set the correct security level for SC LTKs
      Bluetooth: Use custom macro for testing BR/EDR SC enabled
      Bluetooth: Add mgmt_set_secure_conn support for any LE adapter
      Bluetooth: Update LTK lookup to correctly deal with SC LTKs
      Bluetooth: Remove unused hci_find_ltk function
      Bluetooth: Rename hci_find_ltk_by_addr to hci_find_ltk
      Bluetooth: Set link key generation bit if necessary for LE SC
      Bluetooth: Add basic support for AES-CMAC
      Bluetooth: Add ECC library for LE Secure Connections
      Bluetooth: Add basic support for sending our LE SC public key
      Bluetooth: Add handler function for receiving LE SC public key
      Bluetooth: Add support for sending LE SC Confirm value
      Bluetooth: Add LE SC support for responding to Pairing Confirm PDU
      Bluetooth: Add support for LE SC numeric comparison
      Bluetooth: Add support for handling LE SC user response
      Bluetooth: Add support for LE SC DHKey check PDU
      Bluetooth: Add support for LE SC key generation
      Bluetooth: Track authentication method in SMP context
      Bluetooth: Add selection of the SC authentication method
      Bluetooth: Detect SMP SC debug keys
      Bluetooth: Add check for accidentally generating a debug key
      Bluetooth: Set correct LTK type and authentication for SC
      Bluetooth: Add support for SC just-works pairing
      Bluetooth: Fix BR/EDR Link Key type when derived through LE SC
      Bluetooth: Add passkey entry support for LE SC
      Bluetooth: Fix DHKey Check sending order for slave role
      Bluetooth: Add dummy handler for LE SC keypress notification
      Bluetooth: Use debug keys for SMP when HCI_USE_DEBUG_KEYS is set
      Bluetooth: Add hci_conn flag for new link key generation
      Bluetooth: Add debugfs switch for forcing SMP over BR/EDR
      Bluetooth: Add skeleton for BR/EDR SMP channel
      Bluetooth: Add full SMP BR/EDR support
      Bluetooth: Add SC-only mode support for SMP
      Bluetooth: Unify remote OOB data functions
      Bluetooth: Store address type with OOB data
      Bluetooth: Add support for adding remote OOB data for LE
      Bluetooth: Set SMP OOB flag if OOB data is available
      Bluetooth: Add basic LE SC OOB support for remote OOB data
      Bluetooth: Introduce SMP_DBG macro for low-level debuging
      Bluetooth: Fix missing const declarations in SMP functions
      Bluetooth: Organize SMP crypto functions to logical sections
      Bluetooth: Fix SMP debug key handling
      Bluetooth: Fix minor coding style issue in smp.c
      Bluetooth: Fix false-positive "uninitialized" compiler warning
      Bluetooth: Add callback to create proper cmd_complete events
      Bluetooth: Store parameter length with pending mgmt commands
      Bluetooth: Convert Disconnect mgmt command to use cmd_complete callba=
ck
      Bluetooth: Use cmd_complete callback for authentication mgmt commands
      Bluetooth: Convert Pair Device to use cmd_complete callback
      Bluetooth: Convert Unpair Device to use cmd_complete callback
      Bluetooth: Convert discovery commands to use cmd_complete callback
      Bluetooth: Convert Get Clock Info to use cmd_complete callback
      Bluetooth: Fix initializing hci_conn RSSI to invalid value
      Bluetooth: Fix Get Conn Info to use cmd_complete callback
      Bluetooth: Remove redundant reverse_base_uuid variable

Johannes Berg (23):
      iwlwifi: mvm: use correct type for firmware status
      iwlwifi: mvm: rs: don't use shadowing variable
      iwlwifi: mvm: don't capture firmware coredump for D3->D0 reconfig
      iwlwifi: mvm: support random MAC address for scanning
      iwlwifi: pcie: support 7265-D devices
      iwlwifi: mvm: use unsigned for ssid_bitmap
      iwlwifi: mvm: refactor key add/remove functions
      iwlwifi: mvm: add WEP RX hardware offload support
      iwlwifi: build mac80211 rx_status in place
      iwlwifi: mvm: pull crypto header into skb->head
      iwlwifi: mvm: pull SNAP header into skb->head
      ath10k: don't rebuild all the time
      Revert "mac80211_hwsim: VHT add 160MHz width support"
      mac80211: disable 80+80/160 in VHT correctly
      cfg80211: remove pointless channel lookup in survey code
      mac80211: check if channels allow 80 MHz for VHT probe requests
      cfg80211: refactor the various CQM event sending code
      cfg80211: clean up beacon loss CQM event
      nl80211: don't crash sending invalid chandef
      cfg80211: make WEXT compatibility unselectable
      NFC: Don't include linux/unaligned/access_ok.h
      cfg80211: remove unneeded initialisations in nl80211_set_reg
      iwlwifi: move firmware file format definitions to correct header

John W. Linville (9):
      Merge tag 'iwlwifi-next-for-john-2014-11-24' of git://git.kernel.org/=
=2E../iwlwifi/iwlwifi-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge tag 'iwlwifi-next-for-john-2014-12-02' of git://git.kernel.org/=
=2E../iwlwifi/iwlwifi-next
      Merge tag 'nfc-next-3.19-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge git://git.kernel.org/.../jberg/mac80211-next
      MAINTAINERS: orphan rtl8180
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

Julien Lefrique (10):
      NFC: NCI: Add passive Listen modes in discover request
      NFC: NCI: Enable NFC-DEP in Listen A and Listen F
      NFC: NCI: Handle Target mode activation
      NFC: NCI: Configure ATR_RES general bytes
      NFC: NCI: Implement Target mode send function
      NFC: NCI: Forward data received in Target mode to nfc core
      NFC: Fix a memory leak
      NFC: NCI: Handle Discovery deactivation type
      NFC: NCI: Signal deactivation in Target mode
      NFC: NCI: Fix max length of General Bytes in ATR_RES

Larry Finger (3):
      rtlwifi: rtl8192ce: Fix editing error that causes silent memory corru=
ption
      rtlwifi: rtl8192ce: Fix kernel crashes due to missing callback entry
      rtlwifi: rtl8192ce: Fix missing interrupt ready flag

Liad Kaufman (8):
      iwlwifi: mvm: fix init_dbg flow to work as expected
      iwlwifi: mvm: block TID when using TDLS
      iwlwifi: pcie: add fh registers to dump data
      iwlwifi: use correct fw file in 8000 b-step
      iwlwifi: define the .ucode file format for debug
      iwlwifi: mvm: send dbg config hcmds to fw if set in tlv
      iwlwifi: pcie: config regs according to fw tlv
      iwlwifi: pcie: support more monitor types dumping

Lino Sanfilippo (1):
      wil6210: Fix potential memory leaks on error paths

Lorenzo Bianconi (3):
      rtlwifi: update RCR register in rtl_op_configure_filter()
      ath9k: add TX power per-rate tables
      ath9k: add TPC capability to TX descriptor path

Luciano Coelho (24):
      iwlwifi: mvm: refactor temperature notification handling
      iwlwifi: mvm: handle unsolicited DTS_MEASUREMENT_NOTIFICATIONs
      iwlwifi: mvm: make nd_ies part of the mvm struct
      iwlwifi: mvm: use new pre_channel_switch op instead of channel_switch=
_beacon
      iwlwifi: mvm: only save csa_vif in AP/GO mode
      iwlwifi: mvm: refactor iwl_mvm_switch_vif_chanctx to support other mo=
des
      iwlwifi: mvm: add support for CHANCTX_SWMODE_REASSIGN_VIF
      iwlwifi: mvm: return the actual error code when switch_vif_chanctx fa=
ils
      iwlwifi: mvm: disable PS during channel switch
      iwlwifi: mvm: use switching_chanctx argument instead of csa_active
      iwlwifi: mvm: add CSA absent time event for clients
      iwlwifi: mvm: schedule CSA time event a bit before beacon 1
      iwlwifi: mvm: finalize on post_switch instead of unassign
      iwlwifi: mvm: add a channel_switch op to bypass mac80211 timer
      iwlwifi: mvm: disable beacon filtering during CSA
      iwlwifi: mvm: clear TE data if CSA time event fails to start
      iwlwifi: mvm: protect session during CSA
      iwlwifi: mvm: add support for net detect
      iwlwifi: mvm: refactor wowlan and netdetect configuration when suspen=
ding
      iwlwifi: mvm: refactor iwl_mvm_query_wakeup_reasons()
      iwlwifi: mvm: treat netdetect wake up separately
      iwlwifi: mvm: check and report if wake up was due to net detect
      iwlwifi: mvm: add SSID match information for net-detect
      iwlwifi: mvm: add channel information to the netdetect notifications

Marcel Holtmann (19):
      Bluetooth: Increase minor version of core module
      Bluetooth: Increment management interface revision
      Bluetooth: Simplify the error handling of Start Discovery command
      Bluetooth: Use {start,stop}_discovery_complete handler for cmd_comple=
te
      Bluetooth: Split triggering of discovery commands into separate funct=
ion
      Bluetooth: Add HCI_RSSI_INVALID for unknown RSSI value
      Bluetooth: Filter device found events based on RSSI threshold
      Bluetooth: Add framework for device found filtering based on UUID
      Bluetooth: Add helper function for clearing the discovery filter
      Bluetooth: Fix memory leaks from discovery filter UUID list
      Bluetooth: Clear discovery filter before starting background scan
      Bluetooth: Fix discovery filter when no RSSI is available
      Bluetooth: Report invalid RSSI for service discovery and background s=
can
      Bluetooth: Move LE advertising report defines to the right location
      Bluetooth: Add definitions for LE Direct Advertising Report event
      Bluetooth: Enabled LE Direct Advertising Report event if supported
      Bluetooth: Add support for handling LE Direct Advertising Report even=
ts
      Bluetooth: Add support for enabling Extended Scanner Filter Policies
      Bluetooth: Enable events for P-256 Public Key and DHKey commands

Mark A. Greer (13):
      NFC: digital: Fix potential skb leaks in NFC-DEP code
      NFC: digital: Rearrange NFC-DEP DEP_REQ/DEP_RES Code
      NFC: digital: Ensure no DID in NFC-DEP responses
      NFC: digital: Add Target-mode NFC-DEP DID Support
      NFC: digital: Ensure no NAD byte in DEP_REQ and DEP_RES frames
      NFC: digital: Enforce NFC-DEP PNI sequencing
      NFC: digital: Implement NFC-DEP max payload lengths
      NFC: digital: Add NFC-DEP Send Chaining Support
      NFC: digital: Add NFC-DEP Receive Chaining Support
      NFC: digital: Add NFC-DEP Initiator-side NACK Support
      NFC: digital: Add NFC-DEP Target-side NACK Support
      NFC: digital: Add NFC-DEP Initiator-side ATN Support
      NFC: digital: Add NFC-DEP Target-side ATN Support

Matti Gottlieb (1):
      iwlwifi: mvm: add remove flow for AUX ROC time events

Michal Kazior (23):
      ath10k: start using sk_buff_head
      ath10k: simplify Rx loop
      ath10k: refactor htt->rx_confused
      ath10k: unify rx undecapping
      ath10k: remove unused function argument
      ath10k: use rx descriptor for ppdu status extraction
      ath10k: report rx rate and signal for fragmented Rx
      ath10k: remove extra_tx_headroom
      ath10k: fix offchan reliability
      ath10k: make hw roc more reliable
      ath10k: fix offchannel cancel failures
      ath10k: don't drop corrupted mgmt frames
      ath10k: add missing goto
      ath10k: clean up num_peers locking
      ath10k: fix station count enforcement
      ath10k: add pointer constness to traces
      ath10k: fix wmi svc bitmap dbg print
      ath10k: add sanity checks for service bmap parsing
      ath10k: make wmi service bitmap non-debug
      ath10k: remove unused callback argument from struct ath10k_hif_cb::rx=
_completion
      ath10k: remove transfer_id from ath10k_hif_cb::tx_completion
      ath10k: prevent pci tx/rx starvation
      ath10k: simplify rx ring size/fill calculation

Oren Givon (2):
      iwlwifi: sdio: new SDIO card id for 4165 series
      iwlwifi: fix 4165 series name

Patrik Flykt (1):
      mac80211_hwsim: Send alpha2 only if non-zero

Ricardo Ribalda Delgado (1):
      wireless/p54: Remove duplicated net2280 header

Stanislaw Gruszka (5):
      rt2800: calculate tx power temperature compensation on selected chips
      rt2x00: use timeout in rt2x00usb_vendor_request
      rt2x00: change REGISTER_BUSY_COUNT for USB
      rt2x00: change REGISTER_TIMEOUT
      Revert "rt2x00: Endless loop on hub port power down"

Stefan Schmidt (5):
      net/6lowpan: Remove FSF address from GPL statement.
      net/ieee802154: Make sure alignment matches parenthesis..
      net/ieee802154: Remove and add extra blank lines as needed.
      net/mac802154: Remove extra blank lines.
      net/mac802154: No need for an extra space when casting

Steven Walter (1):
      Bluetooth: Automatically flushable packets aren't allowed on LE links

Sujith Manoharan (3):
      ath10k: fix shared WEP
      ath10k: fix locking for WEP keys
      ath10k: fix bug reported by lockdep

Varka Bhadram (4):
      ieee802154: fix spelling mistakes
      mac802154: remove unnecessary if statement
      mac802154: use goto label on failure
      cc2520: adds terminating newline

Vivek Natarajan (2):
      ath: Fix a false radar detection pattern
      ath10k: do not limit RTS threshold value to 2347

Vladimir Kondratiev (9):
      wil6210: propagate disconnect reason
      wil6210: add handling of RX HTRSH interrupt
      wil6210: fix recovery after scan timeout
      wil6210: remove wil_to_pcie_dev()
      wil6210: configurable vring sizes
      wil6210: fix warning in pointer arithmetic
      wil6210: Rate limit "ring full" error message
      wil6210: reset flow update
      wil6210: remove TODO wrt buffer alignment

Xinming Hu (1):
      Bluetooth: btmrvl add firmware dump support

Yanbo Li (2):
      ath10k: add register access debugfs interface
      ath10k: add memory dump debugfs interface

 Documentation/devicetree/bindings/btmrvl.txt       |   29 +
 Documentation/devicetree/bindings/bus/bcma.txt     |   21 +
 MAINTAINERS                                        |   18 +-
 drivers/bcma/bcma_private.h                        |    1 +
 drivers/bcma/driver_chipcommon.c                   |    2 +-
 drivers/bcma/driver_gpio.c                         |    4 +-
 drivers/bcma/driver_mips.c                         |   11 +-
 drivers/bcma/driver_pci_host.c                     |    4 +-
 drivers/bcma/main.c                                |   79 +-
 drivers/bcma/scan.c                                |    1 +
 drivers/bluetooth/Kconfig                          |    1 +
 drivers/bluetooth/ath3k.c                          |    4 +
 drivers/bluetooth/btmrvl_debugfs.c                 |   31 +
 drivers/bluetooth/btmrvl_drv.h                     |   20 +
 drivers/bluetooth/btmrvl_main.c                    |   68 +-
 drivers/bluetooth/btmrvl_sdio.c                    |  304 +++-
 drivers/bluetooth/btmrvl_sdio.h                    |    5 +
 drivers/bluetooth/btusb.c                          |   14 +-
 drivers/bluetooth/hci_ath.c                        |    2 +-
 drivers/bluetooth/hci_h5.c                         |   25 +
 drivers/net/ethernet/broadcom/b44.c                |    2 +
 drivers/net/ieee802154/Kconfig                     |   10 -
 drivers/net/ieee802154/Makefile                    |    1 -
 drivers/net/ieee802154/at86rf230.c                 |  445 +++---
 drivers/net/ieee802154/cc2520.c                    |   73 +-
 drivers/net/ieee802154/fakehard.c                  |  427 -----
 drivers/net/ieee802154/fakelb.c                    |   91 +-
 drivers/net/ieee802154/mrf24j40.c                  |  104 +-
 drivers/net/wireless/ath/ath.h                     |   13 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   92 +-
 drivers/net/wireless/ath/ath10k/ce.h               |   21 +-
 drivers/net/wireless/ath/ath10k/core.c             |  154 +-
 drivers/net/wireless/ath/ath10k/core.h             |  100 +-
 drivers/net/wireless/ath/ath10k/debug.c            | 1154 +++++++++++---
 drivers/net/wireless/ath/ath10k/debug.h            |   46 +-
 drivers/net/wireless/ath/ath10k/hif.h              |   53 +-
 drivers/net/wireless/ath/ath10k/htc.c              |   13 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    9 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           | 1256 +++++++--------
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   11 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   32 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  746 +++++----
 drivers/net/wireless/ath/ath10k/mac.h              |    6 +
 drivers/net/wireless/ath/ath10k/pci.c              |  579 ++++---
 drivers/net/wireless/ath/ath10k/spectral.c         |   34 +-
 drivers/net/wireless/ath/ath10k/spectral.h         |    8 +-
 drivers/net/wireless/ath/ath10k/trace.h            |  207 ++-
 drivers/net/wireless/ath/ath10k/txrx.c             |    4 +-
 drivers/net/wireless/ath/ath10k/wmi.c              | 1179 ++++++++------
 drivers/net/wireless/ath/ath10k/wmi.h              |  401 ++---
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    6 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    8 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    4 +-
 drivers/net/wireless/ath/ath6kl/common.h           |    2 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |   28 +-
 drivers/net/wireless/ath/ath6kl/debug.h            |   13 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |    9 -
 drivers/net/wireless/ath/ath9k/Kconfig             |    7 +
 drivers/net/wireless/ath/ath9k/Makefile            |    9 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    7 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   42 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    8 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |    9 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   11 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   56 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   54 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  181 ++-
 drivers/net/wireless/ath/ath9k/ar9003_rtt.h        |   36 +
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   |  498 +++++-
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   |    8 +-
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |  144 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   27 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    5 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    6 +-
 drivers/net/wireless/ath/ath9k/calib.h             |    2 +-
 drivers/net/wireless/ath/ath9k/channel.c           |  338 ++--
 .../ath/ath9k/{spectral.c =3D> common-spectral.c}    |  165 +-
 .../ath/ath9k/{spectral.h =3D> common-spectral.h}    |   29 +-
 drivers/net/wireless/ath/ath9k/common.c            |    2 +-
 drivers/net/wireless/ath/ath9k/common.h            |    1 +
 drivers/net/wireless/ath/ath9k/debug.c             |   60 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   31 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    9 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    5 +
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |    6 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   25 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   13 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   16 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    7 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   98 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   43 +-
 drivers/net/wireless/ath/ath9k/init.c              |   73 +-
 drivers/net/wireless/ath/ath9k/link.c              |   12 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    9 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |  361 +++--
 drivers/net/wireless/ath/ath9k/pci.c               |   10 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   38 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |    4 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   37 +-
 drivers/net/wireless/ath/carl9170/phy.c            |    4 +-
 drivers/net/wireless/ath/dfs_pattern_detector.c    |    4 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |    7 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    5 +-
 drivers/net/wireless/ath/wil6210/debug.c           |   17 +
 drivers/net/wireless/ath/wil6210/debugfs.c         |    8 +-
 drivers/net/wireless/ath/wil6210/fw.c              |    1 -
 drivers/net/wireless/ath/wil6210/fw_inc.c          |    4 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   30 +-
 drivers/net/wireless/ath/wil6210/main.c            |  136 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    2 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   18 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |    4 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   26 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   10 +-
 drivers/net/wireless/b43/main.c                    |    7 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c     |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   51 +-
 drivers/net/wireless/brcm80211/brcmfmac/btcoex.c   |    6 +-
 .../brcm80211/brcmfmac/{dhd_bus.h =3D> bus.h}        |   11 +-
 .../brcmfmac/{wl_cfg80211.c =3D> cfg80211.c}         |  338 +++-
 .../brcmfmac/{wl_cfg80211.h =3D> cfg80211.h}         |   11 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/common.c   |  168 ++
 .../net/wireless/brcm80211/brcmfmac/commonring.c   |    2 +-
 .../brcm80211/brcmfmac/{dhd_linux.c =3D> core.c}     |   47 +-
 .../wireless/brcm80211/brcmfmac/{dhd.h =3D> core.h}  |   10 +-
 .../brcm80211/brcmfmac/{dhd_dbg.c =3D> debug.c}      |    6 +-
 .../brcm80211/brcmfmac/{dhd_dbg.h =3D> debug.h}      |    6 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  400 -----
 drivers/net/wireless/brcm80211/brcmfmac/feature.c  |   34 +-
 drivers/net/wireless/brcm80211/brcmfmac/feature.h  |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |  102 +-
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   95 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   19 +-
 drivers/net/wireless/brcm80211/brcmfmac/of.c       |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/proto.c    |    6 +-
 .../brcm80211/brcmfmac/{dhd_sdio.c =3D> sdio.c}      |   55 +-
 .../brcm80211/brcmfmac/{sdio_host.h =3D> sdio.h}     |    8 +-
 .../net/wireless/brcm80211/brcmfmac/tracepoint.c   |   15 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  142 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb_rdl.h  |   75 -
 drivers/net/wireless/brcm80211/brcmfmac/vendor.c   |   21 +-
 drivers/net/wireless/brcm80211/brcmsmac/debug.c    |  180 ++-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    7 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   29 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |   16 +
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |    2 +
 .../net/wireless/brcm80211/include/brcmu_utils.h   |    2 +
 drivers/net/wireless/cw1200/scan.c                 |    2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    2 +-
 drivers/net/wireless/ipw2x00/libipw.h              |    5 -
 drivers/net/wireless/ipw2x00/libipw_module.c       |   15 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |   21 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/4965.h               |    5 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    1 +
 drivers/net/wireless/iwlwifi/dvm/commands.h        |   31 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |   51 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    1 +
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   48 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |   28 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   23 +
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   39 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    3 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  198 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |    3 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |  308 ++++
 drivers/net/wireless/iwlwifi/iwl-fw.h              |  244 +--
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    5 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    3 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   25 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |   29 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |   33 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    7 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  618 +++++---
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  200 ++-
 drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h     |    9 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |    6 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  297 ++++
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  179 ++-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   74 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |  106 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  531 +++++--
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  154 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   31 +-
 drivers/net/wireless/iwlwifi/mvm/offloading.c      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   87 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    4 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |   40 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  123 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |    2 +
 drivers/net/wireless/iwlwifi/mvm/rx.c              |  150 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  786 ++++++++-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |  303 +++-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    5 +
 drivers/net/wireless/iwlwifi/mvm/tdls.c            |  569 ++++++-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |  146 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    4 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   75 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   45 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   37 +
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   20 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  404 +++--
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   99 +-
 drivers/net/wireless/mac80211_hwsim.c              |  660 +++++++-
 drivers/net/wireless/mac80211_hwsim.h              |   28 +-
 drivers/net/wireless/mwifiex/11n.c                 |    4 +
 drivers/net/wireless/mwifiex/11n.h                 |    4 +
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |    6 +
 drivers/net/wireless/mwifiex/Kconfig               |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  130 +-
 drivers/net/wireless/mwifiex/decl.h                |   19 +
 drivers/net/wireless/mwifiex/fw.h                  |   34 +-
 drivers/net/wireless/mwifiex/init.c                |   22 +-
 drivers/net/wireless/mwifiex/join.c                |    4 +-
 drivers/net/wireless/mwifiex/main.c                |  123 +-
 drivers/net/wireless/mwifiex/main.h                |   63 +-
 drivers/net/wireless/mwifiex/scan.c                |   78 +-
 drivers/net/wireless/mwifiex/sdio.c                |    2 +
 drivers/net/wireless/mwifiex/sdio.h                |    7 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/mwifiex/sta_event.c           |   14 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    4 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |    3 +
 drivers/net/wireless/mwifiex/sta_tx.c              |    6 +
 drivers/net/wireless/mwifiex/tdls.c                |  288 ++++
 drivers/net/wireless/mwifiex/txrx.c                |   35 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/uap_event.c           |    5 +
 drivers/net/wireless/mwifiex/uap_txrx.c            |   11 +-
 drivers/net/wireless/mwifiex/usb.c                 |   51 +-
 drivers/net/wireless/mwifiex/usb.h                 |    3 +
 drivers/net/wireless/mwifiex/util.c                |   38 +
 drivers/net/wireless/mwifiex/wmm.c                 |   42 +-
 drivers/net/wireless/mwl8k.c                       |    7 +-
 drivers/net/wireless/p54/net2280.h                 |  451 ------
 drivers/net/wireless/p54/p54usb.h                  |   13 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   18 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   45 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   12 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   28 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   41 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |   21 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    3 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   24 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |    2 +
 drivers/net/wireless/rtlwifi/rtl8192ee/Makefile    |    5 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |    3 -
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile    |    3 -
 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile    |    3 -
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c       |   12 +-
 drivers/net/wireless/ti/wl1251/main.c              |    2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   15 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    2 -
 drivers/net/wireless/ti/wlcore/event.c             |    5 +-
 drivers/net/wireless/ti/wlcore/main.c              |   23 +-
 drivers/nfc/pn544/i2c.c                            |    2 +-
 drivers/nfc/st21nfca/i2c.c                         |   41 +-
 drivers/nfc/st21nfca/st21nfca.c                    |   32 +-
 drivers/nfc/st21nfca/st21nfca.h                    |    2 -
 drivers/nfc/st21nfca/st21nfca_dep.c                |   47 +-
 drivers/nfc/st21nfca/st21nfca_dep.h                |    4 +-
 drivers/nfc/st21nfcb/i2c.c                         |   39 +-
 drivers/nfc/st21nfcb/ndlc.c                        |    2 +-
 drivers/ssb/pcihost_wrapper.c                      |   33 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |    4 +-
 drivers/staging/vt6656/main_usb.c                  |    7 +-
 include/linux/ath9k_platform.h                     |    3 +
 include/linux/bcma/bcma.h                          |    2 +
 include/linux/bcma/bcma_driver_mips.h              |    4 +-
 include/linux/ieee80211.h                          |   71 +-
 include/{net =3D> linux}/ieee802154.h                |   61 +-
 include/linux/netdevice.h                          |    3 +
 include/linux/nl802154.h                           |    4 -
 include/linux/platform_data/st21nfca.h             |    1 -
 include/linux/platform_data/st21nfcb.h             |    1 -
 include/net/6lowpan.h                              |   12 +-
 include/net/af_ieee802154.h                        |    4 -
 include/net/bluetooth/hci.h                        |   68 +-
 include/net/bluetooth/hci_core.h                   |   78 +-
 include/net/bluetooth/l2cap.h                      |   21 +-
 include/net/bluetooth/mgmt.h                       |   24 +-
 include/net/cfg80211.h                             |  241 ++-
 include/net/cfg802154.h                            |  161 ++
 include/net/ieee802154_netdev.h                    |   18 +-
 include/net/mac80211.h                             |  319 +++-
 include/net/mac802154.h                            |  158 +-
 include/net/nfc/digital.h                          |   13 +
 include/net/nfc/hci.h                              |    4 +
 include/net/nfc/nci.h                              |   37 +-
 include/net/nfc/nci_core.h                         |    9 +
 include/net/nfc/nfc.h                              |    2 +
 include/net/nl802154.h                             |  226 ++-
 include/net/regulatory.h                           |   12 +
 include/net/wpan-phy.h                             |  105 --
 include/uapi/linux/nfc.h                           |   23 +-
 include/uapi/linux/nl80211.h                       |  147 +-
 net/6lowpan/iphc.c                                 |  103 +-
 net/bluetooth/6lowpan.c                            |  300 ++--
 net/bluetooth/Kconfig                              |   21 +-
 net/bluetooth/Makefile                             |    2 +-
 net/bluetooth/af_bluetooth.c                       |    2 +-
 net/bluetooth/amp.c                                |   25 +-
 net/bluetooth/bnep/Kconfig                         |    2 +-
 net/bluetooth/cmtp/Kconfig                         |    2 +-
 net/bluetooth/ecc.c                                |  816 ++++++++++
 net/bluetooth/ecc.h                                |   54 +
 net/bluetooth/hci_conn.c                           |   15 +-
 net/bluetooth/hci_core.c                           |  415 +++--
 net/bluetooth/hci_event.c                          |  296 +++-
 net/bluetooth/hci_sock.c                           |    2 +-
 net/bluetooth/hidp/Kconfig                         |    2 +-
 net/bluetooth/hidp/core.c                          |   10 +-
 net/bluetooth/l2cap_core.c                         |   97 +-
 net/bluetooth/l2cap_sock.c                         |   29 +-
 net/bluetooth/mgmt.c                               | 1000 ++++++++----
 net/bluetooth/rfcomm/Kconfig                       |    2 +-
 net/bluetooth/rfcomm/core.c                        |   12 +-
 net/bluetooth/smp.c                                | 1670 ++++++++++++++++=
+---
 net/bluetooth/smp.h                                |   60 +-
 net/ieee802154/6lowpan_rtnl.c                      |  149 +-
 net/ieee802154/Makefile                            |    4 +-
 net/ieee802154/af802154.h                          |    4 -
 net/ieee802154/af_ieee802154.c                     |    8 +-
 net/ieee802154/core.c                              |  321 ++++
 net/ieee802154/core.h                              |   46 +
 net/ieee802154/dgram.c                             |    7 +-
 net/ieee802154/header_ops.c                        |    3 +-
 net/ieee802154/ieee802154.h                        |    6 +-
 net/ieee802154/netlink.c                           |   11 +-
 net/ieee802154/nl-mac.c                            |  269 +---
 net/ieee802154/nl-phy.c                            |   32 +-
 net/ieee802154/nl802154.c                          |  957 +++++++++++
 net/ieee802154/nl802154.h                          |    7 +
 net/ieee802154/nl_policy.c                         |    4 -
 net/ieee802154/raw.c                               |    5 -
 net/ieee802154/rdev-ops.h                          |   89 ++
 net/ieee802154/reassembly.c                        |    8 +-
 net/ieee802154/reassembly.h                        |    4 +-
 net/ieee802154/sysfs.c                             |  128 ++
 net/ieee802154/sysfs.h                             |    9 +
 net/ieee802154/wpan-class.c                        |  230 ---
 net/mac80211/Kconfig                               |   18 +
 net/mac80211/Makefile                              |    3 +-
 net/mac80211/agg-tx.c                              |   12 +-
 net/mac80211/cfg.c                                 |  193 ++-
 net/mac80211/chan.c                                |   28 +-
 net/mac80211/debug.h                               |   10 +
 net/mac80211/debugfs_key.c                         |   12 +-
 net/mac80211/debugfs_sta.c                         |   11 +-
 net/mac80211/driver-ops.h                          |  157 +-
 net/mac80211/ieee80211_i.h                         |  122 +-
 net/mac80211/iface.c                               |   33 +-
 net/mac80211/key.c                                 |   11 +-
 net/mac80211/main.c                                |   44 +-
 net/mac80211/mesh.h                                |    3 +
 net/mac80211/mesh_pathtbl.c                        |   31 +
 net/mac80211/mlme.c                                |  333 +++-
 net/mac80211/ocb.c                                 |  250 +++
 net/mac80211/rate.c                                |    8 +-
 net/mac80211/rate.h                                |   24 +-
 net/mac80211/rc80211_minstrel.c                    |    7 +-
 net/mac80211/rc80211_minstrel_ht.c                 |  334 +++-
 net/mac80211/rc80211_minstrel_ht.h                 |   40 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |   43 +-
 net/mac80211/rx.c                                  |  181 ++-
 net/mac80211/scan.c                                |  129 +-
 net/mac80211/sta_info.c                            |   19 +-
 net/mac80211/sta_info.h                            |   11 +
 net/mac80211/status.c                              |  171 +-
 net/mac80211/tdls.c                                |  800 +++++++++-
 net/mac80211/trace.h                               |  248 ++-
 net/mac80211/tx.c                                  |  316 +++-
 net/mac80211/util.c                                |  203 ++-
 net/mac80211/vht.c                                 |    2 +
 net/mac80211/wep.c                                 |    2 -
 net/mac80211/wme.c                                 |   72 +-
 net/mac80211/wme.h                                 |    2 -
 net/mac80211/wpa.c                                 |    5 -
 net/mac802154/Kconfig                              |    2 +-
 net/mac802154/Makefile                             |    4 +-
 net/mac802154/cfg.c                                |  210 +++
 net/mac802154/cfg.h                                |    9 +
 net/mac802154/driver-ops.h                         |  222 +++
 net/mac802154/ieee802154_dev.c                     |  415 -----
 net/mac802154/{mac802154.h =3D> ieee802154_i.h}      |  132 +-
 net/mac802154/iface.c                              |  586 +++++++
 net/mac802154/llsec.c                              |   23 +-
 net/mac802154/mac_cmd.c                            |   88 +-
 net/mac802154/main.c                               |  217 +++
 net/mac802154/mib.c                                |  271 +---
 net/mac802154/monitor.c                            |  117 --
 net/mac802154/rx.c                                 |  310 +++-
 net/mac802154/tx.c                                 |  154 +-
 net/mac802154/util.c                               |   84 +
 net/mac802154/wpan.c                               |  599 -------
 net/nfc/digital_dep.c                              |  834 +++++++++-
 net/nfc/hci/command.c                              |    3 +
 net/nfc/hci/core.c                                 |   56 +
 net/nfc/llcp_commands.c                            |    6 +-
 net/nfc/llcp_core.c                                |    5 +-
 net/nfc/llcp_sock.c                                |    6 +-
 net/nfc/nci/core.c                                 |  150 +-
 net/nfc/nci/data.c                                 |   24 +-
 net/nfc/nci/ntf.c                                  |  152 +-
 net/nfc/netlink.c                                  |   77 +-
 net/wireless/Kconfig                               |    2 +-
 net/wireless/Makefile                              |    2 +-
 net/wireless/chan.c                                |   10 +-
 net/wireless/core.c                                |   95 +-
 net/wireless/core.h                                |   13 +
 net/wireless/nl80211.c                             |  978 +++++++++---
 net/wireless/ocb.c                                 |   88 ++
 net/wireless/rdev-ops.h                            |   79 +-
 net/wireless/reg.c                                 |  156 +-
 net/wireless/sme.c                                 |   13 +-
 net/wireless/trace.h                               |  155 +-
 net/wireless/util.c                                |    5 +-
 435 files changed, 29693 insertions(+), 11237 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/btmrvl.txt
 delete mode 100644 drivers/net/ieee802154/fakehard.c
 rename drivers/net/wireless/ath/ath9k/{spectral.c =3D> common-spectral.c} =
(73%)
 rename drivers/net/wireless/ath/ath9k/{spectral.h =3D> common-spectral.h} =
(85%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_bus.h =3D> bus.h} (98%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{wl_cfg80211.c =3D> cfg8021=
1.c} (95%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{wl_cfg80211.h =3D> cfg8021=
1.h} (98%)
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/common.c
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_linux.c =3D> core.c} (=
96%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd.h =3D> core.h} (96%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_dbg.c =3D> debug.c} (9=
8%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_dbg.h =3D> debug.h} (9=
8%)
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
 rename drivers/net/wireless/brcm80211/brcmfmac/{dhd_sdio.c =3D> sdio.c} (9=
8%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{sdio_host.h =3D> sdio.h} (=
98%)
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/usb_rdl.h
 delete mode 100644 drivers/net/wireless/p54/net2280.h
 rename include/{net =3D> linux}/ieee802154.h (79%)
 create mode 100644 include/net/cfg802154.h
 delete mode 100644 include/net/wpan-phy.h
 create mode 100644 net/bluetooth/ecc.c
 create mode 100644 net/bluetooth/ecc.h
 create mode 100644 net/ieee802154/core.c
 create mode 100644 net/ieee802154/core.h
 create mode 100644 net/ieee802154/nl802154.c
 create mode 100644 net/ieee802154/nl802154.h
 create mode 100644 net/ieee802154/rdev-ops.h
 create mode 100644 net/ieee802154/sysfs.c
 create mode 100644 net/ieee802154/sysfs.h
 delete mode 100644 net/ieee802154/wpan-class.c
 create mode 100644 net/mac80211/ocb.c
 create mode 100644 net/mac802154/cfg.c
 create mode 100644 net/mac802154/cfg.h
 create mode 100644 net/mac802154/driver-ops.h
 delete mode 100644 net/mac802154/ieee802154_dev.c
 rename net/mac802154/{mac802154.h =3D> ieee802154_i.h} (63%)
 create mode 100644 net/mac802154/iface.c
 create mode 100644 net/mac802154/main.c
 delete mode 100644 net/mac802154/monitor.c
 create mode 100644 net/mac802154/util.c
 delete mode 100644 net/mac802154/wpan.c
 create mode 100644 net/wireless/ocb.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Qxx1br4bt0+wmkIi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUhfzHAAoJEJctW/TcYTgG8bgQAJbw3PusOs0IAKBVN8OAgqu6
M9V8a65vnK8VpN7Q+W9Nk+gJuCKpDMZDTHHOotbQjZvDA99yi5H3vzndWpT44cSR
DFQ7vY5t/F9ZQ5ubuk4wu9h/bZTZnM2AiwG0fQYYDZG+ah2dTGov0pQ+USDbE4Ih
2i8/oN1w5qAfQsAykVL8ZcfyHjwK1Azdv9qykL8RS0mGOi82Jfq7SybtII8Pb7rp
E4ANgaZ4aoI9P/UyP2rXvXbDkintpyCj2X74GJsl8pq/c15ban3iPKfvFhjblcHS
szraME0HDF82G7VsmpNQ+z7YiV4OiCI61K4GXmaJZ/JEhuUXf3CXkrepynKHY7Bj
lMFICQ5zj6xVcY/h7WZLBRv5ZRb2Ic7BvM8OzqPu/k+SNSigkPA8ZhIIDv0RA4Ny
US0r4zEKUdfD/Lk+J2yXKC2H6cNwuLnHpYcEIfxkGY+gHeIDeqsZHb0aSEwmvHO5
hewX7I78RCXqMpiTfmhkgyeGIuYx5PnmDyL2U+nrc4dGM1vqnMfT/HLRKcgKh+CW
v9qzrn1INOLl3I8OaCbflvSKsCiUGtcZD6z0PSKMNx0VpeLD0zNy9iJU3htSUWMd
zPgmPJ0HmdAl7PMxgestT+C4T0NwDeqg441Gc+YbiYV/NR3wW4YeS7a/0nLpAmJH
/Wuv7TxEtLMWND+1vCwx
=a8O5
-----END PGP SIGNATURE-----

--Qxx1br4bt0+wmkIi--
