From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH for-next 0/3] Add TOS support and some cleanup
Date: Fri,  5 Feb 2016 11:43:27 +0530
Message-ID: <1454652810-25086-1-git-send-email-hariprasad@chelsio.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This series adds TOS support for iWARP and also does some cleanup to make
code more readable. Patch series is created against infiniband tree and 
includes patches on iw_cxgb4 and cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  iw_cxgb4: make queue allocation code more readable
  iw_cxgb4: remove false error log entry
  cxgb4/iw_cxgb4: TOS support

 drivers/infiniband/hw/cxgb4/cm.c              | 54 +++++++++++-------
 drivers/infiniband/hw/cxgb4/qp.c              | 81 ++++++++++++++-------------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h   |  2 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  1 +
 4 files changed, 80 insertions(+), 58 deletions(-)

-- 
2.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
