From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2014-03-10
Date: Mon, 10 Mar 2014 15:01:02 -0400
Message-ID: <20140310190101.GB25703@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intende for the 3.15 stream!

For the mac80211 bits, Johannes says:

"This time, I have a number of small fixes and improvements, and those
are fairly straight-forward. More interesting changes come from Luca
with some preparations for the CSA work, mostly around interface/channel
combinations checking. One other possibly interesting change is a small
one by myself to add NAPI support back to mac80211, which can help
improve TCP behaviour through GRO."

For the Bluetooth bits, Gustavo says:

"This is our first pull request for 3.15, the main feature here is the addi=
tion of
the privacy feature for low energy devices. Other than that we have a bunch=
 of small
improvements, fixes, and clean ups all over the tree."

And...

"Another pull request to 3.15. Here we have the second part of the LE priva=
te
feature, the LE auto-connect feature and improvements to the power off
procedures. The rest are small improvements, clean up, and fixes."

For the iwlwifi bits, Emmanuel says:

"I have here a whole bunch of various things. Trivial cleanups,
debugfs handlers and new stuff for the new generation of devices
along with new capabilities for monitor mode. We also have support
for power save for dual interface mode, but that is not supported by
the firmware currently available."

And for the Atheros bits, Kalle says:

"For ath10k Alexander did some cleanup to PCI error cases and switched
ath10k to use pci_enable_msi_range(). Michal implemented AP CSA support
and sta_rc_update() operation. I enabled firmware "STA quick kickout"
functionality for faster detection of disappeared clients.

Also there are lots of small fixes to everywhere from various people."

I pulled the wireless tree to avoid some merge conflicts, and I
reverted the staging patch that I had mistakenly merged previously.
Along with that, mwifiex, brcmfmac, wil6210, ath9k, and a few other
drivers get their usual round of updates.  Also notable is the addition
of yet another driver in the rtlwifi family.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9063e21fb026c4966fc93261c18322214f9835eb:

  netlink: autosize skb lengthes (2014-03-10 13:56:26 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 250422cac6431363d8436ca6e281ff8dc9147263:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-03-10 14:18:17 -0400)

----------------------------------------------------------------

Alexander Bondar (1):
      iwlwifi: mvm: Enable power save on BSS and P2P client in DCM

Alexander Gordeev (3):
      ath10k: Get rid of superfluous call to pci_disable_msi()
      ath10k: Disable MSI in case IRQ configuration is unknown
      ath10k: Use pci_enable_msi_range()

Amitkumar Karwar (9):
      mwifiex: enable obss scan offload feature flag
      mwifiex: change transmit buffer size for 8897
      mwifiex: abort scan while cancelling pending command
      mwifiex: skipping pending commands after unload
      mwifiex: stop AP at shutdown time
      mwifiex: block further commands after timeout
      mwifiex: get rid of extra num_cmd_timeout variable
      mwifiex: replace num_cmd_timeout with is_cmd_timedout
      mwifiex: update MCS information as per antenna settings

Andre Guedes (22):
      Bluetooth: Save connection interval parameters in hci_conn
      Bluetooth: Group list_head fields from strcut hci_dev together
      Bluetooth: Introduce le_conn_failed() helper
      Bluetooth: Introduce connection parameters list
      Bluetooth: Use connection parameters if any
      Bluetooth: Create hci_req_add_le_scan_disable helper
      Bluetooth: Declare le_conn_failed in hci_core.h
      Bluetooth: Stop scanning on LE connection
      Bluetooth: Remove unused function
      Bluetooth: Refactor HCI connection code
      Bluetooth: Move address type conversion to outside hci_connect_le
      Bluetooth: Introduce hdev->pend_le_conn list
      Bluetooth: Introduce LE auto connection infrastructure
      Bluetooth: Introduce LE auto connect options
      Bluetooth: Connection parameters and auto connection
      Bluetooth: Temporarily stop background scanning on discovery
      Bluetooth: Auto connection and power on
      Bluetooth: Connection parameters and resolvable address
      Bluetooth: Support resolvable private addresses
      Bluetooth: Add le_auto_conn file on debugfs
      Bluetooth: Create hci_req_add_le_passive_scan helper
      Bluetooth: Update background scan parameters

Andrzej Kaczmarek (2):
      Bluetooth: Fix channel check when binding RFCOMM sock
      Bluetooth: Fix NULL pointer dereference when sending data

Andy Shevchenko (2):
      Bluetooth: sort the list of IDs in the source code
      Bluetooth: append new supported device to the list [0b05:17d0]

Arend van Spriel (5):
      brcmfmac: fix use of skb control buffer in SDIO driver part
      brcmfmac: remove unused variable data_len from brcmf_sdio_bus_txdata()
      brcmfmac: use pre-allocated scatter-gather table for txglomming
      brcmfmac: reset suspend flag upon sdio suspend failure
      Revert "brcmfmac: Use atomic functions for intstatus update."

Avinash Patil (2):
      mwifiex: use del_timer_sync instead of del_timer
      mwifiex: remove redundant del_timer

Avinash kumar (1):
      drivers:net:wireless:airo.c:checkpatch.pl cleanup

Bartosz Markowski (2):
      ath10k: remove excessive rx msdu len check
      ath10k: AP: handle HT station which does not have HT RX MCS

Ben Greear (4):
      ath10k:  Print out firmware feature bits from IE.
      ath10k: print out size of wmi-ready-event message
      ath10k: add more debugging for receive errors
      ath10k: better tx/rx debugging

Bing Zhao (1):
      mwifiex: remove global variable cmd_wait_q_required

Calvin Owens (1):
      ieee80211: Print human-readable disassoc/deauth reason codes

Chun-Yeow Yeoh (1):
      ath10k: fix the printing of 10.x FW version when FW crashed

C=E9dric Le Goater (1):
      hostap: add Netgear MA401 card

Dan Carpenter (1):
      mwifiex: memory corruption in mwifiex_tdls_add_vht_capab()

Daniel Kim (1):
      brcmfmac: Correct mcs index report

David Spinadel (1):
      mac80211: fix IE buffer len

Eliad Peller (5):
      mac80211: reset probe_send_count also in HW_CONNECTION_MONITOR case
      mac80211: add beacon_loss debugfs file
      iwlwifi: pcie: clean iwl_pcie_[rt]xq_inc_wr_ptr a bit
      iwlwifi: mvm: add debugfs for prph reg read/write
      iwlwifi: mvm: fix a few wd_disable comments

Emmanuel Grumbach (4):
      iwlwifi: mvm: propagate LDPC / STBC status to radiotap
      iwlwifi: mvm: don't dump log of second CPU when not relevant
      iwlwifi: pcie: stop the firmware when we restart it
      iwlwifi: mvm: set immediate apply time bit in time events

Eran Harary (2):
      iwlwifi: mvm: new NVM format in family 8000
      iwlwifi: mvm: prepare infrastructure for more TLV flags

Eyal Shapira (1):
      iwlwifi: mvm: add Rx frames statistics via debugfs

Eytan Lifshitz (1):
      iwlwifi: mvm: fix possible memory leak

Felix Fietkau (6):
      ath9k: list more reset causes in debugfs
      ath9k: do not set half/quarter channel flags in AR_PHY_MODE
      ath9k: make some hardware reset log messages debug-only
      ath5k: set SURVEY_INFO_IN_USE on get_survey
      ath9k_hw: toggle weak signal detection in AP mode on older chipsets
      ath9k_hw: tweak noise immunity thresholds for older chipsets

Hante Meuleman (9):
      brcmfmac: Make firmeware roaming a module param.
      brcmfmac: Correct header debug dump for sdio tx hdrs.
      brcmfmac: de-init driver layers in correct order.
      brcmfmac: Minimize SDIO dpc scheduling.
      brcmfmac: Remove immediate sleep support from SDIO.
      brcmfmac: Small cleanup of redundant code.
      brcmfmac: Use atomic functions for intstatus update.
      brcmfmac: Put frame sdio tx error handling in sub function.
      brcmfmac: Use atomic functions for intstatus update.

Heinrich Schuchardt (1):
      rtlwifi: Remove redundant if clause

Inbal Hacohen (1):
      iwlwifi: mvm: remove redundant define in fw.c

Ivaylo Dimitrov (1):
      wl1251: use skb_trim to make skb shorter

Janusz Dziedzic (4):
      ath10k: enable wmi ps peer param command for 10.x FW
      ath10k: AP mode, set UAPSD params correctly
      ath10k: pass frames with invalid peer status to upper layer
      cfg80211: regulatory: introduce NL80211_RRF_AUTO_BW rule flag

Joe Perches (1):
      ath9k: Use static const

Johan Hedberg (100):
      Bluetooth: Fix outgoing authentication requirement check
      Bluetooth: Fix mgmt error code for negative PIN response
      Bluetooth: Reorder L2CAP functions to avoid forward declarations
      Bluetooth: Queue incoming ACL data until BT_CONNECTED state is reached
      Bluetooth: Remove useless l2cap_seq_list_remove function
      Bluetooth: Rename L2CAP_CHAN_CONN_FIX_A2MP to L2CAP_CHAN_FIXED
      Bluetooth: Switch ATT channels to use L2CAP_CHAN_FIXED
      Bluetooth: Fix BT_SECURITY socket option for fixed channels (ATT)
      Bluetooth: Fix CID initialization for fixed channels
      Bluetooth: Fix respecting le_default_mps value
      Bluetooth: Fix disconnecting L2CAP channel for credits violation
      Bluetooth: Fix disconnecting L2CAP when a credits overflow occurs
      Bluetooth: Free up l2cap_chan->sport when initiating a connection
      Bluetooth: Refuse peer L2CAP address reading when not connected
      Bluetooth: Refuse peer RFCOMM address reading when not connected
      Bluetooth: Always use l2cap_chan->psm for returning PSM to user space
      Bluetooth: Remove unnecessary check for chan->psm
      Bluetooth: Enable LTK distribution to slave devices
      Bluetooth: Remove Simultaneous LE & BR/EDR flags from AD
      Bluetooth: Fix long_term_keys debugfs output
      Bluetooth: Make LTK key type check more readable
      Bluetooth: Remove unnecessary LTK type check from hci_add_ltk
      Bluetooth: Fix differentiating stored master vs slave LTK types
      Bluetooth: Enable LE L2CAP CoC support by default
      Bluetooth: Fix missing PDU length checks for SMP
      Bluetooth: Fix minor whitespace issues in SMP code
      Bluetooth: Add smp_irk_matches helper function
      Bluetooth: Add AES crypto context for each HCI device
      Bluetooth: Add basic IRK management support
      Bluetooth: Add hci_bdaddr_is_rpa convenience function
      Bluetooth: Implement mgmt_load_irks command
      Bluetooth: Enable support for remote IRK distribution
      Bluetooth: Fix properly ignoring unexpected SMP PDUs
      Bluetooth: Fix missing address type check for removing LTKs
      Bluetooth: Remove return values from functions that don't need them
      Bluetooth: Fix hci_remove_ltk failure when no match is found
      Bluetooth: Fix completing SMP as peripheral when no keys are expected
      Bluetooth: Fix removing any IRKs when unpairing devices
      Bluetooth: Add convenience function for fetching IRKs
      Bluetooth: Remove SMP data specific crypto context
      Bluetooth: Track the LE Identity Address in struct hci_conn
      Bluetooth: Fix updating Identity Address in L2CAP channels
      Bluetooth: Wait for SMP key distribution completion when pairing
      Bluetooth: Don't try to look up private addresses as Identity Address
      Bluetooth: Look up RPA for connection requests with Identity Address
      Bluetooth: Use Identity Address in Device Found event
      Bluetooth: Avoid using GFP_ATOMIC where not necessary
      Bluetooth: Return added key when adding LTKs and IRKs
      Bluetooth: Move New LTK store hint evaluation into mgmt_new_ltk
      Bluetooth: Track SMP keys in the SMP context
      Bluetooth: Move SMP LTK notification after key distribution
      Bluetooth: Add support for sending New IRK event
      Bluetooth: Fix iterating wrong list in hci_remove_irk()
      Bluetooth: Add helper variables to smp_distribute_keys()
      Bluetooth: Add initial code for distributing local IRK
      Bluetooth: Move enable/disable_advertising higher up in mgmt.c
      Bluetooth: Add mgmt defines for privacy
      Bluetooth: Add Privacy flag to mgmt supported/current settings
      Bluetooth: Ensure hci_conn always contains the local identity address
      Bluetooth: Set the correct values for Identity Address Information
      Bluetooth: Add SMP function for generating RPAs
      Bluetooth: Add timer for regenerating local RPA
      Bluetooth: Add hci_update_random_address() convenience function
      Bluetooth: Use hci_update_random_address() when connecting LE
      Bluetooth: Use hci_update_random_address() for enabling advertising
      Bluetooth: Use hci_update_random_address() for initiating LE scan
      Bluetooth: Don't write static address during power on
      Bluetooth: Add debugfs entry for RPA regeneration timeout
      Bluetooth: Add support for Set Privacy command
      Bluetooth: Fix setting correct src_type when connecting LE
      Bluetooth: Remove unneeded hdev->own_addr_type
      Bluetooth: Enable RPA resolving if mgmt_set_privacy is called
      Bluetooth: Fix canceling RPA expiry timer
      Bluetooth: Add convenience function for getting total connection count
      Bluetooth: Move HCI_ADVERTISING handling into mgmt.c
      Bluetooth: Move check for MGMT_CONNECTED flag into mgmt.c
      Bluetooth: Don't clear HCI_DISCOVERABLE when powering off
      Bluetooth: Don't clear HCI_CONNECTABLE when powering off
      Bluetooth: Don't clear HCI_ADVERTISING when powering off
      Bluetooth: Clean up HCI state when doing power off
      Bluetooth: Fix advertising address type when toggling connectable
      Bluetooth: Ignore IRKs with no Identity Address
      Bluetooth: Track not yet received keys in SMP
      Bluetooth: Simplify logic for checking for SMP completion
      Bluetooth: Remove unneeded "force" parameter from smp_distribute_keys=
()
      Bluetooth: Add tracking of advertising address type
      Bluetooth: Add hci_copy_identity_address convenience function
      Bluetooth: Fix disconnecting connections in non-connected states
      Bluetooth: Add timer to force power off
      Bluetooth: Fix clearing SMP keys if pairing fails
      Bluetooth: Add protections for updating local random address
      Bluetooth: Fix updating connection state to BT_CONNECT too early
      Bluetooth: Track LE initiator and responder address information
      Bluetooth: Use hdev->init/resp_addr values for smp_c1 function
      Bluetooth: Add defines for LE initiator filter policy
      Bluetooth: Add timeout for LE connection attempts
      Bluetooth: Re-encrypt link after receiving an LTK
      Bluetooth: Delay LTK encryption to let remote receive all keys
      Bluetooth: Fix trying to disable scanning twice
      Bluetooth: Remove unnecessary stop_scan_complete function

Johannes Berg (14):
      mac80211: remove superfluous band variable
      mac80211_hwsim: fix number of channels in interface combinations
      mac80211: simplify roc check in idle calculation
      cfg80211: remove NL80211_FEATURE_P2P_DEVICE_NEEDS_CHANNEL
      nl80211: use ie_len in scheduled scan
      mac80211: add NAPI support back
      iwlwifi: make various things const
      iwlwifi: mvm: use IEEE80211_TX_CTRL_PORT_CTRL_PROTO flag
      iwlwifi: remove iwl_fw_valid_(tx|rx)_ant inlines
      mac80211: remove erroneous comment about RX radiotap header
      Merge remote-tracking branch 'wireless-next/master' into mac80211-next
      cfg80211: document sched_scan_stop synchronous behaviour
      mac80211: allow driver to return error from sched_scan_stop
      iwlwifi: nvm: remove reading valid antennas from NVM

John W. Linville (8):
      Revert "Staging: rtl8812ae: remove modules field of rate_control_ops"
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (1):
      ath9k: Enable U-APSD AP mode support

Julien Massot (2):
      ath6kl: increase usb rx buffer size to 4096
      ath6kl: set rx urb count threshold to 1

Jurgen Kramer (1):
      Bluetooth: btusb: Add IMC Networks (Broadcom based)

Kalle Valo (5):
      ath10k: enable firmware STA quick kickout
      Merge remote-tracking branch 'wireless-next/master' into ath-next
      ath10k: fix alignment in ath10k_dbg()
      ath: remove camel case from struct reg_dmn_pair_mapping
      ath10k: release conf_mutex if vdev_start() fails

Larry Finger (16):
      rtlwifi: btcoexist: Add new mini driver
      rtlwifi: Prepare existing drivers for new driver
      rtlwifi: rtl8723ae: rtl8723-common: Create new driver for common code
      rtlwifi: rtl8723ae: rtl8723-common: Copy common firmware code
      rtlwifi: rtl8723ae: rtl8723-common: Copy common dynamic power managem=
ent code
      rtlwifi: rtl8723be: Add new driver
      rtlwifi: rtl8192ce: rtl8192cu: rtl8192de: rtl8192se: rtl8723ae: rtl87=
23be: rtl8188eu: Modify for new API
      rtlwifi: Move common routines to core
      rtlwifi: rtl8723be: rtl8723com: Remove unused allow_all_destaddr func=
tions
      rtlwifi: rtl8192cu: Fix too long disable of IRQs
      rtlwifi: rtl8192se: Fix too long disable of IRQs
      rtlwifi: rtl8188ee: Fix too long disable of IRQs
      rtlwifi: rtl8723ae: Fix too long disable of IRQs
      rtlwifi: rtl8192ce: Handle unused switch case
      rtlwifi: rtl8723be: Fix sparse errors
      rtlwifi: rtl8723be: Fix smatch warnings

Lucas De Marchi (1):
      Bluetooth: allocate static minor for vhci

Luciano Coelho (8):
      mac80211_hwsim: allow creation of single-channel radios with chanctx
      cfg80211: docbook: fix small formatting error
      cfg80211: docbook: add interface combinations documentation
      mac80211: allow drivers to request SMPS off
      nl80211: make sure we check for DFS with mesh channel switch
      cfg80211: remove radar requirements check from cfg80211_can_use_iftyp=
e_chan()
      mac80211: ibss: handle cfg80211_chandef_dfs_required() error codes
      wl1251: split wl251 platform data to a separate structure

Lukasz Rymanowski (1):
      Bluetooth: Fix response on confirm_name

Marcel Holtmann (60):
      Bluetooth: Add LMP feature definitions for Secure Connections support
      Bluetooth: Add HCI command definition for Secure Connections enabling
      Bluetooth: Add HCI command definition for extended OOB data
      Bluetooth: Add definitions for new link key types
      Bluetooth: Add support for handling P-256 derived link keys
      Bluetooth: Enable Authenticated Payload Timeout Expired event
      Bluetooth: Add flags and setting for Secure Connections support
      Bluetooth: Add management command for enabling Secure Connections
      Bluetooth: Enable Secure Connection during power on if configured
      Bluetooth: Limit acceptable link key types to only supported ones
      Bluetooth: Add support for local OOB data with Secure Connections
      Bluetooth: Add debugfs quirk for forcing Secure Connections support
      Bluetooth: Provide remote OOB data for Secure Connections
      Bluetooth: Add internal function for storing P-192 and P-256 data
      Bluetooth: Add support for remote OOB input of P-256 data
      Bluetooth: Track Secure Connections support of remote devices
      Bluetooth: Introduce requirements for security level 4
      Bluetooth: Handle security level 4 for L2CAP connections
      Bluetooth: Handle security level 4 for RFCOMM connections
      Bluetooth: Add debugfs entry to show Secure Connections Only mode
      Bluetooth: Increment management interface revision
      Bluetooth: Add management setting for use of debug keys
      Bluetooth: Add management command to allow use of debug keys
      Bluetooth: Remove use_debug_keys debugfs entry
      Bluetooth: Remove one level of indentation from hci_encrypt_change_evt
      Bluetooth: Track the AES-CCM encryption status of LE and BR/EDR links
      Bluetooth: Remove check for valid LTK authenticated parameter
      Bluetooth: Rename authentication to key_type in mgmt_ltk_info
      Bluetooth: Remove __packed from struct smp_ltk
      Bluetooth: Add management command for Secure Connection Only Mode
      Bluetooth: Include security level 4 in connections check
      Bluetooth: Track if link is using P-256 authenticated combination key
      Bluetooth: Add constants for LTK key types
      Bluetooth: Restrict long term keys to public and static addresses
      Bluetooth: Fix sending wrong store hint for new long term keys
      Bluetooth: Add missing index added event on user channel failure
      Bluetooth: Allow HCI User Channel usage for controllers without addre=
ss
      Bluetooth: Report identity address when remote device connects
      Bluetooth: Use connection address for reporting connection failures
      Bluetooth: Fix wrong identity address during connection failures
      Bluetooth: Expose current list of identity resolving keys via debugfs
      Bluetooth: Use same LE min/max connection event length during update
      Bluetooth: Don't send store hint for devices using identity addresses
      Bluetooth: Add comment explainging store hint for long term keys
      Bluetooth: Replace own_address_type with force_static_address debugfs
      Bluetooth: Track the current configured random address
      Bluetooth: Provide option for changing LE advertising channel map
      Bluetooth: Increase minor version of core module
      Bluetooth: Fix issue with missing management event opcode
      Bluetooth: Expose current identity information in debugfs
      Bluetooth: Use unresolvable private address for active scanning
      Bluetooth: Use privacy mode for non-connectable advertising
      Bluetooth: Store current RPA and update it if needed
      Bluetooth: Export current local RPA with identity information
      Bluetooth: Make hci_blacklist_clear function static
      Bluetooth: Add definitions for LE white list HCI commands
      Bluetooth: Clear all LE white list entries when powering controller
      Bluetooth: Add support for storing LE white list entries
      Bluetooth: Track LE white list modification via HCI commands
      Bluetooth: Use __le64 type for LE random numbers

Marek Kwaczynski (1):
      ath10k: Set proper nss value for the peer

Marek Puzyniak (3):
      ath10k: configure access category for arp
      ath10k: refactor suspend/resume functions
      ath10k: suspend hardware before reset

Michal Kazior (7):
      ath10k: implement channel switching
      ath10k: implement AP CSA
      ath10k: implement and use new beacon method
      ath10k: properly return err from start()
      ath10k: fix device initialization routine
      ath10k: fix SMPS support
      ath10k: implement sta_rc_update()

Oleksij Rempel (10):
      ath9k: move ath9k_init_channels_rates to common-init
      ath9k_htc: use ath9k_cmn_init_channels_rates
      ath9k: move setup_ht_cap to common-init
      ath9k_htc: use ath9k_cmn_setup_ht_cap
      ath9k-common: set maxstream=3D1 for ar9271
      ath9k: move ath9k_reload_chainmask_settings to common
      ath9k_htc: use ath9k_cmn_reload_chainmask
      ath9k: remove unused listen_interval and sleepduration.
      ath9k_htc: remove unused variable sleepduration
      ath9k_htc: add function ath9k_regwrite_multi

Oliver Neukum (2):
      Bluetooth: Enable Atheros 0cf3:311e for firmware upload
      Bluetooth: Add firmware update for Atheros 0cf3:311f

Paul Stewart (1):
      mwifiex: Track BA sequence number reset

Peter Hurley (24):
      Revert "Bluetooth: Remove rfcomm_carrier_raised()"
      Revert "Bluetooth: Always wait for a connection on RFCOMM open()"
      Revert "Bluetooth: Move rfcomm_get_device() before rfcomm_dev_activat=
e()"
      tty: Fix ref counting for port krefs
      Bluetooth: Fix racy acquire of rfcomm_dev reference
      Bluetooth: Exclude released devices from RFCOMMGETDEVLIST ioctl
      Bluetooth: Release rfcomm_dev only once
      Bluetooth: Fix unreleased rfcomm_dev reference
      Bluetooth: Fix RFCOMM tty teardown race
      Bluetooth: Verify dlci not in use before rfcomm_dev create
      Bluetooth: Simplify RFCOMM session state eval
      Bluetooth: Refactor deferred setup test in rfcomm_dlc_close()
      Bluetooth: Refactor dlc disconnect logic in rfcomm_dlc_close()
      Bluetooth: Directly close dlc for not yet started RFCOMM session
      Bluetooth: Fix unsafe RFCOMM device parenting
      Bluetooth: Fix RFCOMM parent device for reused dlc
      Bluetooth: Rename __rfcomm_dev_get() to __rfcomm_dev_lookup()
      Bluetooth: Serialize RFCOMMCREATEDEV and RFCOMMRELEASEDEV ioctls
      Bluetooth: Refactor rfcomm_dev_add()
      Bluetooth: Cleanup RFCOMM device registration error handling
      Bluetooth: Force -EIO from tty read/write if .activate() fails
      Bluetooth: Don't fail RFCOMM tty writes
      Bluetooth: Refactor write_room() calculation
      Bluetooth: Fix write_room() calculation

Peter Wu (2):
      rtlwifi: avoid accessing RCR directly
      rtlwifi: properly apply filter flags

Sachin Kamat (1):
      net: wireless: wl3501_cs: Remove duplicate include

Sebastian Reichel (4):
      wl1251: move power GPIO handling into the driver
      wl1251: spi: add vio regulator support
      wl1251: spi: add device tree support
      Documentation: dt: wireless: Add wl1251

Silvan Jegen (1):
      net: Replace min macro with min_t

Stanislaw Gruszka (4):
      iwl3945: fix wakeup interrupt
      iwlegacy: merge reclaim check
      iwlegacy: properly enable power saving
      iwl4965: disable 8K A-MSDU by default

Sunil Dutt Undekari (1):
      cfg80211: Pass TDLS peer capability information in tdls_mgmt

Surendra Patil (1):
      Drivers:net:wireless:ti:wl1251: Fixed Sparse invalid assignment warni=
ng

Sylvain Roger Rieunier (1):
      ath9k: fix invalid max frame length

Szymon Janc (1):
      Bluetooth: Print error when dropping L2CAP data

Tejun Heo (1):
      wireless/rt2x00: don't use PREPARE_WORK in rt2800usb.c

Vladimir Kondratiev (18):
      wil6210: Tx management frame
      wil6210: [DEBUG] allow to query Rx and all Tx VRING descriptors
      wil6210: [DEBUG] Improve Vring printing
      wil6210: multiple connect - initial support
      wil6210: Block ACK
      wil6210: Find free vring for Tx
      wil6210: broadcast Tx
      wil6210: fix BACK status processing
      wil6210: dump_station initial support
      wil6210: per-connection statistics
      wil6210: disconnect only requested peer
      wil6210: Fill vring2cid_tid table early
      wil6210: Provide signal strength indication
      wil6210: use ether_addr_equal
      wil6210: single station disconnect
      wil6210: do not reorder groupcast Rx
      wil6210: fix buffer overflow in wil_txdesc_debugfs_show()
      wil6210: fix smatch warning in wil_cfg80211_get_station()

Wei Yongjun (1):
      Bluetooth: Convert to use ATTRIBUTE_GROUPS macro

Yogesh Ashok Powar (5):
      mwl8k: Adding support to access BBP registers
      mwl8k: Implement sw_scan start/stop cbs
      mwl8k: Adding support to gather survey per channel
      mwl8k: le32_to_cpu cast to restricted
      mwl8k: mwl8k_update_survey can be static

Zhao, Gang (10):
      b43: Kconfig: let config B43_BCMA_PIO depends on B43
      b43: return true / false instead of numbers in functions which return=
 bool value
      airo: replace function ieee80211_{dsss_chan_to_freq, freq_to_dsss_cha=
n}
      atmel: replace function ieee80211_{dsss_chan_to_freq, freq_to_dsss_ch=
an}
      wl3501_cs: replace function ieee80211_{dsss_chan_to_freq, freq_to_dss=
s_chan}
      rndis_wlan: replace function ieee80211_{dsss_chan_to_freq, freq_to_ds=
ss_chan}
      zd1201: replace function ieee80211_{dsss_chan_to_freq, freq_to_dsss_c=
han}
      orinoco: replace function ieee80211_{dsss_chan_to_freq, freq_to_dsss_=
chan}
      ieee80211: remove function ieee80211_{dsss_chan_to_freq, freq_to_dsss=
_chan}
      wireless: Kconfig: add missing dependency

andrea merello (7):
      rtl818x: Explicitly enable contetion window
      rtl818x: pci_iomap() should pair with pci_iounmap()
      rtl818x: check for pci_map_single() success when initializing RX ring
      rtl818x: make dev_alloc_skb() null pointer check to really work
      rtl818x: add comments to explain few not obvious HW configs.
      rtl818x: Make sure the TX descriptor "valid" flag is written by last
      rtl818x: make sure TX descriptor writes are done before kicking DMA

 Documentation/DocBook/80211.tmpl                   |    2 +
 Documentation/devices.txt                          |    1 +
 .../devicetree/bindings/net/wireless/ti,wl1251.txt |   39 +
 arch/arm/mach-omap2/board-omap3pandora.c           |    6 +-
 arch/arm/mach-omap2/board-rx51-peripherals.c       |   13 +-
 drivers/bluetooth/ath3k.c                          |   84 +-
 drivers/bluetooth/btusb.c                          |   58 +-
 drivers/bluetooth/hci_vhci.c                       |    3 +-
 drivers/net/wireless/Kconfig                       |    8 +-
 drivers/net/wireless/airo.c                        |   17 +-
 drivers/net/wireless/ath/ath.h                     |    3 +-
 drivers/net/wireless/ath/ath10k/core.c             |   36 +-
 drivers/net/wireless/ath/ath10k/core.h             |   47 +-
 drivers/net/wireless/ath/ath10k/debug.h            |    2 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   35 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    4 +-
 drivers/net/wireless/ath/ath10k/hw.h               |    6 +
 drivers/net/wireless/ath/ath10k/mac.c              |  634 +++-
 drivers/net/wireless/ath/ath10k/pci.c              |  147 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    4 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  118 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   34 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    1 +
 drivers/net/wireless/ath/ath6kl/usb.c              |    6 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    4 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   41 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    4 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 -
 drivers/net/wireless/ath/ath9k/ath9k.h             |    2 -
 drivers/net/wireless/ath/ath9k/beacon.c            |   23 +-
 drivers/net/wireless/ath/ath9k/common-init.c       |  244 ++
 drivers/net/wireless/ath/ath9k/common-init.h       |   20 +
 drivers/net/wireless/ath/ath9k/common.h            |    2 +
 drivers/net/wireless/ath/ath9k/debug.c             |   26 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    1 -
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   22 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  229 +-
 drivers/net/wireless/ath/ath9k/init.c              |  231 +-
 drivers/net/wireless/ath/ath9k/main.c              |    8 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   10 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    5 +-
 drivers/net/wireless/ath/regd.c                    |   10 +-
 drivers/net/wireless/ath/wil6210/Makefile          |    1 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  202 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |  119 +-
 drivers/net/wireless/ath/wil6210/main.c            |  119 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |  177 +
 drivers/net/wireless/ath/wil6210/txrx.c            |  125 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |    7 +
 drivers/net/wireless/ath/wil6210/wil6210.h         |   82 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  116 +-
 drivers/net/wireless/atmel.c                       |    8 +-
 drivers/net/wireless/b43/Kconfig                   |    2 +-
 drivers/net/wireless/b43/debugfs.h                 |    2 +-
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/b43/phy_common.c              |    4 +-
 drivers/net/wireless/b43/pio.c                     |   10 +-
 drivers/net/wireless/b43/sysfs.c                   |    2 +-
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/b43legacy/main.c              |    4 +-
 drivers/net/wireless/b43legacy/sysfs.c             |    2 +-
 drivers/net/wireless/b43legacy/xmit.c              |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   55 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  209 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |    2 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   55 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |    1 -
 drivers/net/wireless/cw1200/fwio.c                 |    4 +-
 drivers/net/wireless/hostap/hostap_cs.c            |    2 +
 drivers/net/wireless/ipw2x00/ipw2100.c             |    2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    2 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |   13 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   15 +-
 drivers/net/wireless/iwlegacy/commands.h           |    3 +-
 drivers/net/wireless/iwlegacy/common.c             |   83 +-
 drivers/net/wireless/iwlegacy/common.h             |   17 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    4 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c         |    2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    2 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   53 +-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |   14 +
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |    5 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   17 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   24 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |  245 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    2 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |    2 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  118 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |    3 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |    5 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   14 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |    2 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   18 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   35 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   67 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |    2 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    4 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |   48 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   93 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   21 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    4 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |    6 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    4 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    6 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    2 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   47 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   68 +-
 drivers/net/wireless/libertas/if_sdio.c            |    4 +-
 drivers/net/wireless/mac80211_hwsim.c              |   31 +-
 drivers/net/wireless/mac80211_hwsim.h              |    4 +
 drivers/net/wireless/mwifiex/11h.c                 |    4 +-
 drivers/net/wireless/mwifiex/11n.c                 |    8 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   32 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |    3 +-
 drivers/net/wireless/mwifiex/README                |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  205 +-
 drivers/net/wireless/mwifiex/cfp.c                 |    2 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   95 +-
 drivers/net/wireless/mwifiex/debugfs.c             |    8 +-
 drivers/net/wireless/mwifiex/fw.h                  |   13 +
 drivers/net/wireless/mwifiex/ie.c                  |    6 +-
 drivers/net/wireless/mwifiex/init.c                |    3 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    2 +-
 drivers/net/wireless/mwifiex/join.c                |   52 +-
 drivers/net/wireless/mwifiex/main.c                |    7 +-
 drivers/net/wireless/mwifiex/main.h                |   14 +-
 drivers/net/wireless/mwifiex/pcie.c                |    9 +-
 drivers/net/wireless/mwifiex/pcie.h                |    3 +
 drivers/net/wireless/mwifiex/scan.c                |    4 +-
 drivers/net/wireless/mwifiex/sdio.c                |    9 +-
 drivers/net/wireless/mwifiex/sdio.h                |    6 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |   84 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    9 +-
 drivers/net/wireless/mwifiex/sta_event.c           |   40 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  117 +-
 drivers/net/wireless/mwifiex/tdls.c                |   18 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |    4 +-
 drivers/net/wireless/mwifiex/uap_event.c           |    6 +-
 drivers/net/wireless/mwifiex/usb.c                 |   10 +-
 drivers/net/wireless/mwifiex/util.c                |    4 +-
 drivers/net/wireless/mwl8k.c                       |  197 +-
 drivers/net/wireless/orinoco/cfg.c                 |    5 +-
 drivers/net/wireless/orinoco/hw.c                  |    2 +-
 drivers/net/wireless/orinoco/scan.c                |    5 +-
 drivers/net/wireless/orinoco/wext.c                |    2 +-
 drivers/net/wireless/p54/p54usb.c                  |    2 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    3 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   41 +-
 drivers/net/wireless/rtlwifi/Kconfig               |   27 +-
 drivers/net/wireless/rtlwifi/Makefile              |    3 +
 drivers/net/wireless/rtlwifi/btcoexist/Makefile    |    7 +
 .../net/wireless/rtlwifi/btcoexist/halbt_precomp.h |   75 +
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.c   | 3698 ++++++++++++++++=
++++
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.h   |  173 +
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  | 1011 ++++++
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |  559 +++
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c   |  218 ++
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h   |   52 +
 drivers/net/wireless/rtlwifi/core.c                |  124 +-
 drivers/net/wireless/rtlwifi/core.h                |    4 +
 drivers/net/wireless/rtlwifi/pci.c                 |   66 +-
 drivers/net/wireless/rtlwifi/pci.h                 |   14 +
 drivers/net/wireless/rtlwifi/ps.c                  |  100 +
 drivers/net/wireless/rtlwifi/ps.h                  |   60 +
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   62 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       |   63 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |    1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h       |   16 -
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   20 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |   71 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |   16 -
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   31 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |   71 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   50 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |  429 +--
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h       |   14 -
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   34 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   87 +-
 drivers/net/wireless/rtlwifi/rtl8192se/reg.h       |   12 -
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.h       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |    5 -
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |   42 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  260 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |   18 +-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |    2 +
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   60 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |  530 +--
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |   21 -
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       |   16 -
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |   13 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |    5 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |   13 +-
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile    |   19 +
 drivers/net/wireless/rtlwifi/rtl8723be/def.h       |  248 ++
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        | 1325 +++++++
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h        |  310 ++
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |  620 ++++
 drivers/net/wireless/rtlwifi/rtl8723be/fw.h        |  248 ++
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        | 2527 +++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/hw.h        |   64 +
 drivers/net/wireless/rtlwifi/rtl8723be/led.c       |  153 +
 drivers/net/wireless/rtlwifi/rtl8723be/led.h       |   35 +
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c       | 2152 ++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/phy.h       |  217 ++
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c    |  106 +
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h    |  304 ++
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c |  140 +
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h |   95 +
 drivers/net/wireless/rtlwifi/rtl8723be/reg.h       | 2277 ++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/rf.c        |  504 +++
 drivers/net/wireless/rtlwifi/rtl8723be/rf.h        |   43 +
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |  384 ++
 drivers/net/wireless/rtlwifi/rtl8723be/sw.h        |   35 +
 drivers/net/wireless/rtlwifi/rtl8723be/table.c     |  572 +++
 drivers/net/wireless/rtlwifi/rtl8723be/table.h     |   43 +
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |  960 +++++
 drivers/net/wireless/rtlwifi/rtl8723be/trx.h       |  617 ++++
 drivers/net/wireless/rtlwifi/rtl8723com/Makefile   |    9 +
 .../net/wireless/rtlwifi/rtl8723com/dm_common.c    |   65 +
 .../net/wireless/rtlwifi/rtl8723com/dm_common.h    |   33 +
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |  329 ++
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |  126 +
 drivers/net/wireless/rtlwifi/rtl8723com/main.c     |   33 +
 .../net/wireless/rtlwifi/rtl8723com/phy_common.c   |  434 +++
 .../net/wireless/rtlwifi/rtl8723com/phy_common.h   |   89 +
 drivers/net/wireless/rtlwifi/usb.c                 |    4 +-
 drivers/net/wireless/rtlwifi/wifi.h                |  518 ++-
 drivers/net/wireless/ti/wilink_platform_data.c     |   37 +-
 drivers/net/wireless/ti/wl1251/cmd.c               |    2 +-
 drivers/net/wireless/ti/wl1251/rx.c                |    2 +-
 drivers/net/wireless/ti/wl1251/sdio.c              |   31 +-
 drivers/net/wireless/ti/wl1251/spi.c               |   71 +-
 drivers/net/wireless/ti/wl1251/wl1251.h            |    4 +-
 drivers/net/wireless/ti/wlcore/main.c              |    8 +-
 drivers/net/wireless/ti/wlcore/spi.c               |    4 +-
 drivers/net/wireless/ti/wlcore/sysfs.c             |    2 +-
 drivers/net/wireless/wl3501_cs.c                   |    6 +-
 drivers/net/wireless/zd1201.c                      |    9 +-
 drivers/staging/rtl8821ae/rc.c                     |    1 +
 include/linux/ieee80211.h                          |   36 -
 include/linux/miscdevice.h                         |    1 +
 include/linux/tty.h                                |    6 +-
 include/linux/wl12xx.h                             |   24 +-
 include/net/bluetooth/bluetooth.h                  |    1 +
 include/net/bluetooth/hci.h                        |   76 +-
 include/net/bluetooth/hci_core.h                   |  197 +-
 include/net/bluetooth/l2cap.h                      |    8 +-
 include/net/bluetooth/mgmt.h                       |   51 +-
 include/net/bluetooth/rfcomm.h                     |   10 +-
 include/net/cfg80211.h                             |   24 +-
 include/net/mac80211.h                             |   43 +-
 include/uapi/linux/nl80211.h                       |   42 +-
 net/bluetooth/a2mp.c                               |    8 +-
 net/bluetooth/af_bluetooth.c                       |    2 +-
 net/bluetooth/hci_conn.c                           |  206 +-
 net/bluetooth/hci_core.c                           | 1469 ++++++--
 net/bluetooth/hci_event.c                          |  478 ++-
 net/bluetooth/hci_sock.c                           |    1 +
 net/bluetooth/hci_sysfs.c                          |   18 +-
 net/bluetooth/l2cap_core.c                         |  616 ++--
 net/bluetooth/l2cap_sock.c                         |   62 +-
 net/bluetooth/mgmt.c                               |  913 ++++-
 net/bluetooth/rfcomm/core.c                        |   92 +-
 net/bluetooth/rfcomm/sock.c                        |   33 +-
 net/bluetooth/rfcomm/tty.c                         |  262 +-
 net/bluetooth/smp.c                                |  418 ++-
 net/bluetooth/smp.h                                |   22 +-
 net/mac80211/cfg.c                                 |    7 +-
 net/mac80211/debugfs_netdev.c                      |   13 +
 net/mac80211/driver-ops.h                          |   12 +-
 net/mac80211/ht.c                                  |    2 -
 net/mac80211/ibss.c                                |    5 +
 net/mac80211/ieee80211_i.h                         |    2 +
 net/mac80211/iface.c                               |   11 +-
 net/mac80211/main.c                                |   12 +
 net/mac80211/mlme.c                                |   72 +-
 net/mac80211/rx.c                                  |    5 +-
 net/mac80211/scan.c                                |    9 +-
 net/wireless/chan.c                                |    6 +-
 net/wireless/genregdb.awk                          |    2 +
 net/wireless/ibss.c                                |    7 +-
 net/wireless/mesh.c                                |    6 +
 net/wireless/nl80211.c                             |   33 +-
 net/wireless/rdev-ops.h                            |    9 +-
 net/wireless/reg.c                                 |   83 +-
 net/wireless/trace.h                               |   12 +-
 net/wireless/util.c                                |   31 +-
 313 files changed, 30471 insertions(+), 4733 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/ti,wl125=
1.txt
 create mode 100644 drivers/net/wireless/ath/ath9k/common-init.c
 create mode 100644 drivers/net/wireless/ath/ath9k/common-init.h
 create mode 100644 drivers/net/wireless/ath/wil6210/rx_reorder.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbt_precomp.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/trx.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/dm_common.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/main.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/phy_common.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTHgvtAAoJEJctW/TcYTgG6AIQAJUdkTzwP/KguF5FpFJcB4mL
+YxbCYC/m6DtkXJubwWxa4k/9bB5g79u6xax9nP8BoKw4whBW0tzjIZlIQ5lA+b2
IabStb9K1I0xO6dStJr1YlaJcArNqY4pEJY/a43+BghQBVuRsIU92M8ScNinSKYE
bkXoeTV6hpUOHZ9U78pCN15IQ41ekhx25SncQh+CkbO7RYJht3qntk7+QIF8skkQ
OojRFdiIit0HSaUhm8wyNU5yFw1URHBhRx7rzfXSsVlf0MQetvnscSAxg/Fa663F
LjJSgMQafQRX00nPYs/QTmB2ZO75CXCRyFliiEd2UQflUu98paCl6hZGT4rZkJ0Q
MDNqQ3/aPRxptkl/x7TevCOYdJD16z6l8Uci+gjOdF2uXmHBwupQ9xflYYV7kCat
+PuVyU+AoVgcvU18iy3nDIg9zQY3YgNBVNxedcCFB3pddvqvs4rpWOUmmGHEe/6w
50kzsD1rkdZsJhM+zltZbdCSPdsby3lJTKzwG34tVXOf18frDFnOnOL3NMCKF7gi
EClz3TRCq+y6n/8h7rYQUloA+pGKes05EcGJEw0sJA0sg1hpZGnW8S9jrjxuo+Qb
BOPdOvtYoyyBhZZ/BAMpe441fiM1nPa8/BpSx6RTJC8LtgvWCA8N+BLOLoc2VHFD
0OlsSOzLocdE2qZR/Ede
=3Z5/
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
