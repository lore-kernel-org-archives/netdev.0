From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/8] dsa: Export functions from core to modules
Date: Sun, 27 Nov 2011 22:38:57 +0000
Message-ID: <1322433537.7454.32.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
	 <1322267647.2839.382.camel@deadeye> <20111127191556.GQ795@wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MP4VqjRui8aMplNc69zS"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52321 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751030Ab1K0WjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:39:13 -0500
In-Reply-To: <20111127191556.GQ795@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MP4VqjRui8aMplNc69zS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-11-27 at 20:15 +0100, Lennert Buytenhek wrote:
[...]
> > diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> > index 56cf9b8..c9d52ca 100644
> > --- a/net/dsa/slave.c
> > +++ b/net/dsa/slave.c
> > @@ -45,6 +45,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
> >  			ds->master_mii_bus->id, ds->pd->sw_addr);
> >  	ds->slave_mii_bus->parent =3D &ds->master_mii_bus->dev;
> >  }
> > +EXPORT_SYMBOL_GPL(dsa_slave_mii_bus_init);
> > =20
> >=20
> >  /* slave device handling *********************************************=
*******/
> > @@ -402,3 +403,4 @@ dsa_slave_create(struct dsa_switch *ds, struct devi=
ce *parent,
> > =20
> >  	return slave_dev;
> >  }
> > +EXPORT_SYMBOL_GPL(dsa_slave_create);
>=20
> Why do these need to be exported?  They are only called from dsa.c,
> and dsa.c and slave.c are always linked into the same entity, even
> after your patches.

Oh, yes.  I just failed to revert these exports when I decided they
should be linked together.

Ben.

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-MP4VqjRui8aMplNc69zS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATtK8Aee/yOyVhhEJAQqtvw/+J1GKzwyYiVzyQn/UxWycC8slxtnmq0Xr
ftbsn3NWeUSglt6H0wd4OLSU4U/t0rnldelhaPkXxiKn2RlMVl1jb63EHhETA6iB
jgtISJ0m2r5K8aG0s26TMAZrQVaikFnbdY05gxYnZb6Y7ubfk/jQZWKlM40Ef3io
AUpxfAA+qgb4hFnN+imi1gR0LyrMb2Zn9FReQ2dwwtxyjr4qebayreKl2jxPTdBc
8duf35TP/mKBumr2gHbZIjrpL0Gg1ZUFIrfjlW3BgtqgIRb341m5jUElYCJHJv5+
tV1KlS/oi02xiX1bW2rBEHTFGwSoaOO2N8qoo+1EB940oUCYTkiFvpNjfCDL+WgE
aw0qezvxVHU0GIDLvA2LMcg/zTVLUD3lfo4gzKS1DE3RB7wZtUJ4iFnxz8VDVT7F
DAqLnLTOXFb6NHlpgAQR+qM0CXgV91zoLgVbNPvt7CjjedL3Tj1uhxHw3oX2jcy5
tPJOVIMDy5pHwvqS6fdnEydJiEAMwI7tnR5eVMPEziPHldDjEoIxAguj82y3DxKx
VodvRmw3h1vryQosQr4e1QpIpVf3NhnRhFjw+QaBsqvuV3nzBsK/6iZLXHIl4COp
NWYPF/571rKw0edvqQUguWy4IJuXWR4ObEhS8sE5Hgs6dCTQIk6OIipzMPPgIt3v
vvetzLRuaug=
=Hxhj
-----END PGP SIGNATURE-----

--=-MP4VqjRui8aMplNc69zS--
