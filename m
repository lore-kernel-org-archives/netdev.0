From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH 1/9] ipv6: implement dataplane support for rthdr type
 4 (Segment Routing Header)
Date: Mon, 17 Oct 2016 17:04:45 +0200
Message-ID: <5804E88D.4040702@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>        <1476715350-18983-2-git-send-email-david.lebrun@uclouvain.be> <20161017.105706.175400937082419121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="pkFmhRXe6Mf9oS8r7XefvaQjn9KDwODCV"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33517 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754734AbcJQPDP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:03:15 -0400
In-Reply-To: <20161017.105706.175400937082419121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--pkFmhRXe6Mf9oS8r7XefvaQjn9KDwODCV
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/17/2016 04:57 PM, David Miller wrote:
> Please don't use packed, it results in extremely inefficient code on
> several architectures.
>=20
> You can simply declare the flags as two 8-bit pieces and all will work
> out fine.

Noted, will do


--pkFmhRXe6Mf9oS8r7XefvaQjn9KDwODCV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlgE6JAACgkQjbzn67sZ6AM8sgCfRAGpFdoO0EykZq6KMEOtXDY1
ZY0An1sFtE82dmCmM/VpJyT/ojq82Mrx
=v2fB
-----END PGP SIGNATURE-----

--pkFmhRXe6Mf9oS8r7XefvaQjn9KDwODCV--
