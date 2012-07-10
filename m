From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH v2 net-next 0/5] Cleanup, mostly kernel-doc
Date: Tue, 10 Jul 2012 21:53:24 +0100
Message-ID: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41096 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751213Ab2GJUx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 16:53:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I spotted some minor errors in the RSS policy changes, and one thing led
to another and I ended up with all this.

v2: Avoid leaving comments starting with '/*\n'.
    Fix a few more non-kernel-doc comments.

Ben Hutchings (5):
  net: Properly define functions with no parameters
  net: Fix (nearly-)kernel-doc comments for various functions
  net: Fix non-kernel-doc comments with kernel-doc start marker
  drivers/net/ethernet: Fix (nearly-)kernel-doc comments for various
    functions
  drivers/net/ethernet: Fix non-kernel-doc comments with kernel-doc
    start markers

 drivers/net/cris/eth_v10.c                         |    2 +-
 drivers/net/ethernet/3com/3c501.c                  |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   68 ++--
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   70 ++--
 drivers/net/ethernet/atheros/atl1e/atl1e_param.c   |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |   41 +--
 drivers/net/ethernet/atheros/atlx/atl2.c           |   56 +--
 drivers/net/ethernet/atheros/atlx/atlx.c           |   10 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    9 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |   36 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    5 +-
 drivers/net/ethernet/broadcom/cnic.c               |    4 +-
 drivers/net/ethernet/brocade/bna/bfa_cee.c         |   97 ++----
 drivers/net/ethernet/brocade/bna/bfa_cs.h          |   34 +--
 drivers/net/ethernet/brocade/bna/bfa_defs.h        |   63 +---
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h    |   15 +-
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   35 +--
 drivers/net/ethernet/brocade/bna/bfa_defs_status.h |    3 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c         |  393 +++++++-------------
 drivers/net/ethernet/brocade/bna/bfa_ioc.h         |   43 +--
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      |   48 +--
 drivers/net/ethernet/brocade/bna/bfa_msgq.c        |    4 +-
 drivers/net/ethernet/brocade/bna/bfi.h             |   81 +---
 drivers/net/ethernet/brocade/bna/bfi_cna.h         |   42 +--
 drivers/net/ethernet/brocade/bna/bfi_enet.h        |  107 ++----
 drivers/net/ethernet/brocade/bna/bfi_reg.h         |    4 +-
 drivers/net/ethernet/brocade/bna/bna.h             |   51 +--
 drivers/net/ethernet/brocade/bna/bna_enet.c        |   15 +-
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h     |   33 +--
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |   17 +-
 drivers/net/ethernet/brocade/bna/bna_types.h       |   66 +---
 drivers/net/ethernet/brocade/bna/bnad.c            |   12 +-
 drivers/net/ethernet/brocade/bna/bnad.h            |    4 +-
 drivers/net/ethernet/chelsio/cxgb3/sge.c           |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c         |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |    2 +-
 drivers/net/ethernet/ethoc.c                       |    4 +-
 drivers/net/ethernet/freescale/fec.c               |    4 +-
 drivers/net/ethernet/ibm/ehea/ehea_qmr.c           |    4 +-
 drivers/net/ethernet/intel/e1000/e1000_hw.c        |    8 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    9 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    1 +
 drivers/net/ethernet/intel/igbvf/netdev.c          |    1 +
 drivers/net/ethernet/intel/igbvf/vf.c              |    5 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   41 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |   38 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |    8 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    6 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |    8 +-
 drivers/net/ethernet/micrel/ksz884x.c              |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |   10 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.h     |    3 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |    5 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |   12 +-
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |   10 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   42 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |    4 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h               |    3 +-
 drivers/net/ethernet/sfc/net_driver.h              |    2 +-
 drivers/net/ethernet/sfc/rx.c                      |    1 +
 drivers/net/ethernet/smsc/smc911x.c                |    6 +-
 drivers/net/ethernet/smsc/smc91x.c                 |    6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c               |  177 +++++----
 drivers/net/ethernet/ti/davinci_emac.c             |   78 ++--
 drivers/net/ethernet/toshiba/spider_net.c          |    6 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    2 +-
 net/9p/trans_virtio.c                              |    2 +-
 net/appletalk/ddp.c                                |    8 +-
 net/batman-adv/bridge_loop_avoidance.c             |   51 ++-
 net/batman-adv/hash.h                              |    3 +-
 net/batman-adv/main.h                              |    3 +-
 net/batman-adv/types.h                             |    3 +-
 net/ceph/pagelist.c                                |   14 +-
 net/core/dev.c                                     |   10 +-
 net/core/rtnetlink.c                               |    2 +-
 net/core/skbuff.c                                  |    5 +-
 net/dcb/dcbnl.c                                    |    3 +-
 net/dccp/ackvec.h                                  |    7 +-
 net/dccp/ccid.c                                    |    1 +
 net/dccp/ccids/ccid3.c                             |    8 +-
 net/dccp/ccids/lib/loss_interval.c                 |    1 +
 net/dccp/ccids/lib/packet_history.c                |    3 +-
 net/dccp/ccids/lib/tfrc_equation.c                 |    2 +
 net/dccp/dccp.h                                    |    1 +
 net/dccp/feat.c                                    |   10 +
 net/dccp/input.c                                   |    1 +
 net/dccp/options.c                                 |    1 +
 net/dccp/output.c                                  |    1 +
 net/ethernet/eth.c                                 |    3 +
 net/ipv4/ipmr.c                                    |    4 +-
 net/ipv4/tcp.c                                     |    3 +-
 net/ipv6/ip6_tunnel.c                              |    2 +-
 net/llc/af_llc.c                                   |    2 +-
 net/llc/llc_station.c                              |   16 +-
 net/mac80211/mesh.c                                |    2 +-
 net/mac80211/mesh_hwmp.c                           |    7 +-
 net/mac80211/mesh_pathtbl.c                        |    4 +-
 net/mac80211/mesh_plink.c                          |    5 +-
 net/mac80211/rx.c                                  |    2 +-
 net/netfilter/xt_TPROXY.c                          |    4 +-
 net/netlink/genetlink.c                            |    2 +-
 net/rds/page.c                                     |    9 +-
 net/rxrpc/ar-output.c                              |    2 +-
 net/sunrpc/backchannel_rqst.c                      |    9 +-
 net/sunrpc/clnt.c                                  |    2 +-
 net/sunrpc/xdr.c                                   |   12 +-
 net/sunrpc/xprt.c                                  |    2 +-
 net/tipc/bcast.c                                   |   10 +-
 net/tipc/bearer.c                                  |    7 +-
 net/tipc/bearer.h                                  |    2 +-
 net/tipc/link.c                                    |   22 +-
 net/tipc/name_table.c                              |   10 +-
 net/tipc/port.c                                    |    2 +-
 net/tipc/port.h                                    |    1 +
 net/tipc/socket.c                                  |    5 +-
 net/x25/x25_route.c                                |    2 +-
 127 files changed, 893 insertions(+), 1424 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
