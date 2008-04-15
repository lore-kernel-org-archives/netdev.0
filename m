From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/7 net-2.6.26] [TIPC]: Ref table and message buffer changes
Date: Tue, 15 Apr 2008 15:43:50 -0400
Message-ID: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46921 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755426AbYDOTpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 15:45:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set includes 3 patches enhancing the operation of TIPC's object
reference table, and 4 patches that enhance TIPC's handling of message
buffers.  Please see each individual patch for further description.

Summary:

 net/tipc/core.h |   17 +++-
 net/tipc/link.c |   95 ++++++++++++++++++++---
 net/tipc/ref.c  |  225 ++++++++++++++++++++++++++++++++++++++++---------------
 net/tipc/ref.h  |   89 +-------------------	--
 4 files changed, 263 insertions(+), 163 deletions(-)

Allan Stephens (7):
      [TIPC]: Remove inlining of reference table locking routines
      [TIPC]: Optimized initialization of TIPC reference table
      [TIPC]: Cleanup of TIPC reference table code
      [TIPC]: Remove redundant NULL check when discarding buffers
      [TIPC]: Use fast buffer cloning to improve performance
      [TIPC]: Force linearization of non-linear sk_buffs
      [TIPC]: Enhance validation of format on incoming messages

Thanks,
Al
