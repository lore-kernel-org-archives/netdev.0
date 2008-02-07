From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.24-git] net/enc28j60: section fix
Date: Wed, 6 Feb 2008 22:08:48 -0800
Message-ID: <200802062208.48838.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47A9EA42.3080800@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.sbc.mail.mud.yahoo.com ([68.142.198.209]:33893 "HELO
	smtp110.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752216AbYBGGIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 01:08:52 -0500
In-Reply-To: <47A9EA42.3080800@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor bugfixes to the enc28j60 driver ... wrong section marking and
indentation, and bogus use of spi_bus_type.  (Setting the bus type
of a driver is a SPI framework responsibility.)

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
Bonus patch.

 drivers/net/enc28j60.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1555,7 +1555,7 @@ error_alloc:
 	return ret;
 }
 
-static int enc28j60_remove(struct spi_device *spi)
+static int __devexit enc28j60_remove(struct spi_device *spi)
 {
 	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
 
@@ -1572,9 +1572,8 @@ static int enc28j60_remove(struct spi_de
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
