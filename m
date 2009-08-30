From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 1/2 next] sky2: Fix B0_Y2LED to match vendor driver
Date: Sun, 30 Aug 2009 12:58:27 +0900
Message-ID: <4A99F8E3.2020904@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rene Mayrhofer <rene@mayrhofer.eu.org>,
	Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f186.google.com ([209.85.211.186]:61970 "EHLO
	mail-yw0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbZH3ECW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 00:02:22 -0400
Received: by ywh16 with SMTP id 16so3100132ywh.19
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 21:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

B0_LED is 0x0006 in the vendor driver, but was 0x0005 in sky2.
B0_LED is right next to B0_POWER_CTRL, so this is possibly
accounts for the device being accidently powered down as
reported by Rene Mayrhofer.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 73c9547..a1f3d5f 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -155,7 +155,7 @@ enum pci_cfg_reg1 {
 enum csr_regs {
 	B0_RAP		= 0x0000,
 	B0_CTST		= 0x0004,
-	B0_Y2LED	= 0x0005,
+	B0_Y2LED	= 0x0006,
 	B0_POWER_CTRL	= 0x0007,
 	B0_ISRC		= 0x0008,
 	B0_IMSK		= 0x000c,
-- 
1.5.6.5


