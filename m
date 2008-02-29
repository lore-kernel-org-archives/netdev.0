From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: [PATCH 03/08 net-2.6.26] [TIPC]: Eliminate "sparse" warning in socket code
Date: Fri, 29 Feb 2008 10:40:46 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0252DE22@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51631 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758993AbYB2Sks convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:40:48 -0500
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id m1TIelTj012240
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 10:40:47 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates warnings about a pair of undeclared symbols.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e5a6983..356a18c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -81,6 +81,12 @@ static int sockets_enabled = 0;
 
 static atomic_t tipc_queue_size = ATOMIC_INIT(0);
 
+/*
+ * Declare public routines so "sparse" doesn't complain ...
+ */
+
+extern int  tipc_socket_init(void);
+extern void tipc_socket_stop(void);
 
 /*
  * sock_lock(): Lock a port/socket pair. lock_sock() can
-- 
1.5.3.2
