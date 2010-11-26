From: Shannon Wynter <kernel.org.alias@fremnet.net>
Subject: skge.c patch to limit DMA for ASUS A8N-SLI Premium board
Date: Fri, 26 Nov 2010 10:06:41 +1000
Message-ID: <4CEEFA11.6040205@fremnet.net>
Reply-To: Shannon Wynter <kernel.org.alias@fremnet.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040904000402030907050105"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:43996 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752754Ab0KZALY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 19:11:24 -0500
Received: from priya.2y.net (localhost [127.0.0.1])
	by priya.2y.net (Postfix) with ESMTP id CB4661D8398
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 10:06:16 +1000 (EST)
Received: from [10.0.1.117] (eth2026.qld.adsl.internode.on.net [150.101.176.237])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: freman from domain fremnet.net)
	by priya.2y.net (Postfix) with ESMTPSA id 9511F1D8397
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 10:06:16 +1000 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040904000402030907050105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi

I would like to contribute a patch to add ASUS A8N-SLI Premium to the 
list of boards that require the quirk to limit DMA to 32bit in the 
skge.c module.

It took 2 hours of fiddling with my machine last night to get the 
network card working - the lights were on but no-one was at home.

I never would have found it if not for the original bug listed on redhat 
for the Gigabyte motherboard.

Kind regards

Shannon.

--------------040904000402030907050105
Content-Type: text/x-patch;
 name="skge-quirk-for-asus-a8n-sli-DMA.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="skge-quirk-for-asus-a8n-sli-DMA.patch"

diff -uNr linux-2.6.37-rc3.old/drivers/net/skge.c linux-2.6.37-rc3.new//drivers/net/skge.c
--- linux-2.6.37-rc3.old/drivers/net/skge.c	2010-11-26 08:35:21.000000000 +1000
+++ linux-2.6.37-rc3.new//drivers/net/skge.c	2010-11-26 08:58:52.000000000 +1000
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
 

--------------040904000402030907050105--
