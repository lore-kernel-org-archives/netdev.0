From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 3/5] sc92031: inline SC92031_DESCRIPTION
Date: Mon, 12 Jan 2009 21:21:49 -0200
Message-ID: <1231802511-14825-3-git-send-email-cesarb@cesarb.net>
References: <496BD04F.2050502@cesarb.net>
Cc: netdev@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-01.mandic.com.br ([200.225.81.132]:53913 "EHLO
	smtp-01.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631AbZALX2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 18:28:33 -0500
In-Reply-To: <496BD04F.2050502@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SC92031_DESCRIPTION is only used in one place.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/sc92031.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 07bd13b..ac4ccd4 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -36,7 +36,6 @@
 #define PCI_DEVICE_ID_SILAN_8139D	0x8139
 
 #define SC92031_NAME "sc92031"
-#define SC92031_DESCRIPTION "Silan SC92031 PCI Fast Ethernet Adapter driver"
 
 /* BAR 0 is MMIO, BAR 1 is PIO */
 #ifndef SC92031_USE_BAR
@@ -1622,4 +1621,4 @@ module_exit(sc92031_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Cesar Eduardo Barros <cesarb@cesarb.net>");
-MODULE_DESCRIPTION(SC92031_DESCRIPTION);
+MODULE_DESCRIPTION("Silan SC92031 PCI Fast Ethernet Adapter driver");
-- 
1.6.1.dirty

