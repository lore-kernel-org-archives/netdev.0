From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/4] A few more man pages and documentation fixup
Date: Thu, 29 Oct 2015 10:55:20 +0100
Message-ID: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54811 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbbJ2Jz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 05:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds man pages for ifcfg, genl and ifstat utilities. Some of
them have already been submitted once in 2013[1] but weren't picked up
for unknown reasons.

Along with this comes a final patch fixing bridge fdb help text.


[1]: http://lists.openwall.net/netdev/2013/05/27/102

Phil Sutter (4):
  ifcfg: add manpage
  genl: add manpage
  ifstat: add manpage
  bridge: fdb: minor syntax fix in help text

 bridge/fdb.c      |  6 ++---
 man/man8/genl.8   | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ifcfg.8  | 48 ++++++++++++++++++++++++++++++++++
 man/man8/ifstat.8 | 59 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 187 insertions(+), 3 deletions(-)
 create mode 100644 man/man8/genl.8
 create mode 100644 man/man8/ifcfg.8
 create mode 100644 man/man8/ifstat.8

-- 
2.1.2
