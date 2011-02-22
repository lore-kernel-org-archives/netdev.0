From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-02-22
Date: Tue, 22 Feb 2011 16:52:30 -0500
Message-ID: <20110222215229.GJ12153@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58113 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab1BVWAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 17:00:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest batch of wireless bits intended for 2.6.39.  It seem=
s
I neglected to send a pull request last week, so this one is a bit big
-- I apologize!

This includes a rather large batch of bluetooth bits by way of Gustavo.
It looks like a variety of bits, including some code refactoring, some
protocol support enhancements, some bugfixes, etc. -- nothing too
unusual.

Other items of interest include a new driver from Realtek, some ssb
support enhancements, and the usual sort of updates for mac80211 and a
variety of drivers.  Also included is a wireless-2.6 pull to resolve
some build breakage.

Please let me know if there are problems!

John

---

The following changes since commit db62983a1e4b2af9e79c97af768f0c8b80bd=
93f0:

  Merge branch 'net/ax88796' of git://git.pengutronix.de/git/mkl/linux-=
2.6 (2011-02-22 11:15:29 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Andrei Emeltchenko (3):
      Bluetooth: Use non-flushable by default L2CAP data packets
      Bluetooth: Do not use assignments in IF conditions
      Bluetooth: fix crash by disabling tasklet in sock accept

Andrei Warkentin (1):
      Bluetooth: Make hci a child of the corresponding tty device.

Bala Shanmugam (1):
      Bluetooth: Add firmware support for Atheros 3012

Ben Greear (7):
      ath9k: Print channel-type in chan-change dbg message.
      mac80211: Properly set work-item channel-type.
      mac80211: Allow scanning on existing channel-type.
      mac80211: Allow work items to use existing channel type.
      ath9k: Add debug info for configuring power level.
      mac80211: Ensure power-level set properly for scanning.
      mac80211: Add power to debugfs.

Bob Copeland (1):
      ath5k: move external function definitions to a header file

Cho, Yu-Chen (1):
      Bluetooth: Add Atheros BT AR5BBU12 fw supported

Christian Lamparter (6):
      p54: sort channel list by frequency instead of channel index
      p54: p54_generate_band cleanup
      p54: enhance rssi->dBm database import
      p54spi: update sample eeprom
      p54: implement flush callback
      ar9170usb: mark the old driver as obsolete

Claudio Takahasi (3):
      Bluetooth: Add LE signaling commands handling
      Bluetooth: Add connection parameter update response
      Bluetooth: Send LE Connection Update Command

Eliad Peller (4):
      wl12xx: mcp2.5 - add config_ps acx
      wl12xx: move to new firmware (6.1.3.50.49)
      wl12xx: use the conf struct instead of macros for memory configur=
ation
      wl12xx: set supported_rates after association

George (9):
      rtlwifi: Add usb driver
      rtlwifi: Add headers for rtl8187cu
      rtlwifi: rtl8192cu: Add routines dm, fw, led and sw
      rtlwifi: rtl8192cu: Add routine hw
      rtlwifi: rtl8192cu: Add routine mac
      rtlwifi: rtl8192cu: Add routine phy
      rtlwifi: rtl8192cu: Add routine rf
      rtlwifi: rtl8192cu: Add routine table
      rtlwifi: rtl8192cu: Add routine trx

Gustavo F. Padovan (27):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-2.6 into wireless
      Bluetooth: Fix setting of MTU for ERTM and Streaming Mode
      Bluetooth: Rename l2cap.c to l2cap_core.c
      Bluetooth: Initial work for L2CAP split.
      Bluetooth: move l2cap_sock_ops to l2cap_sock.c
      Bluetooth: move l2cap_sock_release() to l2cap_sock.c
      Bluetooth: move l2cap_sock_bind()/listen() to l2cap_sock.c
      Bluetooth: move l2cap_sock_accept() to l2cap_sock.c
      Bluetooth: move l2cap_sock_getname() to l2cap_sock.c
      Bluetooth: move l2cap_sock_setsockopt() to l2cap_sock.c
      Bluetooth: move l2cap_sock_getsockopt() to l2cap_sock.c
      Bluetooth: move l2cap_sock_connect() to l2cap_sock.c
      Bluetooth: move l2cap_sock_recvmsg() to l2cap_sock.c
      Bluetooth: move l2cap_sock_shutdown() to l2cap_sock.c
      Bluetooth: move l2cap_sock_sendmsg() to l2cap_sock.c
      Bluetooth: move L2CAP sock timers function to l2cap_sock.c
      Bluetooth: move l2cap_sock_kill() to l2cap_sock.c
      Bluetooth: move __l2cap_sock_close() to l2cap_sock.c
      Bluetooth: update Bluetooth daemon name in Kconfig help
      Bluetooth: Merge L2CAP and SCO modules into bluetooth.ko
      Bluetooth: remove l2cap_load() hack
      Bluetooth: Add L2CAP mode to debugfs output
      Bluetooth: Use usb_fill_int_urb()
      Bluetooth: Fix crash when ioctl(HCIUARTSETPROTO) fails
      Bluetooth: fix errors reported by checkpatch.pl
      Bluetooth: Fix errors reported by checkpatch.pl
      Bluetooth: fix checkpatch errors in af_bluetooth.c

Helmut Schaa (4):
      mac80211: Remove superfluous if clause
      rt2x00: Minor optimization for devices with RTS/CTS offload
      Revert "rt2x00 : avoid timestamp for monitor injected frame."
      rt2x00: Remove superfluos empty line

Henry Ptasinski (1):
      wireless-next-2.6: brcm80211: fix compile issue

Jan Beulich (1):
      small adjustment to net/mac80211/Kconfig

Jesper Juhl (1):
      Bluetooth: Fix failure to release lock in read_index_list()

Johan Hedberg (25):
      Bluetooth: Implement automatic setup procedure for local adapters
      Bluetooth: Add support for management powered event
      Bluetooth: Add support for set_powered management command
      Bluetooth: Add support for set_discoverable management command
      Bluetooth: Add set_connectable management command
      Bluetooth: Unify mode related management messages to a single str=
uct
      Bluetooth: Add flag to track managment controlled adapters
      Bluetooth: Add send_mode_rsp convenience function for mgmt.c
      Bluetooth: Implement set_pairable managment command
      Bluetooth: Implement UUID handling through the management interfa=
ce
      Bluetooth: Implement debugfs support for listing UUIDs
      Bluetooth: Reject pairing requests when in non-pairable mode
      Bluetooth: Add special handling with __hci_request and HCI_INIT
      Bluetooth: Add controller side link key clearing to hci_init_req
      Bluetooth: Remove page timeout setting from HCI init sequence
      Bluetooth: Implement a more complete adapter initialization seque=
nce
      Bluetooth: Add class of device control to the management interfac=
e
      Bluetooth: Implement link key handling for the management interfa=
ce
      Bluetooth: Add connected/disconnected management events
      Bluetooth: Add disconnect managment command
      Bluetooth: Add support for connect failed management event
      Bluetooth: Add get_connections managment interface command
      Bluetooth: Create common cmd_complete function for mgmt.c
      Bluetooth: Add support for PIN code handling in the management in=
terface
      Bluetooth: Add set_io_capability management command

Johannes Berg (2):
      mac80211: reply to directed probes in IBSS
      mac80211: fix 2.4 GHz 40 MHz disabling

John W. Linville (5):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-2.6
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-next-2.6
      Merge ssh://master.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jussi Kivilinna (4):
      zd1211rw: correct use of usb_bulk_msg on interrupt endpoints
      zd1211rw: use async urb for write command
      zd1211rw: move async iowrite16v up to callers
      zd1211rw: add unlikely to ZD_ASSERT

Larry Finger (13):
      rtlwifi: Modify core routines
      rtlwifi: rtl8192ce: Refactor rtl8192ce/dm
      rtlwifi: rtl8192ce: Refactor rtl8192ce/fw
      rtlwifi: rtl8192ce: Rework rtl8192ce/phy.c
      p54: Fix compile warning
      rtlwifi: Make changes in rtlwifi/rtl8192ce/reg.h to support rtl81=
92cu
      rtlwifi: Make changes in rtlwifi/rtl8192ce/def.h to support rtl81=
92cu
      rtlwifi: Modify some rtl8192ce routines for merging rtl8192cu
      rtlwifi: Modify wifi.h for rtl8192cu
      rtlwifi: Move common parts of rtl8192ce/phy.c
      rtlwifi: Modify build system for rtl8192cu
      rtlwifi: rtl8192ce: Fix endian warnings
      rtlwifi: Remove obsolete/unused macros

Michael Buesch (1):
      ssb: Make ssb_wait_bit multi-bit safe

Mohammed Shafi Shajakhan (1):
      ath9k: Fix ath9k prevents CPU to enter C3 states

Nikolay Ledovskikh (1):
      ath5k: Correct channel setting for AR2317 chip

Oliver Neukum (1):
      Bluetooth: fix crash with quirky dongles doing sound

RA-Jay Hung (2):
      rt2x00: Add antenna setting for RT3070/RT3090/RT3390 with RX ante=
nna diversity support
      rt2x00: Fix rt2800 txpower setting to correct value

RA-Shiang Tu (1):
      rt2x00: Add support for RT5390 chip

Rafa=C5=82 Mi=C5=82ecki (5):
      ssb: extract boardflags2 for SPROMs rev 4 and 5
      ssb: trivial: fix SPROM extract warning formatting
      ssb: remove invalid define SSB_TMSLOW_PHYCLK
      ssb: when needed, reject IM input while disabling device
      ssb: reset device only if it was enabled

Rajkumar Manoharan (1):
      ath9k: disable beaconing before stopping beacon queue

Randy Dunlap (1):
      wl12xx: fix sdio_test kconfig/build errors

Rog=C3=A9rio Brito (1):
      Bluetooth: ath3k: Avoid duplication of code

Seth Forshee (1):
      rt2x00: Check for errors from skb_pad() calls

Shiang Tu (2):
      rt2x00: Add/Modify protection related register definitions
      rt2x00: Add/Modify the GPIO register definition

Stanislaw Gruszka (4):
      iwlwifi: cleanup iwl_recover_from_statistics
      iwlwifi: cleanup iwl_good_ack_health
      iwlwifi: fix ack health for WiFi/BT combo devices
      mac80211: fix conn_mon_timer running after disassociate

Steve Brown (1):
      ath9k: Remove redundant beacon_interval

Sujith Manoharan (1):
      ath9k_hw: Fix power on reset

Szymon Janc (5):
      Bluetooth: Use #include <linux/uaccess.h> instead of <asm/uaccess=
=2Eh>
      Bluetooth: Clean up hci_sniff_subrate_evt function
      Bluetooth: Fix some code style issues in hci_core.h
      Bluetooth: Fix some code style issues in hci_core.c
      Bluetooth: Fix some code style issues in hci_event.c

Vasanthakumar Thiagarajan (1):
      ath9k: Implement op_flush()

Vasiliy Kulikov (3):
      Bluetooth: l2cap: fix 1 byte infoleak to userspace
      Bluetooth: bnep: fix buffer overflow
      Bluetooth: sco: fix information leak to userspace

Ville Tervo (9):
      Bluetooth: Add low energy commands and events
      Bluetooth: Add LE connect support
      Bluetooth: Use LE buffers for LE traffic
      Bluetooth: Add LE connection support to L2CAP
      Bluetooth: Add server socket support for LE connection
      Bluetooth: Do not send disconn comand over LE links
      Bluetooth: Treat LE and ACL links separately on timeout
      Bluetooth: Add SMP command structures
      Bluetooth: Use proper timer for hci command timout

Vinicius Costa Gomes (1):
      Bluetooth: Fix initiated LE connections

Vivek Natarajan (3):
      ath9k_htc: Fix a compilation warning.
      ath9k_hw: Updates for AR9485 1.1 chipsets.
      mac80211: Clear PS related flag on disabling power save.

Vladislav P (1):
      Bluetooth: Release BTM while sleeping to avoid deadlock

Wey-Yi Guy (2):
      iwlagn: donot process bt update when bt coex disable
      iwlagn: handle bt defer work in 2000 series

Wojciech Dubowik (1):
      ath5k: Enable AR2315 chipset recognition

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800pci.c: add two ids

 Documentation/feature-removal-schedule.txt         |   11 +
 MAINTAINERS                                        |    2 +-
 drivers/bluetooth/ath3k.c                          |  290 +++-
 drivers/bluetooth/btusb.c                          |   20 +-
 drivers/bluetooth/hci_ldisc.c                      |    1 +
 drivers/net/wireless/ath/ar9170/Kconfig            |    4 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   20 +
 drivers/net/wireless/ath/ath5k/attach.c            |    3 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   17 -
 drivers/net/wireless/ath/ath5k/phy.c               |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  112 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   | 1141 +++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |   13 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   43 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    1 -
 drivers/net/wireless/ath/ath9k/init.c              |    8 -
 drivers/net/wireless/ath/ath9k/main.c              |  124 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    4 +
 drivers/net/wireless/ath/ath9k/xmit.c              |   30 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   74 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   37 +-
 drivers/net/wireless/p54/eeprom.c                  |  208 ++-
 drivers/net/wireless/p54/eeprom.h                  |    7 +
 drivers/net/wireless/p54/fwio.c                    |   12 +-
 drivers/net/wireless/p54/lmac.h                    |    1 +
 drivers/net/wireless/p54/main.c                    |   47 +-
 drivers/net/wireless/p54/p54.h                     |    6 +-
 drivers/net/wireless/p54/p54spi_eeprom.h           |    9 +-
 drivers/net/wireless/p54/txrx.c                    |    6 +-
 drivers/net/wireless/rt2x00/Kconfig                |   12 +
 drivers/net/wireless/rt2x00/rt2800.h               |  129 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  747 +++++--
 drivers/net/wireless/rt2x00/rt2800pci.c            |   12 +
 drivers/net/wireless/rt2x00/rt2x00.h               |    4 +
 drivers/net/wireless/rt2x00/rt2x00ht.c             |    1 -
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    6 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    9 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   12 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   12 +-
 drivers/net/wireless/rtlwifi/Kconfig               |   17 +-
 drivers/net/wireless/rtlwifi/Makefile              |    6 +-
 drivers/net/wireless/rtlwifi/base.c                |   76 +-
 drivers/net/wireless/rtlwifi/base.h                |   39 +-
 drivers/net/wireless/rtlwifi/core.c                |   14 +-
 drivers/net/wireless/rtlwifi/debug.h               |    1 +
 drivers/net/wireless/rtlwifi/pci.c                 |  148 +-
 drivers/net/wireless/rtlwifi/pci.h                 |   12 +-
 drivers/net/wireless/rtlwifi/ps.c                  |   58 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  | 1388 +++++++++++
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c | 2049 ++++++++++++=
++++
 drivers/net/wireless/rtlwifi/rtl8192ce/Makefile    |    2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |  144 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        | 1361 +-----------
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/fw.c        |   59 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  153 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       | 2072 +-----------=
-----
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |   73 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.h        |    2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |  170 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |  464 ++--
 drivers/net/wireless/rtlwifi/rtl8192cu/Makefile    |   15 +
 drivers/net/wireless/rtlwifi/rtl8192cu/def.h       |   62 +
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |  116 +
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.h        |   32 +
 drivers/net/wireless/rtlwifi/rtl8192cu/fw.c        |   30 +
 drivers/net/wireless/rtlwifi/rtl8192cu/fw.h        |   30 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        | 2505 ++++++++++++=
++++++++
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |  107 +
 drivers/net/wireless/rtlwifi/rtl8192cu/led.c       |  142 ++
 drivers/net/wireless/rtlwifi/rtl8192cu/led.h       |   37 +
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       | 1144 +++++++++
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h       |  180 ++
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |  611 +++++
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.h       |   34 +
 drivers/net/wireless/rtlwifi/rtl8192cu/reg.h       |   30 +
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |  493 ++++
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h        |   30 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |  327 +++
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h        |   35 +
 drivers/net/wireless/rtlwifi/rtl8192cu/table.c     | 1888 ++++++++++++=
+++
 drivers/net/wireless/rtlwifi/rtl8192cu/table.h     |   71 +
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |  684 ++++++
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.h       |  430 ++++
 drivers/net/wireless/rtlwifi/usb.c                 | 1035 ++++++++
 drivers/net/wireless/rtlwifi/usb.h                 |  164 ++
 drivers/net/wireless/rtlwifi/wifi.h                |  667 ++++--
 drivers/net/wireless/wl12xx/Kconfig                |    2 +-
 drivers/net/wireless/wl12xx/acx.c                  |   86 +-
 drivers/net/wireless/wl12xx/acx.h                  |   41 +-
 drivers/net/wireless/wl12xx/cmd.c                  |   10 +-
 drivers/net/wireless/wl12xx/cmd.h                  |   14 +-
 drivers/net/wireless/wl12xx/conf.h                 |   49 +
 drivers/net/wireless/wl12xx/event.c                |   14 -
 drivers/net/wireless/wl12xx/event.h                |    2 -
 drivers/net/wireless/wl12xx/init.c                 |   13 +
 drivers/net/wireless/wl12xx/main.c                 |  143 +-
 drivers/net/wireless/wl12xx/ps.c                   |    6 +-
 drivers/net/wireless/wl12xx/rx.c                   |    6 +-
 drivers/net/wireless/wl12xx/rx.h                   |    2 +-
 drivers/net/wireless/wl12xx/tx.c                   |   22 -
 drivers/net/wireless/wl12xx/wl12xx.h               |   66 +-
 drivers/net/wireless/zd1211rw/zd_chip.c            |   35 +-
 drivers/net/wireless/zd1211rw/zd_def.h             |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |  177 ++-
 drivers/net/wireless/zd1211rw/zd_usb.h             |    9 +-
 drivers/ssb/main.c                                 |   44 +-
 drivers/ssb/pci.c                                  |    6 +-
 drivers/staging/brcm80211/brcmfmac/wl_cfg80211.c   |    4 +-
 include/linux/ssb/ssb_regs.h                       |    7 +-
 include/net/bluetooth/bluetooth.h                  |   33 +
 include/net/bluetooth/hci.h                        |  122 +
 include/net/bluetooth/hci_core.h                   |  152 +-
 include/net/bluetooth/l2cap.h                      |   53 +-
 include/net/bluetooth/mgmt.h                       |  142 ++
 include/net/bluetooth/smp.h                        |   76 +
 net/bluetooth/Kconfig                              |   16 +-
 net/bluetooth/Makefile                             |    4 +-
 net/bluetooth/af_bluetooth.c                       |   53 +-
 net/bluetooth/bnep/core.c                          |    2 -
 net/bluetooth/bnep/sock.c                          |    1 +
 net/bluetooth/cmtp/capi.c                          |    3 +-
 net/bluetooth/cmtp/core.c                          |   11 +-
 net/bluetooth/hci_conn.c                           |   78 +-
 net/bluetooth/hci_core.c                           |  345 +++-
 net/bluetooth/hci_event.c                          |  622 +++++-
 net/bluetooth/hci_sock.c                           |    6 +-
 net/bluetooth/hci_sysfs.c                          |   58 +-
 net/bluetooth/hidp/core.c                          |   11 +-
 net/bluetooth/{l2cap.c =3D> l2cap_core.c}            | 1722 ++++------=
----
 net/bluetooth/l2cap_sock.c                         | 1156 +++++++++
 net/bluetooth/mgmt.c                               | 1312 ++++++++++-
 net/bluetooth/rfcomm/core.c                        |    2 -
 net/bluetooth/rfcomm/tty.c                         |    2 +
 net/bluetooth/sco.c                                |   17 +-
 net/mac80211/Kconfig                               |    2 +-
 net/mac80211/cfg.c                                 |    1 +
 net/mac80211/debugfs.c                             |    6 +
 net/mac80211/ibss.c                                |   11 +-
 net/mac80211/ieee80211_i.h                         |    2 -
 net/mac80211/main.c                                |   33 +-
 net/mac80211/mlme.c                                |    8 +
 net/mac80211/rx.c                                  |   12 +-
 net/mac80211/scan.c                                |   15 +-
 net/mac80211/tx.c                                  |    1 +
 net/mac80211/util.c                                |    6 -
 net/mac80211/work.c                                |   59 +-
 153 files changed, 22844 insertions(+), 6512 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192cu/trx.h
 create mode 100644 drivers/net/wireless/rtlwifi/usb.c
 create mode 100644 drivers/net/wireless/rtlwifi/usb.h
 create mode 100644 include/net/bluetooth/smp.h
 rename net/bluetooth/{l2cap.c =3D> l2cap_core.c} (76%)
 create mode 100644 net/bluetooth/l2cap_sock.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-02-22.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
