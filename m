From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/1] net: fec: implement rx_copybreak to improve rx
 performance
Date: Wed, 01 Oct 2014 21:28:49 -0400 (EDT)
Message-ID: <20141001.212849.2078900538773317003.davem@davemloft.net>
References: <1412040485-19130-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shawn.guo@linaro.org,
	romieu@fr.zoreil.com, eric.dumazet@gmail.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbaJBB2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 21:28:51 -0400
In-Reply-To: <1412040485-19130-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 30 Sep 2014 09:28:05 +0800

> - Copy short frames and keep the buffers mapped, re-allocate skb instead of
>   memory copy for long frames.
> - Add support for setting/getting rx_copybreak using generic ethtool tunable
> 
> Changes V3:
> * As Eric Dumazet's suggestion that removing the copybreak module parameter
>   and only keep the ethtool API support for rx_copybreak.
> 
> Changes V2:
> * Implements rx_copybreak
> * Rx_copybreak provides module parameter to change this value
> * Add tunable_ops support for rx_copybreak
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied, thanks.
