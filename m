From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 14/15] com20020_cs: more device support
Date: Fri, 30 Jun 2006 22:03:51 +0200
Message-ID: <20060630200351.GO9095@dominikbrodowski.de>
References: <20060630195439.GE9095@dominikbrodowski.de> <20060630195501.GF9095@dominikbrodowski.de> <20060630195600.GG9095@dominikbrodowski.de> <20060630195657.GH9095@dominikbrodowski.de> <20060630195753.GI9095@dominikbrodowski.de> <20060630195920.GJ9095@dominikbrodowski.de> <20060630195950.GK9095@dominikbrodowski.de> <20060630200015.GL9095@dominikbrodowski.de> <20060630200111.GM9095@dominikbrodowski.de> <20060630200146.GN9095@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.239.214.66]:33979 "EHLO linta.de")
	by vger.kernel.org with ESMTP id S1750921AbWF3UMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 16:12:39 -0400
To: linux-pcmcia@lists.infradead.org
Content-Disposition: inline
In-Reply-To: <20060630200146.GN9095@dominikbrodowski.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Marc Sowen <Marc.Sowen@ibeo-as.de>
Date: Sun, 25 Jun 2006 01:56:24 -0700
Subject: [PATCH] com20020_cs: more device support

Enable the com20020_cs arcnet driver to see the SoHard (now Mercury
Computer Systems Inc.) SH ARC-PCMCIA card.

Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/com20020_cs.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 441de82..48434d7 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -387,7 +387,10 @@ static int com20020_resume(struct pcmcia
 }
 
 static struct pcmcia_device_id com20020_ids[] = {
-	PCMCIA_DEVICE_PROD_ID12("Contemporary Control Systems, Inc.", "PCM20 Arcnet Adapter", 0x59991666, 0x95dfffaf),
+	PCMCIA_DEVICE_PROD_ID12("Contemporary Control Systems, Inc.",
+			"PCM20 Arcnet Adapter", 0x59991666, 0x95dfffaf),
+	PCMCIA_DEVICE_PROD_ID12("SoHard AG",
+			"SH ARC PCMCIA", 0xf8991729, 0x69dff0c7),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, com20020_ids);
-- 
1.4.0

