From: Martijn van Oosterhout <kleptog@svana.org>
Subject: Re: Very slow change of IP in kernel (slow socket?).
Date: Wed, 22 Dec 2004 17:26:32 +0100
Message-ID: <20041222162632.GC29278@svana.org>
References: <41C895D6.2040001@cs.columbia.edu>
Reply-To: Martijn van Oosterhout <kleptog@svana.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ghzN8eJ9Qlbqn3iT"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Andrea G Forte <andreaf@cs.columbia.edu>
Content-Disposition: inline
In-Reply-To: <41C895D6.2040001@cs.columbia.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ghzN8eJ9Qlbqn3iT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Seems long, but have you condered other possible delays, like ARP,
routing daemons, etc. BTW, I don't quite understand what you mean by
changing IPs, because "ip route add" adds routes, not IPs. Presumably
you're using an unbound UDP socket. You need to be a bit clearer about
what you're actually trying to do...

On Tue, Dec 21, 2004 at 04:29:58PM -0500, Andrea G Forte wrote:
> Hi all,
>=20
> after some talking I decided to try again and post a specific thread for=
=20
> this problem.
> I noticed that when I change IP address for the same wireless card=20
> (since I am moving to a different subnet I need a new IP), the actual=20
> change in the kernel happens between 300 to 500 ms later. In particular,=
=20
> after changing the IP (ip route add...) and updating route table and=20
> default gw, the actual data packets are sent using the new IP only after=
=20
> 300 to 500 ms after setting all the above.
> Does anyone of you know what this could be related to? Or, does anyone=20
> of you know where in the kernel code I could start looking for some answe=
rs?
> I have already had some feedback with suggestions to look into the=20
> route_cache, however this does not seem to me as a route problem but=20
> more as a socket problem and perhaps some kind of timer that is set to=20
> refresh the socket info in the kernel.
>=20
> Any help would be really appreciated.
>=20
> Thanks all,
> Andrea
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Martijn van Oosterhout   <kleptog@svana.org>   http://svana.org/kleptog/
> Patent. n. Genius is 5% inspiration and 95% perspiration. A patent is a
> tool for doing 5% of the work and then sitting around waiting for someone
> else to do the other 95% so you can sue them.

--ghzN8eJ9Qlbqn3iT
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQFByaA4Y5Twig3Ge+YRAkZDAJkBSeRFUdN25wAQY0muOxwjlKI8IgCfYB2B
Y0GJbUUjhs7bD9kVMwmF5cg=
=wlKq
-----END PGP SIGNATURE-----

--ghzN8eJ9Qlbqn3iT--
