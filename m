From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: redesign socket-level flow control
Date: Mon,  2 May 2016 11:58:44 -0400
Message-ID: <1462204727-9224-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.bf1.yahoo.com ([98.139.244.54]:31537 "EHLO
	smtp106.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754022AbcEBP71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 11:59:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket-level flow control in TIPC has long been due for a major
overhaul. This series fixes this.

Jon Maloy (3):
  tipc: re-enable compensation for socket receive buffer double counting
  tipc: propagate peer node capabilities to socket layer
  tipc: redesign connection-level flow control

 net/tipc/core.c   |   8 ++-
 net/tipc/msg.h    |  14 +++++-
 net/tipc/node.c   |  21 +++++++-
 net/tipc/node.h   |   6 ++-
 net/tipc/socket.c | 144 +++++++++++++++++++++++++++++++++++-------------------
 net/tipc/socket.h |  17 +++++--
 6 files changed, 145 insertions(+), 65 deletions(-)

-- 
1.9.1
