From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 4/5] s390: iucv Kconfig help description changes
Date: Mon, 8 Jan 2007 17:30:33 +0100
Message-ID: <20070108163033.GD21639@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55771 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161352AbXAHQbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 11:31:25 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l08GVLEf030089
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 11:31:21 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l08GVLbS551948
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:21 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l08GVL6C010749
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:21 -0700
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 4/5] s390: iucv Kconfig help description changes

From: Ursula Braun <braunu@de.ibm.com>
        remove text from help description which does not
	apply anymore for 2.6 kernel series.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/Kconfig |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/Kconfig b/drivers/s390/net/Kconfig
index 1a93fa6..5262515 100644
--- a/drivers/s390/net/Kconfig
+++ b/drivers/s390/net/Kconfig
@@ -27,10 +27,7 @@ config IUCV
 	help
 	  Select this option if you want to use inter-user communication
 	  under VM or VIF. If unsure, say "Y" to enable a fast communication
-	  link between VM guests. At boot time the user ID of the guest needs
-	  to be passed to the kernel. Note that both kernels need to be
-	  compiled with this option and both need to be booted with the user ID
-	  of the other VM guest.
+	  link between VM guests.
 
 config NETIUCV
 	tristate "IUCV network device support (VM only)"
-- 
1.4.2.3

