From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 0/3] sch_netem: some improvements and cleanups.
Date: Fri, 14 Feb 2014 10:30:40 +0800
Message-ID: <1392345043-12208-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:31715 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaBNCcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 21:32:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2:
	remove patch #4.

 patch 1/3: To avoid breaking old settings when we change failed,
	    do return errcode before doing setup.
 pacth 2/3: Replace some functions' parameters, these functions
	    only need struct netem_sched_data *q.
 patch 3/3: Replace magic numbers with enumerate for better readability.

Yang Yingliang (3):
  sch_netem: return errcode before setting params
  sch_netem: change some func's param from "struct Qdisc *" to "struct
    netem_sched_data *"
  sch_netem: replace magic numbers with enumerate in GE model

 net/sched/sch_netem.c | 75 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 47 insertions(+), 28 deletions(-)

-- 
1.8.0
