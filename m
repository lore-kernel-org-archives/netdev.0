From: Vincent <vincent.stehle@laposte.net>
Subject: [PATCH] smsc911x: Add MODULE_ALIAS()
Date: Fri, 24 Sep 2010 00:08:05 +0200
Message-ID: <4C9BCFC5.9090808@bergerie>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050100010002060606010102"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:53491 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350Ab0IWWIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 18:08:13 -0400
Received: from romuald.bergerie (unknown [82.228.252.113])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 3BDA44C8068
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 00:08:07 +0200 (CEST)
Received: from [192.168.124.7] (clopinette.bergerie [192.168.124.7])
	by romuald.bergerie (Postfix) with ESMTPS id 9EAE5120104
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 00:08:05 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050100010002060606010102
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit


Hi,

The smsc911x ethernet driver is lacking a module alias. This does
prevent auto-loading of the driver.

The attached patch fixes this. Please apply.

Best regards,

-- 
Vincent StehlÈ

--------------050100010002060606010102
Content-Type: text/x-patch;
 name="0001-smsc911x-Add-MODULE_ALIAS.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
 filename="0001-smsc911x-Add-MODULE_ALIAS.patch"

>From 54d0c88812d9707fc721ab4b6a2f669a44f873d7 Mon Sep 17 00:00:00 2001
From: =?utf-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>
Date: Thu, 23 Sep 2010 23:19:14 +0200
Subject: [PATCH] smsc911x: Add MODULE_ALIAS()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

This enables auto loading for the smsc911x ethernet driver.

Signed-off-by: Vincent Stehl√© <vincent.stehle@laposte.net>
---
 drivers/net/smsc911x.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 7a7b01a..1cf5b8a 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -58,6 +58,7 @@
 
 MODULE_LICENSE("GPL");
 MODULE_VERSION(SMSC_DRV_VERSION);
+MODULE_ALIAS("platform:smsc911x");
 
 #if USE_DEBUG > 0
 static int debug = 16;
-- 
1.5.6.5


--------------050100010002060606010102--
