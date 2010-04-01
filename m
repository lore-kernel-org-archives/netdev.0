From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 1 Apr 2010 14:28:40 +0800
Message-ID: <20100401062840.GA21284@gondor.apana.org.au>
References: <1270053478.26743.111.camel@bigi> <20100401003352.GA19147@gondor.apana.org.au> <1270089323.26743.138.camel@bigi> <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi> <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38932 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753434Ab0DAG3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 02:29:08 -0400
Content-Disposition: inline
In-Reply-To: <4BB43B38.1060004@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 09:20:40AM +0300, Timo Ter=E4s wrote:
>
> But my statement still holds. If iif/oif is swapped, it's changing
> current semantics and can end up breaking setups. Both are still
> valid for 'in' and 'fwd' policies too, right? What if I'm using
> 'in' policy to make sure that all stuff arriving via 'eth0' is
> encrypted, but 'eth1' is trusted and does not need xfrm. This
> would break.

The thing is if you're currently specifying an ifindex in the
selector for inbound/forward, it probably just won't work as
it'll be matched against oif which is meaningless on inbound
and forward.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
