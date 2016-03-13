From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 00/12] cxgb4 patch series for cxgbit.ko
Date: Sun, 13 Mar 2016 19:49:22 +0530
Message-ID: <cover.1457877852.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <target-devel-owner@vger.kernel.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicholas,

   I am posting cxgb4 patch series as
   suggested by you in following email thread

   http://www.spinics.net/lists/target-devel/msg12437.html

   This series consists of patches from
   initial cxgb4 series without any change.

Thanks
Varun

Varun Prakash (12):
  cxgb4: add new ULD type CXGB4_ULD_ISCSIT
  cxgb4: allocate resources for CXGB4_ULD_ISCSIT
  cxgb4: large receive offload support
  cxgb4, iw_cxgb4: move definitions to common header file
  cxgb4, iw_cxgb4, cxgb4i: remove duplicate definitions
  cxgb4, cxgb4i: move struct cpl_rx_data_ddp definition
  cxgb4: add definitions for iSCSI target ULD
  cxgb4: update struct cxgb4_lld_info definition
  cxgb4: move VLAN_NONE macro definition
  cxgb4, iw_cxgb4: move delayed ack macro definitions
  cxgb4: add iSCSI DDP page pod manager
  cxgb4: update Kconfig and Makefile

 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h          |  99 -----
 drivers/net/ethernet/chelsio/Kconfig               |  11 +
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  27 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  34 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  97 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c     | 464 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h     | 310 ++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |  11 +
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |   2 -
 drivers/net/ethernet/chelsio/cxgb4/l2t.h           |   2 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        | 217 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   7 +
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h                 |  17 -
 15 files changed, 1174 insertions(+), 138 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h

-- 
2.0.2
