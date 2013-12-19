From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/4] net_sched: improve tc action code
Date: Wed, 18 Dec 2013 16:36:39 -0800
Message-ID: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:38841 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab3LSAgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:36:54 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so399413pab.28
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 16:36:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset continues to cleanup and improve tc action
code, especially for mirred action we are now able to cleanup
the action upon device unregister event.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (4):
  net_sched: act: clean up notification functions
  net_sched: act: move idx_gen to struct tcf_hash_info
  net_sched: mirred: remove action when the target device is gone
  net_sched: mirred: notify user-space when action gets removed

 include/net/act_api.h          |   8 +--
 include/net/tc_act/tc_mirred.h |   1 +
 net/sched/act_api.c            | 110 +++++++++++++++++------------------------
 net/sched/act_csum.c           |   3 +-
 net/sched/act_gact.c           |   3 +-
 net/sched/act_ipt.c            |   3 +-
 net/sched/act_mirred.c         |  31 +++++++-----
 net/sched/act_nat.c            |   3 +-
 net/sched/act_pedit.c          |   3 +-
 net/sched/act_police.c         |   3 +-
 net/sched/act_simple.c         |   3 +-
 net/sched/act_skbedit.c        |   3 +-
 12 files changed, 80 insertions(+), 94 deletions(-)

-- 
1.8.3.1
