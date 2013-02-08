From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/11] couple of net/sched fixes+improvements
Date: Fri,  8 Feb 2013 19:59:30 +0100
Message-ID: <1360349981-27801-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:48667 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760225Ab3BHS7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 13:59:48 -0500
Received: by mail-ee0-f43.google.com with SMTP id c50so2227150eek.16
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 10:59:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2:
 - made struct psched_ratecfg const in params of couple of inline functions
   (patch "sch: make htb_rate_cfg and functions around that generic")
 - fixes misspelled "peak"
   (patch "tbf: improved accuracy at high rates")
 - added last 4 patches to this set

Jiri Pirko (11):
  htb: use PSCHED_TICKS2NS()
  htb: fix values in opt dump
  htb: remove pointless first initialization of buffer and cbuffer
  htb: initialize cl->tokens and cl->ctokens correctly
  sch: make htb_rate_cfg and functions around that generic
  tbf: improved accuracy at high rates
  tbf: ignore max_size check for gso skbs
  tbf: fix value set for q->ptokens
  act_police: move struct tcf_police to act_police.c
  act_police: improved accuracy at high rates
  act_police: remove <=mtu check for gso skbs

 include/net/act_api.h     |  15 ------
 include/net/sch_generic.h |  19 +++++++
 net/sched/act_police.c    | 124 +++++++++++++++++++++++++---------------------
 net/sched/sch_generic.c   |  37 ++++++++++++++
 net/sched/sch_htb.c       |  80 ++++++------------------------
 net/sched/sch_tbf.c       |  71 +++++++++++++-------------
 6 files changed, 173 insertions(+), 173 deletions(-)

-- 
1.8.1.2
