From: Meelis Roos <mroos@ut.ee>
Subject: [PATCH] Add Fujitsu 1000base-SX PCI ID to tg3
Date: Wed, 25 May 2011 18:43:47 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1105251836550.16961@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:36447 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757865Ab1EYQEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2011 12:04:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the PCI ID of Fujitsu 1000base-SX NIC to tg3 driver. 
Tested to detect the card, MAC and serdes, not tested with link at the 
moment since I have no fiber switch here. I did not add new constants to 
the pci_ids.h header file since these constants are used only here.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7a5daef..7b1901e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -273,6 +273,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1003)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC9100)},
 	{PCI_DEVICE(PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_TIGON3)},
+	{PCI_DEVICE(0x10cf, 0x11a2)}, /* Fujitsu 1000base-SX with BCM5703SKHB */
 	{}
 };
 

-- 
Meelis Roos (mroos@linux.ee)
