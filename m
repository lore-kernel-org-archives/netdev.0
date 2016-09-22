From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net 0/2] Fix tc-ife bugs
Date: Thu, 22 Sep 2016 15:55:24 +0300
Message-ID: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yotam Gigi <yotamg@mellanox.com>
To: <jhs@mojatatu.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0050.outbound.protection.outlook.com ([104.47.2.50]:10938
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751220AbcIVQ1K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 12:27:10 -0400
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
