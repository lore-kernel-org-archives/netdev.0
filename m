From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 02/15] pcmcia: remove remaining unused IRQ_FIRST_SHARED parameter
Date: Wed,  6 Jan 2010 12:46:13 +0100
Message-ID: <1262778386-30182-2-git-send-email-linux@dominikbrodowski.net>
References: <20100106114531.GA29913@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, Komuro <komurojun-mbn@nifty.com>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:47082 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755685Ab0AFLrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 06:47:15 -0500
In-Reply-To: <20100106114531.GA29913@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Komuro pointed out correctly that I missed one IRQ_FIRST_SHARED
parameter in smc91c92_cs.c, and that another line could be writter
more beautifully.

CC: netdev@vger.kernel.org
CC: Komuro <komurojun-mbn@nifty.com>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/smc91c92_cs.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 6dd486d..aa57cfd 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -453,8 +453,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
-    link->irq.Attributes =
-	IRQ_TYPE_DYNAMIC_SHARING;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->io.IOAddrLines = 16;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
@@ -652,8 +651,7 @@ static int osi_config(struct pcmcia_device *link)
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
-    link->irq.Attributes =
-	IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->io.NumPorts1 = 64;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
-- 
1.6.3.3

