From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 0/2] net sched small OCD cleanups
Date: Tue, 17 May 2016 17:19:13 -0400
Message-ID: <1463519955-2866-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, nbd@nbd.name,
	baronchon@n7mm.org, alexander.duyck@gmail.com,
	herbert@gondor.apana.org.au, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36346 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbcEQVT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 17:19:27 -0400
Received: by mail-io0-f193.google.com with SMTP id k129so5948605iof.3
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 14:19:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

I have been staring at these small OCD cleanups for a while.
Got cycles to do them as prep for another patch i am working on.
Indentation/stylistic and consistency updates

Jamal Hadi Salim (2):
  net sched: indentation and other OCD stylistic fixes
  net sched: actions use tcf_lastuse_update for consistency

 include/net/act_api.h          | 14 ++++++++------
 include/net/tc_act/tc_defact.h |  4 ++--
 include/uapi/linux/pkt_cls.h   |  6 +++---
 net/sched/act_api.c            | 19 +++++++++++--------
 net/sched/act_bpf.c            |  3 ++-
 net/sched/act_connmark.c       |  2 +-
 net/sched/act_csum.c           |  2 +-
 net/sched/act_gact.c           |  3 ++-
 net/sched/act_ife.c            |  6 +++---
 net/sched/act_ipt.c            |  8 +++++---
 net/sched/act_mirred.c         |  1 -
 net/sched/act_nat.c            |  2 +-
 net/sched/act_pedit.c          |  2 +-
 net/sched/act_simple.c         |  2 +-
 net/sched/act_skbedit.c        |  2 +-
 net/sched/act_vlan.c           |  5 +++--
 net/sched/cls_api.c            | 11 +++++++----
 17 files changed, 52 insertions(+), 40 deletions(-)

-- 
1.9.1
