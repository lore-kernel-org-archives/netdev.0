From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 0/3] tipc: three bug fixes
Date: Thu, 23 Apr 2015 09:37:37 -0400
Message-ID: <1429796260-14178-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:23971 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933919AbbDWNiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 09:38:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A set of unrelated corrections; one for the tipc netns implementation,
one regarding problems with random link resets, and one removing a
an erroneous refcount decrement when reading link statistsics via
netlink.

Erik Hugne (2):
  tipc: fix random link reset problem
  tipc: fix node refcount issue

Ying Xue (1):
  tipc: fix topology server broken issue

 net/tipc/link.c   | 1 -
 net/tipc/server.c | 9 +++------
 net/tipc/socket.c | 3 ++-
 3 files changed, 5 insertions(+), 8 deletions(-)

-- 
1.9.1
