From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/8] net: mediatek: make the driver pass stress tests
Date: Tue, 12 Apr 2016 22:42:09 -0400 (EDT)
Message-ID: <20160412.224209.261657745151516457.davem@davemloft.net>
References: <1460069651-1234-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, matthias.bgg@gmail.com, sean.wang@mediatek.com,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: blogic@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbcDMCmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 22:42:12 -0400
In-Reply-To: <1460069651-1234-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <blogic@openwrt.org>
Date: Fri,  8 Apr 2016 00:54:03 +0200

> While testing the driver we managed to get the TX path to stall and fail
> to recover. When dual MAC support was added to the driver, the whole queue
> stop/wake code was not properly adapted. There was also a regression in the
> locking of the xmit function. The fact that watchdog_timeo was not set and
> that the tx_timeout code failed to properly reset the dma, irq and queue
> just made the mess complete.
> 
> This series make the driver pass stress testing. With this series applied
> the testbed has been running for several days and still has not locked up.
> We have a second setup that has a small hack patch applied to randomly stop
> irqs and/or one of the queues and successfully manages to recover from these
> simulated tx stalls.

Series applied, thanks.
