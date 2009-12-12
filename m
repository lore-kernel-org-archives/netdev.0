From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 11 Dec 2009 18:17:12 -0800 (PST)
Message-ID: <20091211.181712.211179737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32930
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762656AbZLLCRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 21:17:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pretty much entirely bug fixes including a 2.6.32 regression fix for
stalled TCP regressions (will be sent to -stable) from Damian
Lukowski.

Resolve some wireless merge issues.

As well as a fix for NETREG_UNINITIALIZED state net devices,
from Krishna Kumar.

There is an 'origin' pull in here to resolve a net/tcp.h conflict with
your tree.

Please pull, thanks a lot!

The following changes since commit 2fe77b81c77eed92c4c0439f74c8148a295b4a86:
  Linus Torvalds (1):
        Merge branch 'next' of git://git.kernel.org/.../davej/cpufreq

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amit Kumar Salecha (2):
      netxen: protect device reset by rtnl_lock
      netxen:fix napi intr enable check

Andrew Morton (1):
      net/rfkill/core.c: work around gcc-4.0.2 silliness

Anton Vorontsov (1):
      gianfar: Fix build with CONFIG_NET_POLL_CONTROLLER=y

Asier Llano (1):
      net/mpc5200: Fix locking on fec_mpc52xx driver

Barry Song (1):
      can: add the driver for Analog Devices Blackfin on-chip CAN controllers

Breno Leitao (1):
      cxgb3: Fixing EEH handlers

Brice Goglin (1):
      myri10ge: use src+dst for rss hashing

Bruce Allan (3):
      e1000e: minor correction to name of bit in CTRL_EXT register
      e1000e: replace incorrect use of GG82563_REG macro
      e1000e: only perform ESB2 MDIC workaround on certain configurations

Damian Lukowski (2):
      tcp: Stalling connections: Fix timeout calculation routine
      tcp: Stalling connections: Move timeout calculation routine

David Kilroy (1):
      orinoco: remove spare KERN_DEBUG

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
      tcp: Remove runtime check that can never be true.
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

Denis Kirjanov (1):
      mv643xx_eth: check for valid hw address (resubmit)

Dhananjay Phadke (1):
      netxen: fix firmware type check

Don Skidmore (1):
      ixgbe: add support for 82599 KR device 0x1517

Eric Dumazet (4):
      ixgbe: Fix TX stats accounting
      tcp: Fix a connect() race with timewait sockets
      tcp: Fix a connect() race with timewait sockets
      tcp: documents timewait refcnt tricks

Felix Fietkau (1):
      ath9k: fix tx status reporting

Heiko Carstens (2):
      net: fix compat_sys_recvmmsg parameter type
      net: use compat helper functions in compat_sys_recvmmsg

Herton Ronaldo Krzesinski (1):
      rtl8187: add radio led and fix warnings on suspend

Ilpo Järvinen (1):
      tcp: fix retrans_stamp advancing in error cases

Javier Cardona (2):
      mac80211: Fixed bug in mesh portal paths
      mac80211: Revert 'Use correct sign for mesh active path refresh'

Jie Yang (2):
      atl1c:add pci map direction in atl1c_buffer flags
      atl1c:use common_task instead of reset_task and link_chg_task

Joe Perches (1):
      include/linux/if_ether.h: Remove unused defines MAC_BUF_SIZE and DECLARE_MAC_BUF

Johannes Berg (1):
      mac80211: recalculate idle later in MLME

John W. Linville (3):
      iwlwifi: fix warning from ieee80211_stop_tx_ba_cb_irqsafe argument change
      wireless: correctly report signal value for IEEE80211_HW_SIGNAL_UNSPEC
      wireless: update old static regulatory domain rules

Julia Lawall (1):
      net/mac80211: Correct size given to memset

Kalle Valo (3):
      wl1251: remove false warning messages
      wl1251: fix bssid handling
      wl1251: don't build null data template in wl1251_op_config()

Krishna Kumar (1):
      net: Handle NETREG_UNINITIALIZED devices correctly

Larry Finger (2):
      rtl8187: Fix wrong rfkill switch mask for some models
      b43: Remove reset after fatal DMA error

Lennert Buytenhek (12):
      mwl8k: fix MCS bitmap size in SET_RATE command
      mwl8k: fix UPDATE_STADB command struct legacy_rates array length
      mwl8k: prevent corruption of QoS field on receive
      mwl8k: fix addr4 zeroing and payload overwrite on DMA header creation
      mwl8k: properly report rate on received 40MHz packets
      mwl8k: allow more time for firmware commands to complete
      mwl8k: allow more time for transmit rings to drain
      mwl8k: increase firmware loading timeouts
      mwl8k: don't forget to call pci_disable_device()
      mwl8k: struct ieee80211_rx_status::qual is deprecated
      mwl8k: don't overwrite mwl8k_vif::bssid until after disassociation
      mwl8k: don't complain about oversized beacons in FINALIZE_JOIN

Luis R. Rodriguez (1):
      ath5k: enable EEPROM checksum check

Martin Willi (1):
      xfrm: Fix truncation length of authentication algorithms installed via PF_KEY

Michael Chan (2):
      cnic: Send delete command when shutting down iSCSI ring.
      cnic: Zero out status block and Event Queue indices.

Mike Frysinger (1):
      smc91x: fix unused flags warnings on UP systems

Oliver Neukum (1):
      MAINTAINERS: Transfering maintainership of cdc-ether

Paul Mundt (1):
      net: smc91x: Fix up type mismatch in smc_drv_resume().

Randy Dunlap (1):
      net: niu uses crc32, so select CRC32

Shahar Or (1):
      ath5k: add support for Dell Vostro A860 LED

Stanislav Brabec (1):
      b44 WOL setup: one-bit-off stack corruption kernel panic fix

Takashi Iwai (2):
      net: Fix Yukon-2 Optima TCP offload setup
      net: Add missing TST_CFG_WRITE bits around sky2_pci_write

Tilman Schmidt (2):
      gigaset: don't enable any debugging output by default
      gigaset: documentation amendments

Vasanthakumar Thiagarajan (1):
      mac80211: Fix bug in computing crc over dynamic IEs in beacon

Vivek Natarajan (2):
      mac80211: Fix dynamic power save for scanning.
      cfg80211: Clear encryption privacy when key off is done.

chas williams - CONTRACTOR (3):
      atm: [lec] initialize .netdev_ops before calling register_netdev()
      atm: [he] adjust tests to account for sk_wmem_alloc changes
      atm: [br2684] allow routed mode operation again

 Documentation/isdn/README.gigaset             |  116 +++-
 MAINTAINERS                                   |    3 +-
 drivers/atm/he.c                              |    4 +-
 drivers/isdn/gigaset/common.c                 |    2 +-
 drivers/net/Kconfig                           |    1 +
 drivers/net/atl1c/atl1c.h                     |   17 +-
 drivers/net/atl1c/atl1c_main.c                |   94 ++--
 drivers/net/b44.c                             |    3 +-
 drivers/net/can/Kconfig                       |    9 +
 drivers/net/can/Makefile                      |    1 +
 drivers/net/can/bfin_can.c                    |  783 +++++++++++++++++++++++++
 drivers/net/cnic.c                            |   11 +
 drivers/net/cxgb3/cxgb3_main.c                |    1 +
 drivers/net/e1000e/defines.h                  |    2 +-
 drivers/net/e1000e/es2lan.c                   |   97 ++-
 drivers/net/e1000e/hw.h                       |    7 +
 drivers/net/e1000e/ich8lan.c                  |    8 +-
 drivers/net/e1000e/netdev.c                   |    2 +-
 drivers/net/fec_mpc52xx.c                     |  121 ++--
 drivers/net/gianfar.c                         |    1 +
 drivers/net/ixgbe/ixgbe_82599.c               |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c             |    1 +
 drivers/net/ixgbe/ixgbe_main.c                |   22 +-
 drivers/net/ixgbe/ixgbe_type.h                |    1 +
 drivers/net/mv643xx_eth.c                     |    3 +
 drivers/net/myri10ge/myri10ge.c               |    4 +-
 drivers/net/netxen/netxen_nic_init.c          |   14 +-
 drivers/net/netxen/netxen_nic_main.c          |   49 ++-
 drivers/net/sky2.c                            |    9 +
 drivers/net/smc91x.c                          |    8 +-
 drivers/net/wireless/ath/ath5k/eeprom.c       |    3 +-
 drivers/net/wireless/ath/ath5k/led.c          |    2 +
 drivers/net/wireless/ath/ath9k/xmit.c         |    2 +-
 drivers/net/wireless/b43/main.c               |    5 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c         |    2 +-
 drivers/net/wireless/mwl8k.c                  |  327 +++++------
 drivers/net/wireless/orinoco/hermes_dld.c     |    2 +-
 drivers/net/wireless/rtl818x/rtl8187.h        |    6 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c    |   12 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c   |   68 ++-
 drivers/net/wireless/rtl818x/rtl8187_leds.h   |    2 +
 drivers/net/wireless/rtl818x/rtl8187_rfkill.c |    4 +-
 drivers/net/wireless/wl12xx/wl1251_main.c     |   36 +-
 include/linux/gigaset_dev.h                   |   22 +-
 include/linux/if_ether.h                      |    2 -
 include/net/compat.h                          |    2 +-
 include/net/inet6_hashtables.h                |    2 +-
 include/net/inet_hashtables.h                 |    8 +-
 include/net/inet_timewait_sock.h              |    3 +
 include/net/tcp.h                             |   23 -
 net/atm/br2684.c                              |   11 +-
 net/atm/lec.c                                 |   10 +-
 net/compat.c                                  |   11 +-
 net/core/dev.c                                |   10 +-
 net/dccp/ipv4.c                               |    2 +-
 net/dccp/ipv6.c                               |    4 +-
 net/ipv4/inet_hashtables.c                    |   24 +-
 net/ipv4/inet_timewait_sock.c                 |   61 ++-
 net/ipv4/tcp.c                                |    5 -
 net/ipv4/tcp_input.c                          |   35 +-
 net/ipv4/tcp_ipv4.c                           |    2 +-
 net/ipv4/tcp_timer.c                          |   29 +
 net/ipv6/inet6_hashtables.c                   |    8 +-
 net/ipv6/tcp_ipv6.c                           |    4 +-
 net/key/af_key.c                              |    1 +
 net/mac80211/cfg.c                            |    3 +-
 net/mac80211/ieee80211_i.h                    |    1 +
 net/mac80211/mesh.c                           |    2 +-
 net/mac80211/mesh.h                           |    5 +-
 net/mac80211/mesh_hwmp.c                      |    2 +-
 net/mac80211/mlme.c                           |   10 +-
 net/mac80211/rx.c                             |    1 -
 net/mac80211/scan.c                           |   20 +-
 net/mac80211/util.c                           |    2 +-
 net/rfkill/core.c                             |    4 +-
 net/wireless/reg.c                            |   75 +--
 net/wireless/wext-compat.c                    |    1 +
 77 files changed, 1677 insertions(+), 594 deletions(-)
 create mode 100644 drivers/net/can/bfin_can.c
