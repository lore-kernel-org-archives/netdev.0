From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: coding style improvements (remove
 assignment in if statements)
Date: Sun, 23 Nov 2014 14:29:19 -0500 (EST)
Message-ID: <20141123.142919.1812114692737446678.davem@davemloft.net>
References: <1416657725-7829-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbaKWT3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 14:29:21 -0500
In-Reply-To: <1416657725-7829-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Sat, 22 Nov 2014 12:02:05 +0000

> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 7226697..7d7733a 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -2410,8 +2410,7 @@ static int mr6_msgsize(bool unresolved, int maxvif)
>  		      + nla_total_size(0)	/* RTA_MULTIPATH */
>  		      + maxvif * NLA_ALIGN(sizeof(struct rtnexthop))
>  						/* RTA_MFC_STATS */
> -		      + nla_total_size(sizeof(struct rta_mfc_stats))
> -		;
> +		      + nla_total_size(sizeof(struct rta_mfc_stats));
>  
>  	return len;
>  }

This first of all has absolutely nothing to do with your patch, it is
not eliminating an assignment from an if statement.

Second of all, this layout is absolutely intentional.

It makes it such that when new netlink attributed are added, the
patch to add them to this calculation is minimized to one line.

Therefore, please keep that semicolon on a line all by itself.
