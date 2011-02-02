From: Chuck Ebbert <cebbert@redhat.com>
Subject: [Patch] atl1c: Add missing PCI device ID
Date: Wed, 2 Feb 2011 10:59:02 -0500
Message-ID: <20110202105902.3c0d2f9e@katamari>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jie Yang <Jie.Yang@atheros.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754542Ab1BBQBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 11:01:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit 8f574b35f22fbb9b5e5f1d11ad6b55b6f35f4533 added support for a new
adapter but failed to add it to the PCI device table.

Signed-Off-By: Chuck Ebbert <cebbert@redhat.com>

--- vanilla-2.6.38-rc3.orig/drivers/net/atl1c/atl1c_main.c
+++ vanilla-2.6.38-rc3/drivers/net/atl1c/atl1c_main.c
@@ -48,6 +48,7 @@ static DEFINE_PCI_DEVICE_TABLE(atl1c_pci
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATHEROS_L2C_B)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATHEROS_L2C_B2)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATHEROS_L1D)},
+	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATHEROS_L1D_2_0)},
 	/* required last entry */
 	{ 0 }
 };
