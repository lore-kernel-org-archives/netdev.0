From: Jeff Sipek <jeffpc@optonline.net>
Subject: Re: [PATCH 2.6] watch64: generic variable monitoring system
Date: Fri, 03 Sep 2004 16:24:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409031624.22665.jeffpc@optonline.net>
References: <200409031307.01240.jeffpc@optonline.net>
 <200409031319.24863.jeffpc@optonline.net>
 <20040904.040727.72671952.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <20040904.040727.72671952.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki / =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
 <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday 03 September 2004 15:07, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> I agree with the basic principle; it is very similar to mine.

Yes, I saw a patch on lkml a while a go (possibly yours?) that used a=20
workqueue (IIRC.)

> However, it is too complicated isn't it?

I considered the option of removing the capability of the programmer aski=
ng=20
for a certain interval, and instead having all the variables checked ever=
y=20
WATCH64_INTERVAL.=20

> I would do per-"table" registration (instead of per-variable one);

I considered that option, but then decided to make the watch64 system gen=
eric=20
enough so that it could be used from anywhere in the kernel. Is my idea o=
f=20
having a kernel-wide subsystem like this too heavy-weight?

> watch64_getval() seems very ugly to me...

How so? Is it the multiplicity of "if (!st)"?

Jeff.

- --=20
bad pun of the week: the formula 1 control computer suffered from a race=20
condition
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBONLzwFP0+seVj/4RAvYsAKCdVy9EzivcGtwa9CDiuvy/nwWuJwCglQ4L
iIf4QXC7PA+YwQs3905sRv0=3D
=3DNkA4
-----END PGP SIGNATURE-----
