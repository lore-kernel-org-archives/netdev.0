From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/7 net-2.6.26] [TIPC]: Initial patch set for TIPC 1.6.3
Date: Tue,  4 Mar 2008 16:20:12 -0500
Message-ID: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48046 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754494AbYCDVgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 16:36:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains code created as part of the TIPC 1.7 development
project.  It contains minor enhancements that do not introduce new features,
and is thus being integrated under the current TIPC 1.6 designation.

Summary:

 include/net/tipc/tipc_bearer.h |   10 ++++++++
 include/net/tipc/tipc_port.h   |    7 ------
 net/tipc/core.c                |   12 +---------
 net/tipc/core.h                |    7 ++++++
 net/tipc/link.c                |   16 ++++++-------
 net/tipc/msg.c                 |   16 ++++++-------
 net/tipc/msg.h                 |   50 ++++++++++------------------------------
 net/tipc/port.c                |   12 ++--------
 net/tipc/socket.c              |    5 ++--
 9 files changed, 53 insertions(+), 82 deletions(-)

Allan Stephens (7):
      [TIPC]: Update version to 1.6.3
      [TIPC]: Add argument validation for shutdown()
      [TIPC]: Eliminate "sparse" warning in socket code
      [TIPC]: Minor cleanup of message header code
      [TIPC]: Use correct bitmask when setting version in message
      [TIPC]: Enhancements to message header field writing
      [TIPC]: Removal of obsolete message header option code

Thanks,
Al
