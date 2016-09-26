From: Yotam Gigi <yotam.gi@gmail.com>
Subject: [PATCH net v3 0/2] Fix tc-ife bugs
Date: Mon, 26 Sep 2016 13:45:24 +0300
Message-ID: <1474886726-56363-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        mlxsw@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35503 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933368AbcIZKno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 06:43:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id 133so13442457wmq.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 03:43:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set contains two bugfixes in the tc-ife action, one fixing some
random behaviour in encode side, and one fixing the decode side packet
parsing logic.

v2->v3
 - Fix the encode side instead of the decode side

Yotam Gigi (2):
  act_ife: Fix external mac header on encode
  act_ife: Fix false encoding

 net/sched/act_ife.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

-- 
2.4.11
