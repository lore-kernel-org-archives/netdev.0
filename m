From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/2] small set of sched cleanups
Date: Thu, 16 Mar 2017 12:53:40 +0200
Message-ID: <1489661622-14498-1-git-send-email-ogerlitz@mellanox.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52564 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751182AbdCPLU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 07:20:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Just two cleanups -- but for the 2nd one I think we need ack from 
Cong Wang to make sure this isn't actually a bug report..

Or.

changes from V1:
  - addressed comment from Sergei to use 12 hex digits etc


Or Gerlitz (2):
  net/sched: act_ife: Staticfy find_decode_metaid()
  net/sched: fq_codel: Avoid set-but-unused variable

 net/sched/act_ife.c      | 4 ++--
 net/sched/sch_fq_codel.c | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

-- 
2.3.7
