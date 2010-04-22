From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Thu, 22 Apr 2010 09:21:20 -0700
Message-ID: <20100422092120.603e83b8@nehalam>
References: <20100422.042157.99869295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38124 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab0DVQV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 12:21:26 -0400
In-Reply-To: <20100422.042157.99869295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Apr 2010 04:21:57 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> But it turns out using it is largely pointless since the only way to
> get the hash value(s) is through a structure which is prepended to the
> packet data (so we take a cache miss on the packet data anyways)
> instead of being able to fetch it out of the RX descriptors :-/
> 
> If anyone out there is trying to design sane hardware, please put the
> following into your RX descriptors:
> 
> 1) ethernet protocol type (u16)
> 2) a flag bit indicating if the packet destination matched one
>    of the programmed unicast MAC addresses
> 3) a flag bit indicating "multicast"
> 4) a flag bit indicating "broadcast"
> 5) at least 32-bits of the computed flow hash (u32)
> 
> kthx, bye!
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Could you make configurable via ethtool like I did for sky2.

P.s: where is that patch seems lost in patchwork
