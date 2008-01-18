From: Olaf Hering <olaf@aepfle.de>
Subject: [PATCH] add modalias info to mv643xx_eth.ko
Date: Fri, 18 Jan 2008 10:38:05 +0100
Message-ID: <20080118093805.GA28004@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dale Farnsworth <dale@farnsworth.org>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50162 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393AbYARJhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 04:37:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv643xx_eth has an platform modalias file in sysfs.
But the module itself has no alias: line. Autoloading fails
without the alias info in the module.

Signed-off-by: Olaf Hering <olaf@aepfle.de>

---
 drivers/net/mv643xx_eth.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2099,6 +2099,7 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
 		" and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
+MODULE_ALIAS("platform:mv643xx_eth");
 
 /*
  * The second part is the low level driver of the gigE ethernet ports.
