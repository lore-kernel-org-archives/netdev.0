From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: fix most sparse warnings
Date: Wed, 05 Dec 2012 16:25:46 -0500 (EST)
Message-ID: <20121205.162546.1187131916097405931.davem@davemloft.net>
References: <1354652235-13174-1-git-send-email-gallatin@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab2LEVZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:25:47 -0500
In-Reply-To: <1354652235-13174-1-git-send-email-gallatin@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue,  4 Dec 2012 15:17:15 -0500

> - convert remaining htonl/ntohl +__raw_read/__raw_writel to
>   swab32 + readl/writel
> - add missing __iomem qualifier in myri10ge_open()
> - fix  dubious: x & !y warning by switching from logical to bitwise not
> 
> The swab32 conversion fixes a bug in myri10ge_led() where
> big-endian machines would write the wrong pattern.
> 
> The only remaining warning (lock context imbalance) is due to
> the use of __netif_tx_trylock(), and cannot easily be fixed.
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>

Applied.
