From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add default_advmss() methods to blackhole dst_ops
Date: Fri, 18 Feb 2011 14:33:25 +0100
Message-ID: <1298036005.6201.58.camel@edumazet-laptop>
References: <20110218050321.10415.qmail@science.horizon.com>
	 <1298010735.2642.9.camel@edumazet-laptop>
	 <1298023023.2595.170.camel@edumazet-laptop>
	 <AANLkTi=GRPWNWZuORx1zoJJURE-drqEoMdTuKB9LZ8Ux@mail.gmail.com>
	 <1298035443.6201.51.camel@edumazet-laptop>
	 <AANLkTi=O1LZzSc8=qMX=R3rJpCVL8eWr1eo6NkiZXS0m@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: George Spelvin <linux@horizon.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=O1LZzSc8=qMX=R3rJpCVL8eWr1eo6NkiZXS0m@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 21:29 +0800, Changli Gao a =C3=A9=
crit :
> On Fri, Feb 18, 2011 at 9:24 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 21:16 +0800, Changli Gao a =
=C3=A9crit :
> >
> >> I am wondering why magic number 256 is used here. Is there a speci=
al
> >> reason? Thanks.
> >>
> >
> > It really doesnt matter. SYN message will be dropped anyway.
> >
> > 256 happens to be the default value
> > of /proc/sys/net/ipv4/route/min_adv_mss
> >
>=20
> Thanks for your explaining. IMHO, ip_rt_min_advmss is better than a
> magic number, here.
>=20

I had this exact idea but found we need struct net pointer to get this
value, not provided in parameters, so I falled back to the 256 value.
