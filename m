From: Ben Hutchings <ben@decadent.org.uk>
Subject: forcedeth driver hangs under heavy load
Date: Sun, 11 Apr 2010 00:36:46 +0100
Message-ID: <1270942606.6179.64.camel@localhost>
References: <4B9E6C60.7030300@atlanticlinux.ie>
	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>
	 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-YarqaRxEWnZ0eND/lNxD"
Cc: stephen mulcahy <smulcahy@atlanticlinux.ie>, 572201@bugs.debian.org
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43981 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752298Ab0DJXjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Apr 2010 19:39:09 -0400
In-Reply-To: <4BBCA19C.5080204@atlanticlinux.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YarqaRxEWnZ0eND/lNxD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Stephen Mulcahy reported a regression in forcedeth at
<http://bugs.debian.org/572201>.  The system information and some
diagnostic information can be found there.  Anyone able to help?

Ben.

stephen mulcahy wrote:
> When running linux-image-2.6.32-trunk-amd64, the network stops=20
> responding if large amounts of traffic are transmitted/received. Running=20
> ifdown eth0 followed by ifup eth0 restores operation of the network.=20
> There are no errors relating to this failure logged in /var/log that I=20
> could see.
>=20
> Downgrading to linux-image-2.6.30-2-amd64 results in a stable network.=20
> Not sure if this is a forcedeth specific problem or a general problem in=20
> the newer kernel (I have seen problems with forcedeth on other=20
> distro/kernel combinations).
>=20
> Happy to run further diagnostics to tie this down if you let me know=20
> what to run.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-YarqaRxEWnZ0eND/lNxD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS8ELiee/yOyVhhEJAQJwpxAAgWi4nK/MzzSjuewV7oYz7mg95QkXwFmI
uE1SbX8G5ysJHQqjhyKf2TdDKXyx/1+8eQn6jzk4j0zcLikh0ehBFfT/KvSIRaU+
NGznmo2Du+fbDPBWbcOQX+nOho4Qh24vnanuAiSlti8IRzw12nk4dVvs3PJHLvK2
84+Ekv+uW4k74VEfwZFDv3JhxYbWluEMuNeOKYByVJGFXX5E8qIybczsLIjommUC
2lripSzsGrYhbg1h5uNWybL9QA9mrziTEAkSe5AW6tpigCFDx9nu3EURwNZbqZic
z/VcMLJ3xKmgzZJSDqlnyGQJSb+PRjbPTSuY3JQYUw3o3Xyglwt6ElOVEHhFwfxJ
R4+AO0PwU0paVrK7tZNyOAkSVRZXfFH1w+PKdWtPE/odq+sX6veuH5PGUfYr+OUF
J3qu2Euz4Ng0YkV9cs/JpUeKKzbXebYh+YUjLXwmupQ8hVNsBAlxh9Z1ruaBLOjT
dzb+3QYrJvNFe4/N56bRyk5rBD8sgxuGRdnC2uwCA9Kp/vkuEAU7rADy0eX6aZsn
YciEw0GbMfHVGEYQQJt2aX8w3wgs634BO2Fiy5ylHkXm5Yk8QAiugo9fLYkQ4kr5
dH4ugVxKCjJK1QoOefOqKW7aq/J8lWfUK85Kp2vzegsZ1NN+k99u/uBbWTTd/ME2
3/qgbhk5M+o=
=tZdN
-----END PGP SIGNATURE-----

--=-YarqaRxEWnZ0eND/lNxD--
