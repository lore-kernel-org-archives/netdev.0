From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Sat, 02 Feb 2013 23:08:51 -0500 (EST)
Message-ID: <20130202.230851.809969826800130930.davem@davemloft.net>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab3BCEIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 23:08:53 -0500
In-Reply-To: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Fri, 1 Feb 2013 16:56:26 +0800

> @@ -1607,6 +1607,7 @@ static int fec_enet_init(struct net_device *ndev)
>  	}
>  
>  	spin_lock_init(&fep->hw_lock);
> +	spin_lock_init(&fep->tmreg_lock);

This breaks the build, tmreg_lock is only present in certain
configurations.
