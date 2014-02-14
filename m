From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/2] tipc: eliminate smatch warnings
Date: Fri, 14 Feb 2014 16:40:42 -0500
Message-ID: <1392414044-14326-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:21109 "HELO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752676AbaBNVr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:47:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We fix a couple of issues introduced by the series 
"tipc: clean up media and bearer layer". 

Thanks to Dan Carpenter and Walter Harms for highlighting this.

Jon Maloy (2):
  tipc: fix a loop style problem
  tipc: correct usage of spin_lock() vs spin_lock_bh()

 net/tipc/link.c |    6 +++---
 net/tipc/node.c |   10 +++++-----
 2 files changed, 8 insertions(+), 8 deletions(-)

-- 
1.7.9.5
