From: Magnus Damm <magnus.damm@gmail.com>
Subject: ax88796: add superh to kconfig dependencies
Date: Thu, 08 Nov 2007 16:31:05 +0900
Message-ID: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	ben-linux@fluff.org, akpm@linux-foundation.org, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:4497 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbXKHHcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 02:32:14 -0500
Received: by wa-out-1112.google.com with SMTP id v27so102404wah
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2007 23:32:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ax88796: add superh to kconfig dependencies

This patch adds sh architecture support to the ax88796 kconfig.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 This patch was posted about a month ago but never picked up:
 http://www.mail-archive.com/netdev@vger.kernel.org/msg50018.html
 The rest of the sh support is already included in rc1. Please apply.

 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 0002/drivers/net/Kconfig
+++ work/drivers/net/Kconfig	2007-10-09 19:37:27.000000000 +0900
@@ -218,7 +218,7 @@ source "drivers/net/arm/Kconfig"
 
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS
+	depends on ARM || MIPS || SUPERH
 	select CRC32
 	select MII
 	help
