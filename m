From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net v2] ipv6: sr: fix user space compilation error with
 old glibc
Date: Mon, 15 May 2017 16:21:09 +0200
Message-ID: <9f06720b-1a6e-2a0b-0756-70e9e73b631f@uclouvain.be>
References: <20170515110320.23369-1-david.lebrun@uclouvain.be>
 <20170515.100922.2194549018034831667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="S60dR1cuWrOUXUQnkqgbcruA9wE1gQVc9"
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:48179 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934565AbdEOOUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:20:40 -0400
In-Reply-To: <20170515.100922.2194549018034831667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--S60dR1cuWrOUXUQnkqgbcruA9wE1gQVc9
Content-Type: multipart/mixed; boundary="1Nolc0iIUxlaaSjj1xArIkqigq2vuTo8k"
From: David Lebrun <david.lebrun@uclouvain.be>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
Message-ID: <9f06720b-1a6e-2a0b-0756-70e9e73b631f@uclouvain.be>
Subject: Re: [PATCH net v2] ipv6: sr: fix user space compilation error with
 old glibc
References: <20170515110320.23369-1-david.lebrun@uclouvain.be>
 <20170515.100922.2194549018034831667.davem@davemloft.net>
In-Reply-To: <20170515.100922.2194549018034831667.davem@davemloft.net>

--1Nolc0iIUxlaaSjj1xArIkqigq2vuTo8k
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/15/2017 04:09 PM, David Miller wrote:
> Please, no.
>=20
> The reason we put together a method by which glibc and the kernel can
> stay out of eachother's way in header files is exactly so that we
> don't need ifdefs that conditionally do netinet/in.h vs. using the
> kernel header.
>=20
> There are more than a dozen other UAPI headers which make use of
> linux/in6.h and none of them jump through hoops like what is being
> proposed here, and that's on purpose.
>=20
> So special casing this one one header is really not the way to go.

Mmmh it's true that special casing in kernel headers for a user space
issue is not the best way to go.. I'll find a way to solve this in user
space only.

Sorry about the lousy patch.

David


--1Nolc0iIUxlaaSjj1xArIkqigq2vuTo8k--

--S60dR1cuWrOUXUQnkqgbcruA9wE1gQVc9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWRm5VQAKCRCNvOfruxno
A/pPAJ9PbGoEKm3CcRWaBOcRbD0hwpqN7QCdFisfmP4y6od0IuiEMfrAJBZugrE=
=mbwl
-----END PGP SIGNATURE-----

--S60dR1cuWrOUXUQnkqgbcruA9wE1gQVc9--
