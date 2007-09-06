From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Thu, 06 Sep 2007 14:44:45 +0200
Message-ID: <1189082685.28781.70.camel@johannes.berg>
References: <E1ITGb2-0006Be-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LWtdbtBJirb3aZ2jyNYY"
Cc: satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1ITGb2-0006Be-00-XQvu0L+U/CjiRBuR/1fSEKKkPtS2pBon@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-LWtdbtBJirb3aZ2jyNYY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-09-06 at 20:36 +0800, Herbert Xu wrote:
> Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> >
> > Hah, I suspected as much but didn't have a chance to look yet. I had
> > plans to replace that sub_if_list with an RCU list and not require the
> > lock there, but that's far off. Any ideas how to fix this? We can't
> > reject the master stop so we have to walk the list, I guess we'll have
> > to audit the other list manipulation places, I think they're all under
> > RTNL.
>=20
> Yeah I think they're all under RTNL too.  So you don't need to
> take the lock here at all since you should already have the RTNL.

I'll take a look at them and post appropriate patches.

johannes

--=-LWtdbtBJirb3aZ2jyNYY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG3/Y9/ETPhpq3jKURAvLjAKCFSRyi4Ij0UTiBFZ/CyT1nxeIqqQCcCaaT
JOrgWZa3EoGGNxK7mFGN0KA=
=e5W9
-----END PGP SIGNATURE-----

--=-LWtdbtBJirb3aZ2jyNYY--
