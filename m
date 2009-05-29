From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Fri, 29 May 2009 19:28:21 +1000
Message-ID: <20090529092821.GA11725@gondor.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au> <20090527175223.GB7804@neterion.com> <20090527230858.GA24278@gondor.apana.org.au> <20090528152143.GA4501@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <ben.lahaise@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58923 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751827AbZE2J2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 05:28:25 -0400
Content-Disposition: inline
In-Reply-To: <20090528152143.GA4501@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2009 at 11:21:43AM -0400, Benjamin LaHaise wrote:
> 
> With GRO off I'm getting ~4.7-5Gbps to the receiver which is CPU bound with 
> netperf.  With GRO on, that drops to ~3.9-4.3Gbps.  The only real difference 
> is the entry point into the net code being napi_gro_receive() vs 
> netif_receive_skb().

That doesn't sound right at all.  Can you run tcpdump on it to see
if it's actually aggregating?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
