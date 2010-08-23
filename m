From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netdev: re-expose net_device_stats to user headers
Date: Mon, 23 Aug 2010 09:17:50 -0700
Message-ID: <20100823091750.2bf87605@nehalam>
References: <20100823083258.0777e83d@nehalam>
	<1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48866 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754341Ab0HWQRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 12:17:53 -0400
In-Reply-To: <1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Aug 2010 16:43:23 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2010-08-23 at 08:32 -0700, Stephen Hemminger wrote:
> > This commit broke iproute2 build:
> > 
> > commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b
> > Author: Ben Hutchings <bhutchings@solarflare.com>
> > Date:   Tue Jun 8 07:19:54 2010 +0000
> > 
> >     net: Enable 64-bit net device statistics on 32-bit architectures
> >     
> >     Use struct rtnl_link_stats64 as the statistics structure.
> > 
> > Iproute2 uses a the kernel exported headers, and the structure
> > net_device_stats which is part of the netlink IFLA_STATS message
> > was no longer exposed.
> [...]
> 
> This is not true; the kernel uses struct rtnl_link_stats for IFLA_STATS.
> AFAICS the only reference to struct net_device_stats in iproute2 is:
> 
> misc/ifstat.c:51:#define MAXS (sizeof(struct net_device_stats)/sizeof(unsigned long))
> 
> This should be changed to refer to the structure that is actually used.

Ok.
