From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] socket: Add SO_RXQ_OVFL documentation
Date: Tue, 28 Jan 2014 07:24:37 -0500
Message-ID: <1390911877-5984-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, mtk.manpages@gmail.com,
	andi@firstfloor.org, netdev@vger.kernel.org
To: linux-man@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45854 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbaA1MYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 07:24:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation for the SO_RXQ_OVFL socket option

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: mtk.manpages@gmail.com
CC: andi@firstfloor.org
CC: netdev@vger.kernel.org
---
 man7/socket.7 | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/man7/socket.7 b/man7/socket.7
index 6b229dd..aa0aad9 100644
--- a/man7/socket.7
+++ b/man7/socket.7
@@ -663,6 +663,11 @@ with a specific port then it is not possible
 to bind to this port for any local address.
 Argument is an integer boolean flag.
 .TP
+.B SO_RXQ_OVFL
+Indicates that an unsigned 32 bit value ancilliary msg (cmsg) should be attached
+to recieved skbs indicating the number of packets dropped by the socket between
+the last recieved packet and this received packet
+.TP
 .B SO_SNDBUF
 Sets or gets the maximum socket send buffer in bytes.
 The kernel doubles this value (to allow space for bookkeeping overhead)
-- 
1.8.3.1
