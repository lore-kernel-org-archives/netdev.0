From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Mon, 05 Jul 2010 14:59:14 +0200
Message-ID: <1278334754.2877.173.camel@edumazet-laptop>
References: <20100705120617.GA6267@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705120617.GA6267@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 05 juillet 2010 =C3=A0 20:06 +0800, Herbert Xu a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >> 2) The layer using skb->cb[] should clear this area after use and
> >> before handing the skb to another layer.  Ubicom should modify the
> >> driver to clear the skb->cb[] area before sending it up the line.
> >>=20
> >=20
> > This is the right option. If you use one word in cb[], only your dr=
iver
> > knows how to clear it efficiently.
>=20
> Absolutely not! No protocol stack should rely on an external skb
> having a zero cb.
>=20

Why do we clear full 48 bytes skb->cb[] in skb_alloc(), if no protocol
stack should rely it being zero ?
