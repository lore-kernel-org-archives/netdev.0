From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip/link_vti*.c: Fix output for ikey/okey
Date: Mon, 7 Aug 2017 15:38:15 -0700
Message-ID: <20170807153815.7acf5b93@xeon-e3>
References: <bf2d09ad-28b8-c64c-dd60-4fb288259e3e@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/dNyKLlerprA3HDPl6dto_22"; protocol="application/pgp-signature"
Cc: <netdev@vger.kernel.org>
To: Christian Langrock <christian.langrock@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35903 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbdHGWiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 18:38:18 -0400
Received: by mail-pf0-f173.google.com with SMTP id c28so6761000pfe.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 15:38:18 -0700 (PDT)
In-Reply-To: <bf2d09ad-28b8-c64c-dd60-4fb288259e3e@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/dNyKLlerprA3HDPl6dto_22
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 7 Aug 2017 11:59:28 +0200
Christian Langrock <christian.langrock@secunet.com> wrote:

> ikey and okey are normal u32 values. There's no reason to print them as
> IPv4/IPv6 addresses.
>=20
> Signed-off-by: Christian Langrock <christian.langrock@secunet.com>

Changing output format breaks scripts that parse output.
But on the other hand, the VTI code breaks the assumption that ip command
output should be the same as input.

More likely the original output format was done to match Cisco output.


Why not print in hex like fwmark?






--Sig_/dNyKLlerprA3HDPl6dto_22
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlmI69cACgkQgKd/YJXN
5H7+rQ//dWj2nxz53uH7ZoguZxAy4hju84Orl8dOfKvMIRTc4yFRIqdz5FGs9uaE
pwXVOrARymrR0tuVXZVGvaBX+xzlIvfz11WSXUI1Xhjwz80tm9WUckUvXlV9ctUW
32j7Dfew6IVtCQNH3ONvOXYsUULF80+STiDZKb4jMOQYTWwbaXYpfbc9hWFIxlJa
a48DHIh9chEwTUc5aylkUlnXr38FVibILprCnIijoRIwah1HNu4c8BfClpRlD8s6
YfjX8x5SLgA/iccV+1MdMpLw0TRNbgA5zk+wycxNEHHLwEK3/SjoE/oM8CWsYPL7
wvXvip7/5Q4QBp5kYZdT3z3l9JrgLRgSZccS08YcUPCyaHrc0zTxFIn5Ds48TBwp
Atz0v8nsEPPJGPsQeGwmqFarr1tgtPIDMbzvloBbNaUxg/mcc87Qj/hD7N3BAOxM
n5p0Z5RKbmfvnpqxp47VAl2acw/W9kImIhm3yfq4hd69My/Eas2ojqA618N3rTNk
VSU2tivMtazYvZLnbtvCsUNrlLsiHbsHr210ln/iFD3zYo1u7M+HKdcukR4iVNQl
h84CL9tdXpDkx5RuyqOEaP+qVC7IDmrFmMZs0E2k2XOR2tZ/DeDkkKbtb2v+0Gnx
3uu9gSY+SOIAmEMAGoSF6+PYWLV5tbqfTXfV3ViRcC8UCLgJtio=
=Z+TE
-----END PGP SIGNATURE-----

--Sig_/dNyKLlerprA3HDPl6dto_22--
