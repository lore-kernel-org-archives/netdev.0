From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/7 net-2.6.26] [TIPC]: More socket code enhancements
Date: Mon, 14 Apr 2008 17:16:27 -0400
Message-ID: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55741 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761354AbYDNVSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set includes a number fixes/cleanups to TIPC's socket code.
The first 6 are fairly trivial, while the last one does a complete overhaul
of the locking TIPC uses to make it more Linux-like.  Please see each
individual patch for a further description.

Summary:

 include/net/tipc/tipc_port.h |    6 
 net/tipc/port.c              |   31 +
 net/tipc/socket.c            | 1113 ++++++++++++++++++++++++------------------
 3 files changed, 667 insertions(+), 483 deletions(-)

Allan Stephens (7):
      [TIPC]: Skip connection flow control in connectionless sockets
      [TIPC]: Allow stream receive to read from multiple TIPC messages
      [TIPC]: Ignore message padding when receiving stream data
      [TIPC]: Correct "off by 1" error in socket queue limit enforcement
      [TIPC]: Add error check to detect non-blocking form of connect()
      [TIPC]: Cosmetic changes to TIPC connect() code
      [TIPC]: Overhaul of socket locking logic

Thanks,
Al
