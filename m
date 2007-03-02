From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: whitespace fixes
Date: Fri, 02 Mar 2007 15:55:27 -0800 (PST)
Message-ID: <20070302.155527.85408614.davem@davemloft.net>
References: <20070302140449.1e86aef4@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38514
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992776AbXCBXz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 18:55:28 -0500
In-Reply-To: <20070302140449.1e86aef4@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 2 Mar 2007 14:04:49 -0800

> 
> The udp code is full of bad indenting, extra whitespace and other
> style confusion.  It makes no sense to declare functions that are used
> outside the current file (extern) as inline.
> 
> Signed-off-by: Stephen Hemminger <shemminge@linux-foundation.org>
> ---
>  net/ipv4/udp.c |  402 ++++++++++++++++++++++++++++-----------------------------
>  net/ipv6/udp.c |  175 +++++++++++++-----------
>  2 files changed, 295 insertions(+), 282 deletions(-)
> 
> --- tcp-2.6.orig/net/ipv4/udp.c	2007-03-02 12:08:06.000000000 -0800
> +++ tcp-2.6/net/ipv4/udp.c	2007-03-02 12:37:38.000000000 -0800
> @@ -120,8 +120,8 @@
>  	struct hlist_node *node;
>  
>  	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
> -		if (sk->sk_hash == num)
> -			return 1;
> +	    if (sk->sk_hash == num)
> +		return 1;

This turns tabs into spaces, it cannot be correct.

Yoshifuji fixed all the whitespace problems under net/ already
for 2.6.21
