From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] RDMA/cxgb4,cxgb4vf,cxgb4i,csiostor: Cleanup macros
Date: Mon,  3 Nov 2014 17:46:51 +0530
Message-ID: <1415017014-12701-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	praveenm@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:53019
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752155AbaKCMMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 07:12:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series moves the debugfs code to a new file debugfs.c, Cleans up macros so
that they match the hardware generated one.

Will post few more series so that we can cover all the macros so that they all
follow the same conventions and looks clean.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4, cxgb4vf, iw_cxgb4, csiostor and cxgb4i driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  cxgb4: Add cxgb4_debugfs.c, move all debugfs code to new file
  cxgb4: Cleanup macros to match the HW generated one
  cxgb4: Cleanup macros to match the HW generated one, part 2

 drivers/infiniband/hw/cxgb4/cm.c                   |   56 +++---
 drivers/infiniband/hw/cxgb4/cq.c                   |    8 +-
 drivers/infiniband/hw/cxgb4/mem.c                  |   14 +-
 drivers/infiniband/hw/cxgb4/qp.c                   |   26 ++--
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    3 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h     |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  158 ++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   52 ++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  173 +++++---------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   15 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   32 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  127 +++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   72 +++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  142 ++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   32 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  150 +++++++++---------
 drivers/scsi/csiostor/csio_attr.c                  |    8 +-
 drivers/scsi/csiostor/csio_hw.c                    |   14 +-
 drivers/scsi/csiostor/csio_hw_t4.c                 |   15 +-
 drivers/scsi/csiostor/csio_hw_t5.c                 |   21 ++-
 drivers/scsi/csiostor/csio_init.c                  |    6 +-
 drivers/scsi/csiostor/csio_lnode.c                 |   18 +-
 drivers/scsi/csiostor/csio_mb.c                    |  172 ++++++++++----------
 drivers/scsi/csiostor/csio_scsi.c                  |   24 ++--
 drivers/scsi/csiostor/csio_wr.h                    |    2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |   35 ++--
 28 files changed, 816 insertions(+), 568 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
