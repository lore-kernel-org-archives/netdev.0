From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make UNIX a bool
Date: Sat, 25 Feb 2006 17:01:50 +0100
Message-ID: <20060225160150.GX3674@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161018AbWBYQBw@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CONFIG_UNIX=m doesn't make much sense.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 20 Feb 2006

--- linux-2.6.16-rc4-mm1-full/net/unix/Kconfig.old	2006-02-20 14:40:19.000000000 +0100
+++ linux-2.6.16-rc4-mm1-full/net/unix/Kconfig	2006-02-20 14:40:27.000000000 +0100
@@ -3,7 +3,7 @@
 #
 
 config UNIX
-	tristate "Unix domain sockets"
+	bool "Unix domain sockets"
 	---help---
 	  If you say Y here, you will include support for Unix domain sockets;
 	  sockets are the standard Unix mechanism for establishing and
