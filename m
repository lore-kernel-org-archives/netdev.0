From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 00/05]: Pseudo-classful qdisc consolidation
Date: Sun, 20 Jan 2008 19:28:49 +0100 (MET)
Message-ID: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64045 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285AbYATS2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 13:28:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches contain some preparatory cleanups and consolidate the
Qdisc_class_ops for pseudo-classful qdiscs. The main reason for
RFC is that the naming is not particular appealing (both qdisc_q_...
and sch_pseudo_classful), suggestions for better names are welcome.


 include/net/pkt_sched.h         |    4 +
 include/net/sch_generic.h       |   78 +++++++++++++-------
 net/core/dev.c                  |    4 +-
 net/sched/Kconfig               |    6 ++
 net/sched/Makefile              |    1 +
 net/sched/sch_atm.c             |   17 +++--
 net/sched/sch_blackhole.c       |    2 +-
 net/sched/sch_cbq.c             |   18 +++--
 net/sched/sch_dsmark.c          |   11 +--
 net/sched/sch_fifo.c            |   62 +++++++++++++---
 net/sched/sch_generic.c         |   12 ++--
 net/sched/sch_gred.c            |   18 ++--
 net/sched/sch_hfsc.c            |   12 ++--
 net/sched/sch_htb.c             |   11 ++-
 net/sched/sch_netem.c           |  157 +++++++--------------------------------
 net/sched/sch_prio.c            |   13 ++-
 net/sched/sch_pseudo_classful.c |  101 +++++++++++++++++++++++++
 net/sched/sch_red.c             |  152 ++++++--------------------------------
 net/sched/sch_sfq.c             |    2 +-
 net/sched/sch_tbf.c             |  150 +++++--------------------------------
 20 files changed, 347 insertions(+), 484 deletions(-)
 create mode 100644 net/sched/sch_pseudo_classful.c

Patrick McHardy (5):
      [NET_SCHED]: Consolidate default fifo setup
      [NET_SCHED]: Rename qdisc helpers for built-in queue
      [NET_SCHED]: Introduce child qdisc helpers
      [NET_SCHED]: Use qdisc helpers
      [NET_SCHED]: Consolidate class ops for pseudo classful qdisc
