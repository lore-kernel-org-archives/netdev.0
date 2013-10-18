From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/15] net: ethernet: remove unnecessary
 pci_set_drvdata() part 1
Date: Fri, 18 Oct 2013 00:04:30 -0400 (EDT)
Message-ID: <20131018.000430.982140151062639781.davem@davemloft.net>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab3JREEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 00:04:31 -0400
In-Reply-To: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Fri, 18 Oct 2013 09:16:19 +0900

> Since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound),
> the driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.

Series applied, thanks.
