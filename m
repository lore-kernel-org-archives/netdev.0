From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2014-11-21
Date: Fri, 21 Nov 2014 13:30:15 -0500
Message-ID: <20141121183014.GA24984@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.19 stream...

For the mac80211 bits, Johannes says:

"It has been a while since my last pull request, so we accumulated
another relatively large set of changes:
 * TDLS off-channel support set from Arik/Liad, with some support
   patches I did
 * custom regulatory fixes from Arik
 * minstrel VHT fix (and a small optimisation) from Felix
 * add back radiotap vendor namespace support (myself)
 * random MAC address scanning for cfg80211/mac80211/hwsim (myself)
 * CSA improvements (Luca)
 * WoWLAN Net Detect (wake on network found) support (Luca)
 * and lots of other smaller changes from many people"

For the Bluetooth bits, Johan says:

"Here's another set of patches for 3.19. Most of it is again fixes and
cleanups to ieee802154 related code from Alexander Aring. We've also got
better handling of hardware error events along with a proper API for HCI
drivers to notify the HCI core of such situations. There's also a minor
fix for mgmt events as well as a sparse warning fix. The code for
sending HCI commands synchronously also gets a fix where we might loose
the completion event in the case of very fast HW (particularly easily
reproducible with an emulated HCI device)."

And...

"Here's another bluetooth-next pull request for 3.19. We've got:

 - Various fixes, cleanups and improvements to ieee802154/mac802154
 - Support for a Broadcom BCM20702A1 variant
 - Lots of lockdep fixes
 - Fixed handling of LE CoC errors that should trigger SMP"

For the Atheros bits, Kalle says:

"One ath6kl patch and rest for ath10k, but nothing really major which
stands out. Most notable:

o fix resume (Bartosz)

o firmware restart is now faster and more reliable (Michal)

o it's now possible to test hardware restart functionality without
  crashing the firmware using hw-restart parameter with
  simulate_fw_crash debugfs file (Michal)"

On top of that...both ath9k and mwifiex get their usual level of
updates.  Of note is the ath9k spectral scan work from Oleksij Rempel.

I also pulled from the wireless tree in order to avoid some merge issues.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit bf515fb11ab539c76d04f0e3c5216ed41f41d81f:

  Merge tag 'mac80211-next-for-john-2014-11-04' of git://git.kernel.org/pub=
/scm/linux/kernel/git/jberg/mac80211-next (2014-11-04 16:18:12 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-11-20

for you to fetch changes up to 9e6f3f472c8f95021ad048acc7cd3e40a827f8ce:

  mwifiex: Add USB8766 support (2014-11-20 16:14:39 -0500)

----------------------------------------------------------------
Alexander Aring (90):
      at86rf230: fix page parameter constraints
      ieee802154: remove default channel settings
      at86rf230: add default channel settings
      cfg802154: introduce cfg802154_registered_device
      mac802154: introduce mac802154_config_ops
      ieee802154: add helper wpan_phy_to_rdev function
      cfg802154: convert deprecated iface add and del
      ieee802154: don't allow to change addr while netif_running
      mac802154: add helper for converting dev_addr
      mac802154: set extended address filter on ifup
      mac802154: set short address filter on ifup
      mac802154: set panid address filter on ifup
      mac802154: move phy settings into netlink receive
      ieee802154: add extended address validation helper
      mac802154: iface: add validation for extended address
      ieee802154: 6lowpan: remove set of mac address
      ieee802154: add missing ULL definition
      ieee802154: fix byteorder issues
      mac802154: fix byteorder issues
      ieee802154: sysfs: add missing include
      mac802154: cfg: add missing include
      ieee802154: remove unnecessary functions
      netdevice: add ieee802154_ptr to net_device
      ieee802154: rework wpan_phy index assignment
      ieee802154: remove nl802154 unused functions
      mac802154: move interface del handling in iface
      mac802154: move interface add handling in iface
      mac802154: move dev_hold out of ieee802154_if_add
      ieee802154: rework interface registration
      ieee802154: remove mlme get_phy callback
      mac802154: add default interface registration
      mac802154: add ieee802154_vif struct
      ieee802154: add IEEE802154_EXTENDED_ADDR_LEN
      ieee802154: add ieee802154_random_extended_addr
      mac802154: add ieee802154_le64_to_be64
      mac802154: cleanup ieee802154_netdev_to_extended_addr
      mac802154: add support for perm_extended_addr
      at86rf230: generate random perm extended address
      at86rf230: add force slotted operation bit
      mac802154: use IEEE802154_EXTENDED_ADDR_LEN
      mac802154: fix typo promisuous to promiscuous
      Bluetooth: 6lowpan: fix skb_unshare behaviour
      mac802154: move mac pib attributes into wpan_dev
      mac802154: remove mac_params in sdata
      ieee802154: rename wpan_phy_alloc
      ieee802154: add cfg802154_registered_device list
      ieee802154: add iftype to wpan_dev
      ieee802154: add wpan_dev_list
      ieee802154: sysfs add wpan_phy index and name
      ieee802154: add new nl802154 header
      ieee802154: add nl802154 framework
      ieee802154: add wpan_phy dump support
      ieee802154: add wpan_dev dump support
      mac820154: don't set monitor dev_addr
      ieee802154: netlink add rtnl lock
      ieee802154: fix iface dump with lowpan
      mac802154: protect address changes via ioctl
      mac820154: move interface unregistration into iface
      mac820154: rename sdata next to tmp
      mac820154: move mutex locks out of loop
      mac802154: add wpan_phy priv id
      mac802154: change module description
      mac802154: add ifname change notifier
      ieee802154: cleanup cfg802154 intendation
      ieee820154: add channel set support
      ieee820154: remove valid page and channel checks
      ieee820154: add pan_id setting support
      ieee820154: add short_addr setting support
      ieee820154: add backoff exponent setting support
      at86rf230: remove invalid backoff exponent check
      ieee820154: add max csma backoffs setting support
      at86rf230: remove invalid max csma backoffs check
      ieee820154: add max frame retries setting support
      at86rf230: remove invalid max frame retries check
      ieee820154: add lbt setting support
      mac802154: add interframe spacing time handling
      at86rf230: remove interframe spacing time workaround
      mac802154: remove unused prototypes
      at86rf230: fix commentation for symbol duration
      mac802154: remove const for non pointer in driver-ops
      mac802154: remove const for non pointer in cfg ops
      mac802154: remove const for non pointer in rdev-ops
      mac802154: remove deprecated linux-zigbee info
      mac802154: use new nl802154 iftype types
      mac802154: remove wpan_dev parameter in if_add
      ieee802154: add new interface command
      ieee802154: setting extended address while iface add
      ieee802154: add del interface command
      ieee802154: rename and move WPAN_NUM_ defines
      ieee802154: fix byteorder for short address and panid

Alexey Khoroshilov (1):
      ath6kl: remove incorrect reset_resume handler

Amitkumar Karwar (2):
      mwifiex: fix out of memory issue observed for USB chipsets
      mwifiex: fix version display problem on big endian platforms

Arend van Spriel (1):
      brcmfmac: fix conversion of channel width 20MHZ_NOHT

Arik Nemtsov (12):
      cfg80211: introduce regulatory flags controlling bw
      mac80211: add supported channels IE during TDLS setup
      mac80211: add BSS coex IE to TDLS setup frames
      cfg/mac80211: define TDLS channel switch feature bit
      mac80211: track AP and peer STA TDLS chan-switch support
      mac80211: prepare TDLS mgmt code for channel-switch templates
      cfg80211: introduce TDLS channel switch commands
      mac80211: add parsing of TDLS specific IEs
      mac80211: introduce TDLS channel switch ops
      mac80211: add TDLS channel-switch Rx flow
      cfg80211: update missing fields in custom regulatory path
      cfg80211: explicitly initialize some fields in custom reg path

Avinash Patil (11):
      mwifiex: rx workqueue support for USB interface
      mwifiex: remove data_complete handler
      mwifiex: do not setup AMPDU/AMSDU with broadcast receiver
      mwifiex: fix warning while starting BSS
      mwifiex: module load parameter for interface creation
      mwifiex: update rx packet descriptor structure to match FW
      mwifiex: do not explicitly disable TDLS link during teardown
      mwifiex: wmm support for TDLS link
      mwifiex: add auto TDLS support
      mwifiex: support for parsing TDLS discovery frames
      mwifiex: enable auto TDLS support for SD8887

Bartosz Markowski (1):
      ath10k: fix pm resume after suspend

Ben Greear (1):
      ath9k: fix misc debugfs when not using chan context

Chan-yeol Park (1):
      Bluetooth: Fix hci_sync missing wakeup interrupt

Chun-Yeow Yeoh (3):
      ath9k: fix the assignment of hw queues for mesh interface
      ath9k|ath9k_htc: Seperate the software crypto flag for Tx and Rx
      ath9k_htc: Enable software crypto for mgmt frame in Tx for USB devices

Dan Carpenter (1):
      ieee802154: || vs && in ieee802154_is_valid_extended_addr()

Eliad Peller (2):
      mac80211: remove redundant check
      mac80211: don't allow 40MHz tx rates in case of 20MHz chandef

Emmanuel Grumbach (1):
      iwlwifi: mvm: abort scan upon RFKILL

Fabian Frederick (1):
      Bluetooth: hidp: replace kzalloc/copy_from_user by memdup_user

Fabio K (1):
      Bluetooth: Add support for Broadcom BCM20702A1 variant

Felix Fietkau (4):
      ath10k: add SURVEY_INFO_IN_USE for current channel on survey
      ath9k: add support for reporting tx power to mac80211
      mac80211: skip legacy rate mask handling for VHT rates
      mac80211: minstrel_ht: add a small optimization to minstrel_aggr_check

Fengguang Wu (1):
      at86rf230: fix simple_return.cocci warnings

Fugang Duan (1):
      Bluetooth: hci-uart-ath: Correct the comments in this driver

Hauke Mehrtens (3):
      b43: fix NULL pointer dereference in b43_phy_copy()
      bcma: make it possible to specify a IRQ num in bcma_core_irq()
      bcma: get IRQ numbers from dt

Henning Rogge (1):
      cfg80211: fix nl80211 cmd id in nl80211_send_mpath()

Jaganath Kanakkassery (1):
      Bluetooth: Send mgmt_connected only if state is BT_CONFIG

James Cameron (1):
      mwifiex: simplify ad hoc join capability info

Johan Hedberg (21):
      Bluetooth: Fix sparse warnings in RFCOMM
      Bluetooth: Fix sparse warning in amp.c
      Bluetooth: Fix mgmt connected notification
      Bluetooth: 6lowpan: Remove unnecessary RCU callback
      Bluetooth: Fix l2cap_sock_teardown_cb lockdep warning
      Bluetooth: Remove unnecessary hci_dev_lock/unlock in smp.c
      Bluetooth: Use proper nesting annotation for l2cap_chan lock
      Bluetooth: Fix L2CAP socket lock nesting level
      Bluetooth: Fix L2CAP nesting level initialization location
      Bluetooth: Fix correct nesting for 6lowpan server channel
      Bluetooth: Fix sending incorrect LE CoC PDU in BT_CONNECT2 state
      Bluetooth: Add key preference parameter to smp_sufficient_security
      Bluetooth: Trigger SMP for the appropriate LE CoC errors
      Bluetooth: Convert LTK list to RCU
      Bluetooth: Convert IRK list to RCU
      Bluetooth: Remove unnecessary hdev locking in smp.c
      Bluetooth: Add debug logs to help track locking issues
      Bluetooth: Fix clearing remote OOB data through mgmt
      Bluetooth: Fix BR/EDR-only address checks for remote OOB data
      Bluetooth: Use shorter "rand" name for "randomizer"
      Bluetooth: Call drain_workqueue() before resetting state

Johannes Berg (12):
      mac80211: add back support for radiotap vendor namespace data
      mac80211: refactor duplicate detection
      Merge remote-tracking branch 'wireless-next/master' into mac80211-next
      mac80211: move skb info band assignment out
      mac80211: factor out 802.11 header building code
      mac80211: add function to create data frame template including key
      cfg80211: allow drivers to support random MAC addresses for scan
      mac80211: rcu-ify scan and scheduled scan request pointers
      mac80211: allow drivers to support NL80211_SCAN_FLAG_RANDOM_ADDR
      mac80211_hwsim: support scanning with random MAC address
      mac80211-hwsim: remove unnecessary hwname check
      mac80211: notify drivers on sta rate table changes

John W. Linville (8):
      Merge tag 'mac80211-for-john-2014-11-10' of git://git.kernel.org/.../=
jberg/mac80211
      Merge tag 'iwlwifi-for-john-2014-11-10' of git://git.kernel.org/.../i=
wlwifi/iwlwifi-fixes
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      ath9k_htc: remove return of value in empty definintion of ath9k_htc_d=
einit_debug
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge commit '4e6ce4dc7ce71d0886908d55129d5d6482a27ff9' of git://git.=
kernel.org/.../linville/wireless
      Merge tag 'mac80211-next-for-john-2014-11-20' of git://git.kernel.org=
/.../jberg/mac80211-next

Jukka Rissanen (2):
      mac80211-hwsim: hwname is always known so use the value from wiphy
      nl80211: Replace interface socket owner attribute with more generic o=
ne

Kristian Evensen (1):
      mwifiex: Add USB8766 support

Kuba Pawlak (2):
      Bluetooth: Clear role switch pending flag
      Bluetooth: Sort switch cases by opcode's numeric value

Larry Finger (3):
      rtlwifi: Fix setting of tx descriptor for new trx flow
      rtlwifi: Fix errors in descriptor manipulation
      rtlwifi: rtl8192se: Fix connection problems

Liad Kaufman (5):
      iwlwifi: pcie: fix prph dump length
      mac80211: add option for setting skb flags before xmit
      mac80211: retransmit TDLS teardown packet through AP if not ACKed
      mac80211: add specific-queue flushing support
      mac80211: synchronously reserve TID per station

Luciano Coelho (9):
      mac80211: fix order of setting ch_switch and drv_pre_channel_switch c=
all
      mac80211: add device_timestamp to the drv_pre_channel_switch trace
      cfg80211: add channel switch started notification
      mac80211: send channel switch started notifications
      cfg80211/mac80211: allow any interface to send channel switch notific=
ations
      wlcore: check minimum buffer size in some cmd_send functions
      wlcore: make wlcore_cmd_send_failsafe() static
      cfg80211: refactor nl80211_start_sched_scan so it can be reused
      cfg80211: add wowlan net-detect support

Marcel Holtmann (11):
      Bluetooth: Check status of command complete for HCI_Reset
      Bluetooth: Print error message for HCI_Hardware_Error event
      Bluetooth: Use HCI_EV_HARDWARE_ERROR define for event payload
      Bluetooth: Introduce BT_BREDR and BT_LE config options
      Bluetooth: Add hci_reset_dev() for driver triggerd stack reset
      Bluetooth: Switch HCI H5 driver to use hci_reset_dev() function
      Bluetooth: Introduce HCI_QUIRK_STRICT_DUPLICATE_FILTER
      Bluetooth: Set HCI_QUIRK_STRICT_DUPLICATE_FILTER for Broadcom devices
      Bluetooth: Consolidate whitelist debugfs entry into device_list
      Bluetooth: btusb: Add internal callback for USB bulk rx data
      Bluetooth: Add hci_conn_lookup_type() helper function

Markus Elfring (1):
      net: brcm80211: Deletion of unnecessary checks before two function ca=
lls

Martin Townsend (1):
      6lowpan: move skb_free from error paths in decompression

Miaoqing Pan (2):
      ath9k: Fix RTC_DERIVED_CLK usage
      ath9k: Use new QCA953x initvals

Michal Kazior (20):
      ath10k: don't drop control and null func Rx
      ath10k: remove unused variable
      ath10k: use ieee80211 defines for crypto param lengths
      ath10k: fix rx buffer tracing
      ath10k: deduplicate htt rx dma unmapping
      ath10k: don't drop frames aggressively
      ath10k: add extra sanity check when popping amsdu
      ath10k: don't forget to replenish after fragmented Rx
      ath10k: clear htt->rx_confused on load
      ath10k: remove tsf argument from rx_desc tracing
      ath10k: re-use trace class
      ath10k: call correct function for frag threshold
      ath10k: avoid possible deadlock with scan timeout
      ath10k: change ce ring cleanup logic
      ath10k: make warm reset a bit safer and faster
      ath10k: split reset logic from power up
      ath10k: don't reset chip on power_down
      ath10k: fix possible bmi crash
      ath10k: expose hw restart via debugfs
      ath10k: speed up hw recovery

Oleksij Rempel (23):
      ath9k: add struct ath_spec_scan_priv
      ath9k: move spectral_mode to ath_spec_scan_priv
      ath9k: move spec_config to ath_spec_scan_priv
      ath9k: use struct dentry by ath9k_spectral_init_debug
      ath9k: add ath_hw to ath_spec_scan_priv
      ath9k: remove all struct ath_softc dependencies from spectral code
      ath: add struct ath_ps_ops
      ath9k: add ath_ps_ops bindings
      ath9k: use ath_ps_ops in ath9k_spectral_scan_
      ath9k: use ath_common instead of ieee80211_hw in ath9k_spectral_scan_
      ath9k: make ath9k_spectral_scan_ do not depend on ath_softc
      ath9k: move ath9k_spectral_scan_ from main.c to spectral.c
      ath9k: move spectral.* to common-spectral.*
      ath9k: For AR9271 chipsets, set count =3D 0 for endless samples.
      ath9k_htc: fix rs_datalen conversation
      ath9k_htc: add ath_ps_ops bindings
      ath9k_htc: add struct ath_spec_scan_priv to ath9k_htc_priv
      ath9k_htc: set initial spec_config values
      ath9k_htc: trigger spectral scan on set_channel
      ath9k_htc: process rx spectral packets
      ath9k_htc: add spectral scan debug interface
      ath9k: common-spectral: don't depend from ATH9K_DEBUGFS
      ath9k_common: make sure DEBUG_FS and RELAY enabled

Patrik Flykt (2):
      mac80211-hwsim: Factor out netlink attribute appending
      mac80211-hwsim: Add HWSIM_CMD_GET_RADIO command

Peter Oh (1):
      ath10k: fix mismatched wmi api call

Rafa=C5=82 Mi=C5=82ecki (1):
      cfg80211: protect fools returning NULL in add_virtual_intf

Rajkumar Manoharan (3):
      ath10k: handle ieee80211 header and payload tracing separately
      ath10k: add modpram 'skip_otp' to ignore empty otp error during BMI
      ath10k: advertise support for AP mode channel width changes

Ronald Wahl (1):
      mac80211: Fix regression that triggers a kernel BUG with CCMP

Simon Vincent (1):
      6lowpan: fix udp header compression when using raw sockets

Stanislaw Gruszka (1):
      rt2x00: do not align payload on modern H/W

Sujith Manoharan (10):
      ath9k: Update QCA953x initvals
      ath9k: Fix LED configuration
      ath9k: Enable TSF2 for generic HW timers
      ath9k: Store the chip chainmask in HW capabilities
      ath9k: Fix thermometer programming
      ath9k: Clear offchannel state properly
      ath9k: Cancel pending offchannel operations
      ath9k: Handle failure to send NoA
      ath9k: Adjust tbtt delta properly
      ath9k: Move roc completion to the offchannel timer

Szymon Janc (1):
      Bluetooth: Fix invalid response for 'Start Discovery' command

Tomasz Bursztyka (1):
      nl80211: Broadcast CMD_NEW_INTERFACE and CMD_DEL_INTERFACE

kbuild test robot (2):
      ath9k: ath9k_op_ps_wakeup() can be static
      ath9k_htc: ath9k_htc_op_ps_wakeup() can be static

 Documentation/devicetree/bindings/bus/bcma.txt     |  21 +
 drivers/bcma/driver_chipcommon.c                   |   2 +-
 drivers/bcma/driver_gpio.c                         |   4 +-
 drivers/bcma/driver_mips.c                         |  11 +-
 drivers/bcma/driver_pci_host.c                     |   4 +-
 drivers/bcma/host_pci.c                            |   5 +-
 drivers/bcma/main.c                                |  74 +-
 drivers/bluetooth/btusb.c                          |   9 +-
 drivers/bluetooth/hci_ath.c                        |   2 +-
 drivers/bluetooth/hci_h5.c                         |  13 +-
 drivers/net/ieee802154/at86rf230.c                 |  91 +-
 drivers/net/ieee802154/cc2520.c                    |   1 +
 drivers/net/ieee802154/fakelb.c                    |   3 -
 drivers/net/wireless/ath/ath.h                     |  12 +
 drivers/net/wireless/ath/ath10k/ce.c               |   9 +-
 drivers/net/wireless/ath/ath10k/core.c             |  30 +-
 drivers/net/wireless/ath/ath10k/core.h             |   5 +
 drivers/net/wireless/ath/ath10k/debug.c            |   7 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  99 +--
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   4 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  27 +-
 drivers/net/wireless/ath/ath10k/mac.h              |   1 +
 drivers/net/wireless/ath/ath10k/pci.c              | 364 ++++----
 drivers/net/wireless/ath/ath10k/trace.h            | 109 ++-
 drivers/net/wireless/ath/ath10k/txrx.c             |   3 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  16 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   6 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |   9 -
 drivers/net/wireless/ath/ath9k/Kconfig             |   2 +
 drivers/net/wireless/ath/ath9k/Makefile            |   6 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   9 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   9 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  51 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  13 +
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   | 498 ++++++++++-
 drivers/net/wireless/ath/ath9k/ath9k.h             |  11 +-
 drivers/net/wireless/ath/ath9k/channel.c           |  23 +-
 .../ath/ath9k/{spectral.c =3D> common-spectral.c}    | 165 +++-
 .../ath/ath9k/{spectral.h =3D> common-spectral.h}    |  29 +-
 drivers/net/wireless/ath/ath9k/common.c            |  10 +-
 drivers/net/wireless/ath/ath9k/common.h            |   1 +
 drivers/net/wireless/ath/ath9k/debug.c             |  13 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   9 +-
 drivers/net/wireless/ath/ath9k/htc.h               |   5 +
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |   6 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  25 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  13 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |  16 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  68 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   7 +-
 drivers/net/wireless/ath/ath9k/init.c              | 112 ++-
 drivers/net/wireless/ath/ath9k/main.c              | 174 ++--
 drivers/net/wireless/ath/ath9k/pci.c               |   4 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   3 +
 drivers/net/wireless/ath/ath9k/xmit.c              |  10 +-
 drivers/net/wireless/ath/regd.c                    |  14 +
 drivers/net/wireless/ath/wcn36xx/main.c            |   7 +-
 drivers/net/wireless/b43/main.c                    |   7 +-
 drivers/net/wireless/b43/phy_common.c              |   4 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |   6 +
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |  25 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   7 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   3 +-
 drivers/net/wireless/cw1200/scan.c                 |   2 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  10 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   1 +
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   1 +
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  12 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  20 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   7 +-
 drivers/net/wireless/mac80211_hwsim.c              | 283 +++++-
 drivers/net/wireless/mac80211_hwsim.h              |   3 +
 drivers/net/wireless/mwifiex/11n.h                 |   4 +
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |  52 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |   2 +
 drivers/net/wireless/mwifiex/Kconfig               |   2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   6 +
 drivers/net/wireless/mwifiex/decl.h                |   5 +
 drivers/net/wireless/mwifiex/fw.h                  |   1 +
 drivers/net/wireless/mwifiex/init.c                |  19 +-
 drivers/net/wireless/mwifiex/join.c                |   4 +-
 drivers/net/wireless/mwifiex/main.c                |  49 +-
 drivers/net/wireless/mwifiex/main.h                |  45 +-
 drivers/net/wireless/mwifiex/sdio.c                |   2 +
 drivers/net/wireless/mwifiex/sdio.h                |   7 +
 drivers/net/wireless/mwifiex/sta_event.c           |   9 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   4 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |   3 +
 drivers/net/wireless/mwifiex/tdls.c                | 288 +++++++
 drivers/net/wireless/mwifiex/txrx.c                |   4 -
 drivers/net/wireless/mwifiex/uap_cmd.c             |   2 +-
 drivers/net/wireless/mwifiex/usb.c                 |  51 +-
 drivers/net/wireless/mwifiex/usb.h                 |   3 +
 drivers/net/wireless/mwifiex/util.c                |  38 +
 drivers/net/wireless/mwl8k.c                       |   7 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   1 +
 drivers/net/wireless/rt2x00/rt2x00.h               |   7 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   7 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  50 +-
 drivers/net/wireless/rtlwifi/base.c                |   2 +-
 drivers/net/wireless/rtlwifi/core.c                |  13 +-
 drivers/net/wireless/rtlwifi/core.h                |   1 +
 drivers/net/wireless/rtlwifi/pci.c                 |  22 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |   2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |  17 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |   1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   7 +
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |   1 +
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |   2 +
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   7 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   2 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |  38 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   3 +
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c       |  15 +-
 drivers/net/wireless/rtlwifi/usb.c                 |  11 +
 drivers/net/wireless/ti/wl1251/main.c              |   2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |  15 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |   2 -
 drivers/staging/vt6656/main_usb.c                  |   7 +-
 include/linux/bcma/bcma.h                          |   2 +
 include/linux/bcma/bcma_driver_mips.h              |   4 +-
 include/linux/ieee80211.h                          |  49 ++
 include/linux/ieee802154.h                         |  42 +
 include/linux/netdevice.h                          |   3 +
 include/net/bluetooth/hci.h                        |  27 +-
 include/net/bluetooth/hci_core.h                   |  37 +-
 include/net/bluetooth/l2cap.h                      |  15 +-
 include/net/bluetooth/mgmt.h                       |  12 +-
 include/net/cfg80211.h                             |  94 ++
 include/net/cfg802154.h                            | 102 ++-
 include/net/ieee802154_netdev.h                    |  12 -
 include/net/mac80211.h                             | 149 +++-
 include/net/mac802154.h                            |  36 +-
 include/net/nl802154.h                             | 222 ++---
 include/uapi/linux/nl80211.h                       | 108 ++-
 net/6lowpan/iphc.c                                 |  41 +-
 net/bluetooth/6lowpan.c                            |  36 +-
 net/bluetooth/Kconfig                              |  20 +-
 net/bluetooth/amp.c                                |  25 +-
 net/bluetooth/bnep/Kconfig                         |   2 +-
 net/bluetooth/cmtp/Kconfig                         |   2 +-
 net/bluetooth/hci_core.c                           | 184 ++--
 net/bluetooth/hci_event.c                          |  91 +-
 net/bluetooth/hidp/Kconfig                         |   2 +-
 net/bluetooth/hidp/core.c                          |  10 +-
 net/bluetooth/l2cap_core.c                         |  35 +-
 net/bluetooth/l2cap_sock.c                         |  29 +-
 net/bluetooth/mgmt.c                               | 108 ++-
 net/bluetooth/rfcomm/Kconfig                       |   2 +-
 net/bluetooth/rfcomm/core.c                        |   6 +-
 net/bluetooth/smp.c                                |  61 +-
 net/bluetooth/smp.h                                |   9 +-
 net/ieee802154/6lowpan_rtnl.c                      |  38 +-
 net/ieee802154/Makefile                            |   2 +-
 net/ieee802154/core.c                              | 220 ++++-
 net/ieee802154/core.h                              |  46 +
 net/ieee802154/ieee802154.h                        |   2 +-
 net/ieee802154/netlink.c                           |   2 +-
 net/ieee802154/nl-mac.c                            | 226 +----
 net/ieee802154/nl-phy.c                            |  23 +-
 net/ieee802154/nl802154.c                          | 957 +++++++++++++++++=
++++
 net/ieee802154/nl802154.h                          |   7 +
 net/ieee802154/rdev-ops.h                          |  89 ++
 net/ieee802154/sysfs.c                             |  40 +-
 net/mac80211/aes_ccm.c                             |   3 +
 net/mac80211/agg-tx.c                              |   7 +
 net/mac80211/cfg.c                                 |  27 +-
 net/mac80211/debugfs_sta.c                         |  11 +-
 net/mac80211/driver-ops.h                          |  83 +-
 net/mac80211/ibss.c                                |   2 +-
 net/mac80211/ieee80211_i.h                         |  45 +-
 net/mac80211/iface.c                               |  20 +-
 net/mac80211/main.c                                |   6 +
 net/mac80211/mesh.c                                |   2 +-
 net/mac80211/mlme.c                                |  33 +-
 net/mac80211/rate.c                                |   5 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   6 +-
 net/mac80211/rx.c                                  | 160 +++-
 net/mac80211/scan.c                                | 129 ++-
 net/mac80211/spectmgmt.c                           |  18 +-
 net/mac80211/sta_info.c                            |  15 +-
 net/mac80211/sta_info.h                            |  11 +
 net/mac80211/status.c                              |  55 +-
 net/mac80211/tdls.c                                | 792 ++++++++++++++++-
 net/mac80211/trace.h                               | 142 ++-
 net/mac80211/tx.c                                  | 303 +++++--
 net/mac80211/util.c                                |  60 +-
 net/mac80211/vht.c                                 |   2 +
 net/mac80211/wme.c                                 |  39 +
 net/mac802154/Makefile                             |   2 +-
 net/mac802154/cfg.c                                | 210 +++++
 net/mac802154/cfg.h                                |   9 +
 net/mac802154/driver-ops.h                         |  46 +-
 net/mac802154/ieee802154_i.h                       |  47 +-
 net/mac802154/iface.c                              | 310 +++++--
 net/mac802154/mac_cmd.c                            |  78 +-
 net/mac802154/main.c                               | 150 ++--
 net/mac802154/mib.c                                |  81 +-
 net/mac802154/rx.c                                 |  14 +-
 net/mac802154/tx.c                                 |   2 +-
 net/mac802154/util.c                               |  35 +-
 net/wireless/core.c                                |   4 +
 net/wireless/core.h                                |   1 +
 net/wireless/nl80211.c                             | 522 +++++++++--
 net/wireless/rdev-ops.h                            |  24 +
 net/wireless/reg.c                                 |  49 +-
 net/wireless/trace.h                               |  58 ++
 216 files changed, 8045 insertions(+), 2323 deletions(-)
 rename drivers/net/wireless/ath/ath9k/{spectral.c =3D> common-spectral.c} =
(73%)
 rename drivers/net/wireless/ath/ath9k/{spectral.h =3D> common-spectral.h} =
(85%)
 create mode 100644 net/ieee802154/core.h
 create mode 100644 net/ieee802154/nl802154.c
 create mode 100644 net/ieee802154/nl802154.h
 create mode 100644 net/ieee802154/rdev-ops.h
 create mode 100644 net/mac802154/cfg.c
 create mode 100644 net/mac802154/cfg.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUb4S2AAoJEJctW/TcYTgGjYkQAJFZtFCq7BwK0TViJRDvc0xi
zO26PnxclQX+cBSrB0dsZO6PW3PlifeLKHVTPT6ZDiu1kRyDt5GbqP7lVomODip9
3TvESF6kCmer5HSgA5KDj6cmeKLgoL6OT9Sm/oLx5fUvgGFioRuaAt8up6OgNWdT
gOLJAFowFj34lScOCVMp6H3wfUVfgsWrlX+GbweKDx44sJsYLDJ399Gj21FFRjRf
YRgvK+aFobQ+OIhjLzN54mLQgNqWBP7zWZtQ6Q370luPimq4ZDppi8cipFx4GpyV
n8Ln+g+xqoaUEibBrDR4jmYINAb5204LEB5XvDdRFlmHRWijgYpZpsfM/YDWfUPN
txB+/XfnjE433GmqAXL9UKL8JKlHjnK6UDgzbCb/lftHkSLMbmW4qoVGuX+qNrLf
0wOTyzeE8W7ylLyYO8xtfIVtAauK83c8LC4gA2+rkfLpNQSTVZs6SBmD0h8/J34K
vaigWfchWWHg2+rwg9yf4NU/srIbuDcaXF5a9R4PFy/RBdGNmPFkv0l5TNURobsj
QpWS/Gq+o7gRg6Qwn1+ovYw0PBAYjtAM9BjJmfobvZPIbqK8dBw+sdPCLp74Jzfg
PWCcwR9AuzfLGi1ojQZk1MguO0l7iWquIOgQPe2DvrSuMRUIe2O1Hz4dU1ZjHPNI
KEE2T3XqUA/y7Fovn+f4
=v4My
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
