From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-06-24
Date: Fri, 24 Jun 2011 16:22:49 -0400
Message-ID: <20110624202249.GF4793@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a big batch of updates intended for 3.1.  This batch got a bit
bigger than I would have liked -- I guess I let the Bluetooth, ath9k,
and b43 stuff sneak up on me...

Anyway, this is more-or-less the usual stuff -- lots of driver updates,
etc.  The usual suspects like iwlagn and ath9k have a lot of activity,
as do b43, zd1211rw, rtlwifi, and a few others.  The Bluetooth folks
are makign a strong showing as well.

Please let me know if there are problems!

Thanks,

John

---
The following changes since commit 22c8c9343258feda9ea9ebb9e5f8cbb727b6=
9454:

  qlcnic: multi protocol internal loopback support added. (2011-06-24 0=
1:17:07 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Amitkumar Karwar (2):
      mwifiex: get rid of global adapter pointer
      mwifiex: remove casts of void pointers

Anderson Briglia (7):
      Bluetooth: Add advertising report meta event structs
      Bluetooth: Implement the first SMP commands
      Bluetooth: Start SMP procedure
      Bluetooth: Add simple SMP pairing negotiation
      Bluetooth: Add LE SMP Cryptoolbox functions
      Bluetooth: Add SMP confirmation structs
      Bluetooth: Add SMP confirmation checks methods

Anderson Lizardo (1):
      Bluetooth: fix missing parameter for HCI_OP_DISCONNECT

Andre Guedes (8):
      Bluetooth: LE advertising cache
      Bluetooth: Add Advertising Report Meta Event handler
      Bluetooth: Clear advertising cache before scanning
      Bluetooth: Advertising entries lifetime
      Bluetooth: Add 'dst_type' field to struct hci_conn
      Bluetooth: Remove useless check in hci_connect()
      Bluetooth: Check advertising cache in hci_connect()
      Bluetooth: Set 'peer_addr_type' in hci_le_connect()

Antti Julku (2):
      Bluetooth: Move blacklisting functions to hci_core
      Bluetooth: Add blacklisting support for mgmt interface

Arend van Spriel (1):
      drivers: bcma: export bcma_core_disable() function

Connor Hansen (1):
      drivers/ssb/driver_chipcommon_pmu.c: uninitilized warning

Dan Carpenter (2):
      b43: check for allocation failures
      iwlegacy: fix up brokenness caused by cleanup

Daniel Drake (1):
      libertas: add sd8686 reset_card support

David Miller (3):
      Bluetooth: Kill set but not used variable 'l2cap_sk' in rfcomm_so=
ck_getsockopt_old()
      Bluetooth: Do not ignore errors returned from strict_strtol()
      Bluetooth: Kill set but unused variable 'cmd' in cmtp_recv_capims=
g()

Eliad Peller (3):
      mac80211: add ieee80211_get_operstate() function
      mac80211: add cancel_hw_scan() callback
      mac80211: quiesce vif before suspending

Emmanuel Grumbach (15):
      iwlagn: don't disable interrupts after the NIC has been reset
      iwlagn: add a iwl_pci.[ch] files that will contain all PCI specif=
ic code
      iwlagn: remove uneeded include to pci.h and dma_mapping.h from a =
few files
      iwlagn: introduce iwl_bus and iwl_bus_ops
      iwlagn: add get_dev to iwl_bus_ops
      iwlagn: move PCI related operations from probe and remove to PCI =
layer
      iwlagn: don't use the PCI wrappers for DMA operation
      iwlagn: add a method to get the HW ID description as a string to =
iwl_bus_ops
      iwlagn: don't read the PCI_REVISION_ID from iwl-agn.c
      iwlagn: add a get_irq method to iwl_bus_ops and use it
      iwlagn: finally kill the pointer to pci_dev from iwl-dev.h
      iwlagn: waterfall the bus level if prepare card failed
      iwlagn: fix misplaced bracket
      iwlagn: warn about nested SYNC commands
      iwlagn: store the irq number to iwl_bus just like dev

Gabor Juhos (32):
      ath9k: define mac version for AR9330
      ath9k: define device id for AR9330
      ath9k: add MAC revision detection for AR9330
      ath9k: add platform device id for AR9330
      ath9k: add AR9330 initvals
      ath9k: initialize mode registers for AR9330
      ath9k: initialize tx gain table for AR9330
      ath9k: initialize rx gain table for AR9330
      ath9k: add AR9330 specific PLL initialization
      ath9k: use different BB watchdog timeout value for AR9330
      ath9k: don't enable LDPC for AR9330
      ath9k: read spur frequency information from eeprom for AR9330
      ath9k: fix channel frequency calculation for AR9340
      ath9k: configure RF channel frequency for AR9330
      ath9k: enable TX/RX data byte swap for AR9330
      ath9k: skip internal regulator configuration for AR9330
      ath9k: enable tuning capacitance configuration for AR9330
      ath9k: use correct EEPROM base for AR9330
      ath9k: configure xpa bias level for AR9330
      ath9k: set NF limits for AR9330
      ath9k: enable antenna diversity for AR9330
      ath9k: use correct max_streams for AR9330
      ath9k: add a missing case statement to ath_ant_div_comb_alt_check
      ath9k: fix antenna diversity configuration for non AR9485 chips
      ath9k: remove superfluous parentheses
      ath9k: add fast_div_bias configuration for diversity group 1
      ath9k: set diversity group for AR9330
      ath9k: fix few register offsets for AR9330
      ath9k: configure diversity based on eeprom contents for AR9330
      ath9k: configure internal regulator for AR9330
      ath9k: add external_reset callback to ath9k_platfom_data for AR93=
30
      ath9k: enable support for AR9330

Gustavo F. Padovan (21):
      Bluetooth: fix set but not used warning
      Bluetooth: Create __l2cap_chan_close()
      Bluetooth: Create l2cap_chan_send()
      Bluetooth: Add chan->chan_type struct member
      Bluetooth: create channel timer to replace sk_timer
      Bluetooth: Remove export of l2cap_chan_clear_timer()
      Bluetooth: Rename __l2cap_chan_close() to l2cap_chan_close()
      Merge master.kernel.org:/.../padovan/bluetooth-2.6
      Bluetooth: Merge l2cap_chan_create() in the l2cap_sock_alloc()
      Bluetooth: Add l2cap_chan_ops abstraction
      Bluetooth: add recv() callback to l2cap_chan_ops
      Bluetooth: add close() callback to l2cap_chan_ops
      Bluetooth: Add state tracking to struct l2cap_chan
      Bluetooth: Add refcnt to struct l2cap_chan
      Bluetooth: Make timer functions generic
      Bluetooth: keep reference if any ERTM timer is enabled
      Bluetooth: Don't forget to check for LE_LINK
      Bluetooth: use bit operation on conf_state
      Bluetooth: Use bit operations on conn_state
      Bluetooth: Fix locking in blacklist code
      Merge master.kernel.org:/.../padovan/bluetooth-2.6

Hauke Mehrtens (1):
      ssb: add __devinit to some functions

Ilia Kolomisnky (1):
      Bluetooth: Fix L2CAP connection establishment

Jaikumar Ganesh (1):
      Bluetooth: Add BT_POWER L2CAP socket option.

Johan Hedberg (2):
      Bluetooth: Remove unnecessary use of hci_dev_list_lock
      Bluetooth: Fix accepting connect requests for defer_setup

Johannes Berg (4):
      Bluetooth: fix sparse & gcc warnings
      iwlagn: don't check ucode subtype
      netlink: advertise incomplete dumps
      nl80211: use netlink consistent dump feature for BSS dumps

John W. Linville (5):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      ath5k: free sc->ah in ath5k_deinit_softc
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth=
-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jussi Kivilinna (6):
      zd1211rw: fix invalid signal values from device
      zd1211rw: make 'handle_rx_packet: invalid, small RX packet' messa=
ge debug-only
      zd1211rw: only update HW beacon if new beacon differs from currec=
t
      zd1211rw: handle lost read-reg interrupts
      zd1211rw: don't let zd_mac_config_beacon() run too long from beac=
on interrupt handler
      zd1211rw: detect stalled beacon interrupt faster

Kalle Valo (4):
      iwlegacy: fix stop/wake queue hacks
      iwlwifi: fix stop/wake queue hacks
      zd1211rw: include mac80211.h from zd_chip.h
      rtlwifi: include mac80211.h from core.h

Larry Finger (1):
      rtlwifi: Fix warnings on parisc arch

Luiz Augusto von Dentz (2):
      Bluetooth: fix shutdown on SCO sockets
      Bluetooth: Fix L2CAP security check

Mat Martineau (2):
      Bluetooth: Restore accidentally-deleted line
      Bluetooth: Fix check for the ERTM local busy state

Mike McCormack (7):
      rtlwifi: Remove unnecessary indent
      rtlwifi: Resubmit skbs with bad CRC early
      rtlwifi: Free skb in one place
      rtlwifi: Factor out code to receive one packet
      rtlwifi: Fix typo in variable name
      rtlwifi: rtl8192cu: Remove unused parameter
      rtlwifi: rtl8192{c,ce,cu,se}: Remove comparisons of booleans with=
 true

Mohammed Shafi Shajakhan (5):
      ath9k: Add debug messages to track PAPRD failures
      ath9k: remove a redundant call to pcipowersave
      ath9k: Fix a corner case failure in sending PAPRD frames in HT40
      ath9k_hw: make sure PAPRD training is properly done
      ath9k_hw: Fix calculation of PAPRD training power at 5Ghz

Nikanth Karthikesan (1):
      if_spi: Fix compilation warning - unused variable

Paul Stewart (2):
      cfg80211: Ignore downstream DEAUTH for authtry_bsses
      mac80211: Start monitor work on restart

Pavel Roskin (5):
      ath9k: use standard max(), remove A_MAX macro
      ath9k: typo fix in a comment
      ath5k: minor cleanup
      ath5k: annotate reg in ath5k_hw_nic_reset() as __iomem
      ath5k: add missing ieee80211_free_hw() on unload in AHB code

Rafa=C5=82 Mi=C5=82ecki (16):
      b43: define new PHYs and radio regs for cores >=3D 24
      b43: HT-PHY: add place for writing HT PHY support
      b43: add Kconfig option for compiling SSB driver
      b43: HT-PHY: implement radio ops
      b43: HT-PHY: implement switching analog
      bcma: enable support for 14e4:4357 (BCM43225)
      bcma: fix BCM43224 rev 0 workaround
      bcma: clean exports of functions
      b43: HT-PHY: implement killing radio
      b43: HT-PHY: enable radio
      b43: HT-PHY: define standard structs for channel switching
      b43: HT-PHY: add place for implementing channel switching
      b43: HT-PHY: switch radio to requested channel
      b43: N-PHY: update switching analog on/off
      b43: N-PHY: move declarations of chantables functions to correct =
files
      b43: HT-PHY: calibrate radio after switching channel

Ruiyi Zhang (1):
      Bluetooth: Allow unsegmented SDU retries on sock_queue_rcv_skb fa=
ilure

Stanislaw Gruszka (8):
      iwlegacy: remove unused power commands defines
      iwlegacy: remove recover from statistics
      iwlegacy: remove reset rf infrastructure
      iwlegacy: remove firmware event log
      iwlegacy: remove unused agg_tids_count
      iwlegacy: refactor iwl4965_mac_channel_switch
      rt2x00: fix possible memory corruption in case of invalid rxdesc.=
size
      rt2x00: reset usb devices at probe

Stephen Boyd (1):
      Bluetooth: Silence DEBUG_STRICT_USER_COPY_CHECKS=3Dy warning

Stephen Rothwell (1):
      Bluetooth: include scatterlist.h where needed

Ville Tervo (1):
      Bluetooth: Do not send SET_EVENT_MASK for 1.1 and earlier devices

Vincent Zweije (1):
      networking: fix warning about unused label wake_up

Vinicius Costa Gomes (13):
      Bluetooth: Add support for using the crypto subsystem
      Bluetooth: Add support for LE Start Encryption
      Bluetooth: Remove debug statements
      Bluetooth: Add support for resuming socket when SMP is finished
      Bluetooth: Fix initial security level of LE links
      Bluetooth: Update the security level when link is encrypted
      Bluetooth: Add support for building pairing commands
      Bluetooth: Add support for Pairing features exchange
      Bluetooth: Add support for SMP timeout
      Bluetooth: Add key size checks for SMP
      Bluetooth: Fix crash when setting a LE socket to ready
      Bluetooth: Remove useless access to the socket
      Bluetooth: Fix not setting the chan state

Waldemar Rymarkiewicz (6):
      Bluetooth: Fix auth_complete_evt for legacy units
      Bluetooth: Refactor hci_auth_complete_evt function
      Bluetooth: Remove a magic number
      Bluetooth: Verify a pin code in pin_code_reply
      Bluetooth: Simplify hci_conn_accept_secure check
      Bluetooth: Clean up some code style issues

Wey-Yi Guy (27):
      iwlagn: usersapce application decide the size of trace buffer
      iwlagn: add dumpit support for testmode trace function
      iwlagn: move bt_coex_active as part of iwlagn_mod_params
      iwlagn: move led_mode as part of iwlagn_mod_params
      iwlagn: move no_sleep_autoadjust as part of iwlagn_mod_params
      iwlagn: Band capabilities in EEPROM
      iwlagn: use sku capabilities information from EEPROM
      iwlagn: add coex debug flag
      iwlagn: add debug message for coex related activities
      iwlagn: use IWL_DEBUG_TEMP for temperature related debug
      iwlagn: use IWL_DEBUG_FW for firmware related debug msg
      iwlagn: remove unused debug flag
      iwlagn: generic temperature location in EEPROM
      iwlagn: group similar defines together
      iwlagn: merge duplicated code into single place
      iwlagn: Sanity check for 11n capability
      iwlagn: Sanity check for valid context
      iwlagn: Remove un-necessary indirect call
      iwlagn: add PAN to tx flush
      iwlagn: Support flush queues for specified interface
      iwlagn: move PCI power related functions to the PCI layer
      iwlagn: add power_save module parameter
      iwlagn: Add power_level module parameter
      iwlagn: add offset define for subsystem id
      iwlagn: code alignment
      iwlagn: merge duplicate code into single function
      iwlagn: remove incorrect define

 drivers/bcma/bcma_private.h                        |    4 +-
 drivers/bcma/core.c                                |    3 +-
 drivers/bcma/driver_chipcommon_pmu.c               |    6 +-
 drivers/bcma/driver_pci.c                          |    1 +
 drivers/bcma/host_pci.c                            |    1 +
 drivers/bcma/main.c                                |    2 -
 drivers/net/b44.c                                  |    4 +-
 drivers/net/wireless/ath/ath5k/ahb.c               |    1 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |    7 +-
 drivers/net/wireless/ath/ath5k/base.c              |   15 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    6 +-
 drivers/net/wireless/ath/ath5k/reset.c             |    6 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |    4 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   39 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  182 +++-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   39 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   41 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    6 +-
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   | 1147 ++++++++++++=
++++++++
 .../net/wireless/ath/ath9k/ar9330_1p2_initvals.h   | 1080 ++++++++++++=
++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   96 ++-
 drivers/net/wireless/ath/ath9k/hw.h                |    8 +-
 drivers/net/wireless/ath/ath9k/init.c              |    4 +-
 drivers/net/wireless/ath/ath9k/main.c              |   16 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    6 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  146 ++-
 drivers/net/wireless/ath/ath9k/reg.h               |   16 +
 drivers/net/wireless/b43/Kconfig                   |   13 +
 drivers/net/wireless/b43/Makefile                  |    2 +
 drivers/net/wireless/b43/b43.h                     |    6 +
 drivers/net/wireless/b43/bus.c                     |    9 +-
 drivers/net/wireless/b43/main.c                    |   37 +-
 drivers/net/wireless/b43/phy_common.c              |    6 +
 drivers/net/wireless/b43/phy_common.h              |    3 +
 drivers/net/wireless/b43/phy_ht.c                  |  274 +++++
 drivers/net/wireless/b43/phy_ht.h                  |   34 +
 drivers/net/wireless/b43/phy_n.c                   |   21 +-
 drivers/net/wireless/b43/radio_2055.h              |    5 +
 drivers/net/wireless/b43/radio_2056.h              |    5 +
 drivers/net/wireless/b43/radio_2059.c              |   30 +
 drivers/net/wireless/b43/radio_2059.h              |   49 +
 drivers/net/wireless/b43/sdio.c                    |    6 +-
 drivers/net/wireless/b43/tables_nphy.h             |    8 -
 drivers/net/wireless/iwlegacy/iwl-3945.c           |    4 -
 drivers/net/wireless/iwlegacy/iwl-4965-lib.c       |   79 +--
 drivers/net/wireless/iwlegacy/iwl-4965-rx.c        |   78 +--
 drivers/net/wireless/iwlegacy/iwl-4965.c           |    4 -
 drivers/net/wireless/iwlegacy/iwl-commands.h       |    7 -
 drivers/net/wireless/iwlegacy/iwl-core.c           |   91 +-
 drivers/net/wireless/iwlegacy/iwl-core.h           |   15 +-
 drivers/net/wireless/iwlegacy/iwl-debugfs.c        |  192 +---
 drivers/net/wireless/iwlegacy/iwl-dev.h            |   60 +-
 drivers/net/wireless/iwlegacy/iwl-devtrace.c       |    3 -
 drivers/net/wireless/iwlegacy/iwl-devtrace.h       |   60 -
 drivers/net/wireless/iwlegacy/iwl-helpers.h        |    9 +
 drivers/net/wireless/iwlegacy/iwl-rx.c             |   21 -
 drivers/net/wireless/iwlegacy/iwl-scan.c           |   92 +--
 drivers/net/wireless/iwlegacy/iwl3945-base.c       |  301 +-----
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |  463 +-------
 drivers/net/wireless/iwlwifi/Makefile              |    1 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    4 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   20 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   22 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |    7 -
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   75 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |   38 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   30 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |   45 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  541 +++-------
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   26 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   35 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   85 +--
 drivers/net/wireless/iwlwifi/iwl-core.h            |   47 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   18 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    7 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   60 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   25 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   25 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |    9 +
 drivers/net/wireless/iwlwifi/iwl-io.h              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |   14 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c             |  571 ++++++++++
 drivers/net/wireless/iwlwifi/iwl-pci.h             |   69 ++
 drivers/net/wireless/iwlwifi/iwl-power.c           |   33 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c         |  139 ++-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   33 +-
 drivers/net/wireless/libertas/if_sdio.c            |   34 +
 drivers/net/wireless/libertas/if_spi.c             |    6 +-
 drivers/net/wireless/mwifiex/11n.c                 |   33 +-
 drivers/net/wireless/mwifiex/11n.h                 |   14 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |    5 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |    5 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   28 +-
 drivers/net/wireless/mwifiex/join.c                |   23 +-
 drivers/net/wireless/mwifiex/main.c                |   18 +-
 drivers/net/wireless/mwifiex/main.h                |   17 +-
 drivers/net/wireless/mwifiex/scan.c                |    6 +-
 drivers/net/wireless/mwifiex/sdio.c                |   81 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |  101 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   69 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |    2 +-
 drivers/net/wireless/mwifiex/txrx.c                |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   13 +
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    1 +
 drivers/net/wireless/rtlwifi/base.c                |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |   12 +-
 drivers/net/wireless/rtlwifi/core.h                |    2 +
 drivers/net/wireless/rtlwifi/efuse.c               |    8 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  206 ++--
 drivers/net/wireless/rtlwifi/ps.c                  |   65 +-
 drivers/net/wireless/rtlwifi/ps.h                  |    3 +-
 drivers/net/wireless/rtlwifi/rc.c                  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/led.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192se/led.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/reg.h       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    6 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.h            |    2 +
 drivers/net/wireless/zd1211rw/zd_def.h             |    6 +
 drivers/net/wireless/zd1211rw/zd_mac.c             |  118 ++-
 drivers/net/wireless/zd1211rw/zd_mac.h             |    1 +
 drivers/net/wireless/zd1211rw/zd_usb.c             |  129 ++-
 drivers/net/wireless/zd1211rw/zd_usb.h             |    5 +-
 drivers/ssb/driver_chipcommon_pmu.c                |    4 +-
 drivers/ssb/driver_gige.c                          |   13 +-
 drivers/ssb/driver_pcicore.c                       |   10 +-
 drivers/ssb/main.c                                 |   29 +-
 drivers/ssb/pcihost_wrapper.c                      |    6 +-
 include/linux/ath9k_platform.h                     |    2 +
 include/linux/bcma/bcma.h                          |    1 +
 include/linux/bcma/bcma_driver_pci.h               |    2 +
 include/linux/netlink.h                            |    2 +
 include/net/bluetooth/bluetooth.h                  |   15 +-
 include/net/bluetooth/hci.h                        |   59 +
 include/net/bluetooth/hci_core.h                   |   68 +-
 include/net/bluetooth/l2cap.h                      |  117 ++-
 include/net/bluetooth/mgmt.h                       |   10 +
 include/net/bluetooth/rfcomm.h                     |    9 +-
 include/net/bluetooth/smp.h                        |   46 +
 include/net/genetlink.h                            |   32 +
 include/net/mac80211.h                             |   20 +
 include/net/netlink.h                              |   24 +
 net/bluetooth/Kconfig                              |    8 +
 net/bluetooth/Makefile                             |    2 +-
 net/bluetooth/cmtp/capi.c                          |    3 +-
 net/bluetooth/hci_conn.c                           |   85 ++-
 net/bluetooth/hci_core.c                           |  195 ++++-
 net/bluetooth/hci_event.c                          |  206 +++-
 net/bluetooth/hci_sock.c                           |   70 +--
 net/bluetooth/l2cap_core.c                         |  885 ++++++++++--=
----
 net/bluetooth/l2cap_sock.c                         |  375 +++----
 net/bluetooth/mgmt.c                               |  133 ++-
 net/bluetooth/rfcomm/sock.c                        |    6 +-
 net/bluetooth/smp.c                                |  534 +++++++++
 net/mac80211/driver-ops.h                          |   10 +
 net/mac80211/driver-trace.h                        |    6 +
 net/mac80211/mlme.c                                |    8 +
 net/mac80211/pm.c                                  |   43 +-
 net/mac80211/scan.c                                |   37 +-
 net/mac80211/util.c                                |    2 +
 net/netlink/af_netlink.c                           |    2 +
 net/wireless/mlme.c                                |    4 +-
 net/wireless/nl80211.c                             |   12 +-
 185 files changed, 7520 insertions(+), 3614 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9330_1p1_initvals.=
h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9330_1p2_initvals.=
h
 create mode 100644 drivers/net/wireless/b43/phy_ht.c
 create mode 100644 drivers/net/wireless/b43/phy_ht.h
 create mode 100644 drivers/net/wireless/b43/radio_2059.c
 create mode 100644 drivers/net/wireless/b43/radio_2059.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-pci.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-pci.h
 create mode 100644 net/bluetooth/smp.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-06-24.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
