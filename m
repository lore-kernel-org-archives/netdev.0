From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 01 Mar 2011 06:53:26 +0100
Message-ID: <1298958806.2676.27.camel@edumazet-laptop>
References: <AANLkTikXUyQy+fjFSwagB3Uud2JPodsR2yFtt+jiZPSk@mail.gmail.com>
	 <AANLkTikmqQfT1s2Z6J+KYmqi0CuCc4+2k67eeb4ydtCM@mail.gmail.com>
	 <1298631127.2659.22.camel@edumazet-laptop>
	 <20110225.103456.226779149.davem@davemloft.net>
	 <1298659538.2659.103.camel@edumazet-laptop>
	 <1298659663.2659.104.camel@edumazet-laptop>
	 <AANLkTi=MQoEKY5OLLN6f8-N7eD--Q6hL99HFFTAGU_Y4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net, mirqus@gmail.com,
	ratbert@faraday-tech.com, Ajit Khaparde <ajit.khaparde@emulex.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=MQoEKY5OLLN6f8-N7eD--Q6hL99HFFTAGU_Y4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 13:45 +0800, Po-Yu Chuang a =C3=A9crit :
> Hi Eric,
>=20
> On Sat, Feb 26, 2011 at 2:47 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> >
> > A compromise would be to use 128 for the allocation, but only copy =
64
> > bytes.
>=20
> I will use this way and submit v7 later.
>=20

BTW, even with IPV6, the first 64 bytes contain "RPS" header

We changed NET_SKB_PAD a while back and added this comment in
include/linux/skbuff.h

NET_IP_ALIGN(2) + ethernet_header(14) + IP_header(20/40) + ports(8)
