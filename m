From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 01 Apr 2016 20:04:18 -0400 (EDT)
Message-ID: <20160401.200418.1955162623018529637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Missing device reference in IPSEC input path results in crashes duri=
ng
   device unregistration.  From Subash Abhinov Kasiviswanathan.

2) Per-queue ISR register writes not being done properly in macb driver=
,
   from Cyrille Pitchen.

3) Stats accounting bugs in bcmgenet, from Patri Gynther.

4) Lightweight tunnel's TTL and TOS were swapped in netlink dumps,
   from Quentin Armitage.

5) SXGBE driver has off-by-one in probe error paths, from Rasmus
   Villemoes.

6) Fix race in save/swap/delete options in netfilter ipset, from
   Vishwanath Pai.

7) Ageing time of bridge not set properly when not operating over a
   switchdev device.  Fix from Haishuang Yan.

8) Fix GRO regression wrt. nested FOU/GUE based tunnels, from
   Alexander Duyck.

9) IPV6 UDP code bumps wrong stats, from Eric Dumazet.

10) FEC driver should only access registers that actually exist on
    the given chipset, fix from Fabio Estevam.

Please pull, thanks a lot!

The following changes since commit e46b4e2b46e173889b19999b8bd033d5e8b3=
acf0:

  Merge tag 'trace-v4.6' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/rostedt/linux-trace (2016-03-24 10:52:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to db5dd0db2d8352bb7fd5e9d16e17b79d66c7e4e3=
:

  net: mvneta: fix changing MTU when using per-cpu processing (2016-04-=
01 15:16:37 -0400)

----------------------------------------------------------------
Alexander Duyck (3):
      ixgbe: Store VXLAN port number in network order
      ixgbe: Fix ATR so that it correctly handles IPv6 extension header=
s
      gro: Allow tunnel stacking in the case of FOU/GUE

Arnd Bergmann (1):
      openvswitch: call only into reachable nf-nat code

Bjorn Helgaas (1):
      netpoll: Fix extra refcount release in netpoll_cleanup()

Bj=F8rn Mork (1):
      qmi_wwan: add "D-Link DWM-221 B1" device id

Charles Keepax (1):
      net: macb: Only call GPIO functions if there is a valid GPIO

Colin Ian King (1):
      qed: initialize return rc to avoid returning garbage

Cosmin-Gabriel Samoila (1):
      Drivers: isdn: hisax: isac.c: Fix assignment and check into one e=
xpression.

Cyrille Pitchen (2):
      net: macb: replace macb_writel() call by queue_writel() to update=
 queue ISR
      net: macb: remove BUG_ON() and reset the queue to handle RX error=
s

Daniel Borkmann (3):
      bpf: add missing map_flags to bpf_map_show_fdinfo
      bpf: make padding in bpf_tunnel_key explicit
      tun, bpf: fix suspicious RCU usage in tun_{attach, detach}_filter

Daniele Palmas (1):
      net: usb: cdc_ncm: adding Telit LE910 V2 mobile broadband card

David S. Miller (4):
      Merge branch 'hns-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/net-que=
ue
      Merge branch 'stmmac-fixes'

Diego Viola (1):
      drivers/net/usb/plusb.c: Fix typo

Emil Tantilov (2):
      ixgbevf: fix error code path when setting MAC address
      ixgbe: make __ixgbe_setup_tc static

Eric Dumazet (1):
      ipv6: udp: fix UDP_MIB_IGNOREDMULTI updates

=46abio Estevam (1):
      fec: Do not access unexisting register in Coldfire

=46lorian Westphal (3):
      netfilter: x_tables: validate e->target_offset early
      netfilter: x_tables: make sure e->next_offset covers remaining bl=
ob size
      netfilter: x_tables: fix unconditional helper

Giuseppe CAVALLARO (3):
      stmmac: fix TX normal DESC
      Revert "stmmac: Fix 'eth0: No PHY found' regression"
      stmmac: fix MDIO settings

Haishuang Yan (2):
      openvswitch: Use proper buffer size in nla_memcpy
      bridge: Allow set bridge ageing time when switchdev disabled

Jaedon Shin (1):
      net: phy: bcm7xxx: Add entries for Broadcom BCM7346 and BCM7362

Jarno Rajahalme (1):
      openvswitch: Fix checking for new expected connections.

Jisheng Zhang (5):
      net: mvpp2: replace MVPP2_CPU_D_CACHE_LINE_SIZE with L1_CACHE_BYT=
ES
      net: mvneta: replace MVNETA_CPU_D_CACHE_LINE_SIZE with L1_CACHE_B=
YTES
      net: mvpp2: fix maybe-uninitialized warning
      net: mvpp2: use cache_line_size() to get cacheline size
      net: mvneta: use cache_line_size() to get cacheline size

Kejian Yan (1):
      net: hns: fix warning of passing zero to 'PTR_ERR'

Lino Sanfilippo (1):
      ravb: fix software timestamping

Liping Zhang (1):
      netfilter: ipv4: fix NULL dereference

Lisheng (2):
      net: hns: fixed the setting and getting overtime bug
      net: hns: set-coalesce-usecs returns errno by dsaf.ko

Manish Chopra (1):
      qlge: Update version to 1.00.00.35

Marcelo Ricardo Leitner (1):
      sctp: really allow using GFP_KERNEL on sctp_packet_transmit

Marcin Wojtas (1):
      net: mvneta: fix changing MTU when using per-cpu processing

Mark Rustad (1):
      ixgbe: Use udelay to avoid sleeping while atomic

Michael Chan (3):
      bnxt_en: Implement proper firmware message padding.
      bnxt_en: Fix typo in bnxt_hwrm_set_pause_common().
      bnxt_en: Fix ethtool -a reporting.

Nicolas Dichtel (2):
      switchdev: fix typo in comments/doc
      rtnl: fix msg size calculation in if_nlmsg_size()

Pablo Neira Ayuso (2):
      netfilter: nfnetlink_queue: honor NFQA_CFG_F_FAIL_OPEN when netli=
nk unicast fails
      netfilter: x_tables: enforce nul-terminated table name from getso=
ckopt GET_ENTRIES

Patrick Uiterwijk (2):
      net: dsa: mv88e6xxx: Introduce _mv88e6xxx_phy_page_{read, write}
      net: dsa: mv88e6xxx: Clear the PDOWN bit on setup

Petri Gynther (2):
      net: bcmgenet: fix dev->stats.tx_bytes accounting
      net: bcmgenet: fix skb_len in bcmgenet_xmit_single()

Prashant Sreedharan (1):
      bnxt_en: Initialize CP doorbell value before ring allocation

Qianqian Xie (4):
      net: hns: fix a bug for cycle index
      net: hns: optimizate fmt of snprintf()
      net: hns: bug fix for return values
      net: hns: remove useless variable assignment and comment

Quentin Armitage (1):
      Fix returned tc and hoplimit values for route with IPv6 encapsula=
tion

Rasmus Villemoes (1):
      net: sxgbe: fix error paths in sxgbe_platform_probe()

Sheng Li (2):
      net: hns: optimizate irq proccess for HNS V2
      net: hns: bug fix about getting hilink status for HNS v2

Sridhar Samudrala (3):
      ixgbe: fix error handling in TC cls_u32 offload routines
      ixgbe: Fix cls_u32 offload support for fields with masks
      ixgbe: Fix cls_u32 offload support for L4 ports

Stefan Assmann (2):
      ixgbe: call ndo_stop() instead of dev_close() when running offlin=
e selftest
      ixgbevf: call ndo_stop() instead of dev_close() when running offl=
ine selftest

Tushar Dave (1):
      ixgbe: Fix for RAR0 not being set to default MAC addr

Vishwanath Pai (1):
      netfilter: ipset: fix race condition in ipset save, swap and dele=
te

Xin Long (1):
      team: team should sync the port's uc/mc addrs when add a port

subashab@codeaurora.org (1):
      xfrm: Fix crash observed during device unregistration and decrypt=
ion

 Documentation/networking/switchdev.txt                |   2 +-
 drivers/isdn/hisax/isac.c                             |  15 ++--
 drivers/net/dsa/mv88e6xxx.c                           |  85 ++++++++++=
+++++++----
 drivers/net/dsa/mv88e6xxx.h                           |   8 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt.c             |  10 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h             |   2 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c     |   6 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c        |  16 ++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.h        |   6 ++
 drivers/net/ethernet/cadence/macb.c                   |  69 ++++++++++=
+++----
 drivers/net/ethernet/freescale/fec_main.c             |   2 +-
 drivers/net/ethernet/hisilicon/hns/hnae.h             |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c     |  64 ++++++----=
------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c    |   3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c    |  12 +--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c    |  40 +++++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c     | 196 ++++++++++=
+++++++++++++--------------------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h     |  23 +++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h     |   3 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c         |  16 ++--
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c      |  10 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h              |  10 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c      |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         | 165 ++++++++++=
+++++++++----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h        |  21 ++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c         |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c          |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h          |   2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c     |  16 ++--
 drivers/net/ethernet/intel/ixgbevf/vf.c               |   4 +-
 drivers/net/ethernet/marvell/mvneta.c                 |  40 +++++-----
 drivers/net/ethernet/marvell/mvpp2.c                  |  18 +----
 drivers/net/ethernet/qlogic/qed/qed_int.c             |   2 +-
 drivers/net/ethernet/qlogic/qlge/qlge.h               |   2 +-
 drivers/net/ethernet/renesas/ravb_main.c              |   2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c   |   4 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c       |  16 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  16 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c     |  10 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  91 ++++++++++=
++++++-------
 drivers/net/phy/bcm7xxx.c                             |   4 +
 drivers/net/team/team.c                               |   5 ++
 drivers/net/tun.c                                     |   8 +-
 drivers/net/usb/cdc_ncm.c                             |   7 ++
 drivers/net/usb/plusb.c                               |   2 +-
 drivers/net/usb/qmi_wwan.c                            |   1 +
 include/linux/brcmphy.h                               |   2 +
 include/linux/filter.h                                |   4 +
 include/linux/netfilter/ipset/ip_set.h                |   4 +
 include/linux/stmmac.h                                |   1 -
 include/uapi/linux/bpf.h                              |   1 +
 kernel/bpf/syscall.c                                  |   6 +-
 net/bridge/br_stp.c                                   |   2 +-
 net/bridge/netfilter/ebtables.c                       |   4 +
 net/bridge/netfilter/nft_reject_bridge.c              |  20 ++---
 net/core/filter.c                                     |  38 ++++++----
 net/core/netpoll.c                                    |   3 +-
 net/core/rtnetlink.c                                  |   1 +
 net/ipv4/fou.c                                        |  16 ++++
 net/ipv4/ip_tunnel_core.c                             |   4 +-
 net/ipv4/netfilter/arp_tables.c                       |  43 ++++++----=
-
 net/ipv4/netfilter/ip_tables.c                        |  48 ++++++----=
--
 net/ipv4/netfilter/ipt_SYNPROXY.c                     |  54 +++++++---=
----
 net/ipv6/netfilter/ip6_tables.c                       |  48 ++++++----=
