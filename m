From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Mon, 5 Jul 2010 17:07:28 -0300
Message-ID: <20100705200728.GB11096@khazad-dum.debian.net>
References: <20100705120617.GA6267@gondor.apana.org.au> <1278334754.2877.173.camel@edumazet-laptop> <20100705132245.GA6876@gondor.apana.org.au> <1278336898.2877.212.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1278336898.2877.212.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Jul 2010, Eric Dumazet wrote:
> Le lundi 05 juillet 2010 =E0 21:22 +0800, Herbert Xu a =E9crit :
> > On Mon, Jul 05, 2010 at 02:59:14PM +0200, Eric Dumazet wrote:
> > >
> > > Why do we clear full 48 bytes skb->cb[] in skb_alloc(), if no pro=
tocol
> > > stack should rely it being zero ?
> >=20
> > Unless a protocol is allocating the skb itself, then the fact
> > that skb_alloc clears skb->cb is no guarantee that the skb->cb
> > will be zero.
>=20
> I see. We could :
>=20
> Avoid this memset(skb->cb, 0, sizeof(skb->cb)) in fastpath.

Any chances of skb->cb being leaked to userspace or the network, due to
driver bugs or other such oddities?

--=20
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
