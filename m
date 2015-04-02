From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: remove some unnecessary complexity
Date: Thu,  2 Apr 2015 09:32:59 -0400
Message-ID: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:29582 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227AbbDBNdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 09:33:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TIPC code is unnecessarily complex in some places, often because
the conditions or assumptions that were the cause for the complexity
are not valid anymore.

In these three commits, we eliminate some cases of such redundant
complexity.

Jon Maloy (3):
  tipc: drop tunneled packet duplicates at reception
  tipc: eliminate delayed link deletion at link failover
  tipc: simplify link mtu negotiation

 net/tipc/bcast.c |   4 +-
 net/tipc/link.c  | 343 ++++++++++++++++++-------------------------------------
 net/tipc/link.h  |  29 +++--
 net/tipc/msg.c   |   4 +-
 net/tipc/msg.h   |  10 +-
 net/tipc/node.c  |  22 ++--
 6 files changed, 147 insertions(+), 265 deletions(-)

-- 
1.9.1
