From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 0/3] net_sched: make tbf support 64bit rates
Date: Thu, 7 Nov 2013 10:13:29 +0800
Message-ID: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <jhs@mojatatu.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33286 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189Ab3KGCQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:16:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After this patch(commit 3e1e3aae1f5d4e8e5:
net_sched: add u64 rate to psched_ratecfg_precompute())
which is from Eric, tbf can deal with 64bit rates.
Add two new attributes so that tc can use them to break
the 32bit limit.
And, fix some checkpatch errors;
replace printk(KERN_DEBUG ...) with pr_debug.

v1 -> v2:
  - patch 2/3: return an assignment on seperate line
    in tcf_hash_new_index() suggested by Stephen.

Yang Yingliang (3):
  net_sched: tbf: support of 64bit rates
  net_sched: fix some checkpatch errors
  net_sched: Use pr_debug replace printk(KERN_DEBUG ...)

 include/uapi/linux/pkt_sched.h |  2 ++
 net/sched/act_api.c            |  5 +++--
 net/sched/cls_bpf.c            |  2 +-
 net/sched/cls_u32.c            |  2 +-
 net/sched/sch_cbq.c            |  5 +++--
 net/sched/sch_dsmark.c         |  2 +-
 net/sched/sch_generic.c        |  4 ++--
 net/sched/sch_gred.c           |  4 ++--
 net/sched/sch_htb.c            | 19 ++++++++++---------
 net/sched/sch_netem.c          |  2 +-
 net/sched/sch_sfq.c            | 10 ++++++----
 net/sched/sch_tbf.c            | 22 ++++++++++++++++++----
 12 files changed, 50 insertions(+), 29 deletions(-)

-- 
1.7.12
