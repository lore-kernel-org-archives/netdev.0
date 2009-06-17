From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: make netns aware
Date: Wed, 17 Jun 2009 23:26:23 +0200
Message-ID: <1245273983.31588.45.camel@johannes.local>
References: <1245267218.31588.41.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-HNJQFZFragc4T6tzK9V1"
Cc: Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47171 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758023AbZFQV0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 17:26:52 -0400
In-Reply-To: <1245267218.31588.41.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HNJQFZFragc4T6tzK9V1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 21:34 +0200, Johannes Berg wrote:
> This makes generic netlink network namespace aware.
> No actual generic netlink families are made namespace
> aware, they need to be checked one by one and then
> set the family->netnsok member to true.

This needs locking fixes too, of course. Sorry.

johannes

--=-HNJQFZFragc4T6tzK9V1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOV95AAoJEODzc/N7+QmaeVYQAJj3QsQaavuDkEM1AO9Etqx6
7uRKageTlkIkYWQq10Mf+l5m9j7IJc7I5+ubjEBtWUXzrFWC3jbSABGHh0+zifLo
RXzVB0kM8JlG7kA5qsHdINcZmwRC29QZMgZPsegEDNRqaCcj73UPcq8i1bWUllZS
bJHZtWFtf4JDORdcxW2YGYs11JhALx4CVHNJpoYl6zHgH+qIZGFJwtILFZPBX8qk
PswsWzYY0UYDkTGE3B+k08+el75vfiKWv0mY4vYLtpVAdVTQdBO/olT+wN18J+Cf
mC4imWLR8F7sJIT4y300mNdw6/W7CfJLmwbyB5a43Mr9PQqxCNTB0PQV27CbPpKi
tAuiSivY5+mPNdN3RJETuwdibNPovMx9gv3yDHYZTLt9JaIJr9t6e5nQJjKVRcFa
Ib3wZ+8+MeLTjUwlnknJnWCu0l4o7MUngd+EoBaIEVtRM9utFlK8fKtsuP9JKyZl
v9Z6jZhneWcM/FOx6VzDmvpeKbXquCv+fb5DufDanKM5pCQrcVTW1ycbqTiMs+V3
qNG/7loRI+oh52Dof/yhkUQEXmgkXOsrUdQvAcLn3DIMgwcmLB/OxhPt+omhd5ZW
BtsVId4lfmQDNrTnQP1DU01uHeeUmzZgKeA3huPF/7Xyg+gIx2I6KjvnUb38TTCK
Wwj0uwpX5/HXogmfMt10
=Pi0x
-----END PGP SIGNATURE-----

--=-HNJQFZFragc4T6tzK9V1--

