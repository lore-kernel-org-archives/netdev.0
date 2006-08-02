From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/23] [PATCH] [XFRM]: Add XFRM_MODE_xxx for future use.
Date: Wed, 02 Aug 2006 14:53:40 +1000
Message-ID: <E1G88jk-0003bi-00@gondolin.me.apana.org.au>
References: <11541653852481-git-send-email-nakam@linux-ipv6.org>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:30981 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751165AbWHBEyB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 00:54:01 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <11541653852481-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masahide NAKAMURA <nakam@linux-ipv6.org> wrote:
> 
> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> index 6b42cc4..7dff1c8 100644
> --- a/include/linux/xfrm.h
> +++ b/include/linux/xfrm.h
> @@ -178,6 +178,13 @@ struct xfrm_user_sec_ctx {
>        __u16                   ctx_len;
> };
> 
> +enum {
> +       XFRM_MODE_TRANSPORT = 0,
> +       XFRM_MODE_TUNNEL = 1,
> +       XFRM_MODE_ROUTEOPTIMIZATION = 2,
> +       XFRM_MODE_IN_TRIGGER = 3,
> +};
> +

Please rebase your tree on something that's more recent.  We've had
xfrm modes for more than two months now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
