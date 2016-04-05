From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 0/3] tipc: some small fixes
Date: Tue,  5 Apr 2016 16:35:33 -0400
Message-ID: <1459888536-22697-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.bf1.yahoo.com ([98.139.221.61]:48440 "EHLO
	smtp102.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648AbcDEUfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:35:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running TIPC in large clusters we experience behavior that
may potentially become problematic in the future. This series
picks some low-hanging fruit in this regard, and also fixes a
couple of other minor issues.

v2: Corrected typos in commit #3, as per feedback from S. Shtylyov

Jon Maloy (3):
  tipc: eliminate buffer leak in bearer layer
  tipc: stricter filtering of packets in bearer layer
  tipc: reduce transmission rate of reset messages when link is down

 net/tipc/bearer.c   | 101 ++++++++++++++++++++++++++++++----------------------
 net/tipc/discover.c |   7 ++--
 net/tipc/discover.h |   2 +-
 net/tipc/link.c     |  10 +++---
 net/tipc/msg.h      |   5 +++
 5 files changed, 73 insertions(+), 52 deletions(-)

-- 
1.9.1
