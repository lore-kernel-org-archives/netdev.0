From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: Patch: add loglevel to printk's in net/ipv4/route.c
Date: Thu, 30 Dec 2004 00:39:10 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412300037310.3495@dragon.hygekrogen.localhost>
References: <Pine.LNX.4.61.0412290256000.3528@dragon.hygekrogen.localhost>
 <41D2104D.3010406@conectiva.com.br> <Pine.LNX.4.61.0412290312540.3528@dragon.hygekrogen.localhost>
 <41D2120E.8030008@conectiva.com.br> <20041229021256.GD29323@wohnheim.fh-wedel.de>
 <41D2152F.8080501@conectiva.com.br> <Pine.LNX.4.61.0412290344340.28589@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	=?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	Networking Team <netdev@oss.sgi.com>,
	linux-net <linux-net@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jesper Juhl <juhl-lkml@dif.dk>
In-Reply-To: <Pine.LNX.4.61.0412290344340.28589@dragon.hygekrogen.localhost>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Dec 2004, Jesper Juhl wrote:

> On Wed, 29 Dec 2004, Arnaldo Carvalho de Melo wrote:
>=20
> >=20
> >=20
> > J=F6rn Engel wrote:
> > > On Wed, 29 December 2004 00:10:22 -0200, Arnaldo Carvalho de Melo=
 wrote:
> > >=20
> > > > > It doesn't make much difference, it's mostly for
> > > > > completeness/correctness.
> > > >=20
> > > > No, it does a helluva difference, give it a try :-)
> > >=20
> > >=20
> > > hint: look for "\n"
> >=20
> > hint2: Or the _lack_ of "\n" 8)
> >=20
>=20
> Ok, obviously something's wrong, but it's currently 03:44 here, so I'=
ll=20
> take a look at it tomorrow (or quite possibly the day after since I h=
ave=20
> things to do).
> Thank you for commenting, I'll dig into it at the first oppotunity I =
have.
>=20
>=20
Ok, this is a bit embarresing. Looking at the patch now after getting s=
ome=20
sleep it's quite obvious that it is wrong. I should have slept on it=20
before sending it - sorry for the noise people.

--=20
Jesper Juhl



