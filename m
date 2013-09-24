From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/5] tipc: some small patches
Date: Tue, 24 Sep 2013 04:27:43 -0500
Message-ID: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.bf1.yahoo.com ([98.139.244.54]:29724 "HELO
	smtp106.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750713Ab3IXJev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 05:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some small and relatively straightforward patches that fix a number of
minor issues. The patches are functionally unrelated to each other.

Ying Xue (5):
  tipc: silence sparse warnings
  tipc: make bearer and media naming consistent
  tipc: avoid unnecessary lookup for tipc bearer instance
  tipc: correct return value of recv_msg routine
  tipc: correct return value of link_cmd_set_value routine

 net/tipc/bearer.c    |   18 ++++---------
 net/tipc/bearer.h    |   10 ++++----
 net/tipc/eth_media.c |   68 +++++++++++++++++++++++++-------------------------
 net/tipc/ib_media.c  |   58 +++++++++++++++++++++---------------------
 net/tipc/link.c      |   33 ++++++++++++++++--------
 net/tipc/msg.c       |    4 +--
 net/tipc/socket.c    |    6 ++---
 7 files changed, 100 insertions(+), 97 deletions(-)

-- 
1.7.9.5
