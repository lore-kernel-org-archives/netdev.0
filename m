From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: put tx to napi poll function
 to fix dead lock
Date: Mon, 04 Mar 2013 14:15:07 -0500 (EST)
Message-ID: <20130304.141507.1100300683952317840.davem@davemloft.net>
References: <1362368065-5809-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758520Ab3CDTPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 14:15:08 -0500
In-Reply-To: <1362368065-5809-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Mon, 4 Mar 2013 11:34:25 +0800

> up stack ndo_start_xmit already hold lock.
> fec_enet_start_xmit needn't spin lock.
> stat_xmit just update fep->cur_tx
> fec_enet_tx just update fep->dirty_tx
> 
> Reserve a empty bdb to check full or empty
> cur_tx == dirty_tx    means full
> cur_tx == dirty_tx +1 means empty
> 
> So needn't is_full variable.
 ...
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied.
