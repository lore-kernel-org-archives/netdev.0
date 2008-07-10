From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/7 net-next-2.6] tipc: More miscellaneous fixes & optimizations
Date: Thu, 10 Jul 2008 17:26:04 -0400
Message-ID: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33081 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbYGJVZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set includes a number of bug fixes and optimizations for TIPC.
Please see each individual patch for a further description.

Summary:

 include/net/tipc/tipc_port.h |   13 ++-------
 net/tipc/bcast.c             |   10 +++----
 net/tipc/bearer.c            |    8 +++--
 net/tipc/cluster.c           |    2 +
 net/tipc/eth_media.c         |    6 ++--
 net/tipc/link.c              |   18 ++++++------
 net/tipc/name_table.c        |   41 ++++++++++++++++++++--------
 net/tipc/net.c               |    4 +--
 net/tipc/node.c              |   29 ++++++++++++++++----
 net/tipc/port.c              |   62 ++++++++++++++++++------------------------
 net/tipc/ref.c               |    2 +
 net/tipc/socket.c            |   59 ++++++++++++++++++++--------------------
 net/tipc/user_reg.c          |   14 +++++----
 13 files changed, 146 insertions(+), 122 deletions(-)

Allan Stephens (7):
      tipc: Remove unneeded parameter to tipc_createport_raw()
      tipc: Optimize pointer dereferencing when receiving stream data
      tipc: Fix race condition that could cause accept() to fail
      tipc: Eliminate improper use of TIPC_OK error code
      tipc: Fix bug in scope checking for multicast messages
      tipc: Add missing locks when inspecting node list & link list
      tipc: Optimization to multicast name lookup algorithm

Thanks,
Al
