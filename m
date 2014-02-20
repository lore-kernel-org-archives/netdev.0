From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4: Mellanox driver update 01-01-2014
Date: Thu, 20 Feb 2014 22:15:47 +0200
Message-ID: <20140220201320.GA24686@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
 <20140219.165049.1684072721398326970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:40318 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654AbaBTUPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 15:15:52 -0500
Received: by mail-we0-f181.google.com with SMTP id w61so1844919wes.40
        for <netdev@vger.kernel.org>; Thu, 20 Feb 2014 12:15:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140219.165049.1684072721398326970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/02/14 16:50 -0500, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Wed, 19 Feb 2014 14:58:01 +0200
> 
> > V0 of this patch was sent before previous net-next got closed, and
> > now we would like to resume it.
> > 
> > Yuval has reworked the affinity hint patch, according to Ben's comments. The
> > patch was actually rewritten.
> > After a discussion with Yuval Mintz, use of netif_get_num_default_rss_queues()
> > is not reverted, but done in the right place. Instead of limiting the number of
> > IRQ's for the driver it will limit the number of queues in RSS.
> > 
> > Patchset was applied and tested against commit: cb6e926 "ipv6:fix checkpatch
> > errors with assignment in if condition"
> 
> Influencing IRQs to be allocated on the same NUMA code as the one where
> the card resides doesn't sound like an mlx4 specific desire to me.
> 
> Other devices, both networking and non-networking, probably might like
> that as well.
> 
> Therefore doing this by hand in a specific driver doesn't seem
> appropriate at all.

I agree. Will try to find a way to make it generic and resubmit this
patch.
Please continue with the review of the other patches by Ido, that will
fix the way netif_get_num_default_rss_queues() is used in Mellanox
driver.

Thanks,
Amir
