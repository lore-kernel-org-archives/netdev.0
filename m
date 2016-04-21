From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: spi_ks8895: Don't leak references to SPI
 devices
Date: Thu, 21 Apr 2016 15:00:39 -0400 (EDT)
Message-ID: <20160421.150039.591459586047228776.davem@davemloft.net>
References: <1461153245-7992-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbcDUTAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:00:41 -0400
In-Reply-To: <1461153245-7992-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Wed, 20 Apr 2016 12:54:05 +0100

> The ks8895 driver is using spi_dev_get() apparently just to take a copy
> of the SPI device used to instantiate it but never calls spi_dev_put()
> to free it.  Since the device is guaranteed to exist between probe() and
> remove() there should be no need for the driver to take an extra
> reference to it so fix the leak by just using a straight assignment.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>

Applied.
