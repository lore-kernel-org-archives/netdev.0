From: Martin Michlmayr <tbm@cyrius.com>
Subject: [PATCH] mv643xx_eth: Define module alias for platform device
Date: Sat, 16 Feb 2008 18:16:54 +0100
Message-ID: <20080216171654.GA2835@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:3942 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755641AbYBPRmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2008 12:42:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv643xx_eth driver can be loaded as a platform device, as is done by
various Orion (ARM) based devices.  The driver needs to define a module
alias for the platform driver so udev will load it automatically.
Tested with Debian on a QNAP TS-209.

Signed-off-by: Martin Michlmayr <tbm@cyrius.com>

--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2104,6 +2104,7 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
 		" and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
+MODULE_ALIAS("platform:mv643xx_eth");
 
 /*
  * The second part is the low level driver of the gigE ethernet ports.

-- 
Martin Michlmayr
http://www.cyrius.com/
