From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 25 Feb 2011 19:45:38 +0100
Message-ID: <1298659538.2659.103.camel@edumazet-laptop>
References: <AANLkTikXUyQy+fjFSwagB3Uud2JPodsR2yFtt+jiZPSk@mail.gmail.com>
	 <AANLkTikmqQfT1s2Z6J+KYmqi0CuCc4+2k67eeb4ydtCM@mail.gmail.com>
	 <1298631127.2659.22.camel@edumazet-laptop>
	 <20110225.103456.226779149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ratbert.chuang@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net, mirqus@gmail.com,
	ratbert@faraday-tech.com, Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110225.103456.226779149.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 10:34 -0800, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 25 Feb 2011 11:52:07 +0100
>=20
> > Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 17:45 +0800, Po-Yu Chuang a=
 =C3=A9crit :
> >=20
> >> It's a little faster than v5 now. Thanks.
> >> I will submit the current version later.
> >>=20
> >> One more question just curious, why 128 bytes?
> >=20
> > Probably its best for NIU hardware specs
> >=20
> > You could try 64, as it should be enough for most IP/TCP/UDP proces=
sing.
>=20
> IPV6.

drivers/net/benet/be.h:70:#define BE_HDR_LEN            64

Maybe we should have a comment somewhere.

CC Ajit Khaparde <ajit.khaparde@emulex.com>
