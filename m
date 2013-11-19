From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v3 0/2] net: sched: fix some issues
Date: Tue, 19 Nov 2013 15:25:37 +0800
Message-ID: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:32885 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab3KSH0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 02:26:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a regression introduced by commit b757c9336d63f94c6b57532
(tbf: improved accuracy at high rates).
fix quantum calculation introduced by 64bit rates.

v2
  patch 1/2: redescribe the regression.
  patch 2/2: add Eric's ack.

v3
  patch 1/2: use psched_l2t_ns to calculate max_size
  and cleanup exit/done section suggested by Jesper.

Yang Yingliang (2):
  net: sched: tbf: fix calculation of max_size
  net: sched: htb: fix calculation of quantum

 net/sched/sch_htb.c | 18 ++++++++------
 net/sched/sch_tbf.c | 71 ++++++++++++++++++++++++++++-------------------------
 2 files changed, 47 insertions(+), 42 deletions(-)

-- 
1.8.0
