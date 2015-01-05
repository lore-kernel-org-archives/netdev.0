From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 0/5] RDMA/cxgb4/cxgb4vf/csiostor: Cleanup register defines
Date: Mon,  5 Jan 2015 16:30:42 +0530
Message-ID: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This series continues to cleanup all the macros/register defines related to
SGE, PCIE, MC, MA, TCAM, MAC, etc that are defined in t4_regs.h and the
affected files.

Will post another 1 or 2 series so that we can cover all the macros so that
they all follow the same style to be consistent.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4, cxgb4vf, iw_cxgb4 and csiostor driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (5):
  RDMA/cxgb4/cxgb4vf/csiostor: Cleanup SGE register defines
  cxgb4/cxgb4vf/csiostor: Cleanup SGE and PCI related register defines
  cxgb4/cxg4vf/csiostor: Cleanup MC, MA and CIM related register
    defines
  cxgb4/csiostor: Cleanup TP, MPS and TCAM related register defines
  cxgb4/cxgb4vf/csiostor: Cleanup PL, XGMAC, SF and MC related register
    defines

 drivers/infiniband/hw/cxgb4/t4.h                   |   26 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  266 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |    9 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  174 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  960 ++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 2749 ++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |  118 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   40 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   47 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h   |    4 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   43 +-
 drivers/scsi/csiostor/csio_hw.c                    |  515 ++--
 drivers/scsi/csiostor/csio_hw.h                    |    8 +-
 drivers/scsi/csiostor/csio_hw_chip.h               |   14 +-
 drivers/scsi/csiostor/csio_hw_t4.c                 |  144 +-
 drivers/scsi/csiostor/csio_hw_t5.c                 |  150 +-
 drivers/scsi/csiostor/csio_isr.c                   |    2 +-
 drivers/scsi/csiostor/csio_mb.c                    |   53 +-
 drivers/scsi/csiostor/csio_wr.c                    |  154 +-
 19 files changed, 3151 insertions(+), 2325 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_values.h

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
