From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-11-28
Date: Wed, 28 Nov 2012 14:23:52 -0500
Message-ID: <20121128192352.GB9118@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wRRV7LY7NUeQGEoC"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 79d38f7d6cf545ff838dd5227869f3916d1d100d

Dave,

This pull request is intended for the 3.8 stream.  It is a bit large
-- I guess Thanksgiving got me off track!  At least the code got to
spend some time in linux-next... :-)

This includes the usual batch of pulls for Bluetooth, NFC, and mac80211
as well as iwlwifi.  Also here is an ath6kl pull, and a new driver
in the rtlwifi family.  The brcmfmac, brcmsmac, ath9k, and mwl8k get
their usual levels of attention, and a handful of other updates tag
along as well.

For more detail on the pulls, please see below...

On Bluetooth, Gustavo says:

"Another set of patches for integration in wireless-next. There are two big=
 set
of changes in it: Andrei Emeltchenko and Mat Martineau added more patches
towards a full Bluetooth High Speed support and Johan Hedberg improve the
single mode support for Bluetooth dongles. Apart from that we have small fi=
xes
and improvements."

=2E..and:

"A few patches to 3.8. The majority of the work here is from Andrei on the =
High
Speed support. Other than that Johan added support for setting LE advertisi=
ng
data. The rest are fixes and clean ups and small improvements like support =
for
a new broadcom hardware."

On mac80211, Johannes says:

"This is for mac80211, for -next (3.8). Plenty of changes, as you can see
below. Some fixes for previous changes like the export.h include, the
beacon listener fix from Ben Greear, etc. Overall, no exciting new
features, though hwsim does gain channel context support for people to
try it out and look at."

=2E..and...:

"This one contains the mac80211-next material. Apart from a few small new
features and cleanups I have two fixes for the channel context code. The
RX_END timestamp support will probably be reworked again as Simon Barber
noted the calculations weren't really valid, but the discussions there
are still going on and it's better than what we had before."

=2E..and:

"Please pull (see below) to get the following changes:
 * a fix & a debug aid in IBSS from Antonio,
 * mesh cleanups from Marco,
 * a few bugfixes for some of my previous patches from Arend and myself,
 * and the big initial VHT support patchset"

And on iwlwifi, Johannes says:

"In addition to the previous four patches that I'm not resending,
we have a number of cleanups, message reduction, firmware error
handling improvements (yes yes... we need to fix them instead)
and various other small things all over."

=2E..and:

"In his quest to try to understand the current iwlwifi problems (like
stuck queues etc.) Emmanuel has first cleaned up the PCIe code, I'm
including his changes in this pull request. Other than that I only have
a small cleanup from Sachin Kamat to remove a duplicate include and a
bugfix to turn off MFP if software crypto is enabled, but this isn't
really interesting as MFP isn't supported right now anyway."

On NFC, Samuel says:

"With this one we have:

- A few HCI improvements in preparation for an upcoming HCI chipset support.
- A pn544 code cleanup after the old driver was removed.
- An LLCP improvement for notifying user space when one peer stops ACKing I
  frames."

On ath6kl, Kalle says:

"Major changes this time are firmware recover support to gracefully
handle if firmware crashes, support for changing regulatory domain and
support for new ar6004 hardware revision 1.4. Otherwise there are just
smaller fixes or cleanups from different people."

Thats about it... :-)  Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 03f52a0a554210d5049eeed9f1bb29047dc807cb:

  ip6mr: Add sizeof verification to MRT6_ASSERT and MT6_PIM (2012-11-26 17:=
35:58 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 79d38f7d6cf545ff838dd5227869f3916d1d100d:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-11-28 10:56:03 -0500)

----------------------------------------------------------------

Aarthi Thiruvengadam (1):
      ath6kl: use custom MAC address for newly created interfaces

Amitkumar Karwar (2):
      nl/cfg80211: advertise OBSS scan requirement
      mwifiex: add support for SDIO card reset

Andi Kleen (1):
      ath6kl: fix uninitialized variable in ath6kl_sdio_enable_scatter()

Andrei Emeltchenko (27):
      Bluetooth: trivial: Remove unneeded assignment
      Bluetooth: Use helper function sending EFS conf rsp
      Bluetooth: AMP: Process Physical Link Complete evt
      Bluetooth: AMP: Process Logical Link complete evt
      Bluetooth: Add put(hcon) when deleting hchan
      Bluetooth: trivial: Fix braces style and remove empty line
      Bluetooth: Save hs_hchan instead of hs_hcon in loglink complete
      Bluetooth: Return correct L2CAP response type
      Bluetooth: Derive remote and local amp id from chan struct
      Bluetooth: AMP: Add Logical Link Create function
      Bluetooth: AMP: Process Disc Logical Link
      Bluetooth: AMP: Process Disc Physical Link Complete evt
      Bluetooth: AMP: Remove hci_conn receiving error command status
      Bluetooth: Disconnect logical link when deleting chan
      Bluetooth: AMP: Check for hs_hcon instead of ctrl_id
      Bluetooth: AMP: Use l2cap_physical_cfm in phylink complete evt
      Bluetooth: Process Create Chan Request
      Bluetooth: Rename ctrl_id to remote_amp_id
      Bluetooth: Use __l2cap_no_conn_pending helper
      Bluetooth: Remove unneeded local_amp_id initialization
      Bluetooth: Refactor locking in amp_physical_cfm
      Bluetooth: Disable FCS only for new HS channels
      Bluetooth: trivial: Use __constant for constants
      Bluetooth: Fix sending L2CAP Create Chan Req
      Bluetooth: Set local_amp_id after getting Phylink Completed evt
      Bluetooth: Improve error message printing
      Bluetooth: AMP: Set no FCS for incoming L2CAP chan

Antonio Quartulli (6):
      nl/cfg80211: add the NL80211_CMD_SET_MCAST_RATE command
      mac80211: implement set_mcast_rate() callback
      cfg80211: store the ssid into wirless_dev in AP mode
      nl80211: send the NL80211_ATTR_SSID in nl80211_send_iface()
      mac80211: in ADHOC don't update last_rx if sta is not authorized
      mac80211: in ADHOC print debug message for every Auth message

Arend van Spriel (21):
      wireless: add peer-to-peer related definitions
      brcmfmac: remove obsolete structure ap_info
      brcmfmac: simplify if-else condition in brcmf_cfg80211_escan()
      brcmfmac: restrict error condition in brcmf_inform_bss()
      brcmfmac: make pointer type constant in brcmf_set_management_ie()
      brcmfmac: change parameter of brcmf_set_management_ie()
      brcmfmac: remove obsolete variable from brcmf_cfg80211_start_ap()
      brcmfmac: fix NULL pointer access in brcmf_create_iovar()
      brcmfmac: fix build regression
      brcmfmac: use struct brcmf_if parameter in firmware event callbacks
      brcmfmac: rework firmware event handling code
      brcmfmac: change parameter in brcmf_add_if() function
      brcmfmac: fix for multiple netdevice interface support
      brcmfmac: correct handling IF firmware event
      brcmfmac: change mac address parameter in brcmf_add_if()
      brcmfmac: remove mac address validation from brcmf_net_attach()
      brcmfmac: fix wrong usage of unaligned include file
      brcmfmac: ignore IF event if it is a add for ifidx 0
      brcmfmac: restructure handling of IF event
      mac80211: check add_chanctx callback before use in ieee80211_reconfig
      cfg80211: change function signature of cfg80211_get_p2p_attr()

Assaf Krauss (1):
      iwlwifi: remove MFP Kconfig option

Avinash Patil (1):
      mwifiex: add multi-queue support

Bala Shanmugam (1):
      ath6kl: Add support for AR6004 hardware version 1.3

Ben Greear (1):
      cfg80211: allow registering more than one beacon listener

Bing Zhao (1):
      mwifiex: process RX packets in SDIO IRQ thread directly

Christian Lamparter (1):
      p54: improve TSF timestamp precision

Dan Carpenter (1):
      ath5k: precedence error in ath5k_hw_nic_wakeup()

Dengke Qiu (1):
      ath6kl: fix link speed when using sgi

Denis Kirjanov (1):
      Bluetooth:Replace list_for_each with list_for_each_entry() helper

Eliad Peller (1):
      mac80211: make remain_on_channel() op pass vif param

Emmanuel Grumbach (20):
      iwlwifi: don't leak Tx skb when a queue is disabled
      iwlwifi: handle RFKILL logic in the transport layer
      iwlwifi: don't call stop_device twice
      iwlwifi: check the SCD conf from ALIVE response
      iwlwifi: zero trans_cfg before settings its fields
      mac80211: include export.h in aes_cmac
      iwlwifi: don't warn if transport's allocation failed
      iwlwifi: don't enable interrupt as a W/A when MSI is enabled
      iwlwifi: add comments for the PCIe transport statuses
      iwlwifi: rename functions in transport layer
      iwlwifi: init the replenish work in rx_init
      iwlwifi: continue clean up - pcie/rx.c
      iwlwifi: continue clean up - pcie/trans.c
      iwlwifi: continue clean up - pcie/tx.c
      iwlwifi: merge 2 functions in reclaim flow
      iwlwifi: make iwl_queue_used return bool
      iwlwifi: more cleanup in pcie/rx.c
      iwlwifi: make iwl_pcie_rxq_inc_wr_ptr static
      iwlwifi: update the RB_TIMEOUT to 0x11
      iwlwifi: remove effectless assignment

Eric Lapuyade (5):
      NFC: Fix hci_connect_gate() when a pre-opened pipe is passed
      NFC: Ignore err when chip doesn't implement HW/SW info registers
      NFC: Dot not dispatch HCI event received on unopened pipe
      NFC: Export nfc_hci_result_to_errno as it can be needed by HCI drivers
      NFC: Export nfc_hci_sak_to_protocol()

Franky Lin (5):
      brcmfmac: use dynamically allocated control frame buffer
      brcmfmac: decrease the range of SDIO access lock
      brcmfmac: protect consecutive SDIO access with sdio_claim_host
      brcmfmac: remove brcmf_sdbrcm_wait_for_event
      brcmfmac: change return type of brcmf_sdio_hdparser

Gustavo Padovan (1):
      Bluetooth: Replace *_init() for *_setup()

Hante Meuleman (20):
      brcmfmac: remove obsolete i-scan and clean up related code.
      brcmfmac: use fwil for netdev callbacks.
      brcmfmac: handle exceptions in brcmf_bus_start correct.
      brcmfmac: use wait_event_timeout for 8021x pending count
      brcmfmac: fix pkt_filter sizeof calculation.
      brcmfmac: remove obsolete function brcmf_c_mkiovar
      brcmfmac: return immediately error for out of range key_idx.
      brcmfmac: check bus state to be data before sending data.
      brcmfmac: on halting driver check before release or free.
      brcmfmac: add dedicated USB log level.
      brcmfmac: cleanup of usb firmware download routines
      brcmfmac: usb suspend/resume.
      brcmfmac: fix NULL pointer access in brcmf_fweh_detach()
      brcmfmac: Any error should result in failure of probe.
      brcmfmac: Handle mmc exceptions during init correct.
      brcmfmac: sdio unload fix.
      brcmfmac: avoid usage of func->card->dev in sdio probe.
      brcmfmac: sdio module load fix.
      brcmfmac: limit hex dump on fwil.
      brcmfmac: code cleanup

Harro Haan (1):
      add Marvell 88W8688 support to libertas_sdio

Hauke Mehrtens (1):
      bcma: add more package IDs

Jaume Delcl=F2s (1):
      Wireless: rt2x00: Add device id for Sweex LW323 to rt2800usb.c

Jeff Cook (1):
      Bluetooth: Add support for BCM20702A0 [0b05, 17b5]

Joe Perches (2):
      wireless: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
      brcmsmac: Add __printf verification to logging prototypes

Johan Hedberg (19):
      Bluetooth: Add initial support for LE-only controllers
      Bluetooth: Fix LE MTU reporting for HCIGETDEVINFO
      Bluetooth: Add setting of the LE event mask
      Bluetooth: Read adversiting channel TX power during init sequence
      Bluetooth: Fix HCI command sending when powering on LE-only adapters
      Bluetooth: mgmt: Restrict BR/EDR settings to BR/EDR-only adapters
      Bluetooth: Fix updating host feature bits for LE
      Bluetooth: Add missing feature test macros
      Bluetooth: Make use feature test macros
      Bluetooth: Add flag for LE GAP Peripheral role
      Bluetooth: Disallow LE scanning and connecting in peripheral role
      Bluetooth: Fix setting host feature bits for SSP
      Bluetooth: Fix sending unnecessary HCI_Write_SSP_Mode command
      Bluetooth: Fix unnecessary EIR update during powering on
      Bluetooth: Fix sending unnecessary HCI_LE_Host_Enable
      Bluetooth: Fix parameter order of hci_get_route
      Bluetooth: Use proper invalid value for tx_power
      Bluetooth: Add support for setting LE advertising data
      Bluetooth: Fix updating advertising state flags and data

Johannes Berg (61):
      mac80211: a few formatting fixes
      mac80211: move AP teardown code to correct place
      mac80211: add explicit AP/GO driver operations
      iwlwifi: support host command with copied data
      iwlwifi: clarify NOCOPY/DUP documentation
      Merge remote-tracking branch 'wireless-next/master' into mac80211-next
      mac80211_hwsim: allow using channel contexts
      nl80211: move "can set channel" check
      cfg80211: allow per interface TX power setting
      mac80211: handle TX power per virtual interface
      mac80211_hwsim: print per interface TX power
      mac80211: combine status/drop reporting
      mac80211: use a counter for remain-on-channel cookie
      mac80211: send deauth only with channel context
      iwlwifi: fix flush command
      iwlwifi: don't clear CTL_AMPDU on frame status
      iwlwifi: fix queue flush confusion
      iwlwifi: use list_first_entry
      wireless: add utility function to get P2P attribute
      mac80211: pass P2P powersave parameters to driver
      iwlwifi: remove EEPROM version message by default
      iwlwifi: remove SKU/antenna messages by default
      iwlwifi: remove useless messages
      iwlwifi: fix typo in RX data tracing
      mac80211: use mac_pton
      mac80211: fix race in TKIP MIC test debugfs file
      mac80211: use kstrtoull return value
      mac80211: fix TX error path
      mac80211: add debugfs file for HW queues
      mac80211: remove unused tracepoint
      mac80211: call driver method when restart completes
      mac80211: clarify interface iteration and make it configurable
      mac80211: reassign channel contexts before stations
      iwlwifi: return commands with error on FW error
      mwifiex: don't select lib80211
      lib80211: hide Kconfig symbol
      iwlwifi: disallow MFP with software crypto
      mac80211: use CMAC_PN_LEN
      mac80211: introduce IEEE80211_NUM_TIDS and use it
      mac80211: support radiotap vendor namespace RX data
      mac80211: fix channel context suspend/reconfig handling
      mac80211: fix radiotap vendor area skipping
      mac80211: fix RX chains configuration
      mac80211: rename IEEE80211_STA_DISABLE_11N to HT
      mac80211: disable HT advertising unless AP supports it
      cfg80211: use DS or HT operation IEs to determine BSS channel
      mac80211: fix managed mode channel flags handling
      cfg80211: remove remain-on-channel channel type
      nl80211: add documentation for channel type
      cfg80211: pass a channel definition struct
      nl80211/cfg80211: support VHT channel configuration
      mac80211: convert to channel definition struct
      nl80211/cfg80211: add VHT MCS support
      mac80211: support drivers reporting VHT RX
      mac80211: support VHT rates in TX info
      wireless: add definitions for VHT MCS support
      mac80211_hwsim: advertise VHT support
      mac80211_hwsim: remove printing scan config
      cfg80211: fix some tracing output issues
      iwlegacy: initialize rx_status
      iwlwifi: initialize rx_status

John W. Linville (14):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge tag 'nfc-next-3.8-2' of git://git.kernel.org/.../sameo/nfc-3.0
      brcmfmac: check return from kzalloc in brcmf_fweh_process_event
      brcmfmac: include linux/vmalloc.h from usb.c
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      rtl8723ae: fix build break from "mac80211: support RX_FLAG_MACTIME_EN=
D"
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (1):
      cfg80211: Add TDLS event to allow drivers to request operations

Julia Lawall (1):
      drivers/net/wireless/ath/ath6kl/hif.c: drop if around WARN_ON

Kalle Valo (5):
      ath6kl: move ath6kl_wmi_startscan_cmd()
      ath6kl: refactor wmi scan command
      ath6kl: add support for changing contry code
      ath6kl: fix incorrect use of IEEE80211_NUM_BANDS
      ath6kl: support NL80211_USER_REG_HINT_CELL_BASE events

Larry Finger (3):
      rtlwifi: rtl8723ae: Add new driver
      rtlwifi: Modify files for addition of rtl8723ae
      rtlwifi: rtl8192ce: rtl8192cu: rtl8192se: rtl81723ae: Turn on buildin=
g of the new driver

Luis R. Rodriguez (1):
      carl9170: kill MODULE_VERSION

Marcel Holtmann (3):
      NFC: Remove unused details from pn544.h header file
      NFC: Move pn544.h to linux/platform_data/
      MAINTAINERS: Add reference to pn544.h platform data header

Marco Porsch (3):
      mac80211: move Mesh Capability field definition to ieee80211.h
      mac80211: refactor ieee80211_set_qos_hdr
      mac80211: remove mesh config macros from mesh_plink.c

Marina Makienko (1):
      ath6kl: check usb_register() return value

Mat Martineau (18):
      Bluetooth: Add new l2cap_chan struct members for high speed channels
      Bluetooth: Add L2CAP create channel request handling
      Bluetooth: Remove unnecessary intermediate function
      Bluetooth: Lookup channel structure based on DCID
      Bluetooth: Channel move request handling
      Bluetooth: Add new ERTM receive states for channel move
      Bluetooth: Add move channel confirm handling
      Bluetooth: Add state to hci_chan
      Bluetooth: Move channel response
      Bluetooth: Add logical link confirm
      Bluetooth: Add move confirm response handling
      Bluetooth: Handle physical link completion
      Bluetooth: Flag ACL frames as complete for AMP controllers
      Bluetooth: Do not send data during channel move
      Bluetooth: Configure appropriate timeouts for AMP controllers
      Bluetooth: Ignore BR/EDR packet size constraints when fragmenting for=
 AMP
      Bluetooth: Do not retransmit data during a channel move
      Bluetooth: Start channel move when socket option is changed

Mohammed Shafi Shajakhan (7):
      ath6kl: trivial cleanup on interface type selection
      ath6kl: Remove obselete USB device related checks
      ath6kl: Return error case when ath6kl_usb_alloc_pipe_resources fails
      ath6kl: Rename ATH6KL_HW_FLAG_64BIT_RATES
      ath6kl: Fix inactivity timeout for AR6004
      ath6kl: Fix mapping uplink endpoint for AR6004
      ath6kl: Add a hardware flag for SDIO CRC error workaround

Nishant Sarmukadam (3):
      mwl8k: Unmap the pci DMA address in xmit error path
      mwl8k: Do not expire eapol frames
      mwl8k: Set packet timestamp to 0 when life time expiry is not used

Pandiyarajan Pitchaimuthu (5):
      ath6kl: Make use of return value from ath6kl_diag_read()
      ath6kl: Max clients reached notification
      ath6kl: Blocked client notification
      ath6kl: Array index out of bounds check
      ath6kl: Check for valid endpoint ID in ath6kl_tx_complete()

Piotr Haber (1):
      ssb: fix SPROM offset

Pontus Fuchs (2):
      ar5523: Fix sparse endianness warnings
      ar5523: Don't dereference sta if NULL

Raja Mani (3):
      ath6kl: Avoid null ptr dereference while printing reg domain pair
      ath6kl: Check for valid rate table index
      ath6kl: Check for valid endpoint ID values in ath6kl_control_tx()

Rajkumar Manoharan (4):
      ath9k_hw: Fix wrong peak detector DC offset
      ath9k: Process FATAL interrupts at first
      ath9k: Fix MCI reset in BT cal_req
      ath9k: stomp audio profiles on weak signal strength

Sachin Kamat (1):
      iwlwifi: Remove duplicate inclusion of iwl-trans.h in pcie/drv.c

Samuel Ortiz (3):
      NFC: Copy user space buffer when sending UI frames
      NFC: Stop sending LLCP frames when tx queues are getting too deep
      NFC: Queue a copy of the transmitted LLCP skb

Seth Forshee (24):
      brcmsmac: Introduce AMPDU sessions for assembling AMPDUs
      brcmsmac: Don't weight AMPDU packets in txfifo
      brcmsmac: Add helper function for updating txavail count
      brcmsmac: Remove unimplemented flow control functions
      brcmsmac: Use IEEE 802.11 AC levels for pktq precedence levels
      brcmsmac: Remove internal tx queue
      brcmsmac: Use correct descriptor count when calculating next rx descr=
iptor
      brcmsmac: Reduce number of entries in tx DMA rings
      brcm80211: Allow trace support to be enabled separately from debug
      brcm80211: Convert log message levels to debug levels
      brcmsmac: Add module parameter for setting the debug level
      brcmsmac: Add support for writing debug messages to the trace buffer
      brcmsmac: Use debug macros for general error and debug statements
      brcmsmac: Add brcms_dbg_mac80211() debug macro
      brcmsmac: Add rx and tx debug macros
      brcmsmac: Add brcms_dbg_int() debug macro
      brcmsmac: Add brcms_dbg_dma() debug macro
      brcmsmac: Add brcms_dbg_ht() debug macro
      brcmsmac: Improve tx trace and debug support
      brcmsmac: Add tracepoint for macintstatus
      brcmsmac: Add tracepoint for AMPDU session information
      brcmsmac: Remove some noisy and uninformative debug messages
      brcmsmac: Remove unused wlc_prio2prec_map and _BRCMS_PREC_* constants
      brcmsmac: Remove stray argument from debug macro

Stanislav Yakovlev (2):
      net/wireless: ipw2x00: remove unreachable code
      net/wireless: ipw2200: introduce ipw_set_geo function

Sujith Manoharan (11):
      ath9k_hw: Update AR9485 initvals
      ath9k: Remove unused workaround
      ath9k_hw: Program filter coefficients correctly
      ath9k: Fix BTCOEX debugfs file usage
      mac80211: Add debugfs callbacks for station addition/removal
      ath9k/ath9k_htc: Remove WME macros
      ath9k: Fix the 'xmit' debugfs file
      ath9k: Add a debugfs file to dump queue statistics
      ath9k: Fill remove_sta_debugfs() callback
      ath9k: Fix rate control debugging
      ath9k: Remove 'stations' debugfs file

Syam Sidhardhan (5):
      Bluetooth: trivial: Remove newline before EOF
      Bluetooth: Replace include linux/module.h with linux/export.h
      Bluetooth: Remove unnecessary include export.h
      Bluetooth: mgmt: Use __constant when dealing with constants
      ath5k: Use module_platform_driver macro for ahb.c

Szymon Janc (2):
      Bluetooth: Increase HCI command tx timeout
      Bluetooth: Remove OOB data if device was discovered in band

Thomas Pedersen (8):
      ath6kl: support rssi threshold for sched scan
      ath6kl: support TX error rate notification
      ath6kl: configure wow filters per-vif
      ath6kl: restart concurrent vifs on failed connect
      ath6kl: reconfigure RSN capabilities when restarting AP
      ath6kl: rework scheduled scan
      ath6kl: consolidate WoW pattern length
      mac80211: support RX_FLAG_MACTIME_END

Vasanthakumar Thiagarajan (12):
      ath6kl: Fix potential skb double free in ath6kl_wmi_sync_point()
      ath6kl: Fix potential memory leak in ath6kl_tx_complete()
      ath6kl: Refactor ath6kl_init_hw_start() and ath6kl_init_hw_stop()
      ath6kl: Recover from fw crash
      ath6kl: Add support to detect fw error through heart beat
      ath6kl: Recover from "wmi ctrl ep is full" condition
      ath6kl: Fix bug in scheduling hb_timer
      ath6kl: Remove unnecessary recovery state check in ath6kl_recovery_hb=
_timer()
      ath6kl: Add a bit to ath6kl_dev_state for recovery cleanup state
      ath6kl: Make fw error recovery configurable
      ath6kl: Fix reconnection issue after recovery
      ath6kl: Fix random rx data corruption

Wei Yongjun (4):
      ath6kl: use list_move_tail instead of list_del/list_add_tail
      ar5523: use module_usb_driver to simplify the code
      brcmfmac: remove duplicated include from dhd_dbg.c
      rtlwifi: use eth_zero_addr() to assign zero address

Yogesh Ashok Powar (3):
      mwl8k: defining interface combinations
      mwl8k: recheck if station still has valid rates
      mwl8k: Send BASTREAM firmware commands per vif

Zefir Kurtisi (3):
      ath9k: resolve name collision in DFS detector
      ath9k: fix memory leak in DFS pattern detector
      ath9k: [DFS] add pulse width tolerance for ETSI

 MAINTAINERS                                        |    1 +
 drivers/bluetooth/btusb.c                          |    1 +
 drivers/net/wireless/at76c50x-usb.c                |   85 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |   60 +-
 drivers/net/wireless/ath/ar5523/ar5523_hw.h        |    2 +-
 drivers/net/wireless/ath/ath5k/ahb.c               |   15 +-
 drivers/net/wireless/ath/ath5k/base.c              |   12 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    5 +-
 drivers/net/wireless/ath/ath5k/reset.c             |    6 +-
 drivers/net/wireless/ath/ath6kl/Kconfig            |    9 +
 drivers/net/wireless/ath/ath6kl/Makefile           |    1 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  406 ++--
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    1 -
 drivers/net/wireless/ath/ath6kl/core.c             |   21 +
 drivers/net/wireless/ath/ath6kl/core.h             |   69 +-
 drivers/net/wireless/ath/ath6kl/debug.h            |    1 +
 drivers/net/wireless/ath/ath6kl/hif.c              |   12 +-
 drivers/net/wireless/ath/ath6kl/htc_mbox.c         |   13 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   14 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   92 +-
 drivers/net/wireless/ath/ath6kl/main.c             |   55 +-
 drivers/net/wireless/ath/ath6kl/recovery.c         |  160 ++
 drivers/net/wireless/ath/ath6kl/sdio.c             |   27 +-
 drivers/net/wireless/ath/ath6kl/txrx.c             |   47 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |   32 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |  284 ++-
 drivers/net/wireless/ath/ath6kl/wmi.h              |   78 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   76 +
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   22 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |    1 -
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   46 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |  338 ++-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   34 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    2 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |    1 +
 drivers/net/wireless/ath/ath9k/btcoex.h            |    1 +
 drivers/net/wireless/ath/ath9k/common.h            |    7 -
 drivers/net/wireless/ath/ath9k/debug.c             |  198 +-
 drivers/net/wireless/ath/ath9k/debug.h             |   18 +-
 .../net/wireless/ath/ath9k/dfs_pattern_detector.c  |   12 +-
 .../net/wireless/ath/ath9k/dfs_pattern_detector.h  |    4 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   58 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |    8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |    8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   24 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   28 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    5 -
 drivers/net/wireless/ath/ath9k/hw.h                |    4 -
 drivers/net/wireless/ath/ath9k/init.c              |    6 +-
 drivers/net/wireless/ath/ath9k/link.c              |    5 +-
 drivers/net/wireless/ath/ath9k/main.c              |   78 +-
 drivers/net/wireless/ath/ath9k/mci.c               |   39 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   12 -
 drivers/net/wireless/ath/ath9k/rc.c                |   53 +-
 drivers/net/wireless/ath/ath9k/rc.h                |   16 +
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   12 +-
 drivers/net/wireless/ath/carl9170/fw.c             |    5 -
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/b43legacy/xmit.c              |    2 +-
 drivers/net/wireless/brcm80211/Kconfig             |   15 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   43 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  140 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  186 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |   72 -
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  452 +---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |    6 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   10 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  509 ++---
 .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |    7 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  252 ++-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |  509 +++++
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |  207 ++
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |   26 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  278 +--
 drivers/net/wireless/brcm80211/brcmfmac/usb.h      |   18 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 1010 ++-------
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |  120 +-
 drivers/net/wireless/brcm80211/brcmsmac/Makefile   |    3 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |  723 +++---
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.h    |   29 +-
 drivers/net/wireless/brcm80211/brcmsmac/antsel.c   |    4 +-
 .../brcm80211/brcmsmac/brcms_trace_events.h        |  175 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |   10 +-
 drivers/net/wireless/brcm80211/brcmsmac/debug.c    |   44 +
 drivers/net/wireless/brcm80211/brcmsmac/debug.h    |   52 +
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |  343 ++-
 drivers/net/wireless/brcm80211/brcmsmac/dma.h      |   11 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |  123 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     | 1195 +++-------
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |   48 +-
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |   37 -
 drivers/net/wireless/brcm80211/brcmsmac/stf.c      |    8 +-
 drivers/net/wireless/brcm80211/brcmsmac/types.h    |    3 +-
 drivers/net/wireless/brcm80211/include/defs.h      |   11 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |    5 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   40 +-
 drivers/net/wireless/ipw2x00/libipw.h              |    2 +-
 drivers/net/wireless/ipw2x00/libipw_geo.c          |    3 +-
 drivers/net/wireless/iwlegacy/3945.c               |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    4 +-
 drivers/net/wireless/iwlegacy/common.h             |    5 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    9 -
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    4 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |    7 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |    2 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |    1 -
 drivers/net/wireless/iwlwifi/dvm/lib.c             |   37 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   16 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   20 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |    6 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |    9 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   27 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    1 -
 drivers/net/wireless/iwlwifi/pcie/internal.h       |  117 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  396 +++-
 drivers/net/wireless/iwlwifi/pcie/trans.c          | 1047 +--------
 drivers/net/wireless/iwlwifi/pcie/tx.c             | 1263 ++++++++---
 drivers/net/wireless/libertas/cfg.c                |   24 +-
 drivers/net/wireless/libertas/if_sdio.c            |   39 +-
 drivers/net/wireless/mac80211_hwsim.c              |  580 ++++-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    8 +-
 drivers/net/wireless/mwifiex/Kconfig               |    1 -
 drivers/net/wireless/mwifiex/cfg80211.c            |   54 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    3 +
 drivers/net/wireless/mwifiex/debugfs.c             |   10 +-
 drivers/net/wireless/mwifiex/init.c                |   20 +-
 drivers/net/wireless/mwifiex/join.c                |    6 +-
 drivers/net/wireless/mwifiex/main.c                |   86 +-
 drivers/net/wireless/mwifiex/main.h                |    6 +-
 drivers/net/wireless/mwifiex/sdio.c                |   39 +-
 drivers/net/wireless/mwifiex/sdio.h                |    1 +
 drivers/net/wireless/mwifiex/sta_event.c           |   10 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    9 +-
 drivers/net/wireless/mwifiex/txrx.c                |   28 +-
 drivers/net/wireless/mwifiex/uap_event.c           |    7 +
 drivers/net/wireless/mwifiex/usb.c                 |    2 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   12 +-
 drivers/net/wireless/mwifiex/wmm.h                 |    2 +
 drivers/net/wireless/mwl8k.c                       |   57 +-
 drivers/net/wireless/orinoco/cfg.c                 |   11 +-
 drivers/net/wireless/p54/txrx.c                    |    6 +-
 drivers/net/wireless/rndis_wlan.c                  |   12 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   19 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    6 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |    2 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |    2 +-
 drivers/net/wireless/rtlwifi/Kconfig               |   11 +
 drivers/net/wireless/rtlwifi/Makefile              |    4 +-
 drivers/net/wireless/rtlwifi/base.c                |   24 +
 drivers/net/wireless/rtlwifi/base.h                |    2 +
 drivers/net/wireless/rtlwifi/cam.c                 |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |    5 +-
 drivers/net/wireless/rtlwifi/debug.h               |    2 +
 drivers/net/wireless/rtlwifi/pci.c                 |   20 +-
 drivers/net/wireless/rtlwifi/pci.h                 |    2 +
 drivers/net/wireless/rtlwifi/rc.c                  |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |   22 +
 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h       |   41 +
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |  163 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  920 ++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |  149 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  745 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |  101 +
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |  542 +++++
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h    |  160 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   | 1786 +++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |  151 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 2380 ++++++++++++++++=
++++
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h        |   73 +
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |  151 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/led.h       |   39 +
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       | 2044 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |  224 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |  109 +
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |  322 +++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c |  129 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h |   98 +
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       | 2097 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c        |  505 +++++
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |   43 +
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |  387 ++++
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h        |   37 +
 drivers/net/wireless/rtlwifi/rtl8723ae/table.c     |  738 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/table.h     |   50 +
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  670 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |  725 ++++++
 drivers/net/wireless/rtlwifi/stats.c               |  268 +++
 drivers/net/wireless/rtlwifi/stats.h               |   46 +
 drivers/net/wireless/rtlwifi/wifi.h                |  108 +-
 drivers/net/wireless/ti/wl1251/rx.c                |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   11 +-
 drivers/nfc/pn544/i2c.c                            |    2 +-
 include/linux/bcma/bcma.h                          |    5 +
 include/linux/ieee80211.h                          |   72 +
 include/linux/nfc/pn544.h                          |  104 -
 include/linux/platform_data/pn544.h                |   44 +
 include/linux/ssb/ssb_regs.h                       |    2 +-
 include/net/bluetooth/amp.h                        |    4 +
 include/net/bluetooth/hci.h                        |   29 +-
 include/net/bluetooth/hci_core.h                   |   48 +-
 include/net/bluetooth/l2cap.h                      |   38 +-
 include/net/cfg80211.h                             |  223 +-
 include/net/mac80211.h                             |  158 +-
 include/net/nfc/hci.h                              |    3 +
 include/uapi/linux/nl80211.h                       |  113 +-
 net/bluetooth/Kconfig                              |    1 -
 net/bluetooth/a2mp.c                               |    4 +-
 net/bluetooth/amp.c                                |   97 +
 net/bluetooth/bnep/netdev.c                        |    1 -
 net/bluetooth/cmtp/capi.c                          |    2 +-
 net/bluetooth/cmtp/sock.c                          |    2 +-
 net/bluetooth/hci_conn.c                           |    6 +
 net/bluetooth/hci_core.c                           |  163 +-
 net/bluetooth/hci_event.c                          |  351 ++-
 net/bluetooth/l2cap_core.c                         | 1010 ++++++++-
 net/bluetooth/l2cap_sock.c                         |    5 +
 net/bluetooth/mgmt.c                               |  100 +-
 net/mac80211/aes_cmac.c                            |    1 +
 net/mac80211/agg-rx.c                              |    2 +-
 net/mac80211/agg-tx.c                              |   12 +-
 net/mac80211/cfg.c                                 |  258 ++-
 net/mac80211/chan.c                                |  130 +-
 net/mac80211/debugfs_key.c                         |    6 +-
 net/mac80211/debugfs_netdev.c                      |   68 +-
 net/mac80211/debugfs_sta.c                         |   19 +-
 net/mac80211/driver-ops.h                          |   75 +-
 net/mac80211/ht.c                                  |    4 +-
 net/mac80211/ibss.c                                |   75 +-
 net/mac80211/ieee80211_i.h                         |   50 +-
 net/mac80211/iface.c                               |   60 +-
 net/mac80211/key.c                                 |   15 +-
 net/mac80211/key.h                                 |    8 +-
 net/mac80211/main.c                                |   50 +-
 net/mac80211/mesh.c                                |   36 +-
 net/mac80211/mesh.h                                |   14 -
 net/mac80211/mesh_plink.c                          |   47 +-
 net/mac80211/mesh_sync.c                           |   46 +-
 net/mac80211/mlme.c                                |  198 +-
 net/mac80211/offchannel.c                          |   13 +-
 net/mac80211/pm.c                                  |   48 +-
 net/mac80211/rate.c                                |    5 +-
 net/mac80211/rate.h                                |    2 +-
 net/mac80211/rx.c                                  |  169 +-
 net/mac80211/scan.c                                |    9 +-
 net/mac80211/sta_info.c                            |   12 +-
 net/mac80211/sta_info.h                            |   27 +-
 net/mac80211/status.c                              |  145 +-
 net/mac80211/trace.h                               |  116 +-
 net/mac80211/tx.c                                  |   21 +-
 net/mac80211/util.c                                |  194 +-
 net/mac80211/wme.c                                 |   40 +-
 net/nfc/hci/command.c                              |    4 +-
 net/nfc/hci/core.c                                 |   25 +-
 net/nfc/llcp/commands.c                            |   32 +-
 net/nfc/llcp/llcp.c                                |   17 +-
 net/wireless/Kconfig                               |    5 +-
 net/wireless/ap.c                                  |    1 +
 net/wireless/chan.c                                |  280 ++-
 net/wireless/core.c                                |    7 +
 net/wireless/core.h                                |   30 +-
 net/wireless/ibss.c                                |   27 +-
 net/wireless/mesh.c                                |   49 +-
 net/wireless/mlme.c                                |   36 +-
 net/wireless/nl80211.c                             |  590 +++--
 net/wireless/nl80211.h                             |    8 +-
 net/wireless/rdev-ops.h                            |   53 +-
 net/wireless/scan.c                                |   45 +-
 net/wireless/trace.h                               |  338 +--
 net/wireless/util.c                                |  174 +-
 net/wireless/wext-compat.c                         |   32 +-
 net/wireless/wext-sme.c                            |   11 +-
 289 files changed, 27506 insertions(+), 8374 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath6kl/recovery.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/fweh.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/fweh.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/debug.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/debug.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
 create mode 100644 drivers/net/wireless/rtlwifi/stats.c
 create mode 100644 drivers/net/wireless/rtlwifi/stats.h
 delete mode 100644 include/linux/nfc/pn544.h
 create mode 100644 include/linux/platform_data/pn544.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--wRRV7LY7NUeQGEoC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQtmTHAAoJEJctW/TcYTgGGIoP/A4K+hKaT9yV23ljuVRnLO0V
vhQimUJhm+sSh8t0u2fZ/CsWhcXgixtsic1HvrjKkfrtJ/3u6iHmoXdeIeDBqG2t
NrwCLvBJb8hAJhcdE7dIN22ANetB7KDJV9PucIchIkVzjGExNnm0QkTcMq6k7TfZ
De1rjOnMa6yed3rHJVGBC+ibZ3lm4QC1M39JllmMuLpIo3qR8Lr4+sR7ODwEwoo/
yvErxEttK8e6OvRKfIZO7+MpkVGiccb0tIK+h6BBRHFeC1JIk102ozBHTaj9JFje
UB83832vo85WJ7GTfNUXSMT0g27ETB4xc2kWDmb0bsvy4RKQrNdD56NIYGCZpHpj
+DcwOCF4BvvEywQxjCr+tWCz9aCsy6ys86IeARwtW7pz3n01T4Mxf9zVmuf5uKmn
CNXVMA6n3AaRf0LULRBXz6CYGcZ/1iiRji5g9M5CEbmJjIXMvJbl/CFa0TJCI5qU
ltxxbsKn7ytCK2hS+HNL3AdnVhmARgl6YKPYbTkZP85mzJ3rhV76kTcgDznraQxy
Kfl6vY1pPQ+teULm4XWQkyOk4IHJ3poqUCft4b54ndJljlejCM01RJh6fecFjIav
E8VoBkpwJrWGv3aVnkMj41dDHdQVm8Izo/ZlUm9pwc6sw3VDSsSR0HjXVKGpwcf0
RZ4RsGbquwZCbSnf2ecV
=trJk
-----END PGP SIGNATURE-----

--wRRV7LY7NUeQGEoC--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
