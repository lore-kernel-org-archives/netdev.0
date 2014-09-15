From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/5] net_sched: some fixes and cleanup for tcindex
Date: Mon, 15 Sep 2014 14:06:45 -0700
Message-ID: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:46956 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757873AbaIOVHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:07:04 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so7286070pab.10
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:07:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (5):
  net_sched: fix an allocation bug in tcindex_set_parms()
  net_sched: fix memory leak in cls_tcindex
  net_sched: fix suspicious RCU usage in tcindex_classify()
  net_sched: use tcindex_filter_result_init()
  net_sched: clean up tcindex_set_parms()

 net/sched/cls_tcindex.c | 34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

-- 
1.8.3.1
