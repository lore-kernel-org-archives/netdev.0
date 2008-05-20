From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/5 net-next-2.6] [TIPC]: Fixes to several obscure problems
Date: Tue, 20 May 2008 17:08:27 -0400
Message-ID: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41771 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757460AbYETVJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 17:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set is a collection of small changes that fix issues in TIPC that do
not impact typical users.  Please see each individual patch for a further
description of each item.

Summary:

 include/linux/tipc_config.h |   10 +++++++++-
 net/tipc/config.c           |    9 ++++++---
 net/tipc/core.c             |    4 ++--
 net/tipc/core.h             |    2 +-
 net/tipc/discover.c         |    5 ++---
 net/tipc/net.c              |   10 +++++++---
 net/tipc/net.h              |    2 +-
 net/tipc/netlink.c          |   16 +++++++++-------
 net/tipc/node.c             |   26 ++++++++++++++++++++++++++
 net/tipc/port.c             |    1 +
 10 files changed, 64 insertions(+), 21 deletions(-)

Allan Stephens (5):
      [TIPC]: Fix skb_under_panic when configuring TIPC without privileges
      [TIPC]: Prevent node object duplication due to simultaneous discovery
      [TIPC]: Optimize null pointer check during neighbor discovery
      [TIPC]: Update "previous node" indicators when node address changes
      [TIPC]: Fix initialization sequence problems when entering network mode

Thanks,
Al
