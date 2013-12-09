From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net: sfc: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 18:09:43 -0500 (EST)
Message-ID: <20131209.180943.1955378524645765626.davem@davemloft.net>
References: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	bhutchings@solarflare.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab3LIXJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 18:09:47 -0500
In-Reply-To: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 09 Dec 2013 12:24:07 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
