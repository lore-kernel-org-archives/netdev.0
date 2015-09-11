From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V5 net-next 1/2] net: introduce socket family constants
Date: Fri, 11 Sep 2015 14:09:09 +0200
Message-ID: <1441973350-62517-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1441973350-62517-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:40817 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbbIKMJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 08:09:26 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Sep 2015 13:09:22 +0100
In-Reply-To: <1441973350-62517-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The new socket family is assigned the next available address / protocol
family constant 41.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 include/linux/socket.h |  4 +++-
 include/net/smc.h      | 13 +++++++++++++
 2 files changed, 16 insertions(+), 1 deletion(-)
 create mode 100644 include/net/smc.h

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5bf59c8..1adcbcc 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -200,7 +200,8 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_SMC		41	/* smc sockets			*/
+#define AF_MAX		42	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -246,6 +247,7 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_SMC		AF_SMC
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/net/smc.h b/include/net/smc.h
new file mode 100644
index 0000000..cd513ee
--- /dev/null
+++ b/include/net/smc.h
@@ -0,0 +1,13 @@
+/*
+ * SMC		Definitions for the SMC protocol.
+ *
+ * Author:	Ursula Braun <ursula.braun@de.ibm.com>
+ */
+#ifndef _SMC_H
+#define _SMC_H
+
+/* SMC socket options - disjunct with TCP socket options */
+#define SMC_KEEPALIVE		99	/* start/stop keepalives */
+
+#endif /* _SMC_H */
+
-- 
2.3.8
