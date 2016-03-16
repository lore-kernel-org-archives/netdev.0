From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/4] tc: pedit: further fixes
Date: Wed, 16 Mar 2016 22:48:31 +0100
Message-ID: <1458164915-31802-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40574 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbcCPVst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 17:48:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series was created after testing pedit on a big-endian
system. It starts with a patch fixing coding style in tc/p_ip.c, then the
actual big-endian fixup, a fix for raw op discovered when writing the
pedit test for testsuite and finally the actual testsuite addon.

Phil Sutter (4):
  tc/p_ip.c: Lint through checkpatch.pl
  tc: pedit: Fix for big-endian systems
  tc: pedit: Fix raw op
  testsuite: add a test for tc pedit action

 tc/m_pedit.c               |  23 ++---
 tc/p_ip.c                  |  38 ++++----
 testsuite/tests/tc/pedit.t | 217 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 250 insertions(+), 28 deletions(-)
 create mode 100755 testsuite/tests/tc/pedit.t

-- 
2.7.2
