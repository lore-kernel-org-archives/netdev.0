From: Chuck Ebbert <cebbert@redhat.com>
Subject: [PATCH] CAN: softing driver depends on IOMEM
Date: Mon, 31 Jan 2011 10:44:07 -0500
Message-ID: <20110131104407.25a54119@katamari>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756089Ab1AaPrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:47:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAN: softing driver depends on IOMEM

Without this dependency the softing driver will be buildable on s390,
where it fails.

Signed-Off-By: Chuck Ebbert <cebbert@redhat.com>

--- a/drivers/net/can/softing/Kconfig
+++ b/drivers/net/can/softing/Kconfig
@@ -1,6 +1,6 @@
 config CAN_SOFTING
 	tristate "Softing Gmbh CAN generic support"
-	depends on CAN_DEV
+	depends on CAN_DEV && HAS_IOMEM
 	---help---
 	  Support for CAN cards from Softing Gmbh & some cards
 	  from Vector Gmbh.
