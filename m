From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/2] Remove duplicate register definitions in Chelsio cxgb4
Date: Fri, 31 Aug 2012 14:54:30 +0530
Message-ID: <1346405072-24561-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, sivasu-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David Miller/Roland,

This patch series has minor changes in cxgb4 driver. It removes the duplicate
definitions of the registers in cxgb4 driver. It also has a minor update in
RDMA/cxgb4 driver due to change in cxgb4 driver.

This patch series is built against Stephen Rothwell's linux-next tree. We
request to merge patch series thorough single tree to avoid build failures.

Thanks,
Vipul Pandya

Vipul Pandya (2):
  cxgb4: Remove duplicate register definitions
  RDMA/cxgb4: Update RDMA/cxgb4 due to macro definition removal in
    cxgb4 driver

 drivers/infiniband/hw/cxgb4/qp.c                |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   18 ++++----
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   12 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   54 +++++-----------------
 5 files changed, 31 insertions(+), 59 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
