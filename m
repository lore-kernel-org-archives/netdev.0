From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v3 5/6] ARM: davinci: da850: add OF_DEV_AUXDATA entry for eth0.
Date: Sun, 23 Jun 2013 20:30:06 +0530
Message-ID: <1371999607-6483-6-git-send-email-prabhakar.csengg@gmail.com>
References: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Heiko Schocher <hs@denx.de>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	devicetree-discuss@lists.ozlabs.org, Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:50995 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab3FWPAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 11:00:54 -0400
In-Reply-To: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

Add OF_DEV_AUXDATA for eth0  driver in da850 board dt
file to use emac clock.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 Changes for V2: none
 Changes for V3: none

 arch/arm/mach-davinci/da8xx-dt.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/mach-davinci/da8xx-dt.c b/arch/arm/mach-davinci/da8xx-dt.c
index f33f767..1eb3fa8 100644
--- a/arch/arm/mach-davinci/da8xx-dt.c
+++ b/arch/arm/mach-davinci/da8xx-dt.c
@@ -48,6 +48,9 @@ static struct of_dev_auxdata da850_auxdata_lookup[] __initdata = {
 	OF_DEV_AUXDATA("ti,da850-ecap", 0x01f08000, "ecap", NULL),
 	OF_DEV_AUXDATA("ti,da830-spi", 0x01f0e000, "spi_davinci.1", NULL),
 	OF_DEV_AUXDATA("ti,davinci_mdio", 0x01e24000, "davinci_mdio.0", NULL),
+	OF_DEV_AUXDATA("ti,davinci-dm6467-emac", 0x01e20000, "davinci_emac.1",
+		       NULL),
+
 	{}
 };
 
-- 
1.7.9.5
