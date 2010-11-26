From: Shannon Wynter <kernel.org.alias@fremnet.net>
Subject: [PATCH] skge: 32bit DMA for ASUS A8N-SLI Premium
Date: Fri, 26 Nov 2010 23:51:46 +1000
Message-ID: <4CEFBB72.2060400@fremnet.net>
Reply-To: Shannon Wynter <kernel.org.alias@fremnet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:9656 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752688Ab0KZNwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 08:52:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ASUS A8N-SLI Premium to the list of boards that require the quirk to
limit DMA to 32bit in the skge.c module.

Signed-off-by: Shannon Wynter <kernel.org.alias@fremnet.net>
---
--- a/drivers/net/skge.c	2010-11-26 08:35:21.000000000 +1000
+++ b/drivers/net/skge.c	2010-11-26 08:58:52.000000000 +1000
@@ -4158,6 +4158,13 @@
  			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
  		},
  	},
+	{
+		.ident = "ASUSTeK A8N-SLI Premium",
+		.matches = {
+			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
+			DMI_MATCH(DMI_BOARD_NAME, "A8N-SLI Premium"),
+		},
+	},
  	{}
  };


