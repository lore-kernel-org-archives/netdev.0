From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
Date: Mon, 15 May 2017 12:53:16 +0200
Message-ID: <d402278a-543f-1cbb-32f9-7d61d8f62f51@uclouvain.be>
References: <20170515091828.19349-1-david.lebrun@uclouvain.be>
 <59197D53.8030104@iogearbox.net>
 <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
 <59198665.7060908@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="R77k2LQNqRPnN1I3A7DHqWLtUO9BN1pPh"
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36489 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755099AbdEOKwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 06:52:45 -0400
In-Reply-To: <59198665.7060908@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--R77k2LQNqRPnN1I3A7DHqWLtUO9BN1pPh
Content-Type: multipart/mixed; boundary="tWP3SiqKt8r71IE6E4taNl59mnx7Admcm"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: netdev@vger.kernel.org
Message-ID: <d402278a-543f-1cbb-32f9-7d61d8f62f51@uclouvain.be>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
References: <20170515091828.19349-1-david.lebrun@uclouvain.be>
 <59197D53.8030104@iogearbox.net>
 <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
 <59198665.7060908@iogearbox.net>
In-Reply-To: <59198665.7060908@iogearbox.net>

--tWP3SiqKt8r71IE6E4taNl59mnx7Admcm
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/15/2017 12:43 PM, Daniel Borkmann wrote:
>=20
> Okay, thanks!

Mmmh actually I can fix this without sending a patch to iproute2.
Handling the __USE_KERNEL_IPV6_DEFS case in seg6.h is wrong, as it is
already performed in netinet/in.h. I can fix the issue with a simpler ifd=
ef.

Will send v2.

David


--tWP3SiqKt8r71IE6E4taNl59mnx7Admcm--

--R77k2LQNqRPnN1I3A7DHqWLtUO9BN1pPh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWRmInAAKCRCNvOfruxno
A043AKCMNj0hnygLi6GYuRfbYpD9qy4nXwCfW11JWBesIGEb5Bv97uAGrHgEn28=
=d8tG
-----END PGP SIGNATURE-----

--R77k2LQNqRPnN1I3A7DHqWLtUO9BN1pPh--
