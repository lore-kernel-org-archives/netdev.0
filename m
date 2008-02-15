From: Johann Felix Soden <johfel@gmx.de>
Subject: [PATCH] [XFRM] Add CONFIG_INET dependency to CONFIG_XFRM_STATISTICS
Date: Fri, 15 Feb 2008 16:08:43 +0100
Message-ID: <1203088123.29269.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:54851 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756878AbYBOPIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 10:08:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Felix Soden <johfel@users.sourceforge.net>

With INET=n and XFRM_STATISTICS=y I get the following build failure:

net/built-in.o: In function `xfrm_init':
(.init.text+0xcd7): undefined reference to `snmp_mib_init'

Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>
CC: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/xfrm/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 8f9dbec..3bf2338 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -38,7 +38,7 @@ config XFRM_MIGRATE
 
 config XFRM_STATISTICS
 	bool "Transformation statistics (EXPERIMENTAL)"
-	depends on XFRM && PROC_FS && EXPERIMENTAL
+	depends on XFRM && PROC_FS && INET && EXPERIMENTAL
 	---help---
 	  This statistics is not a SNMP/MIB specification but shows
 	  statistics about transformation error (or almost error) factor
-- 
1.5.4.1


