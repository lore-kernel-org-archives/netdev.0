From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/7 net-2.6.26] [TIPC]: Initial patch set for TIPC 1.6.3
Date: Thu,  6 Mar 2008 16:34:22 -0500
Message-ID: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55387 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763678AbYCFVu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 16:50:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains code created as part of the TIPC 1.7 development
project.  It contains minor enhancements that do not introduce new features,
and is thus being integrated under the current TIPC 1.6 designation.

Summary:

 include/net/tipc/tipc_bearer.h |    9 +++++++
 include/net/tipc/tipc_port.h   |    7 ------
 net/tipc/core.c                |   11 +--------
 net/tipc/core.h                |    6 +++++
 net/tipc/link.c                |   16 ++++++-------
 net/tipc/msg.c                 |   16 ++++++-------
 net/tipc/msg.h                 |   50 ++++++++++------------------------------
 net/tipc/port.c                |   12 ++--------
 net/tipc/socket.c              |    5 ++--
 9 files changed, 51 insertions(+), 81 deletions(-)

Allan Stephens (7):
      [TIPC]: Removal of message header option code
      [TIPC]: Add argument validation for shutdown()
      [TIPC]: Eliminate "sparse" symbol warnings
      [TIPC]: Minor cleanup of message header code
      [TIPC]: Use correct bitmask when setting version
      [TIPC]: Enhancements to message header writing
      [TIPC]: Update version to 1.6.3

Thanks,
Al
