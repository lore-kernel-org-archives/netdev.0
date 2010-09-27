From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: igmp: Allow mininum interval specification for igmp timers.
Date: Mon, 27 Sep 2010 10:54:44 -0700 (PDT)
Message-ID: <20100927.105444.214208865.davem@davemloft.net>
References: <alpine.DEB.2.00.1009221354410.32661@router.home>
	<20100923.213823.137834706.davem@davemloft.net>
	<OF4BA8F9C2.467056E9-ON882577AB.005F4832-882577AB.00612DD6@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org
To: dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OF4BA8F9C2.467056E9-ON882577AB.005F4832-882577AB.00612DD6-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Mon, 27 Sep 2010 10:41:20 -0700

>         I don't know if you saw the more extended discussion we
> had on this or not, but I think while this would help for IB,
> it's not appropriate in general. These can in fact be "0" per
> RFC which is worst case for IB if there is a delay for being
> able to use the group, and the newer IGMPv3 standard has shortened
> the max interval from 10sec in v2 to 1 sec.

I did see the extended discussion, and it was interesting :-)

But that mainly focused on the second patch, which I appropriately
marked as needing changes in patchwork.

This patch on the other hand is attacking a different problem,
namely avoiding the worst cases caused by the randomization we
do for the timer.

With bad luck this thing times out way too fast because the total of
all of the randomized intervals can end up being very small, and I
think we should fix that independently of the other issues hit by the
IB folks.

Don't you agree?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
