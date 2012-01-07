From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Sat, 07 Jan 2012 12:13:39 -0800 (PST)
Message-ID: <20120107.121339.633839797125273714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab2AGUNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 15:13:40 -0500
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q07KDdXw008330
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 7 Jan 2012 12:13:39 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/Kconfig |    6 +++++-
 net/unix/Kconfig |    2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 1a8f93b..43e1439 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -410,8 +410,12 @@ config INET_TCP_DIAG
 	def_tristate INET_DIAG
 
 config INET_UDP_DIAG
+	tristate "UDP: socket monitoring interface"
 	depends on INET_DIAG
-	def_tristate INET_DIAG && IPV6
+	default n
+	---help---
+	  Support for UDP socket monitoring interface used by the ss tool.
+	  If unsure, say Y.
 
 menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
diff --git a/net/unix/Kconfig b/net/unix/Kconfig
index c2128b1..8b31ab8 100644
--- a/net/unix/Kconfig
+++ b/net/unix/Kconfig
@@ -22,7 +22,7 @@ config UNIX
 config UNIX_DIAG
 	tristate "UNIX: socket monitoring interface"
 	depends on UNIX
-	default UNIX
+	default n
 	---help---
 	  Support for UNIX socket monitoring interface used by the ss tool.
 	  If unsure, say Y.
-- 
1.7.6.5
