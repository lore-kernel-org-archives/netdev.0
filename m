From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Add IPv6 support to the ping socket.
Date: Sat, 25 May 2013 21:11:16 -0700 (PDT)
Message-ID: <20130525.211116.1055819647914301942.davem@davemloft.net>
References: <1369289851-25570-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	yoshfuji@linux-ipv6.org, segoon@openwall.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab3EZELR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 00:11:17 -0400
In-Reply-To: <1369289851-25570-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu, 23 May 2013 15:17:31 +0900

> This adds the ability to send ICMPv6 echo requests without a
> raw socket. The equivalent ability for ICMPv4 was added in
> 2011.
> 
> Instead of having separate code paths for IPv4 and IPv6, make
> most of the code in net/ipv4/ping.c dual-stack and only add a
> few IPv6-specific bits (like the protocol definition) to a new
> net/ipv6/ping.c. Hopefully this will reduce divergence and/or
> duplication of bugs in the future.
> 
> Caveats:
> 
> - Setting options via ancillary data (e.g., using IPV6_PKTINFO
>   to specify the outgoing interface) is not yet supported.
> - There are no separate security settings for IPv4 and IPv6;
>   everything is controlled by /proc/net/ipv4/ping_group_range.
> - The proc interface does not yet display IPv6 ping sockets
>   properly.
> 
> Tested with a patched copy of ping6 and using raw socket calls.
> Compiles and works with all of CONFIG_IPV6={n,m,y}.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Ok, looks pretty good, applied.
