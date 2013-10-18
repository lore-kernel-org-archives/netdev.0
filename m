From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 0/8] tipc: some small patches
Date: Fri, 18 Oct 2013 07:23:13 +0200
Message-ID: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
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
Received: from smtp104.biz.mail.gq1.yahoo.com ([98.137.12.179]:46698 "HELO
	smtp104.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750797Ab3JRFaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 01:30:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some small and relatively straightforward patches. With exception of
the two first ones they are all unrelated and address minor issues.

v2: update of v1 (http://patchwork.ozlabs.org/patch/277404/)

-added commit to use memcpy_fromiovec on user data as per v1 feedback
-updated sparse fix commit to drop chunks covered by above commit
-added new commit that greatly simplifies the link lookup routine

Erik Hugne (1):
  tipc: simplify the link lookup routine

Ying Xue (7):
  tipc: don't use memcpy to copy from user space
  tipc: remove iovec length parameter from all sending functions
  tipc: silence sparse warnings
  tipc: make bearer and media naming consistent
  tipc: avoid unnecessary lookup for tipc bearer instance
  tipc: correct return value of recv_msg routine
  tipc: correct return value of link_cmd_set_value routine

 net/tipc/bearer.c    |   18 ++----
 net/tipc/bearer.h    |   10 +--
 net/tipc/eth_media.c |   68 ++++++++++----------
 net/tipc/ib_media.c  |   58 +++++++++---------
 net/tipc/link.c      |  167 +++++++++++++-------------------------------------
 net/tipc/link.h      |    4 +-
 net/tipc/msg.c       |   27 ++++----
 net/tipc/msg.h       |    3 +-
 net/tipc/port.c      |   66 ++++++++------------
 net/tipc/port.h      |   16 ++---
 net/tipc/socket.c    |   12 ++--
 11 files changed, 167 insertions(+), 282 deletions(-)

-- 
1.7.9.5
