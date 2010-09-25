From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Sun, 26 Sep 2010 00:33:17 +0100
Message-ID: <1285457597.2697.183.camel@localhost>
References: <20100924222434.GA7743@electric-eye.fr.zoreil.com>
	 <20100924.223709.233700415.davem@davemloft.net>
	 <1285394797.2478.54.camel@edumazet-laptop>
	 <20100925.001300.193725148.davem@davemloft.net>
	 <1285405945.2478.255.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-M1duQENH3LDaYo/Cn8hl"
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40672 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756786Ab0IYXd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 19:33:27 -0400
In-Reply-To: <1285405945.2478.255.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-M1duQENH3LDaYo/Cn8hl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-09-25 at 11:12 +0200, Eric Dumazet wrote:
[...]
> The r8169 current problem is its currently copying all incoming frames.
> I guess nobody cares or noticed the performance drop.
> (But commit c0cd884a is recent (2.6.34), this is not yet in
> production...)

Since that was a security fix it was backported to 2.6.32.12 and
probably most distribution kernels.  So yes it is in production.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-M1duQENH3LDaYo/Cn8hl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATJ6Gtue/yOyVhhEJAQLdlRAAg0vXGs6H5Bah/x9d3c/vhCD4miX9j53G
5T3tuParzYdZl3B9/xWnzPK8TaEz4A8KV8U/uME70lG/o3Wz0J4/uJC6tENKIxYW
ThI4rAObKCPP0p5T4jmdCVz1WYT+HzcQAel8TKjskpF7xdOtUngwGACiYZ8pCd/t
wnIoSHEUaDKXHDwHji74ZZq4X5xQP0Lo8eZyRPephr2Q0UFCLvrfIwWDQRhab4ED
+qqyhJKEp6DjGS+h74JCFF2YX1JFMjNpHObBnD+0rdFUuXmjtNlhZy3Ru1hsLrJU
MR3nplsNPA3A0xgfTChw6Wprztx2Jd+JUJvlDqeZ97xNV3gu3PbJNBPxteKPbijA
Zsj+be6/NLJnm5WJ6WZ/hzqSSQqn6+HCugal4ZYM+LrQdg25io4sa6y7y8UOa5iM
G2y5hWfHuVSg44KuFRTx3pFt8VmKGIs/oOTm1uZceBp1yF923zbjxWnPSwtSfqoS
EDw22tW99ZrjbF0oa2Lu3o92/A62SN53odX+E3VvMgPARS5GBSGziv0gDM3lFky6
8ioTPFfEHxVB8XinKeh5fGqRYvlfrz936b8jcO8WZA5IiqAPXquCMpvsL6m2dpC0
2mGLY5dXhBsc8827oKPXQClhhGkjK3KpC24YqgL4dgLkQgBe6H55vvYnF3LdV6LY
s4KkBT8MdiI=
=Qq3u
-----END PGP SIGNATURE-----

--=-M1duQENH3LDaYo/Cn8hl--
