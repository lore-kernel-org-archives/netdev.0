From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 0/3] tipc: three small fixes
Date: Mon, 11 Jul 2016 16:08:34 -0400
Message-ID: <1468267717-518-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:32430 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbcGKUIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes for some broadcast link problems that may occur in large systems.

Jon Maloy (3):
  tipc: extend broadcast link initialization criteria
  tipc: ensure correct broadcast send buffer release when peer is lost
  tipc: reset all unicast links when broadcast send link fails

 net/tipc/bearer.c | 15 +++++++++++++++
 net/tipc/bearer.h |  1 +
 net/tipc/link.c   |  9 ++++++++-
 net/tipc/node.c   | 15 +++++++++++----
 4 files changed, 35 insertions(+), 5 deletions(-)

-- 
1.9.1
