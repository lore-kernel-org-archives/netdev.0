From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: fix unicast filter programming in
 promiscuous mode
Date: Fri, 19 Jun 2009 00:25:08 -0700 (PDT)
Message-ID: <20090619.002508.239934377.davem@davemloft.net>
References: <20090618213502.GM12752@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50161
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752807AbZFSHZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 03:25:04 -0400
In-Reply-To: <20090618213502.GM12752@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 18 Jun 2009 23:35:02 +0200

> From: Prabhanjan Sarnaik <sarnaik@marvell.com>
> 
> The Unicast Promiscious Mode (UPM) bit in the mv643xx_eth port
> configuration register doesn't do exactly what its name would suggest:
> setting this bit merely enables reception of all unicast frames with a
> destination address that differs from our local MAC address in bits
> [47:4].  In particular, it doesn't have any effect on unicast frames
> with a destination address that matches our MAC address in bits [47:4]
> -- these will still be tested against the 16-entry unicast address
> filter table.
> 
> Therefore, if the interface is set to promiscuous mode, just setting
> the unicast promiscuous bit isn't enough -- we need to set all filter
> bits in the unicast filter table to 1 as well.
> 
> Reported-by: Sachin Sanap <ssanap@marvell.com>
> Signed-off-by: Prabhanjan Sarnaik <sarnaik@marvell.com>
> Tested-by: Siddarth Gore <gores@marvell.com>
> Tested-by: Mahavir Jain <mjain@marvell.com>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Cc: stable@kernel.org
> ---
> This patch is relevant for 2.6.29 and 2.6.30 as well.

Applied, and queued up for -stable.
