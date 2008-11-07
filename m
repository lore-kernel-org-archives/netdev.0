From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] via-velocity: enable perfect filtering for
 multicast packets
Date: Fri, 7 Nov 2008 14:51:52 -0800
Message-ID: <20081107145152.f3f264fb.akpm@linux-foundation.org>
References: <20081107223617.GA23082@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?S=E9guier_R?= =?ISO-8859-1?Q?=E9gis?=
	<rseguier@e-teleport.net>, HaraldWelte@viatech.com,
	JoeyZhuo@via.com.tw, AJJiang@via.com.tw, BruceChang@via.com.tw,
	WaltonLi@via.com.tw
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60171 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbYKGWwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 17:52:32 -0500
In-Reply-To: <20081107223617.GA23082@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Nov 2008 23:36:17 +0100 Francois Romieu <romieu@fr.zoreil.com> wrote:

> Signed-off-by: Joey Zhuo <joeyzhuo@via.com.tw>
> Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>

ooh, we need a Hacked-off-by too :)

I guess you meant Acked-by:, but as you were on the delivery path for
this patch, a Signed-off-by: is more appropriate.


> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
> @@ -2296,7 +2296,7 @@ static void velocity_set_multi(struct net_device *dev)
>  		}
>  
>  		mac_set_cam_mask(regs, vptr->mCAMmask);
> -		rx_mode = (RCR_AM | RCR_AB);
> +		rx_mode = RCR_AM | RCR_AB | RCR_AP;
>  	}
>  	if (dev->mtu > 1500)
>  		rx_mode |= RCR_AL;

