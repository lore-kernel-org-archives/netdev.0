From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6.26 2008-02-29
Date: Fri, 29 Feb 2008 16:22:18 -0500
Message-ID: <20080229212218.GG3234@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3426 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612AbYB2VcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 16:32:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a ton of wireless patches intended for 2.6.26 -- too much to go
into details.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26=
/

---

The following changes since commit 5fbd7e24da874a1c7b06ae6b10bbf2d71c1b=
6a11:
  Matheos Worku (1):
        [NIU]: Add Support for Sun ATCA Blade Server.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.2=
6.git master

Adam Baker (2):
      rt2x00: don't write past the end when writing short descriptors o=
n rt61
      rt2x00: correct address calc for queue private data

Aurelien Jarno (1):
      ssb: Add CHIPCO IRQ access functions

Bruno Randolf (3):
      mac80211: better definition of mactime
      mac80211: move function ieee80211_sta_join_ibss()
      mac80211: enable IBSS merging

Christian Lamparter (1):
      p54: use IEEE 802.11e defaults for initialization

Daniel Drake (1):
      ipw2100/ipw2200: note firmware loading caveat in Kconfig help tex=
t

Emmanuel Grumbach (1):
      iwlwifi-2.6: Adds and fixes defines about security

=46lorian Fainelli (1):
      p54: print unknown eeprom fields

Gertjan van Wingerde (1):
      rt2x00: Fix hw mode registration with mac80211.

Holger Schurig (5):
      libertas: trim overly long debug statement
      libertas: make association debug output nicer
      libertas: make lbs_sync_channel() static
      libertas: make lbs_unset_basic_rate_flags() static
      libertas: rename/document scan_channel

Ivo van Doorn (43):
      rt2x00: Update copyright notice
      rt2x00: Queue handling overhaul
      rt2x00: Fix tx parameter initialization
      rt2x00: Enable master and adhoc mode again
      rt2x00: Driver requiring firmware should select crc algo
      rt2x00: Add per-interface structure
      rt2x00: Remove TX_MGMT queue usage
      rt2x00: Initialize QID from queue->qid
      rt2x00: Move beacon and atim queue defines into rt2x00
      rt2x00: Fix queue index handling
      wireless: Fix WARN_ON() with ieee802.11b
      rt2x00: Rate structure overhaul
      rt2x00: Remove HWMODE_{A,B,G}
      rt2x00: Use ieee80211_channel_to_frequency()
      rt2x00: Make use of MAC80211_LED_TRIGGERS
      rt2x00: Enable LED class support for rt2500usb/rt73usb
      rt2x00: Fix rate initialization
      rt2x00: Release rt2x00 2.1.0
      rt2x00: Fix invalid DMA free
      rt2x00: Make rt2x00 less verbose
      rt2x00: Remove MGMT ring initialization
      rt2x00: Select CONFIG_NEW_LEDS
      rt2x00: make csr_cache and csr_addr an union
      rt2x00: Fix scheduling while atomic errors in usb drivers
      rt2x00: Add queue statistics to debugfs
      rt2x00: Fix typo in debug statement
      rt2x00: Fix skbdesc->data_len initialization
      rt2x00: Fix queue->qid initialization
      rt2x00: Cleanup Makefile
      rt2x00: Kill guardian urb during disable_radio
      rt2x00: Release rt2x00 2.1.1
      rt2x00: Send frames out with configured TX power
      rt2x00: Don't report driver generated frames to tx_status()
      rt2x00: Filter ACK_CTS based on FIF_CONTROL
      rt2x00: Fix Descriptor DMA initialization
      rt2x00: Remove reset_tsf()
      rt2x00: Rename dscape -> mac80211
      rt2x00: Cleanup mode registration
      rt2x00: Remove async vendor request calls from rt2x00usb
      rt2x00: Fix MAC address defines in rt61pci
      rt2x00: Release rt2x00 2.1.2
      rt2x00: Check for 5GHz band in link tuner
      rt2x00: Release rt2x00 2.1.3

Javier Cardona (1):
      zd1211rw: Fixed incorrect constant name.

Jiri Slaby (1):
      WDEV: ath5k, typecheck on nonDEBUG

Johannes Berg (34):
      mac80211: allow sending multicast frames through virtual ports
      mac80211: dissolve pre-rx handlers
      cfg80211 API for channels/bitrates, mac80211 and driver conversio=
n
      nl80211: export hardware bitrate/channel capabilities
      mac80211: fix scan band off-by-one error
      mac80211: remove port control enable switch, clean up sta flags
      wireless: fix ERP rate flags
      mac80211: split ieee80211_txrx_result
      mac80211: split RX_DROP
      mac80211: clean up some things in the RX path
      mac80211: remove "dynamic" RX/TX handlers
      mac80211: move some code into ieee80211_invoke_rx_handlers
      mac80211: defer master netdev allocation to ieee80211_register_hw
      mac80211: give burst time in txop rather than 0.1msec units
      mac80211: fix ecw2cw brain-damage
      rtl818x: fix RTS/CTS-less transmit
      b43(legacy): include full timestamp in beacon frames
      mac80211: convert sta_info.pspoll to a flag
      mac80211: invoke set_tim() callback after setting own TIM info
      mac80211: remove sta TIM flag, fix expiry TIM handling
      mac80211: consolidate TIM handling code
      adm8211: fix sparse warnings
      p54: fix sparse warnings
      mac80211: rework TX filtered frame code
      mac80211: atomically check whether STA exists already
      mac80211: Disallow concurrent IBSS/STA mode interfaces
      mac80211: fix debugfs_sta print_mac() warning
      mac80211: fix IBSS code
      adm8211: fix cfg80211 band API conversion
      mac80211: clarify use of TX status/RX callbacks
      mac80211: safely free beacon in ieee80211_if_reinit
      mac80211: remove STA infos last_ack stuff
      mac80211: split ieee80211_key_alloc/free
      mac80211: fix key replacing, hw accel

Luis R. Rodriguez (7):
      ath5k: Port to new bitrate/channel API
      ath5k: Cleanup after API changes
      ath5k: ath5k_copy_channels() was not setting the channel band
      ath5k: Use our own Kconfig file, we'll be expanding this shortly
      ath5k: Port debug.c over to the new band API and enable as build =
option
      ath5k: Use software encryption for now
      ath5k/phy.c: fix negative array index

Marcin Slusarz (1):
      ipw2200: le*_add_cpu conversion

Matthias Kaehlcke (3):
      prism54: Convert acl->sem in a mutex
      prism54: Convert stats_sem in a mutex
      prism54: Convert wpa_sem in a mutex

Michael Buesch (6):
      b43: Fix bandswitch
      mac80211: Extend filter flag documentation about unsupported flag=
s
      b43: Add HostFlags HI support
      zd1211rw: Fix beacon filter flags thinko
      ssb: Add support for 8bit register access
      b43legacy: Fix nondebug build

Michael Wu (3):
      nl80211: Add monitor interface configuration flags
      mac80211: Use monitor configuration flags
      mac80211: Add cooked monitor mode support

Mohamed Abbas (2):
      iwlwifi: initialize ieee80211_channel->hw_value
      iwlwifi: set rate_idx correctly from plcp

Pavel Roskin (2):
      mac80211: fix incorrect use of CONFIG_MAC80211_IBSS_DEBUG
      ath5k: fix all endian issues reported by sparse

Randy Dunlap (1):
      wireless: rt2x00: fix driver menu indenting

Reinette Chatre (2):
      iwlwifi: Update iwlwifi version stamp to 1.2.26
      iwlwifi: fix name of function in comment (_rx_card_state_notif)

Roel Kluin (2):
      wireless/iwlwifi/iwl-4965.c: add parentheses
      wireless: Convert to list_for_each_entry_rcu()

Ron Rindjunsky (14):
      mac80211: A-MPDU Tx add session's and low level driver's API
      mac80211: A-MPDU Tx add MLME structures
      mac80211: A-MPDU Tx adding basic functionality
      mac80211: A-MPDU Tx adding qdisc support
      mac80211: A-MPDU Tx MLME data initialization
      mac80211: A-MPDU add debugfs support
      mac80211: A-MPDU Tx change tx_status to support Block Ack data
      mac80211: A-MPDU Tx add delBA from recipient support
      iwlwifi: A-MPDU Tx conform API to mac80211
      iwlwifi: A-MPDU Tx conform flows to mac80211
      iwlwifi: A-MPDU Tx conform block Ack rate scaling to mac80211
      iwlwifi: A-MPDU Tx activation by load measures
      mac80211: adjustable number of bits for qdisc pool
      iwlwifi: remove IWL{4965,3945}_QOS

S.=C3=87a=C4=9Flar Onur (2):
      net/mac80211/: Use time_* macros
      drivers/net/wireless/atmel.c: Use time_* macros

Stefano Brivio (4):
      rc80211-pid: fix rate adjustment
      b43legacy: add definitions for MAC control register
      b43legacy: fix upload of beacon packets to the hardware
      b43legacy: fix B43legacy_WARN_ON macro

Tomas Winkler (7):
      mac80211: set assoc flag to bss_conf
      iwlwifi: enable 802.11n in Kconfig
      iwlwifi: Fix HT compilation breakage caused by cfg80211 API for c=
hannels/bitrates patch
      iwlwifi: change iwl->priv iwl_priv * type in iwl-YYY-io.h
      iwlwifi: Add tx_ant_num hw setting variable
      iwlwifi: remove twice defined CSR register
      wireless: update US regulatory domain

 drivers/net/wireless/Kconfig                     |   44 +-
 drivers/net/wireless/adm8211.c                   |   88 +-
 drivers/net/wireless/adm8211.h                   |   65 +--
 drivers/net/wireless/ath5k/Kconfig               |   37 +
 drivers/net/wireless/ath5k/Makefile              |    8 +-
 drivers/net/wireless/ath5k/ath5k.h               |  106 ++--
 drivers/net/wireless/ath5k/base.c                |  417 +++++----
 drivers/net/wireless/ath5k/base.h                |   18 +-
 drivers/net/wireless/ath5k/debug.c               |   55 +-
 drivers/net/wireless/ath5k/debug.h               |   23 +-
 drivers/net/wireless/ath5k/hw.c                  |  172 +---
 drivers/net/wireless/ath5k/initvals.c            |    6 +-
 drivers/net/wireless/ath5k/phy.c                 |   88 +-
 drivers/net/wireless/atmel.c                     |    5 +-
 drivers/net/wireless/b43/b43.h                   |   79 +-
 drivers/net/wireless/b43/main.c                  |  428 ++++++----
 drivers/net/wireless/b43/main.h                  |    4 +-
 drivers/net/wireless/b43/sysfs.c                 |   89 +--
 drivers/net/wireless/b43/xmit.c                  |   95 ++-
 drivers/net/wireless/b43legacy/b43legacy.h       |   46 +-
 drivers/net/wireless/b43legacy/main.c            |  433 +++++-----
 drivers/net/wireless/b43legacy/xmit.c            |   78 +-
 drivers/net/wireless/ipw2200.c                   |    4 +-
 drivers/net/wireless/iwlwifi/Kconfig             |   17 +-
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h |   19 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h       |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945-io.h       |   39 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |   90 +--
 drivers/net/wireless/iwlwifi/iwl-3945.c          |   38 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h          |   22 +-
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h |   43 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965-io.h       |   39 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c       |  371 ++++++--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h       |   12 +
 drivers/net/wireless/iwlwifi/iwl-4965.c          |  865 ++++++--------=
-----
 drivers/net/wireless/iwlwifi/iwl-4965.h          |  119 +--
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |  469 +++--------
 drivers/net/wireless/iwlwifi/iwl4965-base.c      |  687 +++++---------=
-
 drivers/net/wireless/libertas/assoc.c            |   20 +-
 drivers/net/wireless/libertas/assoc.h            |    1 -
 drivers/net/wireless/libertas/cmd.c              |   23 +-
 drivers/net/wireless/libertas/cmdresp.c          |    6 +-
 drivers/net/wireless/libertas/debugfs.c          |    2 +-
 drivers/net/wireless/libertas/dev.h              |    4 +-
 drivers/net/wireless/libertas/join.c             |   20 -
 drivers/net/wireless/libertas/join.h             |    2 -
 drivers/net/wireless/libertas/main.c             |   14 +-
 drivers/net/wireless/libertas/scan.c             |   39 +-
 drivers/net/wireless/p54.h                       |    4 -
 drivers/net/wireless/p54common.c                 |   96 ++-
 drivers/net/wireless/p54common.h                 |   75 --
 drivers/net/wireless/prism54/isl_ioctl.c         |   46 +-
 drivers/net/wireless/prism54/islpci_dev.c        |    2 +-
 drivers/net/wireless/prism54/islpci_dev.h        |    6 +-
 drivers/net/wireless/rt2x00/Kconfig              |   62 ++-
 drivers/net/wireless/rt2x00/Makefile             |   37 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |  436 ++++++----
 drivers/net/wireless/rt2x00/rt2400pci.h          |    8 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |  442 ++++++----
 drivers/net/wireless/rt2x00/rt2500pci.h          |    6 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |  512 +++++++-----
 drivers/net/wireless/rt2x00/rt2500usb.h          |    9 +-
 drivers/net/wireless/rt2x00/rt2x00.h             |  339 ++++----
 drivers/net/wireless/rt2x00/rt2x00config.c       |  163 ++--
 drivers/net/wireless/rt2x00/rt2x00debug.c        |  124 ++-
 drivers/net/wireless/rt2x00/rt2x00debug.h        |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c          |  907 +++++++++-----=
------
 drivers/net/wireless/rt2x00/rt2x00dump.h         |    8 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c     |   43 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c         |  217 +++++
 drivers/net/wireless/rt2x00/rt2x00leds.h         |   63 ++
 drivers/net/wireless/rt2x00/rt2x00lib.h          |  101 +++-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |  243 ++++--
 drivers/net/wireless/rt2x00/rt2x00pci.c          |  286 ++++---
 drivers/net/wireless/rt2x00/rt2x00pci.h          |   67 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.c        |  299 +++++++
 drivers/net/wireless/rt2x00/rt2x00queue.h        |  457 ++++++++++
 drivers/net/wireless/rt2x00/rt2x00reg.h          |   75 +--
 drivers/net/wireless/rt2x00/rt2x00rfkill.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2x00ring.h         |  290 -------
 drivers/net/wireless/rt2x00/rt2x00usb.c          |  324 ++++---
 drivers/net/wireless/rt2x00/rt2x00usb.h          |  161 +++-
 drivers/net/wireless/rt2x00/rt61pci.c            |  640 +++++++-------
 drivers/net/wireless/rt2x00/rt61pci.h            |   33 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |  521 ++++++------
 drivers/net/wireless/rt2x00/rt73usb.h            |   24 +-
 drivers/net/wireless/rtl8180.h                   |    2 +-
 drivers/net/wireless/rtl8180_dev.c               |  103 ++-
 drivers/net/wireless/rtl8180_grf5101.c           |    5 +-
 drivers/net/wireless/rtl8180_max2820.c           |    5 +-
 drivers/net/wireless/rtl8180_rtl8225.c           |   15 +-
 drivers/net/wireless/rtl8180_sa2400.c            |    5 +-
 drivers/net/wireless/rtl8187.h                   |    2 +-
 drivers/net/wireless/rtl8187_dev.c               |   92 ++-
 drivers/net/wireless/rtl8187_rtl8225.c           |   15 +-
 drivers/net/wireless/rtl818x.h                   |   70 --
 drivers/net/wireless/strip.c                     |    6 +-
 drivers/net/wireless/zd1211rw/zd_chip.c          |   23 +-
 drivers/net/wireless/zd1211rw/zd_chip.h          |    9 +-
 drivers/net/wireless/zd1211rw/zd_ieee80211.c     |   11 +-
 drivers/net/wireless/zd1211rw/zd_mac.c           |  172 ++--
 drivers/net/wireless/zd1211rw/zd_mac.h           |    2 +-
 drivers/ssb/driver_chipcommon.c                  |   10 +
 drivers/ssb/main.c                               |   18 +
 drivers/ssb/pci.c                                |   28 +
 drivers/ssb/pcmcia.c                             |   32 +
 include/linux/nl80211.h                          |   99 +++
 include/linux/ssb/ssb.h                          |   10 +
 include/linux/ssb/ssb_driver_chipcommon.h        |    4 +
 include/net/cfg80211.h                           |   24 +-
 include/net/mac80211.h                           |  384 +++++----
 include/net/wireless.h                           |  168 ++++
 net/mac80211/Makefile                            |    1 -
 net/mac80211/cfg.c                               |   68 +-
 net/mac80211/debugfs.c                           |   47 +-
 net/mac80211/debugfs_netdev.c                    |    9 -
 net/mac80211/debugfs_sta.c                       |  170 +++--
 net/mac80211/ieee80211.c                         |  825 ++++++++++++++=
-----
 net/mac80211/ieee80211_i.h                       |  164 +---
 net/mac80211/ieee80211_iface.c                   |   10 +-
 net/mac80211/ieee80211_ioctl.c                   |  217 +++---
 net/mac80211/ieee80211_key.h                     |   26 +-
 net/mac80211/ieee80211_rate.c                    |   15 +-
 net/mac80211/ieee80211_rate.h                    |   28 +-
 net/mac80211/ieee80211_sta.c                     | 1004 ++++++++++++++=
--------
 net/mac80211/key.c                               |  171 +++-
 net/mac80211/rc80211_pid_algo.c                  |  158 ++--
 net/mac80211/rc80211_simple.c                    |   72 +-
 net/mac80211/regdomain.c                         |  152 ----
 net/mac80211/rx.c                                |  572 +++++++------
 net/mac80211/sta_info.c                          |  168 +++--
 net/mac80211/sta_info.h                          |  110 ++-
 net/mac80211/tx.c                                |  335 ++++----
 net/mac80211/util.c                              |  142 +---
 net/mac80211/wep.c                               |   16 +-
 net/mac80211/wep.h                               |    4 +-
 net/mac80211/wme.c                               |  135 +++-
 net/mac80211/wme.h                               |   23 +-
 net/mac80211/wpa.c                               |   72 +-
 net/mac80211/wpa.h                               |   12 +-
 net/wireless/Makefile                            |    2 +-
 net/wireless/core.c                              |   41 +
 net/wireless/core.h                              |    3 +
 net/wireless/nl80211.c                           |  118 +++-
 net/wireless/reg.c                               |  159 ++++
 net/wireless/util.c                              |   98 +++
 147 files changed, 10637 insertions(+), 8305 deletions(-)
 create mode 100644 drivers/net/wireless/ath5k/Kconfig
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00leds.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00leds.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00queue.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00queue.h
 delete mode 100644 drivers/net/wireless/rt2x00/rt2x00ring.h
 delete mode 100644 net/mac80211/regdomain.c
 create mode 100644 net/wireless/reg.c
 create mode 100644 net/wireless/util.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26=
-2008-02-29.patch.gz

--=20
John W. Linville
linville@tuxdriver.com
