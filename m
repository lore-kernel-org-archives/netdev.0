From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/6] documentation enhancements
Date: Fri, 18 Sep 2015 20:16:59 +0200
Message-ID: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39502 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbbIRSRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 14:17:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series extends manpages of ip-address and ip by a few smaller things,
practically rewrites lnstat manpage to cover in detail what it is used for and
what the meanings of the available statistics are, adds a minimal manpage for
the rtpr script and last but not least fixes two remaining file headers listing
an incorrect FSF address.

Phil Sutter (6):
  man: ip-address: align synopsis with help output
  man: ip: add -h[uman-readable] option
  comment: Fix remaining listings of wrong FSF address
  man: ip-address: document mngtmpaddr and noprefixroute flags
  man: lnstat: rewrite manpage
  man: rtpr: add minimal manpage

 include/linux/tc_act/tc_skbedit.h |   3 +-
 man/man8/Makefile                 |   2 +-
 man/man8/ip-address.8.in          |  20 +++-
 man/man8/ip.8                     |   5 +
 man/man8/lnstat.8                 | 197 +++++++++++++++++++++++++++++++++++++-
 man/man8/rtpr.8                   |  25 +++++
 tc/m_connmark.c                   |   3 +-
 7 files changed, 243 insertions(+), 12 deletions(-)
 create mode 100644 man/man8/rtpr.8

-- 
2.1.2
