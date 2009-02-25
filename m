From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 23/26] RDS: Add AF and PF #defines for RDS sockets
Date: Tue, 24 Feb 2009 17:30:40 -0800
Message-ID: <1235525443-9007-24-git-send-email-andy.grover@oracle.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49080 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754323AbZBYBbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:31:40 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS is a reliable datagram protocol used for IPC on Oracle
database clusters. This adds address and protocol family numbers
for it.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 include/linux/socket.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 20fc4bb..3cdc041 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -191,7 +191,8 @@ struct ucred {
 #define AF_RXRPC	33	/* RxRPC sockets 		*/
 #define AF_ISDN		34	/* mISDN sockets 		*/
 #define AF_PHONET	35	/* Phonet sockets		*/
-#define AF_MAX		36	/* For now.. */
+#define AF_RDS		36	/* RDS sockets 			*/
+#define AF_MAX		37	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -229,6 +230,7 @@ struct ucred {
 #define PF_RXRPC	AF_RXRPC
 #define PF_ISDN		AF_ISDN
 #define PF_PHONET	AF_PHONET
+#define PF_RDS		AF_RDS
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -298,6 +300,7 @@ struct ucred {
 #define SOL_PPPOL2TP	273
 #define SOL_BLUETOOTH	274
 #define SOL_PNPIPE	275
+#define SOL_RDS		276
 
 /* IPX options */
 #define IPX_TYPE	1
-- 
1.5.6.3

