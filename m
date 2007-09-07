From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Fri, 07 Sep 2007 16:35:59 +0200
Message-ID: <1189175759.28781.169.camel@johannes.berg>
References: <E1ITGb2-0006Be-00@gondolin.me.apana.org.au>
	 <1189085815.28781.78.camel@johannes.berg>
	 <20070906154612.GD8030@linux.vnet.ibm.com>
	 <1189171635.28781.134.camel@johannes.berg>
	 <20070907142538.GC8864@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-IdO4tpi0nZG8DJ8ISM4+"
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


--=-IdO4tpi0nZG8DJ8ISM4+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-09-07 at 07:25 -0700, Paul E. McKenney wrote:

> > > > @@ -226,22 +225,22 @@ void ieee80211_if_reinit(struct net_devi
> > > >  		/* Remove all virtual interfaces that use this BSS
> > > >  		 * as their sdata->bss */
> > > >  		struct ieee80211_sub_if_data *tsdata, *n;
> > > > -		LIST_HEAD(tmp_list);
> > > >=20
> > > > -		write_lock_bh(&local->sub_if_lock);
> > >=20
> > > This code is also protected by RTNL?
> >=20
> > Yes.
>=20
> Comment?  (Or is it in the function header?)

Oh, forgot to say: yes, there is a comment further up and even an
ASSERT_RTNL()

johannes

--=-IdO4tpi0nZG8DJ8ISM4+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG4WHP/ETPhpq3jKURAr3DAKCDiqVlmDTgtNA0MrlPeedNvxUItACgnz5U
LagOxuLcia2E1MN7EXK3TPA=
=f/3v
-----END PGP SIGNATURE-----

--=-IdO4tpi0nZG8DJ8ISM4+--
