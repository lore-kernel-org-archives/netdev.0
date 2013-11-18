From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v2 0/2] net: sched: fix some issues
Date: Mon, 18 Nov 2013 16:39:22 +0800
Message-ID: <1384763964-5000-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:65183 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab3KRIjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 03:39:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a regression introduced by commit b757c9336d63f94c6b57532
(tbf: improved accuracy at high rates).
fix quantum calculation introduced by 64bit rates.

v2
  patch 1/2: redescribe the regression
  patch 2/2: add Eric's ack

Yang Yingliang (2):
  net: sched: tbf: fix calculation of max_size
  net: sched: htb: fix calculation of quantum

 include/net/sch_generic.h | 46 ++++++++++++++++++++++++++++++++
 net/sched/sch_htb.c       | 18 +++++++------
 net/sched/sch_tbf.c       | 67 ++++++++++++++++++++++++++---------------------
 3 files changed, 93 insertions(+), 38 deletions(-)

-- 
1.8.0
