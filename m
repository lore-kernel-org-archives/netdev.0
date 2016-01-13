From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH stable-3.2 stable-3.12] net: fix checksum check in
 skb_copy_and_csum_datagram_iovec()
Date: Wed, 13 Jan 2016 11:02:00 +0000
Message-ID: <1452682920.7020.32.camel@decadent.org.uk>
References: <20151228140157.6F592A0C7D@unicorn.suse.cz>
	 <568BF0FD.4010208@suse.cz> <1452012008.2768.82.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Sf0MV9uOeDoodPh9/bMQ"
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>, Michal Kubecek <mkubecek@suse.cz>,
	stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35876 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933470AbcAMLCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 06:02:09 -0500
In-Reply-To: <1452012008.2768.82.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Sf0MV9uOeDoodPh9/bMQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-01-05 at 16:40 +0000, Ben Hutchings wrote:
> On Tue, 2016-01-05 at 17:36 +0100, Jiri Slaby wrote:
> > On 12/28/2015, 03:01 PM, Michal Kubecek wrote:
> > > Recent fix "net: add length argument to
> > > skb_copy_and_csum_datagram_iovec" added to some pre-3.19 stable
> > > branches, namely
> > >=20
> > > =C2=A0 stable-3.2.y: commit 127500d724f8
> > > =C2=A0 stable-3.12.y: commit 3e1ac3aafbd0
> >=20
> > Applied this fix to 3.12. Thanks!
> [...]
>=20
> You don't want this, you want Eric's fix (commit 197c949e7, "udp:
> properly support MSG_PEEK with truncated buffers") although that's not
> upstream yet.

It's now upstream as commit 197c949e7798fbf28cfadc69d9ca0c2abbf93191.

Ben.

--=20
Ben Hutchings
Unix is many things to many people,
but it's never been everything to anybody.
--=-Sf0MV9uOeDoodPh9/bMQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVpYuqOe/yOyVhhEJAQoahw//eIAEW9vkbPzAT3gMmtdlcRAdQWmHUZZf
l7dPH9zVxzqeKJHiP1Z40h2j3LikkSjk/mRCFx/AZtIuPqzbbJY7smEYeT9Cyk22
DZ5k6SmoMXATha40kw7rm2/SDzwONaR98Kn24IllQ78QQ6OOsDIXZ8mEDzRaDjAd
BY7VUSrVIB1OmZsl+YPtyaXCAY1BPA4EuHIWCsyyxgAKL/rq7zoTZ4RDO3EjHHG0
oYlvNFYjZC3hdQ6D8xUUmBvsJw5QK7OoWNM1Gzt8X6FqvyxOrmTBb+m04dAzVC99
mA7p0qAOVg2v/ahnv+FwCXL3NASC3RxA3tuFfvEJqoDTOXpgbJsb717MFak5DJlK
ZtemJfLJOVYYoul+8HURiLqYBNMhKHXEHbdruX720FNJVKa6bSo6ynp3l2NW5Wzr
NfpNx7MOdVGaakbkOuo3UEpONu2eedJQ0swtyQYi7lIQd4izOddzQT8rm+CJx0XV
A9pP9eBy+K78h0QEmbUdk4m4+XaA/h9+KHgiQT63Z95EVbhioM7yM4oiX6YFDPaC
NK+duFYDfp3cf7DKfJxJLp+bEjtPr1ZcccZybLoBhmFAo+9j/0W0hNN9BNk0NCCR
sDZoUq9zGMPqM4gEuCNHo/7Qi2uP1iyRM2PfPuMnSW8Tv1gKj/MpHo/hOdOUvY68
KaTW8R7XN2w=
=SFLF
-----END PGP SIGNATURE-----

--=-Sf0MV9uOeDoodPh9/bMQ--
