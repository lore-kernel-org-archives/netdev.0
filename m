From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: [PATCH v5 2/2] ARM: davinci: da850: add OF_DEV_AUXDATA entry for davinci_emac
Date: Fri, 16 Aug 2013 19:41:02 +0530
Message-ID: <1376662262-21795-3-git-send-email-prabhakar.csengg@gmail.com>
References: <1376662262-21795-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:44589 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab3HPOMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 10:12:47 -0400
In-Reply-To: <1376662262-21795-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

Add OF_DEV_AUXDATA for ethernet davinci_emac driver in da850 board dt
file to use emac clock.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 arch/arm/mach-davinci/da8xx-dt.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/mach-davinci/da8xx-dt.c b/arch/arm/mach-davinci/da8xx-dt.c
index d172563..d2bc574 100644
--- a/arch/arm/mach-davinci/da8xx-dt.c
+++ b/arch/arm/mach-davinci/da8xx-dt.c
@@ -44,6 +44,8 @@ static struct of_dev_auxdata da850_auxdata_lookup[] __initdata = {
 	OF_DEV_AUXDATA("ns16550a", 0x01d0c000, "serial8250.1", NULL),
 	OF_DEV_AUXDATA("ns16550a", 0x01d0d000, "serial8250.2", NULL),
 	OF_DEV_AUXDATA("ti,davinci_mdio", 0x01e24000, "davinci_mdio.0", NULL),
+	OF_DEV_AUXDATA("ti,davinci-dm6467-emac", 0x01e20000, "davinci_emac.1",
+		       NULL),
 	{}
 };
 
-- 
1.7.9.5
