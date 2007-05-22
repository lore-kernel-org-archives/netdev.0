From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 4/4] forcedeth: version bump
Date: Mon, 21 May 2007 20:23:17 -0400
Message-ID: <465237F5.2010208@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090808070408040401020603"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:14888 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760408AbXEVDHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 23:07:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090808070408040401020603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch bumps up the version.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090808070408040401020603
Content-Type: text/plain;
 name="patch-forcedeth-version"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-version"

--- old/drivers/net/forcedeth.c	2007-05-21 20:09:03.000000000 -0400
+++ new/drivers/net/forcedeth.c	2007-05-21 20:10:32.000000000 -0400
@@ -112,6 +112,7 @@
  *	0.58: 30 Oct 2006: Added support for sideband management unit.
  *	0.59: 30 Oct 2006: Added support for recoverable error.
  *	0.60: 20 Jan 2007: Code optimizations for rings, rx & tx data paths, and stats.
+ *	0.61: 21 May 2007: Fix power management code, cpu mask, and added vitesse phy.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -128,7 +129,7 @@
 #else
 #define DRIVERNAPI
 #endif
-#define FORCEDETH_VERSION		"0.60"
+#define FORCEDETH_VERSION		"0.61"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -5634,6 +5635,7 @@
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(FORCEDETH_VERSION);
 
 MODULE_DEVICE_TABLE(pci, pci_tbl);
 

--------------090808070408040401020603--
