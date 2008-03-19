From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Thu, 20 Mar 2008 00:31:50 +0100
Message-ID: <47E1A266.20500@imap.cc>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>	<47D98510.60801@imap.cc>	<939d53060803191052o2f43b75cu426d51f9f24e2a46@mail.gmail.com> <20080319141608.ede86a86.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig322D9505A9133F30EF2B7D23"
Cc: Benjamin Thery <ben.thery@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com, xemul@openvz.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:42890 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756586AbYCSXcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 19:32:04 -0400
In-Reply-To: <20080319141608.ede86a86.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig322D9505A9133F30EF2B7D23
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 19.03.2008 22:16 schrieb Andrew Morton:
> On Wed, 19 Mar 2008 18:52:41 +0100
> "Benjamin Thery" <ben.thery@gmail.com> wrote:
>=20
>> I bisected the problem to the commit "[NET]: Make /proc/net a symlink
>> on /proc/self/net (v3)"
[...]
>> I've attached a tiny test program that can be used to reproduce the pr=
oblem
>> without Postfix.

Thanks. Works great.

> Although this is advertised as a 2.6.25-rc5-mm1 problem, I assume the
> regression is also in mainline? 2.6.25-rc6?

My results:

up to 2.6.25-rc5 -- good
2.6.25-rc5-mm1 -- bad
2.6.25-rc6 -- bad

HTH
T.

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig322D9505A9133F30EF2B7D23
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH4aJuMdB4Whm86/kRAoadAJsHwaecacSWR1blDaxJGkDI0ueeGQCZAfzO
V7ftNLgLj91v8NRfUwHHTp8=
=LaBb
-----END PGP SIGNATURE-----

--------------enig322D9505A9133F30EF2B7D23--
