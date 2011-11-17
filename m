From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2011-11-17
Date: Thu, 17 Nov 2011 13:29:39 -0500
Message-ID: <20111117182939.GD32622@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CE+1k2dSO48ffgeK"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit e11c259f745889b55bc5596ca78271f2f5cf08d2

Dave,

Here is a huge pull request for wireless bits intended for 3.3.  I
reckon that the extended release cycle for 3.1 led to a backlog of new
work that appeared during the merge window for 3.2?

At any rate...there is a big Bluetooth pull with a lot of code
refactoring; a lot of brcm80211 bits including cleanups, refactoring,
and some new hardware support; the normal set of iwlwifi updates plus
some refactoring; an unusual large flurry of mac80211 and cfg80211
updates from Johannes (including the new wireless TX status socket
option); some updates to the new NFC subsystem; and the usual collection
of other driver and mac80211 updates.  This also includes a pull of the
wireless.git tree to resolve some build issues.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 8d26784cf0d04c1238e906efdd5de76439cb0a1e:

  ipv6: Use pr_warn() in ip6_fib.c (2011-11-17 03:18:28 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Alexander Simon (1):
      mac80211: Add HT helper functions

Alwin Beukers (4):
      brcm80211: cleanup defines in main.c
      brcm80211: removed duplicate defines
      brcm80211: smac: don't modify sta parameters when adding sta
      brcm80211: smac: combine promiscuous mode functionality

Amitkumar Karwar (3):
      mwifiex: enable SDIO multiport aggregation
      mwifiex: remove unnecessary free_priv handler
      mwifiex: release bss structure returned by cfg80211_inform_bss()

Andre Guedes (3):
      Bluetooth: Create hci_do_inquiry()
      Bluetooth: Create hci_cancel_inquiry()
      Bluetooth: Periodic Inquiry and Discovery

Andrei Emeltchenko (33):
      Bluetooth: EFS: l2cap extended feature mask update
      Bluetooth: EFS: add enable_hs kernel param
      Bluetooth: convert flushable variable to flag in l2cap chan
      Bluetooth: convert force_reliable variable to flag in l2cap chan
      Bluetooth: convert force_active variable to flag in l2cap chan
      Bluetooth: convert role_switch variable to flag in l2cap chan
      Bluetooth: clean up spaces in L2CAP header
      Bluetooth: EWS: extended window size option support
      Bluetooth: EWS: adds ext control field bit mask
      Bluetooth: EWS: rewrite handling Supervisory (S) bits
      Bluetooth: EWS: rewrite handling SAR bits
      Bluetooth: EWS: rewrite reqseq calculation
      Bluetooth: EWS: rewrite L2CAP ERTM txseq calculation
      Bluetooth: EWS: rewrite check frame type function
      Bluetooth: EWS: rewrite handling FINAL (F) bit
      Bluetooth: EWS: rewrite handling POLL (P) bit
      Bluetooth: EWS: recalculate L2CAP header size
      Bluetooth: EWS: define L2CAP header sizes
      Bluetooth: EFS: definitions and headers
      Bluetooth: EFS: assign default values in chan add
      Bluetooth: EFS: add efs option in L2CAP conf req
      Bluetooth: AMP: read local amp info HCI command
      Bluetooth: EWS: handling different Control fields
      Bluetooth: EWS: support extended seq numbers
      Bluetooth: EWS: remove magic numbers in l2cap
      Bluetooth: EWS: fix max_pdu calculation
      Bluetooth: EFS: parse L2CAP config request
      Bluetooth: EFS: implement L2CAP config pending state
      Bluetooth: remove magic offset and size
      Bluetooth: correct debug output
      Bluetooth: Initialize tx_win_max for fixed channel
      Bluetooth: Define HCI reasons instead of magic number
      Bluetooth: EFS: parse L2CAP config response

Andrzej Kaczmarek (1):
      Bluetooth: Use miliseconds for L2CAP channel timeouts

Arek Lichwa (1):
      Bluetooth: Revert: Fix L2CAP connection establishment

Arend van Spriel (21):
      brcm80211: smac: eliminate a null pointer dereference in dma.c
      brcm80211: smac: drop "40MHz intolerant" flag from HT capability info
      brcm80211: smac: remove obsolete srom variables from n-phy
      brcm80211: smac: avoid sprom endianess conversions for crc8 check
      brcm80211: smac: some local function made static in main.c
      brcm80211: smac: remove phy api bypass in rate.h
      brcm80211: util: move brcmu_pktfrombuf() function to brcmfmac
      brcm80211: util: remove function brcmu_format_hex() from brcmutil
      brcm80211: fmac: use sk_buff list for handling frames in receive path
      brcm80211: smac: rename buffer endianess conversion functions
      brcm80211: smac: use sk_buff list for handling frames in receive path
      brcm80211: smac: change buffer endianess convert function interface
      brcm80211: smac: fix endianess issue for OTP memory access
      brcm80211: smac: remove code under unused macro definitions
      brcm80211: smac: replace own access category definitions with mac8021=
1 enum
      brcm80211: smac: remove duplicate definition of D11_PHY_HDR_LEN
      brcm80211: smac: remove usage of brcmu_pkttotlen
      brcm80211: util: use sk_buff_head in precedence queue functions
      brcm80211: util: move brcmu_pkttotlen() function to brcmfmac
      brcm80211: util: remove pointer traversal from brcmu_pkt_buf_free_skb
      brcm80211: fmac: add function to free the glom skb queue

Arik Nemtsov (6):
      mac80211: support adding IV-room in the skb for CCMP keys
      mac80211: init rate-control for TDLS sta when supp-rates are known
      mac80211: make sure hw_key exists before checking its flags
      nl80211: Add probe response offload attribute
      nl80211: Pass probe response data to drivers
      mac80211: Save probe response data for bss

Ben Greear (1):
      ath9k: Improve debugfs printout for stations.

Christian Lamparter (1):
      mac80211: handle HT PHY BSS membership selector value correctly

Dan Carpenter (6):
      ath9k_hw: min_t() casts u32 to int
      rndis_wlan: add range check in del_key()
      iwmc3200wifi: add some more range checks
      mwifiex: remove unneeded kfree(NULL);
      mwifiex: remove an unneeded NULL check
      mwifiex: prevent corruption instead of just warning

Daniel Kuehn (1):
      ath9k: set ATH9K_PCI to y by default

David Herrmann (13):
      Bluetooth: hidp: Stop I/O on shutdown
      Bluetooth: Fix hci core device initialization
      Bluetooth: Rename sysfs un/register to add/del
      Bluetooth: Forward errors from hci_register_dev
      Bluetooth: Return proper error codes on rfcomm tty init
      Bluetooth: Replace rfcomm tty tasklet by workqueue
      Bluetooth: Ignore hci_unregister_dev return value
      Bluetooth: Make hci_unregister_dev return void
      Bluetooth: ath3k: Use GFP_KERNEL instead of GFP_ATOMIC
      Bluetooth: bcm203x: Fix race condition on disconnect
      Bluetooth: bcm203x: Use GFP_KERNEL in workqueue
      Bluetooth: bfusb: Fix error path on firmware load
      Bluetooth: hidp: Fix module reference cleanup

David Kilroy (1):
      orinoco: release BSS structures returned by cfg80211_inform_bss()

Dmitry Tarnyagin (1):
      cfg80211: merge in beacon ies of hidden bss.

Don Fry (8):
      iwlagn: remove unnecessary type for tracing operations
      iwlagn: simplify iwl_alloc_all
      iwlagn: move ucode_write_complete from priv to trans structure
      iwlagn: remove knowledge of ucode image location from upper layers
      iwlagn: push knowledge of ucode image lower down
      iwlagn: move ucode files out of the iwl_priv structure
      iwlagn: Remove dependence of iwl_priv from eeprom routines.
      iwlagn: move nvm_device_type from iwl_priv to iwl_trans

Eliad Peller (4):
      mac80211: use min rate as basic rate for buggy APs
      mac80211: call set_wmm_default only for valid vifs
      mac80211: set BSS_CHANGED_IDLE on vif reconfig
      mac80211: set carrier_on for ibss vifs only while joined

Emmanuel Grumbach (3):
      iwlwifi: fix unused label in iwl_send_cmd_sync
      iwlwifi: remove the use of the QOS debug flag
      iwlwifi: add debug information on queue stop / wake

Eyal Shapira (2):
      wl12xx: fix wl12xx_scan_sched_scan_ssid_list() check that all given s=
sids are in filters
      mac80211: add recalc PS in ieee80211_reconfig()

Franky Lin (28):
      brcm80211: fmac: allow wd timer to be disabled when bus down
      brcm80211: fmac: use brcmf_del_if for all net devices
      brcm80211: fmac: use brcmf_add_if for all net devices
      brcm80211: fmac: store brcmf_if in net device private data
      brcm80211: fmac: remove state from brcmf_if in fullmac
      brcm80211: fmac: remove unnecessary 4329 chip specific code
      brcm80211: fmac: move chip recognition function to sdio_chip.c
      brcm80211: fmac: move bus core prep code to sdio_chip.c
      brcm80211: fmac: abstract chip buscore setup function
      brcm80211: fmac: move core disable function to sdio_chip.c
      brcm80211: fmac: disable dongle arm core in bus core setup function
      brcm80211: fmac: move dongle gpio reset code to chip attach function
      brcm80211: fmac: remove duplicate regiter set in chip attach path
      brcm80211: fmac: chip attach code flow clean up
      brcm80211: fmac: abstract chip iscoreup function
      brcm80211: fmac: abstract chip core revision function
      brcm80211: fmac: move chip reset core function to sdio_chip.c
      brcm80211: fmac: move chip detach function to sdio_chip.c
      brcm80211: fmac: move chip drive strength related code to sdio_chip.c
      brcm80211: fmac: replace private SB macros with ssb_regs version
      brcm80211: fmac: optimize chip core info management
      brcm80211: fmac: add iscoreup function for bcm4330 chip
      brcm80211: fmac: add corerev function for bcm4330 chip
      brcm80211: fmac: add coredisable function for bcm4330 chip
      brcm80211: fmac: add resetcore function for bcm4330 chip
      brcm80211: fmac: remove id retrieve code
      brcm80211: fmac: remove PCMCIA core related code
      brcm80211: fmac: release bss struct returned from cfg80211_inform_bss

Gustavo F. Padovan (16):
      Bluetooth: use list_for_each_entry() in hidp
      Bluetooth: prioritize the interrupt channel in hidp
      Bluetooth: Trasmit interrupt channel messages first
      Bluetooth: Fix input device registration
      Bluetooth: Remove wrong error check
      Bluetooth: Uses test_and_clear_bit() when possible
      Bluetooth: Delay session allocation in hidp
      Bluetooth: Rename hidp_find_connection()
      Bluetooth: Fix permission of enable_le param
      Bluetooth: return proper error if sock_queue_rcv_skb() fails
      Bluetooth: Add missing cmd_status() in mgmt
      Bluetooth: Use list_for_each_entry() in mgmt
      Bluetooth: Fix mgmt interaction with userspace
      Bluetooth: Fix missing cmd_status in mgmt
      Bluetooth: small styles clean ups to l2cap_core.c
      Bluetooth: Fix hidp_get_connection()

Helmut Schaa (2):
      ath: Fix NULL ptr dereference in ath_reg_apply_world_flags
      mac80211: Also report the STA's TDLS flag via nl80211

Ilan Elias (3):
      NFC: Update names and structs to NCI spec 1.0 d18
      NFC: Removal of unused operations for NCI spec 1.0 d18
      NFC: Check if NCI data flow control is used

Janusz.Dziedzic-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org (1):
      mac80211: uAPSD - fix IEEE80211_FCTL_MOREDATA bit setting

Javier Cardona (2):
      mac80211: Avoid filling up mesh preq queue with redundant requests
      mac80211: simplify mesh frame queue mapping and QoS

Jesper Juhl (1):
      net, wireless, mwifiex: Fix mem leak in mwifiex_update_curr_bss_param=
s()

Johan Hedberg (17):
      Bluetooth: Fix command complete/status for discovery commands
      Bluetooth: Set HCI_MGMT flag only in read_controller_info
      Bluetooth: Fix mgmt response when adapter goes down or is removed
      Bluetooth: Clean up logic in hci_cc_write_scan_enable
      Bluetooth: Add timeout field to mgmt_set_discoverable
      Bluetooth: Fix mgmt response when HCI_Write_Scan_Enable fails
      Bluetooth: Convert power off mechanism to use delayed_work
      Bluetooth: Remove redundant code from mgmt_block & mgmt_unblock
      Bluetooth: Fix response for mgmt_start_discovery when powered off
      Bluetooth: Update link key mgmt APIs to match latest spec.
      Bluetooth: Add address type fields to mgmt messages that need them
      Bluetooth: Pass full hci_dev struct to mgmt callbacks
      Bluetooth: Move pending management command list into struct hci_dev
      Bluetooth: Add missing hci_dev locking when calling mgmt functions
      Bluetooth: Fix cancel_delayed_work_sync usage with locks
      Bluetooth: Fix consistency with u16 integer type in mgmt pending_cmd
      Bluetooth: Remove redundant hci_dev comparisons in mgmt lookups

Johannes Berg (38):
      nl80211: fix HT capability attribute validation
      cfg80211: allow setting TXQ parameters only in AP mode
      cfg80211: fix cmp_ies
      cfg80211: fix missing kernel-doc
      iwlagn: update wowlan API
      iwlagn: use 6 Mbps rate for no-CCK scans
      mac80211: fix confusing parentheses
      mac80211: exit cooked monitor RX early if there are none
      nl80211: clean up genlmsg_end uses
      cfg80211: annotate cfg80211_inform_bss
      mac80211: preserve EOSP in QoS header
      net: add wireless TX status socket option
      mac80211: verify virtual interfaces in driver API
      mac80211: add helper to free TX skb
      mac80211: add support for control port protocol in AP mode
      nl80211: allow subscribing to unexpected class3 frames
      mac80211: support spurious class3 event
      nl80211: advertise device AP SME
      nl80211: add API to probe a client
      mac80211: support client probe
      cfg80211: allow registering to beacons
      mac80211: report OBSS beacons
      cfg80211: add event for unexpected 4addr frames
      mac80211: send unexpected 4addr event
      cfg80211/mac80211: allow management TX to not wait for ACK
      nl80211: advertise socket TX status capability
      mac80211: implement wifi TX status
      mac80211: simplify scan state machine
      mac80211/cfg80211: report monitor channel in wireless extensions
      wireless: move ieee80211chan2mhz macro
      nl80211: fix compiler warning
      iwlagn: add P2P NoA to probe responses
      iwlagn: fix NULL ptr deref when reprogramming sta w/o LQ
      iwlagn: use per-vif AC parameters
      iwlagn: explicitly program P2P QoS parameters
      iwlagn: convert remain-on-channel duration to TU
      iwlagn: don't always split remain-on-channel
      mac80211: fix warning in ieee80211_probe_client

John W. Linville (7):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-n=
ext
      wireless: cleanup brcm80211 bits in drivers/net/wireless/Makefile
      brcmsmac: fix warning in _initvars_srom_pci
      libertas: release bss references and avoid warning from cfg80211_info=
rm_bss
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (4):
      mac80211_hwsim: Claim support for TDLS
      ath9k: Advertise support for TDLS
      ieee80211: Define cipher suite selector for WPI-SMS4
      nl80211: Increase maximum NL80211_ATTR_KEY_SEQ length to 16

Julia Lawall (2):
      net/mac80211/debugfs.c: use kstrtoul, etc
      net/rfkill/core.c: use kstrtoul, etc

Jussi Kivilinna (1):
      rndis_wlan: release BSS structures returned by cfg80211_inform_bss()

Larry Finger (1):
      rtl8192cu: Add new device IDs

Luiz Augusto von Dentz (7):
      Bluetooth: replace list_for_each with list_for_each_entry whenever po=
ssible
      Bluetooth: set skbuffer priority based on L2CAP socket priority
      Bluetooth: make use sk_priority to priritize RFCOMM packets
      Bluetooth: prioritizing data over HCI
      Bluetooth: handle priority change within quote
      Bluetooth: recalculate priorities when channels are starving
      Bluetooth: use buffer priority to mark URB_ISO_ASAP flag

Mat Martineau (9):
      Bluetooth: Add BT_CHANNEL_POLICY socket option
      Bluetooth: Change scope of the enable_hs module parameter
      Bluetooth: Add channel policy to getsockopt/setsockopt
      Bluetooth: Add AMP-related data and structures for channel signals
      Bluetooth: Add signal handlers for channel creation
      Bluetooth: Add definitions for L2CAP fixed channels
      Bluetooth: Use symbolic values for the fixed channel map
      Bluetooth: Add signal handlers for channel moves
      Bluetooth: Guarantee BR-EDR device will be registered as hci0

Patrick Kelle (1):
      minstrel: Remove unused function parameter in calc_rate_durations()

Paul Bolle (2):
      Bluetooth: btusb: also be quiet when suspending
      Bluetooth: btusb: hide more usb_submit_urb errors

Paul Fertser (1):
      Bluetooth: ath3k: output firmware filename when request_firmware fail=
ed

Peter Hurley (1):
      Bluetooth: hidp: safely acquire hci connection

Rafa=C5=82 Mi=C5=82ecki (2):
      b43: fill ctl1 word on all newer PHYs, fix PHY errors
      b43: HT-PHY: report signal to mac80211

Rajkumar Manoharan (7):
      ath9k_hw: Update CCK spur mitigation for AR9462
      ath9k: Add btcoex profile management support for AR9462
      ath9k_hw: Updated AR9462 initval table to improve rx performance
      ath9k_hw: Read and configure quick drop for AR9003
      ath9k_hw: Read and configure xpa timing field
      ath9k_hw: Fix channel list of CalFreqPeir for AR938x
      ath9k_hw: Fix tx power settings for AR9003

Roland Vossen (14):
      brcm80211: smac: removed support for SROM rev < 8
      brcm80211: fmac: annotated little endian struct with _le
      brmc80211: fmac: reworked next_bss()
      brcm80211: fmac: changed two scan related structures
      brcm80211: smac: indicate severe problems to Mac80211
      brcm80211: smac: removed MPC related code
      brcm80211: smac: removed MPC related variables
      brcm80211: smac: removed down-on-watchdog MPC functionality
      brcm80211: smac: removed down-on-rf-kill functionality
      brcm80211: smac: bugfix for tx mute in brcms_b_init()
      brcm80211: smac: fixed inconsistency in transmit mute
      brcm80211: smac: modified Mac80211 callback interface
      brcm80211: smac: mute transmit on ops_start
      brcm80211: smac: changed check to confirm STA only support

Stanislav Yakovlev (1):
      ipw2x00: remove unused function libipw_ratelimit_debug.

Stanislaw Gruszka (3):
      mac80211: remove uneeded scan_chan variable
      mac80211: remove useless brackets in ieee80211_cfg_on_oper_channel
      mac80211: simplify ieee80211_work_work

Szymon Janc (3):
      Bluetooth: rfcomm: Fix sleep in invalid context in rfcomm_security_cfm
      Bluetooth: Increase HCI reset timeout in hci_dev_do_close
      Bluetooth: Add debug print to l2cap_chan_create

Thomas Pedersen (6):
      mac80211: comment allocation of mesh frames
      mac80211: add HT IEs to mesh frames
      mac80211: set HT capabilities for mesh peer
      mac80211: allow frame aggregation for mesh
      mac80211: QoS multicast frames have No Ack policy
      mac80211: check if frame is really part of this BA

Todd Previte (1):
      iwlwifi: Suppress noisy syslog messages when RF_KILL switch engaged

Venkataraman, Meenakshi (1):
      iwlwifi: fix rate-scaling algorithm for BT combo devices

Wen-chien Jesse Sung (1):
      Bluetooth: Add support for Broadcom BCM20702A0

Wey-Yi Guy (11):
      iwlwifi: HW rev for 105 and 135 series
      iwlwifi: two more SKUs for 6x05 series
      iwlagn: check for SMPS mode
      iwlwifi: remove un-supported SKUs
      iwlwifi: move all mac80211 related functions to one place
      iwlwifi: move more mac80211 callback function
      iwlwifi: move hw_scan into _mac80211 file
      iwlwifi: move station functions to mac80211
      iwlwifi: Move the core suspend function to iwl-agn-lib
      iwlwifi: set "echo" host command length
      iwlwifi: check status before send command

Yogesh Ashok Powar (5):
      mwifiex: fix ht_cap_info in ibss beacons
      mwifiex: use existing helper function mwifiex_fill_cap_info
      mwifiex: change return types to void
      mwifiex: fix coding style
      mwifiex: fix 'Smatch' warnings

 arch/alpha/include/asm/socket.h                    |    3 +
 arch/arm/include/asm/socket.h                      |    3 +
 arch/avr32/include/asm/socket.h                    |    3 +
 arch/cris/include/asm/socket.h                     |    3 +
 arch/frv/include/asm/socket.h                      |    3 +
 arch/h8300/include/asm/socket.h                    |    3 +
 arch/ia64/include/asm/socket.h                     |    3 +
 arch/m32r/include/asm/socket.h                     |    3 +
 arch/m68k/include/asm/socket.h                     |    3 +
 arch/mips/include/asm/socket.h                     |    3 +
 arch/mn10300/include/asm/socket.h                  |    3 +
 arch/parisc/include/asm/socket.h                   |    3 +
 arch/powerpc/include/asm/socket.h                  |    3 +
 arch/s390/include/asm/socket.h                     |    3 +
 arch/sparc/include/asm/socket.h                    |    3 +
 arch/xtensa/include/asm/socket.h                   |    3 +
 drivers/bluetooth/ath3k.c                          |   15 +-
 drivers/bluetooth/bfusb.c                          |    4 +-
 drivers/bluetooth/bluecard_cs.c                    |    4 +-
 drivers/bluetooth/bt3c_cs.c                        |    4 +-
 drivers/bluetooth/btuart_cs.c                      |    4 +-
 drivers/bluetooth/btusb.c                          |   19 +-
 drivers/bluetooth/dtl1_cs.c                        |    4 +-
 drivers/bluetooth/hci_vhci.c                       |    5 +-
 drivers/net/wireless/Makefile                      |    6 +-
 drivers/net/wireless/ath/ath.h                     |    1 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    3 +-
 drivers/net/wireless/ath/ath6kl/init.c             |    3 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    1 +
 drivers/net/wireless/ath/ath9k/Makefile            |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  140 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    2 +
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |   26 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 +
 drivers/net/wireless/ath/ath9k/debug.c             |   13 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    3 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    7 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    4 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   11 +
 drivers/net/wireless/ath/ath9k/init.c              |    3 +
 drivers/net/wireless/ath/ath9k/main.c              |   12 +-
 drivers/net/wireless/ath/ath9k/mci.c               |  254 +++
 drivers/net/wireless/ath/ath9k/mci.h               |  118 ++
 drivers/net/wireless/ath/ath9k/xmit.c              |    5 +-
 drivers/net/wireless/ath/regd.c                    |    2 +
 drivers/net/wireless/b43/xmit.c                    |   15 +-
 drivers/net/wireless/b43/xmit.h                    |   16 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmchip.h  |    7 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   18 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |    5 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  301 ++---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  709 +-------
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |  622 +++++++
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |  136 ++
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   41 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |    9 -
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |   76 -
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    6 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |  118 --
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |   44 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.h      |    3 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |  121 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |    2 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  687 +++-----
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |   19 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |   10 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  |    5 -
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   38 +-
 drivers/net/wireless/brcm80211/brcmsmac/pmu.c      |    1 +
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |   38 +-
 drivers/net/wireless/brcm80211/brcmsmac/rate.h     |    5 +-
 drivers/net/wireless/brcm80211/brcmsmac/srom.c     |  469 +-----
 drivers/net/wireless/brcm80211/brcmsmac/srom.h     |    5 -
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |  218 +--
 .../net/wireless/brcm80211/include/brcmu_utils.h   |   30 +-
 drivers/net/wireless/brcm80211/include/defs.h      |    1 -
 drivers/net/wireless/brcm80211/include/soc.h       |   12 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    8 +
 drivers/net/wireless/ipw2x00/libipw.h              |    8 -
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   20 -
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   10 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  358 ++++
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   49 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |   78 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |  154 ++-
 drivers/net/wireless/iwlwifi/iwl-agn.c             | 1781 ++--------------=
----
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   31 +-
 drivers/net/wireless/iwlwifi/iwl-cfg.h             |    6 -
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   27 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  307 +----
 drivers/net/wireless/iwlwifi/iwl-core.h            |   14 -
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   19 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   34 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   23 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  142 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        | 1632 ++++++++++++++++=
++
 drivers/net/wireless/iwlwifi/iwl-pci.c             |   20 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   50 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c         |    7 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |   35 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |   52 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |   23 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   50 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c       |   15 +-
 drivers/net/wireless/libertas/cfg.c                |   25 +-
 drivers/net/wireless/mac80211_hwsim.c              |    2 +
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   18 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    4 +-
 drivers/net/wireless/mwifiex/fw.h                  |    2 +-
 drivers/net/wireless/mwifiex/init.c                |    4 +-
 drivers/net/wireless/mwifiex/join.c                |   96 +-
 drivers/net/wireless/mwifiex/pcie.c                |   11 +-
 drivers/net/wireless/mwifiex/scan.c                |   10 +-
 drivers/net/wireless/mwifiex/sdio.c                |    4 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |   12 +-
 drivers/net/wireless/orinoco/scan.c                |   16 +-
 drivers/net/wireless/rndis_wlan.c                  |   23 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   36 +-
 drivers/net/wireless/wl12xx/scan.c                 |    2 +-
 include/asm-generic/socket.h                       |    3 +
 include/linux/errqueue.h                           |    3 +-
 include/linux/ieee80211.h                          |    6 +
 include/linux/nl80211.h                            |  111 ++
 include/linux/skbuff.h                             |   19 +-
 include/net/bluetooth/bluetooth.h                  |   29 +-
 include/net/bluetooth/hci.h                        |   22 +
 include/net/bluetooth/hci_core.h                   |  136 ++-
 include/net/bluetooth/l2cap.h                      |  416 ++++-
 include/net/bluetooth/mgmt.h                       |   47 +-
 include/net/cfg80211.h                             |  112 ++-
 include/net/ieee80211_radiotap.h                   |    8 -
 include/net/mac80211.h                             |   35 +-
 include/net/nfc/nci.h                              |  109 +-
 include/net/nfc/nci_core.h                         |   13 +-
 include/net/sock.h                                 |    6 +
 net/bluetooth/bnep/core.c                          |   13 +-
 net/bluetooth/cmtp/core.c                          |   13 +-
 net/bluetooth/hci_conn.c                           |   71 +-
 net/bluetooth/hci_core.c                           |  399 ++++--
 net/bluetooth/hci_event.c                          |  221 ++-
 net/bluetooth/hci_sysfs.c                          |   40 +-
 net/bluetooth/hidp/core.c                          |  157 +-
 net/bluetooth/l2cap_core.c                         |  963 ++++++++---
 net/bluetooth/l2cap_sock.c                         |   90 +-
 net/bluetooth/mgmt.c                               |  500 +++---
 net/bluetooth/rfcomm/core.c                        |   65 +-
 net/bluetooth/rfcomm/sock.c                        |    2 +
 net/bluetooth/rfcomm/tty.c                         |   45 +-
 net/bluetooth/smp.c                                |    3 +-
 net/core/skbuff.c                                  |   20 +
 net/core/sock.c                                    |    9 +
 net/mac80211/agg-rx.c                              |    3 +-
 net/mac80211/agg-tx.c                              |   10 +-
 net/mac80211/cfg.c                                 |  165 ++-
 net/mac80211/debugfs.c                             |    2 +-
 net/mac80211/driver-ops.h                          |   68 +-
 net/mac80211/ht.c                                  |    3 +-
 net/mac80211/ibss.c                                |    3 +
 net/mac80211/ieee80211_i.h                         |   29 +-
 net/mac80211/iface.c                               |   44 +-
 net/mac80211/key.c                                 |    9 +-
 net/mac80211/main.c                                |   39 +-
 net/mac80211/mesh.c                                |   70 +-
 net/mac80211/mesh.h                                |    7 +
 net/mac80211/mesh_hwmp.c                           |   52 +-
 net/mac80211/mesh_pathtbl.c                        |    3 -
 net/mac80211/mesh_plink.c                          |   50 +-
 net/mac80211/mlme.c                                |   89 +-
 net/mac80211/pm.c                                  |    2 +-
 net/mac80211/rc80211_minstrel.c                    |    7 +-
 net/mac80211/rx.c                                  |   73 +-
 net/mac80211/scan.c                                |  199 +--
 net/mac80211/sta_info.c                            |    8 +-
 net/mac80211/sta_info.h                            |    8 +
 net/mac80211/status.c                              |   87 +-
 net/mac80211/tx.c                                  |  110 ++-
 net/mac80211/util.c                                |  126 ++-
 net/mac80211/wme.c                                 |   10 +-
 net/mac80211/work.c                                |   46 +-
 net/mac80211/wpa.c                                 |    9 +-
 net/nfc/nci/core.c                                 |   18 +-
 net/nfc/nci/data.c                                 |    5 +-
 net/nfc/nci/lib.c                                  |    8 +-
 net/nfc/nci/ntf.c                                  |  152 +-
 net/nfc/nci/rsp.c                                  |   83 +-
 net/rfkill/core.c                                  |    4 +-
 net/socket.c                                       |   18 +
 net/wireless/core.c                                |    4 +
 net/wireless/core.h                                |    4 +-
 net/wireless/mlme.c                                |   35 +-
 net/wireless/nl80211.c                             |  419 ++++--
 net/wireless/nl80211.h                             |    5 +
 net/wireless/scan.c                                |  130 ++-
 net/wireless/wext-compat.c                         |   12 +
 205 files changed, 9141 insertions(+), 6576 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/mci.c
 create mode 100644 drivers/net/wireless/ath/ath9k/mci.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-mac80211.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--CE+1k2dSO48ffgeK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOxVKTAAoJEJctW/TcYTgG+8gQAJZqkMno5mGMjMzvDAHz+mDc
ahK6SVv0G2WpdGgiYzj9gedr9EQkz1UAEUCIh30p+7XE/XS9sNW3owIlFU1D+ZOm
REgoxgO5Q4SfUlykM1/4duKuPnc4AImk8i6wr9aT8+6KyfQP4joWcrYY0N5XctuQ
ZdXOT6hC+lzkAXjFIfowJ+/w6l8xXXt1o/vVWFAScqmiyffCcfumTFN27ptCRWWf
/1GHa3pgKS5LkNbnADmvg5BmQw4y7PLYQM0WKUkUTRcp7Y0zeBYzpGpOmTq3sJEm
y9oQrCbRbGCkrqQgjbi7CJvJ9OdIM50/eLg19P8IxZybZ6s+xGLsZImrngNob3W4
eNey4K+aIfSXY/t3oocvwBPd8FA132TQFVTYztHrhVQFAKHndPHgfGrvgCXfLpwm
BgkQgcy50M26AD/Wo0p3MSPFX8FBlGYRvq52RI3HkctvrkrLiyZTmUgGwD/Kk6IK
pWttMwDTtIFU2bu+XK++j8JNFk8K3NGAO05pth9vGEqyIyqmjr+WUS6G6p+EqsG5
0YRxjqrQhBDXew7xAwaM5/J3PKW1oh7AjTFZ8QIKZoOm2S4ovv9Uph5hbsFqKRIx
xZ/A1y4W82MMI8rKIHH20B1oOd0K600oAYTBbCiDi472p8F1hpA0QY2sUWN0/dqb
tChHaBqpTaHFnbUCYyRr
=qzTn
-----END PGP SIGNATURE-----

--CE+1k2dSO48ffgeK--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
