From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: [PATCH] acenic: SET_NETDEV_DEV is always there these days
Date: Wed, 6 Jun 2007 16:04:39 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0706061601420.25857@pademelon.sonytel.be>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, trivial@kernel.org,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jes Sorensen <jes@trained-monkey.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:33933 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751113AbXFFOEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 10:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

acenic: SET_NETDEV_DEV is always there these days

Signed-off-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

---
Disclaimer: not tested at all

--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -159,10 +159,6 @@ static struct pci_device_id acenic_pci_t
 };
 MODULE_DEVICE_TABLE(pci, acenic_pci_tbl);
 
-#ifndef SET_NETDEV_DEV
-#define SET_NETDEV_DEV(net, pdev)	do{} while(0)
-#endif
-
 #define ace_sync_irq(irq)	synchronize_irq(irq)
 
 #ifndef offset_in_page

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- Sony Network and Software Technology Center Europe (NSCE)
Geert.Uytterhoeven@sonycom.com ------- The Corporate Village, Da Vincilaan 7-D1
Voice +32-2-7008453 Fax +32-2-7008622 ---------------- B-1935 Zaventem, Belgium
