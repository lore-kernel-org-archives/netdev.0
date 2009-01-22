From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp/ipv6.c: use ipv6_addr_copy
Date: Thu, 22 Jan 2009 16:18:43 -0500
Message-ID: <4978E2B3.3010109@hp.com>
References: <1232658506.15489.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Networking Team <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:21502 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbZAVVSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 16:18:46 -0500
In-Reply-To: <1232658506.15489.63.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index ceaa4aa..7862275 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -97,8 +97,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
>  		if (addr) {
>  			addr->a.v6.sin6_family = AF_INET6;
>  			addr->a.v6.sin6_port = 0;
> -			memcpy(&addr->a.v6.sin6_addr, &ifa->addr,
> -				 sizeof(struct in6_addr));
> +			ipv6_addr_copy(&addr->a.v6.sin6_addr, &ifa->addr);
>  			addr->a.v6.sin6_scope_id = ifa->idev->dev->ifindex;
>  			addr->valid = 1;
>  			spin_lock_bh(&sctp_local_addr_lock);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

ACK.  Simple enough of a cleanup.

-vlad
