From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 0/2] net_sched: refactor tc action structures
Date: Mon, 25 Jul 2016 16:09:40 -0700
Message-ID: <1469488182-12296-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33063 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbcGYXJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 19:09:51 -0400
Received: by mail-pf0-f180.google.com with SMTP id y134so68458491pfg.0
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 16:09:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches factor out the struct tcf_common.

v2: fix a compile warning

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
