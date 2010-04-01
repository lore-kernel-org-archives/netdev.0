From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 1 Apr 2010 14:39:57 +0800
Message-ID: <20100401063956.GA21422@gondor.apana.org.au>
References: <1270053478.26743.111.camel@bigi> <20100401003352.GA19147@gondor.apana.org.au> <1270089323.26743.138.camel@bigi> <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi> <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi> <20100401062840.GA21284@gondor.apana.org.au> <4BB43DE6.9060300@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:35028 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753699Ab0DAGkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 02:40:23 -0400
Content-Disposition: inline
In-Reply-To: <4BB43DE6.9060300@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 09:32:06AM +0300, Timo Ter=E4s wrote:
>
> On inbound it's always loopback interface. Does the same hold
> true on forward? I was under the impression that it would
> reflect the actual destination interface.

That's a good point.  I suppose there might just be some crazy
people out there using it this way.

So Jamal, I think this is a good reason why we do need a new
field instead of just overloading the current one.  Otherwise
inbound selectors and forward selectors will have different
semantics which is needlessly confusing.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
