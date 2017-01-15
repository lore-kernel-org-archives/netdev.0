From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v3 0/1] Add support for tc cookies
Date: Sun, 15 Jan 2017 09:01:18 -0500
Message-ID: <1484488879-29560-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33551 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbdAOOBh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 09:01:37 -0500
Received: by mail-it0-f65.google.com with SMTP id v14so9782293itb.0
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 06:01:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes in v3:
 - use TC_ prefix for the max size
 - move the cookie struct so visible only to kernel
 - remove unneeded void * cast

Changes in V2:
 -move from a union to a length-value representation

Jamal Hadi Salim (1):
  net sched actions: Add support for user cookies

 include/net/act_api.h        |  1 +
 include/net/pkt_cls.h        | 19 +++++++++++++------
 include/uapi/linux/pkt_cls.h |  3 +++
 net/sched/act_api.c          | 29 +++++++++++++++++++++++++++--
 4 files changed, 44 insertions(+), 8 deletions(-)

-- 
1.9.1
