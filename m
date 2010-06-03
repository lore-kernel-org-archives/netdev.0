From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] syncookies: remove Kconfig text line about disabled-by-default
Date: Thu,  3 Jun 2010 12:42:30 +0200
Message-ID: <1275561750-24111-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:45150 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933805Ab0FCKo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:44:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

syncookies default to on since
e994b7c901ded7200b525a707c6da71f2cf6d4bb
(tcp: Don't make syn cookies initial setting depend on CONFIG_SYSCTL).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/Kconfig |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 8e3a1fd..7c3a7d1 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -303,7 +303,7 @@ config ARPD
 	  If unsure, say N.
 
 config SYN_COOKIES
-	bool "IP: TCP syncookie support (disabled per default)"
+	bool "IP: TCP syncookie support"
 	---help---
 	  Normal TCP/IP networking is open to an attack known as "SYN
 	  flooding". This denial-of-service attack prevents legitimate remote
@@ -328,13 +328,13 @@ config SYN_COOKIES
 	  server is really overloaded. If this happens frequently better turn
 	  them off.
 
-	  If you say Y here, note that SYN cookies aren't enabled by default;
-	  you can enable them by saying Y to "/proc file system support" and
+	  If you say Y here, you can disable SYN cookies at run time by
+	  saying Y to "/proc file system support" and
 	  "Sysctl support" below and executing the command
 
-	  echo 1 >/proc/sys/net/ipv4/tcp_syncookies
+	  echo 0 > /proc/sys/net/ipv4/tcp_syncookies
 
-	  at boot time after the /proc file system has been mounted.
+	  after the /proc file system has been mounted.
 
 	  If unsure, say N.
 
-- 
1.6.4.4

