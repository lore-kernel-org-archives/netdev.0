From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 00/20] slight optimization of addr compare for
 net modules
Date: Sat, 28 Dec 2013 14:16:56 +0800
Message-ID: <52BE6CD8.3040300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the second patchset for slight optimization of address compare,
mainly for net tree, just following the Joe's opinion, it will help review
the code for maintainers and supports.

v2: Change some style for patch 2.
    According Eric's suggestion, use the ether_addr_equal_64bits to instead
    of ether_addr_equal for patch 19.
    In fact, there are a lot of places which could use ether_addr_equal_64bits
    to instead of ether_addr_equal, but not this time, thanks for Joe's
    opinion.

Best Regards
Ding

Ding Tianhong (20):
  net: 3com: slight optimization of addr compare
  net: bnx2x: slight optimization of addr compare
  net: cxgb3: slight optimization of addr compare
  net: enic: slight optimization of addr compare
  net: benet: slight optimization of addr compare
  net: igbvf: slight optimization of addr compare
  net: ixgbe: slight optimization of addr compare
  net: mlx4: slight optimization of addr compare
  net: ksz884x: slight optimization of addr compare
  net: vxge: slight optimization of addr compare
  net: packetengines: slight optimization of addr compare
  net: netxen: slight optimization of addr compare
  net: qlcnic: slight optimization of addr compare
  net: renesas: slight optimization of addr compare
  net: seeq: slight optimization of addr compare
  net: sun: optimization of addr compare
  net: ti: slight optimization of addr compare
  net: fddi: slight optimization of addr compare
  net: plip: slight optimization of addr compare
  net: caif: slight optimization of addr compare

 drivers/net/ethernet/3com/3c509.c                     |  3 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c        | 10 ++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c      |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c    |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/l2t.c              |  2 +-
 drivers/net/ethernet/cisco/enic/enic_pp.c             |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |  2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c             |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c        |  3 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 drivers/net/ethernet/micrel/ksz884x.c                 |  9 ++++-----
 drivers/net/ethernet/neterion/vxge/vxge-main.c        |  2 +-
 drivers/net/ethernet/packetengines/yellowfin.c        |  8 ++------
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c    |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c        |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  4 ++--
 drivers/net/ethernet/renesas/sh_eth.c                 |  2 +-
 drivers/net/ethernet/seeq/sgiseeq.c                   |  2 +-
 drivers/net/ethernet/sun/sunvnet.c                    |  2 +-
 drivers/net/ethernet/ti/cpsw_ale.c                    |  2 +-
 drivers/net/fddi/skfp/fplustm.c                       |  3 ++-
 drivers/net/plip/plip.c                               |  2 +-
 net/caif/cfrfml.c                                     |  2 +-
 26 files changed, 38 insertions(+), 46 deletions(-)

-- 
1.8.0
