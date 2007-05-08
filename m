From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v2] Add rtl8187 wireless driver
Date: Mon, 7 May 2007 20:03:24 -0400
Message-ID: <200705072003.29448.flamingice@sourmilk.net>
References: <200705071022.11711.flamingice@sourmilk.net> <200705071917.25414.flamingice@sourmilk.net> <20070507.162518.35013789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1562274.oebPpi6ZBI";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070507.162518.35013789.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1562274.oebPpi6ZBI
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 07 May 2007 19:25, David Miller wrote:
> I know this sounds trite, but when merging and researching up to 450
> patches at a time like I have to, this stuff starts to matter.
>
> Please put things as high in the directory hierachy as possible and
> when you can put the entire driver into a single source file do so.
>
Sure. I generally prefer that too, but all the drivers I put in wireless-de=
v=20
were put in separate directories because I didn't want to break the pattern.

> The only significant argument you present is the code sharing one for
> the radio stuff, but that isn't realized yet and you can certainly
> split the code out once you make that sharing a reality.
Having different modules for different radio chips really isn't the point o=
f=20
keeping it in a separate file. (in fact, rtl8187_rtl8225.c actually contain=
s=20
support for two versions of the rtl8225 radio) It's just that=20
rtl8187_rtl8225.c is basically a bunch of numbers with a bit of glue code t=
o=20
send them to the hardware. Not much is missed if you decide not to look at=
=20
how the radio tuning works, and I like to avoid looking at that code if I=20
can. It's also consistent with how the (unreleased) rtl8180 driver works,=20
which really does have support for different radios in different files.

But of course, we can just make an exception for rtl8187. Would merging the=
=20
files together make that much of a difference for you?

=2DMichael Wu

--nextPart1562274.oebPpi6ZBI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGP75RT3Oqt9AH4aERArWhAKDIrPlqESQGRu1liJUy71aLRXlsfQCguNLG
gCDrRTO/dxU5G92aSk5dAiA=
=/gYw
-----END PGP SIGNATURE-----

--nextPart1562274.oebPpi6ZBI--
