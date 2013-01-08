From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Place 'inline' in the beginning of
 declaration
Date: Mon, 07 Jan 2013 19:23:41 -0800 (PST)
Message-ID: <20130107.192341.1915401786644216098.davem@davemloft.net>
References: <1357615233-30241-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab3AHDXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:23:42 -0500
In-Reply-To: <1357615233-30241-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue,  8 Jan 2013 01:20:33 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Fix the following warning when building with W=1 option:
> 
> drivers/net/ethernet/freescale/fec.c:810:1: warning: '__inline__' is not at beginning of declaration [-Wold-style-declaration]
> 
> Putting __inline__ in the beggining then checkpath complains:
> 
> WARNING: plain inline is preferred over __inline__
> #24: FILE: drivers/net/ethernet/freescale/fec.c:810:
> +static __inline__ void fec_get_mac(struct net_device *ndev)
> 
> ,so use 'inline' in the beginning and make gcc and checkpath happy.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

I would remove the inline tag altogether, it's pointless.
