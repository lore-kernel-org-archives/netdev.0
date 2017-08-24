From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 0/4] net_sched: clean up tc classes and u32 filter
Date: Thu, 24 Aug 2017 16:51:26 -0700
Message-ID: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36203 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753428AbdHXXvx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 19:51:53 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so1345847pgb.3
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:51:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 and patch 2 prepare for patch 3. Major changes
are in patch 3 and patch 4, details are there too.

Cong Wang (4):
  net_sched: get rid of more forward declarations
  net_sched: introduce tclass_del_notify()
  net_sched: remove tc class reference counting
  net_sched: kill u32_node pointer in Qdisc

---
v2: Add patch 1 and 2, group all into a patchset
    Fix a coding style issue in patch 4

 include/net/sch_generic.h |   4 +-
 net/sched/cls_api.c       |  17 +-
 net/sched/cls_u32.c       |  57 ++++++-
 net/sched/sch_api.c       | 408 ++++++++++++++++++++++++----------------------
 net/sched/sch_atm.c       |  30 ++--
 net/sched/sch_cbq.c       |  41 +----
 net/sched/sch_drr.c       |  30 +---
 net/sched/sch_dsmark.c    |  17 +-
 net/sched/sch_fq_codel.c  |   9 +-
 net/sched/sch_hfsc.c      |  32 +---
 net/sched/sch_htb.c       |  33 +---
 net/sched/sch_ingress.c   |  20 +--
 net/sched/sch_mq.c        |   9 +-
 net/sched/sch_mqprio.c    |   9 +-
 net/sched/sch_multiq.c    |  11 +-
 net/sched/sch_netem.c     |   9 +-
 net/sched/sch_prio.c      |  11 +-
 net/sched/sch_qfq.c       |  30 +---
 net/sched/sch_red.c       |   9 +-
 net/sched/sch_sfb.c       |   9 +-
 net/sched/sch_sfq.c       |   9 +-
 net/sched/sch_tbf.c       |   9 +-
 22 files changed, 361 insertions(+), 452 deletions(-)

-- 
2.13.0
