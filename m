From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/4] net: ethernet: remove unnecessary
 platform_set_drvdata()
Date: Mon, 27 May 2013 22:36:49 -0700 (PDT)
Message-ID: <20130527.223649.1171764029650198407.davem@davemloft.net>
References: <000101ce5b60$5fcef5f0$1f6ce1d0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com,
	rob.herring@calxeda.com, stigge@antcom.de, mugunthanvnm@ti.com,
	hsweeten@visionengravers.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932643Ab3E1Fgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:36:50 -0400
In-Reply-To: <000101ce5b60$5fcef5f0$1f6ce1d0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 28 May 2013 14:01:12 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Acked-by: Rob Herring <rob.herring@calxeda.com>
> Acked-by: Roland Stigge <stigge@antcom.de>
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
> Reviewed-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Tested-by: Roland Stigge <stigge@antcom.de>

Applied.
