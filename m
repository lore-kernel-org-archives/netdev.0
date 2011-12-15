From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/13] sock_diag: Move the SOCK_DIAG_BY_FAMILY cmd declaration
Date: Thu, 15 Dec 2011 16:42:42 +0400
Message-ID: <4EE9EB42.7010506@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26298 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758745Ab1LOMmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:42:47 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should belong to sock_diag, not inet_diag.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    1 -
 include/linux/sock_diag.h |    3 +++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 78972a1..a27e621 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -6,7 +6,6 @@
 /* Just some random number */
 #define TCPDIAG_GETSOCK 18
 #define DCCPDIAG_GETSOCK 19
-#define SOCK_DIAG_BY_FAMILY 20
 
 #define INET_DIAG_GETSOCK_MAX 24
 
diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index ba4933b..7999778 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -1,5 +1,8 @@
 #ifndef __SOCK_DIAG_H__
 #define __SOCK_DIAG_H__
+
+#define SOCK_DIAG_BY_FAMILY 20
+
 struct sk_buff;
 struct nlmsghdr;
 
-- 
1.5.5.6
