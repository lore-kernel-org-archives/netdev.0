From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-2.6] Revert "net: Support inclusion of
 <linux/socket.h> before <sys/socket.h>"
Date: Thu, 12 Nov 2009 03:05:15 +0000
Message-ID: <1257995115.2237.90.camel@localhost>
References: <1257991205.2237.73.camel@localhost>
	 <20091111.185124.22668587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-19JBBeos2A9Wto2e1XBc"
Cc: netdev@vger.kernel.org, 538372@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60495 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759968AbZKLDFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:05:21 -0500
In-Reply-To: <20091111.185124.22668587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-19JBBeos2A9Wto2e1XBc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-11-11 at 18:51 -0800, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Thu, 12 Nov 2009 02:00:05 +0000
>=20
> > This reverts commit 9c501935a3cdcf6b1d35aaee3aa11c7a7051a305.  That
> > commit caused <linux/rtnetlink.h> to require that <sys/socket.h> is
> > included first, breaking autoconf tests for <linux/rtnetlink.h> and
> > presumably some real programs too.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> I'm not reverting this Ben.  The dependency those programs and
> autoconf tests have is _dubious_ at best.
>=20
> It means they were depending upon the libc5 checks passing, that's
> rediculious and not something we should cater to.
[...]

Sorry, I'm getting my headers mixed up.  The problem is with
<linux/netlink.h> not <linux/rtnetlink.h>.

<linux/netlink.h> will not compile for userland, because
<linux/socket.h> is no longer defining sa_family_t.  For userland, this
should be defined by <sys/socket.h>.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-19JBBeos2A9Wto2e1XBc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASvt7Z+e/yOyVhhEJAQLfow//c2JDwpxWXNirizj9kVv5ize1N8KfM7X6
PMONpkgLHqG8+Ot6KPtGxykhkpmvIridKFsQczxPfOeMfsZBk7I4xj8pjrkbgHKB
iZBBYx1RbEJztWPUtWxfGVlI+qSKco1JBgtnTDEYlnt2l1dkqXOQKhV6WdyZA6mD
YJbKzobFsUn0yNWPQtcGxYMw6/Ra7OvjHip+foPAx61RuRY9XdRerqwAIE3rvBan
6+QbJqFsexw4KV5DAB9MpENl9L+bdPxeb/JnT0ZA3E1+YocNV4fhXbFv6lhKBU7P
b4hUmOU8TZ+5MJZ1nieHHo96Hk/ADO1zTQ7JHOijlHuBT8inL/Y71YO4tbw0gurA
d+NqBD1w3nU5sh0rYcmrBE0tHphTgaHC+Uz6D37gyXhDdlZcWNrDXG+n3T4A+mQD
JDXHTw9jiYdTiK7Yzddy/srnrWul6nGsquUl3S8stXbWLfkLzXcb6KEhMX27ePHa
QbK5wAJcZNtLqzbq1kk+ytEV7hzUu/PH0QUcXGdGQLmp/79TOZ7yOFkeD74+oHfF
jjWEtIdf5B4mDkTYImr7uNTHJxKtLDTxbBVaVFlZCUl3Gcd7ClKyB6979WRH7hqg
sJmAL7pTzjXG0AzqvKRwUYbtz0oXClouV5TYmvxGS6auPV3ga/giYkL7VHRMoNZ2
dBfWWS7S7NU=
=mNT0
-----END PGP SIGNATURE-----

--=-19JBBeos2A9Wto2e1XBc--
