From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 24 Jan 2012 18:33:15 -0500 (EST)
Message-ID: <20120124.183315.1848457736103329038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix JIT code generation on x86-64 for divide by zero, from Eric Duma=
zet.

2) tg3 header length computation correction from Eric Dumazet.

3) More build and reference counting fixes for socket memory cgroup
   code from Glauber Costa.

4) module.h snuck back into a core header after all the hard work we
   did to remove that, from Paul Gortmaker and Jesper Dangaard Brouer.

5) Fix PHY naming regression and add some new PCI IDs in stmmac, from
   Alessandro Rubini.

6) Netlink message generation fix in new team driver, should only adver=
tise
   the entries that changed during events, from Jiri Pirko.

7) SRIOV VF registration and unregistration fixes, and also add a
   missing PCI ID, from Roopa Prabhu.

8) Fix infinite loop in tx queue flush code of brcmsmac, from Stanislaw=
 Gruszka.

9) ftgmac100/ftmac100 build fix, missing interrupt.h include.

10) Memory leak fix in net/hyperv do_set_mutlicast() handling, from Wei=
 Yongjun.

11) Off by one fix in netem packet scheduler, from Vijay Subramanian.

12) TCP loss detection fix from Yuchung Cheng.

13) TCP reset packet MD5 calculation uses wrong address, fix from Shawn=
 Lu.

14) skge carrier assertion and DMA mapping fixes from Stephen Hemminger=
=2E

15) Congestion recovery undo performed at the wrong spot in BIC and CUB=
IC
    congestion control modules, fix from Neal Cardwell.

16) Ethtool ETHTOOL_GSSET_INFO is unnecessarily restrictive, from Micha=
=A9=A9 Miros=A9=A9aw.

17) Fix triggerable race in ipv6 sysctl handling, from Francesco Rugger=
i.

18) Statistics bug fixes in mlx4 from Eugenia Emantayev.

19) rds locking bug fix during info dumps, from your's truly.

Please pull, thanks a lot.

The following changes since commit 4a7cbb56fdbd92a47f57ca8b25bf5db35f0d=
6518:

  regulator: Fix documentation for of_node parameter of regulator_regis=
ter() (2012-01-24 10:40:06 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Alessandro Rubini (2):
      stmmac: fix phy naming inconsistency
      stmmac: added PCI identifiers

Alexander Duyck (1):
      ixgbe: Fix register defines to correctly handle complex expressio=
ns

Ariel Elior (1):
      bnx2x: handle CHIP_REVISION during init_one

Carolyn Wyborny (1):
      igb: Update Copyright on all Intel copyrighted files.

Chris Healy (1):
      dsa: Add reporting of silicon revision for Marvell 88E6123/88E616=
1/88E6165 switches.

Darren Hart (1):
      pch_gbe: Do not abort probe on bad MAC

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss
      bluetooth: hci: Fix type of "enable_hs" to bool.
      rds: Make rds_sock_lock BH rather than IRQ safe.

Dmitry Kravkov (2):
      bnx2x: fix Big-Endianess in ethtool -t
      bnx2x: allow user to change ring size in ISCSI SD mode

Eric Dumazet (3):
      net: bpf_jit: fix divide by 0 generation
      macvlan: fix a possible use after free
      tg3: fix ipv6 header length computation

Eugenia Emantayev (3):
      mlx4_en: clear all eth statistics when port goes up
      mlx4: VF is not allowed to perform dump stats
      mlx4_en: eth statistics modification

=46rancesco Ruggeri (1):
      net: race condition in ipv6 forwarding and disable_ipv6 parameter=
s

Glauber Costa (3):
      net: fix socket memcg build with !CONFIG_NET
      cgroup: make sure memcg margin is 0 when over limit
      net: introduce res_counter_charge_nofail() for socket allocations

Greg Rose (1):
      ixgbevf: Prevent possible race condition by checking for message

Javier Cardona (1):
      mac80211: Use the right headroom size for mesh mgmt frames

Jesper Dangaard Brouer (1):
      net: flow_dissector.c missing include linux/export.h

Jiri Bohac (1):
      bonding: fix enslaving in alb mode when link down

Jiri Pirko (1):
      team: send only changed options/ports via netlink

Johannes Berg (2):
      mac80211: fix debugfs key->station symlink
      mac80211: fix work removal on deauth request

John W. Linville (1):
      b43: add option to avoid duplicating device support with brcmsmac

Marcel Apfelbaum (3):
      mlx4_core: removed function index from vf.
      mlx4_core: Fix mtt profile issue
      mlx4_core: map async events to arbitrary slave eqs

Micha=A9=A9 Miros=A9=A9aw (1):
      ethtool: allow ETHTOOL_GSSET_INFO for users

Mitch A Williams (1):
      igbvf: Remove unnecessary irq disable/enable

Neal Cardwell (2):
      tcp: fix undo after RTO for BIC
      tcp: fix undo after RTO for CUBIC

Paul Gortmaker (3):
      pktgen: Fix unsigned function that is returning negative vals
      drivers/net: dsa/mv88e6xxx.c files need linux/module.h
      netprio_cgroup.h: dont include module.h from other includes

Paulius Zaleckas (1):
      mv643xx_eth: Add Rx Discard and Rx Overrun statistics

Radu Iliescu (1):
      llc: Fix race condition in llc_ui_recvmsg

Randy Dunlap (2):
      kernel-doc: fix new warning in net/phy/mdio_bus.c
      kernel-doc: fix new warning in net/sock.h

Roopa Prabhu (5):
      enic: This patch adds pci id 0x71 for SRIOV VF's
      enic: Add sriov vf device id checks in port profile code
      enic: rearrange some of the port profile code
      enic: fix location of vnic dev unregister in enic_probe cleanup c=
ode
      enic: fix compile when CONFIG_PCI_IOV is not enabled

Sathya Perla (1):
      be2net: create RSS rings even in multi-channel configs

Stanislaw Gruszka (1):
      brcmsmac: fix tx queue flush infinite loop

Stephen Hemminger (5):
      igb: make local functions static
      igbvf: remove unneeded cast
      ixgbevf: make ethtool ops and strings const
      ixgbevf: fix sparse warnings
      ixgbevf: make operations tables const

Thomas Faber (1):
      net: ftgmac100/ftmac100: add missing interrupt.h include

Vijay Subramanian (1):
      netem: Fix off-by-one bug in reordering

Wei Yongjun (1):
      net/hyperv: fix possible memory leak in do_set_multicast()

Yevgeny Petrilin (1):
      mlx4_en: set number of rx rings used by RSS using ethtool

Yuchung Cheng (1):
      tcp: detect loss above high_seq in recovery

Yuval Mintz (3):
      bnx2x: credit-leakage fixup on vlan_mac_del_all
      bnx2x: fixed ethtool statistics for MF modes
      bnx2x: fix compilation error with SOE in fw_dump

shawnlu (1):
      tcp: md5: using remote adress for md5 lookup in rst packet

stephen hemminger (3):
      skge: don't assert carrier until link is up
      skge: check for PCI dma mapping errors
      skge: add byte queue limit support

 arch/x86/net/bpf_jit_comp.c                        |   36 +++--
 drivers/net/bonding/bond_alb.c                     |   27 +---
 drivers/net/dsa/mv88e6060.c                        |    1 +
 drivers/net/dsa/mv88e6123_61_65.c                  |   22 +++-
 drivers/net/dsa/mv88e6131.c                        |    1 +
 drivers/net/dsa/mv88e6xxx.c                        |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  111 ++++++------=
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   11 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |   44 ++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |   11 ++
 drivers/net/ethernet/broadcom/tg3.c                |    9 +-
 drivers/net/ethernet/cisco/enic/enic.h             |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |   38 +++--
 drivers/net/ethernet/emulex/benet/be_main.c        |    3 +-
 drivers/net/ethernet/faraday/ftgmac100.c           |    1 +
 drivers/net/ethernet/faraday/ftmac100.c            |    1 +
 drivers/net/ethernet/intel/igb/Makefile            |    2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c       |    2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h       |    2 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h     |    2 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h          |    2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c         |    4 +-
 drivers/net/ethernet/intel/igb/e1000_mac.h         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.h         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.h         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.h         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h        |    2 +-
 drivers/net/ethernet/intel/igb/igb.h               |    2 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   10 +-
 drivers/net/ethernet/intel/igbvf/ethtool.c         |    3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |    5 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   32 ++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |    5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |    8 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |   41 +++---
 drivers/net/ethernet/intel/ixgbevf/mbx.c           |    3 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c            |    7 +-
 drivers/net/ethernet/intel/ixgbevf/vf.h            |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |   14 ++
 drivers/net/ethernet/marvell/skge.c                |  109 ++++++++++--=
--
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    9 +-
 drivers/net/ethernet/mellanox/mlx4/cq.c            |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  159 ++++++++++++=
++++++--
 drivers/net/ethernet/mellanox/mlx4/en_main.c       |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   38 ++++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    8 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   21 +--
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    7 -
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 -
 drivers/net/ethernet/mellanox/mlx4/main.c          |    3 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    8 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    3 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c            |    2 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c            |    3 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |   23 +++
 drivers/net/ethernet/mellanox/mlx4/profile.c       |    2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   39 +-----
 drivers/net/ethernet/mellanox/mlx4/srq.c           |    2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   17 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    6 +-
 drivers/net/hyperv/netvsc_drv.c                    |    5 +-
 drivers/net/macvlan.c                              |    1 +
 drivers/net/phy/mdio_bus.c                         |    5 +-
 drivers/net/team/team.c                            |  136 +++++++++++-=
-----
 drivers/net/wireless/b43/Kconfig                   |    6 +
 drivers/net/wireless/b43/main.c                    |    2 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   10 +-
 include/linux/if_team.h                            |   10 ++
 include/linux/mlx4/device.h                        |    1 +
 include/linux/res_counter.h                        |   11 ++-
 include/linux/snmp.h                               |    1 -
 include/net/bluetooth/hci.h                        |    2 +-
 include/net/netprio_cgroup.h                       |    1 -
 include/net/sock.h                                 |   13 +-
 kernel/res_counter.c                               |   25 +++
 mm/memcontrol.c                                    |    4 +-
 net/bluetooth/hci_core.c                           |    2 +-
 net/core/ethtool.c                                 |    1 +
 net/core/flow_dissector.c                          |    1 +
 net/core/pktgen.c                                  |    4 +-
 net/core/sock.c                                    |    4 +-
 net/ipv4/proc.c                                    |    1 -
 net/ipv4/tcp_bic.c                                 |   11 +-
 net/ipv4/tcp_cubic.c                               |   10 +-
 net/ipv4/tcp_input.c                               |   41 ++----
 net/ipv4/tcp_ipv4.c                                |    2 +-
 net/ipv6/addrconf.c                                |   61 +++++---
 net/ipv6/tcp_ipv6.c                                |    2 +-
 net/llc/af_llc.c                                   |    5 +
 net/mac80211/debugfs_key.c                         |    7 +-
 net/mac80211/mesh_hwmp.c                           |    8 +-
 net/mac80211/mesh_plink.c                          |    4 +-
 net/mac80211/mlme.c                                |   38 ++++--
 net/rds/af_rds.c                                   |   20 +--
 net/sched/sch_netem.c                              |    2 +-
 102 files changed, 904 insertions(+), 512 deletions(-)
