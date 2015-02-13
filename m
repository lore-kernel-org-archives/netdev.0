From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/7] ss: Unify socket info output to common funcs
Date: Fri, 13 Feb 2015 22:13:57 +0200
Message-ID: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:39023 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbbBMUZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:11 -0500
Received: by labgq15 with SMTP id gq15so18717335lab.6
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Split tcpstat struct into sockstat & tcpstat, old sockstat renamed
to sksummary.

Refactored printing socket info to common funcs.

Also fixed wrong setting tcp ato value.

Vadim Kochan (7):
  ss: Split tcpstap struct to sockstat & tcpstat
  ss: Replace pktstat struct by new sockstat struct
  ss: Replace unixstat struct by new sockstat struct
  ss: Unify state socket output:netid, state, rq, wq
  ss: Unify details info output:ino,uid,sk
  ss: Unify socket address output by one generic func
  ss: Fixed wrong tcp ato value from netlink

 include/utils.h |   2 +
 lib/utils.c     |   6 +
 misc/ss.c       | 539 +++++++++++++++++++++++++++++---------------------------
 3 files changed, 290 insertions(+), 257 deletions(-)

-- 
2.2.2
