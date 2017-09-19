From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 0/4] qed: iWARP fixes and enhancements
Date: Tue, 19 Sep 2017 20:26:15 +0300
Message-ID: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series includes several fixes and enhancements
related to iWARP.

Patch #1 is actually the last of the initial iWARP submission.
It has been delayed until now as I wanted to make sure that qedr
supports iWARP prior to enabling iWARP device detection.

iWARP changes in RDMA tree have been accepted and targeted at
kernel 4.15, therefore, all iWARP fixes for this cycle are
submitted to net-next.

Signed-off by: Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Michal Kalderon (4):
  qed: Add iWARP enablement support
  qed: Add iWARP out of order support
  qed: Fix maximum number of CQs for iWARP
  qed: iWARP - Add check for errors on a SYN packet

 drivers/net/ethernet/qlogic/qed/qed_cxt.c         |  6 +++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c       | 52 +++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h       | 11 ++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c         |  1 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         | 10 ++---
 drivers/net/ethernet/qlogic/qed/qed_rdma.c        | 24 +++++++----
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  1 +
 include/linux/qed/qed_ll2_if.h                    |  1 +
 8 files changed, 91 insertions(+), 15 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
