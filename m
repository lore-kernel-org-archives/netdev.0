From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] net: sched: couple of chain fixes
Date: Tue, 22 Aug 2017 22:46:48 +0200
Message-ID: <20170822204650.7016-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38576 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752733AbdHVUqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 16:46:54 -0400
Received: by mail-wr0-f193.google.com with SMTP id k10so11003257wre.5
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 13:46:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Jiri Pirko (2):
  net: sched: fix use after free when tcf_chain_destroy is called
    multiple times
  net: sched: don't do tcf_chain_flush from tcf_chain_destroy

 net/sched/cls_api.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

-- 
2.9.3
