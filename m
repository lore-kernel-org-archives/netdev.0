From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: fix link failover/synch problems
Date: Thu, 20 Aug 2015 02:12:53 -0400
Message-ID: <1440051176-32672-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:44739 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbbHTGNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 02:13:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We fix three problems with the new link failover/synch implementation,
which was introduced earlier in this release cycle. They are all related
to situations where there is a very short interval between the disabling
and enabling of interfaces.

Jon Maloy (3):
  tipc: eliminate risk of premature link setup during failover
  tipc: interrupt link synchronization when a link goes down
  tipc: fix stale link problem during synchronization

 net/tipc/link.c |  5 +++--
 net/tipc/node.c | 27 +++++++++++++++++++++------
 2 files changed, 24 insertions(+), 8 deletions(-)

-- 
1.9.1
