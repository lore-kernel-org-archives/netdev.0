From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: fec: reduce spin lock time in fec_ptp_adjfreq
Date: Wed, 07 Nov 2012 18:53:04 -0500 (EST)
Message-ID: <20121107.185304.1774660119595460505.davem@davemloft.net>
References: <1352268889-16836-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, richardcochran@gmail.com, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.or, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab2KGXxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 18:53:07 -0500
In-Reply-To: <1352268889-16836-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Wed, 7 Nov 2012 14:14:49 +0800

> move below calculate out of spin lock section
> 	diff = fep->cc.mult;
> 	diff *= ppb;
> 	diff = div_u64(diff, 1000000000ULL);
> 
> diff is local variable and not neccesary in spin lock
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Also applied, thanks.
