From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH/RFC 0/2] HFSC & Stab documentation
Date: Fri, 27 Feb 2009 00:01:30 +0100
Message-ID: <cover.1235685021.git.soltys@ziu.info>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:2960 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754943AbZBZXWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 18:22:09 -0500
Received: from localhost.ppgk.com.pl (localhost [127.0.0.1])
	by relay.ppgk.com.pl (Postfix) with ESMTP id 08DF63761B
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 00:13:38 +0100 (CET)
Received: from relay.ppgk.com.pl ([127.0.0.1])
	by localhost.ppgk.com.pl (relay.ppgk.com.pl [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id kig9LbS9gele for <netdev@vger.kernel.org>;
	Fri, 27 Feb 2009 00:13:37 +0100 (CET)
Received: from localhost.localdomain (87-205-204-139.adsl.inetia.pl [87.205.204.139])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by relay.ppgk.com.pl (Postfix) with ESMTPSA id 2F3B0375DC
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 00:13:37 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add documentation for HFSC scheduler
and size tables. See patch covers for detailed info.

Michal Soltys (2):
  HFSC (7) & (8) documentation + assorted changes
  Stab documentation + assorted changes

 Makefile           |    2 +
 man/man7/tc-hfsc.7 |  525 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tc-hfsc.8 |   61 ++++++
 man/man8/tc-stab.8 |  156 ++++++++++++++++
 man/man8/tc.8      |    3 +
 tc/q_hfsc.c        |    6 +-
 tc/tc_core.c       |    4 +-
 tc/tc_stab.c       |    9 +-
 8 files changed, 759 insertions(+), 7 deletions(-)
 create mode 100644 man/man7/tc-hfsc.7
 create mode 100644 man/man8/tc-hfsc.8
 create mode 100644 man/man8/tc-stab.8

