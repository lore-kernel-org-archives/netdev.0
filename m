From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/4] tc: Minor action utility improvements
Date: Sat, 23 Jul 2016 13:28:06 +0200
Message-ID: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56760 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbcGWL2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:28:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When asked by Jamal to unify the various code duplications he had to
adjust in commit 43726b750a398 ("tc: don't ignore ok as an action
branch") I created patches 2 and 3, the rest is fallout.

Phil Sutter (4):
  tc: Reformat tc_util.h
  tc: util: bore up action_a2n()
  tc: use action_a2n() everywhere
  tc: util: No need for action_n2a() to be reentrant

 tc/m_bpf.c      |  27 ++--------
 tc/m_connmark.c |  27 +---------
 tc/m_csum.c     |  31 ++----------
 tc/m_gact.c     |  24 +++------
 tc/m_ife.c      |  30 ++----------
 tc/m_mirred.c   |  30 ++----------
 tc/m_nat.c      |  30 ++----------
 tc/m_pedit.c    |  26 ++--------
 tc/m_police.c   |  60 ++---------------------
 tc/m_simple.c   |  27 +---------
 tc/m_skbedit.c  |  22 +--------
 tc/m_vlan.c     |  29 ++---------
 tc/tc_util.c    |  68 ++++++++++++++++----------
 tc/tc_util.h    | 149 +++++++++++++++++++++++++++++---------------------------
 14 files changed, 159 insertions(+), 421 deletions(-)

-- 
2.8.2
