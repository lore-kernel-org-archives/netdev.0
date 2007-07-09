From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 00/05]: Kill NET_CLS_POLICE
Date: Mon,  9 Jul 2007 22:46:12 +0200 (MEST)
Message-ID: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41501 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbXGIUqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:46:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[This is a resend because of a typo in Jamal's address that I believe
 made vger reject the mails. Appologies in case they arrive twice.]


These patches update the NET_CLS_ACT code to fully replace NET_CLS_POLICE
and remove the old code. There is one incompatibility, please look at
patch 4/5 for details.


 include/net/act_api.h     |   30 ---
 include/net/pkt_cls.h     |    8 -
 include/net/pkt_sched.h   |    4 +-
 include/net/sch_generic.h |    2 +-
 net/sched/Kconfig         |    8 +-
 net/sched/Makefile        |    1 -
 net/sched/act_police.c    |  246 ++----------------------
 net/sched/cls_api.c       |   40 ----
 net/sched/cls_u32.c       |    3 -
 net/sched/sch_api.c       |   67 ++++---
 net/sched/sch_atm.c       |  475 ++++++++++++++++++++++-----------------------
 net/sched/sch_cbq.c       |   48 ++---
 net/sched/sch_dsmark.c    |   34 ++--
 net/sched/sch_hfsc.c      |    3 -
 net/sched/sch_htb.c       |    3 -
 net/sched/sch_ingress.c   |   19 --
 net/sched/sch_tbf.c       |    2 +-
 17 files changed, 330 insertions(+), 663 deletions(-)

Patrick McHardy (5):
      [NET_SCHED]: sch_atm: Lindent
      [NET_SCHED]: sch_atm: act_api support
      [NET_SCHED]: sch_dsmark: act_api support
      [NET_SCHED]: act_api: qdisc internal reclassify support
      [NET_SCHED]: Kill CONFIG_NET_CLS_POLICE
