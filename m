From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 7/7] be2net: remove ASIC generation number from Kconfig
Date: Tue, 9 Feb 2010 17:09:05 +0530
Message-ID: <20100209113855.GA10593@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:51824 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab0BILjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:39:12 -0500
Received: by iwn12 with SMTP id 12so8480922iwn.26
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 03:39:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the driver is supporting multiple generations of the ASIC
don't mention any ASIC generation number.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/Kconfig b/drivers/net/benet/Kconfig
index fdb6e81..1a41a49 100644
--- a/drivers/net/benet/Kconfig
+++ b/drivers/net/benet/Kconfig
@@ -1,6 +1,6 @@
 config BE2NET
-	tristate "ServerEngines' 10Gbps NIC - BladeEngine 2"
+	tristate "ServerEngines' 10Gbps NIC - BladeEngine"
 	depends on PCI && INET
 	help
 	This driver implements the NIC functionality for ServerEngines'
-	10Gbps network adapter - BladeEngine 2.
+	10Gbps network adapter - BladeEngine.
-- 
1.6.3.3

