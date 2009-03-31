From: Alan Carvalho de Assis <acassis@gmail.com>
Subject: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Tue, 31 Mar 2009 10:36:39 -0300
Message-ID: <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com>
	 <37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com>
	 <20090330143155.GA20101@pengutronix.de>
	 <37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com>
	 <20090331075951.GF22913@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sascha Hauer <s.hauer@pengutronix.de>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:35768 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573AbZCaNgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 09:36:42 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2432262ywb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 06:36:40 -0700 (PDT)
In-Reply-To: <20090331075951.GF22913@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a fix to get cs89x0 network driver working on i.MX31ADS

Signed-off-by: Alan Carvalho de Assis <acassis@gmail.com>
---
 drivers/net/cs89x0.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index ff64976..8ccc8f7 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -190,6 +190,7 @@ static unsigned int cs8900_irq_map[] =
{IRQ_IXDP2X01_CS8900, 0, 0, 0};
 static unsigned int netcard_portlist[] __used __initdata =
{CIRRUS_DEFAULT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {CIRRUS_DEFAULT_IRQ, 0, 0, 0};
 #elif defined(CONFIG_MACH_MX31ADS)
+#include <mach/hardware.h>
 #include <mach/board-mx31ads.h>
 static unsigned int netcard_portlist[] __used __initdata = {
 	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
-- 
1.5.6.3


Any comments please send as CC to me because I'm not on netdev mainling list.

Regards,

Alan
