From: Stephen Frost <sfrost@snowman.net>
Subject: Re: [IPSEC] Too many SADs!
Date: Tue, 22 Mar 2005 14:11:33 -0500
Message-ID: <20050322191133.GD8725@ns.snowman.net>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de> <20050322165928.GC8725@ns.snowman.net> <6298.1111517185@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LwW0XdcUbUexiWVK"
Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>, netdev@oss.sgi.com
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <6298.1111517185@marajade.sandelman.ottawa.on.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LwW0XdcUbUexiWVK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Michael Richardson (mcr@sandelman.ottawa.on.ca) wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
>=20
>=20
> >>>>> "Stephen" =3D=3D Stephen Frost <sfrost@snowman.net> writes:
>     Stephen> interfaces to the IPSEC in Linux.  Additionally, the
>     Stephen> problem isn't that I've got too many policies which end up
>     Stephen> requiring too many SADs- the  problem is that SADs are
>     Stephen> being created above and beyond what's actually necessary
>     Stephen> for my policies, which is a problem.  I'm not entirely sure
>=20
>   There is certainly a bug in openswan 2.3.1drX, possibly in 2.3.0,
> where more SPD entries get created than necessary.

Well, that's interesting, since my problem had been with racoon...

>   This would result in many SAD entries, since the incoming SAs are not
> removed until they expire, or the remote end asks for them to be deleted.
> =20
>   As the SAD interface in NETKEY provided by netfilter/pfkey does not
> permit any kind of "insert here" option, it is possible that there is
> some other bug whereby SAD entries multiply.

Got me, but if you're seeing this with openswan too, well, that'd be
rather interesting and might point to a problem outside of the userspace
tools...

	Stephen

--LwW0XdcUbUexiWVK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCQG3lrzgMPqB3kigRAoSYAKCVDYpxoU8EdW36WDrlOlUC/1Y5lgCglwPh
vLUjV8ROBw1jhUzGrdH7fiE=
=caNA
-----END PGP SIGNATURE-----

--LwW0XdcUbUexiWVK--
