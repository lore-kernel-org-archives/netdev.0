From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v4 0/2] net: sched: fix some issues
Date: Tue, 3 Dec 2013 11:26:52 +0800
Message-ID: <1386041214-72744-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:12232 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab3LCD1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 22:27:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix calculation of max_size in tbf
fix quantum calculation introduced by 64bit rates.

v2
  patch 1/2: redescribe the regression.
  patch 2/2: add Eric's ack.

v3
  patch 1/2: use psched_l2t_ns to calculate max_size
  and cleanup exit/done section suggested by Jesper.

v4
  patch 1/2:
  1.Update commit message suggested by Jesper.
  2.Use a macro to replace 65535 constant.
  3.Add condition that when peakrate is lower than rate, return -EINVAL.
  4.Don't use cell_log anymore.

Yang Yingliang (2):
  net: sched: tbf: fix calculation of max_size
  net: sched: htb: fix calculation of quantum

 net/sched/sch_htb.c | 18 ++++++-----
 net/sched/sch_tbf.c | 91 ++++++++++++++++++++++++++++++-----------------------
 2 files changed, 61 insertions(+), 48 deletions(-)

-- 
1.8.0
