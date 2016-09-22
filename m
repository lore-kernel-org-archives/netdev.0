From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 22 Sep 2016 03:52:43 -0400 (EDT)
Message-ID: <20160922.035243.1430811165206917354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Mostly small bits scattered all over the place, which is usually
how things go this late in the -rc series.

1) Proper driver init device resets in bnx2, from Baoquan He.

2) Fix accounting overflow in __tcp_retransmit_skb(), sk_forward_alloc,
   and ip_idents_reserve, from Eric Dumazet.

3) Fix crash in bna driver ethtool stats handling, from Ivan Vecera.

4) Missing check of skb_linearize() return value in mac80211, from
   Johannes Berg.

5) Endianness fix in nf_table_trace dumps, from Liping Zhang.

6) SSN comparison fix in SCTP, from Marcelo Ricardo Leitner.

7) Update DSA and b44 MAINTAINERS entries.

8) Make input path of vti6 driver work again, from Nicolas Dichtel.

9) Off-by-one in mlx4, from Sebastian Ott.

10) Fix fallback route lookup handling in ipv6, from Vincent Bernat.

11) Fix stack corruption on probe in qed driver, from Yuval Mintz.

12) PHY init fixes in r8152 from Hayes Wang.

13) Missing SKB free in irda_accept error path, from Phil Turnbull.

Please pull, thanks a lot!

The following changes since commit da499f8f5385c181e29978fdaab15a58de185302:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-09-12 07:56:06 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 7e32b44361abc77fbc01f2b97b045c405b2583e5:

  tcp: properly account Fast Open SYN-ACK retrans (2016-09-22 03:33:01 -0400)

----------------------------------------------------------------
Andrew Lunn (1):
      MAINTAINERS: Add an entry for the core network DSA code

Baoquan He (1):
      bnx2: Reset device during driver initialization

Beni Lev (1):
      iwlwifi: mvm: update TX queue before making a copy of the skb

Christophe Jaillet (1):
      drivers: net: phy: xgene: Fix 'remove' function

David S. Miller (11):
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'mac80211-for-davem-2016-09-13' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'batadv-net-for-davem-20160914' of git://git.open-mesh.org/linux-merge
      Merge branch 'qeth-fixes'
      Merge tag 'mac80211-for-davem-2016-09-16' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'mlx5-fixes'
      Merge tag 'linux-can-fixes-for-4.8-20160919' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'r8152-phy-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-09-20' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge tag 'linux-can-fixes-for-4.8-20160921' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec

Eric Dumazet (3):
      tcp: fix overflow in __tcp_retransmit_skb()
      net: avoid sk_forward_alloc overflows
      net: get rid of an signed integer overflow in ip_idents_reserve()

Fabio Estevam (1):
      can: flexcan: fix resume function

Felix Fietkau (2):
      mac80211: fix tim recalculation after PS response
      mac80211: fix sequence number assignment for PS response frames

Filipe Manco (1):
      xen-netback: fix error handling on netback_probe()

Gao Feng (1):
      netfilter: synproxy: Check oom when adding synproxy and seqadj ct extensions

Giuseppe CAVALLARO (1):
      stmmac: fix PWRDWN into the PMT register for global unicast.

Hans Wippel (1):
      qeth: restore device features after recovery

Hariprasad Shenai (1):
      cxgb4/cxgb4vf: Allocate more queues for 25G and 100G adapter

Ilan Tayari (1):
      xfrm: Fix memory leak of aead algorithm name

Ivan Mikhaylov (2):
      net/ibm/emac: add set mac addr callback
      net/ibm/emac: add mutex to 'set multicast list'

Ivan Vecera (2):
      bna: add missing per queue ethtool stat
      bna: fix crash in bnad_get_strings()

Johannes Berg (3):
      nl80211: validate number of probe response CSA counters
      mac80211: check skb_linearize() return value
      mac80211: reject TSPEC TIDs (TSIDs) for aggregation

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-09-15' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Kamal Heib (1):
      net/mlx4_core: Fix to clean devlink resources

Linus Lüssing (1):
      batman-adv: fix elp packet data reservation

Liping Zhang (2):
      netfilter: nf_tables_trace: fix endiness when dump chain policy
      netfilter: nft_chain_route: re-route before skb is queued to userspace

Marcelo Ricardo Leitner (1):
      sctp: fix SSN comparision

Marek Vasut (1):
      net: can: ifi: Configure transmitter delay

Mark Tomlinson (1):
      net: VRF: Pass original iif to ip_route_input()

Mathias Krause (1):
      xfrm_user: propagate sec ctx allocation errors

Michael Chan (1):
      MAINTAINERS: Update b44 maintainer.

Nicolas Dichtel (1):
      vti6: fix input path

Nikolay Aleksandrov (1):
      ipmr, ip6mr: return lastuse relative to now

Or Gerlitz (2):
      net/mlx5: E-Switch, Fix error flow in the SRIOV e-switch init code
      net/mlx5: E-Switch, Handle mode change failures

Pablo Neira Ayuso (1):
      netfilter: nf_nat: handle NF_DROP from nfnetlink_parse_nat_setup()

Pedersen, Thomas (1):
      mac80211: make mpath path fixing more robust

Roi Dayan (1):
      net/mlx5: Fix flow counter bulk command out mailbox allocation

Sean Wang (1):
      net: ethernet: mediatek: fix module loading automatically based on MODULE_DEVICE_TABLE

Sebastian Ott (1):
      net/mlx4_en: fix off by one in error handling

Sven Eckelmann (1):
      batman-adv: Add missing refcnt for last_candidate

Thomas Richter (1):
      s390/qeth: fix setting VIPA address

Ursula Braun (5):
      s390/qeth: use ip_lock for hsuid configuration
      s390/qeth: allow hsuid configuration in DOWN state
      qeth: check not more than 16 SBALEs on the completion queue
      qeth: do not limit number of gso segments
      qeth: do not turn on SG per default

Vincent Bernat (1):
      net: ipv6: fallback to full lookup if table lookup is unsuitable

Wei Yongjun (1):
      nfp: fix error return code in nfp_net_netdev_open()

Xin Long (1):
      sctp: hold the transport before using it in sctp_hash_cmp

Yuchung Cheng (2):
      tcp: fix under-accounting retransmit SNMP counters
      tcp: properly account Fast Open SYN-ACK retrans

Yuval Mintz (1):
      qed: Fix stack corruption on probe

hayeswang (5):
      r8152: move some functions
      r8152: move enabling PHY
      r8152: move PHY settings to hw_phy_cfg
      r8152: remove r8153_enable_eee
      r8152: disable ALDPS and EEE before setting PHY

phil.turnbull@oracle.com (1):
      irda: Free skb on irda_accept error path.

thomas.zeitlhofer+lkml@ze-it.at (1):
      vti: use right inner_mode for inbound inter address family policy checks

 MAINTAINERS                                                |  11 +-
 drivers/net/can/flexcan.c                                  |  13 ++-
 drivers/net/can/ifi_canfd/ifi_canfd.c                      |  11 +-
 drivers/net/ethernet/broadcom/bnx2.c                       |  12 ++-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c            |  57 ++++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h                 |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c            |  15 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c                 |   7 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h              |   6 ++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h         |  15 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c             |   9 +-
 drivers/net/ethernet/ibm/emac/core.c                       |  34 ++++++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c                |   1 +
 drivers/net/ethernet/mellanox/mlx4/eq.c                    |   4 +-
 drivers/net/ethernet/mellanox/mlx4/main.c                  |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c          |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c |  20 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c           |   4 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c        |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c                  |   4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c       |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c          |   2 +-
 drivers/net/phy/mdio-xgene.c                               |   6 +-
 drivers/net/usb/r8152.c                                    | 281 ++++++++++++++++++++++++++-------------------------
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                |  19 ++--
 drivers/net/xen-netback/xenbus.c                           |  46 ++++++---
 drivers/s390/net/qeth_core.h                               |   1 +
 drivers/s390/net/qeth_core_main.c                          |  32 +++++-
 drivers/s390/net/qeth_l2_main.c                            |   6 +-
 drivers/s390/net/qeth_l3_main.c                            |  29 ++++--
 drivers/s390/net/qeth_l3_sys.c                             |   5 +
 include/net/netfilter/nf_conntrack_synproxy.h              |  14 +++
 include/net/sctp/sm.h                                      |   2 +-
 include/net/sock.h                                         |  10 ++
 include/net/xfrm.h                                         |   4 +-
 net/batman-adv/bat_v_elp.c                                 |   2 +-
 net/batman-adv/routing.c                                   |  28 ++++-
 net/ipv4/ip_input.c                                        |   5 +-
 net/ipv4/ip_vti.c                                          |  15 ++-
 net/ipv4/ipmr.c                                            |   7 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c                  |  11 +-
 net/ipv4/route.c                                           |  10 +-
 net/ipv4/tcp_input.c                                       |   2 +-
 net/ipv4/tcp_output.c                                      |   7 +-
 net/ipv4/tcp_timer.c                                       |   1 +
 net/ipv6/ip6_vti.c                                         |  19 +++-
 net/ipv6/ip6mr.c                                           |   7 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c                  |  10 +-
 net/ipv6/route.c                                           |  11 +-
 net/ipv6/xfrm6_input.c                                     |  16 ++-
 net/ipv6/xfrm6_tunnel.c                                    |   2 +-
 net/irda/af_irda.c                                         |   5 +-
 net/mac80211/agg-rx.c                                      |   8 +-
 net/mac80211/agg-tx.c                                      |   3 +
 net/mac80211/mesh_hwmp.c                                   |   3 +-
 net/mac80211/mesh_pathtbl.c                                |   2 +-
 net/mac80211/sta_info.c                                    |   4 +-
 net/mac80211/tx.c                                          |  73 ++++++-------
 net/netfilter/nf_conntrack_core.c                          |   6 +-
 net/netfilter/nf_nat_core.c                                |   5 +-
 net/netfilter/nf_tables_trace.c                            |   2 +-
 net/sctp/input.c                                           |  27 +++--
 net/wireless/nl80211.c                                     |   2 +-
 net/xfrm/xfrm_state.c                                      |   1 +
 net/xfrm/xfrm_user.c                                       |   9 +-
 65 files changed, 658 insertions(+), 343 deletions(-)
