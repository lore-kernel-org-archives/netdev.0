From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/3] sch_netem: some improvements
Date: Thu, 23 Jan 2014 17:31:36 +0800
Message-ID: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3798 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbaAWJb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 04:31:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset do three improvements to sch_netem.

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

 net/sched/sch_netem.c | 74 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 46 insertions(+), 28 deletions(-)

-- 
1.8.0
