From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/2] Two minor testsuite fixes
Date: Thu,  9 Feb 2017 11:50:53 +0100
Message-ID: <20170209105055.2477-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48025 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752329AbdBILAh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 06:00:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While playing around with testsuite, I noticed two minor nits which this
series attempts to fix.

Changes since v1:
- Replaced patch1 completely.

Phil Sutter (2):
  testsuite: Generate nlmsg blob at runtime
  testsuite: Search kernel config in modules dir also

 .gitignore                                |   2 +
 testsuite/Makefile                        |   8 +++
 testsuite/tests/ip/link/dev_wo_vf_rate.nl | Bin 14076 -> 0 bytes
 testsuite/tools/Makefile                  |   2 +
 testsuite/tools/generate_nlmsg.c          | 116 ++++++++++++++++++++++++++++++
 5 files changed, 128 insertions(+)
 delete mode 100644 testsuite/tests/ip/link/dev_wo_vf_rate.nl
 create mode 100644 testsuite/tools/Makefile
 create mode 100644 testsuite/tools/generate_nlmsg.c

-- 
2.11.0
