From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] switchdev: select INET in Kconfig
Date: Wed, 11 Mar 2015 10:49:12 +0100
Message-ID: <1426067352-9327-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, f.fainelli@gmail.com, sfeldma@gmail.com,
	rdunlap@infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:43326 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbbCKJtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 05:49:18 -0400
Received: by wevl61 with SMTP id l61so7808458wev.10
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 02:49:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This would fix randconfig compile error:
net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
(.text+0xf7811): undefined reference to `fib_flush_external'

Also it fixes following warning:
warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)

Suggested-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/switchdev/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/switchdev/Kconfig b/net/switchdev/Kconfig
index 86a47e1..3487940 100644
--- a/net/switchdev/Kconfig
+++ b/net/switchdev/Kconfig
@@ -4,7 +4,7 @@
 
 config NET_SWITCHDEV
 	bool "Switch (and switch-ish) device support (EXPERIMENTAL)"
-	depends on INET
+	select INET
 	---help---
 	  This module provides glue between core networking code and device
 	  drivers in order to support hardware switch chips in very generic
-- 
1.9.3
