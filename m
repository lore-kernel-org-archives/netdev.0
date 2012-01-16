From: David Lamparter <equinox@diac24.net>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 21:29:07 +0100
Message-ID: <20120116202907.GF1077372@jupiter.n2.diac24.net>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the risk of repeating myself, Linux GRE support already has
provisions for multipoint tunnels. And unlike your code, those reuse th=
e
existing neighbor table infrastructure, including all of its user
interface and introspection capabilities.

It's actually slightly visible in your patch:

On Mon, Jan 16, 2012 at 08:45:14PM +0100, =C5=A0tefan Gula wrote:
> +++ linux-3.2.1-my/net/ipv4/ip_gre.c	2012-01-16 20:42:03.000000000 +0=
100
> @@ -716,7 +942,19 @@ static netdev_tx_t ipgre_tunnel_xmit(str
[...]
>  		/* NBMA tunnel */
>=20
>  		if (skb_dst(skb) =3D=3D NULL) {


-David
