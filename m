From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-07-11
Date: Fri, 11 Jul 2014 16:06:50 -0400
Message-ID: <20140711200650.GL25478@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.17 stream...

This is primarily a Bluetooth pull.  Gustavo says:

"A lot of patches to 3.17. The bulk of changes here are for LE support.
The 6loWPAN over Bluetooth now has it own module, we also have support for
background auto-connection and passive scanning, Bluetooth device address
provisioning, support for reading Bluetooth clock values and LE connection
parameters plus many many fixes."

The balance is just a pull of the wireless.git tree, to avoid some
pending merge problems.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5e6438db34d522ee1c78b5d4c1c35a4a3bbd5054:

  Merge branch 'mvebu' (2014-07-10 17:19:38 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 95d01a669bd35d0e8eb28dd8a946876c00a9a61a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-07-11 15:52:57 -0400)

----------------------------------------------------------------

Adam Lee (1):
      Bluetooth: ath3k: reduce pipe setting times in ath3k_load_fwfile()

Amitkumar Karwar (2):
      mwifiex: fix Tx timeout issue
      mwifiex: initialize Tx/Rx info of a packet correctly

Anantha Krishnan (1):
      Bluetooth: Add support for Acer [13D3:3432]

Andre Guedes (6):
      Bluetooth: Use macro instead of hard-coded value
      Bluetooth: Connection parameters check helper
      Bluetooth: Connection Parameter Update Procedure
      Bluetooth: Move LE event mask setting into init3 phase
      Bluetooth: Enable new LE meta event
      Bluetooth: Introduce "New Connection Parameter" Event

Andrea Merello (1):
      rt2800usb: Don't perform DMA from stack

Arend van Spriel (1):
      brcmfmac: assign chip id and rev in bus interface after brcmf_usb_dln=
eeded

Bartosz Markowski (1):
      ath10k: fix 8th virtual AP interface with DFS

Bing Zhao (1):
      Bluetooth: btmrvl: indicate pscan scheduling instant in a debug event

Chin-Ran Lo (1):
      Bluetooth: btmrvl: wait for HOST_SLEEP_ENABLE event in suspend

Eliad Peller (1):
      cfg80211: fix elapsed_jiffies calculation

Fabian Frederick (1):
      Bluetooth: constify seq_operations

Johan Hedberg (104):
      Bluetooth: Fix overriding higher security level in SMP
      Bluetooth: Refactor authentication method lookup into its own function
      Bluetooth: Fix rejecting pairing in case of insufficient capabilities
      Bluetooth: Fix missing NULL check for smp_chan_create() return value
      Bluetooth: Remove unnecessary SMP STK define
      Bluetooth: Remove HCI prefix from SMP LTK defines
      Bluetooth: Remove unused LTK authentication defines
      Bluetooth: Convert SMP flags into an enum
      Bluetooth: Add flexible buffer byte order swapping function
      Bluetooth: Fix validating IO capability values in mgmt commands
      Bluetooth: Fix checking for master LTKs
      Bluetooth: Update hci_add_link_key() to return pointer to key
      Bluetooth: Move mgmt event sending out from hci_add_link_key()
      Bluetooth: Rename HCI_DEBUG_KEYS to HCI_KEEP_DEBUG_KEYS
      Bluetooth: Don't store debug keys if flag for them is not set
      Bluetooth: Convert hcon->flush_key to a proper flag
      Bluetooth: Fix ignoring debug keys in mgmt_load_link_keys
      Bluetooth: Add a new HCI_USE_DEBUG_KEYS flag
      Bluetooth: Add support for mode 0x02 for mgmt_set_debug_keys
      Bluetooth: Convert hci_conn->link_mode into flags
      Bluetooth: Fix missing hdev locking in smp_cmd_ident_addr_info
      Bluetooth: Add dedicated AES instance for each SMP context
      Bluetooth: Update SMP crypto functions to take the SMP context
      Bluetooth: Remove unnecessary hci_dev_unlock for smp_user_confirm_rep=
ly
      Bluetooth: Fix missing check for SMP session in smp_user_confirm_reply
      Bluetooth: Remove unnecessary hcon->smp_conn variable
      Bluetooth: Use kzalloc instead of kmalloc for pending mgmt commands
      Bluetooth: Add tracking of local and piconet clock values
      Bluetooth: Add support for Get Clock Info mgmt command
      Bluetooth: Allow L2CAP getpeername() for BT_CONFIG state
      Bluetooth: Fix redundant encryption when receiving Security Request
      Bluetooth: Add flag to track STK encryption
      Bluetooth: Allow re-encryption with LTK when STK is in use
      Bluetooth: Fix redundant device (un)blocked events
      Bluetooth: Centralize looking up blocked devices to l2cap_recv_frame
      Bluetooth: Drop LE connections for blocked devices
      Bluetooth: Fix sparse warning with btmrvl driver
      Bluetooth: Rename hci_conn_params_clear to hci_conn_params_clear_all
      Bluetooth: Add specific connection parameter clear functions
      Bluetooth: Add new auto_conn value matching mgmt action 0x00
      Bluetooth: Remove only enabled entries with Remove Device command
      Bluetooth: Add Load Connection Parameters command
      Bluetooth: Fix missing update of conn params
      Bluetooth: Make hci_le_conn_update return the store hint
      Bluetooth: Pass store hint to mgmt_new_conn_param
      Bluetooth: Make is_identity_address a global function
      Bluetooth: Don't send connection parameters without identity address
      Bluetooth: Track number of added devices with HCI_AUTO_CONN_REPORT
      Bluetooth: Allow mgmt_device_found events for kernel-side scanning
      Bluetooth: Add support for background LE scanning
      Bluetooth: Support scanning for devices using RPA
      Bluetooth: Fix buffer overflow with variable length commands
      Bluetooth: Fix missing update of pend_le_reports
      Bluetooth: Remove redundant IRK lookup
      Bluetooth: Use hci_conn_params in pend_le_conns
      Bluetooth: Remove unnecessary checks for auto-connected devices
      Bluetooth: Add identity address check in param lookup functions
      Bluetooth: Fix missing return statement in process_adv_report
      Bluetooth: Convert pend_le_conn list to a generic action list
      Bluetooth: Convert pend_le_reports into a list
      Bluetooth: Simplify use of hci_pend_le_conns_clear()
      Bluetooth: Don't bother doing anything if auto_connect doesn't change
      Bluetooth: Simplify hci_conn_params->action list usage
      Bluetooth: Remove unused hci_pend_le_conn_del() function
      Bluetooth: Fix clearing and restarting all LE actions on power cycle
      Bluetooth: Remove unnecessary usage of hci_pend_le_conn_add
      Bluetooth: Remove unused hci_pend_le_conn_add function
      Bluetooth: Make hci_pend_le_conn_lookup more general purposed
      Bluetooth: Use hci_pend_le_action_lookup to look up report entries
      Bluetooth: Don't take actions on blocked devices when scanning
      Bluetooth: Use list_del when freeing the list entry
      Bluetooth: Restrict blocked device check in l2cap_recv_frame to LE
      Bluetooth: Fix sending Device Removed when clearing all parameters
      Bluetooth: Use lower timeout for LE auto-connections
      Bluetooth: Fix updating background scan for LE connect complete
      Bluetooth: Fix connecting devices during LE device discovery
      Bluetooth: Remove redundant IRK lookup in mgmt_device_found()
      Bluetooth: Remove unnecessary return value from check_pending_le_conn
      Bluetooth: Update discovery state earlier in hci_discovery_set_state
      Bluetooth: Don't let background scanning interfering with discovery
      Bluetooth: Enable passive scanning whenever we're connectable
      Bluetooth: Remove auth_type parameter from hci_connect_le()
      Bluetooth: Pass desired connection role to hci_connect_le()
      Bluetooth: Don't try background scanning if LE is not enabled
      Bluetooth: Add flag to track the real advertising state
      Bluetooth: Remove unnecessary mgmt_advertising function
      Bluetooth: Use real advertising state to random address update decisi=
on
      Bluetooth: Simplify usage of the enable_advertising function
      Bluetooth: Use the correct flag to decide to disable advertising
      Bluetooth: Stop advertising always before initiating a connection
      Bluetooth: Fix advertising and active scanning co-existence
      Bluetooth: Fix check for re-enabling advertising
      Bluetooth: Fix setting STOPPING state for discovery
      Bluetooth: Fix connectable and discoverable supported settings values
      Bluetooth: Fix toggling background scan when changing connectable sta=
te
      Bluetooth: Fix clearing HCI_LE_ADV for LE connections
      Bluetooth: Unify helpers for bdaddr_list manipulations
      Bluetooth: Introduce a whitelist for BR/EDR devices
      Bluetooth: Update page scan when necessary for Add/Remove Device
      Bluetooth: Fix incorrectly setting HCI_CONNECTABLE
      Bluetooth: Refactor connection request handling
      Bluetooth: Enable page scan also if there are white list entries
      Bluetooth: Add white list lookup for incoming connection requests
      Bluetooth: Fix setting HCI_CONNECTABLE from ioctl code

Johannes Berg (2):
      Revert "cfg80211: Use 5MHz bandwidth by default when checking usable =
channels"
      nl80211: move set_qos_map command into split state

John W. Linville (8):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'ath-current' of git://github.com/kvalo/ath
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jukka Rissanen (5):
      Bluetooth: Provide L2CAP ops callback for memcpy_fromiovec
      Bluetooth: 6LoWPAN: Use connected oriented channel instead of fixed o=
ne
      Bluetooth: 6LoWPAN: Create a kernel module
      Bluetooth: 6LoWPAN: Count module usage
      Bluetooth: 6LoWPAN: Remove network devices when unloading

Loic Poulain (2):
      Bluetooth: Ignore H5 non-link packets in non-active state
      Bluetooth: Remove redundant calls to h5_reset_rx

Lukasz Rymanowski (1):
      Bluetooth: Fix for ACL disconnect when pairing fails

Marcel Holtmann (82):
      Revert "Bluetooth: Add a new PID/VID 0cf3/e005 for AR3012."
      Merge git://git.kernel.org/.../bluetooth/bluetooth
      Bluetooth: Use const for struct l2cap_ops field
      Bluetooth: Assign L2CAP socket priority when allocating SKB
      Bluetooth: Shrink size of struct l2cap_ctrl fields
      Bluetooth: Use explicit header and body length for L2CAP SKB allocati=
on
      Bluetooth: Use struct delayed_work for HCI command timeout
      Bluetooth: Use separate dbg_flags to special debugfs options
      Bluetooth: Store current LE connection parameters in hci_conn struct
      Bluetooth: Track LE connection parameter update event
      Bluetooth: Set default min/max connection interval for LE slaves
      Bluetooth: Add support LE slave connection update procedure
      Bluetooth: Remove ssp_debug_mode debugfs option
      Bluetooth: Remove reason parameter from hci_amp_disconn function
      Bluetooth: Remove unneeded hci_conn_disconnect abstraction
      Bluetooth: Send HCI_Read_Clock_Offset before disconnecting
      Bluetooth: Increment management interface revision
      Bluetooth: Restrict access for raw-only controllers
      Bluetooth: Don't use non-resolvable private address for passive scann=
ing
      Bluetooth: Move hci_pend_le_conn_* functions to different location
      Bluetooth: Clear pending connections from hci_conn_params_clear
      Bluetooth: Update background scanning from hci_conn_params_clear
      Bluetooth: Store latency and supervision timeout in connection params
      Bluetooth: Use LE connection parameters if known
      Bluetooth: Add support for Add/Remove Device management commands
      Bluetooth: Replace le_auto_conn debugfs with device_list entry
      Bluetooth: Add Device Added and Device Removed management events
      Bluetooth: Provide defaults for LE connection latency and timeout
      Bluetooth: Expose default connection latency setting via debugfs
      Bluetooth: Expose default supervision timeout setting via debugfs
      Bluetooth: Provide function to create and set connection parameters
      Bluetooth: Add default connection parameters before pairing
      Bluetooth: Start background scanning only when controller is ready
      Bluetooth: Use bool for smp_ltk_encrypt return value
      Bluetooth: Change hci_conn_params_add to return the parameter struct
      Bluetooth: Use hci_conn_params_add within hci_conn_params_set
      Bluetooth: Remove connection interval parameters from hci_conn_params=
_set
      Bluetooth: Fix merge of advertising data and scan response data
      Bluetooth: Provide flags parameter direct to mgmt_device_found
      Bluetooth: Add support for Not Connectable flag for Device Found even=
ts
      Bluetooth: Do not trigger background scanning when HCI_AUTO_OFF is set
      Bluetooth: Ensure that background scanning gets enabled on power on
      Bluetooth: Add support for hdev->set_bdaddr callback handling
      Bluetooth: Add public address configration for Broadcom USB devices
      Bluetooth: Add public address configration for Intel USB devices
      Bluetooth: Default to internal use manufacturer identifier
      Bluetooth: Check for default address of Intel USB controllers
      Bluetooth: Check for default address of Broadcom BCM20702A0 controlle=
rs
      Bluetooth: Introduce unconfigured controller state
      Bluetooth: Add support for Unconfigured Index Added events
      Bluetooth: Add support for Unconfigured Index Removed events
      Bluetooth: Add support for Read Unconfigured Index List command
      Bluetooth: Support HCI_QUIRK_RAW_DEVICE for hci_vhci driver
      Bluetooth: Add support for controller configuration info command
      Bluetooth: Fix constant for public address configuration
      Bluetooth: Document the existing device quirks
      Bluetooth: Add quirk for invalid controller address setting
      Bluetooth: Set HCI_QUIRK_INVALID_BADDR for Intel USB default address
      Bluetooth: Set HCI_QUIRK_INVALID_BADDR for BCM20702A0 default address
      Bluetooth: Allow reading configuration info when unconfigured
      Bluetooth: Add quirk for external configuration requirement
      Bluetooth: Fix quirks that are valid during setup driver callback
      Bluetooth: Support HCI_QUIRK_EXTERNAL_CONFIG for hci_vhci driver
      Bluetooth: Add support for Set External Configuration management comm=
and
      Bluetooth: Move mgmt_event helper function to different location
      Bluetooth: Add support for New Configuration Options management event
      Bluetooth: Use a more simpler style for HCI event callbacks
      Bluetooth: Run special init procedure for unconfigured controllers
      Bluetooth: Store Bluetooth address from controller setup
      Bluetooth: Run controller setup after external configuration
      Bluetooth: Add support for changing the public device address
      Bluetooth: Clear HCI_RAW flag when controller becomes configured
      Bluetooth: Add support for Intel bootloader devices
      Bluetooth: Skip unconfigured init procedure for raw-only devices
      Bluetooth: Remove module parameters for ignoring USB devices
      Bluetooth: Handle Intel USB bootloader with buggy interrupt
      Bluetooth: Ignore isochronous endpoints for Intel USB bootloader
      Bluetooth: Fix memory leaking when hdev->send returns an error
      Bluetooth: Enforce providing hdev->send driver callback
      Bluetooth: Use BTUSB_BROKEN_ISOC flag for CSR USB sniffer devices
      Bluetooth: Fix enabling Authenticated Payload Timeout Expired event
      Bluetooth: Don't send ERTM configuration option when disabled

Max Stepanov (1):
      mac80211: WEP extra head/tail room in ieee80211_send_auth

Michal Kazior (1):
      ath10k: remove unnecessary htt rx corruption check

Nick Pelly (1):
      Bluetooth: Fallback to SCO on error code 0x10 (Connection Accept Time=
out)

Stephan Gabert (1):
      Bluetooth: Remove trailing whitespaces from Kconfig

 drivers/bluetooth/Kconfig                     |   12 +-
 drivers/bluetooth/ath3k.c                     |    8 +-
 drivers/bluetooth/btmrvl_drv.h                |    3 +
 drivers/bluetooth/btmrvl_main.c               |   44 +-
 drivers/bluetooth/btmrvl_sdio.c               |    5 +
 drivers/bluetooth/btmrvl_sdio.h               |    2 +
 drivers/bluetooth/btusb.c                     |  188 +++-
 drivers/bluetooth/hci_h5.c                    |    5 +-
 drivers/bluetooth/hci_vhci.c                  |   34 +-
 drivers/net/wireless/ath/ath10k/core.c        |    6 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c      |   18 -
 drivers/net/wireless/brcm80211/brcmfmac/usb.c |    5 +-
 drivers/net/wireless/mwifiex/11n_aggr.c       |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c       |    1 +
 drivers/net/wireless/mwifiex/cmdevt.c         |    1 +
 drivers/net/wireless/mwifiex/main.c           |    1 +
 drivers/net/wireless/mwifiex/sta_tx.c         |    1 +
 drivers/net/wireless/mwifiex/tdls.c           |    2 +
 drivers/net/wireless/mwifiex/txrx.c           |    1 +
 drivers/net/wireless/mwifiex/uap_txrx.c       |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c       |   28 +-
 include/net/bluetooth/bluetooth.h             |   18 +-
 include/net/bluetooth/hci.h                   |  135 ++-
 include/net/bluetooth/hci_core.h              |  134 ++-
 include/net/bluetooth/l2cap.h                 |   36 +-
 include/net/bluetooth/mgmt.h                  |   99 ++
 net/bluetooth/6lowpan.c                       |  857 +++++++++++++----
 net/bluetooth/6lowpan.h                       |   47 -
 net/bluetooth/Kconfig                         |    6 +-
 net/bluetooth/Makefile                        |    4 +-
 net/bluetooth/a2mp.c                          |    8 +-
 net/bluetooth/af_bluetooth.c                  |    2 +-
 net/bluetooth/hci_conn.c                      |  176 +++-
 net/bluetooth/hci_core.c                      |  909 +++++++++---------
 net/bluetooth/hci_event.c                     |  698 ++++++++++----
 net/bluetooth/hci_sock.c                      |   12 +-
 net/bluetooth/l2cap_core.c                    |  144 +--
 net/bluetooth/l2cap_sock.c                    |   46 +-
 net/bluetooth/mgmt.c                          | 1254 +++++++++++++++++++++=
----
 net/bluetooth/smp.c                           |  237 +++--
 net/bluetooth/smp.h                           |    7 +
 net/mac80211/util.c                           |    5 +-
 net/wireless/core.h                           |    2 +-
 net/wireless/nl80211.c                        |   11 +-
 net/wireless/reg.c                            |   22 +-
 45 files changed, 3758 insertions(+), 1478 deletions(-)
 delete mode 100644 net/bluetooth/6lowpan.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTwEPaAAoJEJctW/TcYTgGSlsP/3cLGGBBl2DEcjO9aWrR9Z65
SyzrXT0FaDO+sqsMKomKLSWA59jzIdg5wRBxGc4+fuu8GIwWk5o5B7vlZ4HBRAQU
QQ2Asris6MbLMPq3K0U4T//AYmIJn9/njx7Hz4BzbwiPieK7Cfdeg9jLSeHxBWuz
9MVgnVFp4tHIicl58VQDcqY/idpY47rddFpAWWh2DLXNqKov74W/wbyYA0vt2kk2
gbIdpsJEqur086AYy+gEYm2MqnQ3dU9OrvA7fdBVdMTGVx+c/MnVUptExPqM5epr
lvXH+SM6+mZgNBfHJdcB0O0KWf+A7hIjE7rvkMdU+7yY0U5vKWV8vRUGeXi9sKQU
bIaCibrr/y526H6fxLymYBCYat3B+3YExn5ygsvQBjUU2I63jn0qCKX8xdIJRSpC
jzG9q7BhUCG50y5aEHNNBr5hsLnpXGlTpsR2niLYK70+IRa4AIEqzNImzVEcs8Xb
ywpvak3iaJa8lUAxpBl47oaP2DB5eQrKevt+O5kK2u2HIAQycPR4PSzPyLtprxC9
nJdry+Y/SoeN5VBpoyWD/wBGagWo6AkSlX4mM41+WJEu8L3gGxf/ESnBdjvFGCyM
TA4CT0wH+Jy46t7MkEja4pgNTPyD6GtypJIG0J94LAj69deUAsoJFqVhMq3Sl8je
sBmd0/sMWLXTCC5piK01
=+E07
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--
