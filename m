From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/2] net_sched: refactor tc action structures
Date: Wed, 20 Jul 2016 22:23:32 -0700
Message-ID: <1469078614-13540-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32980 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbcGUFXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 01:23:49 -0400
Received: by mail-pf0-f179.google.com with SMTP id y134so26480630pfg.0
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 22:23:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches factor our the struct tcf_common.

Cong Wang (2):
  net_sched: move tc_action into tcf_common
  net_sched: get rid of struct tcf_common

 include/net/act_api.h            |  91 +++++++-------
 include/net/tc_act/tc_bpf.h      |   5 +-
 include/net/tc_act/tc_connmark.h |   5 +-
 include/net/tc_act/tc_csum.h     |   5 +-
 include/net/tc_act/tc_defact.h   |   5 +-
 include/net/tc_act/tc_gact.h     |   7 +-
 include/net/tc_act/tc_ife.h      |   5 +-
 include/net/tc_act/tc_ipt.h      |   5 +-
 include/net/tc_act/tc_mirred.h   |   5 +-
 include/net/tc_act/tc_nat.h      |   7 +-
 include/net/tc_act/tc_pedit.h    |   5 +-
 include/net/tc_act/tc_skbedit.h  |   5 +-
 include/net/tc_act/tc_vlan.h     |   5 +-
 net/sched/act_api.c              | 250 ++++++++++++++++-----------------------
 net/sched/act_bpf.c              |  26 ++--
 net/sched/act_connmark.c         |  24 ++--
 net/sched/act_csum.c             |  22 ++--
 net/sched/act_gact.c             |  24 ++--
 net/sched/act_ife.c              |  38 +++---
 net/sched/act_ipt.c              |  48 ++++----
 net/sched/act_mirred.c           |  26 ++--
 net/sched/act_nat.c              |  22 ++--
 net/sched/act_pedit.c            |  28 +++--
 net/sched/act_police.c           |  49 ++++----
 net/sched/act_simple.c           |  29 ++---
 net/sched/act_skbedit.c          |  26 ++--
 net/sched/act_vlan.c             |  28 +++--
 27 files changed, 378 insertions(+), 417 deletions(-)

-- 
2.1.0
