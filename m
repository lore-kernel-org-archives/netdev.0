From: David Miller <davem@davemloft.net>
Subject: Re: 4.4 stable request for net: macb: fix default configuration
 for GMAC on AT91
Date: Mon, 27 Jun 2016 10:09:47 -0400 (EDT)
Message-ID: <20160627.100947.1346266322935682261.davem@davemloft.net>
References: <576BAB64.5050104@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas.FERRE@atmel.com,
	romain.henriet@l-acoustics.com
To: cyrille.pitchen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbcF0OKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:10:16 -0400
In-Reply-To: <576BAB64.5050104@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date: Thu, 23 Jun 2016 11:27:00 +0200

> For 4.4 -stable, can you please consider commit:
> 
> commit 6bdaa5e9ed39b3b3328f35d218e8ad5a99cfc4d2
> Author: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date:   Thu Mar 10 16:44:32 2016 +0100
> 
>     net: macb: fix default configuration for GMAC on AT91
 ...
> Without this patch, the macb ethernet controller is always configured to be
> connected to a RMII phy on sama5dx SoCs. Hence the network doesn't work on
> boards embedding such SoCs and MII phy.
> 
> 
> A backport to 4.4.13 is below.

Queued up, thanks.
