From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/4] sch_netem: some improvements and cleanups.
Date: Wed, 12 Feb 2014 10:58:11 +0800
Message-ID: <1392173895-5012-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:60432 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbaBLC6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 21:58:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 patch 1/4: To avoid breaking old settings when we change failed,
	    do return errcode before doing setup.
 pacth 2/4: Replace some functions' parameters, these functions
	    only need struct netem_sched_data *q.
 patch 3/4: Replace magic numbers with enumerate for better readability.
 patch 4/4: Replace spin_(un)lock_bh with sch_tree_(un)lock.

Yang Yingliang (4):
  sch_netem: return errcode before setting params
  sch_netem: change some func's param from "struct Qdisc *" to "struct
    netem_sched_data *"
  sch_netem: replace magic numbers with enumerate in GE model
  sch_netem: replace spin_(un)lock_bh with sch_tree_(un)lock

 net/sched/sch_netem.c | 82 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 49 insertions(+), 33 deletions(-)

-- 
1.8.0
