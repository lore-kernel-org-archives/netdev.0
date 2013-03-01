From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1 net-next] fec: net: put tx to napi poll function
 to fix dead lock
Date: Fri, 01 Mar 2013 15:58:59 -0500 (EST)
Message-ID: <20130301.155859.2106303756469493825.davem@davemloft.net>
References: <1362109034-25805-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816Ab3CAU7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 15:59:01 -0500
In-Reply-To: <1362109034-25805-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Fri, 1 Mar 2013 11:37:14 +0800

> @@ -566,27 +554,47 @@ fec_timeout(struct net_device *ndev)
>  	netif_wake_queue(ndev);
>  }
>  
> -static void
> +static int
>  fec_enet_tx(struct net_device *ndev)

The return value of this function is never tested, get rid of it.
