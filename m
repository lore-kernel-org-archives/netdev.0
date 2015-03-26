From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/2] tipc: fix two corner issues
Date: Thu, 26 Mar 2015 18:10:22 +0800
Message-ID: <1427364624-5930-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34667 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbbCZKKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 06:10:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch set aims at resolving the following two critical issues:

Patch #1: Resolve a deadlock which happens while all links are reset
Patch #2: Correct a mistake usage of RCU lock which is used to protect
          node list

Ying Xue (2):
  tipc: fix potential deadlock when all links are reset
  tipc: involve reference counter for node structure

 net/tipc/bcast.c      |   28 +++------------
 net/tipc/bcast.h      |    4 ---
 net/tipc/discover.c   |    1 +
 net/tipc/link.c       |   12 +++----
 net/tipc/name_distr.c |    2 ++
 net/tipc/node.c       |   90 +++++++++++++++++++++++++++++++++++--------------
 net/tipc/node.h       |   12 +++++--
 7 files changed, 87 insertions(+), 62 deletions(-)

-- 
1.7.9.5
