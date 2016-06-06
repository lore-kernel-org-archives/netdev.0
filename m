From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 0/3] net sched action timestamp improvements
Date: Mon,  6 Jun 2016 06:32:52 -0400
Message-ID: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33755 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbcFFKfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 06:35:09 -0400
Received: by mail-it0-f65.google.com with SMTP id u203so5540268itc.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 03:35:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Various aggregations of duplicated code, fixes and introduction of firstused
timestamp

v2: add const for source time info per suggestion from Cong

Jamal Hadi Salim (3):
  net sched: actions use tcf_lastuse_update for consistency
  net sched actions: introduce timestamp for firsttime use
  net sched actions: aggregate dumping of actions timeinfo

 include/net/act_api.h        | 10 ++++++++++
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/act_api.c          |  1 +
 net/sched/act_bpf.c          |  5 +----
 net/sched/act_connmark.c     |  6 ++----
 net/sched/act_csum.c         |  7 +++----
 net/sched/act_gact.c         |  4 +---
 net/sched/act_ife.c          | 10 ++++------
 net/sched/act_ipt.c          |  8 ++++----
 net/sched/act_mirred.c       |  6 ++----
 net/sched/act_nat.c          |  7 +++----
 net/sched/act_pedit.c        |  8 ++++----
 net/sched/act_police.c       |  2 ++
 net/sched/act_simple.c       |  7 +++----
 net/sched/act_skbedit.c      |  7 +++----
 net/sched/act_vlan.c         |  6 ++----
 16 files changed, 46 insertions(+), 49 deletions(-)

-- 
1.9.1
