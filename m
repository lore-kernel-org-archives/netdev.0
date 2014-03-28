From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 0/2] tipc: fix handling of NETDEV_CHANGEADDR event
Date: Fri, 28 Mar 2014 10:32:07 +0100
Message-ID: <1395999129-31688-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, <aleksandar.igic@dektech.com.au>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg20.ericsson.net ([193.180.251.50]:45263 "EHLO
	sessmg20.mgmt.ericsson.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750893AbaC1Jbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:31:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Aside from manual reconfiguration of the netdevice hwaddr, this can also
be changed automatically for an interface bond in active-backup mode
if fail_over_mac is enabled. This patchset fixes the handling of this
event in TIPC by properly updating the l2 media address for the bearer,
followed by a reinitialization of the node discovery mechanism.

Erik Hugne (2):
  tipc: fix neighbor detection problem after hw address change
  tipc: make discovery domain a bearer attribute

 net/tipc/bearer.c   |  9 ++++++++-
 net/tipc/bearer.h   |  2 ++
 net/tipc/discover.c | 19 +++++++------------
 net/tipc/discover.h |  3 +--
 4 files changed, 18 insertions(+), 15 deletions(-)

-- 
1.8.3.2
