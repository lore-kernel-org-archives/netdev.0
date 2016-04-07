From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 0/2] tipc: name distributor pernet queue
Date: Thu,  7 Apr 2016 10:40:42 -0400
Message-ID: <1460040044-30770-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:23780 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756616AbcDGOlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 10:41:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit #1 fixes a potential issue with deferred binding table 
updates being pushed to the wrong namespace.

Commit #2 solves a problem with deferred binding table updates
remaining in the the defer queue after the issuing node has gone
down.

Erik Hugne (2):
  tipc: make dist queue pernet
  tipc: purge deferred updates from dead nodes

 net/tipc/core.c       |  1 +
 net/tipc/core.h       |  3 +++
 net/tipc/name_distr.c | 35 ++++++++++++++++++++++++++---------
 3 files changed, 30 insertions(+), 9 deletions(-)

-- 
1.9.1
