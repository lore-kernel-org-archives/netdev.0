From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fec: Fix fec_enet_alloc_buffers() error path
Date: Mon, 06 Oct 2014 00:54:21 -0400 (EDT)
Message-ID: <20141006.005421.1323921175700971872.davem@davemloft.net>
References: <1412440801-15381-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmk+kernel@arm.linux.org.uk, Frank.Li@freescale.com,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbaJFEyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:54:22 -0400
In-Reply-To: <1412440801-15381-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Sat,  4 Oct 2014 13:40:01 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> When fec_enet_alloc_buffers() fails we should better undo the previous actions,
> which consists of: disabling the FEC clocks and putting the FEC pins into
> inactive state.
> 
> The error path for fec_enet_mii_probe() is kept unchanged.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks Fabio.
