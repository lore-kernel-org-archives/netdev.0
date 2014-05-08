From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/2] overhaul node action flags
Date: Thu, 8 May 2014 08:54:38 +0800
Message-ID: <1399510480-29558-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53167 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbaEHAy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 20:54:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently have two problems with the node flags field:
 - The naming of the individual action flags is unclear and confusing
 - The flags are often not cleared individually,  making it hard to follow
   where this happens.

So the series aims to solve above two problems.


Ying Xue (2):
  tipc: rename enum names of node flags
  tipc: don't directly overwrite node action_flags

 net/tipc/link.c |    6 +++---
 net/tipc/node.c |   19 +++++++++++--------
 net/tipc/node.h |   29 +++++++++++++----------------
 3 files changed, 27 insertions(+), 27 deletions(-)

-- 
1.7.9.5
