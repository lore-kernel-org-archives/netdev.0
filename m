From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] sfc: Ensure down_write(&filter_sem) and
 up_write() are matched before calling efx_net_open()
Date: Wed, 08 Jul 2015 16:19:17 -0700 (PDT)
Message-ID: <20150708.161917.1393136055881992750.davem@davemloft.net>
References: <559CE98D.1070703@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbbGHXTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:19:18 -0400
In-Reply-To: <559CE98D.1070703@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 8 Jul 2015 10:12:45 +0100

> This patch avoids the double up_write to filter_sem if
> efx_net_open() fails.
> 
> Resolves: 2d432f20d27c1813a2746008e16dd6ce12a14dc1
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
