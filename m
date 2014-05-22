From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: fec: optimize the clock management to save
 power
Date: Thu, 22 May 2014 15:03:26 -0400 (EDT)
Message-ID: <20140522.150326.1369507090122196405.davem@davemloft.net>
References: <1400563371-3359-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbaEVTD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:03:28 -0400
In-Reply-To: <1400563371-3359-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 20 May 2014 13:22:51 +0800

> Add below clock management to save fec power:
> - After probe, disable all clocks incluing ipg, ahb, enet_out, ptp clock.
> - Open ethx interface enable necessary clocks.
>   Close ethx interface disable all clocks.
> 
> The patch also encapsulates the all enet clocks enable/disable to
> .fec_enet_clk_enable(), which can reduce the repetitional code in
> driver.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied to net-next.
