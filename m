From: dlezcano@fr.ibm.com
Subject: [patch 1/1] Fix some Kconfigs on net-2.6.24
Date: Wed, 05 Sep 2007 19:07:30 +0200
Message-ID: <20070905170853.740970916@dyn-9-101-17-26.toulouse-stg.fr.ibm.com>
References: <20070905170729.127852231@dyn-9-101-17-26.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:29662 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754467AbXIERKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 13:10:13 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l85HA4WX185692
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2007 17:10:04 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l85HA4dV3006640
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2007 18:10:04 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l85H9m7d020619
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2007 18:09:48 +0100
Content-Disposition: inline; filename=net-2.6.24-fix-Kconfig.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

Three fixes for Kconfigs.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

---
 drivers/input/misc/Kconfig |    2 +-
 drivers/leds/Kconfig       |    2 +-
 drivers/telephony/Kconfig  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6.24/drivers/input/misc/Kconfig
===================================================================
--- net-2.6.24.orig/drivers/input/misc/Kconfig
+++ net-2.6.24/drivers/input/misc/Kconfig
@@ -152,7 +152,7 @@
 
 config INPUT_YEALINK
 	tristate "Yealink usb-p1k voip phone"
-	depends EXPERIMENTAL
+	depends on EXPERIMENTAL
 	depends on USB_ARCH_HAS_HCD
 	select USB
 	help
Index: net-2.6.24/drivers/leds/Kconfig
===================================================================
--- net-2.6.24.orig/drivers/leds/Kconfig
+++ net-2.6.24/drivers/leds/Kconfig
@@ -83,7 +83,7 @@
 
 config LEDS_H1940
 	tristate "LED Support for iPAQ H1940 device"
-	depends LEDS_CLASS && ARCH_H1940
+	depends on LEDS_CLASS && ARCH_H1940
 	help
 	  This option enables support for the LEDs on the h1940.
 
Index: net-2.6.24/drivers/telephony/Kconfig
===================================================================
--- net-2.6.24.orig/drivers/telephony/Kconfig
+++ net-2.6.24/drivers/telephony/Kconfig
@@ -19,7 +19,7 @@
 
 config PHONE_IXJ
 	tristate "QuickNet Internet LineJack/PhoneJack support"
-	depends ISA || PCI
+	depends on ISA || PCI
 	---help---
 	  Say M if you have a telephony card manufactured by Quicknet
 	  Technologies, Inc.  These include the Internet PhoneJACK and

-- 
