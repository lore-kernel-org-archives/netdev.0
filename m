From: Greg KH <gregkh@linuxfoundation.org>
Subject: [PATCH v2] tg3: add device id of Apple Thunderbolt Ethernet device
Date: Thu, 12 Jul 2012 16:26:22 -0700
Message-ID: <20120712232622.GC26823@kroah.com>
References: <20120712202131.GA26436@kroah.com>
 <20120712205607.GA27999@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:38305 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161988Ab2GLX00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 19:26:26 -0400
Received: by ghrr11 with SMTP id r11so3035214ghr.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 16:26:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120712205607.GA27999@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Apple Thunderbolt ethernet device is already listed in the driver,
but not hooked up in the MODULE_DEVICE_TABLE().  This fixes that and
allows it to work properly.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e47ff8b..3721833 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -298,6 +298,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57762)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
