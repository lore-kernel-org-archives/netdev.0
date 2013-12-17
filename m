From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/2] net_sched: remove unnecessary null pointer check
Date: Tue, 17 Dec 2013 15:29:15 +0800
Message-ID: <1387265357-19352-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:45279 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab3LQH32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:29:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary null pointer check outside of qdisc_put_rtab().

Yang Yingliang (2):
  act_police: remove unnecessary null pointer check
  sch_cbq: remove unnecessary null pointer check

 net/sched/act_police.c | 6 ++----
 net/sched/sch_cbq.c    | 3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

-- 
1.8.0
