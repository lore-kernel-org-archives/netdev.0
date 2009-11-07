From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 58/75] pcnet-cs: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 22:04:09 +0000
Message-ID: <1257631449.15927.478.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, linux-pcmcia@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37935 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602AbZKGWEG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 17:04:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/pcmcia/pcnet_cs.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 42aa81b..9088f06 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -1752,6 +1752,13 @@ static struct pcmcia_device_id pcnet_ids[] = {
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, pcnet_ids);
+MODULE_FIRMWARE("cis/PCMLM28.cis");
+MODULE_FIRMWARE("cis/DP83903.cis");
+MODULE_FIRMWARE("cis/LA-PCM.cis");
+MODULE_FIRMWARE("PE520.cis");
+MODULE_FIRMWARE("cis/NE2K.cis");
+MODULE_FIRMWARE("cis/PE-200.cis");
+MODULE_FIRMWARE("cis/tamarack.cis");
 
 static struct pcmcia_driver pcnet_driver = {
 	.drv		= {
-- 
1.6.5.2



