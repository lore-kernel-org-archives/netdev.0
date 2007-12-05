From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 5 Dec 2007 20:02:28 +1100
Message-ID: <20071205090228.GA14659@gondor.apana.org.au>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au> <47560215.6050104@cn.fujitsu.com> <20071205021559.GA27707@gondor.apana.org.au> <475663D4.9040806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4806 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751245AbXLEJCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:02:35 -0500
Content-Disposition: inline
In-Reply-To: <475663D4.9040806@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 04:39:48PM +0800, Wang Chen wrote:
> Herbert Xu said the following on 2007-12-5 10:15:
> > +#define UDPX_INC_STATS_BH(sk, field) \
> > +	do { \
> > +		if ((sk)->sk_family == AF_INET) \
> > +			UDP_INC_STATS_BH(field, 0); \
> > +		else \
> > +			UDP6_INC_STATS_BH(field, 0); \
> > +	} while (0);
> > +
> 
> Because there are lot of address families, not only AF_INET
> and AF_INET6.

There may be a lot of families but only two run UDP, or rather, only
two are supported by sunrpc :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
