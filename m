From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/5] RDMA/cxgb4,cxgb4vf,csiostor: Cleanup macros
Date: Fri, 21 Nov 2014 12:52:00 +0530
Message-ID: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, praveen@chelsio.com,
	varun@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This series continues to cleanup all the macros/register defines related to
filter, port, VI, queue, RSS, LDST, firmware, etc that are defined in t4fw_api.h
and the affected files.

Will post few more series so that we can cover all the macros so that they all
follow the same style to be consistent.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4, cxgb4vf, iw_cxgb4 and csiostor driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (5):
  RDMA/cxgb4: Cleanup Filter related macros/register defines
  RDMA/cxgb4/csiostor: Cleansup FW related macros/register defines for
    PF/VF and LDST
  cxgb4/cxgb4vf/csiostor: Cleanup macros/register defines related to
    queues
  cxgb4/cxgb4vf/csiostor: Cleanup macros/register defines related to
    port and VI
  RDMA/cxgb4/cxgb4vf/csiostor: Cleanup macros/register defines related
    to PCIE, RSS and FW

 drivers/infiniband/hw/cxgb4/cm.c                   |   16 +-
 drivers/infiniband/hw/cxgb4/provider.c             |    8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c     |   14 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h     |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  193 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  115 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  292 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      | 2121 +++++++++++++-------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   26 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   63 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  232 ++--
 drivers/scsi/csiostor/csio_hw.c                    |   38 +-
 drivers/scsi/csiostor/csio_init.c                  |    8 +-
 drivers/scsi/csiostor/csio_mb.c                    |  171 +-
 drivers/scsi/csiostor/csio_mb.h                    |   12 +-
 17 files changed, 2004 insertions(+), 1321 deletions(-)

