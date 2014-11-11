From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] net: Convert LIMIT_NETDEBUG to
 net_dbg_ratelimited
Date: Tue, 11 Nov 2014 13:30:27 -0500 (EST)
Message-ID: <20141111.133027.1109527863491750125.davem@davemloft.net>
References: <1415307221.21526.0.camel@perches.com>
	<20141108.204202.2273082249078358608.davem@davemloft.net>
	<1415560642.23530.43.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	courmisch@gmail.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415560642.23530.43.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 09 Nov 2014 11:17:22 -0800

> Use the more common dynamic_debug capable net_dbg_ratelimited
> and remove the LIMIT_NETDEBUG macro.
> 
> This may have some negative impact on messages that were
> emitted at KERN_INFO that are not not enabled at all unless
> DEBUG is defined or dynamic_debug is enabled.  Even so, 
> these messages are now _not_ emitted by default.
> 
> This eliminates the use of the net_msg_warn sysctl
> "/proc/sys/net/core/warnings".
> 
> All messages are still ratelimited.
> 
> Some KERN_LEVEL uses are changed to KERN_DEBUG.
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
> Let me know if you want this consolidate patch broken up
> into multiple patches or any of the messages and the
> macro kept.

No objections, please respin with the variable moved and the EXPORT_SYMBOL
removed.

Thanks.
