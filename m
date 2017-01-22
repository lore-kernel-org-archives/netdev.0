From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v5 0/1] Add support for tc cookies
Date: Sun, 22 Jan 2017 07:51:37 -0500
Message-ID: <1485089498-6673-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36433 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdAVNAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 08:00:12 -0500
Received: by mail-qk0-f193.google.com with SMTP id i34so4973921qkh.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 05:00:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes in V5:
 - kill the stylistic changes
 - Adopt a new structure with length-valuepointer representation
 - rename some things

Changes in v4:
 - move stylistic changes out into a separate patch
   (and add more stylistic changes)

Changes in v3:
 - use TC_ prefix for the max size
 - move the cookie struct so visible only to kernel
 - remove unneeded void * cast

Changes in V2:
 -move from a union to a length-value representation

Jamal Hadi Salim (1):
  net sched actions: Add support for user cookies

 include/net/act_api.h        |  1 +
 include/net/pkt_cls.h        |  8 ++++++++
 include/uapi/linux/pkt_cls.h |  3 +++
 net/sched/act_api.c          | 35 +++++++++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+)

-- 
1.9.1
