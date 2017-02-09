From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] sched: cls_api: small cleanup
Date: Thu,  9 Feb 2017 14:38:54 +0100
Message-ID: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:36593 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752655AbdBIOKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:10:43 -0500
Received: by mail-wr0-f174.google.com with SMTP id k90so84418238wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:10:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset makes couple of things in cls_api code a bit nicer and easier
for reader to digest.

Jiri Pirko (6):
  sched: rename tcf_destroy to tcf_destroy_proto
  sched: move tcf_proto_destroy and tcf_destroy_chain helpers into
    cls_api
  sched: push TC filter protocol creation into a separate function
  sched: move err set right before goto errout in tc_ctl_tfilter
  sched: add missing curly braces in else branch in tc_ctl_tfilter
  sched: check negative err value to safe one level of indent

 include/net/pkt_cls.h     |   2 +
 include/net/sch_generic.h |   2 -
 net/sched/cls_api.c       | 191 +++++++++++++++++++++++++++-------------------
 net/sched/sch_api.c       |  22 ------
 net/sched/sch_atm.c       |   1 +
 net/sched/sch_cbq.c       |   1 +
 net/sched/sch_choke.c     |   1 +
 net/sched/sch_dsmark.c    |   1 +
 net/sched/sch_fq_codel.c  |   1 +
 net/sched/sch_htb.c       |   1 +
 net/sched/sch_ingress.c   |   1 +
 net/sched/sch_multiq.c    |   2 +-
 net/sched/sch_prio.c      |   2 +-
 net/sched/sch_sfb.c       |   1 +
 net/sched/sch_sfq.c       |   1 +
 15 files changed, 126 insertions(+), 104 deletions(-)

-- 
2.7.4
