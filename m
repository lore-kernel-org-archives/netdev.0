From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-01-28
Date: Mon, 28 Jan 2013 15:20:55 -0500
Message-ID: <20130128202054.GD2107@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49226 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477Ab3A1UaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 15:30:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept this pull request intended for the 3.9 stream!

Included is an NFC pull.  Samuel says:

"It brings the following goodies:

- LLCP socket timestamping (To be used e.g with the recently released nfcto=
ol
  application for a more efficient skb timestamping when sniffing).
- A pretty big pn533 rework from Waldemar, preparing the driver to support
  more flavours of pn533 based devices.
- HCI changes from Eric in preparation for the microread driver support.
- Some LLCP memory leak fixes, cleanups and slight improvements.
- pn544 and nfcwilink move to the devm_kzalloc API.
- An initial Secure Element (SE) API.
- An nfc.h license change from the original author, allowing non GPL
  application code to safely include it."

Also included are a pair of mac80211 pulls.  Johannes says:

"We found two bugs in the previous code, so I'm sending you a pull
request again this soon.

This contains two regulatory bug fixes, some of Thomas's hwsim beacon
timer work and a documentation fix from Bob."

"Another pull request for mac80211-next. This time, I have a number of
things, the patches are mostly self-explanatory. There are a few fixes
=66rom Felix and myself, and random cleanups & improvements. The biggest
thing is the partial patchset from Marco preparing for mesh powersave."

Additionally, there are a pair of iwlwifi pulls.  Johannes says:

"For iwlwifi-next, I have a few cleanups/improvements as well as a few
not very important fixes and more preparations for new devices."

"Please pull a few updates for iwlwifi. These are just some cleanups and
a debug improvement."

On top of that, there is a slew of driver updates.  This includes
brcmfmac, mwifiex, ath9k, carl9170, and mwl8k as well as a handful
of others.  The bcma and ssb busses get some attention as well.
Still, I don't see any big headliners here.

Also included is a pull of the wireless tree, in order to resolve
some merge conflicts.

Please let me know if there are problems!

John

P.S. This is bigger than I would like it to be.  I'm sorry that I got behin=
d!

---

The following changes since commit cef401de7be8c4e155c6746bfccf721a4fa5fab9:

  net: fix possible wrong checksum generation (2013-01-28 00:27:15 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 4205e6ef4ee747aa81930537b6035086ba5f1e28:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-01-28 14:43:00 -0500)

----------------------------------------------------------------

AceLan Kao (3):
      Bluetooth: Add support for IMC Networks [13d3:3393]
      Bluetooth: Add support for Foxconn / Hon Hai [0489:e04e]
      Bluetooth: Add support for Foxconn / Hon Hai [0489:e056]

Alexey Khoroshilov (3):
      p54pci: don't return zero on failure paths in p54p_probe()
      mwl8k: don't return zero on failure paths in mwl8k_probe[_hw]()
      iwlegacy: don't return zero on failure paths in il4965_pci_probe()

Amitkumar Karwar (4):
      mwifiex: use correct htcapinfo for HT20 ibss network
      mwifiex: update config_bands during infra association
      mwifiex: correct config_bands handling for ibss network
      mwifiex: correction in status codes used for association failure

Anderson Lizardo (1):
      Bluetooth: Fix incorrect strncpy() in hidp_setup_hid()

Arend van Spriel (10):
      brcmsmac: use perimeter lock in add_interface() callback
      brcmsmac: allow user-space setting of interface address
      brcmfmac: assure USB dongle firmware is reset upon module unload
      brcmfmac: define pr_fmt in one place
      brcmfmac: remove rx helper function from bus interface
      brcmfmac: remove brcmf_proto_hdrpull() from bus interface
      brcmfmac: remove unused event related definitions
      brcmfmac: cleanup netdev transmit callback
      brcmfmac: remove unnecessary curly braces in dhd_attach()
      nl80211: allow user-space to set address for P2P_DEVICE

Avinash Patil (7):
      mwifiex: parse WMM IEs from hostapd for mwifiex AP
      mwifiex: access interrupt status only while holding lock
      mwifiex: add init_fw_port handler for PCIe interface
      mwifiex: use pci_alloc/free_consistent APIs for PCIe
      mwifiex: flush TX ring for PCIe after disconnect or bss stop
      mwifiex: use map/unmap APIs in TX and RX to reduce memcpy
      mwifiex: fix typo in PCIe adapter NULL check

Ben Greear (1):
      mac80211: Allow disabling SGI-20

Bob Copeland (3):
      mac80211: fix mesh_hwmp kerneldoc
      mac80211: set NEED_TXPROCESSING for PERR frames
      mac80211: add encrypt headroom to PERR frames

Chen Gang (1):
      drivers/net/wireless: need consider the not '\0' terminated string.

Christian Lamparter (8):
      carl9170: advertise support for TDLS
      carl9170: import 1.9.7 firmware headers
      carl9170: allow P2P_GO interface creation after P2P_CLIENT
      carl9170: Only specify interface combinations if more than one interf=
ace is possible
      carl9170: don't enable hw crypto offload, if the fw doesn't support it
      carl9170: disable hw crypto for p2p networks
      carl9170: remove custom NUM_TID and friends
      carl9170: refactor carl9170_update_beacon

Chun-Yeow Yeoh (2):
      mac80211: use short slot time in mesh for 5GHz
      mac80211: allow disable power save in mesh

Cong Ding (1):
      net: wireless/rtlwifi: fix uninitialized variable issue

Dan Carpenter (2):
      b43: N-PHY: fix gain in b43_nphy_get_gain_ctl_workaround_ent()
      prism54: bug in getting auth type

Daniel Schaal (1):
      Bluetooth: Add support for GC-WB300D PCIe [04ca:3006] to ath3k.

Emmanuel Grumbach (12):
      mac82011: use frame control to differentiate probe resp/beacon
      iwlwifi: make the BC table layout configurable
      iwlwifi: clean up code in AGG
      iwlwifi: don't verify fw after download
      iwlwifi: let the op_mode run a FW while in RFKILL
      iwlwifi: virtualize iwl_{grab,release}_nic_access
      iwlwifi: virtualize SRAM access
      iwlwifi: don't treat a bool as an error code
      iwlwifi: always check that grab_nic_access succeeds
      iwlwifi: allow to zero SRAM
      iwlwifi: audit single frames from AGG queue in RS
      iwlwifi: improve the reports in TX path

Eric Lapuyade (6):
      NFC: Fixed nfc core and hci unregistration and cleanup
      NFC: Added error handling in event_received hci ops
      NFC: Changed event_received hci ops result semantic
      NFC: Fixed skb leak in tm_send() nfc and hci ops implementations
      NFC: Add HCI quirks to support driver (non)standard implementations
      NFC: update HCI documentation

Eytan Lifshitz (1):
      iwlwifi: fix spelling and value in LED registers.

Felix Fietkau (23):
      ath9k: use the devres API for allocations/mappings
      ath9k_hw: use the devres API for allocations
      wireless: fix regulatory HT40 allowed check
      ath9k: do not link receive buffers during flush
      ath9k: fix double-free bug on beacon generate failure
      ath9k: remove the WARN_ON that triggers if generating a beacon fails
      ath9k: add a better fix for the rx tasklet vs rx flush race
      ath9k: fix rx flush handling
      ath9k_hw: add tx gain tables for newer devices
      ath9k: remove sc->rx.rxbuflock to fix a deadlock
      ath9k: disable the tasklet before taking the PCU lock
      mac80211: fix monitor mode injection
      ath9k_hw: fix calibration issues on chainmask that don't include chai=
n 0
      ath9k_hw: fix chain swap setting when setting rx chainmask to 5
      ath9k: allow setting arbitrary antenna masks on AR9003+
      ath9k_hw: fix RF bank initialization
      ath9k: stop rx after tx
      ath9k: clean up processing of pending tx frames on reset
      ath9k: use ath_tx_process_buffer instead of open-coding similar code
      ath9k_hw: make the initval parameter to ath9k_hw_write_array const
      ath9k_hw: remove ath9k_hw_ani_setup and its variables
      ath9k_hw: reduce struct ar5416AniState size
      ath9k_hw: remove a useless WARN_ON

Fengguang Wu (1):
      ath9k_hw: ar9002_hw_spectral_scan_config() can be static

Gabor Juhos (2):
      ath9k: fix column header comments for some initval arrays
      rt2x00: rt2800: convert read_eeprom functions to return an int value

Geert Uytterhoeven (1):
      brcmsmac: initialize morepending in brcms_b_recv()

Gustavo Padovan (1):
      Bluetooth: Check if the hci connection exists in SCO shutdown

Hante Meuleman (7):
      brcmfmac: do not reconfigure refill rx on 0-length packet.
      brcmfmac: removed deprecated set_bitrate_mask support
      brcmfmac: Use dedicated trace level for CDC.
      brcmfmac: Remove unused caching dongle error.
      brcmfmac: Return correct error on netdev xmit.
      brcmfmac: Removing obsolete variables and inline functions.
      brcmfmac: Update init code routines from interface up.

Hauke Mehrtens (7):
      bcma: make bcma_find_core_unit() accessible
      bcma: mips: explicit assign IRQ numbers
      bcma: mips: make some info messages debug messages
      bcma: mips: show also disabled IRQs
      bcma: mips: remove assigned_irqs from structure
      bcma: mips: rename oldirqflag to irqinitmask
      bcma: fix compile error

Helmut Schaa (1):
      rt2x00: Improve TX status handling for BlockAckReq frames

Jaganath Kanakkassery (1):
      Bluetooth: Fix authentication if acl data comes before remote feature=
 evt

Johannes Berg (65):
      Merge remote-tracking branch 'mac80211/master' into HEAD
      mac80211_hwsim: allow testing paged RX
      mac80211: remove final sta_info_flush()
      mac80211: warn if unexpectedly removing stations
      mac80211: optimise roaming time again
      mac80211: remove a bit of dead mesh code
      regulatory: don't write past array when intersecting rules
      regulatory: don't allocate too much memory
      regulatory: clean up regdom_intersect
      regulatory: clean up reg_copy_regd()
      regulatory: don't test list before iterating
      regulatory: simplify regulatory_hint_11d
      regulatory: code cleanup
      regulatory: remove useless locking on exit
      regulatory: use proper enum for return values
      cfg80211: remove wiphy_idx_valid
      regulatory: remove BUG_ON
      regulatory: simplify restore_regulatory_settings
      regulatory: remove redundant isalpha() check
      regulatory: remove useless warning
      regulatory: simplify freq_reg_info_regd
      regulatory: clarify locking rules and assertions
      regulatory: remove locking from wiphy_apply_custom_regulatory
      regulatory: fix reg_is_valid_request handling
      regulatory: remove handling of channel bandwidth
      regulatory: pass new regdomain to reset function
      regulatory: use RCU to protect global and wiphy regdomains
      regulatory: use RCU to protect last_request
      regulatory: use IS_ERR macro family for freq_reg_info
      mac80211: optimise AP stop RCU handling
      cfg80211: adjacent 80+80 MHz channel segments are invalid
      mac80211: fix ieee80211_ie_build_vht_cap indentation
      mac80211: clean up ieee80211_quiesce
      mac80211: clean up association better in suspend
      mac80211: fix channel context iteration
      mac80211: track enable_beacon explicitly
      mac80211: reconfig bss_info_changed only if beaconing
      mac80211: further simplify ieee80211_bss_info_change_notify
      mac80211: assign bss_conf.bssid only once
      mac80211: restrict assoc request VHT capabilities
      cfg80211: move some AP code to right file
      nl80211/mac80211: support full station state in AP mode
      mac80211: split aggregation stop by reason
      mac80211: split out aggregation TX removal
      mac80211: move ieee80211_remove_tid_tx function
      mac80211: split TX aggregation stop action
      wireless: use __packed in ieee80211.h
      mac80211: support HT notify channel width action
      wireless: use __aligned
      mac80211: unset peer's HT 40 MHz support if not usable
      cfg80211: disallow more station changes
      iwlwifi: use __packed
      iwlwifi: request IRQ only once
      iwlwifi: move some PCIe calls to better places
      regulatory: fix uevent
      regulatory: fix restore_regulatory_settings
      mac80211: fix HT40 connections
      iwlwifi: don't memset scalar values
      iwlwifi: don't enable all interrupts on resuming
      iwlwifi: simplify scheduler memory clearing
      iwlwifi: enable communication with WoWLAN firmware
      mac80211: fix FT roaming
      mac80211: fix resume from WoWLAN
      mac80211: call restart complete at wowlan resume time
      mac80211: split out chandef tracing macros

John W. Linville (9):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.sipsolutions.net/mac80211-next
      Merge tag 'nfc-next-3.9-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (1):
      cfg80211: Allow use_mfp to be specified with the connect command

Julia Lawall (2):
      NFC: nfcwilink: Use devm_kzalloc
      drivers/nfc/nfcwilink.c: use devm_kzalloc

Larry Finger (1):
      rtlwifi: Fix build warning introduced by commit a290593

Lauro Ramos Venancio (1):
      NFC: Change nfc.h license

Luis R. Rodriguez (4):
      cfg80211: do not process beacon hints if one is already queued
      cfg80211: move reg_is_world_roaming()
      cfg80211: move world roaming check for beacon hints
      wireless: make the reg_notifier() void

Marco Porsch (5):
      nl80211: add range checks to mesh parameters
      mac80211: update mesh peer link counter during userspace peering
      mac80211: move add_tim to subfunction
      {cfg,nl,mac}80211: set beacon interval and DTIM period on mesh join
      {cfg,nl}80211: mesh power mode primitives and userspace access

Nathan Hintz (8):
      bcma: return the mips irq number in bcma_core_irq
      bcma: update pci configuration for bcm4706/bcm4716
      bcma: fix bcm4716/bcm4748 i2s irqflag
      bcma: delete duplicate readl
      bcma: jump to 'out' label for invalid 'func' value
      bcma: don't map/unmap a subset of the PCI config space
      bcma: add support for 1 and 2 byte extended config space access
      bcma: use consistent case for 'hex' constants

Nishant Sarmukadam (2):
      mwl8k: Disable tx_wait completion
      mwl8k: Wake up queues in mwl8k_start

Piotr Haber (3):
      brcmsmac: increase timer reference count for new timers only
      brcmsmac: remove dead code
      brcmsmac: increase timer reference count for new timers only

Rafa=C5=82 Mi=C5=82ecki (2):
      ssb: add place for serial flash driver
      ssb: add database of serial flash memories

Samuel Ortiz (9):
      NFC: llcp: Remove the tx backlog queue
      NFC: llcp: Fix Rx memory leak
      NFC: pn544: Separate the core code and the i2c one into different mod=
ules
      NFC: pn544: Use module_i2c_driver
      NFC: pn544: Use devm_kzalloc API
      NFC: Initial Secure Element API
      NFC: Update pn544 documentation
      NFC: Avoid memcpy on LLCP connection less Rx path
      NFC: Use skb_copy_datagram_iovec

Sasha Levin (1):
      wireless: mwifiex: remove unreachable paths

Sergio Cambra (1):
      Bluetooth device 04ca:3008 should use ath3k

Simon Wunderlich (3):
      ath9k: add spectral scan feature
      ath9k: fix spectral scan endless mode on AR9002
      cfg80211: check radar interface combinations

Stanislaw Gruszka (5):
      rt2800: refactor RFCSR initialization
      iwlegacy: add flush callback
      iwlegacy: allow to enable PS
      mac80211: synchronize scan off/on-channel and PS states
      iwlegacy: fix IBSS cleanup

Sujith Manoharan (11):
      ath9k_hw: Remove AR9485 1.0 macro
      ath9k_hw: Enable calibration types in init_cal_settings
      ath9k_hw: Remove TEMP_COMP_CAL
      ath9k_hw: Fix calibration for AR9340
      ath9k_hw: Do not enable IQ-CAL for half/quarter rates
      ath9k_hw: Fix MCI init for AGC calibration
      ath9k_hw: Use helper routines to simplify ar9003_hw_init_cal()
      ath9k_hw: Update initvals for QCA955x
      ath9k_hw: Add TempCompensation feature for AR9550
      ath9k_hw: Fix radio programming for AR9550
      ath9k_htc: Fix memory leak

Szymon Janc (1):
      Bluetooth: Fix sending HCI commands after reset

Thierry Escande (2):
      NFC: Add support for SO_TIMESTAMP LLCP socket option
      NFC: pn533: Fix bad allocation size

Thomas Pedersen (4):
      mac80211_hwsim: fix tsf adjustment
      mac80211_hwsim: hrtimer beacon
      mac80211_hwsim: fix beacon timing
      mac80211_hwsim: fix beacon timestamp and mactime

Vladimir Kondratiev (1):
      wireless: more 'capability info' bits

Waldemar Rymarkiewicz (28):
      NFC: pn533: Remove in/out_maxlen as it is not used
      NFC: pn533: Remove unused definitions
      NFC: pn533: Add frame header length define
      NFC: pn533: Remove pointless flags param
      NFC: pn533: Add a new pn533_send_cmd_async iface
      NFC: pn533: Add a new pn533_send_data_async iface
      NFC: pn533: Add a new pn533_send_sync iface
      NFC: pn533: Add pn533_alloc_skb for req allocation
      NFC: pn533: Remove pn533_send_cmd_frame_sync
      NFC: pn533: Del frame logic from TgGet/SetData cmd
      NFC: pn533: Del frame logic from InJumForDep cmd
      NFC: pn533: Del frame logic from Data Exchange cmd
      NFC: pn533: Dump tx and rx data in debug mode
      NFC: pn533: Remove frame logic from poll cmds
      NFC: pn533: Fix quoted strings split across lines
      NFC: pn533: Fix spacing issues
      NFC: pn533: Fix open parenthesis alignment
      NFC: pn533: Fix minor style issues
      NFC: pn533: Remove unused pn533_send_cmd_frame_asy
      NFC: pn533: Fix urb->status handling
      NFC: pn533: Cleanup debug messages
      NFC: pn533: Don't use out_frame in pn533_send_ack
      NFC: pn533: Use skb in __pn533_send_cmd_frame_asyn
      NFC: pn533: Remove deprecated dev->out_frame buff
      NFC: pn533: Cleanup pn533_cmd_complete_t
      NFC: pn533: Remove unused dev->wq_in_frame
      NFC: pn533: Introduce ops for frame logic
      NFC: pn533: Fix missing parenthesis

Yacine Belkadi (1):
      {cfg,mac}80211.h: fix some kernel-doc warnings

Yogesh Ashok Powar (8):
      mwl8k: Remove redundant txq_idx
      mwl8k: set ack policy to normal
      mwl8k: Enable support to support additional ampdu streams
      mwl8k: changing mwl8k_destroy_ba prototype
      mwl8k: Handle Watchdog events for the new ampdu streams
      mwl8k: Handle watchdog event with highest prioriry
      mwl8k: bump firmware API to 3
      mwl8k: Delete ampdu streams with state AMPDU_STREAM_NEW in sta remove

 Documentation/nfc/nfc-hci.txt                      |  129 +-
 Documentation/nfc/nfc-pn544.txt                    |   84 +-
 arch/mips/bcm47xx/serial.c                         |    2 +-
 drivers/bcma/bcma_private.h                        |    2 +
 drivers/bcma/driver_chipcommon.c                   |    2 +-
 drivers/bcma/driver_mips.c                         |  157 +-
 drivers/bcma/driver_pci_host.c                     |   62 +-
 drivers/bcma/main.c                                |    4 +-
 drivers/bluetooth/ath3k.c                          |   10 +
 drivers/bluetooth/btusb.c                          |    5 +
 drivers/net/wireless/ath/ath5k/base.c              |    5 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   16 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   22 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   33 +-
 drivers/net/wireless/ath/ath9k/ani.h               |    8 -
 drivers/net/wireless/ath/ath9k/ar5008_initvals.h   |    8 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   50 +-
 drivers/net/wireless/ath/ath9k/ar9001_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |   23 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   66 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  180 +++
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  145 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  128 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   69 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  122 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |  100 ++
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |  146 ++
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   |  132 +-
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |   76 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |  165 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    4 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  116 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    7 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    4 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    2 +
 drivers/net/wireless/ath/ath9k/hw-ops.h            |   16 -
 drivers/net/wireless/ath/ath9k/hw.c                |   48 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   59 +-
 drivers/net/wireless/ath/ath9k/init.c              |  116 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    3 +-
 drivers/net/wireless/ath/ath9k/main.c              |  163 +-
 drivers/net/wireless/ath/ath9k/mci.c               |    7 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   39 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  171 ++-
 drivers/net/wireless/ath/ath9k/reg.h               |    7 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  145 +-
 drivers/net/wireless/ath/carl9170/carl9170.h       |   19 +-
 drivers/net/wireless/ath/carl9170/fw.c             |   37 +-
 drivers/net/wireless/ath/carl9170/fwcmd.h          |    8 +
 drivers/net/wireless/ath/carl9170/hw.h             |    2 +-
 drivers/net/wireless/ath/carl9170/main.c           |  113 +-
 drivers/net/wireless/ath/carl9170/tx.c             |  133 +-
 drivers/net/wireless/ath/carl9170/version.h        |    6 +-
 drivers/net/wireless/ath/regd.c                    |   37 +-
 drivers/net/wireless/ath/regd.h                    |   10 +-
 drivers/net/wireless/b43/tables_nphy.c             |   30 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    2 -
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    2 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   39 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   19 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |   48 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |    2 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   35 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   90 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   24 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |    2 -
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   27 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   94 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    7 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |   13 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   14 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    9 +-
 drivers/net/wireless/brcm80211/brcmsmac/scb.h      |    1 -
 drivers/net/wireless/iwlegacy/3945-mac.c           |    6 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   10 +-
 drivers/net/wireless/iwlegacy/common.c             |   71 +-
 drivers/net/wireless/iwlegacy/common.h             |    1 +
 drivers/net/wireless/iwlwifi/dvm/commands.h        |    8 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |    4 +-
 drivers/net/wireless/iwlwifi/dvm/led.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   20 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   21 +-
 drivers/net/wireless/iwlwifi/dvm/tt.c              |    4 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   51 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |   96 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    4 +
 drivers/net/wireless/iwlwifi/iwl-io.c              |  168 +--
 drivers/net/wireless/iwlwifi/iwl-io.h              |   21 +-
 drivers/net/wireless/iwlwifi/iwl-test.c            |   53 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   99 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    8 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   14 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  309 +++-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   79 +-
 drivers/net/wireless/libertas/cfg.c                |   33 +-
 drivers/net/wireless/libertas/cfg.h                |    3 -
 drivers/net/wireless/mac80211_hwsim.c              |  177 ++-
 drivers/net/wireless/mwifiex/11n.c                 |    4 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    6 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   25 +-
 drivers/net/wireless/mwifiex/decl.h                |   18 +
 drivers/net/wireless/mwifiex/fw.h                  |   14 +-
 drivers/net/wireless/mwifiex/init.c                |    6 +
 drivers/net/wireless/mwifiex/ioctl.h               |    3 +-
 drivers/net/wireless/mwifiex/join.c                |   30 +-
 drivers/net/wireless/mwifiex/main.h                |    6 +
 drivers/net/wireless/mwifiex/pcie.c                |  656 +++++---
 drivers/net/wireless/mwifiex/pcie.h                |   33 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   10 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   14 +
 drivers/net/wireless/mwifiex/txrx.c                |    6 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   44 +
 drivers/net/wireless/mwifiex/usb.c                 |   30 +-
 drivers/net/wireless/mwifiex/util.h                |    8 +-
 drivers/net/wireless/mwifiex/wmm.c                 |    8 +-
 drivers/net/wireless/mwl8k.c                       |  151 +-
 drivers/net/wireless/p54/p54pci.c                  |    7 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |    1 +
 drivers/net/wireless/ray_cs.c                      |   19 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  814 +++++-----
 drivers/net/wireless/rt2x00/rt2800lib.h            |    8 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   35 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   20 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  101 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   47 +
 drivers/net/wireless/rtlwifi/Kconfig               |    4 +-
 drivers/net/wireless/rtlwifi/core.c                |    4 +-
 drivers/net/wireless/rtlwifi/regd.c                |   37 +-
 drivers/net/wireless/rtlwifi/regd.h                |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   10 +-
 drivers/nfc/Kconfig                                |   15 +-
 drivers/nfc/Makefile                               |    2 +-
 drivers/nfc/nfcwilink.c                            |   10 +-
 drivers/nfc/pn533.c                                | 1593 ++++++++++------=
----
 drivers/nfc/pn544/Kconfig                          |   23 +
 drivers/nfc/pn544/Makefile                         |    5 +-
 drivers/nfc/pn544/i2c.c                            |   44 +-
 drivers/nfc/pn544/pn544.c                          |   65 +-
 drivers/ssb/Kconfig                                |    5 +
 drivers/ssb/Makefile                               |    1 +
 drivers/ssb/driver_chipcommon_sflash.c             |  140 ++
 drivers/ssb/driver_mipscore.c                      |    3 +-
 drivers/ssb/ssb_private.h                          |   11 +
 include/linux/bcma/bcma_driver_mips.h              |    4 +-
 include/linux/bcma/bcma_driver_pci.h               |    2 +
 include/linux/ieee80211.h                          |  100 +-
 include/net/cfg80211.h                             |  212 ++-
 include/net/mac80211.h                             |  112 +-
 include/net/nfc/hci.h                              |   22 +-
 include/net/nfc/nci_core.h                         |    1 +
 include/net/nfc/nfc.h                              |    8 +
 include/net/regulatory.h                           |    4 +
 include/uapi/linux/nfc.h                           |   37 +-
 include/uapi/linux/nl80211.h                       |   72 +-
 net/bluetooth/hci_core.c                           |    8 -
 net/bluetooth/hci_event.c                          |    2 +-
 net/bluetooth/hidp/core.c                          |    2 +-
 net/bluetooth/l2cap_core.c                         |   11 +
 net/bluetooth/sco.c                                |    2 +-
 net/mac80211/agg-tx.c                              |  253 ++--
 net/mac80211/cfg.c                                 |  179 ++-
 net/mac80211/chan.c                                |    3 +-
 net/mac80211/driver-ops.h                          |   23 +-
 net/mac80211/ht.c                                  |   33 +-
 net/mac80211/ibss.c                                |   57 +-
 net/mac80211/ieee80211_i.h                         |   29 +-
 net/mac80211/iface.c                               |   38 +-
 net/mac80211/main.c                                |   70 +-
 net/mac80211/mesh.c                                |   35 +-
 net/mac80211/mesh.h                                |   16 +-
 net/mac80211/mesh_hwmp.c                           |   10 +-
 net/mac80211/mesh_plink.c                          |   14 -
 net/mac80211/mlme.c                                |   72 +-
 net/mac80211/offchannel.c                          |   34 +-
 net/mac80211/pm.c                                  |   64 +-
 net/mac80211/rx.c                                  |   31 +-
 net/mac80211/scan.c                                |   24 +-
 net/mac80211/sta_info.c                            |   48 +-
 net/mac80211/sta_info.h                            |   42 +-
 net/mac80211/trace.h                               |   24 +-
 net/mac80211/tx.c                                  |   56 +-
 net/mac80211/util.c                                |   25 +-
 net/nfc/core.c                                     |   50 +-
 net/nfc/hci/command.c                              |    7 +-
 net/nfc/hci/core.c                                 |   57 +-
 net/nfc/hci/hcp.c                                  |    7 +
 net/nfc/llcp/commands.c                            |    2 +
 net/nfc/llcp/llcp.c                                |   44 +-
 net/nfc/llcp/llcp.h                                |    1 -
 net/nfc/llcp/sock.c                                |   22 +-
 net/nfc/nci/core.c                                 |    2 +
 net/nfc/netlink.c                                  |    1 +
 net/wireless/ap.c                                  |   62 +
 net/wireless/chan.c                                |    4 +
 net/wireless/core.c                                |   26 +-
 net/wireless/core.h                                |   25 +-
 net/wireless/mesh.c                                |    8 +
 net/wireless/mlme.c                                |   62 -
 net/wireless/nl80211.c                             |  268 ++--
 net/wireless/reg.c                                 | 1124 ++++++--------
 net/wireless/reg.h                                 |    7 +-
 net/wireless/sme.c                                 |    9 +-
 net/wireless/util.c                                |   41 +-
 210 files changed, 7702 insertions(+), 4987 deletions(-)
 create mode 100644 drivers/nfc/pn544/Kconfig
 create mode 100644 drivers/ssb/driver_chipcommon_sflash.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRBt2mAAoJEJctW/TcYTgG9NwQAIBUPTwFtu9szh5GBl2PCw/p
BgZb/e+5gJF1yN8yraGYT9Xyd3VZtalNTPVrESRF3YotCy1yjbP/o6PLDJ/fMdu7
ZFaOxKUjZ2h53eyeJ55gFr6mjbqTeGsPevRuqEG/IMuz8QBG5sSYYnZveXJZW/pE
DdVjLqNuU61g1kpB4wLDgp+JPoA4dPz0Nf6LRjUr9fwQz2BkwAxzdb9sPnxM35+z
dCBPdCTpSW96IwjXogSUHQ5I2/8c4l2GwKRVK3BJbBiAF0zuaN3qlGLKgozNHzXy
f4GDY/s6B/UerN9c7S3V5mjRSP5U+1kqDDpkZdqB5KyW5U6LU4SgwHOAbAgP9uZr
V7SCIf3WHwKtJBMj9Lge7RMP18vroY4gaGglXKH8yu20aSK9zBJYkdEXL+z54Hju
6RijvEk8eSQ/kiaJ9Iy9LPXoHwcbWoxAlLzinfbP6AjiV6oLEmpjzbmO1LUgaAZ/
ReMsiO0dX4b2VyFFtIlnOzkZKY5GfKpJFS6ciPlsf5YOJbj+qVYEYBkbcha39k6Z
SpngUQF15rWnS/Rlw9hnOjDpHe5NaJzBfcOopC1raWkCcHNOiyaJyV5/+S+vN/YI
//vYi+5c5hvU3xTRIMGSf8sKrOwr8iAOEJunG18UIJORQOxZfj+MvDI6EiblpdK4
4dgiy8nQZ9zujTYDD9vD
=sRZF
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
