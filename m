From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] r8169: offical fix for CVE-2009-4537 (overlength frame
 DMAs)
Date: Mon, 29 Mar 2010 23:21:05 +0100
Message-ID: <1269901265.8653.408.camel@localhost>
References: <20100329160356.GC22733@hmsreliant.think-freely.org>
	 <1269900105.8653.389.camel@localhost>
	 <20100329.150924.144366212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-rxVSKLRveN/TUP0Q7fdc"
Cc: nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, michael.s.gilbert@gmail.com,
	davem@davemeloft.net, romieu@fr.zoreil.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47697 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752422Ab0C2WVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 18:21:13 -0400
In-Reply-To: <20100329.150924.144366212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rxVSKLRveN/TUP0Q7fdc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-03-29 at 15:09 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 29 Mar 2010 23:01:45 +0100
>=20
> > It also sucks that the secure but low-performance behaviour is enabled
> > for all variants, while AIUI only some suffer from the bug.  I realise
> > you probably don't have access to every variant (and neither does
> > Francois) but perhaps you could come up with a test case that could be
> > used to start whitelisting common variants that don't have the bug?
>=20
> As far as we know all chip variants seem to have the problem.

That's not what I understood from the discussion of the early
back-and-forth changes to receive buffer size.

> Furthermore, this issue has been known about and investigated for
> about 3 months.  In that time no better options for handling this
> issue reliably have been discovered and implemented.
>
> Feel free to code up (and test) something better yourself if you don't
> like the fix as it exists currently. :-)

I would have had a go already, if I actually had some of this hardware
to hand.  Luckily I have managed to avoid buying any so far.  But if
anyone is prepared to loan me a NIC then I promise to have a go at it.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-rxVSKLRveN/TUP0Q7fdc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS7En0Oe/yOyVhhEJAQL+KQ/+IxUvQw46iljAZkUdX0gCk/LcOFBzmOj/
yscVtKrbZoqZljXH9Np2kbdBkjKoNatt97sbyKhg5hdhgD9EGqp07yRiS8oCoFMB
BCgf4cWriO8sE6wGU3tDLvBVLfIKFXfe9R+K2FOc6rOgacBcOf9CGaKrXjHMDVi5
FE9sn4aqBxYVJ44iJ46McDVe5S10aWk0pWGXoSPkv7mQgNt5ykdgKGZBUA2/6N7r
RsFuNzFNU0mq9jCBiITZBAyHLVsWniI+AO8VqLvE2Bar8Lu58kUG0rHPuwgtMI/C
RKgt7So5hYN0+IU4EYNEoWbSqgkNuCaqVUV+v5KWuSabL6GKSgI2r4IRucMStrCX
1MmLO6K4WrIZfMlMAjj/IPYgxEScvETD9AE5Q7mziYW3R0JPB8K9zfNsiDQAHHoO
j3/S3YksE+PsHjZ1G5UkTmrRzBgPt5/F7lmHB9WvMlhnqoEc0loBU+smeotHQoB2
905T01qwQS/+5s6C3FnZ3cTqQQYtmb2eK53Ml1xSqCAkJrFiK8qh72Jnqyb/tJ85
bLdnWjVNlZSBAu7LyOyDVUDd83xUuxCpYp/b+VoW/95SWSVbbnMEtU9iW4Hi9WDW
d5zs8pWlO9enuIiBpsZJoT2ZcDvpN6MBOF1Ku6k8oI0SVRnm6LXqhSmRdNoNVlDf
3g8tBs80h20=
=xyfb
-----END PGP SIGNATURE-----

--=-rxVSKLRveN/TUP0Q7fdc--
