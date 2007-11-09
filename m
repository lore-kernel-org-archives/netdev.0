From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/5] accounting unit and variable
Date: Fri, 9 Nov 2007 20:34:20 +0800
Message-ID: <20071109123420.GD27984@gondor.apana.org.au>
References: <47264E2D.4080109@redhat.com> <47264F3E.3080306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4553 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752088AbXKIMeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 07:34:31 -0500
Content-Disposition: inline
In-Reply-To: <47264F3E.3080306@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 05:23:10PM -0400, Hideo AOKI wrote:
>  
> +#define SK_DATAGRAM_MEM_QUANTUM ((int)PAGE_SIZE)
> +
> +static inline int sk_datagram_pages(int amt)
> +{
> +	return DIV_ROUND_UP(amt, SK_DATAGRAM_MEM_QUANTUM);
> +}

Does this really have to be int? Unsigned would let the compiler
optimise this to a simple shift.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
