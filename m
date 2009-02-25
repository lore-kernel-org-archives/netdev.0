From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm selector generating IKE
Date: Wed, 25 Feb 2009 10:38:05 +0800
Message-ID: <20090225023805.GA30789@gondor.apana.org.au>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com> <20090224020839.GC18696@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BAE1@exch-one.centrify.com> <20090225003330.GA29906@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BC01@exch-one.centrify.com> <20090225022745.GA30643@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BC08@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44717 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754637AbZBYCiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 21:38:14 -0500
Content-Disposition: inline
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02C5BC08@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 06:30:41PM -0800, Paul Moore wrote:
> could u suggest a numbering for my 4 rules - as I said , no combination
> I have tried works
> 
> // for outbound connections
> subnet -> subnet[21] out
> subnet[21] -> subnet in
> // for inbound connections
> subnet[21] -> subnet out
> subnet -> subnet[21] in

If you want them to each use distinct SAs, then 1/2/3/4 or any
four distinct reqid's will do.  The point is that you should set
the reqid on the policy yourself instead of having the kernel pick
one for you at random.  Then you know what to assign to your SAs
when you create those.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
