From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 0/5] net_sched: actions - Add default lookup and walker
Date: Wed,  4 Dec 2013 09:26:51 -0500
Message-ID: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39803 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238Ab3LDO1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 09:27:37 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so26184452iec.5
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 06:27:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches provide defaults for lookup and walkers for actions.
Users can override when needed.
It also enforces mandatory action methods to be passed.

Thanks to David Miller who paid attention and made this patch set 
much better.

Jamal Hadi Salim (5):
  net_sched: Fail if missing mandatory action operation methods
  net_sched: Default action lookup method for actions
  net_sched: Use default action lookup functions
  net_sched: Provide default walker function for actions
  net_sched: Use default action walker methods

 net/sched/act_api.c     |   26 ++++++++++++++------------
 net/sched/act_csum.c    |    2 --
 net/sched/act_gact.c    |    2 --
 net/sched/act_ipt.c     |    4 ----
 net/sched/act_mirred.c  |    2 --
 net/sched/act_nat.c     |    2 --
 net/sched/act_pedit.c   |    2 --
 net/sched/act_police.c  |    1 -
 net/sched/act_simple.c  |    1 -
 net/sched/act_skbedit.c |    1 -
 10 files changed, 14 insertions(+), 29 deletions(-)

-- 
1.7.10.4
