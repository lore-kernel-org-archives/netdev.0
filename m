From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v4 11/11] ethtool.c: support absence of v4
 sockets
Date: Tue, 15 Mar 2016 23:23:29 +0000
Message-ID: <1458084209.31907.3.camel@decadent.org.uk>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
	 <1457719104-39188-12-git-send-email-ddecotig@gmail.com>
	 <1457889843.3331.36.camel@decadent.org.uk>
	 <CAG88wWbKagbn7yUVVi2GW8t1amMWZOsCdNqmB_-mZuozXQfkVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qIvic2ev37an7a/0I9YH"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>
To: David Decotigny <ddecotig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50395 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753923AbcCOXXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 19:23:42 -0400
In-Reply-To: <CAG88wWbKagbn7yUVVi2GW8t1amMWZOsCdNqmB_-mZuozXQfkVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qIvic2ev37an7a/0I9YH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-15 at 16:19 -0700, David Decotigny wrote:
> will send a v5 shortly without this patch: question below.
>=20
> about this patch: this is in prevision of a world where INET can be
> compiled out. So it is not something that matters today with current
> kernels.

OK.

> Now, as you mentioned in another patch, the only socket that survives
> various reasonable CONFIG_* gymnastics is netlink. So even though
> non-IPv4 kernels with IP support is not feasible today, I believe
> there is some logic to using netlink sockets for ethtool purposes,
> instead of IPv4 or IPv6 sockets. Shall I propose a patch to add
> ethtool support on AF_NETLINK sockets, and update the tool to try
> AF_INET first for backward compatibility reasons, then fallback to
> AF_NETLINK?

Yes, please do that.

Ben.

--=20
Ben Hutchings
Hoare's Law of Large Problems:
        Inside every large problem is a small problem struggling to get out=
.
--=-qIvic2ev37an7a/0I9YH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW6JlxAAoJEOe/yOyVhhEJxDcP/j1Wyi7VvV8beb+xdlP7FXGt
F/KpS7ElpBHfcGb5/czh4j/YmYOuo7WgEZP/gXlkkbQ2mEya9ONewA5wdliB7csD
Co/GMlasVzcizX80j/0nzVDErES1C3vQ/49pwJuw9IGNOy9wpF+KD8LKAZ0a/gfr
iWc6UeQQU0LmdiFIheAhQJB6aKg3UuX8H4Hg4ZuMc/in3zFrXwZEOkAxbt0qdrl5
nCR3B+7OnNOjsgB4bAFOMjBiUEuuFRIH4SZWa4TF3V/tr3EVFRG9j4oaLgJHSOzI
yv//c93he2T561dj3sVXO2EVsLIItevwpqJkYEgTO21ranR/h9w3YPg6T2KopmEV
pe8lx+4JFOVc9BfIWMOswJY/YgjK8ermqygexkL0yTtA7kMGQA7AbeCDj1U566DG
Ud71cb24ctxmcOCpihtCPg64Ms85jcUf/a8t+AaGOIHcRZ0oMpm5ByogbyluQ25s
4u6OjwTY1PaQNG9FDNZkIus5aQrGqs09S0HQReCATg5txifO6xdnaU+o+HN07f44
XbmotjEoEFpCHbiB1XdPeJaONjIH77GgcVYO9GybeqMaVItwPnJ0li/8n8zxVaA2
Hyw7S01PtCluqn4LLEBgxX3dVifGzUeuXYlAABXIybn9IJPIWJc4yFP1Nt000C+y
5hn+32dEpTr52Nl/4ABK
=WWe/
-----END PGP SIGNATURE-----

--=-qIvic2ev37an7a/0I9YH--
