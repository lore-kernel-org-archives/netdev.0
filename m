From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] drivers: isdn: Fix dependency for ISDN_PPP
Date: Tue, 10 Jan 2012 09:54:23 -0200
Message-ID: <1326196463-8727-1-git-send-email-festevam@gmail.com>
Cc: isdn@linux-pingi.de, Fabio Estevam <festevam@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42938 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735Ab2AJLyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 06:54:35 -0500
Received: by yenm10 with SMTP id m10so669300yen.19
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 03:54:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following build warning:

warning: (ISDN_PPP) selects SLHC which has unmet direct dependencies (NETDEVICES)

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/isdn/i4l/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/i4l/Kconfig b/drivers/isdn/i4l/Kconfig
index 9c6650e..2302fbe 100644
--- a/drivers/isdn/i4l/Kconfig
+++ b/drivers/isdn/i4l/Kconfig
@@ -6,7 +6,7 @@ if ISDN_I4L
 
 config ISDN_PPP
 	bool "Support synchronous PPP"
-	depends on INET
+	depends on INET && NETDEVICES
 	select SLHC
 	help
 	  Over digital connections such as ISDN, there is no need to
-- 
1.7.1
