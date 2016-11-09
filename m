From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 0/2] qed: Fix RoCE infrastructure
Date: Wed, 9 Nov 2016 22:48:42 +0200
Message-ID: <1478724524-16940-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series fixes 2 basic issues with RoCE support,
one handles a missing configuration in the initial infrastructure
support while the other is a regression introduced by one of the
initial fix submissions.

Dave,

I've built this series against 'net'  [specifically on top of
cdb26d3387f0 ("net: bgmac: fix reversed checks for clock control flag")],
but I'm not entirely convinced whether that's the right place for them -
On one-hand, they're RoCE-specific fixes, but they're also infrastructure
fixes that are wholly contained inside qed.
Would like to hear your [and Doug's] preference on whether we should
target such patches to net or linux-rdma.

Thanks,
Yuval

Ram Amrani (2):
  qed: configure ll2 RoCE v1/v2 flavor correctly
  qed: correct rdma params configuration

 drivers/net/ethernet/qlogic/qed/qed_hsi.h  |  3 ---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c  |  1 +
 drivers/net/ethernet/qlogic/qed/qed_main.c | 17 ++++++++---------
 3 files changed, 9 insertions(+), 12 deletions(-)

-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
