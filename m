From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 0/2] All Chelsio drivers : Cleanup CPL messages macros
Date: Thu,  8 Jan 2015 21:38:14 -0800
Message-ID: <1420781896-25337-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series cleans up all register defines/MACROS defined in t4_msg.h and
affected files as part of the continuing cleanup effort

The patches series is created against 'net-next' tree and  includes patches 
to the cxgb4, cxgb4vf, iw_cxgb4, cxgb4i and csiostor drivers.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

-Anish

Hariprasad Shenai (2):
  RDMA/cxgb4/cxgb4i: Cleanup register defines/MACROS related to CM CPL
    messages
  RDMA/cxgb4/cxgb4vf/cxgb4i/csiostor: Cleanup register defines/MACROS
    related to all other cpl

 drivers/infiniband/hw/cxgb4/cm.c                   |  98 +++---
 drivers/infiniband/hw/cxgb4/mem.c                  |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  16 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   9 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        | 367 +++++++++++++++------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   4 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   6 +-
 drivers/scsi/csiostor/csio_lnode.c                 |   2 +-
 drivers/scsi/csiostor/csio_scsi.c                  |   4 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |  18 +-
 11 files changed, 356 insertions(+), 176 deletions(-)

-- 
2.2.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
