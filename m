From: Stephen Frost <sfrost@snowman.net>
Subject: Re: [IPSEC] Too many SADs!
Date: Tue, 22 Mar 2005 11:59:28 -0500
Message-ID: <20050322165928.GC8725@ns.snowman.net>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TRYliJ5NKNqkz5bu"
Cc: netdev@oss.sgi.com
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Content-Disposition: inline
In-Reply-To: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--TRYliJ5NKNqkz5bu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Wolfgang Walter (wolfgang.walter@studentenwerk.mhn.de) wrote:
> We had the same problem. Seems to be a limitation of the pfkey-implementa=
tion=20
> of linux.
>=20
> racoon and setkey both use the pfkey-interface.
>=20
> We switched to iproute2 and openswan which both use the netfilter-interfa=
ce.=20
> Therefor they can handle thousands of SAD and SPD rules.

Well, that's quite interesting.  I didn't realize there were multiple
interfaces to the IPSEC in Linux.  Additionally, the problem isn't that
I've got too many policies which end up requiring too many SADs- the
problem is that SADs are being created above and beyond what's actually
necessary for my policies, which is a problem.  I'm not entirely sure
why that's happening either.  At one point a SAD was being added every
second when there was *already* an apparently current SAD for the
required policy.  Not good, looks like a bug to me, and I would have
thought it was a kernel bug but I could be wrong there.

I'm certainly curious about the alternative interface to IPSEC in
Linux, and especially your claim that it's a 'netfilter' interface.
I'll certainly look into that...  What kernel are you using?  What
version of iproute2 and Openswan?  Do you have to patch the kernel?

	Stephen

--TRYliJ5NKNqkz5bu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCQE7vrzgMPqB3kigRAsEfAJ47pfPW9pXIg/onxRgPQ74AwSYtvgCghzem
EQII5fyl34+XyQRsTlF559o=
=ehm+
-----END PGP SIGNATURE-----

--TRYliJ5NKNqkz5bu--
