From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: [PATCH 1/2] net: enable smsc911x on MIPS
Date: Tue, 13 Oct 2009 19:25:48 +0200
Message-ID: <1255454749-26895-1-git-send-email-manuel.lauss@gmail.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	Manuel Lauss <manuel.lauss@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:55930 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760117AbZJMR0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:26:32 -0400
Received: by ewy4 with SMTP id 4so3602177ewy.37
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 10:25:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>
---
 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7127760..d9772af 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1001,7 +1001,7 @@ config SMC911X
 
 config SMSC911X
 	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
-	depends on ARM || SUPERH || BLACKFIN
+	depends on ARM || SUPERH || BLACKFIN || MIPS
 	select CRC32
 	select MII
 	select PHYLIB
-- 
1.6.5.rc2

