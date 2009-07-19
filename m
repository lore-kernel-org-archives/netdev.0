From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH] drivers/net/mlx4: Adjust constant
Date: Sun, 19 Jul 2009 21:08:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907192108270.18234@ask.diku.dk>
References: <Pine.LNX.4.64.0907191809050.16542@ask.diku.dk>
 <1248027891.31365.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751191AbZGSTIv@vger.kernel.org>
In-Reply-To: <1248027891.31365.17.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for pointing this out.  I will look into it.

julia


On Sun, 19 Jul 2009, Joe Perches wrote:

> On Sun, 2009-07-19 at 18:09 +0200, Julia Lawall wrote:
> > From: Julia Lawall <julia@diku.dk>
> > 
> > The values in the advertising field are typically ADVERTISED_xxx, not
> > SUPPORTED_xxx.  Both SUPPORTED_10000baseT_Full and
> > ADVERTISED_1000baseT_Full have the same value.
> 
> other possibles:
> 
> drivers/net/sungem.c:#define ADVERTISE_MASK	(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | \
> 			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full | \
> 			 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full | \
> 			 SUPPORTED_Pause | SUPPORTED_Autoneg)
> drivers/net/s2io.c:	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
> drivers/net/spider_net.c:		advertise |= SUPPORTED_1000baseT_Full;
> drivers/net/spider_net.c:		advertise |= SUPPORTED_1000baseT_Half;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
