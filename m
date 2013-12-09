From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] wan: lmc: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 18:10:36 -0500 (EST)
Message-ID: <20131209.181036.1753086010041043078.davem@davemloft.net>
References: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
	<000b01cef48f$09664100$1c32c300$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761319Ab3LIXKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 18:10:37 -0500
In-Reply-To: <000b01cef48f$09664100$1c32c300$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 09 Dec 2013 12:30:41 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
