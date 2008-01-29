From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] sis190: silence section type conflict
Date: Tue, 29 Jan 2008 23:36:09 +0100
Message-ID: <20080129223609.GE15445@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Maximilian Attems <max@stro.at>,
	Andrew Morton <akpm@linux-foundation.org>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44692 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752710AbYA2Wyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 17:54:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC [M]  drivers/net/sis190.o
  drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
  make[5]: *** [drivers/net/sis190.o] Error 1

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Reported-by: Maximilian Attems <max@stro.at>

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b570402..2e9e88b 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -326,7 +326,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
+static struct pci_device_id sis190_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },
