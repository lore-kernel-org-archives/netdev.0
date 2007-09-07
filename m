From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Fri, 07 Sep 2007 16:30:15 +0200
Message-ID: <1189175415.28781.165.camel@johannes.berg>
References: <E1ITGb2-0006Be-00@gondolin.me.apana.org.au>
	 <1189085815.28781.78.camel@johannes.berg>
	 <20070906154612.GD8030@linux.vnet.ibm.com>
	 <1189171635.28781.134.camel@johannes.berg>
	 <20070907142538.GC8864@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-4XdgTktjVHwooodKhzoa"
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070907142538.GC8864-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-4XdgTktjVHwooodKhzoa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-09-07 at 07:25 -0700, Paul E. McKenney wrote:

> > I don't like ASSERT_RTNL() much because it actually tries to lock it.
> > I'd be much happer if it was WARN_ON(!mutex_locked(&rtnl_mutex)) or
> > something equivalent.
>=20
> Ah!  It would indeed be nice to have a lower-overhead ASSERT_RTNL_LIGHT()
> or whatever.

I don't know why it tries that anyway. Maybe it's from semaphore days
where you couldn't check _is_locked()?

> > In any case, I have an updated patch I'll be sending soon, and it
> > requires a new list walking primitive I'll also send.
>=20
> Look forward to seeing it!

Will send in a minute.

johannes

--=-4XdgTktjVHwooodKhzoa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG4WB3/ETPhpq3jKURAmOZAJ9TOGSuLJfpuooUTU6yWlbckOv5NACggVSj
Ken1ushUM1w6gKLvDZtlbCo=
=iT/x
-----END PGP SIGNATURE-----

--=-4XdgTktjVHwooodKhzoa--
