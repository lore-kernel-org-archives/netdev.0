From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-04-24
Date: Wed, 24 Apr 2013 13:17:53 -0400
Message-ID: <20130424171752.GN8362@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qxx1br4bt0+wmkIi"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sapphire.tuxdriver.com ([70.61.120.61]:56801 "EHLO
	linville-x1.hq.tuxdriver.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755255Ab3DXRSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 13:18:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Here is one last(?) big wireless bits pull request before the merge window.=
=2E.

Regarding the mac80211 bits, Johannes says:

"Here's another big pull request for the -next stream. This one has a ton
of driver updates, which hopefully addresses all drivers, but maybe you
have more new drivers than I have in my tree? Not entirely sure, let me
know if this is the case and then I can merge wireless-next.

I'm including a large number of small changes, see the shortlog. The two
bigger things are making VHT compatible with not using channel contexts
(from Karl) and the stop-while-suspended fixes I developed together with
Stanislaw."

=2E..and...

"This time I have a relatively large number of fixes and small
improvements, the most important one being Bob's RCU fix. The two big
things are Felix's work on rate scaling tables (with a big thanks to
Karl too) and my own work on CSA handling to finally properly handle HT
(and some VHT.)"

As for the iwlwifi bits, Johannes says:

"The biggest work here is Bluetooth coexistence and power saving. Other
than that, I have a few small fixes that weren't really needed for 3.9
and a new PCI ID."

About the NFC bits, Samuel says:

"With this one we have:

- A major pn533 update. The pn533 framing support has been changed in order=
 to
  easily support all pn533 derivatives. For example we now support the ACR1=
22
  USB dongle.

- An NFC MEI physical layer code factorization through the mei_phy NFC API.
  Both the microread and the pn544 drivers now use it.

- LLCP aggregation support. This allows NFC p2p devices to send aggregated
  frames containing all sort of LLCP frames except SYMM and aggregation
  frames.

- More LLCP socket options for getting the remote device link parameters.

- Fixes for the LLCP socket option code added with the first pull request f=
or
  3.10.

- Some support for LLCP corner cases like 0 length SDUs and general DISC
  (tagged with a 0,0 dsap ssap couple) handling.

- RFKILL support for NFC."

For the b43 bits, Rafa=C5=82 says:

"Let me remind the changes for b43:
> Changes include:
> 1) Minor improvements for HT-PHY code (BCM4331)
> 2) Code cleaning for HT-PHY and N-PHY"

Concerning the bluetooth bits, Gustavo says:

"A set of changes intended for 3.10. The biggest changes here are from David
Herrmann, he rewrote most of the HIDP layer making it more reliable. Marcel
added a driver setup stage for device that need special handling on their
early initialization. Other than that we have the usual clean ups, bugfixes
and small improvements."

Along with all that, there is the usual collection of random/various
updates to ath9k, mwifiex, brcmfmac, brcmsmac, rt2x00, and wil6210.

I also included a pull of the wireless tree to resolve a merge conflict.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3dec2246c2ff11beb24ca1950f074b2bcbc85953:

  netlink: Fix build with mmap disabled. (2013-04-23 15:39:03 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 6ed0e321a0aef14a894e26658108bf7e895c36a6:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-04-24 10:54:20 -0400)

----------------------------------------------------------------

Alex A. Mihaylov (1):
      rt2x00: Fix transmit power troubles on some Ralink RT30xx cards

Alexander Bondar (13):
      mac80211: allow drivers to set default uAPSD parameters
      iwlwifi: mvm: downgrade to old power management API
      iwlwifi: mvm: Rename some power management definitions and methods
      iwlwifi: mvm: don't disable power management due to P2P device
      iwlwifi: mvm: Fix active-to-powersave transition time units
      iwlwifi: mvm: always send power table command
      iwlwifi: mvm: set keepalive period regardless of PM state
      iwlwifi: mvm: encapsulate power table command log message
      iwlwifi: mvm: change active-to-powersave transition time for BPS
      iwlwifi: mvm: remove redundant iwl_power_get_params()
      mac80211: disable uAPSD if all ACs are under ACM
      mac80211: remove warning from ieee80211_beacon_loss
      mac80211: indicate admission control in TX queue parameters

Andre Guedes (7):
      Bluetooth: Fix HCI request framework
      Bluetooth: Fix hci_inquiry ioctl usage
      Bluetooth: Remove unneeded hci_req_cmd_status function
      Bluetooth: Change LE scanning timeout macros
      Bluetooth: Add LE scan type macros
      Bluetooth: Add macros for filter duplicates values
      Bluetooth: Rename LE_SCANNING_* macros

Andreas Fenkart (2):
      mwifiex: replace ra_list_curr by list rotation.
      mwifiex: rework round robin scheduling of bss nodes.

Andy Shevchenko (1):
      ipw2x00: move to kstrto* functions

Arend van Spriel (19):
      brcmfmac: obtain iftype for firmware-signal descriptor lookup
      brcmfmac: pass ifp pointer in brcmf_fws_find_mac_desc()
      brcmfmac: rename brcmf_fws_mac_desc_ready()
      brcmfmac: remove ifidx variable from brcmf_fws_process_skb()
      cfg80211: introduce critical protocol indication from user-space
      brcmfmac: reinitialize dequeue mask per node
      brcmfmac: check memory allocation in brcmf_add_if()
      brcmfmac: remove error message upon allocation failure
      brcmutil: simplify brcmu_pkt_free_skb()
      brcmfmac: destination mac closed when interface is closed
      brcmfmac: schedule dequeue upon firmware-signal reception
      brcmfmac: use lock in brcmf_fws_del_interface()
      brcmfmac: finalize transmit upon any rollback failure
      brcmfmac: change return type for brcmf_rollback_toq() to void
      brcmfmac: stop dequeue upon sk_buff commit failure
      brcmfmac: allow scanning to be suppressed in the driver
      brcmfmac: flush queue upon MACDESC_DEL firmware signal
      brcmfmac: correct error handling in brcmf_fws_init()
      brcmfmac: add credit borrowing mechanism

Avinash Patil (1):
      mwifiex: use PCI_DMA_FROMDEVICE for RX queue de-init

Ben Greear (3):
      mac80211: make beacon-loss-count configurable
      mac80211: add beacon stats to debugfs
      mac80211: be more careful about sending beacon-loss-events

Bing Zhao (6):
      mwifiex: configure p2p interface during initialization
      mwifiex: correct bss_mode check while appending vht operation IE
      mwifiex: make use of msecs_to_jiffies()
      mwifiex: don't try to associate when bss_mode is not STA
      mwifiex: fix use-after-free in beacon_ie processing
      mwifiex: remove redundant initialization for bss_descriptor

Bob Copeland (2):
      mac80211: return new mpath from mesh_path_add()
      mac80211: use synchronize_rcu() with rcu_barrier()

Chan-yeol Park (3):
      Bluetooth: Fix H4 crash from incoming UART packets
      Bluetooth: Fix possible NULL dereference in hci_uart_tty_receive
      Bluetooth: Remove trivial white space

Chun-Yeow Yeoh (1):
      mac80211: fix the PREP mesh hwmp debug message

Claudio Takahasi (5):
      Bluetooth: Fix SCO connection reference
      Bluetooth: Use GFP_KERNEL in sco_conn_add
      Bluetooth: Minor coding style fix
      Bluetooth: Remove unneeded parameter
      Bluetooth: Reject SCO when hci connection timeouts

Dan Carpenter (1):
      ath9k: use GFP_ATOMIC under spinlock

David Herrmann (18):
      Bluetooth: hidp: remove redundant error message
      Bluetooth: hidp: verify l2cap sockets
      Bluetooth: rename hci_conn_put to hci_conn_drop
      Bluetooth: remove unneeded hci_conn_hold/put_device()
      Bluetooth: introduce hci_conn ref-counting
      Bluetooth: hidp: remove unused session->state field
      Bluetooth: hidp: test "terminate" before sleeping
      Bluetooth: allow constant arguments for bacmp()/bacpy()
      Bluetooth: hidp: move hidp_schedule() to core.c
      Bluetooth: l2cap: introduce l2cap_conn ref-counting
      Bluetooth: l2cap: add l2cap_user sub-modules
      Bluetooth: hidp: add new session-management helpers
      Bluetooth: hidp: remove old session-management
      Bluetooth: hidp: handle kernel_sendmsg() errors correctly
      Bluetooth: hidp: merge hidp_process_{ctrl,intr}_transmit()
      Bluetooth: hidp: merge 'send' functions into hidp_send_message()
      Bluetooth: hidp: don't send boot-protocol messages as HID-reports
      Bluetooth: hidp: fix sending output reports on intr channel

Emmanuel Grumbach (10):
      mac80211: return the RSSI in dBm
      iwlwifi: mvm: ignore bt_ch_announce module parameter
      iwlwifi: mvm: split long debug print
      iwlwifi: mvm: implement reduced Tx power
      iwlwifi: mvm: remove BT Coex constraints upon roaming to A band
      iwlwifi: mvm: beautify code in BT Coex
      iwlwifi: mvm: clean up invalid station handling
      iwlwifi: mvm: rename iwl_mvm_new_bt_coex_notif
      iwlwifi: mvm: remove users of nvm_data->valid_tx_ant
      iwlwifi: dvm: handle FLUSH ampdu actions from mac80211

Eric Lapuyade (1):
      NFC: mei: Add a common mei bus API for NFC drivers

Felix Fietkau (16):
      ath9k_hw: clean up RF Bank6 handling on AR5416/AR91xx
      ath9k_hw: make various ar5416/ar91xx rf banks const
      ath9k_common: remove ath9k_cmn_padpos
      ath9k: improve dma map failure handling
      ath9k: fix handling of broken descriptors
      ath9k: detect more kinds of invalid descriptors
      ath9k: implement buffer holding handling for EDMA FIFO
      mac80211: fix and optimize MCS mask handling
      mac80211: fix CTS protection handling
      mac80211: improve the rate control API
      mac80211/minstrel_ht: use the new rate control API
      mac80211/minstrel: use the new rate control API
      ath: update hardware mac address with bssid mask
      ath9k: always set common->macaddr to the MAC adress of a virtual inte=
rface
      ath9k: merge ath_tx_start_dma into ath_tx_start
      ath9k: add support for the new rate control API

Franky Lin (6):
      brcmfmac: aggregate dongle ram access interface
      brcmfmac: move chip download state code to sdio_chip.c
      brcmutil: add new d11 interface support
      brcmfmac: adopt new d11 interface
      brcmfmac: add support for dongle ARM CR4 core
      brcmfmac: add BCM4335 sdio interface support

Fr=C3=A9d=C3=A9ric Dalleau (1):
      Bluetooth: Move and rename hci_conn_accept

Gabor Juhos (7):
      rt2x00: rt2x00mmio: use rt2x00mmio prefix in function names
      rt2x00: rt2400pci: use the rt2x00mmio_* routines
      rt2x00: rt2500pci: use the rt2x00mmio_* routines
      rt2x00: rt61pci: use the rt2x00mmio_* routines
      rt2x00: rt2800pci: use the rt2x00mmio_* routines
      rt2x00: rt2x00mmio: remove unused rt2x00pci_* defines
      rt2x00: rt2800lib: rename rt2800_init_bbb_early to rt2800_init_bbp_ea=
rly

Han Shen (1):
      rtl8192c:dm: Properly initialize local array and set value.

Hante Meuleman (3):
      brcmfmac: Add 43143 SDIO support.
      brcmfmac: Add drive strength programming for SDIO 43143.
      brcmfmac: define and use platform specific data for SDIO.

Hauke Mehrtens (1):
      b43: use bcma_pmu_spuravoid_pllupdate()

Ilan Peer (1):
      iwlwifi: mvm: Sync FW API time event notification change

Jaganath Kanakkassery (1):
      Bluetooth: Fix incorrect SSP mode bit for non SSP devices

Janusz Dziedzic (3):
      cfg80211: add P2P Notice of Absence attribute
      mac80211: use ieee80211_p2p_noa_attr structure
      mac80211: add P2P NoA settings

Joe Perches (1):
      rt2x00: Use more current logging styles, shrink object size

Johan Hedberg (6):
      Bluetooth: Track received events in hdev
      Bluetooth: Add __hci_cmd_sync() helper function
      Bluetooth: Add support for custom event terminated commands
      Bluetooth: Add __hci_cmd_sync_ev function
      Bluetooth: Track feature pages in a single table
      Bluetooth: Add reading of all local feature pages

Johannes Berg (38):
      mac80211: ibss: disable beaconing before freeing beacon
      mac80211: ibss: use beacon_data struct for beacon and probe response
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: mvm: add per-interface debugfs with mac_params file
      iwlwifi: print opmode when firmware is loaded
      iwlwifi: sleep for at least 10 seconds
      mac80211: remove ancient reference to master interface
      mac80211: remove unused IE pointers from parser
      mac80211: check DSSS params IE length in parser
      mac80211: check ERP info IE length in parser
      mac80211: parse Timeout Interval Element using a struct
      mac80211: remove outdated comment referring to master interface
      mac80211: purge remain-on-channel items when suspending
      mac80211: destroy virtual monitor interface across suspend
      mac80211: fix do_stop handling while suspended
      mac80211: don't fiddle with netdev queues in MLME code
      mac80211: replace some dead code by a warning
      mac80211: don't start new netdev queues if driver stopped
      mac80211: make ieee802_11_parse_elems an inline
      iwlwifi: print warning on request_module failure
      mac80211: always advertise STBC/MCSes even if no AP support
      brcm80211: simplify makefiles
      ath5k: use more idiomatic tracing include style
      wireless: regulatory: fix channel disabling race condition
      mac80211: use second center_freq segment only in 80+80
      mac80211: unify CSA action frame/beacon processing
      cfg80211: add ieee80211_operating_class_to_band
      mac80211: support extended channel switch
      mac80211: support secondary channel offset in CSA
      mac80211: handle extended channel switch announcement
      mac80211: parse VHT channel switch IEs
      mac80211: handle wide bandwidth channel switch
      mac80211: fix station entry leak/warning while suspending
      mac80211: fix P2P-Device management frame RX
      nl80211: allow using wdev identifiers to get scan results
      Merge remote-tracking branch 'wireless-next/master' into mac80211-next
      cfg80211: fix P2P-Device stop locking
      cfg80211: invert P2P-Device vs. netdev check ordering

John W. Linville (8):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge tag 'nfc-next-3.10-2' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.infradead.org/users/rafal/b43-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jonas Gorski (1):
      mwl8k: remove nonstandard rate 72 Mbps

Jouni Malinen (1):
      cfg80211: Document update_ft_ies() cfg80211_ops

Karl Beldan (13):
      mac80211: Use a cfg80211_chan_def in ieee80211_hw_conf_chan
      mac80211: let drivers not supporting channel contexts use VHT
      mac80211_hwsim: advertise VHT support also when channels =3D=3D 1
      mac80211: always pick a basic rate to tx RTS/CTS for pre-HT rates
      mac80211: fix rate control tx handler for VHT rates
      mac80211: adjust initial chandefs assignments in ieee80211_register_hw
      mac80211: VHT off-by-one NSS
      mac80211_hwsim: handle VHT rates in rx_status
      mac80211: cosmetics for minstrel_debugfs
      mac80211: optimize minstrel_ewma
      mac80211: minstrel_ht: pick only supported rates for sta and group ma=
x*rates
      mac80211: minstrel_ht: initialize rates selection
      mac80211_hwsim: handle IEEE80211_HW_SUPPORTS_RC_TABLE

Larry Finger (1):
      rtlwifi: rtl8188ee: Fix loop that ends early

Marcel Holtmann (4):
      Bluetooth: Add driver setup stage for early init
      Bluetooth: Convert BCM92035 support to driver setup callback
      Bluetooth: Remove driver init queue from core
      Bluetooth: Use separate function for BCM92035 vendor setup

Marek Puzyniak (2):
      mac80211: clear SSID when stopping AP
      mac80211: provide SSID in IBSS mode

Marina Makienko (1):
      NFC: pn533: Add missing usb_put_dev

Martin Pitt (1):
      mac80211_hwsim: Register and bind to driver

Mathias Kretschmer (1):
      ath9k: apply coverage class on slottime too

Noguchi Kazutosi (1):
      Bluetooth: Add support for Foxconn/Hon Hai [0489:e04d]

Olivier Guiter (1):
      NFC: llcp: Fix zero octets length SDU handling

Paul Stewart (1):
      mwifiex: Start P2P devices in P2P mode

Piotr Haber (3):
      brcmfmac: support save&restore firmware feature
      brcmfmac: setup SDIO reset behavior
      brcmfmac: support critical protocol API for DHCP

Rafa=C5=82 Mi=C5=82ecki (21):
      b43: HT-PHY: rename defines addressing cores on the 2059 radio
      b43: HT-PHY: tables: don't duplicate core-generic regs
      b43: HT-PHY: finish calculating values for idle TSSI
      b43: HT-PHY: do some extra TSSI setup after configuring TX
      b43: HT-PHY: define regs for power estimation
      b43: HT-PHY: store TX power state before disabling it
      b43: HT-PHY: use enum for RSSI types
      b43: N-PHY: use enum for RAIL type
      b43: N-PHY: simplify conditions in RSSI offset scale function
      b43: N-PHY: use more friendly variables names in RSSI code
      b43: N-PHY: rename RSSI types to be shorter and more accurate
      b43: N-PHY: use enum for RSSI type everywhere we use it
      b43: N-PHY: fix "NB" RSSI calibration on PHYs rev2-
      b43: use defines for board_type
      b43: N-PHY: define missing registers
      b43: N-PHY: use enum for INTC override function argument
      b43: N-PHY: use shortcut "ctl" in functions names
      b43: N-PHY: use defines for (re)storing VCM config
      b43: N-PHY: move tables init function to tables file
      b43: N-PHY: clean init tables
      b43: N-PHY: don't use deprecated b43_radio_foo16

Samuel Ortiz (11):
      NFC: pn533: Use dynamic debug for pn533 hex dumps
      NFC: llcp: Socket miux is a big endian field
      NFC: llcp: Fall back to local values when getting socket options
      NFC: llcp: Only keep raw sockets alive when the LLCP local leaves
      NFC: llcp: Remove local_cleanup last argument
      NFC: llcp: Terminate connection when receiving a DISC on (0,0)
      NFC: Prevent polling when device is down
      NFC: pn533: Turn radio on and off when bringing the device up and down
      rfkill: Add NFC to the list of supported radios
      NFC: RFKILL support
      NFC: pn544: Add MEI physical layer

Shuduo Sang (1):
      iwlwifi: add new pci id for 6x35 series

Simon Wunderlich (1):
      mac80211: fix recalc_radar hwconf sync problem

Stanislaw Gruszka (13):
      rt2800: merge 5xxx normal mode setup
      rt2800: move rf init calibration code
      rt2800: move RFCSR29_RSSI_GAIN to 3290 specific rfcsr init
      rt2800: move 30xx common rf init code
      rt2800: move GPIO_SWITCH setup to 3390 specific rfcsr init
      rt2800: move RFCSR6_R2 & LDO_CFG0 setup to 3572 specific rfcsr init
      rt2800: add rt2800_rx_filter_calibration procedure
      rt2800: move RF_R27 setup to individual rfcsr init subroutines
      rt2800: add rt2800_led_open_drain_enable subroutine
      rt2800: add rt2800_normal_mode_setup_3xxx subroutine
      rt2800: cleanup rt2800_init_rfcsr
      rt2x00: provide separate information about TXWI & RXWI sizes
      rt2800: nulify all last words of TXWI

Sujith Manoharan (4):
      ath9k: Remove unused argument "size"
      ath9k: Reduce deep indentation
      ath9k: Use lockless variants for the RX fifo queue
      ath9k: Fix RX DMA mapping

Thierry Escande (4):
      NFC: llcp: Aggregated frames support
      NFC: llcp: Use localy stored remote_miu value if not set at socket le=
vel
      NFC: llcp: Reset RW, LTO, and MIU remote parameters when link goes do=
wn
      NFC: llcp: Add support in getsockopt for RW, LTO, and MIU remote para=
meters

Thomas Pedersen (3):
      mac80211: unset FC retry bit in mesh fwding path
      mac80211: stringify another plink state
      mac80211: fix ieee80211_queue_stopped()

Vladimir Kondratiev (4):
      wil6210: Use cached copy of Rx descriptor
      wil6210: Tx init optimization
      wil6210: Use cached copy of Tx descriptor
      wil6210: more Rx descriptor accessor functions

Waldemar Rymarkiewicz (19):
      NFC: pn533: Reword all std frame logic funct
      NFC: pn533: Print out response status bits in hex
      NFC: pn533: Fix div by zero while stopping polling
      NFC: pn533: Update copyrights note
      NFC: pn533: Rename pn533_fw_reset appropriately
      NFC: pn533: Fix memleak while scheduling next cmd
      NFC: pn533: Optimise issued cmd context tracking
      NFC: pn533: Keep cmd context in pn533 struct
      NFC: pn533: Remove redundant cmd_ prefix in the struct
      NFC: pn533: Fix incorrect kfree of complete args
      NFC: pn533: Simplify __pn533_send_frame_async
      NFC: pn533: Avoid function declarations
      NFC: pn533: Re-group fields in struct pn533
      NFC: pn533: Move wq_in_error to cmd context
      NFC: pn533: Add protocol type for frame ops
      NFC: pn533: Add support for ACS ACR122U reader
      NFC: pn533: Add pn533_abort_cmd procedure
      NFC: pn533: Remove unused pn533_cmd_complete_t
      NFC: pn533: Increase version number

Wei Yongjun (2):
      rfkill: fix error return code in rfkill_gpio_probe()
      brcmfmac: fix potential NULL pointer dereference in brcmf_fws_flow_co=
ntrol_check()

Zefir Kurtisi (1):
      ath9k: change DFS logging to use ath_dbg()

 drivers/bluetooth/ath3k.c                          |   2 +
 drivers/bluetooth/btusb.c                          |  41 +-
 drivers/bluetooth/hci_h4.c                         |   3 +
 drivers/bluetooth/hci_ldisc.c                      |  15 +-
 drivers/net/wireless/adm8211.c                     |   3 +-
 drivers/net/wireless/at76c50x-usb.c                |   4 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |  14 +-
 drivers/net/wireless/ath/ath5k/Makefile            |   1 +
 drivers/net/wireless/ath/ath5k/base.c              |   2 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   4 +-
 drivers/net/wireless/ath/ath5k/trace.h             |   2 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |  92 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  17 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   9 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   2 +-
 drivers/net/wireless/ath/ath9k/calib.c             |   2 +-
 drivers/net/wireless/ath/ath9k/calib.h             |   6 +
 drivers/net/wireless/ath/ath9k/common.c            |  19 +-
 drivers/net/wireless/ath/ath9k/common.h            |   1 -
 drivers/net/wireless/ath/ath9k/dfs.c               |   6 -
 .../net/wireless/ath/ath9k/dfs_pattern_detector.c  |  43 +-
 .../net/wireless/ath/ath9k/dfs_pattern_detector.h  |   6 +-
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c  |  49 +-
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.h  |  27 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  18 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |  18 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  15 +-
 drivers/net/wireless/ath/ath9k/hw.h                |  13 -
 drivers/net/wireless/ath/ath9k/init.c              |   5 +-
 drivers/net/wireless/ath/ath9k/link.c              |   2 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   8 +
 drivers/net/wireless/ath/ath9k/mac.h               |   1 +
 drivers/net/wireless/ath/ath9k/main.c              |  19 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   4 +-
 drivers/net/wireless/ath/ath9k/recv.c              | 170 ++--
 drivers/net/wireless/ath/ath9k/reg.h               |   3 -
 drivers/net/wireless/ath/ath9k/xmit.c              | 137 +--
 drivers/net/wireless/ath/carl9170/debug.c          |   4 +-
 drivers/net/wireless/ath/carl9170/mac.c            |   8 +-
 drivers/net/wireless/ath/carl9170/main.c           |   9 +-
 drivers/net/wireless/ath/carl9170/phy.c            |   4 +-
 drivers/net/wireless/ath/hw.c                      |   6 +
 drivers/net/wireless/ath/reg.h                     |   4 +
 drivers/net/wireless/ath/wil6210/txrx.c            |  29 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |  49 +-
 drivers/net/wireless/b43/b43.h                     |   2 +-
 drivers/net/wireless/b43/main.c                    |   8 +-
 drivers/net/wireless/b43/phy_ht.c                  | 124 ++-
 drivers/net/wireless/b43/phy_ht.h                  |   6 +
 drivers/net/wireless/b43/phy_lcn.c                 |   5 +-
 drivers/net/wireless/b43/phy_lp.c                  |   4 +-
 drivers/net/wireless/b43/phy_n.c                   | 710 ++++++++-------
 drivers/net/wireless/b43/phy_n.h                   | 146 +++
 drivers/net/wireless/b43/radio_2059.c              |  39 +-
 drivers/net/wireless/b43/radio_2059.h              |  14 +-
 drivers/net/wireless/b43/tables_nphy.c             |  97 +-
 drivers/net/wireless/b43/tables_nphy.h             |  29 +-
 drivers/net/wireless/b43legacy/main.c              |   9 +-
 drivers/net/wireless/brcm80211/Kconfig             |   9 -
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   | 243 +++--
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c | 118 +--
 drivers/net/wireless/brcm80211/brcmfmac/btcoex.c   | 497 +++++++++++
 drivers/net/wireless/brcm80211/brcmfmac/btcoex.h   |  29 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   1 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  11 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 659 +++++++-------
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c | 256 ++++--
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  98 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    | 369 +++++++-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    | 101 ++-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |  32 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 197 ++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |  14 +-
 drivers/net/wireless/brcm80211/brcmsmac/Makefile   |  11 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |   4 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   6 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   4 +-
 drivers/net/wireless/brcm80211/brcmutil/Makefile   |   9 +-
 drivers/net/wireless/brcm80211/brcmutil/d11.c      | 162 ++++
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |  12 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   2 +
 drivers/net/wireless/brcm80211/include/brcmu_d11.h | 145 +++
 .../net/wireless/brcm80211/include/chipcommon.h    |  14 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |  32 +-
 drivers/net/wireless/iwlegacy/3945-rs.c            |   2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |  32 +-
 drivers/net/wireless/iwlegacy/4965-rs.c            |   2 +-
 drivers/net/wireless/iwlegacy/4965.c               |   2 +-
 drivers/net/wireless/iwlegacy/common.c             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   6 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c         |  10 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |  16 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  27 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |   2 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |  11 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |  45 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  14 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   3 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         | 333 ++++++-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   9 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         | 119 +++
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |  64 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  33 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |  12 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  31 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  27 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           | 115 +--
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  36 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   8 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |   2 +
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |  10 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |  14 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   1 +
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   2 +-
 drivers/net/wireless/libertas_tf/main.c            |   8 +-
 drivers/net/wireless/mac80211_hwsim.c              | 114 ++-
 drivers/net/wireless/mwifiex/11ac.c                |   2 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |  14 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  25 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   2 +-
 drivers/net/wireless/mwifiex/init.c                |  21 +-
 drivers/net/wireless/mwifiex/main.h                |   1 -
 drivers/net/wireless/mwifiex/pcie.c                |   4 +-
 drivers/net/wireless/mwifiex/scan.c                |  37 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  17 +-
 drivers/net/wireless/mwifiex/wmm.c                 | 160 ++--
 drivers/net/wireless/mwifiex/wmm.h                 |   3 +
 drivers/net/wireless/mwl8k.c                       |  46 +-
 drivers/net/wireless/p54/fwio.c                    |   4 +-
 drivers/net/wireless/p54/main.c                    |   4 +-
 drivers/net/wireless/p54/txrx.c                    |   4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            | 323 +++----
 drivers/net/wireless/rt2x00/rt2500pci.c            | 353 ++++----
 drivers/net/wireless/rt2x00/rt2500usb.c            |  35 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            | 636 +++++++------
 drivers/net/wireless/rt2x00/rt2800pci.c            | 277 +++---
 drivers/net/wireless/rt2x00/rt2800usb.c            |  66 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |  72 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |  10 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   8 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  24 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |  25 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c           |   2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |  17 +-
 drivers/net/wireless/rt2x00/rt2x00mmio.c           |  52 +-
 drivers/net/wireless/rt2x00/rt2x00mmio.h           |  52 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |  14 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  47 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   6 +-
 drivers/net/wireless/rt2x00/rt2x00soc.c            |   4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |  24 +-
 drivers/net/wireless/rt2x00/rt61pci.c              | 550 ++++++------
 drivers/net/wireless/rt2x00/rt73usb.c              |  32 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   4 +-
 drivers/net/wireless/rtl818x/rtl8180/grf5101.c     |   3 +-
 drivers/net/wireless/rtl818x/rtl8180/max2820.c     |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/rtl8225.c     |   3 +-
 drivers/net/wireless/rtl818x/rtl8180/sa2400.c      |   3 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   4 +-
 drivers/net/wireless/rtl818x/rtl8187/rtl8225.c     |   3 +-
 drivers/net/wireless/rtlwifi/base.c                |   8 +-
 drivers/net/wireless/rtlwifi/core.c                |   6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   4 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |   4 +-
 drivers/net/wireless/ti/wl1251/main.c              |   5 +-
 drivers/net/wireless/ti/wl12xx/cmd.c               |   2 +-
 drivers/net/wireless/ti/wl18xx/cmd.c               |   6 +-
 drivers/net/wireless/ti/wlcore/main.c              |   2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |   4 +-
 drivers/nfc/Kconfig                                |  10 +
 drivers/nfc/Makefile                               |   1 +
 drivers/nfc/mei_phy.c                              | 164 ++++
 drivers/nfc/mei_phy.h                              |  30 +
 drivers/nfc/microread/Kconfig                      |   2 +-
 drivers/nfc/microread/mei.c                        | 139 +--
 drivers/nfc/pn533.c                                | 653 ++++++++++----
 drivers/nfc/pn544/Kconfig                          |  13 +-
 drivers/nfc/pn544/Makefile                         |   2 +
 drivers/nfc/pn544/mei.c                            | 121 +++
 include/linux/bcma/bcma.h                          |   1 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   3 +
 include/linux/bcma/bcma_regs.h                     |   1 +
 include/linux/ieee80211.h                          |  73 +-
 include/linux/platform_data/brcmfmac-sdio.h        | 124 +++
 include/net/bluetooth/bluetooth.h                  |   5 +-
 include/net/bluetooth/hci.h                        |   9 +-
 include/net/bluetooth/hci_core.h                   |  98 +-
 include/net/bluetooth/l2cap.h                      |  15 +
 include/net/cfg80211.h                             |  38 +
 include/net/mac80211.h                             | 127 ++-
 include/net/nfc/nfc.h                              |   2 +
 include/uapi/linux/nfc.h                           |   7 +-
 include/uapi/linux/nl80211.h                       |  39 +
 include/uapi/linux/rfkill.h                        |   2 +
 net/bluetooth/hci_conn.c                           |  38 +-
 net/bluetooth/hci_core.c                           | 239 +++--
 net/bluetooth/hci_event.c                          | 184 ++--
 net/bluetooth/hci_sysfs.c                          |  17 +-
 net/bluetooth/hidp/core.c                          | 992 ++++++++++++-----=
----
 net/bluetooth/hidp/hidp.h                          |  67 +-
 net/bluetooth/hidp/sock.c                          |  22 +-
 net/bluetooth/l2cap_core.c                         | 127 ++-
 net/bluetooth/l2cap_sock.c                         |   6 +
 net/bluetooth/mgmt.c                               |  17 +-
 net/bluetooth/sco.c                                |  49 +-
 net/bluetooth/smp.c                                |   2 +-
 net/mac80211/cfg.c                                 |  57 +-
 net/mac80211/chan.c                                |  54 +-
 net/mac80211/debugfs_netdev.c                      |  11 +
 net/mac80211/debugfs_sta.c                         |   2 +
 net/mac80211/ibss.c                                | 146 +--
 net/mac80211/ieee80211_i.h                         |  49 +-
 net/mac80211/iface.c                               | 121 ++-
 net/mac80211/main.c                                |  82 +-
 net/mac80211/mesh.c                                |   6 +-
 net/mac80211/mesh.h                                |   3 +-
 net/mac80211/mesh_hwmp.c                           |  28 +-
 net/mac80211/mesh_pathtbl.c                        |  56 +-
 net/mac80211/mesh_plink.c                          |   6 +-
 net/mac80211/mlme.c                                | 442 +++++----
 net/mac80211/offchannel.c                          |   6 +-
 net/mac80211/pm.c                                  |  11 +-
 net/mac80211/rate.c                                | 324 +++++--
 net/mac80211/rc80211_minstrel.c                    | 206 +++--
 net/mac80211/rc80211_minstrel.h                    |   7 +-
 net/mac80211/rc80211_minstrel_debugfs.c            |   4 +-
 net/mac80211/rc80211_minstrel_ht.c                 | 172 ++--
 net/mac80211/rc80211_minstrel_ht.h                 |   2 +
 net/mac80211/rx.c                                  |  24 +-
 net/mac80211/scan.c                                |  13 +-
 net/mac80211/trace.h                               |  51 +-
 net/mac80211/tx.c                                  | 153 +---
 net/mac80211/util.c                                | 103 ++-
 net/nfc/core.c                                     |  43 +
 net/nfc/llcp/commands.c                            |  30 +-
 net/nfc/llcp/llcp.c                                | 127 ++-
 net/nfc/llcp/llcp.h                                |   5 +-
 net/nfc/llcp/sock.c                                |  43 +-
 net/rfkill/core.c                                  |   4 +-
 net/rfkill/rfkill-gpio.c                           |   7 +-
 net/wireless/core.h                                |   3 +
 net/wireless/mlme.c                                |   5 +
 net/wireless/nl80211.c                             | 285 ++++--
 net/wireless/rdev-ops.h                            |  24 +-
 net/wireless/reg.c                                 |   2 +-
 net/wireless/trace.h                               |  35 +
 net/wireless/util.c                                |  28 +-
 257 files changed, 9897 insertions(+), 5629 deletions(-)
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/btcoex.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/btcoex.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmutil/d11.c
 create mode 100644 drivers/net/wireless/brcm80211/include/brcmu_d11.h
 create mode 100644 drivers/nfc/mei_phy.c
 create mode 100644 drivers/nfc/mei_phy.h
 create mode 100644 drivers/nfc/pn544/mei.c
 create mode 100644 include/linux/platform_data/brcmfmac-sdio.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Qxx1br4bt0+wmkIi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJReBPAAAoJEJctW/TcYTgGlv8P/1lwswiwyPLyprYPQE/lKTKR
CqxY3CJq1XzvobD/JDrsGhuMe7oP5b/hSBtTIdxABsS/gE5yjB6c9cEQduK73knE
RWn6jcvOaLs/XSTcyjt7U1dIqGos/U+qvc0TGGQOv+Igpi6Ie1SaDyYQaShX4ECB
zrXtwf0UySfqNPwA6zLKsfwwBDOjfqv1PqFsMeS2tbSjQbgQRooTCZWrW5sW0qKq
SrRx5wNEv/3wSrbeSKMdONmgjxqvFn2lPcyiXK++8n5sy1JLZDMCz53296JTEOa3
wbo8ub2o7UClDZ+0MmrCnsObofFKo4eFeDlXgPJ20qj7E8SnI8doNV73e9TncGeM
2Gn9DdYOB1VuvWS/zF9fAwMqKtwBqVzpeabe/Y/Of8gBn2fgbMJUZiq+K3V7q1qI
GOKi9awJ/AED6sgZhLUyUVTJQcR+UKnQwGkCpyy6S0nUJuDJgk4shHmEiKByWZf2
Sgb0zq0do/qz9V0gV3C9Eoi9Z4E7QYaC1ZKixUqQDiRx1WTgx8DE/3mBGjaD4mKC
Wh4QRPKOA5wvhblQNez2cmhcwl6yGgCWnDHqcGEDY7DTwsByqE9XYwffUiPR9A6U
tBS6xFZejw4k2Vk2YwX/xfr5sOyr0WgapUIIJu/NpI5zPPHFpQNIUqqFu/GAYWpv
vfPErTEqhNQFS/gbsqSx
=wBDr
-----END PGP SIGNATURE-----

--Qxx1br4bt0+wmkIi--
