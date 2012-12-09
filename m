From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] caif_usb: Check driver name before
 reading driver state in netdev notifier
Date: Sun, 09 Dec 2012 00:34:33 -0500 (EST)
Message-ID: <20121209.003433.1020103311321779326.davem@davemloft.net>
References: <1354897046.2707.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605Ab2LIFef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 00:34:35 -0500
In-Reply-To: <1354897046.2707.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 7 Dec 2012 16:17:26 +0000

> In cfusbl_device_notify(), the usbnet and usbdev variables are
> initialised before the driver name has been checked.  In case the
> device's driver is not cdc_ncm, this may result in reading beyond the
> end of the netdev private area.  Move the initialisation below the
> driver name check.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
