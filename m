From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Tue, 1 Dec 2015 10:30:48 +0100
Message-ID: <565D68C8.5050901@imap.cc>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
 <1448906497.3546.16.camel@tiscali.nl> <565C95B7.7070001@imap.cc>
 <1448917663.3546.29.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="vELnVN3T9s2MfB3PrLXNmDfWqKFQ9lIOD"
Cc: Sasha Levin <sasha.levin@oracle.com>, isdn@linux-pingi.de,
	davem@davemloft.net, gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Paul Bolle <pebolle@tiscali.nl>,
	Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448917663.3546.29.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vELnVN3T9s2MfB3PrLXNmDfWqKFQ9lIOD
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 30.11.2015 um 22:07 schrieb Paul Bolle:
> How would attaching two devices work with GIGASET_MINORS hardcoded to 1=
?

Ah, it wouldn't. You'd have to recompile with a bigger GIGASET_MINORS.

(I wonder if that would actually work. Somehow I still think of
GIGASET_MINORS as a configurable value, but it has never been anything
but 1 in the entire in-tree history of the driver.)

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--vELnVN3T9s2MfB3PrLXNmDfWqKFQ9lIOD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXWjaAAoJEFPuqx0v+F+qguAIAJKep7sCnOprIVfXnatsbKs2
+jZfy+UAgBrkwkTj7/nYRprNuojbhsQ5UyaJM2JUEvXfaOGONMqfWphngpLtWCwu
NrKxGbm4sYdV261yyP95DpP4RPK2qSxRZC65daATVgAQfnpPSIVs0K46kjERVufE
dA6zVspjUaf7UVsTE3uSkUEI+55uVbTV2ytq1nbYA1EZH2202NvMfjPd4xXGrarO
JPlnsQ1ITtmyj8r5fmnxPZECw8f42LtU8NJDeKW/QA58nPRn/zml09DtAFls6Afo
jfIxhNqKAuGmL+QPQ9dt/2S+MkKm/XGZke/4N/bFhuQ6s/LmMJ4DR41UE+R/8qc=
=0WOu
-----END PGP SIGNATURE-----

--vELnVN3T9s2MfB3PrLXNmDfWqKFQ9lIOD--
