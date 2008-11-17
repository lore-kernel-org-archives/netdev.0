From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TPROXY] implemented IP_RECVORIGDSTADDR socket option
Date: Sun, 16 Nov 2008 19:32:10 -0800 (PST)
Message-ID: <20081116.193210.05230282.davem@davemloft.net>
References: <1226572624.7164.11.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, tproxy@lists.balabit.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hidden@sch.bme.hu, andrey@icomsw.com
To: bazsi@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1226572624.7164.11.camel@bzorp.balabit>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Thu, 13 Nov 2008 11:37:04 +0100

> In case UDP traffic is redirected to a local UDP socket,
> the originally addressed destination address/port
> cannot be recovered with the in-kernel tproxy.
> 
> This patch adds an IP_RECVORIGDSTADDR sockopt that enables
> a IP_ORIGDSTADDR ancillary message in recvmsg(). This
> ancillary message contains the original destination address/port
> of the packet being received.
> 
> Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>

I'm going to apply this to net-next-2.6, thanks!

I was going to suggest simply adding a port member to the
in_pktinfo struct, because at worst the user will see
a MSG_CTRUNC.

But I guess that is not worth the risk.

If you want to do the function pointer cleanup suggested
by David Stevens, please make that as a followon patch.

Thanks.
