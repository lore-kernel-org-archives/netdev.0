From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 21/21] RDS: Add AF and PF #defines for RDS sockets
Date: Mon, 26 Jan 2009 18:17:58 -0800
Message-ID: <1233022678-9259-22-git-send-email-andy.grover@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:47652 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224AbZA0CS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 21:18:57 -0500
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
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
index 20fc4bb..fda91af 100644
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
-- 
1.5.6.3

