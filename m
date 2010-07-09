From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 23:10:14 -0700 (PDT)
Message-ID: <20100708.231014.179943866.davem@davemloft.net>
References: <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	<1278571587.2543.9.camel@edumazet-laptop>
	<1278581971.2651.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752465Ab0GIGKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:10:00 -0400
In-Reply-To: <1278581971.2651.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Jul 2010 11:39:31 +0200

> When we need to shape traffic with low speeds, we need to disable tso on
> network interface :
> 
> ethtool -K eth0.2240 tso off
> 
> It seems vlan interfaces miss the set_tso() ethtool method.
> Propagating tso changes from lower device is not always wanted, some
> vlans want TSO on, others want TSO off.
> 
> Before enabling TSO, we must check real device supports it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks Eric.
