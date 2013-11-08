From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v4 0/2] net_sched: Fix some checkpatch errors and use pr_warn
Date: Fri, 8 Nov 2013 12:02:25 +0800
Message-ID: <1383883347-9320-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <dborkman@redhat.com>,
	<sergei.shtylyov@cogentembedded.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:46804 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3KHECi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:02:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some checkpatch errors and
replace pr_warning with pr_warn.

v1 -> v2:
  - patch 1/2: return an assignment on seperate line
    in tcf_hash_new_index() suggested by Stephen.

v2 -> v3:
  - patch 1/2: don't remove global vars' initialization.
  - patch 2/2: adjust pr_warn content make more comfortable.

v3 -> v4:
  - patch 1/2: do correct indent.
  - patch 2/2: do correct indent and recover pr_debug to printk.

Yang Yingliang (2):
  net_sched: fix some checkpatch errors
  net_sched: Use pr_warn replace pr_warning

 net/sched/act_api.c     |  3 ++-
 net/sched/cls_bpf.c     |  2 +-
 net/sched/cls_u32.c     |  2 +-
 net/sched/sch_cbq.c     |  7 ++++---
 net/sched/sch_dsmark.c  |  4 ++--
 net/sched/sch_generic.c |  4 ++--
 net/sched/sch_gred.c    |  4 ++--
 net/sched/sch_htb.c     | 23 ++++++++++++-----------
 net/sched/sch_netem.c   |  2 +-
 net/sched/sch_sfq.c     | 10 ++++++----
 10 files changed, 33 insertions(+), 28 deletions(-)

-- 
1.7.12
