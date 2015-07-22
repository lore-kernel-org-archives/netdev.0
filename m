From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: clean up socket message reception
Date: Wed, 22 Jul 2015 10:11:17 -0400
Message-ID: <1437574280-12485-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.biz.mail.bf1.yahoo.com ([98.139.221.60]:30404 "EHLO
	smtp101.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933561AbbGVOLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 10:11:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite recent improvements the message reception code in socket.c is
perceived as obscure and hard to follow, especially regarding the logics
for message rejection. With the commits in this series we try to remedy
this situation.

Jon Maloy (3):
  tipc: let function tipc_msg_reverse() expand header when needed
  tipc: introduce new tipc_sk_respond() function
  tipc: clean up socket layer message reception

 net/tipc/msg.c    |  86 ++++++++-------
 net/tipc/msg.h    |   6 +-
 net/tipc/socket.c | 322 +++++++++++++++++++++++++++---------------------------
 net/tipc/socket.h |   2 +-
 4 files changed, 213 insertions(+), 203 deletions(-)

-- 
1.9.1
