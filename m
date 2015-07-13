From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 12 Jul 2015 22:55:39 -0700 (PDT)
Message-ID: <20150712.225539.313717681041513258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbGMFzm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 01:55:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Missing list head init in bluetooth hidp session creation, from
   Tedd Ho-Jeong An.

2) Don't leak SKB in bridge netfilter error paths, from Florian
   Westphal.

3) ipv6 netdevice private leak in netfilter bridging, fixed
   by Julien Grall.

4) Fix regression in IP over hamradio bpq encapsulation, from Ralf
   Baechle.

5) Fix race between rhashtable resize events and table walks, from
   Phil Sutter.

6) Missing validation of IFLA_VF_INFO netlink attributes, fix from
   Daniel Borkmann.

7) Missing security layer socket state initialization in tipc code,
   from Stephen Smalley.

8) Fix shared IRQ handling in boomerang 3c59x interrupt handler, from
   Denyx Vlasenko.

9) Missing minor_idr destroy on module unload on macvtap driver, from
   Johannes Thumshirn.

10) Various pktgen kernel thread races, from Oleg Nesterov.

11) Fix races that can cause packets to be processed in the backlog
    even after a device attached to that SKB has been fully
    unregistered.  From Julian Anastasov.

12) bcmgenet driver doesn't account packet drops vs. errors properly,
    fix from Petri Gynther.

13) Array index validation and off by one fix in DSA layer from
    Florian Fainelli.

Please pull, thanks a lot!

The following changes since commit a611fb75d0517fce65f588cde94f80bb4052=
c6b2:

  Merge tag 'module-misc-v4.1-rc8' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/paulg/linux (2015-07-02 11:07:27 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to cee9f6d0186a586c8023bc91c8a4cf8a088855e5=
:

  Merge tag 'linux-can-fixes-for-4.2-20150712' of git://git.kernel.org/=
pub/scm/linux/kernel/git/mkl/linux-can (2015-07-12 22:24:01 -0700)

----------------------------------------------------------------
Andrew Lunn (1):
      net: fec: Ensure clocks are enabled while using mdio bus

Andy Gospodarek (1):
      ipv4: add support for linkdown sysctl to netconf

Angga (1):
      ipv6: Make MLD packets to only be processed locally

Bernhard Thaler (1):
      netfilter: bridge: fix CONFIG_NF_DEFRAG_IPV4/6 related warnings/e=
rrors

Daniel Borkmann (1):
      rtnetlink: verify IFLA_VF_INFO attributes before passing them to =
driver

Daniel Pieczko (3):
      sfc: refactor code in efx_ef10_set_mac_address()
      sfc: add legacy method for changing a PF's MAC address
      sfc: suppress handled MCDI failures when changing the MAC address

David S. Miller (7):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'sfc-set-mac'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'pktgen-races'
      Merge branch 'netdev_unregister_races'
      Merge branch 'dsa-of-parsing-fixes'
      Merge tag 'linux-can-fixes-for-4.2-20150712' of git://git.kernel.=
org/.../mkl/linux-can

Denys Vlasenko (1):
      3c59x: Fix shared IRQ handling

Enrico Mioso (2):
      cdc_ncm: Add support for moving NDP to end of NCM frame
      cdc_ncm: update specs URL

Eric Dumazet (3):
      net_sched: gen_estimator: extend pps limit
      net: graceful exit from netif_alloc_netdev_queues()
      bridge: fix potential crash in __netdev_pick_tx()

Eric W. Biederman (1):
      netfilter: nf_queue: Don't recompute the hook_list head

=46lorian Fainelli (2):
      net: dsa: Test array index before use
      net: dsa: Fix off-by-one in switch address parsing

=46lorian Westphal (2):
      netfilter: arptables: use percpu jumpstack
      netfilter: bridge: don't leak skb in error paths

Govindarajulu Varadarajan (1):
      enic: fix issues in enic_poll

Hariprasad Shenai (1):
      cxgb4: Fix incorrect sequence numbers shown in devlog

J.D. Schroeder (1):
      can: c_can: Fix default pinmux glitch at init

Johannes Thumshirn (1):
      macvtap: Destroy minor_idr on module_exit

Julian Anastasov (2):
      net: do not process device backlog during unregistration
      net: call rcu_read_lock early in process_backlog

Julien Grall (1):
      netfilter: bridge: Use __in6_dev_get rather than in6_dev_get in b=
r_validate_ipv6

Krzysztof Kozlowski (1):
      net: axienet: Fix devm_ioremap_resource return value check

Lendacky, Thomas (1):
      amd-xgbe: Fix DMA API debug warning

Markus Elfring (3):
      net-ipv6: Delete an unnecessary check before the function call "f=
ree_percpu"
      net-RDS: Delete an unnecessary check before the function call "mo=
dule_put"
      netlink: Delete an unnecessary check before the function call "mo=
dule_put"

Masanari Iida (1):
      Doc: z8530book: Fix typo in API-z8530-sync-txdma-open.html

Mazhar Rana (1):
      bonding: "primary_reselect" with "failure" is not working properl=
y

Mugunthan V N (2):
      drivers: net: cpsw: fix crash while accessing second slave ethern=
et interface
      drivers: net: cpsw: fix disabling of tx interrupt in rx isr

Neil Horman (1):
      vmxnet3: prevent receive getting out of sequence on napi poll

Nicolas Dichtel (1):
      Revert "dev: set iflink to 0 for virtual interfaces"

Nikolay Aleksandrov (2):
      bridge: vlan: fix usage of vlan 0 and 4095 again
      bridge: mdb: zero out the local br_ip variable before use

Oleg Nesterov (2):
      net: pktgen: fix race between pktgen_thread_worker() and kthread_=
stop()
      net: pktgen: kill the "Wait for kthread_stop" code in pktgen_thre=
ad_worker()

Oliver Hartkopp (1):
      can: replace timestamp as unique skb attribute

Pablo Neira Ayuso (2):
      netfilter: nfnetlink: keep going batch handling on missing module=
s
      MAINTAINER: add bridge netfilter

Peter Dunning (1):
      sfc: Report TX completions to BQL after all TX events in interrup=
t

Petri Gynther (1):
      net: bcmgenet: fix accounting of packet drops vs errors

Phil Sutter (2):
      rhashtable: fix for resize events during table walk
      net: inet_diag: always export IPV6_V6ONLY sockopt for listening s=
ockets

Ralf Baechle (1):
      NET: hamradio: Fix IP over bpq encapsulation.

Rob Herring (1):
      net: phy: add dependency on HAS_IOMEM to MDIO_BUS_MUX_MMIOREG

Roger Quadros (1):
      ARM: dts: dra7x-evm: Prevent glitch on DCAN1 pinmux

Satish Ashok (2):
      bridge: mdb: start delete timer for temp static entries
      bridge: mdb: allow the user to delete mdb entry if there's a quer=
ier

Sergei Shtylyov (5):
      can: rcar_can: fix IRQ check
      can: rcar_can: print signed IRQ #
      can: rcar_can: fix typo in error message
      can: rcar_can: print request_irq() error code
      can: rcar_can: unify error messages

Shradha Shah (1):
      sfc: Ensure down_write(&filter_sem) and up_write() are matched be=
fore calling efx_net_open()

Stephen Smalley (1):
      net/tipc: initialize security state for new connection socket

Tedd Ho-Jeong An (2):
      Bluetooth: hidp: Initialize list header of hidp session user
      Bluetooth: Reinitialize the list after deletion for session user =
list

Timo Ter=E4s (1):
      ip_tunnel: fix ipv4 pmtu check to honor inner ip header df

Vaishali Thakkar (1):
      net: systemport: Use eth_hw_addr_random

Vivien Didelot (1):
      net: switchdev: don't abort unsupported operations

Zheng Liu (1):
      drivers/net/usb: add device id for NVIDIA Tegra USB 3.0 Ethernet

 MAINTAINERS                                        |   1 +
 arch/arm/boot/dts/dra7-evm.dts                     |   5 ++-
 arch/arm/boot/dts/dra72-evm.dts                    |   5 ++-
 drivers/net/bonding/bond_main.c                    |  51 +++++++++++++=
++--------
 drivers/net/can/c_can/c_can.c                      |  10 ++++-
 drivers/net/can/dev.c                              |   7 +---
 drivers/net/can/rcar_can.c                         |  16 ++++---
 drivers/net/can/slcan.c                            |   2 +-
 drivers/net/can/vcan.c                             |   3 --
 drivers/net/ethernet/3com/3c59x.c                  |   4 +-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |   3 +-
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           |  11 +++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  17 +++++---
 drivers/net/ethernet/amd/xgbe/xgbe.h               |   3 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     |   4 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  25 +++++------
 drivers/net/ethernet/cisco/enic/enic_main.c        |   4 +-
 drivers/net/ethernet/freescale/fec_main.c          |  88 +++++++++++++=
++++++++++++++++++++------
 drivers/net/ethernet/sfc/ef10.c                    | 172 +++++++++++++=
++++++++++++++++++++++++++++++++++++++++++++++++++------------
 drivers/net/ethernet/sfc/ef10_sriov.c              |  59 +++++--------=
-------------
 drivers/net/ethernet/sfc/ef10_sriov.h              |   6 +++
 drivers/net/ethernet/sfc/efx.c                     |  14 +++++++
 drivers/net/ethernet/sfc/net_driver.h              |   2 +
 drivers/net/ethernet/sfc/tx.c                      |   3 +-
 drivers/net/ethernet/ti/cpsw.c                     |  25 ++++-------
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |   8 ++--
 drivers/net/hamradio/bpqether.c                    |   1 +
 drivers/net/macvtap.c                              |   1 +
 drivers/net/phy/Kconfig                            |   2 +-
 drivers/net/usb/cdc_ether.c                        |   8 ++++
 drivers/net/usb/cdc_mbim.c                         |   2 +-
 drivers/net/usb/cdc_ncm.c                          |  63 +++++++++++++=
+++++++++++----
 drivers/net/usb/huawei_cdc_ncm.c                   |   7 +++-
 drivers/net/usb/r8152.c                            |   2 +
 drivers/net/vmxnet3/vmxnet3_drv.c                  |   8 ++--
 drivers/net/wan/z85230.c                           |   2 +-
 include/linux/can/skb.h                            |   2 +
 include/linux/usb/cdc_ncm.h                        |   7 +++-
 include/uapi/linux/netconf.h                       |   1 +
 lib/rhashtable.c                                   |   4 +-
 net/bluetooth/hidp/core.c                          |   1 +
 net/bluetooth/l2cap_core.c                         |   4 +-
 net/bridge/br_forward.c                            |   1 +
 net/bridge/br_mdb.c                                |  16 ++++---
 net/bridge/br_netfilter_hooks.c                    |  16 ++++---
 net/bridge/br_netfilter_ipv6.c                     |   2 +-
 net/bridge/br_netlink.c                            |   2 +
 net/can/af_can.c                                   |  12 +++---
 net/can/bcm.c                                      |   2 +
 net/can/raw.c                                      |   7 ++--
 net/core/dev.c                                     |  45 ++++++++++---=
-------
 net/core/gen_estimator.c                           |  13 +++---
 net/core/pktgen.c                                  |   9 +---
 net/core/rtnetlink.c                               | 187 +++++++++++++=
+++++++++++++++++++++++++++++----------------------------------------
 net/dsa/dsa.c                                      |   6 +--
 net/ipv4/devinet.c                                 |  13 ++++++
 net/ipv4/inet_diag.c                               |   4 +-
 net/ipv4/ip_tunnel.c                               |   8 ++--
 net/ipv4/netfilter/arp_tables.c                    |  25 +++++++----
 net/ipv6/ip6_input.c                               |   6 +--
 net/ipv6/route.c                                   |   5 +--
 net/netfilter/nf_queue.c                           |   2 +-
 net/netfilter/nfnetlink.c                          |  38 +++++++++++--=
----
 net/netlink/af_netlink.c                           |   2 +-
 net/rds/transport.c                                |   2 +-
 net/switchdev/switchdev.c                          |  12 ++++--
 net/tipc/socket.c                                  |   1 +
 68 files changed, 705 insertions(+), 396 deletions(-)
