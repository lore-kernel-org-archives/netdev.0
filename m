From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 00/12] Add tc action man pages
Date: Fri,  4 Mar 2016 13:11:35 +0100
Message-ID: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42918 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755984AbcCDMNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:13:15 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id B5C916AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:13:13 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 984976894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:13:13 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series adds a set of man pages for previously
undocumented tc actions. On top of that, it adds an article about the
same topic to the docs directory I wrote a little while ago.

Phil Sutter (12):
  man: Add a man page for the connmark action
  man: Add a man page for the csum action.
  man: Add a man page for the mirred action
  man: Add a man page for the nat action
  man: Add a man page for the pedit action
  man: Add a man page for the police action
  man: Add a man page for the simple action
  man: Add a man page for the skbedit action
  man: Add a man page for the vlan action
  man: Add a man page for the xt action
  man: ship action man pages
  doc: Add my article about tc, filters and actions

 .gitignore             |   1 +
 doc/Makefile           |   2 +-
 doc/tc-filters.tex     | 529 +++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/Makefile      |   4 +-
 man/man8/tc-connmark.8 |  55 +++++
 man/man8/tc-csum.8     |  54 +++++
 man/man8/tc-mirred.8   |  89 +++++++++
 man/man8/tc-nat.8      |  78 ++++++++
 man/man8/tc-pedit.8    | 230 +++++++++++++++++++++
 man/man8/tc-police.8   | 127 ++++++++++++
 man/man8/tc-simple.8   |  76 +++++++
 man/man8/tc-skbedit.8  |  45 +++++
 man/man8/tc-vlan.8     |  54 +++++
 man/man8/tc-xt.8       |  42 ++++
 14 files changed, 1384 insertions(+), 2 deletions(-)
 create mode 100644 doc/tc-filters.tex
 create mode 100644 man/man8/tc-connmark.8
 create mode 100644 man/man8/tc-csum.8
 create mode 100644 man/man8/tc-mirred.8
 create mode 100644 man/man8/tc-nat.8
 create mode 100644 man/man8/tc-pedit.8
 create mode 100644 man/man8/tc-police.8
 create mode 100644 man/man8/tc-simple.8
 create mode 100644 man/man8/tc-skbedit.8
 create mode 100644 man/man8/tc-vlan.8
 create mode 100644 man/man8/tc-xt.8

-- 
2.7.2
