From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/8] Follow-up to my action man pages series
Date: Wed, 16 Mar 2016 22:56:16 +0100
Message-ID: <1458165384-900-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59316 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656AbcCPV4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 17:56:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series aims at addressing feedback provided by Jamal
and Alexei. Thanks a lot for your input!

Phil Sutter (8):
  doc/tc-filters.tex: Drop overly subjective paragraphs
  tc: connmark, pedit: Rename BRANCH to CONTROL
  man: tc-csum.8: Add an example
  man: tc-mirred.8: Reword man page a bit, add generic mirror example
  man: tc-police.8: Emphasize on the two rate control mechanisms
  man: tc-skbedit.8: Elaborate a bit on TX queues
  tc/m_vlan.c: mention CONTROL option in help text
  man: tc-vlan.8: Describe CONTROL option

 doc/tc-filters.tex     | 23 ++++-----------------
 man/man8/tc-connmark.8 |  6 +++---
 man/man8/tc-csum.8     | 15 ++++++++++++++
 man/man8/tc-mirred.8   | 26 ++++++++++++++++-------
 man/man8/tc-pedit.8    |  6 +++---
 man/man8/tc-police.8   | 29 ++++++++++++++++++++++----
 man/man8/tc-skbedit.8  | 14 +++++++++++++
 man/man8/tc-vlan.8     | 56 +++++++++++++++++++++++++++++++++++++++++++++++++-
 tc/m_connmark.c        |  4 ++--
 tc/m_pedit.c           |  4 ++--
 tc/m_vlan.c            |  3 ++-
 11 files changed, 144 insertions(+), 42 deletions(-)

-- 
2.7.2
