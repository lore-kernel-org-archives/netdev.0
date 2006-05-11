From: James Cameron <james.cameron@hp.com>
Subject: [PATCH] sis900 Foxconn 661FX7MI-S PHY support
Date: Thu, 11 May 2006 10:05:49 +1000
Message-ID: <20060511000549.GA3994@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:20395 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S965098AbWEKAFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 20:05:47 -0400
To: netdev@vger.kernel.org, Daniele Venzano <venza@brownhat.org>,
	Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is required to get sis900 ethernet working well on a Foxconn
661FX7MI-S motherboard which uses the SiS 661FX chipset.  The patch adds
an entry to mii_chip_info for the transceiver.

Signed-off-by: James Cameron <james.cameron@hp.com>
Acked-by: Daniele Venzano <venza@brownhat.org>
---

diff -puN linux-2.6.17-rc3-git17/drivers/net/sis900.c.orig linux-2.6.17-rc3-git17/drivers/net/sis900.c
--- linux-2.6.17-rc3-git17/drivers/net/sis900.c.orig	2006-05-11 09:21:52.000000000 +1000
+++ linux-2.6.17-rc3-git17/drivers/net/sis900.c	2006-05-11 09:34:26.000000000 +1000
@@ -127,6 +127,7 @@ static const struct mii_chip_info {
 } mii_chip_table[] = {
 	{ "SiS 900 Internal MII PHY", 		0x001d, 0x8000, LAN },
 	{ "SiS 7014 Physical Layer Solution", 	0x0016, 0xf830, LAN },
+	{ "SiS 900 on Foxconn 661 7MI",		0x0143, 0xBC70, LAN },
 	{ "Altimata AC101LF PHY",               0x0022, 0x5520, LAN },
 	{ "ADM 7001 LAN PHY",			0x002e, 0xcc60, LAN },
 	{ "AMD 79C901 10BASE-T PHY",  		0x0000, 0x6B70, LAN },
