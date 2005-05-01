From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: [PATCH 4/4] resource release cleanup in net/ (take 2)
Date: Sun, 1 May 2005 04:14:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0505010413260.2094@dragon.hyggekrogen.localhost>
References: <39e6f6c705043014264eb4c0c5@mail.gmail.com>
 <Pine.LNX.4.62.0505010341560.2094@dragon.hyggekrogen.localhost>
 <Pine.LNX.4.62.0505010352210.2094@dragon.hyggekrogen.localhost>
 <20050501.110929.34344394.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: juhl-lkml@dif.dk, acme@ghostprotocols.net, arnaldo.melo@gmail.com,
        davem@davemloft.net, herbert@gondor.apana.org.au, jkmaline@cc.hut.fi,
        jmorris@intercode.com.au, roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru,
        kunihiro@ipinfusion.com, mk@linux-ipv6.org,
        lksctp-developers@lists.sourceforge.net, andros@umich.edu,
        bfields@umich.edu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050501.110929.34344394.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 1 May 2005, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=CC=
=C0 wrote:

> Hello.
>=20
> In article <Pine.LNX.4.62.0505010352210.2094@dragon.hyggekrogen.localho=
st> (at Sun, 1 May 2005 03:55:37 +0200 (CEST)), Jesper Juhl <juhl-lkml@di=
f.dk> says:
>=20
> > > 	4) whitespace changes
> :
>=20
> Please add me cc: next time...
>=20
> >--- linux-2.6.12-rc3-mm1/net/ipv6/ah6.c.old3	2005-05-01 03:24:09.00000=
0000 +0200
> >+++ linux-2.6.12-rc3-mm1/net/ipv6/ah6.c	2005-05-01 03:24:20.000000000 =
+0200
> >@@ -305,6 +305,7 @@
> > 	skb_pull(skb, hdr_len);
> > 	skb->h.raw =3D skb->data;
> >=20
> >+
> > 	kfree(tmp_hdr);
> >=20
> > 	return nexthdr;
>=20
> Why?
>=20
Whoops, that was supposed to be "-" ...

--=20
Jesper
