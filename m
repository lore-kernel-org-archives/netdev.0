From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: RCU conversion of dev_getbyhwaddr() and
 arp_ioctl()
Date: Wed, 08 Dec 2010 10:05:28 -0800 (PST)
Message-ID: <20101208.100528.193703457.davem@davemloft.net>
References: <1291504514.1874.92.camel@maxim-laptop>
	<1291537161.2806.109.camel@edumazet-laptop>
	<1291548233.2806.212.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maximlevitsky@gmail.com, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960Ab0LHSFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:05:00 -0500
In-Reply-To: <1291548233.2806.212.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Dec 2010 12:23:53 +0100

> [PATCH] net: RCU conversion of dev_getbyhwaddr() and arp_ioctl()
> 
> dev_getbyhwaddr() was called under RTNL.
> 
> Rename it to dev_getbyhwaddr_rcu() and change all its caller to now use
> RCU locking instead of RTNL.
> 
> Change arp_ioctl() to use RCU instead of RTNL locking.
> 
> Note: this fix a dev refcount bug in llc
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
