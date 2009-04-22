From: "Karsten Keil" <Karsten-Keil@t-online.de>
Subject: [PATCH 3/3] Add reference to CAPI 2.0 standard
Date: Wed, 22 Apr 2009 16:31:48 +0200
Message-ID: <f094d823a0fc52e010f99aec720c9144d454c2fa.1240410708.git.keil@b1-systems.de>
References: <cover.1240410708.git.keil@b1-systems.de>
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, tilman@imap.cc,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout01.t-online.de ([194.25.134.80]:52567 "EHLO
	mailout01.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbZDVQwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 12:52:53 -0400
In-Reply-To: <cover.1240410708.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the entry about CAPI 2.0 to the beginning and add a URL.
Incorporate changes suggested by Randy Dunlap, thanks for proofreading.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 Documentation/isdn/INTERFACE.CAPI |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
index 8947ffc..4d802ee 100644
--- a/Documentation/isdn/INTERFACE.CAPI
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -3,6 +3,11 @@ Kernel CAPI Interface to Hardware Drivers
 
 1. Overview
 
+From the CAPI 2.0 spezification:
+COMMON-ISDN-API (CAPI) is an application programming interface standard used
+to access ISDN equipment connected to basic rate interfaces (BRI) and primary
+rate interfaces (PRI).
+
 Kernel CAPI operates as a dispatching layer between CAPI applications and CAPI
 hardware drivers. Hardware drivers register ISDN devices (controllers, in CAPI
 lingo) with Kernel CAPI to indicate their readiness to provide their service
@@ -12,6 +17,9 @@ application registration to an available device, forwarding it to the
 corresponding hardware driver. Kernel CAPI then forwards CAPI messages in both
 directions between the application and the hardware driver.
 
+Format and semantics of CAPI messages are specified in the CAPI 2.0 standard.
+This standard is freely available from http://www.capi.org.
+
 
 2. Driver and Device Registration
 
@@ -53,12 +61,10 @@ open() operation on regular files or character devices.
 After a successful return from register_appl(), CAPI messages from the
 application may be passed to the driver for the device via calls to the
 send_message() callback function. The CAPI message to send is stored in the
-data portion of a skb. Conversely, the driver may call Kernel CAPI's
+data portion of an skb. Conversely, the driver may call Kernel CAPI's
 capi_ctr_handle_message() function to pass a received CAPI message to Kernel
 CAPI for forwarding to an application, specifying its ApplID.
 
-Format and semantics of CAPI messages are specified in the CAPI 2.0 standard.
-
 Deregistration requests (CAPI operation CAPI_RELEASE) from applications are
 forwarded as calls to the release_appl() callback function, passing the same
 ApplID as with register_appl(). After return from release_appl(), no CAPI
@@ -75,9 +81,9 @@ the following non-private fields, all to be set by the driver before calling
 register_capi_driver():
 
 char name[32]
-	the name of the driver, as a zero terminated ASCII string
+	the name of the driver, as a zero-terminated ASCII string
 char revision[32]
-	the revision number of the driver, as a zero terminated ASCII string
+	the revision number of the driver, as a zero-terminated ASCII string
 int (*add_card)(struct capi_driver *driver, capicardparams *data)
 	a callback function pointer (may be NULL)
 
@@ -100,10 +106,10 @@ void *driverdata
 	an opaque pointer to driver specific data, not touched by Kernel CAPI
 
 char name[32]
-	the name of the controller, as a zero terminated ASCII string
+	the name of the controller, as a zero-terminated ASCII string
 
 char *driver_name
-	the name of the driver, as a zero terminated ASCII string
+	the name of the driver, as a zero-terminated ASCII string
 
 int (*load_firmware)(struct capi_ctr *ctrlr, capiloaddata *ldata)
 	(optional) pointer to a callback function for sending firmware and
-- 
1.6.0.2

