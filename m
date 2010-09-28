From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] de2104x: disable media debug messages by default
Date: Tue, 28 Sep 2010 20:18:55 +0200
Message-ID: <201009282018.57547.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Print media debug messages only when HW debug is enabled.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.36-rc3-/drivers/net/tulip/de2104x.c	2010-09-28 19:50:51.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/tulip/de2104x.c	2010-09-28 20:05:34.000000000 +0200
@@ -948,8 +948,9 @@ static void de_set_media (struct de_priv
 	else
 		macmode &= ~FullDuplex;
 
-	if (netif_msg_link(de)) {
+	if (netif_msg_link(de))
 		dev_info(&de->dev->dev, "set link %s\n", media_name[media]);
+	if (netif_msg_hw(de)) {
 		dev_info(&de->dev->dev, "mode 0x%x, sia 0x%x,0x%x,0x%x,0x%x\n",
 			 dr32(MacMode), dr32(SIAStatus),
 			 dr32(CSR13), dr32(CSR14), dr32(CSR15));


-- 
Ondrej Zary
