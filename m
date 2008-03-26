From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Wed, 26 Mar 2008 10:14:02 +0100
Message-ID: <47EA13DA.7070708@trash.net>
References: <200803261115.26157.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Komu Miika <Miika.Komu@hiit.fi>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56734 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbYCZJQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 05:16:08 -0400
In-Reply-To: <200803261115.26157.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Koskela wrote:
> diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
> index 091e670..20d214f 100644
> --- a/net/ipv4/esp4.c
> +++ b/net/ipv4/esp4.c
> @@ -404,7 +404,8 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
>  		break;
>  	case XFRM_MODE_BEET:
>  		/* The worst case. */
> -		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
> +		/* This will be seen to in the esp header_len */
> +		/* mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem); */
>  		break;
>  	}


Why are you disabling this?
