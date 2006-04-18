From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC PATCH 1/8] pcmcia: add new ID to pcnet_cs
Date: Tue, 18 Apr 2006 22:15:22 +0200
Message-ID: <20060418201522.GA32341@isilmar.linta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.239.214.66]:29089 "EHLO linta.de")
	by vger.kernel.org with ESMTP id S932313AbWDRUPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 16:15:23 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please review these patches which I inted to push upstream for 2.6.17 soon.
Thanks,
	Dominik

Subject: [PATCH] pcmcia: add new ID to pcnet_cs

This adds a new ID to pcnet_cs, as noted by Kuro Moji.

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

---

 drivers/net/pcmcia/pcnet_cs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

af6f85925c2984c3596ba480c19573e55724bbdf
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 506e777..d090df4 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -1639,6 +1639,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_DEVICE_PROD_ID12("CONTEC", "C-NET(PC)C-10L", 0x21cab552, 0xf6f90722),
 	PCMCIA_DEVICE_PROD_ID12("corega", "FEther PCC-TXF", 0x0a21501a, 0xa51564a2),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega EtherII PCC-T", 0x5261440f, 0xfa9d85bd),
+	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega EtherII PCC-TD", 0x5261440f, 0xc49bd73d),
 	PCMCIA_DEVICE_PROD_ID12("Corega K.K.", "corega EtherII PCC-TD", 0xd4fdcbd8, 0xc49bd73d),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega Ether PCC-T", 0x5261440f, 0x6705fcaa),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega FastEther PCC-TX", 0x5261440f, 0x485e85d9),
-- 
1.2.6

