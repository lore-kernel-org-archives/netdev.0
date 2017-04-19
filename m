From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v4 0/2] net_sched: clean up tc filter destroy and delete logic
Date: Wed, 19 Apr 2017 14:21:20 -0700
Message-ID: <1492636882-19571-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32841 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938234AbdDSVVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:21:35 -0400
Received: by mail-io0-f196.google.com with SMTP id k87so7601261ioi.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 14:21:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch fixes a potenial race condition, the second one
is pure cleanup.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
v4: split the patch and update changelog
v3: fix a compiler warning
v2: rebase

Cong Wang (2):
  net_sched: move the empty tp check from ->destroy() to ->delete()
  net_sched: remove useless NULL to tp->root

 include/net/sch_generic.h |  4 +--
 net/sched/cls_api.c       | 27 +++++++++---------
 net/sched/cls_basic.c     | 10 +++----
 net/sched/cls_bpf.c       | 11 ++++----
 net/sched/cls_cgroup.c    |  8 ++----
 net/sched/cls_flow.c      | 10 +++----
 net/sched/cls_flower.c    | 10 ++-----
 net/sched/cls_fw.c        | 30 +++++++++++---------
 net/sched/cls_matchall.c  |  7 ++---
 net/sched/cls_route.c     | 44 ++++++++++-------------------
 net/sched/cls_rsvp.h      | 36 ++++++++++++------------
 net/sched/cls_tcindex.c   | 14 +++++-----
 net/sched/cls_u32.c       | 71 +++++++++++++++++++++++++++--------------------
 13 files changed, 134 insertions(+), 148 deletions(-)

-- 
2.5.5
