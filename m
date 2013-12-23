From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 0/3] net_sched: do some cleanup
Date: Mon, 23 Dec 2013 17:38:57 +0800
Message-ID: <1387791540-27028-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:60420 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab3LWJjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 04:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefer pr_warn(... to pr_warning(...
Do not use C99 // comments and fix spelling.
Correct function names by using __func__ .

v1 -> v2:
  patch 1/3: Don't split messages in "..." into multiple lines.
  patch 3/3: Add patch #3.

Yang Yingliang (3):
  net_sched: replace pr_warning with pr_warn
  sch_htb: use /* comments
  sch_dsmark: use correct func name in print messages

 net/sched/sch_cbq.c    |  4 ++--
 net/sched/sch_dsmark.c | 37 +++++++++++++++++++------------------
 net/sched/sch_gred.c   |  4 ++--
 net/sched/sch_htb.c    | 19 +++++++++----------
 4 files changed, 32 insertions(+), 32 deletions(-)

-- 
1.8.0
