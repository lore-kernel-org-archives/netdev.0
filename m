From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Mon, 03 Jan 2011 11:39:59 +0100
Message-ID: <1294051199.2892.198.camel@edumazet-laptop>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>
	 <1294008562.2535.263.camel@edumazet-laptop>
	 <1294008917.18963.3.camel@wall-e>
	 <alpine.LNX.2.00.1101022356550.11481@swampdragon.chaosbits.net>
	 <1294045732.19666.6.camel@wall-e>
	 <1294046867.2892.101.camel@edumazet-laptop>
	 <1294048469.20187.13.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Juhl <jj@chaosbits.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	daniel.baluta@gmail.com, jochen@jochen.org
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294048469.20187.13.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 janvier 2011 =C3=A0 10:54 +0100, Stefani Seibold a =C3=A9cr=
it :

> How can you do a routing, how can you determinate the MTU of the rout=
e.
> This are basics. Look into other code how this things will be handled=
 is
> in my opinion the right way, since there a no function provide to do
> this.
>=20

Hmm, how user land can perform this task then ?

Is there an open source implementation of UDPCP ?

What are its problems ? You say its dog slow, I really wonder why.
UDP stack is pretty scalable these days, yet some improvements are
possible.

Why not adding generic helpers if you believe you miss some
infrastructure ? This could benefit to other 'stacks' as well.

> Otherwise you can say the same about all the filesystem or PCI
> drvivers , which do also a lot in the same way. But since this is the
> way to do it, it is the right way.
>=20

These drivers are here because of high performance on top of high
performance specs.

While UDPCP is only a layer above UDP. If the problem comes from UDP
being too slow, it'll be slow too.
