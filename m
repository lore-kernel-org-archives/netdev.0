From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/15] net: ethernet: remove unnecessary
 pci_set_drvdata() part 2
Date: Mon, 21 Oct 2013 17:21:53 -0400 (EDT)
Message-ID: <20131021.172153.1918303473990261707.davem@davemloft.net>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444Ab3JUVVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 17:21:54 -0400
In-Reply-To: <003801cece02$6abb0160$40310420$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 21 Oct 2013 11:08:21 +0900

> Since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound),
> the driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.

Series applied, thanks.
