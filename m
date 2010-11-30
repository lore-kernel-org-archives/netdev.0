From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 21:11:55 -0500
Message-ID: <4CF45D6B.2070007@hp.com>
References: <20101129.134403.179947389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:5775 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab0K3CL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 21:11:57 -0500
In-Reply-To: <20101129.134403.179947389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2010 04:44 PM, David Miller wrote: 
> +static inline bool inet_peer_addr_equal(inet_peer_address_t *a, inet_peer_address_t *b)
> +{
> +	if (a->family == b->family) {
> +		switch (a->family) {
> +		case AF_INET:
> +			if (a->a4 == b->a4)
> +				return true;
> +			break;
> +		case AF_INET6:
> +			if (!ipv6_addr_cmp((struct in6_addr *)a,
> +					   (struct in6_addr *)b))
> +				return true;
> +			break;

ipv6_addr_equal() ?

-Brian

