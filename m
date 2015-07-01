From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 30 Jun 2015 20:52:10 -0700 (PDT)
Message-ID: <20150630.205210.327198362662823294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbbGADwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 23:52:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) mlx4 driver bug fixes (TX queue wakeups, csum complete indications)
   from Ido Shamay, Eran Ben Elisha, and Or Gerlitz.

2) Missing unlock in error path of PTP support in renesas driver, from
   Dan Carpenter.

3) Add Vitesse 8641 phy IDs to vitesse PHY driver, from Shaohui Xie.

4) Bnx2x driver bug fixes (linearization of encap packets, scratchpad
   parity error notifications, flow-control and speed settings) from
   Yuval Mintz, Manish Chopra, Shahed Shaikh, and Ariel Elior.

5) ipv6 extension header parsing in the igb chip has a HW errata,
   disable it.  Frm Todd Fujinaka.

6) Fix PCI link state locking issue in e1000e driver, from Yanir
   Lubetkin.

7) Cure panics during MTU change in i40e, from Mitch Williams.

8) Don't leak promisc refs in DSA slave driver, from Gilad Ben-Yossef.

9) Add missing HAS_DMA dep to VIA Rhine driver, from Geery
   Uytterhoeven.

10) Make sure DMA map/unmap calls are symmetric in bnx2x driver,
    from Michal Schmidt.

11) Workaround for MDIO access problems in bcm7xxx devices, from
    FLorian Fainelli.

12) Fix races in SCTP protocol between OTTB responses and route
    removals, from Alexander Sverdlin.

13) Fix jumbo frame checksum issue with some mvneta devices, from
    Simon Guinot.

Please pull, thanks a lot!

The following changes since commit aefbef10e3ae6e2c6e3c54f906f10b34c73a2c66:

  Merge branch 'akpm' (patches from Andrew) (2015-06-24 20:47:21 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 7f4ef975e96ff1a050d4e496c59bbd33e28028ed:

  Merge branch 'mvneta-jumbo-frames' (2015-06-30 09:37:10 -0700)

----------------------------------------------------------------
Alexander Sverdlin (1):
      sctp: Fix race between OOTB responce and route removal

Alison Wang (1):
      net/fsl: remove dependency FSL_SOC for Gianfar

Andy Gospodarek (1):
      ipv4: fix RCU lockdep warning from linkdown changes

Ariel Elior (1):
      bnx2x: Fix statistics gathering on link change

Dan Carpenter (2):
      renesas: missing unlock on error path
      cavium/liquidio: fix some error handling in lio_set_phys_id()

David Miller (2):
      ax25: Stop using sock->sk_protinfo.
      net: Kill sock->sk_protinfo

David S. Miller (6):
      Merge branch 'mlx4'
      Merge branch 'bnx2x'
      Merge branch 'kill_sk_protinfo'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-queue
      Merge branch 'bcm7xxx_workaround'
      Merge branch 'mvneta-jumbo-frames'

Eran Ben Elisha (1):
      net/mlx4_en: Release TX QP when destroying TX ring

Eric Dumazet (1):
      bnx2x: fix lockdep splat

Florian Fainelli (3):
      net: phy: bcm7xxx: workaround MDIO management controller initial read
      net: bcmgenet: workaround initial read failures for integrated PHYs
      net: phy: mdio-bcm-unimac: workaround initial read failures for integrated PHYs

Geert Uytterhoeven (3):
      flow_dissector: Pre-initialize ip_proto in __skb_flow_dissect()
      drivers: net: xgene: Pre-initialize ret in xgene_enet_get_resources()
      net: via: VIA_RHINE and VIA_VELOCITY should depend on HAS_DMA

Gilad Ben-Yossef (1):
      dsa: fix promiscuity leak on slave dev open error

Govindarajulu Varadarajan (1):
      enic: use atomic_t instead of spin_lock in busy poll

Greg Ungerer (1):
      net: fec: don't access RACC register when not available

Ido Shamay (2):
      net/mlx4_en: Wake TX queues only when there's enough room
      net/mlx4_en: Fix wrong csum complete report when rxvlan offload is disabled

Jamal Hadi Salim (1):
      net: sched: flower fix typo

Jon Paul Maloy (1):
      tipc: purge backlog queue counters when broadcast link is reset

Li, Liang Z (1):
      xen-netfront: Remove the meaningless code

Manish Chopra (1):
      bnx2x: Don't notify about scratchpad parities

Markus Elfring (1):
      net-Liquidio: Delete unnecessary checks before the function call "vfree"

Michal Schmidt (1):
      bnx2x: fix DMA API usage

Mitch Williams (2):
      i40evf: fix panic during MTU change
      i40evf: don't configure unused RSS queues

Mugunthan V N (1):
      net: phy: fix phy link up when limiting speed via device tree

Nik Nyby (3):
      stmmac: Trivial: fix typo in constant name
      sis900: Trivial: Fix typos in enums
      net: icplus: fix typo in constant name

Or Gerlitz (1):
      mlx4: Disable HA for SRIOV PF RoCE devices

Shahed Shaikh (1):
      bnx2x: Fix VF MAC removal

Shaohui Xie (1):
      net/phy: Add Vitesse 8641 phy ID

Shengzhou Liu (1):
      net/phy: tune get_phy_c45_ids to support more c45 phy

Shreyas Bhatewara (1):
      vmxnet3: Bump up driver version number

Simon Guinot (3):
      net: mvneta: introduce compatible string "marvell, armada-xp-neta"
      ARM: mvebu: update Ethernet compatible string for Armada XP
      net: mvneta: disable IP checksum with jumbo frames for Armada 370

Stephen Hemminger (1):
      api: fix compatibility of linux/in.h with netinet/in.h

Todd Fujinaka (2):
      igb: disable IPv6 extension header processing
      igb: bump version of igb to 5.2.18

Tom Lendacky (1):
      amd-xgbe: Add the __GFP_NOWARN flag to Rx buffer allocation

Yanir Lubetkin (6):
      e1000e: fix locking issue with e1000e_disable_aspm
      e1000e: synchronization of MAC-PHY interface only on non- ME systems
      e1000e: i219 - fix to enable both ULP and EEE in Sx state
      e1000e: i219 - increase IPG for speed 10/100 full duplex
      e1000e: i219 - Increase minimum FIFO read/write min gap
      e1000e: i219 - k1 workaround for LPT is not required for SPT

Yuval Mintz (6):
      bnx2x: Correct asymmetric flow-control
      bnx2x: Correct speed from baseT into KR.
      bnx2x: Prevent false warning when accessing MACs
      bnx2x: Fix self-test for 20g devices
      bnx2x: Release nvram lock on error flow
      bnx2x: Fix linearization for encapsulated packets

 Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt |   2 +-
 arch/arm/boot/dts/armada-370-xp.dtsi                              |   2 --
 arch/arm/boot/dts/armada-370.dtsi                                 |   8 +++++
 arch/arm/boot/dts/armada-xp-mv78260.dtsi                          |   2 +-
 arch/arm/boot/dts/armada-xp-mv78460.dtsi                          |   2 +-
 arch/arm/boot/dts/armada-xp.dtsi                                  |  10 +++++-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c                         |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c                  |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h                       |  12 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c                   |  32 ++++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h                   |  12 ++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c               |  58 +++++++++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c                  |  43 +++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c                  |  60 +++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c                    |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h                    |   1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c                      |  54 ++++++++++++++++++++++++++---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c                |   5 +--
 drivers/net/ethernet/cavium/liquidio/octeon_device.c              |  11 ++----
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c                |   4 +--
 drivers/net/ethernet/cavium/liquidio/request_manager.c            |   3 +-
 drivers/net/ethernet/cisco/enic/enic_main.c                       |   4 +--
 drivers/net/ethernet/cisco/enic/vnic_rq.h                         |  91 +++++++++++++++----------------------------------
 drivers/net/ethernet/freescale/Kconfig                            |   4 +--
 drivers/net/ethernet/freescale/fec.h                              |   2 ++
 drivers/net/ethernet/freescale/fec_main.c                         |  30 +++++++++-------
 drivers/net/ethernet/icplus/ipg.c                                 |   2 +-
 drivers/net/ethernet/icplus/ipg.h                                 |   2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c                       | 126 +++++++++++++++++++++++++++++++++++++++++++++++++++++---------------
 drivers/net/ethernet/intel/e1000e/netdev.c                        |  38 ++++++++++++++++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c                     |   4 +++
 drivers/net/ethernet/intel/i40evf/i40evf.h                        |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c                |   6 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c                   | 110 +++++++++++++++++++++++++----------------------------------
 drivers/net/ethernet/intel/igb/e1000_82575.c                      |  12 ++++---
 drivers/net/ethernet/intel/igb/e1000_defines.h                    |   3 +-
 drivers/net/ethernet/intel/igb/igb_main.c                         |   2 +-
 drivers/net/ethernet/marvell/mvneta.c                             |  27 ++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c                    |   4 ---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c                        |  17 ++++------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c                        |  20 ++++++-----
 drivers/net/ethernet/mellanox/mlx4/intf.c                         |   8 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h                      |   2 +-
 drivers/net/ethernet/renesas/ravb_ptp.c                           |   4 ++-
 drivers/net/ethernet/sis/sis900.h                                 |   4 +--
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c                    |   4 +--
 drivers/net/ethernet/via/Kconfig                                  |   2 ++
 drivers/net/phy/bcm7xxx.c                                         |   7 ++++
 drivers/net/phy/mdio-bcm-unimac.c                                 |  43 +++++++++++++++++++++++
 drivers/net/phy/phy_device.c                                      |  25 +++++++++-----
 drivers/net/phy/vitesse.c                                         |  14 ++++++++
 drivers/net/vmxnet3/vmxnet3_int.h                                 |   4 +--
 drivers/net/xen-netfront.c                                        |   7 ----
 include/net/ax25.h                                                |  16 ++++++++-
 include/net/sock.h                                                |   2 --
 include/uapi/linux/in.h                                           |  16 +++++++--
 include/uapi/linux/libc-compat.h                                  |  22 ++++++++++++
 net/ax25/af_ax25.c                                                |  30 ++++++++--------
 net/ax25/ax25_in.c                                                |   2 +-
 net/core/flow_dissector.c                                         |   2 +-
 net/core/sock.c                                                   |   1 -
 net/dsa/slave.c                                                   |   2 +-
 net/ipv4/fib_semantics.c                                          |   4 +--
 net/sched/cls_flower.c                                            |   4 +--
 net/sctp/output.c                                                 |   4 ++-
 net/sctp/socket.c                                                 |   6 ----
 net/tipc/bcast.c                                                  |   5 +++
 net/tipc/link.c                                                   |   2 +-
 net/tipc/link.h                                                   |   1 +
 69 files changed, 700 insertions(+), 375 deletions(-)
