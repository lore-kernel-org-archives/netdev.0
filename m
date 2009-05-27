From: Greg KH <greg@kroah.com>
Subject: [PATCH] ath1e: add new device id for asus hardware
Date: Tue, 26 May 2009 23:02:49 -0700
Message-ID: <20090527060249.GA19080@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Neil Horman <nhorman@tuxdriver.com>, Gary Lin <glin@novell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:49736 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755763AbZE0GHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 02:07:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@suse.de>

Gary Lin reports that a new device id needs to be added to the atl1e in
order to get some new Asus hardware to work properly.

Cc: Gary Lin <glin@novell.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index fb57b75..1342418 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -37,6 +37,7 @@ char atl1e_driver_version[] = DRV_VERSION;
  */
 static struct pci_device_id atl1e_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1E)},
+	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, 0x1066)},
 	/* required last entry */
 	{ 0 }
 };
