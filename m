From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/09]: sch_ingress cleanups
Date: Sun, 20 Jan 2008 15:32:29 +0100 (MET)
Message-ID: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59142 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbYATOcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches clean up sch_ingress by reformatting the code to match the
usual kernel style, removing lots of debugging statements that seem
unnecessary after years of stable operation, removing some "future use"
stuff that doesn't seem likely to ever get used and some minor additional
cleanups.


 net/sched/Kconfig       |    1 +
 net/sched/sch_ingress.c |  232 ++++++++---------------------------------------
 2 files changed, 41 insertions(+), 192 deletions(-)

Patrick McHardy (9):
      [NET_SCHED]: sch_ingress: formatting fixes
      [NET_SCHED]: sch_ingress: remove excessive debugging
      [NET_SCHED]: sch_ingress: remove qdisc_priv() wrapper
      [NET_SCHED]: sch_ingress: remove unused inner qdisc
      [NET_SCHED]: sch_ingress: return proper error code in ingress_graft()
      [NET_SCHED]: sch_ingress: remove unnecessary ops
      [NET_SCHED]: sch_ingress: move dependencies to Kconfig
      [NET_SCHED]: sch_ingress: avoid a few #ifdefs
      [NET_SCHED]: sch_ingress: remove useless printk
