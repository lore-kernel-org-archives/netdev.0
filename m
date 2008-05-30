From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 00/13 net-next-2.6] [TIPC]: More minor fixes and enhancements
Date: Fri, 30 May 2008 14:20:35 -0400
Message-ID: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50489 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752969AbYE3SXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set is another collection of small changes to TIPC that fix obscure
problems, plus some minor enhancements.  Please see each individual patch for
a more detailed description of each change.

Summary:

 net/tipc/bcast.c      |    4 ++-
 net/tipc/cluster.c    |    2 +-
 net/tipc/discover.c   |    9 +++----
 net/tipc/discover.h   |    2 +-
 net/tipc/link.c       |   60 +++++++++++++++++++++----------------------------
 net/tipc/msg.c        |    3 --
 net/tipc/msg.h        |   42 ++++++++++++++++++++++++++++------
 net/tipc/name_distr.c |    3 +-
 net/tipc/name_table.c |    7 +++++-
 net/tipc/port.c       |   58 +++++++++++++++++++----------------------------
 10 files changed, 98 insertions(+), 92 deletions(-)

Allan Stephens (13):
      [TIPC]: Fix bug in connection setup via native API
      [TIPC]: Standardize error checking on incoming messages via native API
      [TIPC]: Fix bugs in message error code display when debugging
      [TIPC]: Fix minor bugs in link session number handling
      [TIPC]: Minor optimizations to received message processing
      [TIPC]: Prevent access of non-existent field in short message header
      [TIPC]: Optimize message initialization routine
      [TIPC]: Prevent display of name table types with no publications
      [TIPC]: Add missing spinlock in name table display code
      [TIPC]: Expand link sequence gap field to 13 bits
      [TIPC]: Message header creation optimizations
      [TIPC]: Fix bugs in rejection of message with short header
      [TIPC]: Message rejection rework preparatory changes

Thanks,
Al
