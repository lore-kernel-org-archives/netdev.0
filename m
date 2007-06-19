From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/04]: Cleanups
Date: Tue, 19 Jun 2007 17:02:18 +0200 (MEST)
Message-ID: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60150 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbXFSPCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 11:02:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches contain some cleanup in net/sched related to estimators
(removal of the NET_ESTIMATOR config option, unnecessary stats_lock
pointers in multiple structures and the HTB estimator reimplementation)
and additionally remove lots of unnecessary includes.

Please apply, thanks.


 include/net/act_api.h     |    2 -
 net/sched/Kconfig         |   12 -----
 net/sched/act_api.c       |   23 +---------
 net/sched/act_gact.c      |   11 -----
 net/sched/act_ipt.c       |   12 -----
 net/sched/act_mirred.c    |   12 -----
 net/sched/act_pedit.c     |   11 -----
 net/sched/act_police.c    |   36 +--------------
 net/sched/act_simple.c    |    1 -
 net/sched/cls_api.c       |   10 ----
 net/sched/cls_basic.c     |    1 -
 net/sched/cls_fw.c        |   19 +--------
 net/sched/cls_route.c     |   20 +-------
 net/sched/cls_rsvp.c      |   17 +-------
 net/sched/cls_rsvp6.c     |   16 -------
 net/sched/cls_tcindex.c   |    3 -
 net/sched/cls_u32.c       |   18 +-------
 net/sched/ematch.c        |    2 -
 net/sched/sch_api.c       |   18 --------
 net/sched/sch_atm.c       |    4 --
 net/sched/sch_blackhole.c |    1 -
 net/sched/sch_cbq.c       |   34 ++-------------
 net/sched/sch_dsmark.c    |    1 -
 net/sched/sch_fifo.c      |    1 -
 net/sched/sch_generic.c   |   10 ----
 net/sched/sch_gred.c      |    1 -
 net/sched/sch_hfsc.c      |   21 +--------
 net/sched/sch_htb.c       |  102 +++++++++++----------------------------------
 net/sched/sch_ingress.c   |    9 +----
 net/sched/sch_netem.c     |    2 -
 net/sched/sch_prio.c      |   16 -------
 net/sched/sch_red.c       |    1 -
 net/sched/sch_sfq.c       |   18 +-------
 net/sched/sch_tbf.c       |   19 +--------
 net/sched/sch_teql.c      |   18 +-------
 35 files changed, 49 insertions(+), 453 deletions(-)

Patrick McHardy (4):
      [NET_SCHED]: Remove CONFIG_NET_ESTIMATOR option
      [NET_SCHED]: Remove unnecessary stats_lock pointers
      [NET_SCHED]: sch_htb: use generic estimator
      [NET_SCHED]: Remove unnecessary includes
