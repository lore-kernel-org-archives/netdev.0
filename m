From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 4/4] net: wan: remove unnecessary
 platform_set_drvdata()
Date: Mon, 27 May 2013 22:40:12 -0700 (PDT)
Message-ID: <20130527.224012.520275612548234697.davem@davemloft.net>
References: <000401ce5b61$5d26eaf0$1774c0d0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khc@pm.waw.pl
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932643Ab3E1FkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:40:13 -0400
In-Reply-To: <000401ce5b61$5d26eaf0$1774c0d0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 28 May 2013 14:08:17 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
