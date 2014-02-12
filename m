From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v3 0/5] net_sched: act: more cleanup and improvement
Date: Tue, 11 Feb 2014 17:07:30 -0800
Message-ID: <1392167255-21744-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38167 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbaBLBHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:07:43 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so8458865pab.35
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 17:07:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 -> v3:
* fix a mis-splitted patch
* keep hinfo as a pointer in ops

v1 -> v2:
* Fix a bug noticed by Jamal
* Drop patches already merged into net-next
* Add patch 5/5

Patches are cleanup's for the structures of tc actions, except patch 4
which is an improvement.

See each patch for details.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (5):
  net_sched: act: hide struct tcf_common from API
  net_sched: act: refactor cleanup ops
  net_sched: act: move tcf_hashinfo_init() into tcf_register_action()
  net_sched: act: refuse to remove bound action outside
  net_sched: act: clean up tca_action_flush()

 include/net/act_api.h           |  22 +++----
 include/net/tc_act/tc_csum.h    |   4 +-
 include/net/tc_act/tc_defact.h  |   4 +-
 include/net/tc_act/tc_gact.h    |   4 +-
 include/net/tc_act/tc_ipt.h     |   4 +-
 include/net/tc_act/tc_mirred.h  |   4 +-
 include/net/tc_act/tc_nat.h     |   4 +-
 include/net/tc_act/tc_pedit.h   |   4 +-
 include/net/tc_act/tc_skbedit.h |   4 +-
 net/sched/act_api.c             | 142 +++++++++++++++++++++++++---------------
 net/sched/act_csum.c            |  31 +++------
 net/sched/act_gact.c            |  34 +++-------
 net/sched/act_ipt.c             |  68 ++++++-------------
 net/sched/act_mirred.c          |  56 ++++------------
 net/sched/act_nat.c             |  33 +++-------
 net/sched/act_pedit.c           |  45 ++++---------
 net/sched/act_police.c          |  22 +------
 net/sched/act_simple.c          |  64 +++++-------------
 net/sched/act_skbedit.c         |  36 +++-------
 19 files changed, 213 insertions(+), 372 deletions(-)

-- 
1.8.3.1
