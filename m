From: David Hollis <dhollis@davehollis.com>
Subject: Re: Network driver test suite?
Date: Thu, 06 Jan 2005 08:43:41 -0500
Message-ID: <1105019021.5804.4.camel@dhollis-lnx.centricconsulting.com>
References: <1104956386.3877.58.camel@dhollis-lnx.centricconsulting.com>
	 <41DC65DB.1010907@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QyYPyklJnchyC1iCRJ3z"
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
In-Reply-To: <41DC65DB.1010907@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-QyYPyklJnchyC1iCRJ3z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2005-01-05 at 17:10 -0500, Jeff Garzik wrote:
> David Hollis wrote:
> > Is there any kind of test suite (automated or list of tests) available
> > for testing Linux network drivers?  I'm completing the addition of a fe=
w
>=20
>=20
> No, but I would love to someone to write one!!!
>=20
> 	Jeff (in a rare case of multi-exclamation-point use)
>=20
>=20
What kinds of things do you think should be tested?  What I can think of
in no particular order and certainly not complete:

Simple, standard ping remote host
pings with various crazy large packet sizes
mii-tool
ethtool, all of the various options.  Not all need to be supported
certainly, but there is a set of basic ones that really should be
Changing MTU to various sizes
Configuring VLANs and being able to send/recv traffic

What other types of things should be tested?

--=20
David Hollis <dhollis@davehollis.com>

--=-QyYPyklJnchyC1iCRJ3z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB3UCNxasLqOyGHncRAu8rAJ4gFIGclJq0vyTZ3e3aSlVK1YF2twCfXX2O
Is9ZfiSaVj2z4WfvHjlXWlk=
=wvIS
-----END PGP SIGNATURE-----

--=-QyYPyklJnchyC1iCRJ3z--
