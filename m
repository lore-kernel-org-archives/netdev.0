From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6.25 1/7][ATM]: atm is no longer experimental
Date: Sat, 29 Dec 2007 20:06:03 -0500
Message-ID: <200712300106.lBU16311003517@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:59180 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbXL3BGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 20:06:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f57512af6142cf14bd15012c4c627f9ebef0582a
Author: Robert P. J. Day <rpjday@mindspring.com>
Date:   Fri Oct 26 07:27:07 2007 -0400

    [ATM]: atm is no longer experimental
    
    From: Robert P. J. Day <rpjday@mindspring.com>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/Kconfig b/net/atm/Kconfig
index 21ff276..754ea10 100644
--- a/net/atm/Kconfig
+++ b/net/atm/Kconfig
@@ -1,10 +1,9 @@
 #
-# Asynchronous Transfer Mode (ATM) (EXPERIMENTAL)
+# Asynchronous Transfer Mode (ATM)
 #
 
 config ATM
-	tristate "Asynchronous Transfer Mode (ATM) (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	tristate "Asynchronous Transfer Mode (ATM)"
 	---help---
 	  ATM is a high-speed networking technology for Local Area Networks
 	  and Wide Area Networks.  It uses a fixed packet size and is
@@ -20,7 +19,7 @@ config ATM
 	  further details.
 
 config ATM_CLIP
-	tristate "Classical IP over ATM (EXPERIMENTAL)"
+	tristate "Classical IP over ATM"
 	depends on ATM && INET
 	help
 	  Classical IP over ATM for PVCs and SVCs, supporting InARP and
@@ -29,7 +28,7 @@ config ATM_CLIP
 	  (LANE)" below.
 
 config ATM_CLIP_NO_ICMP
-	bool "Do NOT send ICMP if no neighbour (EXPERIMENTAL)"
+	bool "Do NOT send ICMP if no neighbour"
 	depends on ATM_CLIP
 	help
 	  Normally, an "ICMP host unreachable" message is sent if a neighbour
@@ -39,7 +38,7 @@ config ATM_CLIP_NO_ICMP
 	  such neighbours are silently discarded instead.
 
 config ATM_LANE
-	tristate "LAN Emulation (LANE) support (EXPERIMENTAL)"
+	tristate "LAN Emulation (LANE) support"
 	depends on ATM
 	help
 	  LAN Emulation emulates services of existing LANs across an ATM
@@ -48,7 +47,7 @@ config ATM_LANE
 	  ELAN and Ethernet segments. You need LANE if you want to try MPOA.
 
 config ATM_MPOA
-	tristate "Multi-Protocol Over ATM (MPOA) support (EXPERIMENTAL)"
+	tristate "Multi-Protocol Over ATM (MPOA) support"
 	depends on ATM && INET && ATM_LANE!=n
 	help
 	  Multi-Protocol Over ATM allows ATM edge devices such as routers,
