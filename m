From: Stephen Frost <sfrost@snowman.net>
Subject: Re: [IPSEC] Too many SADs!
Date: Tue, 22 Mar 2005 19:33:10 -0500
Message-ID: <20050323003310.GE8725@ns.snowman.net>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de> <20050322224819.GB4924@questra.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rz+pwK2yUstbofK6"
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050322224819.GB4924@questra.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--rz+pwK2yUstbofK6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Scott Mcdermott (smcdermott@questra.com) wrote:
> What, openswan uses PF_KEY last I checked on kernel 2.6.  I
> guess you can use KLIPS, but why would you? What's this
> "netfilter-interface" to ipsec code?

This confused me too...

> I had the exact same problem the original poster had with
> Racoon.  SPDs would multiply without bounds, seemingly
> geometrically.

Yeah.  Not good. :(

> I switched to strongswan and the problems immediately
> vanished.  There is some bug in racoon where it doesn't
> replace SPDs.  I used the latest ipsec-utils and kernel and
> this problem did not go away until I switched instead to
> strongswan (still using PF_KEY) (it also worked with
> openswan).

Sounds like I may need to check out strongswan/openswan. =20
I can tell you I wasn't exactly a fan of freeswan for a variety
of reasons.  I'm suprised there havn't been more people
talking about and looking into fixing this, kind of concerning..

	Thanks,

		Stephen

--rz+pwK2yUstbofK6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCQLlErzgMPqB3kigRAgzEAJ417C1FG8/LJDk2D06g/Q0uktkE4QCbBBJD
YynzJXlu9+jk7AbOMhjHPCw=
=NtUT
-----END PGP SIGNATURE-----

--rz+pwK2yUstbofK6--
