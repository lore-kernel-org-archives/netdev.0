From: <pcnet32@verizon.net>
Subject: [PATCH] pcnet32 NAPI no longer experimental
Date: Fri, 16 Feb 2007 10:09:57 -0600 (CST)
Message-ID: <25626181.1116241171642197159.JavaMail.root@vms226.mailsrvcs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:51723 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945969AbXBPQKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 11:10:05 -0500
Received: from vms226.mailsrvcs.net ([192.168.1.1])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JDK00KYQCWLIHW7@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 16 Feb 2007 10:09:57 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the experimental tag for the pcnet32 NAPI implementation.

Signed-off-by:  Don Fry <pcnet32@verizon.net>

--- linux-2.6.20-git8/drivers/net/Kconfig.orig	2007-02-13 09:55:36.000000000 -0800
+++ linux-2.6.20-git8/drivers/net/Kconfig	2007-02-13 10:00:54.000000000 -0800
@@ -1284,8 +1284,8 @@ config PCNET32
 	  will be called pcnet32.
 
 config PCNET32_NAPI
-	bool "Use RX polling (NAPI) (EXPERIMENTAL)"
-	depends on PCNET32 && EXPERIMENTAL
+	bool "Use RX polling (NAPI)"
+	depends on PCNET32
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
 	  when the driver is receiving lots of packets from the card. It is

