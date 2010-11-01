From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 1/2] solos: Add 'Firmware' attribute for Traverse overall
 firmware version
Date: Mon, 01 Nov 2010 16:34:29 -0400
Message-ID: <1288643669.5977.21.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:34535 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673Ab0KAUed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 16:34:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing 'FirmwareVersion' attribute only covers the DSP firmware as
provided by Conexant; not the overall version of the device firmware. We
do want to be able to see the full version number too.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-attrlist.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-attrlist.c b/drivers/atm/solos-attrlist.c
index 1a9332e..9a676ee 100644
--- a/drivers/atm/solos-attrlist.c
+++ b/drivers/atm/solos-attrlist.c
@@ -1,6 +1,7 @@
 SOLOS_ATTR_RO(DriverVersion)
 SOLOS_ATTR_RO(APIVersion)
 SOLOS_ATTR_RO(FirmwareVersion)
+SOLOS_ATTR_RO(Version)
 // SOLOS_ATTR_RO(DspVersion)
 // SOLOS_ATTR_RO(CommonHandshake)
 SOLOS_ATTR_RO(Connected)
-- 
1.7.3.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

