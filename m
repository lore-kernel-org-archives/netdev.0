From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.4.28-rc1-bk3] forcedeth: Backport of gigabit ethernet support and media detection rewrite
Date: Sat, 30 Oct 2004 09:00:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030130011.GA4261@havoc.gtf.org>
References: <Pine.LNX.4.44.0410301442220.25784-100000@dbl.q-ag.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.tosatti@cyclades.com, blazara@nvidia.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410301442220.25784-100000@dbl.q-ag.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 30, 2004 at 02:53:08PM +0200, Manfred Spraul wrote:
> Differences between 2.6 and 2.4:
> 
> - static msleep helper added.

Sigh, libata has this too.  I'll work up a patch to make it public.


> After applying this patch, the driver is nearly in sync with 2.6.10-rc1:
> The only additional differences are __iomem annotations and the use of
> netdev_priv.

Will __iomem and netdev_priv() changes be in a separate patch?

2.4.x has both.

	Jeff
