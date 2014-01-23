From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 0/5] net_sched: act: more cleanup and improvement
Date: Thu, 23 Jan 2014 14:35:20 -0800
Message-ID: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:58714 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbaAWWfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:35:31 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so2416963pbc.24
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 14:35:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2:
* Fix a bug noticed by Jamal
* Drop patches already merged into net-next
* Add patch 5/5

Patches are cleanup's for the structures of tc actions, except patch 4
which is an improvement.

See each patch for details.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (5):
  net_sched: act: hide struct tcf_common from API
  net_sched: act: refactor cleanup ops
  net_sched: act: move tcf_hashinfo_init() into tcf_register_action()
  net_sched: act: refuse to remove bound action outside
  net_sched: act: clean up tca_action_flush()

 include/net/act_api.h           |  26 ++++----
 include/net/tc_act/tc_csum.h    |   4 +-
 include/net/tc_act/tc_defact.h  |   4 +-
 include/net/tc_act/tc_gact.h    |   4 +-
 include/net/tc_act/tc_ipt.h     |   4 +-
 include/net/tc_act/tc_mirred.h  |   4 +-
 include/net/tc_act/tc_nat.h     |   4 +-
 include/net/tc_act/tc_pedit.h   |   4 +-
 include/net/tc_act/tc_skbedit.h |   4 +-
 net/sched/act_api.c             | 144 ++++++++++++++++++++++++----------------
 net/sched/act_csum.c            |  31 +++------
 net/sched/act_gact.c            |  34 +++-------
 net/sched/act_ipt.c             |  68 ++++++-------------
 net/sched/act_mirred.c          |  56 ++++------------
 net/sched/act_nat.c             |  33 +++------
 net/sched/act_pedit.c           |  45 ++++---------
 net/sched/act_police.c          |  26 ++------
 net/sched/act_simple.c          |  64 +++++-------------
 net/sched/act_skbedit.c         |  36 +++-------
 19 files changed, 214 insertions(+), 381 deletions(-)

-- 
1.8.3.1
