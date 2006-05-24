From: Phil Dibowitz <phil@ipom.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 01:01:14 -0700
Message-ID: <447412CA.50303@ipom.com>
References: <20060523.182217.59656237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig217D24056399EAADA40928DE"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ipom.com ([209.40.128.125]:57491 "EHLO
	uberhacker.sage-inc.com") by vger.kernel.org with ESMTP
	id S932157AbWEXIBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 04:01:20 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060523.182217.59656237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig217D24056399EAADA40928DE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> Some time in the next few weeks, it is likely that the 2.6.18
> merge window will open up shortly after a 2.6.17 release.
>=20
> So if you have major 2.6.18 submissions planned for the networking,
> you need to start thinking about getting it to me now.
>=20
> There is a 2.6.18 tree up at:
>=20
> master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.18.git
>=20
> All it has right now is the I/O AT stuff at the moment, and I plan to
> put Stephen Hemminger's LLC multicast/datagram changes in there as
> well.

David,

I posted a patch for adding support for network device statistic
resetting via ethtool. I saw no objections to it... it impliments the
framework as well as skge support, so it touches both your and Jeff's are=
a.

For your reference, here's the two times I've posted it this month - I'm
happy to send it along again.

2006-05-18
RESEND: [PATCH] Interface Stat Clearing Framework, skge support, ethtool
http://marc.theaimsgroup.com/?l=3Dlinux-netdev&m=3D114794065502155&w=3D2

2006-04-30
[PATCH] Interface Stat Clearing Framework, skge support, ethtool
http://marc.theaimsgroup.com/?l=3Dlinux-netdev&m=3D114636704207480&w=3D2

I'd like to get this into 2.6.18. It's self-contained, so it has little
chance of breaking other things and adds a useful feature that I've seen
a lot of requests for.

Thanks.
--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"Be who you are and say what you feel, because those who mind don't
matter and those who matter don't mind."
 - Dr. Seuss



--------------enig217D24056399EAADA40928DE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFEdBLKN5XoxaHnMrsRAuTPAJwOcuwQa0sRu2OixCydWjz/+I0QOgCeP80u
1qeY/7gpzVKhqOK+KqTN9Ps=
=N184
-----END PGP SIGNATURE-----

--------------enig217D24056399EAADA40928DE--
