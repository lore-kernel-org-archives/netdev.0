From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/4] net/phy: Add VSC8234 support
Date: Wed, 20 Nov 2013 22:10:21 -0500 (EST)
Message-ID: <20131120.221021.1514590746847072232.davem@davemloft.net>
References: <1384987099-4518-1-git-send-email-Shruti@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@gmail.com,
	galak@kernel.crashing.org
To: Shruti@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab3KUDKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 22:10:23 -0500
In-Reply-To: <1384987099-4518-1-git-send-email-Shruti@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Shruti@freescale.com>
Date: Wed, 20 Nov 2013 16:38:16 -0600

> From: Andy Fleming <afleming@gmail.com>
> 
> Vitesse VSC8234 is quad port 10/100/1000BASE-T PHY
> with SGMII and SERDES MAC interfaces.
> 
> Signed-off-by: Andy Fleming <afleming@gmail.com>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> Signed-off-by: Shruti Kanetkar <Shruti@freescale.com>
> ---
>  drivers/net/phy/vitesse.c |   19 +++++++++++++++++--
>  1 file changed, 17 insertions(+), 2 deletions(-)
> 
> v3:	No content change. v1 & 2 didn't get picked up by Patchwork.
> 	No idea what else to do so trying to re-submit from a different
> 	machine (git version, etc.)

These didn't make it to patchwork again, I wonder if it has to do
with the gratuitous angle brackets around "<netdev@vger.kernel.org>"
in your headers.

Whatever the reason I lack the time to look into the cause, so I've
just applied these patches.

Thanks.
