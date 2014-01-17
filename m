From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/6] net_sched: act: more cleanup and improvement
Date: Fri, 17 Jan 2014 11:37:01 -0800
Message-ID: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39722 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbaAQThV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:37:21 -0500
Received: by mail-pd0-f175.google.com with SMTP id r10so4362261pdi.6
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 11:37:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1-5 are cleanup's for the structures of tc actions.
Patch 6 is a small improvement.
See each patch for details.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (6):
  net_sched: act: fetch hinfo from a->ops->hinfo
  net_sched: act: export tcf_hash_search() instead of tcf_hash_lookup()
  net_sched: act: hide struct tcf_common from API
  net_sched: act: refactor cleanup ops
  net_sched: act: move tcf_hashinfo_init() into tcf_register_action()
  net_sched: act: refuse to remove bound action outside

 include/net/act_api.h           |  28 +++++------
 include/net/tc_act/tc_csum.h    |   4 +-
 include/net/tc_act/tc_defact.h  |   4 +-
 include/net/tc_act/tc_gact.h    |   4 +-
 include/net/tc_act/tc_ipt.h     |   4 +-
 include/net/tc_act/tc_mirred.h  |   4 +-
 include/net/tc_act/tc_nat.h     |   4 +-
 include/net/tc_act/tc_pedit.h   |   4 +-
 include/net/tc_act/tc_skbedit.h |   4 +-
 net/sched/act_api.c             | 107 +++++++++++++++++++++++++++-------------
 net/sched/act_csum.c            |  32 +++---------
 net/sched/act_gact.c            |  35 +++----------
 net/sched/act_ipt.c             |  69 +++++++-------------------
 net/sched/act_mirred.c          |  57 ++++++---------------
 net/sched/act_nat.c             |  34 +++----------
 net/sched/act_pedit.c           |  46 +++++------------
 net/sched/act_police.c          |  44 +++++------------
 net/sched/act_simple.c          |  65 ++++++------------------
 net/sched/act_skbedit.c         |  37 ++++----------
 19 files changed, 207 insertions(+), 379 deletions(-)

-- 
1.8.3.1
