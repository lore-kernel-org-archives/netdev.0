From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: Convert LIMIT_NETDEBUG to
 net_dbg_ratelimited
Date: Tue, 11 Nov 2014 14:18:33 -0500 (EST)
Message-ID: <20141111.141833.1514022968668773382.davem@davemloft.net>
References: <1415560642.23530.43.camel@perches.com>
	<20141111.133027.1109527863491750125.davem@davemloft.net>
	<1415732357.16070.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	courmisch@gmail.com, nicolas.dichtel@6wind.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415732357.16070.8.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Nov 2014 10:59:17 -0800

> Use the more common dynamic_debug capable net_dbg_ratelimited
> and remove the LIMIT_NETDEBUG macro.
> 
> All messages are still ratelimited.
> 
> Some KERN_<LEVEL> uses are changed to KERN_DEBUG.
> 
> This may have some negative impact on messages that were
> emitted at KERN_INFO that are not not enabled at all unless
> DEBUG is defined or dynamic_debug is enabled.  Even so,
> these messages are now _not_ emitted by default.
> 
> This also eliminates the use of the net_msg_warn sysctl
> "/proc/sys/net/core/warnings".  For backward compatibility,
> the sysctl is not removed, but it has no function.  The extern
> declaration of net_msg_warn is removed from sock.h and made
> static in net/core/sysctl_net_core.c
> 
> Miscellanea:
> 
> o Update the sysctl documentation
> o Remove the embedded uses of pr_fmt
> o Coalesce format fragments
> o Realign arguments
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> V2: Remove the EXPORT_SYMBOL for net_msg_warn and make
>     it a static in net/core/sysctl_net_core.c

Applied, thanks a lot Joe.
