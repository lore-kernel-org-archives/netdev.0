From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [XFRM]: Add module alias for transformation type. (Re: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.)
Date: Fri, 25 May 2007 15:32:20 +1000
Message-ID: <20070525053220.GA24362@gondor.apana.org.au>
References: <1180067003902-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@axxeo.de, davem@davemloft.net, netdev@vger.kernel.org,
	jmorris@namei.org, kazunori@miyazawa.org, mk@linux-ipv6.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2303 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751177AbXEYFcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 01:32:50 -0400
Content-Disposition: inline
In-Reply-To: <1180067003902-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 25, 2007 at 01:23:23PM +0900, nakam@linux-ipv6.org wrote:
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 1e53520..c9f895f 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -19,9 +19,19 @@
>  #include <net/ipv6.h>
>  #include <net/ip6_fib.h>
>  
> +#define XFRM_PROTO_ESP		50
> +#define XFRM_PROTO_AH		51
> +#define XFRM_PROTO_COMP		108
> +#define XFRM_PROTO_IPIP		4
> +#define XFRM_PROTO_IPV6		41
> +#define XFRM_PROTO_ROUTING	IPPROTO_ROUTING
> +#define XFRM_PROTO_DSTOPTS	IPPROTO_DSTOPTS

Could we use the existing IPPROTO_* values for all of these?

Otherwise this looks pretty good.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
