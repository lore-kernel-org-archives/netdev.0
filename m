From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 13/13] unix_diag: Write it into kbuild
Date: Thu, 15 Dec 2011 16:46:50 +0400
Message-ID: <4EE9EC3A.8030803@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9037 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932519Ab1LOMq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:46:56 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/Kconfig  |    7 +++++++
 net/unix/Makefile |    3 +++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/unix/Kconfig b/net/unix/Kconfig
index 5a69733..52db53c 100644
--- a/net/unix/Kconfig
+++ b/net/unix/Kconfig
@@ -19,3 +19,10 @@ config UNIX
 
 	  Say Y unless you know what you are doing.
 
+config UNIX_DIAG
+	tristate "UNIX: socket monitoring interface"
+	depends on UNIX
+	default UNIX
+	---help---
+	  Support for UNIX socket monitoring interface used by the ss tool.
+	  If unsure, say Y.
diff --git a/net/unix/Makefile b/net/unix/Makefile
index b852a2b..b663c60 100644
--- a/net/unix/Makefile
+++ b/net/unix/Makefile
@@ -6,3 +6,6 @@ obj-$(CONFIG_UNIX)	+= unix.o
 
 unix-y			:= af_unix.o garbage.o
 unix-$(CONFIG_SYSCTL)	+= sysctl_net_unix.o
+
+obj-$(CONFIG_UNIX_DIAG)	+= unix_diag.o
+unix_diag-y		:= diag.o
-- 
1.5.5.6
