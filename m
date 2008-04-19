From: David Brownell <david-b@pacbell.net>
Subject: [RESEND/patch 2.6.25] net/enc28j60: section fix
Date: Fri, 18 Apr 2008 19:08:10 -0700
Message-ID: <200804181908.10283.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802062208.48838.david-b@pacbell.net> <47AAE7CD.9050801@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.sbc.mail.mud.yahoo.com ([68.142.198.210]:34800 "HELO
	smtp111.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751109AbYDSCiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 22:38:50 -0400
In-Reply-To: <47AAE7CD.9050801@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor bugfixes to the enc28j60 driver ... wrong section marking,
indentation, and bogus use of spi_bus_type. 

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
---
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
