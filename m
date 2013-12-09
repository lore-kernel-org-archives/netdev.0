From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] net: sis900: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 18:09:52 -0500 (EST)
Message-ID: <20131209.180952.1446606050807717281.davem@davemloft.net>
References: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
	<000401cef48e$58512790$08f376b0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, venza@brownhat.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab3LIXJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 18:09:53 -0500
In-Reply-To: <000401cef48e$58512790$08f376b0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 09 Dec 2013 12:25:44 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
