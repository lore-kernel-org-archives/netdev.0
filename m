From: David Brownell <david-b@pacbell.net>
Subject: [RESEND #4/patch 2.6.26-rc6] net/enc28j60: section fix
Date: Thu, 12 Jun 2008 21:36:24 -0700
Message-ID: <200806122136.24921.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp122.sbc.mail.sp1.yahoo.com ([69.147.64.95]:38967 "HELO
	smtp122.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751610AbYFMEjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 00:39:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor bugfixes to the enc28j60 driver ... wrong section marking,
indentation, and bogus use of spi_bus_type.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
---
Previously sent:  18-April, 19-February, 6-February.

 drivers/net/enc28j60.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- g26.orig/drivers/net/enc28j60.c	2008-02-22 19:48:13.000000000 -0800
+++ g26/drivers/net/enc28j60.c	2008-02-22 19:48:14.000000000 -0800
@@ -1556,7 +1556,7 @@ error_alloc:
 	return ret;
 }
 
-static int enc28j60_remove(struct spi_device *spi)
+static int __devexit enc28j60_remove(struct spi_device *spi)
 {
 	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
 
@@ -1573,9 +1573,8 @@ static int enc28j60_remove(struct spi_de
 static struct spi_driver enc28j60_driver = {
 	.driver = {
 		   .name = DRV_NAME,
-		   .bus = &spi_bus_type,
 		   .owner = THIS_MODULE,
-		   },
+	 },
 	.probe = enc28j60_probe,
 	.remove = __devexit_p(enc28j60_remove),
 };
