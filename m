From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] Two minor testsuite fixes
Date: Wed,  8 Feb 2017 00:04:20 +0100
Message-ID: <20170207230422.31936-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49547 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752702AbdBGXF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 18:05:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While playing around with testsuite, I noticed two minor nits which this
series attempts to fix.

Phil Sutter (2):
  testsuite: skip link show test on big endian systems
  testsuite: Search kernel config in modules dir also

 .gitignore                                    | 1 +
 testsuite/Makefile                            | 7 +++++++
 testsuite/tests/ip/link/show_dev_wo_vf_rate.t | 5 +++++
 testsuite/tools/Makefile                      | 2 ++
 testsuite/tools/is_big_endian.c               | 7 +++++++
 5 files changed, 22 insertions(+)
 create mode 100644 testsuite/tools/Makefile
 create mode 100644 testsuite/tools/is_big_endian.c

-- 
2.11.0
