From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 0/2] HFSC patches
Date: Mon,  1 Aug 2016 01:03:57 +0200
Message-ID: <1470006239-20299-1-git-send-email-soltys@ziu.info>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:36829 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbcGaXF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 19:05:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- first patch:

This patch syncs virtual times with fair service curve and fixes a very old
subtle bug.

The detailed explanation is in the commit message. Additionally
I've made an illustration to help understand the issue better:

http://imgur.com/a/N8uMC

See the example at the bottom of the commit message - Am1_3 and Am2_3 is what
should happen with such queue setup, Am1_3real and Am2_3real is what actually
happens due to rtsc_min() calculating minimum from corrected and uncorrected
curves.

- second patch:

This is trivial patch that comments out one unused variable, related to another
commented out piece of code.


Michal Soltys (2):
  net/sched/sch_hfsc.c: keep fsc and virtual times in sync; fix an old
    bug
  net/sched/sch_hfsc.c: comment out cl_myfadj

 net/sched/sch_hfsc.c | 56 +++++++++++++++++++++-------------------------------
 1 file changed, 23 insertions(+), 33 deletions(-)

-- 
2.1.3
