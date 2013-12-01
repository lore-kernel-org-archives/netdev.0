From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 0/4] net_sched: actions - Add default lookup and walker
Date: Sun,  1 Dec 2013 17:30:05 -0500
Message-ID: <1385937009-589-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com,
	jhs@mojatatu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:59640 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab3LAWbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 17:31:49 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so19751474ieb.15
        for <netdev@vger.kernel.org>; Sun, 01 Dec 2013 14:31:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches provide defaults for lookup and walkers for actions.
Users can override when needed.

Jamal Hadi Salim (4):
  Provide default lookup function for actions that dont provide one
  Use default lookup functions. Users are free to override when needed.
  Provide default walker function for actions that dont provide one
  Use default walker functions. Users who need something special can
    override.

 net/sched/act_api.c     |    7 +++++++
 net/sched/act_csum.c    |    2 --
 net/sched/act_gact.c    |    2 --
 net/sched/act_ipt.c     |    4 ----
 net/sched/act_mirred.c  |    2 --
 net/sched/act_nat.c     |    2 --
 net/sched/act_pedit.c   |    2 --
 net/sched/act_police.c  |    1 -
 net/sched/act_simple.c  |    1 -
 net/sched/act_skbedit.c |    1 -
 10 files changed, 7 insertions(+), 17 deletions(-)

-- 
1.7.10.4
