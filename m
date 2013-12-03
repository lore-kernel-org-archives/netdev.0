From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 0/5] net_sched: actions - Add default lookup and walker
Date: Tue,  3 Dec 2013 09:23:14 -0500
Message-ID: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:59061 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307Ab3LCOYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 09:24:12 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so24438216iej.28
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 06:24:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches provide defaults for lookup and walkers for actions.
Users can override when needed.


Jamal Hadi Salim (5):
  Default action lookup method for actions that dont provide one
  Use default action lookup functions Users are free to override
  Provide default walker function for actions
  Use default action walker methods Users can still override
  Fail if missing mandatory action operation methods

 net/sched/act_api.c     |   27 +++++++++++++++------------
 net/sched/act_csum.c    |    2 --
 net/sched/act_gact.c    |    2 --
 net/sched/act_ipt.c     |    4 ----
 net/sched/act_mirred.c  |    2 --
 net/sched/act_nat.c     |    2 --
 net/sched/act_pedit.c   |    2 --
 net/sched/act_police.c  |    1 -
 net/sched/act_simple.c  |    1 -
 net/sched/act_skbedit.c |    1 -
 10 files changed, 15 insertions(+), 29 deletions(-)

-- 
1.7.10.4
