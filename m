From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 0/2] Doorbell drop Avoidance Bug fix for iw_cxgb4
Date: Fri, 14 Mar 2014 21:52:06 +0530
Message-ID: <1394814128-8815-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

This patch series provides fixes for Chelsio T4/T5 adapters
related to DB Drop avoidance and other small fix related to keepalive on
iw-cxgb4.

The patches series is created against David Miller's 'net-next' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

We would like to request this patch series to get merged via David Miller's
'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks


Steve Wise (2):
  cxgb4/iw_cxgb4: Treat CPL_ERR_KEEPALV_NEG_ADVICE as negative advice
  cxgb4/iw_cxgb4: Doorbell Drop Avoidance Bug Fixes

 drivers/infiniband/hw/cxgb4/cm.c                |  24 ++--
 drivers/infiniband/hw/cxgb4/device.c            | 177 ++++++++++++++----------
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   9 +-
 drivers/infiniband/hw/cxgb4/provider.c          |  43 +++++-
 drivers/infiniband/hw/cxgb4/qp.c                | 140 +++++++++----------
 drivers/infiniband/hw/cxgb4/t4.h                |   6 +
 drivers/infiniband/hw/cxgb4/user.h              |   5 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  87 +++++++-----
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   1 +
 11 files changed, 299 insertions(+), 202 deletions(-)

-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
