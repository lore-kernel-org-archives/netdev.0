From: "James R. Leu" <jleu@mindspring.com>
Subject: Re: Linux Routers working
Date: Fri, 13 May 2005 09:09:38 -0500
Message-ID: <20050513140938.GB5384@mindspring.com>
References: <20050513041623.95169.qmail@web41425.mail.yahoo.com>
Reply-To: jleu@mindspring.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6sX45UoQRIJXqkqR"
Cc: net dev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: cranium2003 <cranium2003@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050513041623.95169.qmail@web41425.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 12, 2005 at 09:16:23PM -0700, cranium2003 wrote:
>  Hello,
>         Is there any way on linux routers to know on
> which interface packet is forwarded before actually
> packet trasmission begins? Also before packet
> processed by IP layer can it be possible to know from
> which adjecent Router'IP packet came to that router?
> regards,
> cranium

I think the OUTPUT chain in iptables already knows what the outbound
interface is, so you could make a decision based on that.

I think you can use the mac target in the PREROUTING chain to get access
to the source MAC address.

I think all of your answers are in iptables.


>=20
>=20
> 	=09
> __________________________________=20
> Yahoo! Mail Mobile=20
> Take Yahoo! Mail with you! Check email on your mobile phone.=20
> http://mobile.yahoo.com/learn/mail=20

--=20
James R. Leu
jleu@mindspring.com

--6sX45UoQRIJXqkqR
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.0 (GNU/Linux)

iD8DBQFChLUiQcSCk6yg8WERAvFKAJ9yGw3aPiUiypfZ63e8DfuOPO5JLACgo3le
2/dFTrNouev2Bpwg+S+q83U=
=AmhJ
-----END PGP SIGNATURE-----

--6sX45UoQRIJXqkqR--
