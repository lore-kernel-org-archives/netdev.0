From: Yotam Gigi <yotam.gi@gmail.com>
Subject: [PATCH net v2 0/2] Fix tc-ife bugs
Date: Sun, 25 Sep 2016 15:31:49 +0300
Message-ID: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33626 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966128AbcIYMaK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 08:30:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id w84so9876636wmg.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 05:30:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set contains two bugfixes in the tc-ife action, one fixing some
random behaviour in encode side, and one fixing the decode side packet
parsing logic.

Yotam Gigi (2):
  act_ife: Fix external mac header on encode
  act_ife: Fix false parsing on decode side

 net/sched/act_ife.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

-- 
2.4.11
