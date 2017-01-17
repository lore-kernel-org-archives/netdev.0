From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v4 0/2] Add support for tc cookies
Date: Tue, 17 Jan 2017 06:11:47 -0500
Message-ID: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33982 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750920AbdAQLVF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 06:21:05 -0500
Received: by mail-qt0-f195.google.com with SMTP id a29so20729951qtb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 03:21:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes in v4:
 - move stylistic changes out into a separate patch
   (and add more stylistic changes)

Changes in v3:
 - use TC_ prefix for the max size
 - move the cookie struct so visible only to kernel
 - remove unneeded void * cast

Changes in V2:
 -move from a union to a length-value representation

Jamal Hadi Salim (2):
  net sched actions: Add support for user cookies
  net sched: Trivial whitespace and stylistic changes

 include/net/act_api.h        |  8 ++++---
 include/net/pkt_cls.h        | 53 ++++++++++++++++++++++----------------------
 include/uapi/linux/pkt_cls.h |  3 +++
 net/sched/act_api.c          | 45 +++++++++++++++++++++++++++----------
 4 files changed, 67 insertions(+), 42 deletions(-)

-- 
1.9.1
