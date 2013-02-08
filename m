From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/7] couple of net/sched fixes+improvements
Date: Fri,  8 Feb 2013 13:58:40 +0100
Message-ID: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:51532 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946441Ab3BHM6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 07:58:52 -0500
Received: by mail-ee0-f43.google.com with SMTP id c50so2022105eek.16
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 04:58:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (7):
  htb: use PSCHED_TICKS2NS()
  htb: fix values in opt dump
  htb: remove pointless first initialization of buffer and cbuffer
  htb: initialize cl->tokens and cl->ctokens correctly
  sch: make htb_rate_cfg and functions around that generic
  tbf: improved accuracy at high rates
  tbf: ignore max_size check for gso skbs

 include/net/sch_generic.h | 18 +++++++++++
 net/sched/sch_generic.c   | 37 ++++++++++++++++++++++
 net/sched/sch_htb.c       | 80 +++++++++--------------------------------------
 net/sched/sch_tbf.c       | 62 ++++++++++++++++++------------------
 4 files changed, 100 insertions(+), 97 deletions(-)

-- 
1.8.1.2
