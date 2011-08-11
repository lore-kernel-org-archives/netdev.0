From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10] drivers/net organize Ethernet drivers (2nd series)
Date: Thu, 11 Aug 2011 02:51:24 -0700
Message-ID: <1313056294-28426-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33305 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754492Ab1HKJvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 05:51:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second of seven 10 patch series to move the Ethernet
drivers into drivers/net/ethernet/

The following are changes since commit 628a604842b68cb0fc483e7cd5fcfb836be633d5:
  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (10):
  ni5010: Move the Racal-Interlan (Micom) driver
  cassini/niu/sun*: Move the Sun drivers
  sfc: Move the Solarflare drivers
  be2net: Move the Emulex driver
  bna: Move the Brocade driver
  mlx4: Move the Mellanox driver
  myri*: Move the Myricom drivers
  s2io/vxge: Move the Exar drivers
  ehea/ibm*: Move the IBM drivers
  enic: Move the Cisco driver

 MAINTAINERS                                        |   20 +-
 drivers/net/Kconfig                                |  225 --------------------
 drivers/net/Makefile                               |   23 +--
 drivers/net/benet/Kconfig                          |    6 -
 drivers/net/ethernet/Kconfig                       |   10 +
 drivers/net/ethernet/Makefile                      |   10 +
 drivers/net/ethernet/brocade/Kconfig               |   22 ++
 drivers/net/ethernet/brocade/Makefile              |    5 +
 drivers/net/ethernet/brocade/bna/Kconfig           |   17 ++
 drivers/net/{ => ethernet/brocade}/bna/Makefile    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_cee.c   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_cee.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_cs.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_defs.h  |    0
 .../net/{ => ethernet/brocade}/bna/bfa_defs_cna.h  |    0
 .../{ => ethernet/brocade}/bna/bfa_defs_mfg_comm.h |    0
 .../{ => ethernet/brocade}/bna/bfa_defs_status.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.c   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.h   |    0
 .../net/{ => ethernet/brocade}/bna/bfa_ioc_ct.c    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_cna.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_ll.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_reg.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bna.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_ctrl.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_hw.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_txrx.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_types.h |    0
 drivers/net/{ => ethernet/brocade}/bna/bnad.c      |    0
 drivers/net/{ => ethernet/brocade}/bna/bnad.h      |    0
 .../net/{ => ethernet/brocade}/bna/bnad_ethtool.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/cna.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/cna_fwimg.c |    0
 drivers/net/ethernet/cisco/Kconfig                 |   22 ++
 drivers/net/ethernet/cisco/Makefile                |    5 +
 drivers/net/ethernet/cisco/enic/Kconfig            |    9 +
 drivers/net/{ => ethernet/cisco}/enic/Makefile     |    0
 drivers/net/{ => ethernet/cisco}/enic/cq_desc.h    |    0
 .../net/{ => ethernet/cisco}/enic/cq_enet_desc.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic.h       |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_dev.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_dev.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_main.c  |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_pp.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_pp.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_res.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_res.h   |    0
 .../net/{ => ethernet/cisco}/enic/rq_enet_desc.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_cq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_cq.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_dev.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_dev.h   |    0
 .../net/{ => ethernet/cisco}/enic/vnic_devcmd.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_enet.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_intr.c  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_intr.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_nic.h   |    0
 .../net/{ => ethernet/cisco}/enic/vnic_resource.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rq.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rss.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_stats.h |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_vic.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_vic.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_wq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_wq.h    |    0
 .../net/{ => ethernet/cisco}/enic/wq_enet_desc.h   |    0
 drivers/net/ethernet/emulex/Kconfig                |   22 ++
 drivers/net/ethernet/emulex/Makefile               |    5 +
 drivers/net/ethernet/emulex/benet/Kconfig          |    6 +
 drivers/net/{ => ethernet/emulex}/benet/Makefile   |    0
 drivers/net/{ => ethernet/emulex}/benet/be.h       |    0
 drivers/net/{ => ethernet/emulex}/benet/be_cmds.c  |    0
 drivers/net/{ => ethernet/emulex}/benet/be_cmds.h  |    0
 .../net/{ => ethernet/emulex}/benet/be_ethtool.c   |    0
 drivers/net/{ => ethernet/emulex}/benet/be_hw.h    |    0
 drivers/net/{ => ethernet/emulex}/benet/be_main.c  |    0
 drivers/net/ethernet/ibm/Kconfig                   |   47 ++++
 drivers/net/ethernet/ibm/Makefile                  |    8 +
 drivers/net/{ => ethernet/ibm}/ehea/Makefile       |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea.h         |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h      |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c     |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h     |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/Kconfig |   40 ++--
 .../{ibm_newemac => ethernet/ibm/emac}/Makefile    |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/core.c  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/core.h  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/debug.c |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/debug.h |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/emac.h  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/mal.c   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/mal.h   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/phy.c   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/phy.h   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/rgmii.c |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/rgmii.h |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/tah.c   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/tah.h   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/zmii.c  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/zmii.h  |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.c           |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.h           |    0
 drivers/net/{ => ethernet/ibm}/iseries_veth.c      |    0
 drivers/net/ethernet/mellanox/Kconfig              |   22 ++
 drivers/net/ethernet/mellanox/Makefile             |    5 +
 drivers/net/ethernet/mellanox/mlx4/Kconfig         |   27 +++
 drivers/net/{ => ethernet/mellanox}/mlx4/Makefile  |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/alloc.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/catas.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/cmd.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/cq.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_cq.c   |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_ethtool.c  |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_main.c |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_netdev.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_port.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_port.h |    0
 .../{ => ethernet/mellanox}/mlx4/en_resources.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_rx.c   |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_selftest.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_tx.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/eq.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/fw.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/fw.h      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/icm.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/icm.h     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/intf.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/main.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mcg.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mlx4.h    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mlx4_en.h |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mr.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/pd.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/port.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/profile.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/qp.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/reset.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/sense.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/srq.c     |    0
 drivers/net/ethernet/myricom/Kconfig               |   46 ++++
 drivers/net/ethernet/myricom/Makefile              |    5 +
 .../net/{ => ethernet/myricom}/myri10ge/Makefile   |    0
 .../net/{ => ethernet/myricom}/myri10ge/myri10ge.c |    0
 .../{ => ethernet/myricom}/myri10ge/myri10ge_mcp.h |    0
 .../myricom}/myri10ge/myri10ge_mcp_gen_header.h    |    0
 drivers/net/ethernet/neterion/Kconfig              |   54 +++++
 drivers/net/ethernet/neterion/Makefile             |    6 +
 drivers/net/{ => ethernet/neterion}/s2io-regs.h    |    0
 drivers/net/{ => ethernet/neterion}/s2io.c         |    0
 drivers/net/{ => ethernet/neterion}/s2io.h         |    0
 drivers/net/{ => ethernet/neterion}/vxge/Makefile  |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-config.c |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-config.h |    0
 .../{ => ethernet/neterion}/vxge/vxge-ethtool.c    |    0
 .../{ => ethernet/neterion}/vxge/vxge-ethtool.h    |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-main.c   |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-main.h   |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-reg.h    |    0
 .../{ => ethernet/neterion}/vxge/vxge-traffic.c    |    0
 .../{ => ethernet/neterion}/vxge/vxge-traffic.h    |    0
 .../{ => ethernet/neterion}/vxge/vxge-version.h    |    0
 drivers/net/ethernet/racal/Kconfig                 |   32 +++
 drivers/net/ethernet/racal/Makefile                |    5 +
 drivers/net/{ => ethernet/racal}/ni5010.c          |    0
 drivers/net/{ => ethernet/racal}/ni5010.h          |    0
 drivers/net/{ => ethernet}/sfc/Kconfig             |    4 +-
 drivers/net/{ => ethernet}/sfc/Makefile            |    0
 drivers/net/{ => ethernet}/sfc/bitfield.h          |    0
 drivers/net/{ => ethernet}/sfc/efx.c               |    0
 drivers/net/{ => ethernet}/sfc/efx.h               |    0
 drivers/net/{ => ethernet}/sfc/enum.h              |    0
 drivers/net/{ => ethernet}/sfc/ethtool.c           |    0
 drivers/net/{ => ethernet}/sfc/falcon.c            |    0
 drivers/net/{ => ethernet}/sfc/falcon_boards.c     |    0
 drivers/net/{ => ethernet}/sfc/falcon_xmac.c       |    0
 drivers/net/{ => ethernet}/sfc/filter.c            |    0
 drivers/net/{ => ethernet}/sfc/filter.h            |    0
 drivers/net/{ => ethernet}/sfc/io.h                |    0
 drivers/net/{ => ethernet}/sfc/mac.h               |    0
 drivers/net/{ => ethernet}/sfc/mcdi.c              |    0
 drivers/net/{ => ethernet}/sfc/mcdi.h              |    0
 drivers/net/{ => ethernet}/sfc/mcdi_mac.c          |    0
 drivers/net/{ => ethernet}/sfc/mcdi_pcol.h         |    0
 drivers/net/{ => ethernet}/sfc/mcdi_phy.c          |    0
 drivers/net/{ => ethernet}/sfc/mdio_10g.c          |    0
 drivers/net/{ => ethernet}/sfc/mdio_10g.h          |    0
 drivers/net/{ => ethernet}/sfc/mtd.c               |    0
 drivers/net/{ => ethernet}/sfc/net_driver.h        |    0
 drivers/net/{ => ethernet}/sfc/nic.c               |    0
 drivers/net/{ => ethernet}/sfc/nic.h               |    0
 drivers/net/{ => ethernet}/sfc/phy.h               |    0
 drivers/net/{ => ethernet}/sfc/qt202x_phy.c        |    0
 drivers/net/{ => ethernet}/sfc/regs.h              |    0
 drivers/net/{ => ethernet}/sfc/rx.c                |    0
 drivers/net/{ => ethernet}/sfc/selftest.c          |    0
 drivers/net/{ => ethernet}/sfc/selftest.h          |    0
 drivers/net/{ => ethernet}/sfc/siena.c             |    0
 drivers/net/{ => ethernet}/sfc/spi.h               |    0
 drivers/net/{ => ethernet}/sfc/tenxpress.c         |    0
 drivers/net/{ => ethernet}/sfc/tx.c                |    0
 drivers/net/{ => ethernet}/sfc/txc43128_phy.c      |    0
 drivers/net/{ => ethernet}/sfc/workarounds.h       |    0
 drivers/net/ethernet/sun/Kconfig                   |   86 ++++++++
 drivers/net/ethernet/sun/Makefile                  |   11 +
 drivers/net/{ => ethernet/sun}/cassini.c           |    0
 drivers/net/{ => ethernet/sun}/cassini.h           |    0
 drivers/net/{ => ethernet/sun}/niu.c               |    0
 drivers/net/{ => ethernet/sun}/niu.h               |    0
 drivers/net/{ => ethernet/sun}/sunbmac.c           |    0
 drivers/net/{ => ethernet/sun}/sunbmac.h           |    0
 drivers/net/{ => ethernet/sun}/sungem.c            |    0
 drivers/net/{ => ethernet/sun}/sungem.h            |    0
 drivers/net/{ => ethernet/sun}/sungem_phy.c        |    0
 drivers/net/{ => ethernet/sun}/sungem_phy.h        |    0
 drivers/net/{ => ethernet/sun}/sunhme.c            |    0
 drivers/net/{ => ethernet/sun}/sunhme.h            |    0
 drivers/net/{ => ethernet/sun}/sunqe.c             |    0
 drivers/net/{ => ethernet/sun}/sunqe.h             |    0
 drivers/net/{ => ethernet/sun}/sunvnet.c           |    0
 drivers/net/{ => ethernet/sun}/sunvnet.h           |    0
 drivers/net/spider_net.h                           |    2 +-
 227 files changed, 521 insertions(+), 286 deletions(-)
 delete mode 100644 drivers/net/benet/Kconfig
 create mode 100644 drivers/net/ethernet/brocade/Kconfig
 create mode 100644 drivers/net/ethernet/brocade/Makefile
 create mode 100644 drivers/net/ethernet/brocade/bna/Kconfig
 rename drivers/net/{ => ethernet/brocade}/bna/Makefile (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_cee.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_cee.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_cs.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_mfg_comm.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_status.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc_ct.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_ll.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_reg.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_ctrl.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_hw.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_txrx.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_types.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad_ethtool.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/cna_fwimg.c (100%)
 create mode 100644 drivers/net/ethernet/cisco/Kconfig
 create mode 100644 drivers/net/ethernet/cisco/Makefile
 create mode 100644 drivers/net/ethernet/cisco/enic/Kconfig
 rename drivers/net/{ => ethernet/cisco}/enic/Makefile (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/cq_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/cq_enet_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_dev.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_dev.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_main.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_pp.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_pp.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_res.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_res.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/rq_enet_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_cq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_cq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_dev.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_dev.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_devcmd.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_enet.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_intr.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_intr.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_nic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_resource.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rss.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_stats.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_vic.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_vic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_wq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_wq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/wq_enet_desc.h (100%)
 create mode 100644 drivers/net/ethernet/emulex/Kconfig
 create mode 100644 drivers/net/ethernet/emulex/Makefile
 create mode 100644 drivers/net/ethernet/emulex/benet/Kconfig
 rename drivers/net/{ => ethernet/emulex}/benet/Makefile (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_cmds.c (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_cmds.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_ethtool.c (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_hw.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_main.c (100%)
 create mode 100644 drivers/net/ethernet/ibm/Kconfig
 create mode 100644 drivers/net/ethernet/ibm/Makefile
 rename drivers/net/{ => ethernet/ibm}/ehea/Makefile (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/Kconfig (63%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/Makefile (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/core.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/core.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/debug.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/debug.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/emac.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/mal.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/mal.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/phy.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/phy.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/rgmii.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/rgmii.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/tah.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/tah.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/zmii.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/zmii.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.h (100%)
 rename drivers/net/{ => ethernet/ibm}/iseries_veth.c (100%)
 create mode 100644 drivers/net/ethernet/mellanox/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/Kconfig
 rename drivers/net/{ => ethernet/mellanox}/mlx4/Makefile (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/alloc.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/catas.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/cmd.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/cq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_cq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_ethtool.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_main.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_netdev.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_port.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_port.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_resources.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_rx.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_selftest.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_tx.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/eq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/fw.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/fw.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/icm.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/icm.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/intf.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/main.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mcg.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mlx4.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mlx4_en.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mr.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/pd.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/port.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/profile.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/qp.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/reset.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/sense.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/srq.c (100%)
 create mode 100644 drivers/net/ethernet/myricom/Kconfig
 create mode 100644 drivers/net/ethernet/myricom/Makefile
 rename drivers/net/{ => ethernet/myricom}/myri10ge/Makefile (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge.c (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge_mcp.h (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge_mcp_gen_header.h (100%)
 create mode 100644 drivers/net/ethernet/neterion/Kconfig
 create mode 100644 drivers/net/ethernet/neterion/Makefile
 rename drivers/net/{ => ethernet/neterion}/s2io-regs.h (100%)
 rename drivers/net/{ => ethernet/neterion}/s2io.c (100%)
 rename drivers/net/{ => ethernet/neterion}/s2io.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/Makefile (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-config.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-config.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-ethtool.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-ethtool.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-main.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-main.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-reg.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-traffic.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-traffic.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-version.h (100%)
 create mode 100644 drivers/net/ethernet/racal/Kconfig
 create mode 100644 drivers/net/ethernet/racal/Makefile
 rename drivers/net/{ => ethernet/racal}/ni5010.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni5010.h (100%)
 rename drivers/net/{ => ethernet}/sfc/Kconfig (96%)
 rename drivers/net/{ => ethernet}/sfc/Makefile (100%)
 rename drivers/net/{ => ethernet}/sfc/bitfield.h (100%)
 rename drivers/net/{ => ethernet}/sfc/efx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/efx.h (100%)
 rename drivers/net/{ => ethernet}/sfc/enum.h (100%)
 rename drivers/net/{ => ethernet}/sfc/ethtool.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon_boards.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon_xmac.c (100%)
 rename drivers/net/{ => ethernet}/sfc/filter.c (100%)
 rename drivers/net/{ => ethernet}/sfc/filter.h (100%)
 rename drivers/net/{ => ethernet}/sfc/io.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mac.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_mac.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_pcol.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mdio_10g.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mdio_10g.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mtd.c (100%)
 rename drivers/net/{ => ethernet}/sfc/net_driver.h (100%)
 rename drivers/net/{ => ethernet}/sfc/nic.c (100%)
 rename drivers/net/{ => ethernet}/sfc/nic.h (100%)
 rename drivers/net/{ => ethernet}/sfc/phy.h (100%)
 rename drivers/net/{ => ethernet}/sfc/qt202x_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/regs.h (100%)
 rename drivers/net/{ => ethernet}/sfc/rx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/selftest.c (100%)
 rename drivers/net/{ => ethernet}/sfc/selftest.h (100%)
 rename drivers/net/{ => ethernet}/sfc/siena.c (100%)
 rename drivers/net/{ => ethernet}/sfc/spi.h (100%)
 rename drivers/net/{ => ethernet}/sfc/tenxpress.c (100%)
 rename drivers/net/{ => ethernet}/sfc/tx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/txc43128_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/workarounds.h (100%)
 create mode 100644 drivers/net/ethernet/sun/Kconfig
 create mode 100644 drivers/net/ethernet/sun/Makefile
 rename drivers/net/{ => ethernet/sun}/cassini.c (100%)
 rename drivers/net/{ => ethernet/sun}/cassini.h (100%)
 rename drivers/net/{ => ethernet/sun}/niu.c (100%)
 rename drivers/net/{ => ethernet/sun}/niu.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunbmac.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunbmac.h (100%)
 rename drivers/net/{ => ethernet/sun}/sungem.c (100%)
 rename drivers/net/{ => ethernet/sun}/sungem.h (100%)
 rename drivers/net/{ => ethernet/sun}/sungem_phy.c (100%)
 rename drivers/net/{ => ethernet/sun}/sungem_phy.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunhme.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunhme.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunqe.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunqe.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunvnet.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunvnet.h (100%)

-- 
1.7.6

