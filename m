From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/4] tc: pedit: further fixes
Date: Tue, 22 Mar 2016 15:16:20 +0100
Message-ID: <1458656184-22154-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45118 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758750AbcCVOQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:16:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series was created after testing pedit on a big-endian
system. It starts with a minor patch fixing coding style in tc/p_ip.c,
then the actual big-endian fixup, a fix for raw op discovered when
writing the pedit test for testsuite and finally a testsuite addon to
verify pedit functionality.

Changes since v1:
- Rebased whole series onto current master branch.
- Replaced patch 1/4 with a smaller one containing only the rebase
  leftovers.

Phil Sutter (4):
  tc/p_ip.c: Minor coding style cleanup
  tc: pedit: Fix for big-endian systems
  tc: pedit: Fix raw op
  testsuite: add a test for tc pedit action

 tc/m_pedit.c               |  23 ++---
 tc/p_ip.c                  |   8 +-
 testsuite/tests/tc/pedit.t | 217 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 235 insertions(+), 13 deletions(-)
 create mode 100755 testsuite/tests/tc/pedit.t

-- 
2.7.2
