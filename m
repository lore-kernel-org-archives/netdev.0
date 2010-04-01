From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 1 Apr 2010 14:01:45 +0800
Message-ID: <20100401060145.GB20865@gondor.apana.org.au>
References: <1270053478.26743.111.camel@bigi> <20100401003352.GA19147@gondor.apana.org.au> <1270089323.26743.138.camel@bigi> <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:58313 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752752Ab0DAGCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 02:02:12 -0400
Content-Disposition: inline
In-Reply-To: <4BB42692.9010105@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 07:52:34AM +0300, Timo Ter=E4s wrote:
>
> IMHO, it's slightly confusing that in/fwd is split, but out is not.
> But that's the way it works. If you now override the how interface
> is checked for 'out' policy, it'll break current behaviour.

Unless I've misunderstood what his patch is trying to do, it would
seem that out policies would be completely unchanged.

=46orward policies are not used on output.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
