From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] starfire: use PCI_VDEVICE
Date: Sat, 28 Aug 2010 14:08:36 +0900
Message-ID: <1282972116-9941-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Ion Badulescu <ionut@badula.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:45333 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab0H1FP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 01:15:28 -0400
Received: by pvg2 with SMTP id 2so1346294pvg.19
        for <netdev@vger.kernel.org>; Fri, 27 Aug 2010 22:15:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Ion Badulescu <ionut@badula.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/starfire.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index a42b687..26c3634 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -302,7 +302,7 @@ enum chipset {
 };
 
 static DEFINE_PCI_DEVICE_TABLE(starfire_pci_tbl) = {
-	{ 0x9004, 0x6915, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_6915 },
+	{ PCI_VDEVICE(ADAPTEC, 0x6915), CH_6915 },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, starfire_pci_tbl);
-- 
1.6.0.6

