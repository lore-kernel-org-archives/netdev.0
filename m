From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Wed, 22 Dec 2010 15:37:01 +0100
Message-ID: <1293028621.3027.129.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1012172310400.16569@pobox.suse.cz>
	 <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz>
	 <1293017383.3027.75.camel@edumazet-laptop>
	 <alpine.LNX.2.00.1012221231450.16569@pobox.suse.cz>
	 <alpine.LNX.2.00.1012221506500.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012221506500.16569@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 15:07 +0100, Jiri Kosina a =C3=
=A9crit :

>=20
> OK, so current vanilla (not even net-next needed) seems to correctly=20
> handle initcwnd value and sends as many packets as fit into it, inste=
ad of=20
> waiting after one or two MSS-sized packets. So someone already fixed =
it=20
> in some other way apparently. Sorry for the noise.
>=20

Indeed ;)

net-next was necessary at least for the other side, so that its SYNACK
packet advertizes a large enough window ;)
