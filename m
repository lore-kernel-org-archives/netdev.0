From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: [PATCH] net, ipv6: remove redundant NULL checks before kfree in
 ip6_flowlabel.c
Date: Thu, 17 Mar 2005 07:21:01 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0503170719060.2501@dragon.hyggekrogen.localhost>
References: <Pine.LNX.4.62.0503170027390.2558@dragon.hyggekrogen.localhost>
 <20050317.115444.31670680.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050317.115444.31670680.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2005, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> In article <Pine.LNX.4.62.0503170027390.2558@dragon.hyggekrogen.localho=
st> (at Thu, 17 Mar 2005 00:36:35 +0100 (CET)), Jesper Juhl <juhl-lkml@di=
f.dk> says:
>=20
> > I considered also rewriting the=20
> >         if (fl)
> >                 fl_free(fl);
> > bit as simply fl_free(fl) as well, but that if() potentially saves tw=
o=20
> > calls to kfree() inside fl_free as well as the call to fl_free itself=
, so=20
> > I guess that's worth the if().
>=20
> I don't mind calling kfree twice itself (because that function is not
> so performance critical), but fl_free(NULL) is out because
> if fl is NULL, kfree(fl->opt) is out.
>=20
Yes, you are right ofcourse.=20
Thanks.

--=20
Jesper
