From: Wesley Eddy <weddy@grc.nasa.gov>
Subject: Re: TCP rto estimation patch
Date: Fri, 23 Apr 2004 19:19:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040423231914.GB9057@grc.nasa.gov>
References: <20040423142445.GC501@grc.nasa.gov> <OFE28EC49F.335C9D5D-ON88256E7F.0073BC2E-88256E7F.0073F700@us.ibm.com>
Reply-To: weddy@grc.nasa.gov
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nVMJ2NtxeReIH9PS"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFE28EC49F.335C9D5D-ON88256E7F.0073BC2E-88256E7F.0073F700@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--nVMJ2NtxeReIH9PS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 23, 2004 at 02:06:39PM -0700, David Stevens wrote:
> I believe "2" and "3" are the scale factors for the fixed-point=20
> representation
> of the data, not the "alpha" and "beta" I remember from the estimator=20
> paper.
>

The math is done with bit shifts instead of floating point multiplications.
It's the same thing though.  The 2 means beta of 1/4 and the 3 means alpha
of 1/8.

-Wes=20

--nVMJ2NtxeReIH9PS
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAiaRyzBuYqbnj3IwRAkQ4AJ9dXt7Odh3p18MhTydzRxoXrIiGsACdEZfs
7aHa74eaeQkk2fp2VeDNwfA=
=CQbL
-----END PGP SIGNATURE-----

--nVMJ2NtxeReIH9PS--
