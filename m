From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH] smc91x: enable ethtool EEPROM interface
Date: Fri, 16 Jan 2009 00:06:12 -0500 (EST)
Message-ID: <alpine.LFD.2.00.0901160004110.9524@xanadu.home>
References: <1232081619-25580-1-git-send-email-VernonInHand@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Vernon Sauder <vernoninhand@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:9380 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbZAPFGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 00:06:18 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR003.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KDJ00MZLSUCRL20@VL-MO-MR003.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 16 Jan 2009 00:06:12 -0500 (EST)
In-reply-to: <1232081619-25580-1-git-send-email-VernonInHand@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jan 2009, Vernon Sauder wrote:

> From: Vernon Sauder <vsauder@inhand.com>
> 
> 
> Signed-off-by: Vernon Sauder <vsauder@inhand.com>
> ---
>  drivers/net/smc91x.c |  112 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 110 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index b215a8d..f692439 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -1643,6 +1643,113 @@ static void smc_ethtool_setmsglevel(struct net_device *dev, u32 level)
>  	lp->msg_enable = level;
>  }
>  
> +/* GP is same as RPC, just bank 1 */
> +#define SMC_GET_GP		SMC_GET_RPC
> +#define SMC_SET_GP		SMC_SET_RPC

NAK.  This will blow up the moment you have SMC_DEBUG > 0.
Please add proper definitions in smc91x.h instead.


Nicolas
