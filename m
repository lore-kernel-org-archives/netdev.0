From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 17 Aug 2009 22:09:25 -0700 (PDT)
Message-ID: <20090817.220925.220220669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbZHRFJO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 01:09:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) netxen fixes from Dhanajay Pdadke and Amit Kumar Salecha

2) e1000e/ixgbe fixes from the Intel folks

3) Wireless bug fixes via John Linville

4) TUN ioctl race fix from Herbert Xu

5) Eric Dumazet discovered that several ->getname implementations
   leak uninitialized kernel memory to userspace.

6) mwl8k driver fixes from Lennert Buytenhek

7) Fix 8139cp issues caught by DMA debugging, from Francois Romieu

8) Drivers that support netpoll need to not assume the state of
   interrupt enabling when ->hard_start_xmit is called.  Fix from=09
   Dongdong Deng

9) IEEE802154 protocol needs to provide dummy get/setsockopt else
   we oops, plus an ioctl fix from Dmitry Eremin-Solenikov

10) cnic/bnx2 fixes from Michael Chan

11) can protocol oops fixer from Oliver Hartkopp

12) New device IDs for 3c90x and pegasus drivers.

13) SCTP forgets to destroy per-cpu variable on unload, from Rafael Lau=
fer
    DCCP has the same problem, fixed by Wei Yongjun

14) Various read-past-end-of-buffer fixes from Roel Kluin

15) Gianfar loses VLAN state on restart.

16) genetlink datastructure change broke userland, split into kernel
    private and userland copy.  Regression fixed by Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit df4ecf1524c7793de3121b2d4e5fc6bcc0da=
3bfb:
  Linus Torvalds (1):
        Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/ups=
tream-linus

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amit Kumar Salecha (1):
      netxen: remove netxen workqueue

Bob Dunlop (1):
      libertas: correct packing of rxpd structure

Bruce Allan (3):
      e1000e: fix acquisition of SW/FW/HW semaphore for ICHx parts
      e1000e: fix potential NVM corruption on ICH9 with 8K bank size
      e1000e: WoL does not work on 82577/82578 with manageability enabl=
ed

Chris Snook (1):
      MAINTAINERS: update atlx contact info

Christian Lamparter (1):
      ar9170usb: fix spurious firmware related message

Dan Carpenter (1):
      ar9170: fix read & write outside array bounds

David S. Miller (5):
      Merge branch 'for-linus' of git://git.kernel.org/.../lowpan/lowpa=
n
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Revert "libertas: Read buffer overflow"
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Dhananjay Phadke (2):
      netxen: fix dma mask update calculation
      netxen: free napi resources during detach

Dmitry Eremin-Solenikov (2):
      af_ieee802154: fix ioctl processing
      af_ieee802154: provide dummy get/setsockopt

Don Skidmore (1):
      ixgbe: fix issues setting rx-usecs with legacy interrupts

Dongdong Deng (1):
      drivers/net: fixed drivers that support netpoll use ndo_start_xmi=
t()

Eric Dumazet (8):
      phonet: phonet_device_get() fix
      rose: Fix rose_getname() leak
      econet: Fix econet_getname() leak
      netrom: Fix nr_getname() leak
      appletalk: fix atalk_getname() leak
      irda: Fix irda_getname() leak
      can: Fix raw_getname() leak
      net: restore gnet_stats_basic to previous definition

=46rancois Romieu (1):
      8139cp: balance dma_map_single vs dma_unmap_single pair

Greg Ungerer (1):
      fec: fix FEC driver packet transmission breakage

Herbert Xu (1):
      tun: Extend RTNL lock coverage over whole ioctl

Joe Perches (1):
      MAINTAINERS: additional NETWORKING [GENERAL] and NETWORKING DRIVE=
RS patterns

Jussi M=E4ki (1):
      Fix xfrm hash collisions by changing __xfrm4_daddr_saddr_hash to =
hash addresses with addition

Lennert Buytenhek (5):
      mwl8k: fix NULL pointer dereference on receive out-of-memory
      mwl8k: add various missing GET_HW_SPEC endian conversions
      mwl8k: call pci_unmap_single() before accessing command structure=
 again
      mwl8k: prevent crash in ->configure_filter() if no interface was =
added
      mwl8k: prevent module unload hang

Lucy Liu (1):
      ixgbe: Fix receive on real device when VLANs are configured

Luis R. Rodriguez (1):
      mac80211: fix panic when splicing unprepared TIDs

Michael Chan (5):
      cnic: Fix symbol_put_addr() panic on ia64.
      cnic: Refine registration with bnx2.
      bnx2: Use mutex on slow path cnic calls.
      cnic: Fix locking in start/stop calls.
      cnic: Fix locking in init/exit calls.

Oliver Hartkopp (1):
      can: fix oops caused by wrong rtnl newlink usage

Pascal Terjan (1):
      Add IDs for 3C905B-TX Fast Etherlink XL PCI

Pavel Roskin (1):
      rt2x00: fix memory corruption in rf cache, add a sanity check

Petko Manolov (1):
      pegasus: Add new device ID.

Rafael Laufer (1):
      sctp: fix missing destroy of percpu counter variable in sctp_proc=
_exit()

Ralf Baechle (1):
      NETROM: Fix use of static buffer

Roel Kluin (2):
      irda: fix read buffer overflow
      atlx: strncpy does not null terminate string

Tom Goff (1):
      gre: Fix MTU calculation for bound GRE tunnels

Wei Yongjun (1):
      dccp: missing destroy of percpu counter variable while unload mod=
ule

Xiaotian Feng (1):
      e1000e: fix use of pci_enable_pcie_error_reporting

Yi Zou (3):
      ixgbe: Pass rx_ring directly in ixgbe_configure_srrctl()
      ixgbe: Disable packet split only on FCoE queues in 82599
      ixgbe: Do not return 0 in ixgbe_fcoe_ddp() upon FCP_RSP in DDP co=
mpletion

Yong Zhang (1):
      gianfar: keep vlan related state when restart

Zhu Yi (1):
      ipw2x00: Write outside array bounds

roel kluin (4):
      pcnet32: Read buffer overflow
      zorro8390: Fix read buffer overflow in zorro8390_init_one()
      mlx4_en: Fix read buffer overflow in mlx4_en_complete_rx_desc()
      via-velocity: Fix test of mii_status bit VELOCITY_DUPLEX_FULL

 MAINTAINERS                             |    7 ++-
 drivers/net/3c59x.c                     |    4 +
 drivers/net/8139cp.c                    |    5 +-
 drivers/net/atl1c/atl1c_ethtool.c       |    8 +-
 drivers/net/atlx/atl1.c                 |    8 +-
 drivers/net/b44.c                       |    5 +-
 drivers/net/bnx2.c                      |   17 +++--
 drivers/net/bnx2.h                      |    1 +
 drivers/net/can/dev.c                   |    7 ++
 drivers/net/cnic.c                      |  143 ++++++++++++++++++++++-=
--------
 drivers/net/cnic.h                      |    1 +
 drivers/net/cnic_if.h                   |    1 +
 drivers/net/e1000e/ich8lan.c            |   94 +++++++++-----------
 drivers/net/e1000e/netdev.c             |   22 +++---
 drivers/net/fec.c                       |    9 +-
 drivers/net/gianfar.c                   |   12 ++-
 drivers/net/irda/w83977af_ir.c          |    2 +-
 drivers/net/ixgbe/ixgbe.h               |    2 +
 drivers/net/ixgbe/ixgbe_ethtool.c       |   27 ++++--
 drivers/net/ixgbe/ixgbe_fcoe.c          |    2 +-
 drivers/net/ixgbe/ixgbe_main.c          |   90 +++++++------------
 drivers/net/mlx4/en_rx.c                |    5 +-
 drivers/net/netxen/netxen_nic.h         |    2 +-
 drivers/net/netxen/netxen_nic_init.c    |    7 --
 drivers/net/netxen/netxen_nic_main.c    |  105 ++++++++++++++--------
 drivers/net/pcnet32.c                   |    2 +-
 drivers/net/tulip/tulip_core.c          |    5 +-
 drivers/net/tun.c                       |   50 ++++-------
 drivers/net/ucc_geth.c                  |    5 +-
 drivers/net/usb/pegasus.h               |    2 +
 drivers/net/via-rhine.c                 |    5 +-
 drivers/net/via-velocity.c              |    2 +-
 drivers/net/wireless/ath/ar9170/main.c  |    5 +-
 drivers/net/wireless/ath/ar9170/usb.c   |    6 +-
 drivers/net/wireless/ipw2x00/ipw2200.c  |    2 +-
 drivers/net/wireless/libertas/assoc.c   |   18 ++--
 drivers/net/wireless/libertas/hostcmd.h |    4 +-
 drivers/net/wireless/mwl8k.c            |   31 ++++---
 drivers/net/wireless/rt2x00/rt2x00.h    |    6 +-
 drivers/net/zorro8390.c                 |    3 +
 include/linux/gen_stats.h               |    5 +
 include/net/act_api.h                   |    2 +-
 include/net/gen_stats.h                 |   10 +-
 include/net/netfilter/xt_rateest.h      |    2 +-
 include/net/sch_generic.h               |    2 +-
 net/appletalk/ddp.c                     |    1 +
 net/can/raw.c                           |    1 +
 net/core/gen_estimator.c                |   12 ++--
 net/core/gen_stats.c                    |   11 ++-
 net/dccp/proto.c                        |    1 +
 net/econet/af_econet.c                  |    1 +
 net/ieee802154/af_ieee802154.c          |    8 +-
 net/ieee802154/dgram.c                  |   14 +++
 net/ieee802154/raw.c                    |   14 +++
 net/ipv4/ip_gre.c                       |    2 +-
 net/irda/af_irda.c                      |    1 +
 net/mac80211/agg-tx.c                   |    8 ++
 net/netfilter/xt_RATEEST.c              |    2 +-
 net/netrom/af_netrom.c                  |    1 +
 net/netrom/nr_route.c                   |   21 +++--
 net/phonet/pn_dev.c                     |    2 +-
 net/rose/af_rose.c                      |    1 +
 net/sched/sch_atm.c                     |    2 +-
 net/sched/sch_cbq.c                     |    2 +-
 net/sched/sch_drr.c                     |    2 +-
 net/sched/sch_hfsc.c                    |    2 +-
 net/sched/sch_htb.c                     |    2 +-
 net/sctp/protocol.c                     |    1 +
 net/xfrm/xfrm_hash.h                    |    2 +-
 69 files changed, 520 insertions(+), 347 deletions(-)
