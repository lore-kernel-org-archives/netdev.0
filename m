From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/2] net_sched: clean up filter handle
Date: Fri,  4 Aug 2017 21:31:41 -0700
Message-ID: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, jiri@resnulli.us,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36358 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdHEEbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 00:31:52 -0400
Received: by mail-pg0-f66.google.com with SMTP id y129so3451834pgy.3
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 21:31:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset sits in my local branch for a long time, it is time to
send it out. It cleans up the ambiguous use of 'unsigned long fh',
please see each of them for details.

Cong Wang (2):
  net_sched: refactor notification code for RTM_DELTFILTER
  net_sched: use void pointer for filter handle

 include/net/pkt_cls.h     |  2 +-
 include/net/sch_generic.h |  8 +++----
 net/sched/cls_api.c       | 57 +++++++++++++++++++++++++++++++++++++----------
 net/sched/cls_basic.c     | 22 +++++++++---------
 net/sched/cls_bpf.c       | 27 ++++++++++------------
 net/sched/cls_cgroup.c    | 12 +++++-----
 net/sched/cls_flow.c      | 24 ++++++++++----------
 net/sched/cls_flower.c    | 22 +++++++++---------
 net/sched/cls_fw.c        | 26 ++++++++++-----------
 net/sched/cls_matchall.c  | 16 ++++++-------
 net/sched/cls_route.c     | 26 ++++++++++-----------
 net/sched/cls_rsvp.h      | 24 ++++++++++----------
 net/sched/cls_tcindex.c   | 36 +++++++++++++-----------------
 net/sched/cls_u32.c       | 30 ++++++++++++-------------
 14 files changed, 178 insertions(+), 154 deletions(-)

-- 
2.13.0
