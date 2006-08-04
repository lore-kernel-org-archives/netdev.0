From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 4 Aug 2006 21:55:51 +1000
Message-ID: <20060804115551.GB3995@gondor.apana.org.au>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net> <20060804101345.GA17583@gondor.apana.org.au> <44D32B57.2000304@trash.net> <20060804111604.GA25693@gondor.apana.org.au> <20060804112544.GA28774@gondor.apana.org.au> <44D33477.2060803@trash.net> <44D334BC.8040003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:17939 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932609AbWHDLzx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:55:53 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D334BC.8040003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 01:51:24PM +0200, Patrick McHardy wrote:
>
> +	if (!x->props.mode)
> +		mtu -= blksize - 4;

You probably want to check for overflows here since mtu is unsigned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
