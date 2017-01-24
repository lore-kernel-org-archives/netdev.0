From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 0/3] qed: RoCE infrastrucutre fixes
Date: Tue, 24 Jan 2017 23:15:20 +0200
Message-ID: <1485292523-8821-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series contains three RoCE bug fixes that improve stability and
robustness.

Dave,

Please consider applying these to 'net'.

Thanks,
Yuval

Ram Amrani (3):
  qed: on failure release CQ resource under lock
  qed: read queue state before releasing buffer
  qed: don't free a QP more than once

 drivers/net/ethernet/qlogic/qed/qed_roce.c | 63 +++++++++++++++++-------------
 1 file changed, 35 insertions(+), 28 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
