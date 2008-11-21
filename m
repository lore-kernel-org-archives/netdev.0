From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB
 to the kernel and ixgbe driver
Date: Fri, 21 Nov 2008 01:21:15 -0800 (PST)
Message-ID: <20081121.012115.193683243.davem@davemloft.net>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	<49267BE8.6020205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39419
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751405AbYKUJVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 04:21:15 -0500
In-Reply-To: <49267BE8.6020205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 21 Nov 2008 17:14:16 +0800

> Jeff Kirsher said the following on 2008-11-21 10:00:
> > diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
> > index a610016..aaa4404 100644
> > --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> > +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> > @@ -97,9 +97,18 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
> >  	((((struct ixgbe_adapter *)netdev_priv(netdev))->num_tx_queues + \
> >  	((struct ixgbe_adapter *)netdev_priv(netdev))->num_rx_queues) * \
> >  	(sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
> > -#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
> >  #define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
> > -#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
> > +#define IXGBE_PB_STATS_LEN ( \
> > +                 (((struct ixgbe_adapter *)netdev->priv)->flags & \
> 
> Dave, please don't hate me. :)
> I know you've applied it.
> But I don't want this directly reference of netdev->priv.

Send me a patch!
