From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [SCTP]: Kill unused static inline sctp_sysctl_jiffies_ms
Date: Fri, 29 Feb 2008 18:13:15 +0200
Message-ID: <1204301596-15568-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53417 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759372AbYB2QNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 11:13:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the patch:
$ git-grep sctp_sysctl_jiffies_ms | wc -l
0

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sctp.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 57df27f..a653eb3 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -368,11 +368,6 @@ void sctp_sysctl_unregister(void);
 #else
 static inline void sctp_sysctl_register(void) { return; }
 static inline void sctp_sysctl_unregister(void) { return; }
-static inline int sctp_sysctl_jiffies_ms(ctl_table *table, int __user =
*name, int nlen,
-		void __user *oldval, size_t __user *oldlenp,
-		void __user *newval, size_t newlen) {
-	return -ENOSYS;
-}
 #endif
=20
 /* Size of Supported Address Parameter for 'x' address types. */
--=20
1.5.2.2

