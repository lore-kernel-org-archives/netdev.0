From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH] RDS: Add AF and PF defines for RDS sockets
Date: Mon, 25 Aug 2008 21:02:17 -0700
Message-ID: <1219723337.6864.3.camel@lute.groveronline.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11461 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbYHZEI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 00:08:27 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m7Q48Pxu013554
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 23:08:25 -0500
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m7Q2IIOL021202
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 22:08:24 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS is a reliable datagram protocol used for IPC on Oracle
database clusters. This adds address and protocol family numbers
for it.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 include/linux/socket.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index dc5086f..e1f7764 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -190,7 +190,8 @@ struct ucred {
 #define AF_IUCV		32	/* IUCV sockets			*/
 #define AF_RXRPC	33	/* RxRPC sockets 		*/
 #define AF_ISDN		34	/* mISDN sockets 		*/
-#define AF_MAX		35	/* For now.. */
+#define AF_RDS		35	/* RDS sockets 			*/
+#define AF_MAX		36	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -227,6 +228,7 @@ struct ucred {
 #define PF_IUCV		AF_IUCV
 #define PF_RXRPC	AF_RXRPC
 #define PF_ISDN		AF_ISDN
+#define PF_RDS		AF_RDS
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
-- 
1.5.4.rc3



