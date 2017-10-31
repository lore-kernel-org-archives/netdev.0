From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 0/2] net: core: introduce mini_Qdisc and eliminate usage of tp->q for clsact fastpath
Date: Tue, 31 Oct 2017 16:12:20 +0100
Message-ID: <20171031151222.5021-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:51408 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751807AbdJaPMY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 11:12:24 -0400
Received: by mail-wm0-f68.google.com with SMTP id b9so23961398wmh.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 08:12:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset's main patch is patch number 2. It carries the
description and changelog. Patch 1 is just a dependency.

Jiri Pirko (2):
  net: sched: introduce chain_head_change callback
  net: core: introduce mini_Qdisc and eliminate usage of tp->q for
    clsact fastpath

 include/linux/netdevice.h |  9 +++++---
 include/net/pkt_cls.h     | 14 ++++++------
 include/net/sch_generic.h | 37 +++++++++++++++++++++++++++++++-
 net/core/dev.c            | 21 +++++++++---------
 net/sched/cls_api.c       | 54 ++++++++++++++++++++++++++++-------------------
 net/sched/sch_generic.c   | 46 ++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_ingress.c   | 45 +++++++++++++++++++++++++--------------
 7 files changed, 166 insertions(+), 60 deletions(-)

-- 
2.9.5
