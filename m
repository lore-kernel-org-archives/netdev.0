From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
	ip_fragment
Date: Tue, 31 Aug 2010 16:24:44 +0800
Message-ID: <20100831082444.GB29281@gondor.apana.org.au>
References: <20100830200917.GA10754@stratus.com> <1283204118.2405.32.camel@edumazet-laptop> <20100830232147.GB10754@stratus.com> <1283232031.2405.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36736 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab0HaIYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 04:24:55 -0400
Content-Disposition: inline
In-Reply-To: <1283232031.2405.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 31, 2010 at 07:20:31AM +0200, Eric Dumazet wrote:
> Le lundi 30 ao=FBt 2010 =E0 19:21 -0400, Bandan Das a =E9crit :
> > >=20
> > > I wonder if we want this.
> > >=20
> > > Maybe setting skb->local_df =3D 1 in bridge should be enough ?
> > >=20
> > >=20
> > Thanks Eric for looking at this. Indeed, setting local_df to 1 seem=
s to be enough! I will
> > respin and post a different patch.
> >=20
>=20
> Reading this stuff again, I wonder if we should not revert commit
> 17762060c25590bfddd  and use a different trick

I don't quite understand the problem.  Does the packet actually
have IP options? If not why is it trying to look at IP options?

If it does have options, then we should parse options in the
bridge driver before passing it to the IP stack (or just drop
the packet).

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
