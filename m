From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix ethtool stats
Date: Sat, 24 Jul 2010 20:43:30 -0700 (PDT)
Message-ID: <20100724.204330.189711808.davem@davemloft.net>
References: <20100723234252.18203.56378.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	eric.dumazet@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53441
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162Ab0GYDnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 23:43:13 -0400
In-Reply-To: <20100723234252.18203.56378.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 23 Jul 2010 16:44:21 -0700

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> In latest changes about 64bit stats on 32bit arches,
> [commit 28172739f0a276eb8 (net: fix 64 bit counters on 32 bit arches)],
> I missed ixgbe uses a bit of magic in its ixgbe_gstrings_stats
> definition.
> 
> IXGBE_NETDEV_STAT() must now assume offsets relative to
> rtnl_link_stats64, not relative do dev->stats.
> 
> As a bonus, we also get 64bit stats on ethtool -S
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
