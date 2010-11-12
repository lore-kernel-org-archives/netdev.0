From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 v2] macvlan: lockless tx path
Date: Fri, 12 Nov 2010 09:20:19 +0100
Message-ID: <4CDCF8C3.6010007@trash.net>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop> <1289459644.17691.1011.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56887 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755753Ab0KLIUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 03:20:20 -0500
In-Reply-To: <1289459644.17691.1011.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.11.2010 08:14, Eric Dumazet wrote:
> macvlan is a stacked device, like tunnels. We should use the lockless
> mechanism we are using in tunnels and loopback.
> 
> This patch completely removes locking in TX path.
> 
> tx stat counters are added into existing percpu stat structure, renamed
> from rx_stats to pcpu_stats.
> 
> Note : this reverts commit 2c11455321f37 (macvlan: add multiqueue
> capability)
> 
> Note : rx_errors converted to a 32bit counter, like tx_dropped, since
> they dont need 64bit range.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> ---
> V2: correct kerneldoc
>     u32 for tx_dropped and rx_errors

Looks good to me.

Acked-by: Patrick McHardy <kaber@trash.net>


