From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 2/7] net: remove old tcp_optlen function
Date: Sat, 13 Mar 2010 10:11:28 +0100
Message-ID: <1268471488.2947.26.camel@edumazet-laptop>
References: <4B98D592.6040301@gmail.com> <4B98D9A2.8060603@gmail.com>
	 <4B9A40BC.4030301@gmail.com> <20100312174656.GA12175@bicker>
	 <4B9AC8C5.2010300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Carpenter <error27@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Simon Horman <horms@verge.net.au>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B9AC8C5.2010300@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 12 mars 2010 =C3=A0 18:05 -0500, William Allen Simpson a =C3=
=A9crit :

> In this particular instance, I suggest that you take a look at all th=
e
> places that gso_size is set, and cross index with all the code paths =
that
> place these TCP headers onto the txq without a check of doff -- as I =
did!
>=20
> I'll specifically mention the tun and virtio_net devices, but I'm als=
o
> particularly concerned with af_packet.c and skbuff.c -- and the gener=
al
> problem with inet_lro.c, too.
>=20
> Amazingly enough, folks sometimes use Linux for routers....
> --

David already pointed out fact that this code path is not used in
forwardind / routing path. Your assumptions are clearly wrong.

Can you sit down and understand this difference ?

Only *locally* generated trafic by linux kernel can enter this path.

And if a bug in linux core network stack can feed any driver a buggy
skb, bad things can happen, even if a driver is perfect.

Please point out _this_ bug _if_ it really exists, so that we can
correct this bug instead of hiding it in one thousand of drivers.

Your attacks make no sense, you know nothing about linux kernel
internals and assume it was written like other projects you were
involved to.
