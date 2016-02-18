From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB: cdc_subset: only build when one driver is enabled
Date: Thu, 18 Feb 2016 16:00:09 -0500 (EST)
Message-ID: <20160218.160009.1485326686227753180.davem@davemloft.net>
References: <1455747932-2844084-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, linux-arm-kernel@lists.infradead.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948008AbcBRVAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 16:00:13 -0500
In-Reply-To: <1455747932-2844084-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 17 Feb 2016 23:25:11 +0100

> This avoids a harmless randconfig warning I get when USB_NET_CDC_SUBSET
> is enabled, but all of the more specific drivers are not:
> 
> drivers/net/usb/cdc_subset.c:241:2: #warning You need to configure some hardware for this driver
> 
> The current behavior is clearly intentional, giving a warning when
> a user picks a configuration that won't do anything good. The only
> reason for even addressing this is that I'm getting close to
> eliminating all 'randconfig' warnings on ARM, and this came up
> a couple of times.
> 
> My workaround is to not even build the module when none of the
> configurations are enable.
> 
> Alternatively we could simply remove the #warning (nothing wrong
> for compile-testing), turn it into a runtime warning, or
> change the Kconfig options into a menu to hide CONFIG_USB_NET_CDC_SUBSET.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
