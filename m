From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 12:22:51 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031128112251.GA18276@wohnheim.fh-wedel.de>
References: <1069974209.5349.7.camel@teapot.felipe-alfaro.com> <20031128.092326.39861126.yoshfuji@linux-ipv6.org> <20031128.092642.47232575.yoshfuji@linux-ipv6.org> <20031128.094022.106776635.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: felipe_alfaro@linuxmail.org, rmk+lkml@arm.linux.org.uk,
	davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20031128.094022.106776635.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

On Fri, 28 November 2003 09:40:22 +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL=
@ wrote:
> In article <20031128.092642.47232575.yoshfuji@linux-ipv6.org> (at Fri=
, 28 Nov 2003 09:26:42 +0900 (JST)), YOSHIFUJI Hideaki / ?$B5HF#1QL@ <y=
oshfuji@linux-ipv6.org> says:
>=20
> > >  3)   if (len)
> > >          strncpy(dst, src, len - 1);
> > >       dst[len] =3D 0;
>=20
> grr, another mistake...:
>=20
>           if (len) {
>              strncpy(dst, src, len - 1);
>              dst[len - 1];
                           ^
>           }

Did you forget ' =3D 0' there? ;)

J=F6rn

--=20
ticks =3D jiffies;
while (ticks =3D=3D jiffies);
ticks =3D jiffies;
-- /usr/src/linux/init/main.c
