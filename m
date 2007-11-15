From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/5] accounting unit and variable
Date: Thu, 15 Nov 2007 09:09:09 +0800
Message-ID: <20071115010909.GA21193@gondor.apana.org.au>
References: <47264F3E.3080306@redhat.com> <20071109123420.GD27984@gondor.apana.org.au> <473A6B11.7090208@redhat.com> <20071113.195549.181119456.davem@davemloft.net> <473B150A.8050208@redhat.com> <473B852B.3010107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	satoshi.oshima.fk@hitachi.com, andi@firstfloor.org,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	yoshfuji@linux-ipv6.org, yumiko.sugita.yf@hitachi.com
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4364 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754322AbXKOBJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 20:09:53 -0500
Content-Disposition: inline
In-Reply-To: <473B852B.3010107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 06:30:51PM -0500, Hideo AOKI wrote:
>
> +#define SK_DATAGRAM_MEM_QUANTUM ((unsigned int)PAGE_SIZE)
> +
> +static inline int sk_datagram_pages(int amt)
> +{
> +	/* Cast to unsigned as an optimization, since amt is always 
> positive. */
> +	return DIV_ROUND_UP((unsigned int)amt, SK_DATAGRAM_MEM_QUANTUM);
> +}
> +

Thanks, this looks OK to me.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
